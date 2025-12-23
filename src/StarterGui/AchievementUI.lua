-- AchievementUI
-- Client-side UI for displaying achievements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AchievementUI = {}

-- Wait for remotes with timeout
local function waitForRemote(name, timeout)
	local startTime = tick()
	timeout = timeout or 10

	while tick() - startTime < timeout do
		local remote = ReplicatedStorage:FindFirstChild(name)
		if remote then
			return remote
		end
		task.wait(0.1)
	end

	warn("AchievementUI: Timeout waiting for " .. name)
	return nil
end

-- Create the main UI
function AchievementUI:CreateUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AchievementUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Achievement Button (trophy icon in corner)
	local achievementButton = Instance.new("TextButton")
	achievementButton.Name = "AchievementButton"
	achievementButton.Size = UDim2.new(0, 50, 0, 50)
	achievementButton.Position = UDim2.new(0, 10, 0.5, -80)
	achievementButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	achievementButton.BorderSizePixel = 0
	achievementButton.Text = "🏆"
	achievementButton.TextSize = 28
	achievementButton.Font = Enum.Font.GothamBold
	achievementButton.Parent = screenGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = achievementButton

	-- Achievement count badge
	local countBadge = Instance.new("TextLabel")
	countBadge.Name = "CountBadge"
	countBadge.Size = UDim2.new(0, 24, 0, 24)
	countBadge.Position = UDim2.new(1, -8, 0, -8)
	countBadge.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	countBadge.BorderSizePixel = 0
	countBadge.Text = "0"
	countBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
	countBadge.TextSize = 14
	countBadge.Font = Enum.Font.GothamBold
	countBadge.Parent = achievementButton

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(1, 0)
	badgeCorner.Parent = countBadge

	-- Main Achievement Panel (hidden by default)
	local achievementPanel = Instance.new("Frame")
	achievementPanel.Name = "AchievementPanel"
	achievementPanel.Size = UDim2.new(0, 500, 0, 600)
	achievementPanel.Position = UDim2.new(0.5, -250, 0.5, -300)
	achievementPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	achievementPanel.BorderSizePixel = 0
	achievementPanel.Visible = false
	achievementPanel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 12)
	panelCorner.Parent = achievementPanel

	-- Panel Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	header.BorderSizePixel = 0
	header.Parent = achievementPanel

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header

	-- Fix bottom corners of header
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 12)
	headerFix.Position = UDim2.new(0, 0, 1, -12)
	headerFix.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🏆 Achievements"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	local progressLabel = Instance.new("TextLabel")
	progressLabel.Name = "Progress"
	progressLabel.Size = UDim2.new(0, 100, 0, 30)
	progressLabel.Position = UDim2.new(1, -120, 0.5, -15)
	progressLabel.BackgroundTransparency = 1
	progressLabel.Text = "0/20"
	progressLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	progressLabel.TextSize = 16
	progressLabel.Font = Enum.Font.Gotham
	progressLabel.Parent = header

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "Close"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = achievementPanel

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	-- Scrolling frame for achievements
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "AchievementList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -80)
	scrollFrame.Position = UDim2.new(0, 10, 0, 70)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent = achievementPanel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame

	-- Notification popup (for achievement unlocks)
	local notification = Instance.new("Frame")
	notification.Name = "Notification"
	notification.Size = UDim2.new(0, 350, 0, 100)
	notification.Position = UDim2.new(0.5, -175, 0, -120)
	notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	notification.BorderSizePixel = 0
	notification.Visible = false
	notification.Parent = screenGui

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 12)
	notifCorner.Parent = notification

	local notifGlow = Instance.new("UIStroke")
	notifGlow.Color = Color3.fromRGB(255, 215, 0)
	notifGlow.Thickness = 2
	notifGlow.Parent = notification

	local notifIcon = Instance.new("TextLabel")
	notifIcon.Name = "Icon"
	notifIcon.Size = UDim2.new(0, 60, 0, 60)
	notifIcon.Position = UDim2.new(0, 10, 0.5, -30)
	notifIcon.BackgroundTransparency = 1
	notifIcon.Text = "🏆"
	notifIcon.TextSize = 40
	notifIcon.Parent = notification

	local notifTitle = Instance.new("TextLabel")
	notifTitle.Name = "Title"
	notifTitle.Size = UDim2.new(1, -90, 0, 30)
	notifTitle.Position = UDim2.new(0, 80, 0, 15)
	notifTitle.BackgroundTransparency = 1
	notifTitle.Text = "Achievement Unlocked!"
	notifTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
	notifTitle.TextSize = 18
	notifTitle.Font = Enum.Font.GothamBold
	notifTitle.TextXAlignment = Enum.TextXAlignment.Left
	notifTitle.Parent = notification

	local notifName = Instance.new("TextLabel")
	notifName.Name = "Name"
	notifName.Size = UDim2.new(1, -90, 0, 25)
	notifName.Position = UDim2.new(0, 80, 0, 45)
	notifName.BackgroundTransparency = 1
	notifName.Text = "Achievement Name"
	notifName.TextColor3 = Color3.fromRGB(255, 255, 255)
	notifName.TextSize = 16
	notifName.Font = Enum.Font.GothamBold
	notifName.TextXAlignment = Enum.TextXAlignment.Left
	notifName.Parent = notification

	local notifReward = Instance.new("TextLabel")
	notifReward.Name = "Reward"
	notifReward.Size = UDim2.new(1, -90, 0, 20)
	notifReward.Position = UDim2.new(0, 80, 0, 70)
	notifReward.BackgroundTransparency = 1
	notifReward.Text = "+100 Currency"
	notifReward.TextColor3 = Color3.fromRGB(100, 255, 100)
	notifReward.TextSize = 14
	notifReward.Font = Enum.Font.Gotham
	notifReward.TextXAlignment = Enum.TextXAlignment.Left
	notifReward.Parent = notification

	-- Store references
	self.ScreenGui = screenGui
	self.AchievementButton = achievementButton
	self.CountBadge = countBadge
	self.AchievementPanel = achievementPanel
	self.ProgressLabel = progressLabel
	self.ScrollFrame = scrollFrame
	self.Notification = notification
	self.NotifName = notifName
	self.NotifReward = notifReward
	self.CloseButton = closeButton

	-- Connect events
	achievementButton.MouseButton1Click:Connect(function()
		self:TogglePanel()
	end)

	closeButton.MouseButton1Click:Connect(function()
		self:HidePanel()
	end)

	-- Button hover effects
	achievementButton.MouseEnter:Connect(function()
		TweenService:Create(achievementButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 235, 50)
		}):Play()
	end)

	achievementButton.MouseLeave:Connect(function()
		TweenService:Create(achievementButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		}):Play()
	end)

	closeButton.MouseEnter:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 150, 150)
		}):Play()
	end)

	closeButton.MouseLeave:Connect(function()
		TweenService:Create(closeButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		}):Play()
	end)
