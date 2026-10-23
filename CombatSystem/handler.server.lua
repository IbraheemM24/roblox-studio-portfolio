local RegionModule = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RotatedRegion3"))
local Values = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Values"))
local RP = game:GetService('ReplicatedStorage')

-- Damage multipliers per combo hit
local ComboMultipliers = {
	[1] = 1.0,   -- First hit: 100% damage
	[2] = 1.0,   -- Second hit: 100% damage
	[3] = 1.1,   -- Third hit: 110% damage
	[4] = 1.1,   -- Fourth hit: 110% damage
	[5] = 1.2,   -- Fifth hit: 120% damage
	[6] = 1.2,   -- Sixth hit: 120% damage
	[7] = 1.3,   -- Seventh hit: 130% damage
	[8] = 2.5,   -- M2 Finisher: 250% damage (HEAVY HIT)
}

local function Curve(t, p0, p1, p2)
	local A = p0:Lerp(p1, t)
	local B = p1:Lerp(p2, t)
	return A:Lerp(B, t)
end

-- Get player's actual damage (with clan buffs AND combo multiplier)
local function getPlayerDamage(player, comboNumber)
	local stats = player:FindFirstChild("Stats")
	if not stats then return 10, 1.0 end -- Fallback

	local baseDamage = stats.Damage.Value

	-- Check if player has clan damage buff
	local buffedDamage = player:GetAttribute("BuffedDamage")
	if buffedDamage then
		baseDamage = buffedDamage
	end

	-- Apply combo multiplier
	local comboMult = ComboMultipliers[comboNumber] or 1.0
	local finalDamage = baseDamage * comboMult

	return finalDamage, comboMult
end

