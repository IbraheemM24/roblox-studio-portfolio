--// SERVICES
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// UI
local gui = script.Parent
local menuFrame = gui:WaitForChild("MenuFrame")
local playButton = menuFrame:WaitForChild("PlayButton")
local settingsButton = menuFrame:WaitForChild("SettingsButton")
local creditButton = menuFrame:WaitForChild("CreditButton")
local quitButton = menuFrame:WaitForChild("QuitButton")
local fadeFrame = gui:WaitForChild("FadeFrame")



--// CAMERA PART
local camPart = workspace:WaitForChild("MenuCameraPart")

--// GAME STATE
local gameStarted = ReplicatedStorage:FindFirstChild("Values"):FindFirstChild('GameStarted')
if not gameStarted then
	gameStarted = Instance.new("BoolValue")
	gameStarted.Name = "GameStarted"
	gameStarted.Value = false
	gameStarted.Parent = ReplicatedStorage
end

-- // Fade State 

fadeFrame.BackgroundTransparency = 0

--------------------------------------------------
-- BUTTON EFFECTS
--------------------------------------------------

local function tween(obj, props, time)
	local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local buttons = { playButton, settingsButton, creditButton, quitButton }

for _, button in ipairs(buttons) do
	local normalSize = button.Size
	local hoverSize = normalSize + UDim2.new(0, 10, 0, 5)
	local pressSize = normalSize - UDim2.new(0, 6, 0, 3)

	local bar = button:WaitForChild("Bar")
	bar.BackgroundTransparency = 1 -- hidden by default

	button.MouseEnter:Connect(function()
		tween(button, {Size = hoverSize}, 0.15)
		tween(bar, {BackgroundTransparency = 0}, 0.15)
	end)

	button.MouseLeave:Connect(function()
		tween(button, {Size = normalSize}, 0.15)
		tween(bar, {BackgroundTransparency = 1}, 0.15)
	end)

	button.MouseButton1Down:Connect(function()
		tween(button, {Size = pressSize}, 0.08)
	end)

	button.MouseButton1Up:Connect(function()
		tween(button, {Size = hoverSize}, 0.1)
	end)
end

--------------------------------------------------
-- CAMERA MENU MODE
--------------------------------------------------

camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = camPart.CFrame

local mouse = player:GetMouse()

local menuCameraConnection
menuCameraConnection = RunService.RenderStepped:Connect(function()
	if camera.CameraType ~= Enum.CameraType.Scriptable then return end

	local x = (mouse.X - camera.ViewportSize.X/2) / camera.ViewportSize.X
	local y = (mouse.Y - camera.ViewportSize.Y/2) / camera.ViewportSize.Y

	local offset = CFrame.new(x * 2, -y * 2, 0)
	camera.CFrame = camPart.CFrame * offset
end)

--------------------------------------------------
-- FADE + PLAY
--------------------------------------------------

fadeFrame.BackgroundTransparency = 1

local function playGame()
	-- stop the menu camera loop permanently so it can't fight the gameplay camera
	if menuCameraConnection then
		menuCameraConnection:Disconnect()
		menuCameraConnection = nil
	end

	

	-- fade to black
	local fadeIn = TweenService:Create(fadeFrame, TweenInfo.new(0.6), {
		BackgroundTransparency = 0
	})
	fadeIn:Play()
	fadeIn.Completed:Wait()

	-- enable player camera
	camera.CameraType = Enum.CameraType.Custom

	-- tell the character scripts they can take over now
	gameStarted.Value = true

	menuFrame.Visible = false

	-- fade back
	local fadeOut = TweenService:Create(fadeFrame, TweenInfo.new(0.6), {
		BackgroundTransparency = 1
	})
	fadeOut:Play()
	
	
end

--------------------------------------------------
-- BUTTON CLICKS
--------------------------------------------------

playButton.MouseButton1Click:Connect(playGame)

settingsButton.MouseButton1Click:Connect(function()
	-- TODO: open settings UI
end)

creditButton.MouseButton1Click:Connect(function()
	-- TODO: open credits UI
end)

quitButton.MouseButton1Click:Connect(function()
	-- TODO: quit game logic
end)
