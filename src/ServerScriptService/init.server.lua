-- Main Server Initialization Script
-- This initializes all game services and sets up the game

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load services
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ObjectManager = require(script:WaitForChild("ObjectManager"))
local MultiplierService = require(script:WaitForChild("MultiplierService"))
local CurrencyService = require(script:WaitForChild("CurrencyService"))
local PathManager = require(script:WaitForChild("PathManager"))
local UpgradeService = require(script:WaitForChild("UpgradeService"))
local DataService = require(script:WaitForChild("DataService"))
local ComboService = require(script:WaitForChild("ComboService"))
local AdminCommands = require(script:WaitForChild("AdminCommands"))
local AchievementService = require(script:WaitForChild("AchievementService"))
local SoundService = require(script:WaitForChild("SoundService"))
local LeaderboardService = require(script:WaitForChild("LeaderboardService"))
local BossWaveService = require(script:WaitForChild("BossWaveService"))
local RebirthService = require(script:WaitForChild("RebirthService"))
local QuestService = require(script:WaitForChild("QuestService"))
local PetService = require(script:WaitForChild("PetService"))

print("=== Multiplication Game Initializing ===")

-- ==================== RATE LIMITING SYSTEM ====================
-- Prevents exploit attempts by limiting remote event calls per player

local RateLimiter = {}
local RATE_LIMIT = 10 -- Maximum requests per second per player

-- Check if player is within rate limit for a specific remote
local function CheckRateLimit(player, remoteName)
	local key = player.UserId .. "_" .. remoteName
	local now = tick()

	-- Initialize rate limit data for this player+remote
	if not RateLimiter[key] then
		RateLimiter[key] = {count = 1, resetTime = now + 1}
		return true
	end

	-- Reset counter if time window has passed
	if now >= RateLimiter[key].resetTime then
		RateLimiter[key] = {count = 1, resetTime = now + 1}
		return true
	end

	-- Increment counter
	RateLimiter[key].count = RateLimiter[key].count + 1

	-- Check if over limit
	if RateLimiter[key].count > RATE_LIMIT then
		warn(string.format("[Security] %s rate limited on %s (%d requests/sec)",
			player.Name, remoteName, RateLimiter[key].count))
		return false
	end

	return true
end

-- Wrap a RemoteFunction handler with rate limiting + pcall + warn-on-error
local function WrapHandler(remoteName, rateLimitDefault, errorDefault, fn)
	return function(player, ...)
		if not CheckRateLimit(player, remoteName) then
			return rateLimitDefault
		end

		local success, result = pcall(fn, player, ...)

		if success then
			return result
		else
			warn(remoteName .. " error:", result)
			return errorDefault
		end
	end
end

-- Cleanup old rate limit entries periodically
task.spawn(function()
	while true do
		wait(60) -- Clean every minute
		local now = tick()
		for key, data in pairs(RateLimiter) do
			if now > data.resetTime + 10 then
				RateLimiter[key] = nil
			end
		end
	end
end)

-- ==================== REMOTE EVENTS ====================

