
game.Players.PlayerAdded:Connect(function(player)
local Main = script.Parent:WaitForChild("Main")


local function Kick()
	game.ReplicatedStorage.Remotes.BanData:FireServer(player)
	wait(5)
		player:Kick("Our Anti Cheat Detection Has Detected Some Suspicious Activity On "..os.date().. " For Appeals Please Contact @Ibraheem On Twitter.")
end

while wait() do

	if script.Parent:FindFirstChild("Main") == nil then
		Kick()

	elseif Main.Disabled == true then

		Main.Disabled = false
	end
	end
end)
