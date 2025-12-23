-- QuestUI.lua
-- Client-side UI for daily quests

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local QuestUI = {}

-- Create the UI
function QuestUI:CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "QuestUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Quest button (left side)
	local questButton = Instance.new("TextButton")
	questButton.Name = "QuestButton"
	questButton.Size = UDim2.new(0, 60, 0, 60)
	questButton.Position = UDim2.new(0, 20, 0.5, -30)
	questButton.BackgroundColor3 = Color3.fromRGB(50, 120, 180)
	questButton.Text = ""
	questButton.Parent = screenGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 12)
	buttonCorner.Parent = questButton

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(100, 180, 255)
	buttonStroke.Thickness = 2
	buttonStroke.Parent = questButton

	local buttonIcon = Instance.new("TextLabel")
	buttonIcon.Size = UDim2.new(1, 0, 1, 0)
	buttonIcon.BackgroundTransparency = 1
	buttonIcon.Text = "Q"
	buttonIcon.TextColor3 = Color3.new(1, 1, 1)
	buttonIcon.TextSize = 28
	buttonIcon.Font = Enum.Font.GothamBold
	buttonIcon.Parent = questButton

	-- Notification badge
	local badge = Instance.new("Frame")
	badge.Name = "Badge"
	badge.Size = UDim2.new(0, 24, 0, 24)
	badge.Position = UDim2.new(1, -8, 0, -8)
	badge.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	badge.Visible = false
	badge.Parent = questButton

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(1, 0)
	badgeCorner.Parent = badge

	local badgeText = Instance.new("TextLabel")
	badgeText.Size = UDim2.new(1, 0, 1, 0)
	badgeText.BackgroundTransparency = 1
	badgeText.Text = "!"
	badgeText.TextColor3 = Color3.new(1, 1, 1)
	badgeText.TextSize = 14
	badgeText.Font = Enum.Font.GothamBold
	badgeText.Parent = badge

	-- Quest panel
	local panel = Instance.new("Frame")
	panel.Name = "QuestPanel"
	panel.Size = UDim2.new(0, 400, 0, 450)
	panel.Position = UDim2.new(0, 100, 0.5, -225)
	panel.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 16)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(100, 150, 200)
	panelStroke.Thickness = 2
	panelStroke.Parent = panel

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
	header.BorderSizePixel = 0
	header.Parent = panel

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 16)
	headerCorner.Parent = header

	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 20)
	headerFix.Position = UDim2.new(0, 0, 1, -20)
	headerFix.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "DAILY QUESTS"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	-- Streak and timer
	local infoFrame = Instance.new("Frame")
	infoFrame.Name = "InfoFrame"
	infoFrame.Size = UDim2.new(1, -20, 0, 40)
	infoFrame.Position = UDim2.new(0, 10, 0, 70)
	infoFrame.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	infoFrame.BorderSizePixel = 0
	infoFrame.Parent = panel

	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(0, 8)
	infoCorner.Parent = infoFrame

	local streakLabel = Instance.new("TextLabel")
	streakLabel.Name = "StreakLabel"
	streakLabel.Size = UDim2.new(0.5, 0, 1, 0)
	streakLabel.BackgroundTransparency = 1
	streakLabel.Text = "Streak: 1 day"
	streakLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	streakLabel.TextSize = 16
	streakLabel.Font = Enum.Font.GothamBold
	streakLabel.Parent = infoFrame

	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(0.5, 0, 1, 0)
	timerLabel.Position = UDim2.new(0.5, 0, 0, 0)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Text = "Resets in: 12:00:00"
	timerLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	timerLabel.TextSize = 14
	timerLabel.Font = Enum.Font.Gotham
	timerLabel.Parent = infoFrame

	-- Quest container
	local questContainer = Instance.new("ScrollingFrame")
	questContainer.Name = "QuestContainer"
	questContainer.Size = UDim2.new(1, -20, 1, -130)
	questContainer.Position = UDim2.new(0, 10, 0, 120)
	questContainer.BackgroundTransparency = 1
	questContainer.ScrollBarThickness = 4
	questContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 200)
	questContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	questContainer.Parent = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = questContainer

	-- Store references
	self.ScreenGui = screenGui
	self.QuestButton = questButton
	self.Badge = badge
	self.Panel = panel
	self.CloseButton = closeButton
	self.StreakLabel = streakLabel
	self.TimerLabel = timerLabel
	self.QuestContainer = questContainer

	-- Set up events
	self:SetupEvents()