-- Create remote events for client-server communication
local function CreateRemoteEvents()
	-- Shop remotes
	local getUpgrades = Instance.new("RemoteFunction")
	getUpgrades.Name = "GetUpgrades"
	getUpgrades.Parent = ReplicatedStorage

	local purchaseUpgrade = Instance.new("RemoteFunction")
	purchaseUpgrade.Name = "PurchaseUpgrade"
	purchaseUpgrade.Parent = ReplicatedStorage

	-- Combo remotes
	local comboUpdate = Instance.new("RemoteEvent")
	comboUpdate.Name = "ComboUpdate"
	comboUpdate.Parent = ReplicatedStorage

	local comboNotification = Instance.new("RemoteEvent")
	comboNotification.Name = "ComboNotification"
	comboNotification.Parent = ReplicatedStorage

	-- Admin message remote
	local adminMessage = Instance.new("RemoteEvent")
	adminMessage.Name = "AdminMessage"
	adminMessage.Parent = ReplicatedStorage

	-- Achievement remotes
	local getAchievements = Instance.new("RemoteFunction")
	getAchievements.Name = "GetAchievements"
	getAchievements.Parent = ReplicatedStorage

	local achievementUnlocked = Instance.new("RemoteEvent")
	achievementUnlocked.Name = "AchievementUnlocked"
	achievementUnlocked.Parent = ReplicatedStorage

	-- Leaderboard remotes
	local getLeaderboard = Instance.new("RemoteFunction")
	getLeaderboard.Name = "GetLeaderboard"
	getLeaderboard.Parent = ReplicatedStorage

	local getLeaderboardInfo = Instance.new("RemoteFunction")
	getLeaderboardInfo.Name = "GetLeaderboardInfo"
	getLeaderboardInfo.Parent = ReplicatedStorage

	-- Set up remote handlers with error handling and rate limiting
	getUpgrades.OnServerInvoke = WrapHandler("GetUpgrades", {}, {}, function(player)
		return UpgradeService:GetAllUpgrades(player)
	end)

	purchaseUpgrade.OnServerInvoke = WrapHandler("PurchaseUpgrade", {Success = false, Message = "Too many requests. Please slow down."}, {Success = false, Message = "Server error"}, function(player, upgradeName)
		local purchaseSuccess, message = UpgradeService:PurchaseUpgrade(player, upgradeName)
		return {Success = purchaseSuccess, Message = message}
	end)

	getAchievements.OnServerInvoke = WrapHandler("GetAchievements", {}, {}, function(player)
		return AchievementService:GetAllAchievements(player)
	end)

	getLeaderboard.OnServerInvoke = WrapHandler("GetLeaderboard", {}, {}, function(player, leaderboardId)
		return LeaderboardService:GetLeaderboard(leaderboardId, 100)
	end)

	getLeaderboardInfo.OnServerInvoke = WrapHandler("GetLeaderboardInfo", {}, {}, function(player)
		return LeaderboardService:GetAllLeaderboardInfo()
	end)

	-- Rebirth remotes
	local getRebirthInfo = Instance.new("RemoteFunction")
	getRebirthInfo.Name = "GetRebirthInfo"
	getRebirthInfo.Parent = ReplicatedStorage

	local performRebirth = Instance.new("RemoteFunction")
	performRebirth.Name = "PerformRebirth"
	performRebirth.Parent = ReplicatedStorage

	getRebirthInfo.OnServerInvoke = WrapHandler("GetRebirthInfo", {}, {}, function(player)
		return RebirthService:GetRebirthInfo(player)
	end)

	performRebirth.OnServerInvoke = WrapHandler("PerformRebirth", {Success = false, Message = "Too many requests. Please slow down."}, {Success = false, Message = "Server error"}, function(player)
		local rebirthSuccess, tierConfig = RebirthService:Rebirth(player)
		return {Success = rebirthSuccess, TierConfig = tierConfig, Message = not rebirthSuccess and tierConfig or nil}
	end)

	-- Quest remotes
	local getQuests = Instance.new("RemoteFunction")
	getQuests.Name = "GetQuests"
	getQuests.Parent = ReplicatedStorage

	local claimQuest = Instance.new("RemoteFunction")
	claimQuest.Name = "ClaimQuest"
	claimQuest.Parent = ReplicatedStorage

	getQuests.OnServerInvoke = WrapHandler("GetQuests", {}, {}, function(player)
		return QuestService:GetQuests(player)
	end)

	claimQuest.OnServerInvoke = WrapHandler("ClaimQuest", {Success = false, Message = "Too many requests. Please slow down."}, {Success = false, Message = "Server error"}, function(player, questId)
		local claimSuccess, reward = QuestService:ClaimReward(player, questId)
		return {Success = claimSuccess, Reward = reward, Message = not claimSuccess and reward or nil}
	end)

	-- Pet remotes
	local getPetData = Instance.new("RemoteFunction")
	getPetData.Name = "GetPetData"
	getPetData.Parent = ReplicatedStorage

	local hatchEgg = Instance.new("RemoteFunction")
	hatchEgg.Name = "HatchEgg"
	hatchEgg.Parent = ReplicatedStorage

	local equipPet = Instance.new("RemoteFunction")
	equipPet.Name = "EquipPet"
	equipPet.Parent = ReplicatedStorage

	local unequipPet = Instance.new("RemoteFunction")
	unequipPet.Name = "UnequipPet"
	unequipPet.Parent = ReplicatedStorage

	getPetData.OnServerInvoke = WrapHandler("GetPetData", {}, {}, function(player)
		return PetService:GetPetData(player)
	end)

	hatchEgg.OnServerInvoke = WrapHandler("HatchEgg", {Success = false, Message = "Too many requests. Please slow down."}, {Success = false, Message = "Server error"}, function(player, eggId)
		local hatchSuccess, petOrMessage = PetService:HatchEgg(player, eggId)
		return {Success = hatchSuccess, Pet = hatchSuccess and petOrMessage or nil, Message = not hatchSuccess and petOrMessage or nil}
	end)

	equipPet.OnServerInvoke = WrapHandler("EquipPet", {Success = false, Message = "Too many requests. Please slow down."}, {Success = false, Message = "Server error"}, function(player, petId)
		local equipSuccess, pet = PetService:EquipPet(player, petId)
		return {Success = equipSuccess, Pet = pet}
	end)

	unequipPet.OnServerInvoke = WrapHandler("UnequipPet", {Success = false, Message = "Too many requests. Please slow down."}, {Success = false, Message = "Server error"}, function(player, petId)
		local unequipSuccess = PetService:UnequipPet(player, petId)
		return {Success = unequipSuccess}
	end)

	print("Remote events created")
