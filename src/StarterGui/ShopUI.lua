-- ShopUI.lua
-- Creates and manages the upgrade shop interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remote events to be created (increased timeout)
local getUpgradesRemote = ReplicatedStorage:WaitForChild("GetUpgrades", 30)
local purchaseUpgradeRemote = ReplicatedStorage:WaitForChild("PurchaseUpgrade", 30)

if not getUpgradesRemote or not purchaseUpgradeRemote then
	warn("Shop remotes not found after 30 seconds!")
	return
end

print("Shop remotes connected successfully")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Shop toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ShopToggle"
toggleButton.Size = UDim2.new(0, 120, 0, 50)
toggleButton.Position = UDim2.new(1, -130, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "🛒 SHOP"
toggleButton.TextColor3 = Color3.new(0, 0, 0)
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = screenGui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

-- Main shop frame (hidden by default)
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 500, 0, 600)
shopFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
shopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 12)
shopCorner.Parent = shopFrame

-- Shop title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -20, 0, 50)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🛒 UPGRADE SHOP"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
titleLabel.TextSize = 28
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = shopFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 24
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = shopFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Scrolling frame for upgrades
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "UpgradeList"
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- Toggle shop visibility
local function ToggleShop()
	shopFrame.Visible = not shopFrame.Visible
	if shopFrame.Visible then
		RefreshShop()
	end
end

toggleButton.MouseButton1Click:Connect(ToggleShop)
closeButton.MouseButton1Click:Connect(ToggleShop)

-- Create an upgrade card
local function CreateUpgradeCard(upgradeData)
	local card = Instance.new("Frame")
	card.Name = "UpgradeCard_" .. upgradeData.Id
	card.Size = UDim2.new(1, -10, 0, 100)
	card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	card.BorderSizePixel = 0

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	-- Upgrade name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -100, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = upgradeData.Name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	-- Level display
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(0, 90, 0, 25)
	levelLabel.Position = UDim2.new(1, -95, 0, 5)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = string.format("Lv %d/%d", upgradeData.CurrentLevel, upgradeData.MaxLevel)
	levelLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	levelLabel.TextSize = 14
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.Parent = card

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -20, 0, 30)
	descLabel.Position = UDim2.new(0, 10, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = upgradeData.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextWrapped = true
	descLabel.Parent = card

	-- Purchase button
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0, 150, 0, 30)
	buyButton.Position = UDim2.new(0, 10, 1, -35)
	buyButton.BorderSizePixel = 0
	buyButton.Font = Enum.Font.GothamBold
	buyButton.TextSize = 16
	buyButton.Parent = card

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 6)
	buyCorner.Parent = buyButton

	-- Set button state
	if upgradeData.IsMaxed then
		buyButton.Text = "MAX LEVEL"
		buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		buyButton.TextColor3 = Color3.new(0.7, 0.7, 0.7)
		buyButton.Active = false
	elseif not upgradeData.CanAfford then
		buyButton.Text = string.format("💰 %d", upgradeData.NextCost)
		buyButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
		buyButton.TextColor3 = Color3.new(1, 1, 1)
		buyButton.Active = false
	else
		buyButton.Text = string.format("BUY - 💰 %d", upgradeData.NextCost)
		buyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		buyButton.TextColor3 = Color3.new(1, 1, 1)

		-- Debounce to prevent double-clicks
		local purchasing = false
		buyButton.MouseButton1Click:Connect(function()
			if purchasing then return end
			purchasing = true

			-- Attempt purchase
			local success, result = pcall(function()
				return purchaseUpgradeRemote:InvokeServer(upgradeData.Id)
			end)

			if success and result then
				-- Show feedback
				if result.Success then
					buyButton.Text = "✓ PURCHASED!"
					buyButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
					task.wait(0.5)
				else
					buyButton.Text = "✗ FAILED"
					buyButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
					task.wait(0.5)
				end
			end

			RefreshShop()
			purchasing = false
		end)
	end

	return card
end

-- Refresh shop display
function RefreshShop()
	-- Clear existing cards
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") and child.Name:match("UpgradeCard") then
			child:Destroy()
		end
	end

	-- Get upgrades from server with error handling
	local success, upgrades = pcall(function()
		return getUpgradesRemote:InvokeServer()
	end)

	if not success then
		warn("Failed to get upgrades from server:", upgrades)
		return
	end

	if not upgrades or type(upgrades) ~= "table" then
		warn("Invalid upgrades data received")
		return
	end

	-- Create cards for each upgrade
	for _, upgradeData in ipairs(upgrades) do
		local card = CreateUpgradeCard(upgradeData)
		card.Parent = scrollFrame
	end

	-- Update scroll canvas size
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

-- Auto-refresh when currency changes
local function SetupAutoRefresh()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local currency = leaderstats:FindFirstChild("Currency")
		if currency and shopFrame.Visible then
			currency.Changed:Connect(function()
				if shopFrame.Visible then
					RefreshShop()
				end
			end)
		end
	end
end

player.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" then
		SetupAutoRefresh()
	end
end)

print("Shop UI loaded")