end

-- Set up UI events
function QuestUI:SetupEvents()
	self.QuestButton.MouseButton1Click:Connect(function()
		self:TogglePanel()
	end)

	self.CloseButton.MouseButton1Click:Connect(function()
		self:ClosePanel()
	end)

	-- Hover effects
	self.QuestButton.MouseEnter:Connect(function()
		TweenService:Create(self.QuestButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(70, 140, 200)
		}):Play()
	end)

	self.QuestButton.MouseLeave:Connect(function()
		TweenService:Create(self.QuestButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(50, 120, 180)
		}):Play()
	end)
end

-- Toggle panel
function QuestUI:TogglePanel()
	if self.Panel.Visible then
		self:ClosePanel()
	else
		self:OpenPanel()
	end
end

-- Open panel
function QuestUI:OpenPanel()
	self.Panel.Visible = true
	self.Panel.Position = UDim2.new(0, 80, 0.5, -225)
	self.Panel.BackgroundTransparency = 1

	TweenService:Create(self.Panel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0, 100, 0.5, -225),
		BackgroundTransparency = 0
	}):Play()

	self:RefreshQuests()
end

-- Close panel
function QuestUI:ClosePanel()
	TweenService:Create(self.Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0, 80, 0.5, -225),
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.2, function()
		self.Panel.Visible = false
	end)
end