end

-- Game state
local GameState = {
	IsRunning = false,
	SpawnPosition = Vector3.new(0, 10, 0), -- Default spawn position
	ObjectSpawnTimer = 0
}

-- Initialize the game world
local function InitializeGame()
	print("Creating game path...")

	-- Reclaim objects that overshoot the collection zone (no KillBrick exists in the world)
	ObjectManager:StartWatchdog()

	-- Initialize sound service
	SoundService:Initialize()

	-- Initialize leaderboard service
	LeaderboardService:Initialize()

	-- Connect services together
	MultiplierService.ComboService = ComboService
	MultiplierService.AchievementService = AchievementService
	MultiplierService.SoundService = SoundService
	MultiplierService.QuestService = QuestService
	MultiplierService.RebirthService = RebirthService
	MultiplierService.PetService = PetService
	MultiplierService.UpgradeService = UpgradeService
	CurrencyService.AchievementService = AchievementService
	CurrencyService.SoundService = SoundService
	CurrencyService.QuestService = QuestService
	CurrencyService.RebirthService = RebirthService
	CurrencyService.PetService = PetService
	CurrencyService.UpgradeService = UpgradeService
	ComboService.AchievementService = AchievementService
	ComboService.SoundService = SoundService
	ComboService.QuestService = QuestService
	UpgradeService.AchievementService = AchievementService
	UpgradeService.SoundService = SoundService
	AchievementService.SoundService = SoundService
	RebirthService.CurrencyService = CurrencyService
	RebirthService.AchievementService = AchievementService
	RebirthService.SoundService = SoundService
	QuestService.CurrencyService = CurrencyService
	QuestService.AchievementService = AchievementService
	QuestService.SoundService = SoundService
	QuestService.RebirthService = RebirthService
	PetService.CurrencyService = CurrencyService
	PetService.AchievementService = AchievementService
	PetService.SoundService = SoundService

	-- Create the main path
	local path, spawnPlatform = PathManager:CreatePath(GameState.SpawnPosition)

	-- Generate multiplier gates along the path
	print("Generating multiplier gates...")
	MultiplierService:GenerateGatesOnPath(
		GameState.SpawnPosition,
		Config.Path.Length
	)

	-- Enable object pushing mechanics
	print("Enabling object pushing...")
	PathManager:EnableObjectPushing()

	GameState.IsRunning = true

	-- Start background music
	SoundService:StartBackgroundMusic()

	-- Initialize and start boss wave system
	BossWaveService:Initialize(GameState.SpawnPosition, ObjectManager)
	BossWaveService.SoundService = SoundService
	BossWaveService:Start()

	print("Game initialization complete!")
end

