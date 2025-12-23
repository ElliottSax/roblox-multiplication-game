-- BossWaveService.lua
-- Spawns special boss waves with high-value objects

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BossWaveService = {}

-- Boss definitions
BossWaveService.Bosses = {
	GoblinKing = {
		Name = "Goblin King",
		Color = Color3.fromRGB(150, 50, 50),
		Size = Vector3.new(5, 5, 5),
		Value = 100,
		Health = 3, -- Hits needed to fully process
		SpawnCount = 1, -- How many spawn
		Announcement = "The Goblin King approaches!"
	},
	TreasureDragon = {
		Name = "Treasure Dragon",
		Color = Color3.fromRGB(255, 200, 50),
		Size = Vector3.new(6, 6, 6),
		Value = 250,
		Health = 5,
		SpawnCount = 1,
		Announcement = "A Treasure Dragon has appeared!"
	},
	DiamondGolem = {
		Name = "Diamond Golem",
		Color = Color3.fromRGB(100, 200, 255),
		Size = Vector3.new(7, 7, 7),
		Value = 500,
		Health = 7,
		SpawnCount = 1,
		Announcement = "The Diamond Golem awakens!"
	},
	GoblinHorde = {
		Name = "Goblin Horde",
		Color = Color3.fromRGB(50, 150, 50),
		Size = Vector3.new(3, 3, 3),
		Value = 25,
		Health = 1,
		SpawnCount = 20, -- Many small goblins
		Announcement = "A Goblin Horde is invading!"
	},
	GoldenPhoenix = {
		Name = "Golden Phoenix",
		Color = Color3.fromRGB(255, 150, 0),
		Size = Vector3.new(4, 4, 4),
		Value = 1000,
		Health = 10,
		SpawnCount = 1,
		Announcement = "A LEGENDARY Golden Phoenix descends!"
	}
}

-- Boss wave configurations
BossWaveService.WaveConfigs = {
	{MinuteMark = 2, BossType = "GoblinHorde", Chance = 100},
	{MinuteMark = 5, BossType = "GoblinKing", Chance = 80},
	{MinuteMark = 10, BossType = "TreasureDragon", Chance = 70},
	{MinuteMark = 15, BossType = "DiamondGolem", Chance = 60},
	{MinuteMark = 20, BossType = "GoldenPhoenix", Chance = 40},
}

-- State
BossWaveService.ActiveBosses = {}
BossWaveService.IsRunning = false
BossWaveService.SpawnPosition = Vector3.new(0, 10, 0)
BossWaveService.WaveCount = 0
BossWaveService.GameStartTime = 0

-- Services references
BossWaveService.ObjectManager = nil
BossWaveService.SoundService = nil

-- Initialize
function BossWaveService:Initialize(spawnPosition, objectManager)
	self.SpawnPosition = spawnPosition
	self.ObjectManager = objectManager
	self.GameStartTime = tick()
	print("[BossWaveService] Initialized")
end

-- Start boss wave system
function BossWaveService:Start()
	if self.IsRunning then return end
	self.IsRunning = true

	task.spawn(function()
		while self.IsRunning do
			task.wait(60) -- Check every minute
			self:CheckForWave()
		end
	end)

	print("[BossWaveService] Started - boss waves will spawn periodically")
end

-- Stop boss wave system
function BossWaveService:Stop()
	self.IsRunning = false
end

-- Check if a wave should spawn
function BossWaveService:CheckForWave()
	local minutesPlayed = math.floor((tick() - self.GameStartTime) / 60)

	for _, config in ipairs(self.WaveConfigs) do
		-- Check if we've reached this minute mark (with some tolerance for repeating)
		if minutesPlayed >= config.MinuteMark and
			(minutesPlayed - config.MinuteMark) % 5 == 0 then -- Repeat every 5 minutes after first trigger

			-- Roll for chance
			if math.random(100) <= config.Chance then
				self:SpawnBossWave(config.BossType)
				return -- Only one wave at a time
			end
		end
	end
end

-- Force spawn a boss wave (for testing or special events)
function BossWaveService:SpawnBossWave(bossType)
	local boss = self.Bosses[bossType]
	if not boss then
		warn("[BossWaveService] Unknown boss type:", bossType)
		return
	end

	self.WaveCount = self.WaveCount + 1

	-- Announce the boss
	self:AnnounceWave(boss)

	-- Spawn boss objects
	for i = 1, boss.SpawnCount do
		task.delay((i - 1) * 0.2, function()
			self:SpawnBossObject(boss)
		end)
	end

	print(string.format("[BossWaveService] Wave %d: %s spawned!", self.WaveCount, boss.Name))
end

