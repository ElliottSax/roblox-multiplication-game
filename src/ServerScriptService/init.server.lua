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

	-- Set up remote handlers with error handling
	getUpgrades.OnServerInvoke = function(player)
		local success, result = pcall(function()
			return UpgradeService:GetAllUpgrades(player)
		end)

		if success then
			return result
		else
			warn("GetUpgrades error:", result)
			return {}
		end
	end

	purchaseUpgrade.OnServerInvoke = function(player, upgradeName)
		local success, result = pcall(function()
			local purchaseSuccess, message = UpgradeService:PurchaseUpgrade(player, upgradeName)
			return {Success = purchaseSuccess, Message = message}
		end)

		if success then
			return result
		else
			warn("PurchaseUpgrade error:", result)
			return {Success = false, Message = "Server error"}
		end
	end

	getAchievements.OnServerInvoke = function(player)
		local success, result = pcall(function()
			return AchievementService:GetAllAchievements(player)
		end)

		if success then
			return result
		else
			warn("GetAchievements error:", result)
			return {}
		end
	end

	getLeaderboard.OnServerInvoke = function(player, leaderboardId)
		local success, result = pcall(function()
			return LeaderboardService:GetLeaderboard(leaderboardId, 100)
		end)

		if success then
			return result
		else
			warn("GetLeaderboard error:", result)
			return {}
		end
	end

	getLeaderboardInfo.OnServerInvoke = function(player)
		local success, result = pcall(function()
			return LeaderboardService:GetAllLeaderboardInfo()
		end)

		if success then
			return result
		else
			warn("GetLeaderboardInfo error:", result)
			return {}
		end
	end

	-- Rebirth remotes
	local getRebirthInfo = Instance.new("RemoteFunction")
	getRebirthInfo.Name = "GetRebirthInfo"
	getRebirthInfo.Parent = ReplicatedStorage

	local performRebirth = Instance.new("RemoteFunction")
	performRebirth.Name = "PerformRebirth"
	performRebirth.Parent = ReplicatedStorage

	getRebirthInfo.OnServerInvoke = function(player)
		local success, result = pcall(function()
			return RebirthService:GetRebirthInfo(player)
		end)

		if success then
			return result
		else
			warn("GetRebirthInfo error:", result)
			return {}
		end
	end

	performRebirth.OnServerInvoke = function(player)
		local success, tierConfig = RebirthService:Rebirth(player)
		return {Success = success, TierConfig = tierConfig, Message = not success and tierConfig or nil}
	end

	-- Quest remotes
	local getQuests = Instance.new("RemoteFunction")
	getQuests.Name = "GetQuests"
	getQuests.Parent = ReplicatedStorage

	local claimQuest = Instance.new("RemoteFunction")
	claimQuest.Name = "ClaimQuest"
	claimQuest.Parent = ReplicatedStorage

	getQuests.OnServerInvoke = function(player)
		local success, result = pcall(function()
			return QuestService:GetQuests(player)
		end)

		if success then
			return result
		else
			warn("GetQuests error:", result)
			return {}
		end
	end

	claimQuest.OnServerInvoke = function(player, questId)
		local success, reward = QuestService:ClaimReward(player, questId)
		return {Success = success, Reward = reward, Message = not success and reward or nil}
	end

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

	getPetData.OnServerInvoke = function(player)
		local success, result = pcall(function()
			return PetService:GetPetData(player)
		end)

		if success then
			return result
		else
			warn("GetPetData error:", result)
			return {}
		end
	end

	hatchEgg.OnServerInvoke = function(player, eggId)
		local success, petOrMessage = PetService:HatchEgg(player, eggId)
		return {Success = success, Pet = success and petOrMessage or nil, Message = not success and petOrMessage or nil}
	end

	equipPet.OnServerInvoke = function(player, petId)
		local success, result = PetService:EquipPet(player, petId)
		return {Success = success, Pet = result}
	end

	unequipPet.OnServerInvoke = function(player, petId)
		local success = PetService:UnequipPet(player, petId)
		return {Success = success}
	end

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
	CurrencyService.AchievementService = AchievementService
	CurrencyService.SoundService = SoundService
	CurrencyService.QuestService = QuestService
	CurrencyService.RebirthService = RebirthService
	CurrencyService.PetService = PetService
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
	-- Start with Goblins
	local objectType = "Goblin"
	local spawnConfig = Config.Objects[objectType]

	-- Spawn at the spawn platform
	local spawnPosition = GameState.SpawnPosition + Vector3.new(
		math.random(-5, 5),
		2,
		math.random(-2, 2)
	)

	local object = ObjectManager:SpawnObject(objectType, spawnPosition)

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

		print("Spawned " .. objectType)
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

	-- Save player data before cleanup
	local sessionData = DataService:GetData(player)
	if sessionData then
		-- Update session data with current values
		local currencyData = CurrencyService.PlayerData[player.UserId]
		if currencyData then
			sessionData.Currency = currencyData.Currency
			sessionData.ObjectsCollected = currencyData.ObjectsCollected
			sessionData.TotalValue = currencyData.TotalValue
		end

		-- Save upgrades
		local upgrades = UpgradeService.PlayerUpgrades[player.UserId]
		if upgrades then
			sessionData.Upgrades = upgrades
		end

		-- Save achievements
		local achievementData = AchievementService:GetSaveData(player)
		if achievementData then
			sessionData.Achievements = achievementData
		end

		-- Save rebirth data
		local rebirthData = RebirthService:GetSaveData(player)
		if rebirthData then
			sessionData.Rebirth = rebirthData
		end

		-- Save quest data
		local questData = QuestService:GetSaveData(player)
		if questData then
			sessionData.Quests = questData
		end

		-- Save pet data
		local petData = PetService:GetSaveData(player)
		if petData then
			sessionData.Pets = petData
		end
	end

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