-- Spawn objects automatically
local function SpawnObjects()
	-- Spawn loop is global/shared rather than per-player, so gate the
	-- weighted progression on whichever active player has gone furthest
	local totalEarned = 0
	for _, player in ipairs(Players:GetPlayers()) do
		local data = CurrencyService.PlayerData[player.UserId]
		if data and data.TotalValue and data.TotalValue > totalEarned then
			totalEarned = data.TotalValue
		end
	end

	-- Spawn at the spawn platform
	local spawnPosition = GameState.SpawnPosition + Vector3.new(
		math.random(-5, 5),
		2,
		math.random(-2, 2)
	)

	local object = ObjectManager:SpawnRandomObject(spawnPosition, totalEarned)

	if object then
		-- Give initial forward momentum
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, -5)
		bodyVelocity.MaxForce = Vector3.new(0, 0, 25000)
		bodyVelocity.Parent = object

		-- Remove velocity after a bit
		task.delay(1, function()
			if bodyVelocity and bodyVelocity.Parent then
				bodyVelocity:Destroy()
			end
		end)

		local typeTag = object:FindFirstChild("ObjectType")
		print("Spawned " .. (typeTag and typeTag.Value or "Unknown"))
	end
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	print(string.format("Player %s joined the game", player.Name))

	-- Load player data
	local playerData = DataService:LoadData(player)

	-- Initialize services with loaded data
	CurrencyService:InitializePlayer(player)
	UpgradeService:InitializePlayer(player)
	ComboService:InitializePlayer(player)
	AchievementService:InitializePlayer(player)
	RebirthService:InitializePlayer(player)
	QuestService:InitializePlayer(player)
	PetService:InitializePlayer(player)

	-- Restore saved data
	if playerData then
		CurrencyService.PlayerData[player.UserId].Currency = playerData.Currency
		CurrencyService.PlayerData[player.UserId].ObjectsCollected = playerData.ObjectsCollected
		CurrencyService.PlayerData[player.UserId].TotalValue = playerData.TotalValue

		-- Restore upgrades
		if playerData.Upgrades then
			UpgradeService.PlayerUpgrades[player.UserId] = playerData.Upgrades
		end

		-- Restore achievements
		if playerData.Achievements then
			AchievementService:LoadAchievements(player, playerData)
		end

		-- Restore rebirth data
		if playerData.Rebirth then
			RebirthService:LoadData(player, playerData.Rebirth)
		end

		-- Restore quest data
		if playerData.Quests then
			QuestService:LoadData(player, playerData.Quests)
		end

		-- Restore pet data
		if playerData.Pets then
			PetService:LoadData(player, playerData.Pets)
		end

		-- Update leaderstats with loaded data
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local currency = leaderstats:FindFirstChild("Currency")
			local collected = leaderstats:FindFirstChild("Collected")
			if currency then currency.Value = playerData.Currency end
			if collected then collected.Value = playerData.ObjectsCollected end
		end

		-- Sync achievement stats with currency data
		AchievementService:UpdateStat(player, "ObjectsCollected", playerData.ObjectsCollected or 0, true)
		AchievementService:UpdateStat(player, "TotalEarned", playerData.TotalValue or 0, true)
	end

	-- Teleport player to spawn when character loads
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5) -- Wait for character to fully load
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		humanoidRootPart.CFrame = CFrame.new(GameState.SpawnPosition + Vector3.new(0, 3, 5))
	end)
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	print(string.format("Player %s left the game", player.Name))

	-- Update leaderboards before saving
	local currencyData = CurrencyService.PlayerData[player.UserId]
	local comboData = ComboService.PlayerCombos[player.UserId]
	if currencyData then
		LeaderboardService:UpdateAllLeaderboards(player, {
			TotalEarned = currencyData.TotalValue or 0,
			ObjectsCollected = currencyData.ObjectsCollected or 0,
			Currency = currencyData.Currency or 0,
			MaxCombo = comboData and comboData.HighestCombo or 0
		})
	end

	-- Save to DataStore
	DataService:PlayerLeaving(player)

	-- Cleanup services
	CurrencyService:CleanupPlayer(player)
	UpgradeService:CleanupPlayer(player)
	ComboService:CleanupPlayer(player)
	AchievementService:CleanupPlayer(player)
	RebirthService:CleanupPlayer(player)
	QuestService:CleanupPlayer(player)
	PetService:CleanupPlayer(player)
end)

-- Main game loop
local function GameLoop()
	while GameState.IsRunning do
		task.wait(1)

		-- Auto-spawn objects
		GameState.ObjectSpawnTimer += 1

		if GameState.ObjectSpawnTimer >= Config.Objects.Goblin.SpawnRate then
			SpawnObjects()
			GameState.ObjectSpawnTimer = 0
		end

		-- Optional: Print stats every 30 seconds
		if GameState.ObjectSpawnTimer % 30 == 0 then
			print(string.format("Active objects: %d", ObjectManager:GetObjectCount()))
		end
	end
end

-- Graceful shutdown handler
game:BindToClose(function()
	print("Server shutting down, saving all data...")
	DataService:BackupAllData()
	task.wait(3) -- Give time for saves to complete
end)

-- Initialize remote events
CreateRemoteEvents()

-- Initialize admin commands
AdminCommands:Initialize()

-- Start combo checker
ComboService:StartComboChecker()

-- Start auto-save system
DataService:StartAutoSave()

-- Initialize the game world
InitializeGame()

-- Start the game loop
task.spawn(GameLoop)

print("=== Multiplication Game is Running ===")
print("=== All services initialized ===")