end

-- Create achievement card
function AchievementUI:CreateAchievementCard(achievement)
	local card = Instance.new("Frame")
	card.Name = achievement.Id
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = achievement.IsUnlocked and Color3.fromRGB(40, 50, 40) or Color3.fromRGB(40, 40, 50)
	card.BorderSizePixel = 0

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	-- Tier accent
	local tierAccent = Instance.new("Frame")
	tierAccent.Size = UDim2.new(0, 4, 1, -10)
	tierAccent.Position = UDim2.new(0, 5, 0, 5)
	tierAccent.BackgroundColor3 = achievement.TierColor or Color3.fromRGB(150, 150, 150)
	tierAccent.BorderSizePixel = 0
	tierAccent.Parent = card

	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, 2)
	accentCorner.Parent = tierAccent

	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 20, 0.5, -25)
	icon.BackgroundTransparency = 1
	icon.Text = achievement.IsUnlocked and "🏆" or "🔒"
	icon.TextSize = 32
	icon.TextTransparency = achievement.IsUnlocked and 0 or 0.5
	icon.Parent = card

	-- Name
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0, 250, 0, 25)
	name.Position = UDim2.new(0, 80, 0, 10)
	name.BackgroundTransparency = 1
	name.Text = achievement.Name
	name.TextColor3 = achievement.IsUnlocked and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
	name.TextSize = 16
	name.Font = Enum.Font.GothamBold
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Parent = card

	-- Description
	local description = Instance.new("TextLabel")
	description.Size = UDim2.new(0, 250, 0, 20)
	description.Position = UDim2.new(0, 80, 0, 32)
	description.BackgroundTransparency = 1
	description.Text = achievement.Description
	description.TextColor3 = Color3.fromRGB(150, 150, 150)
	description.TextSize = 12
	description.Font = Enum.Font.Gotham
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.Parent = card

	-- Progress bar
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(0, 250, 0, 8)
	progressBg.Position = UDim2.new(0, 80, 0, 58)
	progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = card

	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 4)
	progressCorner.Parent = progressBg

	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(achievement.Progress, 0, 1, 0)
	progressFill.BackgroundColor3 = achievement.IsUnlocked and Color3.fromRGB(100, 255, 100) or achievement.TierColor or Color3.fromRGB(255, 215, 0)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = progressFill

	-- Progress text
	local progressText = Instance.new("TextLabel")
	progressText.Size = UDim2.new(0, 100, 0, 20)
	progressText.Position = UDim2.new(1, -110, 0.5, -10)
	progressText.BackgroundTransparency = 1
	progressText.Text = string.format("%d/%d", achievement.CurrentValue, achievement.RequiredValue)
	progressText.TextColor3 = Color3.fromRGB(150, 150, 150)
	progressText.TextSize = 14
	progressText.Font = Enum.Font.Gotham
	progressText.TextXAlignment = Enum.TextXAlignment.Right
	progressText.Parent = card

	-- Reward info
	if achievement.Reward then
		local reward = Instance.new("TextLabel")
		reward.Size = UDim2.new(0, 100, 0, 20)
		reward.Position = UDim2.new(1, -110, 0, 10)
		reward.BackgroundTransparency = 1
		reward.Text = "+" .. achievement.Reward.Value .. " 💰"
		reward.TextColor3 = achievement.IsUnlocked and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 215, 0)
		reward.TextSize = 14
		reward.Font = Enum.Font.GothamBold
		reward.TextXAlignment = Enum.TextXAlignment.Right
		reward.Parent = card
	end

	-- Unlocked checkmark
	if achievement.IsUnlocked then
		local check = Instance.new("TextLabel")
		check.Size = UDim2.new(0, 30, 0, 30)
		check.Position = UDim2.new(1, -40, 0.5, -15)
		check.BackgroundTransparency = 1
		check.Text = "✅"
		check.TextSize = 24
		check.Parent = card
	end

	return card
