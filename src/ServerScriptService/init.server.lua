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

	-- Connect MultiplierService with ComboService
	MultiplierService.ComboService = ComboService

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

	-- Restore saved data
	if playerData then
		CurrencyService.PlayerData[player.UserId].Currency = playerData.Currency
		CurrencyService.PlayerData[player.UserId].ObjectsCollected = playerData.ObjectsCollected
		CurrencyService.PlayerData[player.UserId].TotalValue = playerData.TotalValue

		-- Restore upgrades
		if playerData.Upgrades then
			UpgradeService.PlayerUpgrades[player.UserId] = playerData.Upgrades
		end

		-- Update leaderstats with loaded data
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local currency = leaderstats:FindFirstChild("Currency")
			local collected = leaderstats:FindFirstChild("Collected")
			if currency then currency.Value = playerData.Currency end
			if collected then collected.Value = playerData.ObjectsCollected end
		end
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
	end

	-- Save to DataStore
	DataService:PlayerLeaving(player)

	-- Cleanup services
	CurrencyService:CleanupPlayer(player)
	UpgradeService:CleanupPlayer(player)
	ComboService:CleanupPlayer(player)
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
