-- RebirthUI.lua
-- Client-side UI for the rebirth/prestige system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RebirthUI = {}

-- Create the UI
function RebirthUI:CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RebirthUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Rebirth button (bottom right)
	local rebirthButton = Instance.new("TextButton")
	rebirthButton.Name = "RebirthButton"
	rebirthButton.Size = UDim2.new(0, 60, 0, 60)
	rebirthButton.Position = UDim2.new(1, -80, 1, -150)
	rebirthButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
	rebirthButton.Text = ""
	rebirthButton.Parent = screenGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 30)
	buttonCorner.Parent = rebirthButton

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(200, 150, 255)
	buttonStroke.Thickness = 2
	buttonStroke.Parent = rebirthButton

	local buttonIcon = Instance.new("TextLabel")
	buttonIcon.Size = UDim2.new(1, 0, 1, 0)
	buttonIcon.BackgroundTransparency = 1
	buttonIcon.Text = "R"
	buttonIcon.TextColor3 = Color3.new(1, 1, 1)
	buttonIcon.TextSize = 28
	buttonIcon.Font = Enum.Font.GothamBold
	buttonIcon.Parent = rebirthButton

	-- Tier indicator
	local tierLabel = Instance.new("TextLabel")
	tierLabel.Name = "TierLabel"
	tierLabel.Size = UDim2.new(0, 30, 0, 20)
	tierLabel.Position = UDim2.new(1, -5, 0, -5)
	tierLabel.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
	tierLabel.Text = "0"
	tierLabel.TextColor3 = Color3.new(0, 0, 0)
	tierLabel.TextSize = 14
	tierLabel.Font = Enum.Font.GothamBold
	tierLabel.Parent = rebirthButton

	local tierCorner = Instance.new("UICorner")
	tierCorner.CornerRadius = UDim.new(0, 10)
	tierCorner.Parent = tierLabel

	-- Main rebirth panel (hidden by default)
	local panel = Instance.new("Frame")
	panel.Name = "RebirthPanel"
	panel.Size = UDim2.new(0, 450, 0, 500)
	panel.Position = UDim2.new(0.5, -225, 0.5, -250)
	panel.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 16)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(150, 100, 200)
	panelStroke.Thickness = 3
	panelStroke.Parent = panel

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
	header.BorderSizePixel = 0
	header.Parent = panel

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 16)
	headerCorner.Parent = header

	-- Fix bottom corners of header
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 20)
	headerFix.Position = UDim2.new(0, 0, 1, -20)
	headerFix.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "REBIRTH"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 28
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

	-- Current status section
	local statusFrame = Instance.new("Frame")
	statusFrame.Name = "StatusFrame"
	statusFrame.Size = UDim2.new(1, -30, 0, 100)
	statusFrame.Position = UDim2.new(0, 15, 0, 75)
	statusFrame.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
	statusFrame.BorderSizePixel = 0
	statusFrame.Parent = panel

	local statusCorner = Instance.new("UICorner")
	statusCorner.CornerRadius = UDim.new(0, 12)
	statusCorner.Parent = statusFrame

	local currentTierLabel = Instance.new("TextLabel")
	currentTierLabel.Name = "CurrentTier"
	currentTierLabel.Size = UDim2.new(1, -20, 0, 30)
	currentTierLabel.Position = UDim2.new(0, 10, 0, 10)
	currentTierLabel.BackgroundTransparency = 1
	currentTierLabel.Text = "Current Tier: None"
	currentTierLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	currentTierLabel.TextSize = 18
	currentTierLabel.Font = Enum.Font.Gotham
	currentTierLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentTierLabel.Parent = statusFrame

	local multiplierLabel = Instance.new("TextLabel")
	multiplierLabel.Name = "Multiplier"
	multiplierLabel.Size = UDim2.new(1, -20, 0, 25)
	multiplierLabel.Position = UDim2.new(0, 10, 0, 40)
	multiplierLabel.BackgroundTransparency = 1
	multiplierLabel.Text = "Multiplier: 1.0x"
	multiplierLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	multiplierLabel.TextSize = 16
	multiplierLabel.Font = Enum.Font.GothamBold
	multiplierLabel.TextXAlignment = Enum.TextXAlignment.Left
	multiplierLabel.Parent = statusFrame

	local rebirthCountLabel = Instance.new("TextLabel")
	rebirthCountLabel.Name = "RebirthCount"
	rebirthCountLabel.Size = UDim2.new(1, -20, 0, 25)
	rebirthCountLabel.Position = UDim2.new(0, 10, 0, 65)
	rebirthCountLabel.BackgroundTransparency = 1
	rebirthCountLabel.Text = "Total Rebirths: 0"
	rebirthCountLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
	rebirthCountLabel.TextSize = 14
	rebirthCountLabel.Font = Enum.Font.Gotham
	rebirthCountLabel.TextXAlignment = Enum.TextXAlignment.Left
	rebirthCountLabel.Parent = statusFrame

	-- Next tier section
	local nextFrame = Instance.new("Frame")
	nextFrame.Name = "NextFrame"
	nextFrame.Size = UDim2.new(1, -30, 0, 150)
	nextFrame.Position = UDim2.new(0, 15, 0, 190)
	nextFrame.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
	nextFrame.BorderSizePixel = 0
	nextFrame.Parent = panel

	local nextCorner = Instance.new("UICorner")
	nextCorner.CornerRadius = UDim.new(0, 12)
	nextCorner.Parent = nextFrame

	local nextTitle = Instance.new("TextLabel")
	nextTitle.Name = "NextTitle"
	nextTitle.Size = UDim2.new(1, -20, 0, 30)
	nextTitle.Position = UDim2.new(0, 10, 0, 10)
	nextTitle.BackgroundTransparency = 1
	nextTitle.Text = "Next Tier: Apprentice"
	nextTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
	nextTitle.TextSize = 18
	nextTitle.Font = Enum.Font.GothamBold
	nextTitle.TextXAlignment = Enum.TextXAlignment.Left
	nextTitle.Parent = nextFrame

	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(1, -20, 0, 20)
	progressBar.Position = UDim2.new(0, 10, 0, 45)
	progressBar.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
	progressBar.BorderSizePixel = 0
	progressBar.Parent = nextFrame

	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 6)
	progressCorner.Parent = progressBar

	local progressFill = Instance.new("Frame")
	progressFill.Name = "Fill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBar

	local progressFillCorner = Instance.new("UICorner")
	progressFillCorner.CornerRadius = UDim.new(0, 6)
	progressFillCorner.Parent = progressFill

	local progressText = Instance.new("TextLabel")
	progressText.Name = "ProgressText"
	progressText.Size = UDim2.new(1, -20, 0, 20)
	progressText.Position = UDim2.new(0, 10, 0, 70)
	progressText.BackgroundTransparency = 1
	progressText.Text = "0 / 10,000"
	progressText.TextColor3 = Color3.fromRGB(200, 200, 200)
	progressText.TextSize = 14
	progressText.Font = Enum.Font.Gotham
	progressText.TextXAlignment = Enum.TextXAlignment.Left
	progressText.Parent = nextFrame

	local rewardsLabel = Instance.new("TextLabel")
	rewardsLabel.Name = "RewardsLabel"
	rewardsLabel.Size = UDim2.new(1, -20, 0, 50)
	rewardsLabel.Position = UDim2.new(0, 10, 0, 95)
	rewardsLabel.BackgroundTransparency = 1
	rewardsLabel.Text = "Rewards: 1.5x Multiplier"
	rewardsLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	rewardsLabel.TextSize = 13
	rewardsLabel.Font = Enum.Font.Gotham
	rewardsLabel.TextXAlignment = Enum.TextXAlignment.Left
	rewardsLabel.TextWrapped = true
	rewardsLabel.Parent = nextFrame

	-- Rebirth button (main action)
	local rebirthActionButton = Instance.new("TextButton")
	rebirthActionButton.Name = "RebirthActionButton"
	rebirthActionButton.Size = UDim2.new(1, -30, 0, 50)
	rebirthActionButton.Position = UDim2.new(0, 15, 0, 355)
	rebirthActionButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
	rebirthActionButton.Text = "REBIRTH"
	rebirthActionButton.TextColor3 = Color3.new(1, 1, 1)
	rebirthActionButton.TextSize = 22
	rebirthActionButton.Font = Enum.Font.GothamBold
	rebirthActionButton.Parent = panel

	local actionCorner = Instance.new("UICorner")
	actionCorner.CornerRadius = UDim.new(0, 12)
	actionCorner.Parent = rebirthActionButton

	-- Warning text
	local warningLabel = Instance.new("TextLabel")
	warningLabel.Name = "Warning"
	warningLabel.Size = UDim2.new(1, -30, 0, 40)
	warningLabel.Position = UDim2.new(0, 15, 0, 415)
	warningLabel.BackgroundTransparency = 1
	warningLabel.Text = "Warning: Currency will be reset!"
	warningLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
	warningLabel.TextSize = 14
	warningLabel.Font = Enum.Font.Gotham
	warningLabel.TextWrapped = true
	warningLabel.Parent = panel

	-- Max tier label (shown when maxed)
	local maxLabel = Instance.new("TextLabel")
	maxLabel.Name = "MaxLabel"
	maxLabel.Size = UDim2.new(1, -30, 0, 150)
	maxLabel.Position = UDim2.new(0, 15, 0, 190)
	maxLabel.BackgroundTransparency = 1
	maxLabel.Text = "MAXIMUM TIER REACHED!\nYou are a true legend!"
	maxLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	maxLabel.TextSize = 20
	maxLabel.Font = Enum.Font.GothamBold
	maxLabel.Visible = false
	maxLabel.Parent = panel

	-- Store references
	self.ScreenGui = screenGui
	self.RebirthButton = rebirthButton
	self.TierLabel = tierLabel
	self.Panel = panel
	self.CloseButton = closeButton
	self.CurrentTierLabel = currentTierLabel
	self.MultiplierLabel = multiplierLabel
	self.RebirthCountLabel = rebirthCountLabel
	self.NextTitle = nextTitle
	self.ProgressBar = progressBar
	self.ProgressFill = progressFill
	self.ProgressText = progressText
	self.RewardsLabel = rewardsLabel
	self.RebirthActionButton = rebirthActionButton
	self.WarningLabel = warningLabel
	self.NextFrame = nextFrame
	self.MaxLabel = maxLabel

	-- Set up button events
	self:SetupEvents()
