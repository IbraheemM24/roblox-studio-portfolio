local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local HitboxSettings = require(script:WaitForChild("HitboxSettings1"))
local tool = script.Parent
local HS = nil
local toolEquipped = false
local idleTrack
local combatWalkTrack
local runningConnection

-- function to (re)setup hitbox system
local function SetupHitbox()
	if not Player.Character then
		Player.CharacterAdded:Wait()
	end
	HS = HitboxSettings.new(Player, Vector3.new(6, 7, 6))
	HS.Animation1 = script.HitboxSettings1.Server.Handler.Punch1
	HS.Animation2 = script.HitboxSettings1.Server.Handler.Punch2
	HS.Animation3 = script.HitboxSettings1.Server.Handler.Punch3
	HS.Animation4 = script.HitboxSettings1.Server.Handler.Punch4
	HS.Animation5 = script.HitboxSettings1.Server.Handler.Punch5
	HS.Animation6 = script.HitboxSettings1.Server.Handler.Punch6
	HS.Animation7 = script.HitboxSettings1.Server.Handler.Punch7
	HS.Animation8 = script.HitboxSettings1.Server.Handler.Punch8
	print("DEBUG | Hitbox system setup for new character")
end

-- initial setup
SetupHitbox()

-- re-setup after death
Player.CharacterAdded:Connect(function()
	task.wait(0.2)
	SetupHitbox()
end)

-- Tool equip tracking
tool.Equipped:Connect(function()
	toolEquipped = true
	print("DEBUG | Tool equipped")

	local char = Player.Character
	if not char then print("DEBUG | No character") return end

	local hum = char:FindFirstChild("Humanoid")
	if not hum then print("DEBUG | No humanoid") return end

	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then print("DEBUG | No animator") return end

	-- Idle animation
	local idleAnim = script.HitboxSettings1.Server.Handler:FindFirstChild("Idle")
	if idleAnim then
		print("DEBUG | Idle anim found")
		idleTrack = animator:LoadAnimation(idleAnim)
		idleTrack.Looped = true
		idleTrack.Priority = Enum.AnimationPriority.Action
		idleTrack:Play()
	else
		print("DEBUG | Idle anim NOT found - check name/location in Explorer")
	end

	-- Walk animation
	local walkAnim = script.HitboxSettings1.Server.Handler:FindFirstChild("Walk")
	if walkAnim then
		print("DEBUG | Walk anim found")
		combatWalkTrack = animator:LoadAnimation(walkAnim)
		combatWalkTrack.Looped = true
		combatWalkTrack.Priority = Enum.AnimationPriority.Action

		runningConnection = hum.Running:Connect(function(speed)
			if not toolEquipped then return end
			if speed > 0.1 then
				if not combatWalkTrack.IsPlaying then
					combatWalkTrack:Play(0.2)
				end
			else
				if combatWalkTrack.IsPlaying then
					combatWalkTrack:Stop(0.2)
				end
			end
		end)
	else
		print("DEBUG | Walk anim NOT found - check name/location in Explorer")
	end
end)

tool.Unequipped:Connect(function()
	toolEquipped = false
	print("DEBUG | Tool unequipped")

	if idleTrack then
		idleTrack:Stop()
		idleTrack = nil
	end
	if combatWalkTrack then
		combatWalkTrack:Stop(0.2)
		combatWalkTrack = nil
	end
	if runningConnection then
		runningConnection:Disconnect()
		runningConnection = nil
	end
end)

-- Attack inputs
UIS.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if not toolEquipped then return end
	if not HS then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		HS:Attack(false)
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		HS:Attack(true)
	end
end)

-- Perfect Block FX
script.HitboxSettings1.Server.OnClientEvent:Connect(function(Action)
	if Action ~= "PB" then return end
	local camera = workspace.CurrentCamera
	local TweenService = game:GetService("TweenService")
	local CC = script.ColorCorrection:Clone()
	CC.Parent = camera
	game.Debris:AddItem(CC, 3)
	local info = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 2, true)
	TweenService:Create(CC, info, {
		TintColor = Color3.fromRGB(139, 128, 255),
		Brightness = 1
	}):Play()
	local Blur = script.Blur:Clone()
	Blur.Parent = camera
	game.Debris:AddItem(Blur, 3)
	TweenService:Create(Blur, info, {
		Size = 100
	}):Play()
end)
