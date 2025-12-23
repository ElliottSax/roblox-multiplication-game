-- LeaderboardUI.lua
-- Client-side UI for displaying global leaderboards

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LeaderboardUI = {}

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

	warn("LeaderboardUI: Timeout waiting for " .. name)
	return nil
end

-- Create the main UI
function LeaderboardUI:CreateUI()
	-- Main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LeaderboardUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Leaderboard Button
	local leaderboardButton = Instance.new("TextButton")
	leaderboardButton.Name = "LeaderboardButton"
	leaderboardButton.Size = UDim2.new(0, 50, 0, 50)
	leaderboardButton.Position = UDim2.new(0, 10, 0.5, -20)
	leaderboardButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	leaderboardButton.BorderSizePixel = 0
	leaderboardButton.Text = "📊"
	leaderboardButton.TextSize = 28
	leaderboardButton.Font = Enum.Font.GothamBold
	leaderboardButton.Parent = screenGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = leaderboardButton

	-- Main Leaderboard Panel
	local leaderboardPanel = Instance.new("Frame")
	leaderboardPanel.Name = "LeaderboardPanel"
	leaderboardPanel.Size = UDim2.new(0, 450, 0, 550)
	leaderboardPanel.Position = UDim2.new(0.5, -225, 0.5, -275)
	leaderboardPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	leaderboardPanel.BorderSizePixel = 0
	leaderboardPanel.Visible = false
	leaderboardPanel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 12)
	panelCorner.Parent = leaderboardPanel

	-- Panel Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	header.BorderSizePixel = 0
	header.Parent = leaderboardPanel

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header

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
	title.Text = "📊 Leaderboards"
	title.TextColor3 = Color3.fromRGB(100, 200, 255)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

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
	closeButton.Parent = leaderboardPanel

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	-- Tab bar for different leaderboards
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, -20, 0, 40)
	tabBar.Position = UDim2.new(0, 10, 0, 70)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = leaderboardPanel

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabBar

	-- Scrolling frame for entries
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "EntryList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -180)
	scrollFrame.Position = UDim2.new(0, 10, 0, 120)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent = leaderboardPanel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame

	-- Player rank display
	local playerRank = Instance.new("Frame")
	playerRank.Name = "PlayerRank"
	playerRank.Size = UDim2.new(1, -20, 0, 50)
	playerRank.Position = UDim2.new(0, 10, 1, -60)
	playerRank.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
	playerRank.BorderSizePixel = 0
	playerRank.Parent = leaderboardPanel

	local playerRankCorner = Instance.new("UICorner")
	playerRankCorner.CornerRadius = UDim.new(0, 8)
	playerRankCorner.Parent = playerRank

	local yourRankLabel = Instance.new("TextLabel")
	yourRankLabel.Name = "YourRankLabel"
	yourRankLabel.Size = UDim2.new(0.5, 0, 1, 0)
	yourRankLabel.Position = UDim2.new(0, 10, 0, 0)
	yourRankLabel.BackgroundTransparency = 1
	yourRankLabel.Text = "Your Rank: #---"
	yourRankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	yourRankLabel.TextSize = 16
	yourRankLabel.Font = Enum.Font.GothamBold
	yourRankLabel.TextXAlignment = Enum.TextXAlignment.Left
	yourRankLabel.Parent = playerRank

	local yourScoreLabel = Instance.new("TextLabel")
	yourScoreLabel.Name = "YourScoreLabel"
	yourScoreLabel.Size = UDim2.new(0.5, -10, 1, 0)
	yourScoreLabel.Position = UDim2.new(0.5, 0, 0, 0)
	yourScoreLabel.BackgroundTransparency = 1
	yourScoreLabel.Text = "Score: 0"
	yourScoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	yourScoreLabel.TextSize = 16
	yourScoreLabel.Font = Enum.Font.Gotham
	yourScoreLabel.TextXAlignment = Enum.TextXAlignment.Right
	yourScoreLabel.Parent = playerRank

	-- Store references
	self.ScreenGui = screenGui
	self.LeaderboardButton = leaderboardButton
	self.LeaderboardPanel = leaderboardPanel
	self.TabBar = tabBar
	self.ScrollFrame = scrollFrame
	self.PlayerRank = playerRank
	self.YourRankLabel = yourRankLabel
	self.YourScoreLabel = yourScoreLabel
	self.CloseButton = closeButton
	self.Tabs = {}
	self.CurrentTab = nil

	-- Connect events
	leaderboardButton.MouseButton1Click:Connect(function()
		self:TogglePanel()
	end)

	closeButton.MouseButton1Click:Connect(function()
		self:HidePanel()
	end)

	-- Button hover effects
	leaderboardButton.MouseEnter:Connect(function()
		TweenService:Create(leaderboardButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(130, 220, 255)
		}):Play()
	end)

	leaderboardButton.MouseLeave:Connect(function()
		TweenService:Create(leaderboardButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(100, 200, 255)
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

-- Create a tab button
function LeaderboardUI:CreateTab(leaderboardInfo)
	local tab = Instance.new("TextButton")
	tab.Name = leaderboardInfo.Id
	tab.Size = UDim2.new(0, 100, 1, 0)
	tab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	tab.BorderSizePixel = 0
	tab.Text = leaderboardInfo.DisplayName
	tab.TextColor3 = Color3.fromRGB(200, 200, 200)
	tab.TextSize = 11
	tab.TextTruncate = Enum.TextTruncate.AtEnd
	tab.Font = Enum.Font.Gotham
	tab.Parent = self.TabBar

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 6)
	tabCorner.Parent = tab

	tab.MouseButton1Click:Connect(function()
		self:SelectTab(leaderboardInfo.Id)
	end)

	self.Tabs[leaderboardInfo.Id] = tab

	return tab
end

-- Select a tab
function LeaderboardUI:SelectTab(tabId)
	self.CurrentTab = tabId

	-- Update tab appearances
	for id, tab in pairs(self.Tabs) do
		if id == tabId then
			tab.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
			tab.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			tab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
			tab.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	-- Refresh entries
	self:RefreshEntries(tabId)
end

-- Create an entry row
function LeaderboardUI:CreateEntryRow(entry, isCurrentPlayer)
	local row = Instance.new("Frame")
	row.Name = "Entry_" .. entry.Rank
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = isCurrentPlayer and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(40, 40, 50)
	row.BorderSizePixel = 0

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 6)
	rowCorner.Parent = row

	-- Rank medal/number
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Size = UDim2.new(0, 40, 1, 0)
	rankLabel.Position = UDim2.new(0, 5, 0, 0)
	rankLabel.BackgroundTransparency = 1

	if entry.Rank == 1 then
		rankLabel.Text = "🥇"
		rankLabel.TextSize = 24
	elseif entry.Rank == 2 then
		rankLabel.Text = "🥈"
		rankLabel.TextSize = 24
	elseif entry.Rank == 3 then
		rankLabel.Text = "🥉"
		rankLabel.TextSize = 24
	else
		rankLabel.Text = "#" .. entry.Rank
		rankLabel.TextSize = 14
		rankLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	end

	rankLabel.Font = Enum.Font.GothamBold
	rankLabel.Parent = row

	-- Player name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 200, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = entry.PlayerName
	nameLabel.TextColor3 = isCurrentPlayer and Color3.fromRGB(255, 255, 100) or Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = row

	-- Score
	local scoreLabel = Instance.new("TextLabel")
	scoreLabel.Size = UDim2.new(0, 100, 1, 0)
	scoreLabel.Position = UDim2.new(1, -110, 0, 0)
	scoreLabel.BackgroundTransparency = 1
	scoreLabel.Text = self:FormatNumber(entry.Score)
	scoreLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	scoreLabel.TextSize = 14
	scoreLabel.Font = Enum.Font.GothamBold
	scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
	scoreLabel.Parent = row

	return row