end

-- Toggle panel visibility
function AchievementUI:TogglePanel()
	if self.AchievementPanel.Visible then
		self:HidePanel()
	else
		self:ShowPanel()
	end
end

-- Show achievement panel
function AchievementUI:ShowPanel()
	self:RefreshAchievements()
	self.AchievementPanel.Visible = true
	self.AchievementPanel.Position = UDim2.new(0.5, -250, 0, -600)

	TweenService:Create(self.AchievementPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -250, 0.5, -300)
	}):Play()
end

-- Hide achievement panel
function AchievementUI:HidePanel()
	TweenService:Create(self.AchievementPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0.5, -250, 0, -600)
	}):Play()

	task.delay(0.2, function()
		self.AchievementPanel.Visible = false
	end)
end

-- Refresh achievements list
function AchievementUI:RefreshAchievements()
	-- Clear existing cards
	for _, child in pairs(self.ScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Get achievements from server
	local getAchievements = waitForRemote("GetAchievements")
	if not getAchievements then return end

	local success, achievements = pcall(function()
		return getAchievements:InvokeServer()
	end)

	if not success or not achievements then
		warn("Failed to get achievements")
		return
	end

	-- Create cards
	local unlockedCount = 0
	local totalCount = 0

	for i, achievement in ipairs(achievements) do
		local card = self:CreateAchievementCard(achievement)
		card.LayoutOrder = i
		card.Parent = self.ScrollFrame

		totalCount = totalCount + 1
		if achievement.IsUnlocked then
			unlockedCount = unlockedCount + 1
		end
	end

	-- Update progress
	self.ProgressLabel.Text = string.format("%d/%d", unlockedCount, totalCount)
	self.CountBadge.Text = tostring(unlockedCount)

	-- Update canvas size
	self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalCount * 90)
end

-- Show achievement unlock notification
function AchievementUI:ShowUnlockNotification(achievement)
	self.NotifName.Text = achievement.Name

	if achievement.Reward then
		self.NotifReward.Text = "+" .. achievement.Reward.Value .. " " .. achievement.Reward.Type
	else
		self.NotifReward.Text = ""
	end

	-- Animate in
	self.Notification.Position = UDim2.new(0.5, -175, 0, -120)
	self.Notification.Visible = true

	TweenService:Create(self.Notification, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -175, 0, 20)
	}):Play()

	-- Update badge
	local currentCount = tonumber(self.CountBadge.Text) or 0
	self.CountBadge.Text = tostring(currentCount + 1)

	-- Pulse effect on badge
	TweenService:Create(self.CountBadge, TweenInfo.new(0.1), {
		Size = UDim2.new(0, 32, 0, 32)
	}):Play()

	task.delay(0.1, function()
		TweenService:Create(self.CountBadge, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 24, 0, 24)
		}):Play()
	end)

	-- Hide after 4 seconds
	task.delay(4, function()
		TweenService:Create(self.Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0.5, -175, 0, -120)
		}):Play()

		task.delay(0.3, function()
			self.Notification.Visible = false
		end)
	end)
end

-- Initialize
function AchievementUI:Initialize()
	self:CreateUI()

	-- Connect to achievement unlock event
	local achievementUnlocked = waitForRemote("AchievementUnlocked")
	if achievementUnlocked then
		achievementUnlocked.OnClientEvent:Connect(function(achievement)
			self:ShowUnlockNotification(achievement)
		end)
	end

	-- Initial load
	task.delay(2, function()
		self:RefreshAchievements()
	end)

	print("AchievementUI initialized")
end

-- Start
AchievementUI:Initialize()

return AchievementUI