-- Refresh quest display
function QuestUI:RefreshQuests()
	local getQuests = ReplicatedStorage:FindFirstChild("GetQuests")
	if not getQuests then return end

	local success, questData = pcall(function()
		return getQuests:InvokeServer()
	end)

	if not success or not questData then return end

	-- Update streak
	self.StreakLabel.Text = string.format("Streak: %d day%s",
		questData.DailyStreak,
		questData.DailyStreak == 1 and "" or "s")

	-- Update timer
	self:UpdateTimer(questData.RefreshTime)

	-- Clear existing quests
	for _, child in ipairs(self.QuestContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Create quest cards
	local completedCount = 0
	for i, quest in ipairs(questData.ActiveQuests) do
		self:CreateQuestCard(quest, i)
		if quest.Completed and not quest.Claimed then
			completedCount = completedCount + 1
		end
	end

	-- Update badge
	self.Badge.Visible = completedCount > 0

	-- Update canvas size
	local listLayout = self.QuestContainer:FindFirstChild("UIListLayout")
	if listLayout then
		self.QuestContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end
end

-- Create a quest card
function QuestUI:CreateQuestCard(quest, order)
	local card = Instance.new("Frame")
	card.Name = "Quest_" .. quest.Id
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = quest.Completed and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(35, 40, 55)
	card.BorderSizePixel = 0
	card.LayoutOrder = order
	card.Parent = self.QuestContainer

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card

	-- Icon
	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 10, 0.5, -25)
	icon.BackgroundColor3 = quest.Completed and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(50, 100, 150)
	icon.Parent = card

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	local iconText = Instance.new("TextLabel")
	iconText.Size = UDim2.new(1, 0, 1, 0)
	iconText.BackgroundTransparency = 1
	iconText.Text = quest.Icon or "?"
	iconText.TextColor3 = Color3.new(1, 1, 1)
	iconText.TextSize = 24
	iconText.Font = Enum.Font.GothamBold
	iconText.Parent = icon

	-- Quest info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -150, 0, 25)
	nameLabel.Position = UDim2.new(0, 70, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = quest.Name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -150, 0, 20)
	descLabel.Position = UDim2.new(0, 70, 0, 35)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = quest.Description
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = card

	-- Progress bar
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(1, -150, 0, 12)
	progressBg.Position = UDim2.new(0, 70, 0, 60)
	progressBg.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = card

	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 6)
	progressCorner.Parent = progressBg

	local progress = math.clamp(quest.Progress / quest.Target, 0, 1)
	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(progress, 0, 1, 0)
	progressFill.BackgroundColor3 = quest.Completed and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 150, 220)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	local progressFillCorner = Instance.new("UICorner")
	progressFillCorner.CornerRadius = UDim.new(0, 6)
	progressFillCorner.Parent = progressFill

	-- Progress text
	local progressText = Instance.new("TextLabel")
	progressText.Size = UDim2.new(1, -150, 0, 15)
	progressText.Position = UDim2.new(0, 70, 0, 75)
	progressText.BackgroundTransparency = 1
	progressText.Text = string.format("%d / %d", quest.Progress, quest.Target)
	progressText.TextColor3 = Color3.fromRGB(150, 150, 150)
	progressText.TextSize = 12
	progressText.Font = Enum.Font.Gotham
	progressText.TextXAlignment = Enum.TextXAlignment.Left
	progressText.Parent = card

	-- Reward / Claim button
	local rewardFrame = Instance.new("Frame")
	rewardFrame.Size = UDim2.new(0, 60, 0, 70)
	rewardFrame.Position = UDim2.new(1, -70, 0.5, -35)
	rewardFrame.BackgroundTransparency = 1
	rewardFrame.Parent = card

	if quest.Completed and not quest.Claimed then
		-- Claim button
		local claimButton = Instance.new("TextButton")
		claimButton.Size = UDim2.new(1, 0, 0, 40)
		claimButton.Position = UDim2.new(0, 0, 0.5, -20)
		claimButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
		claimButton.Text = "Claim"
		claimButton.TextColor3 = Color3.new(1, 1, 1)
		claimButton.TextSize = 14
		claimButton.Font = Enum.Font.GothamBold
		claimButton.Parent = rewardFrame

		local claimCorner = Instance.new("UICorner")
		claimCorner.CornerRadius = UDim.new(0, 8)
		claimCorner.Parent = claimButton

		claimButton.MouseButton1Click:Connect(function()
			self:ClaimQuest(quest.Id)
		end)

		-- Pulse animation
		task.spawn(function()
			while claimButton.Parent do
				TweenService:Create(claimButton, TweenInfo.new(0.5), {
					BackgroundColor3 = Color3.fromRGB(100, 220, 100)
				}):Play()
				task.wait(0.5)
				TweenService:Create(claimButton, TweenInfo.new(0.5), {
					BackgroundColor3 = Color3.fromRGB(80, 180, 80)
				}):Play()
				task.wait(0.5)
			end
		end)
	elseif quest.Claimed then
		-- Claimed label
		local claimedLabel = Instance.new("TextLabel")
		claimedLabel.Size = UDim2.new(1, 0, 1, 0)
		claimedLabel.BackgroundTransparency = 1
		claimedLabel.Text = "Done!"
		claimedLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
		claimedLabel.TextSize = 16
		claimedLabel.Font = Enum.Font.GothamBold
		claimedLabel.Parent = rewardFrame
	else
		-- Reward preview
		local rewardLabel = Instance.new("TextLabel")
		rewardLabel.Size = UDim2.new(1, 0, 0, 20)
		rewardLabel.Position = UDim2.new(0, 0, 0.5, -20)
		rewardLabel.BackgroundTransparency = 1
		rewardLabel.Text = "Reward"
		rewardLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		rewardLabel.TextSize = 12
		rewardLabel.Font = Enum.Font.Gotham
		rewardLabel.Parent = rewardFrame

		local rewardValue = Instance.new("TextLabel")
		rewardValue.Size = UDim2.new(1, 0, 0, 25)
		rewardValue.Position = UDim2.new(0, 0, 0.5, 0)
		rewardValue.BackgroundTransparency = 1
		rewardValue.Text = "$" .. quest.Reward
		rewardValue.TextColor3 = Color3.fromRGB(100, 255, 100)
		rewardValue.TextSize = 18
		rewardValue.Font = Enum.Font.GothamBold
		rewardValue.Parent = rewardFrame
	end
end

-- Claim a quest
function QuestUI:ClaimQuest(questId)
	local claimQuest = ReplicatedStorage:FindFirstChild("ClaimQuest")
	if not claimQuest then return end

	local success, result = pcall(function()
		return claimQuest:InvokeServer(questId)
	end)

	if success and result and result.Success then
		self:ShowRewardPopup(result.Reward)
		self:RefreshQuests()
	end
end