end

-- Set up UI events
function RebirthUI:SetupEvents()
	-- Toggle panel
	self.RebirthButton.MouseButton1Click:Connect(function()
		self:TogglePanel()
	end)

	-- Close panel
	self.CloseButton.MouseButton1Click:Connect(function()
		self:ClosePanel()
	end)

	-- Rebirth action
	self.RebirthActionButton.MouseButton1Click:Connect(function()
		self:AttemptRebirth()
	end)

	-- Hover effects
	self.RebirthButton.MouseEnter:Connect(function()
		TweenService:Create(self.RebirthButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(130, 70, 180)
		}):Play()
	end)

	self.RebirthButton.MouseLeave:Connect(function()
		TweenService:Create(self.RebirthButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(100, 50, 150)
		}):Play()
	end)

	self.RebirthActionButton.MouseEnter:Connect(function()
		TweenService:Create(self.RebirthActionButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(130, 70, 180)
		}):Play()
	end)

	self.RebirthActionButton.MouseLeave:Connect(function()
		TweenService:Create(self.RebirthActionButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(100, 50, 150)
		}):Play()
	end)
end

-- Toggle panel visibility
function RebirthUI:TogglePanel()
	if self.Panel.Visible then
		self:ClosePanel()
	else
		self:OpenPanel()
	end