script.Parent.OnServerEvent:Connect(function(plr, Type, Punch1, Punch2, isFinal, comboNumber)
	print("Combat Started | Type:", Type, "| Combo:", comboNumber, "| Final:", isFinal)

	local Char = plr.Character
	if not Char then return end

	local Hum = Char:FindFirstChild("Humanoid")
	local HumRP = Char:FindFirstChild("HumanoidRootPart")
	if not Hum or not HumRP then return end

	-- Get combo number (default to 1 if not provided)
	comboNumber = comboNumber or 1

	-- Get player's damage with combo multiplier
	local playerDamage, comboMult = getPlayerDamage(plr, comboNumber)

	local function Hitbox()
		Values:CreateValue("BoolValue", Char, "NoJump", false, 1)
		local HitTable = {}

		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(9, 9, 9)
		part.CFrame = HumRP.CFrame * CFrame.new(0, 0, part.Size.Z - (part.Size.Z * 2) + (part.Size.Z) / 2)
		part.Parent = workspace
		game.Debris:AddItem(part, .1)

		local Region = RegionModule.FromPart(part)
		local Results = Region:FindPartsInRegion3(nil, 250)

		for i, v in pairs(Results) do
			local Ehum = v.Parent:FindFirstChild("Humanoid")
			local EhumRP = v.Parent:FindFirstChild("HumanoidRootPart")

			if Ehum and EhumRP and v.Parent ~= Char and table.find(HitTable, v.Parent) == nil and not Char:FindFirstChild("Stun") then
				local LookVector1 = (EhumRP.Position - HumRP.Position).unit
				local LookVector2 = EhumRP.CFrame.LookVector
				local DotProduct = math.acos(LookVector2:Dot(LookVector1))

				table.insert(HitTable, v.Parent)

				-- Perfect Block
				if v.Parent:FindFirstChild("PB") then
					local BlockFX = RP:WaitForChild('Assets'):WaitForChild('FX'):WaitForChild('PBFX'):WaitForChild('HitFX'):Clone()
					BlockFX.Parent = EhumRP
					game.Debris:AddItem(BlockFX, 2)

					local AnimTracks = Hum:GetPlayingAnimationTracks()
					script.Parent:FireClient(plr, "PB")

					for _, track in pairs(AnimTracks) do
						track:AdjustSpeed(0)
						delay(2.5, function() track:AdjustSpeed(1) end)
					end

					local Sound = script:WaitForChild("PB"):Clone()
					Sound.Parent = EhumRP
					Sound:Play()
					game.Debris:AddItem(Sound, 3)

					local DmgCounter = script:WaitForChild("DmgCounter"):Clone()
					DmgCounter.Parent = workspace
					DmgCounter.Position = EhumRP.Position
					DmgCounter.Counter.Number.Text = "Perfect Block"
					DmgCounter.Counter.Number.TextColor3 = Color3.fromRGB(85, 85, 255)
					DmgCounter.Counter.Number.TextStrokeColor3 = Color3.fromRGB(85, 0, 255)

					local goal = {TextColor3 = Color3.fromRGB(255, 255, 255)}
					local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0), goal)
					tween:Play()

					game.Debris:AddItem(DmgCounter, .4)

					local P1 = EhumRP.Position
					local P2 = P1 + Vector3.new(math.random(-3, 3), math.random(2, 10), math.random(-3, 3))
					local P3 = P2 + Vector3.new(0, -15, 0)
					task.spawn(function()
						for i = 0, 1, 0.045 do
							DmgCounter.Position = Curve(i, P1, P2, P3)
							task.wait()
						end
					end)

					for _, v in pairs(BlockFX:GetChildren()) do
						local EmitCount = v:GetAttribute("EmitCount")
						if EmitCount then v:Emit(EmitCount) end
					end

					Values:CreateValue("BoolValue", Char, "StopStun", false, 2.5)
					return
				end

				-- Ground block break (finisher breaks block from front)
				if v.Parent:FindFirstChild("Blocking") and isFinal == true and DotProduct < 1.5 then
					local BlockFX = RP:WaitForChild('Assets'):WaitForChild('FX'):WaitForChild('BlockFX'):WaitForChild('HitFX'):Clone()
					BlockFX.Parent = EhumRP
					game.Debris:AddItem(BlockFX, 2)

					for _, c in pairs(EhumRP.Parent:GetChildren()) do
						if c.Name == "Blocking" then c:Destroy() end
					end

					for _, track in pairs(Ehum:GetPlayingAnimationTracks()) do
						track:Stop()
					end

					local GB = Ehum:LoadAnimation(script:WaitForChild("GB"))
					GB:Play()
					delay(1.5, function() GB:Stop() end)

					local Sound = script:WaitForChild("BB"):Clone()
					Sound.Parent = EhumRP
					Sound:Play()
					game.Debris:AddItem(Sound, 3)

					local DmgCounter = script:WaitForChild("DmgCounter"):Clone()
					DmgCounter.Parent = workspace
					DmgCounter.Position = EhumRP.Position
					DmgCounter.Counter.Number.Text = "Broken"
					Values:CreateValue("BoolValue", EhumRP.Parent, "StopStun", false, 1.5)

					local goal = {TextColor3 = Color3.fromRGB(255, 255, 255)}
					local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0), goal)
					tween:Play()
					game.Debris:AddItem(DmgCounter, .4)

					local P1 = EhumRP.Position
					local P2 = P1 + Vector3.new(math.random(-3, 3), math.random(2, 10), math.random(-3, 3))
					local P3 = P2 + Vector3.new(0, -15, 0)
					task.spawn(function()
						for i = 0, 1, 0.045 do
							DmgCounter.Position = Curve(i, P1, P2, P3)
							task.wait()
						end
					end)

					local BV = Instance.new("BodyVelocity", EhumRP)
					BV.Velocity = HumRP.CFrame.LookVector * 10
					BV.MaxForce = Vector3.new(15000, 15000, 15000)
					game.Debris:AddItem(BV, .2)

					local BV2 = Instance.new("BodyVelocity", HumRP)
					BV2.Velocity = HumRP.CFrame.LookVector * 10
					BV2.MaxForce = Vector3.new(15000, 15000, 15000)
					game.Debris:AddItem(BV2, .2)

					for _, v in pairs(BlockFX:GetChildren()) do
						local EmitCount = v:GetAttribute("EmitCount")
						if EmitCount then v:Emit(EmitCount) end
					end
					return
				end

				-- Regular block (blocks hits from front)
				if v.Parent:FindFirstChild("Blocking") and DotProduct < 1.5 then
					local BlockFX = script:WaitForChild("BlockFX"):WaitForChild("HitFX"):Clone()
					BlockFX.Parent = EhumRP
					game.Debris:AddItem(BlockFX, 2)

					local Sound = script:WaitForChild("Blocked"):Clone()
					Sound.Parent = EhumRP
					Sound:Play()
					game.Debris:AddItem(Sound, 1)

					local DmgCounter = script:WaitForChild("DmgCounter"):Clone()
					DmgCounter.Parent = workspace
					DmgCounter.Position = EhumRP.Position
					DmgCounter.Counter.Number.Text = "Blocked"
					DmgCounter.Counter.Number.TextColor3 = Color3.fromRGB(199, 199, 199)
					DmgCounter.Counter.Number.TextStrokeColor3 = Color3.fromRGB(152, 152, 152)

					local goal = {TextColor3 = Color3.fromRGB(255, 255, 255)}
					local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0), goal)
					tween:Play()

					game.Debris:AddItem(DmgCounter, .4)

					local P1 = EhumRP.Position
					local P2 = P1 + Vector3.new(math.random(-3, 3), math.random(2, 10), math.random(-3, 3))
					local P3 = P2 + Vector3.new(0, -15, 0)
					task.spawn(function()
						for i = 0, 1, 0.045 do
							DmgCounter.Position = Curve(i, P1, P2, P3)
							task.wait()
						end
					end)

					local BV = Instance.new("BodyVelocity", EhumRP)
					BV.Velocity = HumRP.CFrame.LookVector * 10
					BV.MaxForce = Vector3.new(15000, 15000, 15000)
					game.Debris:AddItem(BV, .2)

					local BV2 = Instance.new("BodyVelocity", HumRP)
					BV2.Velocity = HumRP.CFrame.LookVector * 10
					BV2.MaxForce = Vector3.new(15000, 15000, 15000)
					game.Debris:AddItem(BV2, .2)

					for _, v in pairs(BlockFX:GetChildren()) do
						local EmitCount = v:GetAttribute("EmitCount")
						if EmitCount then v:Emit(EmitCount) end
					end
					return
				end

				-- Regular damage (WITH COMBO MULTIPLIERS)
				local DmgCounter = script:WaitForChild("DmgCounter"):Clone()
				DmgCounter.Parent = workspace
				DmgCounter.Position = EhumRP.Position

				-- Show damage number
				DmgCounter.Counter.Number.Text = "-" .. math.floor(playerDamage)

				-- Change color for finisher hits
				if comboNumber == 8 then
					DmgCounter.Counter.Number.TextColor3 = Color3.fromRGB(255, 85, 85) -- Red for finisher
					DmgCounter.Counter.Number.TextStrokeColor3 = Color3.fromRGB(200, 0, 0)
				end

				local goal = {TextColor3 = Color3.fromRGB(255, 255, 255)}
				local tween = game:GetService("TweenService"):Create(DmgCounter.Counter.Number, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0), goal)
				tween:Play()
				game.Debris:AddItem(DmgCounter, .4)

				local P1 = EhumRP.Position
				local P2 = P1 + Vector3.new(math.random(-3, 3), math.random(2, 10), math.random(-3, 3))
				local P3 = P2 + Vector3.new(0, -15, 0)
				task.spawn(function()
					for i = 0, 1, 0.045 do
						DmgCounter.Position = Curve(i, P1, P2, P3)
						task.wait()
					end
				end)

				if Punch2 then
					local EnemyAnim = Ehum:LoadAnimation(Punch2)
					EnemyAnim:Play()
				end

				local Sound = script:WaitForChild("PunchSound"):Clone()
				Sound.Parent = EhumRP
				Sound:Play()
				game.Debris:AddItem(Sound, 1)

				Values:CreateValue("BoolValue", EhumRP.Parent, "Stun", false, .6)

				-- Stronger pushback for finisher
				local pushStrength = comboNumber == 8 and 50 or 10

				local BV = Instance.new("BodyVelocity", EhumRP)
				BV.Velocity = HumRP.CFrame.LookVector * pushStrength
				BV.MaxForce = Vector3.new(15000, 15000, 15000)
				game.Debris:AddItem(BV, .2)

				local BV2 = Instance.new("BodyVelocity", HumRP)
				BV2.Velocity = HumRP.CFrame.LookVector * 10
				BV2.MaxForce = Vector3.new(15000, 15000, 15000)
				game.Debris:AddItem(BV2, .2)

				-- HitFX
				local HitFX = RP:WaitForChild('Assets'):WaitForChild('FX'):WaitForChild('HitFX'):WaitForChild("HitFX"):Clone()
				HitFX.Parent = EhumRP
				game.Debris:AddItem(HitFX, 1)
				for _, v in pairs(HitFX:GetChildren()) do
					if v.Name == "Crescents" then v:Emit(5) end
					if v.Name == "Gradient" then v:Emit(1) end
					if v.Name == "Shards" then v:Emit(10) end
					if v.Name == "Specs" then v:Emit(10) end
				end

				-- APPLY DAMAGE (with clan buffs AND combo multiplier)
				Ehum:TakeDamage(playerDamage)

				print(string.format("[Combat] %s dealt %.1f damage (Combo %d, x%.1f) to %s", 
					plr.Name, playerDamage, comboNumber, comboMult, v.Parent.Name))
			end
		end
		Region = nil
	end

	local function Animation()
		if Punch1 then 
			Hum:LoadAnimation(Punch1):Play() 
		end
	end

	if Type == "Animation" and Punch1 then
		Animation()
		Values:CreateValue("BoolValue", Char, "Swinging", false, .2)
	end

	if Type == "Hitbox" then
		Hitbox()
	end
end)