-- Show reward popup
function QuestUI:ShowRewardPopup(reward)
	local popup = Instance.new("TextLabel")
	popup.Size = UDim2.new(0, 200, 0, 50)
	popup.Position = UDim2.new(0.5, -100, 0.4, 0)
	popup.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
	popup.Text = "+$" .. reward
	popup.TextColor3 = Color3.fromRGB(100, 255, 100)
	popup.TextSize = 28
	popup.Font = Enum.Font.GothamBold
	popup.ZIndex = 100
	popup.Parent = self.ScreenGui

	local popupCorner = Instance.new("UICorner")
	popupCorner.CornerRadius = UDim.new(0, 12)
	popupCorner.Parent = popup

	local popupStroke = Instance.new("UIStroke")
	popupStroke.Color = Color3.fromRGB(100, 255, 100)
	popupStroke.Thickness = 2
	popupStroke.Parent = popup

	TweenService:Create(popup, TweenInfo.new(0.5), {
		Position = UDim2.new(0.5, -100, 0.35, 0)
	}):Play()

	task.delay(1.5, function()
		TweenService:Create(popup, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()
		TweenService:Create(popupStroke, TweenInfo.new(0.3), {
			Transparency = 1
		}):Play()

		task.delay(0.3, function()
			popup:Destroy()
		end)
	end)
end

-- Update timer display
function QuestUI:UpdateTimer(secondsRemaining)
	if not secondsRemaining then return end

	local hours = math.floor(secondsRemaining / 3600)
	local minutes = math.floor((secondsRemaining % 3600) / 60)
	local seconds = secondsRemaining % 60

	self.TimerLabel.Text = string.format("Resets in: %02d:%02d:%02d", hours, minutes, seconds)
end

-- Listen for quest updates
function QuestUI:ListenForUpdates()
	task.spawn(function()
		-- Quest update events
		local questUpdate = nil
		local questComplete = nil
		local attempts = 0

		while (not questUpdate or not questComplete) and attempts < 30 do
			questUpdate = ReplicatedStorage:FindFirstChild("QuestUpdate")
			questComplete = ReplicatedStorage:FindFirstChild("QuestCompleted")
			if not questUpdate or not questComplete then
				task.wait(1)
				attempts = attempts + 1
			end
		end

		if questUpdate then
			questUpdate.OnClientEvent:Connect(function(data)
				if self.Panel.Visible then
					self:RefreshQuests()
				end
			end)
		end

		if questComplete then
			questComplete.OnClientEvent:Connect(function(data)
				self:ShowQuestCompleteNotification(data)
				self.Badge.Visible = true
			end)
		end
	end)
end

-- Show quest complete notification
function QuestUI:ShowQuestCompleteNotification(data)
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 300, 0, 60)
	notification.Position = UDim2.new(0.5, -150, 0, -70)
	notification.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
	notification.ZIndex = 100
	notification.Parent = self.ScreenGui

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 12)
	notifCorner.Parent = notification

	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = Color3.fromRGB(100, 200, 100)
	notifStroke.Thickness = 2
	notifStroke.Parent = notification

	local notifText = Instance.new("TextLabel")
	notifText.Size = UDim2.new(1, -20, 0, 25)
	notifText.Position = UDim2.new(0, 10, 0, 10)
	notifText.BackgroundTransparency = 1
	notifText.Text = "Quest Complete!"
	notifText.TextColor3 = Color3.fromRGB(100, 255, 100)
	notifText.TextSize = 18
	notifText.Font = Enum.Font.GothamBold
	notifText.TextXAlignment = Enum.TextXAlignment.Left
	notifText.Parent = notification

	local questName = Instance.new("TextLabel")
	questName.Size = UDim2.new(1, -20, 0, 20)
	questName.Position = UDim2.new(0, 10, 0, 35)
	questName.BackgroundTransparency = 1
	questName.Text = data.QuestName .. " - $" .. data.Reward
	questName.TextColor3 = Color3.new(1, 1, 1)
	questName.TextSize = 14
	questName.Font = Enum.Font.Gotham
	questName.TextXAlignment = Enum.TextXAlignment.Left
	questName.Parent = notification

	TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -150, 0, 20)
	}):Play()

	task.delay(3, function()
		TweenService:Create(notification, TweenInfo.new(0.2), {
			Position = UDim2.new(0.5, -150, 0, -70)
		}):Play()

		task.delay(0.2, function()
			notification:Destroy()
		end)
	end)
end

-- Initialize
function QuestUI:Initialize()
	self:CreateUI()
	self:ListenForUpdates()

	-- Periodic refresh when panel is open
	task.spawn(function()
		while true do
			task.wait(10)
			if self.Panel.Visible then
				self:RefreshQuests()
			end
		end
	end)

	print("QuestUI initialized")
end

-- Start
QuestUI:Initialize()

return QuestUI