end

-- Open panel
function RebirthUI:OpenPanel()
	self.Panel.Visible = true
	self.Panel.Position = UDim2.new(0.5, -225, 0.5, -200)
	self.Panel.BackgroundTransparency = 1

	TweenService:Create(self.Panel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -225, 0.5, -250),
		BackgroundTransparency = 0
	}):Play()

	self:UpdateDisplay()
end

-- Close panel
function RebirthUI:ClosePanel()
	TweenService:Create(self.Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0.5, -225, 0.5, -200),
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.2, function()
		self.Panel.Visible = false
	end)
end

-- Update display with current data
function RebirthUI:UpdateDisplay()
	local getRebirthInfo = ReplicatedStorage:FindFirstChild("GetRebirthInfo")
	if not getRebirthInfo then return end

	local success, info = pcall(function()
		return getRebirthInfo:InvokeServer()
	end)

	if not success or not info then return end

	-- Update tier label on button
	self.TierLabel.Text = tostring(info.CurrentTier)
	if info.CurrentTier > 0 then
		local tierColor = info.AllTiers[info.CurrentTier] and info.AllTiers[info.CurrentTier].Color
		if tierColor then
			self.TierLabel.BackgroundColor3 = tierColor
		end
	end

	-- Update status section
	self.CurrentTierLabel.Text = "Current Tier: " .. info.CurrentTierName
	self.MultiplierLabel.Text = string.format("Multiplier: %.1fx", info.TotalMultiplier)
	self.RebirthCountLabel.Text = "Total Rebirths: " .. info.RebirthCount

	-- Update next tier section
	if info.NextTier then
		self.NextFrame.Visible = true
		self.MaxLabel.Visible = false

		self.NextTitle.Text = "Next Tier: " .. info.NextTier.Name
		self.ProgressText.Text = string.format("%s / %s",
			self:FormatNumber(info.NextTier.Current),
			self:FormatNumber(info.NextTier.Required))

		-- Update progress bar
		local progress = math.clamp(info.NextTier.Progress, 0, 1)
		TweenService:Create(self.ProgressFill, TweenInfo.new(0.3), {
			Size = UDim2.new(progress, 0, 1, 0)
		}):Play()

		-- Update rewards preview
		local rewardText = string.format("%.1fx Multiplier", info.NextTier.Multiplier)
		self.RewardsLabel.Text = "Rewards: " .. rewardText

		-- Update rebirth button state
		if info.CanRebirth then
			self.RebirthActionButton.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
			self.RebirthActionButton.Text = "REBIRTH NOW!"
		else
			self.RebirthActionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			self.RebirthActionButton.Text = "Not Ready"
		end
	else
		-- Max tier reached
		self.NextFrame.Visible = false
		self.MaxLabel.Visible = true
		self.RebirthActionButton.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
		self.RebirthActionButton.Text = "MAX TIER!"
	end
