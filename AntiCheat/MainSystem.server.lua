game.Players.PlayerAdded:Connect(function(player)
	repeat wait() until player
	repeat wait() until player.Character
	local character = player.Character
	local humroot = character:WaitForChild("HumanoidRootPart")
	local backpack = player.Backpack
	local whitelist = {326519963}

	local anti = script.Parent.Anti	
	
local Bodys = {
	"BodyGyro",
	"BodyVelocity",
	"BodyPosition",
		"BodyForce",
		"VectorForce",
		"LineForce",
		"AlignPosition",
		"AlignOrientation"
}


local PreviousPosition


	local function Kick()
		if not table.find(whitelist,player.UserId) then
	game.ReplicatedStorage.Remotes.BanData:Fire(player)
	wait(5)
			player:Kick("Our Anti Cheat Detection Has Detected Some Suspicious Activity On "..os.date().. " For Appeals Please Contact @Ibraheem On Twitter.")
		end
	end

local function checktele()
	if humroot == nil then return Kick() end
	local positionfirst = humroot.Position
	delay(1,function()
		local positionsecond = humroot.Position

		if (positionsecond-positionfirst).magnitude>=140 then return Kick() end

	end)

end

character.ChildRemoved:Connect(function(Obj)
	if Obj:IsA("Humanoid") then return Kick() end
end)
	character.ChildAdded:Connect(function(Obj)
		for i = 1,8 do
			if Obj:IsA(Bodys[i]) then return Kick() end
			end
	end)
while wait() do
	if anti.Disabled then
		anti.Disabled = false
	elseif script.Parent:FindFirstChild("Anti") == nil then
		
			Kick()

			checktele()
		end
		end
	end)
