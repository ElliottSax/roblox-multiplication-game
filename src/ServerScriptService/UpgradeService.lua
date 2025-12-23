-- UpgradeService.lua
-- Manages player upgrades and shop purchases

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local CurrencyService = require(script.Parent:WaitForChild("CurrencyService"))

local UpgradeService = {}
UpgradeService.PlayerUpgrades = {}
UpgradeService.AchievementService = nil -- Set by init.server.lua
UpgradeService.SoundService = nil -- Set by init.server.lua

-- Available upgrades
UpgradeService.Upgrades = {
	PushForce = {
		Name = "Push Power",
		Description = "Increase push force by 50%",
		BaseCost = 100,
		MaxLevel = 10,
		CostMultiplier = 1.5,
		Effect = function(level)
			return 1 + (level * 0.5) -- 1.5x, 2x, 2.5x, etc.
		end
	},
	SpawnRate = {
		Name = "Faster Spawns",
		Description = "Objects spawn 25% faster",
		BaseCost = 150,
		MaxLevel = 5,
		CostMultiplier = 2,
		Effect = function(level)
			return 1 - (level * 0.2) -- 0.8x, 0.6x, 0.4x spawn time
		end
	},
	AutoPush = {
		Name = "Auto Push",
		Description = "Objects move automatically",
		BaseCost = 500,
		MaxLevel = 1,
		CostMultiplier = 1,
		Effect = function(level)
			return level == 1
		end
	},
	CurrencyBonus = {
		Name = "Value Boost",
		Description = "Increase object value by 25%",
		BaseCost = 200,
		MaxLevel = 10,
		CostMultiplier = 1.75,
		Effect = function(level)
			return 1 + (level * 0.25) -- 1.25x, 1.5x, 1.75x, etc.
		end
	},
	BetterObjects = {
		Name = "Better Spawns",
		Description = "Unlock Treasure spawns",
		BaseCost = 300,
		MaxLevel = 1,
		CostMultiplier = 1,
		Effect = function(level)
			return level == 1
		end
	},
	PremiumObjects = {
		Name = "Premium Spawns",
		Description = "Unlock Diamond spawns",
		BaseCost = 1000,
		MaxLevel = 1,
		CostMultiplier = 1,
		Effect = function(level)
			return level == 1
		end,
		RequiresUpgrade = "BetterObjects"
	},
	LuckyGates = {
		Name = "Lucky Gates",
		Description = "10% chance for double gate effect",
		BaseCost = 750,
		MaxLevel = 5,
		CostMultiplier = 2,
		Effect = function(level)
			return level * 0.1 -- 10%, 20%, 30%, 40%, 50%
		end
	}
}

-- Initialize player upgrades
function UpgradeService:InitializePlayer(player)
	if not self.PlayerUpgrades[player.UserId] then
		self.PlayerUpgrades[player.UserId] = {}

		-- Set all upgrades to level 0
		for upgradeName, _ in pairs(self.Upgrades) do
			self.PlayerUpgrades[player.UserId][upgradeName] = 0
		end
	end
end

-- Get upgrade level for a player
function UpgradeService:GetUpgradeLevel(player, upgradeName)
	local upgrades = self.PlayerUpgrades[player.UserId]
	if not upgrades then return 0 end
	return upgrades[upgradeName] or 0
end

-- Calculate cost for next level of upgrade
function UpgradeService:GetUpgradeCost(upgradeName, currentLevel)
	local upgrade = self.Upgrades[upgradeName]
	if not upgrade then return 0 end

	return math.floor(upgrade.BaseCost * (upgrade.CostMultiplier ^ currentLevel))
end

-- Check if player can afford upgrade
function UpgradeService:CanAffordUpgrade(player, upgradeName)
	local currentLevel = self:GetUpgradeLevel(player, upgradeName)
	local upgrade = self.Upgrades[upgradeName]

	if not upgrade then return false end
	if currentLevel >= upgrade.MaxLevel then return false end

	-- Check prerequisites
	if upgrade.RequiresUpgrade then
		local requiredLevel = self:GetUpgradeLevel(player, upgrade.RequiresUpgrade)
		if requiredLevel < 1 then return false end
	end

	local cost = self:GetUpgradeCost(upgradeName, currentLevel)
	local playerCurrency = CurrencyService:GetCurrency(player)

	return playerCurrency >= cost
