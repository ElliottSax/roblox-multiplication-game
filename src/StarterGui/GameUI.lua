-- GameUI.lua
-- Creates and manages the player UI

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create main UI frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Currency Display
local currencyLabel = Instance.new("TextLabel")
currencyLabel.Name = "CurrencyLabel"
currencyLabel.Size = UDim2.new(1, -20, 0, 40)
currencyLabel.Position = UDim2.new(0, 10, 0, 10)
currencyLabel.BackgroundTransparency = 1
currencyLabel.Text = "Currency: 0"
currencyLabel.TextColor3 = Color3.new(1, 1, 1)
currencyLabel.TextSize = 24
currencyLabel.Font = Enum.Font.GothamBold
currencyLabel.TextXAlignment = Enum.TextXAlignment.Left
currencyLabel.Parent = mainFrame

-- Currency icon
local currencyIcon = Instance.new("TextLabel")
currencyIcon.Size = UDim2.new(0, 30, 0, 30)
currencyIcon.Position = UDim2.new(1, -40, 0, 15)
currencyIcon.BackgroundTransparency = 1
currencyIcon.Text = "💰"
currencyIcon.TextSize = 24
currencyIcon.Parent = mainFrame

-- Objects Collected Display
local collectedLabel = Instance.new("TextLabel")
collectedLabel.Name = "CollectedLabel"
collectedLabel.Size = UDim2.new(1, -20, 0, 30)
collectedLabel.Position = UDim2.new(0, 10, 0, 55)
collectedLabel.BackgroundTransparency = 1
collectedLabel.Text = "Objects Collected: 0"
collectedLabel.TextColor3 = Color3.new(1, 1, 1)
collectedLabel.TextSize = 18
collectedLabel.Font = Enum.Font.Gotham
collectedLabel.TextXAlignment = Enum.TextXAlignment.Left
collectedLabel.Parent = mainFrame

-- Instructions
local instructionsLabel = Instance.new("TextLabel")
instructionsLabel.Name = "Instructions"
instructionsLabel.Size = UDim2.new(1, -20, 0, 50)
instructionsLabel.Position = UDim2.new(0, 10, 0, 90)
instructionsLabel.BackgroundTransparency = 1
instructionsLabel.Text = "Walk into objects to push them through gates!\nCollect them at the end!"
instructionsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
instructionsLabel.TextSize = 14
instructionsLabel.Font = Enum.Font.Gotham
instructionsLabel.TextXAlignment = Enum.TextXAlignment.Left
instructionsLabel.TextWrapped = true
instructionsLabel.Parent = mainFrame

-- Update UI from leaderstats
local function UpdateUI()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local currency = leaderstats:FindFirstChild("Currency")
		local collected = leaderstats:FindFirstChild("Collected")

		if currency then
			currencyLabel.Text = "Currency: " .. tostring(currency.Value)

			-- Animate currency change
			currencyLabel.TextSize = 26
			task.wait(0.1)
			currencyLabel.TextSize = 24
		end

		if collected then
			collectedLabel.Text = "Objects Collected: " .. tostring(collected.Value)
		end
	end
end

-- Listen for leaderstats changes
player.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" then
		UpdateUI()

		-- Listen for value changes
		for _, stat in ipairs(child:GetChildren()) do
			if stat:IsA("IntValue") then
				stat.Changed:Connect(UpdateUI)
			end
		end

		child.ChildAdded:Connect(function(stat)
			if stat:IsA("IntValue") then
				stat.Changed:Connect(UpdateUI)
			end
		end)
	end
end)

-- Initial update
UpdateUI()

print("Game UI loaded")