end

-- Attempt to rebirth
function RebirthUI:AttemptRebirth()
	local performRebirth = ReplicatedStorage:FindFirstChild("PerformRebirth")
	if not performRebirth then return end

	local success, result = pcall(function()
		return performRebirth:InvokeServer()
	end)

	if success and result then
		if result.Success then
			self:ShowRebirthAnimation(result.TierConfig)
		else
			self:ShowMessage(result.Message or "Cannot rebirth yet")
		end
	end

	self:UpdateDisplay()
end

-- Show rebirth animation
function RebirthUI:ShowRebirthAnimation(tierConfig)
	-- Create flash effect
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = tierConfig.Color or Color3.fromRGB(200, 150, 255)
	flash.BackgroundTransparency = 0
	flash.ZIndex = 100
	flash.Parent = self.ScreenGui

	TweenService:Create(flash, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.5, function()
		flash:Destroy()
	end)

	-- Show congratulations
	local congrats = Instance.new("TextLabel")
	congrats.Size = UDim2.new(0, 400, 0, 100)
	congrats.Position = UDim2.new(0.5, -200, 0.3, 0)
	congrats.BackgroundTransparency = 1
	congrats.Text = "REBIRTH COMPLETE!\n" .. (tierConfig.Name or "New Tier")
	congrats.TextColor3 = tierConfig.Color or Color3.new(1, 1, 1)
	congrats.TextSize = 36
	congrats.Font = Enum.Font.GothamBold
	congrats.TextStrokeTransparency = 0
	congrats.TextStrokeColor3 = Color3.new(0, 0, 0)
	congrats.ZIndex = 100
	congrats.Parent = self.ScreenGui

	TweenService:Create(congrats, TweenInfo.new(0.5), {
		Position = UDim2.new(0.5, -200, 0.25, 0)
	}):Play()

	task.delay(2, function()
		TweenService:Create(congrats, TweenInfo.new(0.3), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()

		task.delay(0.3, function()
			congrats:Destroy()
		end)
	end)
end

-- Show message
function RebirthUI:ShowMessage(message)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 300, 0, 40)
	label.Position = UDim2.new(0.5, -150, 0.7, 0)
	label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 150, 100)
	label.TextSize = 16
	label.Font = Enum.Font.Gotham
	label.ZIndex = 100
	label.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	task.delay(2, function()
		TweenService:Create(label, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()

		task.delay(0.3, function()
			label:Destroy()
		end)
	end)
end

-- Format numbers
function RebirthUI:FormatNumber(num)
	if num >= 1000000000 then
		return string.format("%.1fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	end
	return tostring(math.floor(num))
end

-- Listen for rebirth announcements
function RebirthUI:ListenForAnnouncements()
	task.spawn(function()
		local remote = nil
		local attempts = 0

		while not remote and attempts < 30 do
			remote = ReplicatedStorage:FindFirstChild("RebirthAnnouncement")
			if not remote then
				task.wait(1)
				attempts = attempts + 1
			end
		end

		if remote then
			remote.OnClientEvent:Connect(function(data)
				-- Show server-wide announcement
				if data.PlayerName ~= LocalPlayer.Name then
					self:ShowOtherPlayerRebirth(data)
				end
			end)
		end
	end)
end

-- Show when another player rebirths
function RebirthUI:ShowOtherPlayerRebirth(data)
	local announcement = Instance.new("TextLabel")
	announcement.Size = UDim2.new(0, 400, 0, 40)
	announcement.Position = UDim2.new(0.5, -200, 0.15, 0)
	announcement.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
	announcement.Text = string.format("%s reached %s tier!", data.PlayerName, data.TierName)
	announcement.TextColor3 = data.Color or Color3.fromRGB(200, 150, 255)
	announcement.TextSize = 18
	announcement.Font = Enum.Font.GothamBold
	announcement.ZIndex = 90
	announcement.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = announcement

	local stroke = Instance.new("UIStroke")
	stroke.Color = data.Color or Color3.fromRGB(200, 150, 255)
	stroke.Thickness = 2
	stroke.Parent = announcement

	task.delay(3, function()
		TweenService:Create(announcement, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.3), {
			Transparency = 1
		}):Play()

		task.delay(0.3, function()
			announcement:Destroy()
		end)
	end)
end

-- Initialize
function RebirthUI:Initialize()
	self:CreateUI()
	self:ListenForAnnouncements()

	-- Update display periodically
	task.spawn(function()
		while true do
			task.wait(5)
			if self.Panel.Visible then
				self:UpdateDisplay()
			end
		end
	end)

	print("RebirthUI initialized")
end

-- Start
RebirthUI:Initialize()

return RebirthUI
