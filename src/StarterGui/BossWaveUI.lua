-- BossWaveUI.lua
-- Shows boss wave announcements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BossWaveUI = {}

-- Create UI elements
function BossWaveUI:CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BossWaveUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Main announcement frame
	local announcement = Instance.new("Frame")
	announcement.Name = "Announcement"
	announcement.Size = UDim2.new(0, 600, 0, 120)
	announcement.Position = UDim2.new(0.5, -300, 0, -150)
	announcement.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	announcement.BorderSizePixel = 0
	announcement.Visible = false
	announcement.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = announcement

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 200, 0)
	stroke.Thickness = 3
	stroke.Parent = announcement

	-- Boss icon (skull emoji placeholder)
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 80, 0, 80)
	icon.Position = UDim2.new(0, 20, 0.5, -40)
	icon.BackgroundTransparency = 1
	icon.Text = "👹"
	icon.TextSize = 60
	icon.Parent = announcement

	-- Boss name
	local bossName = Instance.new("TextLabel")
	bossName.Name = "BossName"
	bossName.Size = UDim2.new(0, 450, 0, 40)
	bossName.Position = UDim2.new(0, 110, 0, 15)
	bossName.BackgroundTransparency = 1
	bossName.Text = "BOSS NAME"
	bossName.TextColor3 = Color3.fromRGB(255, 100, 100)
	bossName.TextSize = 32
	bossName.Font = Enum.Font.GothamBold
	bossName.TextXAlignment = Enum.TextXAlignment.Left
	bossName.Parent = announcement

	-- Announcement text
	local announcementText = Instance.new("TextLabel")
	announcementText.Name = "AnnouncementText"
	announcementText.Size = UDim2.new(0, 450, 0, 25)
	announcementText.Position = UDim2.new(0, 110, 0, 55)
	announcementText.BackgroundTransparency = 1
	announcementText.Text = "Boss approaches!"
	announcementText.TextColor3 = Color3.fromRGB(255, 255, 255)
	announcementText.TextSize = 18
	announcementText.Font = Enum.Font.Gotham
	announcementText.TextXAlignment = Enum.TextXAlignment.Left
	announcementText.Parent = announcement

	-- Value text
	local valueText = Instance.new("TextLabel")
	valueText.Name = "ValueText"
	valueText.Size = UDim2.new(0, 450, 0, 20)
	valueText.Position = UDim2.new(0, 110, 0, 80)
	valueText.BackgroundTransparency = 1
	valueText.Text = "Worth: 1000 Currency!"
	valueText.TextColor3 = Color3.fromRGB(100, 255, 100)
	valueText.TextSize = 16
	valueText.Font = Enum.Font.GothamBold
	valueText.TextXAlignment = Enum.TextXAlignment.Left
	valueText.Parent = announcement

	self.ScreenGui = screenGui
	self.Announcement = announcement
	self.BossName = bossName
	self.AnnouncementText = announcementText
	self.ValueText = valueText
	self.Stroke = stroke
end

-- Show boss wave announcement
function BossWaveUI:ShowAnnouncement(data)
	self.BossName.Text = data.BossName:upper()
	self.AnnouncementText.Text = data.Announcement
	self.ValueText.Text = "Worth: " .. data.Value .. " Currency!"

	-- Update colors
	if data.Color then
		self.BossName.TextColor3 = data.Color
		self.Stroke.Color = data.Color
	end

	-- Position off-screen
	self.Announcement.Position = UDim2.new(0.5, -300, 0, -150)
	self.Announcement.Visible = true

	-- Slide in
	TweenService:Create(self.Announcement, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -300, 0, 50)
	}):Play()

	-- Screen shake effect (subtle)
	self:ScreenShake()

	-- Hide after 4 seconds
	task.delay(4, function()
		TweenService:Create(self.Announcement, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0.5, -300, 0, -150)
		}):Play()

		task.delay(0.3, function()
			self.Announcement.Visible = false
		end)
	end)
end

-- Subtle screen shake
function BossWaveUI:ScreenShake()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local originalCFrame = camera.CFrame

	for i = 1, 10 do
		local shakeX = math.random(-10, 10) / 100
		local shakeY = math.random(-10, 10) / 100

		camera.CFrame = originalCFrame * CFrame.new(shakeX, shakeY, 0)
		task.wait(0.02)
	end

	camera.CFrame = originalCFrame
end

-- Initialize
function BossWaveUI:Initialize()
	self:CreateUI()

	-- Listen for boss wave announcements
	task.spawn(function()
		local remote = nil
		local attempts = 0

		while not remote and attempts < 30 do
			remote = ReplicatedStorage:FindFirstChild("BossWaveAnnouncement")
			if not remote then
				task.wait(1)
				attempts = attempts + 1
			end
		end

		if remote then
			remote.OnClientEvent:Connect(function(data)
				self:ShowAnnouncement(data)
			end)
			print("BossWaveUI connected to remote")
		else
			warn("BossWaveUI: Could not find BossWaveAnnouncement remote")
		end
	end)

	print("BossWaveUI initialized")
end

-- Start
BossWaveUI:Initialize()

return BossWaveUI