end

-- Purchase an upgrade
function UpgradeService:PurchaseUpgrade(player, upgradeName)
	-- Validate player
	if not player or not player.UserId then
		return false, "Invalid player"
	end

	-- Validate upgrade name
	if type(upgradeName) ~= "string" or upgradeName == "" then
		return false, "Invalid upgrade name"
	end

	local upgrade = self.Upgrades[upgradeName]
	if not upgrade then
		return false, "Invalid upgrade"
	end

	local currentLevel = self:GetUpgradeLevel(player, upgradeName)

	-- Check max level
	if currentLevel >= upgrade.MaxLevel then
		return false, "Max level reached"
	end

	-- Check prerequisites
	if upgrade.RequiresUpgrade then
		local requiredLevel = self:GetUpgradeLevel(player, upgrade.RequiresUpgrade)
		if requiredLevel < 1 then
			return false, "Requires " .. self.Upgrades[upgrade.RequiresUpgrade].Name
		end
	end

	-- Check cost
	local cost = self:GetUpgradeCost(upgradeName, currentLevel)
	if not CurrencyService:SpendCurrency(player, cost) then
		return false, "Not enough currency"
	end

	-- Apply upgrade
	local newLevel = currentLevel + 1
	self.PlayerUpgrades[player.UserId][upgradeName] = newLevel

	-- Update achievement stats
	if self.AchievementService then
		self.AchievementService:UpdateStat(player, "UpgradesPurchased", 1, false)

		-- Check if maxed out an upgrade
		if newLevel >= upgrade.MaxLevel then
			self.AchievementService:UpdateStat(player, "MaxUpgrade", 1, false)
		end
	end

	-- Play purchase sound
	if self.SoundService then
		self.SoundService:PlaySound("PurchaseSuccess")
	end

	print(string.format("%s purchased %s (Level %d)", player.Name, upgrade.Name, newLevel))

	return true, string.format("Purchased %s Level %d!", upgrade.Name, newLevel)
end

-- Get upgrade effect multiplier for a player
function UpgradeService:GetUpgradeEffect(player, upgradeName)
	local upgrade = self.Upgrades[upgradeName]
	if not upgrade then return 0 end

	local level = self:GetUpgradeLevel(player, upgradeName)
	return upgrade.Effect(level)
end

-- Get all upgrade info for a player
function UpgradeService:GetAllUpgrades(player)
	local upgradeInfo = {}

	for upgradeName, upgrade in pairs(self.Upgrades) do
		local currentLevel = self:GetUpgradeLevel(player, upgradeName)
		local cost = self:GetUpgradeCost(upgradeName, currentLevel)
		local canAfford = self:CanAffordUpgrade(player, upgradeName)
		local maxed = currentLevel >= upgrade.MaxLevel

		table.insert(upgradeInfo, {
			Id = upgradeName,
			Name = upgrade.Name,
			Description = upgrade.Description,
			CurrentLevel = currentLevel,
			MaxLevel = upgrade.MaxLevel,
			NextCost = maxed and 0 or cost,
			CanAfford = canAfford,
			IsMaxed = maxed,
			Effect = upgrade.Effect(currentLevel),
			RequiresUpgrade = upgrade.RequiresUpgrade
		})
	end

	return upgradeInfo
end

-- Apply upgrades to game systems
function UpgradeService:ApplyUpgradesToPlayer(player)
	-- This would be called by other services to get modified values
	-- For example, ObjectManager would call this to get push force multiplier
	return {
		PushForceMultiplier = self:GetUpgradeEffect(player, "PushForce"),
		SpawnRateMultiplier = self:GetUpgradeEffect(player, "SpawnRate"),
		HasAutoPush = self:GetUpgradeEffect(player, "AutoPush"),
		CurrencyMultiplier = self:GetUpgradeEffect(player, "CurrencyBonus"),
		HasBetterObjects = self:GetUpgradeEffect(player, "BetterObjects"),
		HasPremiumObjects = self:GetUpgradeEffect(player, "PremiumObjects"),
		LuckyGateChance = self:GetUpgradeEffect(player, "LuckyGates")
	}
end

-- Cleanup player data
function UpgradeService:CleanupPlayer(player)
	-- In production, save to DataStore here
	self.PlayerUpgrades[player.UserId] = nil
end

return UpgradeService
