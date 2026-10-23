local manualban = {}
local whitelist = {3431889924} -- Ibraheem whitelisted, add players here if you want to be able to bypass the anti cheat
local bandatastore = game:GetService("DataStoreService"):GetDataStore("Bans")

game.ReplicatedStorage.Remotes.BanData.Event:Connect(function(player)
	local success,errormessage = pcall(function()
		bandatastore:SetAsync(player.UserId,true)
		print("saved")
	end)
end)

game.Players.PlayerAdded:Connect(function(player)
	if not table.find(whitelist,player.UserId) then
	local userid = player.UserId
	if manualban[userid] then
		player:Kick("Our Anti Cheat Detection Has Detected Some Suspicious Activity On "..os.date().. " For Appeals Please Contact @Ibraheem On Twitter.")
	end
	
	local banned
	
	local success,errormessage = pcall(function()
		banned = bandatastore:GetAsync(userid)
	end)
	
	if banned == true then

			player:Kick("Our Anti Cheat Detection Has Detected Some Suspicious Activity On "..os.date().. " For Appeals Please Contact @Ibraheem On Twitter.")
		end
	end
end)