end

-- Format large numbers
function LeaderboardUI:FormatNumber(number)
	if number >= 1000000000 then
		return string.format("%.1fB", number / 1000000000)
	elseif number >= 1000000 then
		return string.format("%.1fM", number / 1000000)
	elseif number >= 1000 then
		return string.format("%.1fK", number / 1000)
	else
		return tostring(math.floor(number or 0))
	end
end

-- Toggle panel visibility
function LeaderboardUI:TogglePanel()
	if self.LeaderboardPanel.Visible then
		self:HidePanel()
	else
		self:ShowPanel()
	end
end

-- Show leaderboard panel
function LeaderboardUI:ShowPanel()
	self.LeaderboardPanel.Visible = true
	self.LeaderboardPanel.Position = UDim2.new(0.5, -225, 0, -550)

	TweenService:Create(self.LeaderboardPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -225, 0.5, -275)
	}):Play()

	-- Refresh data
	if self.CurrentTab then
		self:RefreshEntries(self.CurrentTab)
	end
end

-- Hide leaderboard panel
function LeaderboardUI:HidePanel()
	TweenService:Create(self.LeaderboardPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0.5, -225, 0, -550)
	}):Play()

	task.delay(0.2, function()
		self.LeaderboardPanel.Visible = false
	end)
end

-- Refresh entries for a leaderboard
function LeaderboardUI:RefreshEntries(leaderboardId)
	-- Clear existing entries
	for _, child in pairs(self.ScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Get entries from server
	local getLeaderboard = waitForRemote("GetLeaderboard")
	if not getLeaderboard then return end

	local success, entries = pcall(function()
		return getLeaderboard:InvokeServer(leaderboardId)
	end)

	if not success or not entries then
		warn("Failed to get leaderboard")
		return
	end

	-- Create entry rows
	for i, entry in ipairs(entries) do
		local isCurrentPlayer = entry.UserId == LocalPlayer.UserId
		local row = self:CreateEntryRow(entry, isCurrentPlayer)
		row.LayoutOrder = i
		row.Parent = self.ScrollFrame

		-- Update player rank display if this is the current player
		if isCurrentPlayer then
			self.YourRankLabel.Text = "Your Rank: #" .. entry.Rank
			self.YourScoreLabel.Text = "Score: " .. self:FormatNumber(entry.Score)
		end
	end

	-- Update canvas size
	self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #entries * 45)
end

-- Initialize tabs
function LeaderboardUI:InitializeTabs()
	local getLeaderboardInfo = waitForRemote("GetLeaderboardInfo")
	if not getLeaderboardInfo then return end

	local success, leaderboards = pcall(function()
		return getLeaderboardInfo:InvokeServer()
	end)

	if not success or not leaderboards then
		warn("Failed to get leaderboard info")
		return
	end

	-- Create tabs
	for i, info in ipairs(leaderboards) do
		self:CreateTab(info)

		-- Select first tab
		if i == 1 then
			self:SelectTab(info.Id)
		end
	end
end

-- Initialize
function LeaderboardUI:Initialize()
	self:CreateUI()

	-- Initialize tabs after a delay to ensure server is ready
	task.delay(3, function()
		self:InitializeTabs()
	end)

	print("LeaderboardUI initialized")
end

-- Start
LeaderboardUI:Initialize()

return LeaderboardUI
