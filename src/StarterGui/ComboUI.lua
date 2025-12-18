-- ComboUI.lua
-- Displays combo counter and notifications

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ComboUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Combo counter frame
local comboFrame = Instance.new("Frame")
comboFrame.Name = "ComboFrame"
comboFrame.Size = UDim2.new(0, 200, 0, 80)
comboFrame.Position = UDim2.new(0.5, -100, 0, 80)
comboFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
comboFrame.BackgroundTransparency = 1
comboFrame.BorderSizePixel = 0
comboFrame.Parent = screenGui

local comboCorner = Instance.new("UICorner")
comboCorner.CornerRadius = UDim.new(0, 10)
comboCorner.Parent = comboFrame

-- Combo count label
local comboCountLabel = Instance.new("TextLabel")
comboCountLabel.Name = "ComboCount"
comboCountLabel.Size = UDim2.new(1, 0, 0, 50)
comboCountLabel.Position = UDim2.new(0, 0, 0, 0)
comboCountLabel.BackgroundTransparency = 1
comboCountLabel.Text = ""
comboCountLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
comboCountLabel.TextSize = 36
comboCountLabel.Font = Enum.Font.GothamBold
comboCountLabel.TextStrokeTransparency = 0.5
comboCountLabel.Parent = comboFrame

-- Multiplier label
local multiplierLabel = Instance.new("TextLabel")
multiplierLabel.Name = "Multiplier"
multiplierLabel.Size = UDim2.new(1, 0, 0, 25)
multiplierLabel.Position = UDim2.new(0, 0, 0, 50)
multiplierLabel.BackgroundTransparency = 1
multiplierLabel.Text = ""
multiplierLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
multiplierLabel.TextSize = 18
multiplierLabel.Font = Enum.Font.Gotham
multiplierLabel.TextStrokeTransparency = 0.5
multiplierLabel.Parent = comboFrame

-- Notification frame (for combo tier achievements)
local notificationFrame = Instance.new("Frame")
notificationFrame.Name = "NotificationFrame"
notificationFrame.Size = UDim2.new(0, 400, 0, 100)
notificationFrame.Position = UDim2.new(0.5, -200, 0.3, -50)
notificationFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
notificationFrame.BackgroundTransparency = 1
notificationFrame.BorderSizePixel = 0
notificationFrame.Visible = false
notificationFrame.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 15)
notifCorner.Parent = notificationFrame

-- Notification text
local notificationText = Instance.new("TextLabel")
notificationText.Size = UDim2.new(1, 0, 1, 0)
notificationText.BackgroundTransparency = 1
notificationText.TextColor3 = Color3.new(1, 1, 1)
notificationText.TextSize = 48
notificationText.Font = Enum.Font.GothamBold
notificationText.TextStrokeTransparency = 0
notificationText.TextStrokeColor3 = Color3.new(0, 0, 0)
notificationText.Parent = notificationFrame

-- Update combo display
local function UpdateComboDisplay(comboCount, multiplier)
	if comboCount == 0 then
		-- Hide combo display
		comboFrame.BackgroundTransparency = 1
		comboCountLabel.Text = ""
		multiplierLabel.Text = ""
	else
		-- Show combo display
		comboFrame.BackgroundTransparency = 0.3
		comboCountLabel.Text = string.format("%d COMBO!", comboCount)
		multiplierLabel.Text = string.format("x%.1f Multiplier", multiplier)

		-- Pulse animation
		local pulseTween = TweenService:Create(
			comboCountLabel,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextSize = 40}
		)
		pulseTween:Play()

		pulseTween.Completed:Connect(function()
			local resetTween = TweenService:Create(
				comboCountLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{TextSize = 36}
			)
			resetTween:Play()
		end)
	end
end

-- Show tier notification
local function ShowTierNotification(tierData)
	notificationFrame.Visible = true
	notificationFrame.BackgroundTransparency = 0
	notificationText.TextTransparency = 0
	notificationText.Text = string.format("%s\n%.1fx MULTIPLIER!", tierData.TierName, tierData.Multiplier)

	-- Color based on tier
	if tierData.Multiplier >= 4.0 then
		notificationFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Purple for legendary
	elseif tierData.Multiplier >= 3.0 then
		notificationFrame.BackgroundColor3 = Color3.fromRGB(255, 100, 0) -- Orange
	elseif tierData.Multiplier >= 2.0 then
		notificationFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- Gold
	else
		notificationFrame.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- Green
	end

	-- Scale animation
	notificationFrame.Size = UDim2.new(0, 0, 0, 0)
	local scaleTween = TweenService:Create(
		notificationFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 400, 0, 100)}
	)
	scaleTween:Play()

	-- Hold for 2 seconds, then fade out
	task.delay(2, function()
		local fadeTween = TweenService:Create(
			notificationFrame,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		local textFadeTween = TweenService:Create(
			notificationText,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{TextTransparency = 1}
		)

		fadeTween:Play()
		textFadeTween:Play()

		fadeTween.Completed:Connect(function()
			notificationFrame.Visible = false
		end)
	end)
end

-- Listen for combo updates from server
local function SetupComboListener()
	-- Wait for remote event with longer timeout
	local comboUpdateRemote = ReplicatedStorage:WaitForChild("ComboUpdate", 30)
	if comboUpdateRemote then
		comboUpdateRemote.OnClientEvent:Connect(function(comboData)
			if comboData and type(comboData) == "table" then
				UpdateComboDisplay(comboData.Count or 0, comboData.Multiplier or 1.0)
			end
		end)
		print("Combo update listener connected")
	else
		warn("ComboUpdate remote not found after 30 seconds")
	end

	-- Listen for tier notifications
	local comboNotifRemote = ReplicatedStorage:WaitForChild("ComboNotification", 30)
	if comboNotifRemote then
		comboNotifRemote.OnClientEvent:Connect(function(tierData)
			if tierData and type(tierData) == "table" then
				ShowTierNotification(tierData)
			end
		end)
		print("Combo notification listener connected")
	else
		warn("ComboNotification remote not found after 30 seconds")
	end
end

SetupComboListener()

print("Combo UI loaded")