-- Spawn a single boss object
function BossWaveService:SpawnBossObject(bossConfig)
	-- Create boss part
	local boss = Instance.new("Part")
	boss.Name = "Boss_" .. bossConfig.Name:gsub(" ", "_")
	boss.Size = bossConfig.Size
	boss.Color = bossConfig.Color
	boss.Material = Enum.Material.Neon
	boss.Anchored = false
	boss.CanCollide = true

	-- Add special boss glow
	local highlight = Instance.new("Highlight")
	highlight.FillColor = bossConfig.Color
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.5
	highlight.Parent = boss

	-- Add floating label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, bossConfig.Size.Y / 2 + 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = boss

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = bossConfig.Name
	nameLabel.TextColor3 = bossConfig.Color
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.Parent = billboard

	-- Add object type marker
	local objectType = Instance.new("StringValue")
	objectType.Name = "ObjectType"
	objectType.Value = "Boss"
	objectType.Parent = boss

	-- Add value
	local objectValue = Instance.new("IntValue")
	objectValue.Name = "ObjectValue"
	objectValue.Value = bossConfig.Value
	objectValue.Parent = boss

	-- Add boss marker
	local bossMarker = Instance.new("StringValue")
	bossMarker.Name = "BossType"
	bossMarker.Value = bossConfig.Name
	bossMarker.Parent = boss

	-- Add health system
	local health = Instance.new("IntValue")
	health.Name = "BossHealth"
	health.Value = bossConfig.Health
	health.Parent = boss

	-- Spawn position with some randomness
	local spawnX = self.SpawnPosition.X + math.random(-8, 8)
	local spawnZ = self.SpawnPosition.Z + math.random(-3, 3)
	boss.Position = Vector3.new(spawnX, self.SpawnPosition.Y + bossConfig.Size.Y, spawnZ)

	boss.Parent = workspace

	-- Add particle effects
	self:AddBossParticles(boss, bossConfig.Color)

	-- Track active boss
	table.insert(self.ActiveBosses, boss)

	-- Cleanup when boss is destroyed
	boss.Destroying:Connect(function()
		self:OnBossDestroyed(boss)
	end)

	return boss
end

-- Add special particles to boss
function BossWaveService:AddBossParticles(boss, color)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Rate = 50
	emitter.Speed = NumberRange.new(3, 5)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = boss

	-- Add secondary glow particles
	local glow = Instance.new("ParticleEmitter")
	glow.Color = ColorSequence.new(Color3.new(1, 1, 1))
	glow.Size = NumberSequence.new(2)
	glow.Transparency = NumberSequence.new(0.7)
	glow.Texture = "rbxasset://textures/particles/smoke_main.dds"
	glow.Lifetime = NumberRange.new(0.3, 0.5)
	glow.Rate = 20
	glow.Speed = NumberRange.new(0, 1)
	glow.Parent = boss
end

-- Announce wave to all players
function BossWaveService:AnnounceWave(bossConfig)
	local bossWaveRemote = ReplicatedStorage:FindFirstChild("BossWaveAnnouncement")
	if not bossWaveRemote then
		bossWaveRemote = Instance.new("RemoteEvent")
		bossWaveRemote.Name = "BossWaveAnnouncement"
		bossWaveRemote.Parent = ReplicatedStorage
	end

	-- Send to all players
	bossWaveRemote:FireAllClients({
		BossName = bossConfig.Name,
		Announcement = bossConfig.Announcement,
		Color = bossConfig.Color,
		Value = bossConfig.Value
	})

	-- Also print to console
	print("[BOSS WAVE] " .. bossConfig.Announcement)
end

-- Handle boss destruction
function BossWaveService:OnBossDestroyed(boss)
	-- Remove from active list
	for i, activeBoss in ipairs(self.ActiveBosses) do
		if activeBoss == boss then
			table.remove(self.ActiveBosses, i)
			break
		end
	end
end

-- Get active boss count
function BossWaveService:GetActiveBossCount()
	return #self.ActiveBosses
end

-- Force spawn random boss (for admin command)
function BossWaveService:ForceSpawnRandomBoss()
	local bossTypes = {}
	for bossType, _ in pairs(self.Bosses) do
		table.insert(bossTypes, bossType)
	end

	local randomBoss = bossTypes[math.random(1, #bossTypes)]
	self:SpawnBossWave(randomBoss)

	return randomBoss
end

-- Cleanup all bosses
function BossWaveService:ClearAllBosses()
	for _, boss in ipairs(self.ActiveBosses) do
		if boss and boss.Parent then
			boss:Destroy()
		end
	end
	self.ActiveBosses = {}
end

return BossWaveService
