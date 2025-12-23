-- AchievementService
-- Handles player achievements, tracking, and rewards

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AchievementService = {}
AchievementService.__index = AchievementService

-- Player achievement data
AchievementService.PlayerAchievements = {}
AchievementService.SoundService = nil -- Set by init.server.lua

-- Achievement definitions
AchievementService.Achievements = {
	-- Collection achievements
	FirstBlood = {
		Id = "FirstBlood",
		Name = "First Blood",
		Description = "Collect your first object",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "ObjectsCollected", Value = 1},
		Reward = {Type = "Currency", Value = 10},
		Tier = "Bronze"
	},
	Collector = {
		Id = "Collector",
		Name = "Collector",
		Description = "Collect 100 objects",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "ObjectsCollected", Value = 100},
		Reward = {Type = "Currency", Value = 100},
		Tier = "Bronze"
	},
	Hoarder = {
		Id = "Hoarder",
		Name = "Hoarder",
		Description = "Collect 1,000 objects",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "ObjectsCollected", Value = 1000},
		Reward = {Type = "Currency", Value = 500},
		Tier = "Silver"
	},
	Treasure_Hunter = {
		Id = "Treasure_Hunter",
		Name = "Treasure Hunter",
		Description = "Collect 10,000 objects",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "ObjectsCollected", Value = 10000},
		Reward = {Type = "Currency", Value = 2500},
		Tier = "Gold"
	},
	Legend = {
		Id = "Legend",
		Name = "Legend",
		Description = "Collect 100,000 objects",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "ObjectsCollected", Value = 100000},
		Reward = {Type = "Currency", Value = 10000},
		Tier = "Platinum"
	},

	-- Currency achievements
	Penny_Pincher = {
		Id = "Penny_Pincher",
		Name = "Penny Pincher",
		Description = "Earn 100 currency",
		Icon = "rbxassetid://7072706620",
		Requirement = {Type = "TotalEarned", Value = 100},
		Reward = {Type = "Currency", Value = 25},
		Tier = "Bronze"
	},
	Money_Maker = {
		Id = "Money_Maker",
		Name = "Money Maker",
		Description = "Earn 10,000 currency",
		Icon = "rbxassetid://7072706620",
		Requirement = {Type = "TotalEarned", Value = 10000},
		Reward = {Type = "Currency", Value = 1000},
		Tier = "Silver"
	},
	Millionaire = {
		Id = "Millionaire",
		Name = "Millionaire",
		Description = "Earn 1,000,000 currency",
		Icon = "rbxassetid://7072706620",
		Requirement = {Type = "TotalEarned", Value = 1000000},
		Reward = {Type = "Currency", Value = 50000},
		Tier = "Gold"
	},

	-- Combo achievements
	Combo_Starter = {
		Id = "Combo_Starter",
		Name = "Combo Starter",
		Description = "Reach a 5x combo",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "MaxCombo", Value = 5},
		Reward = {Type = "Currency", Value = 50},
		Tier = "Bronze"
	},
	Combo_Master = {
		Id = "Combo_Master",
		Name = "Combo Master",
		Description = "Reach a 25x combo",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "MaxCombo", Value = 25},
		Reward = {Type = "Currency", Value = 500},
		Tier = "Silver"
	},
	Combo_Legend = {
		Id = "Combo_Legend",
		Name = "Combo Legend",
		Description = "Reach a 100x combo",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "MaxCombo", Value = 100},
		Reward = {Type = "Currency", Value = 5000},
		Tier = "Gold"
	},

	-- Gate achievements
	Gate_Runner = {
		Id = "Gate_Runner",
		Name = "Gate Runner",
		Description = "Pass through 100 gates",
		Icon = "rbxassetid://7072719738",
		Requirement = {Type = "GatesPassed", Value = 100},
		Reward = {Type = "Currency", Value = 100},
		Tier = "Bronze"
	},
	Gate_Guru = {
		Id = "Gate_Guru",
		Name = "Gate Guru",
		Description = "Pass through 1,000 gates",
		Icon = "rbxassetid://7072719738",
		Requirement = {Type = "GatesPassed", Value = 1000},
		Reward = {Type = "Currency", Value = 1000},
		Tier = "Silver"
	},
	Gate_God = {
		Id = "Gate_God",
		Name = "Gate God",
		Description = "Pass through 10,000 gates",
		Icon = "rbxassetid://7072719738",
		Requirement = {Type = "GatesPassed", Value = 10000},
		Reward = {Type = "Currency", Value = 5000},
		Tier = "Gold"
	},

	-- Multiplier achievements
	Big_Multiply = {
		Id = "Big_Multiply",
		Name = "Big Multiply",
		Description = "Multiply a single object to 50+ copies",
		Icon = "rbxassetid://7072720458",
		Requirement = {Type = "SingleMultiply", Value = 50},
		Reward = {Type = "Currency", Value = 200},
		Tier = "Silver"
	},
	Mega_Multiply = {
		Id = "Mega_Multiply",
		Name = "Mega Multiply",
		Description = "Multiply a single object to 500+ copies",
		Icon = "rbxassetid://7072720458",
		Requirement = {Type = "SingleMultiply", Value = 500},
		Reward = {Type = "Currency", Value = 2000},
		Tier = "Gold"
	},

	-- Upgrade achievements
	First_Upgrade = {
		Id = "First_Upgrade",
		Name = "First Upgrade",
		Description = "Purchase your first upgrade",
		Icon = "rbxassetid://7072706620",
		Requirement = {Type = "UpgradesPurchased", Value = 1},
		Reward = {Type = "Currency", Value = 50},
		Tier = "Bronze"
	},
	Fully_Upgraded = {
		Id = "Fully_Upgraded",
		Name = "Fully Upgraded",
		Description = "Max out any upgrade",
		Icon = "rbxassetid://7072706620",
		Requirement = {Type = "MaxUpgrade", Value = 1},
		Reward = {Type = "Currency", Value = 1000},
		Tier = "Gold"
	},

	-- Time-based achievements
	Dedicated = {
		Id = "Dedicated",
		Name = "Dedicated",
		Description = "Play for 10 minutes",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "PlayTime", Value = 600},
		Reward = {Type = "Currency", Value = 100},
		Tier = "Bronze"
	},
	Committed = {
		Id = "Committed",
		Name = "Committed",
		Description = "Play for 1 hour",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "PlayTime", Value = 3600},
		Reward = {Type = "Currency", Value = 500},
		Tier = "Silver"
	},
	Obsessed = {
		Id = "Obsessed",
		Name = "Obsessed",
		Description = "Play for 5 hours total",
		Icon = "rbxassetid://7072718362",
		Requirement = {Type = "PlayTime", Value = 18000},
		Reward = {Type = "Currency", Value = 2500},
		Tier = "Gold"
	},

	-- Rebirth achievements
	First_Rebirth = {
		Id = "First_Rebirth",
		Name = "First Rebirth",
		Description = "Complete your first rebirth",
		Icon = "rbxassetid://7072720458",
		Requirement = {Type = "RebirthCount", Value = 1},
		Reward = {Type = "Currency", Value = 500},
		Tier = "Silver"
	},
	Rebirth_Master = {
		Id = "Rebirth_Master",
		Name = "Rebirth Master",
		Description = "Reach rebirth tier 5",
		Icon = "rbxassetid://7072720458",
		Requirement = {Type = "RebirthTier", Value = 5},
		Reward = {Type = "Currency", Value = 5000},
		Tier = "Gold"
	},
	Rebirth_Legend = {
		Id = "Rebirth_Legend",
		Name = "Rebirth Legend",
		Description = "Reach the maximum rebirth tier",
		Icon = "rbxassetid://7072720458",
		Requirement = {Type = "RebirthTier", Value = 7},
		Reward = {Type = "Currency", Value = 25000},
		Tier = "Platinum"
	},

	-- Quest achievements
	Quest_Beginner = {
		Id = "Quest_Beginner",
		Name = "Quest Beginner",
		Description = "Complete 5 quests",
		Icon = "rbxassetid://7072719738",
		Requirement = {Type = "QuestsCompleted", Value = 5},
		Reward = {Type = "Currency", Value = 100},
		Tier = "Bronze"
	},
	Quest_Expert = {
		Id = "Quest_Expert",
		Name = "Quest Expert",
		Description = "Complete 50 quests",
		Icon = "rbxassetid://7072719738",
		Requirement = {Type = "QuestsCompleted", Value = 50},
		Reward = {Type = "Currency", Value = 1000},
		Tier = "Silver"
	},
	Quest_Master = {
		Id = "Quest_Master",
		Name = "Quest Master",
		Description = "Complete 250 quests",
		Icon = "rbxassetid://7072719738",
		Requirement = {Type = "QuestsCompleted", Value = 250},
		Reward = {Type = "Currency", Value = 5000},
		Tier = "Gold"
	},

	-- Pet achievements
	First_Pet = {
		Id = "First_Pet",
		Name = "First Pet",
		Description = "Hatch your first pet",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "PetsHatched", Value = 1},
		Reward = {Type = "Currency", Value = 50},
		Tier = "Bronze"
	},
	Pet_Collector = {
		Id = "Pet_Collector",
		Name = "Pet Collector",
		Description = "Hatch 25 pets",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "PetsHatched", Value = 25},
		Reward = {Type = "Currency", Value = 500},
		Tier = "Silver"
	},
	Pet_Hoarder = {
		Id = "Pet_Hoarder",
		Name = "Pet Hoarder",
		Description = "Hatch 100 pets",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "PetsHatched", Value = 100},
		Reward = {Type = "Currency", Value = 2500},
		Tier = "Gold"
	},
	Rare_Finder = {
		Id = "Rare_Finder",
		Name = "Rare Finder",
		Description = "Hatch a Legendary or Mythic pet",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "RarePetsHatched", Value = 1},
		Reward = {Type = "Currency", Value = 1000},
		Tier = "Gold"
	},
	Mythic_Hunter = {
		Id = "Mythic_Hunter",
		Name = "Mythic Hunter",
		Description = "Hatch 5 Legendary or Mythic pets",
		Icon = "rbxassetid://7072725342",
		Requirement = {Type = "RarePetsHatched", Value = 5},
		Reward = {Type = "Currency", Value = 10000},
		Tier = "Platinum"
	}
}

-- Tier colors for UI
AchievementService.TierColors = {
	Bronze = Color3.fromRGB(205, 127, 50),
	Silver = Color3.fromRGB(192, 192, 192),
	Gold = Color3.fromRGB(255, 215, 0),
	Platinum = Color3.fromRGB(229, 228, 226)
}

-- Initialize player achievements
function AchievementService:InitializePlayer(player)
	self.PlayerAchievements[player.UserId] = {
		Unlocked = {},
		Progress = {},
		Stats = {
			ObjectsCollected = 0,
			TotalEarned = 0,
			MaxCombo = 0,
			GatesPassed = 0,
			SingleMultiply = 0,
			UpgradesPurchased = 0,
			MaxUpgrade = 0,
			PlayTime = 0,
			SessionStart = tick(),
			-- New stats for rebirth, quests, pets
			RebirthCount = 0,
			RebirthTier = 0,
			QuestsCompleted = 0,
			PetsHatched = 0,
			RarePetsHatched = 0
		}
	}
end

-- Load saved achievements
function AchievementService:LoadAchievements(player, savedData)
	if not self.PlayerAchievements[player.UserId] then
		self:InitializePlayer(player)
	end

	if savedData and savedData.Achievements then
		self.PlayerAchievements[player.UserId].Unlocked = savedData.Achievements.Unlocked or {}
		self.PlayerAchievements[player.UserId].Stats = savedData.Achievements.Stats or self.PlayerAchievements[player.UserId].Stats
	end
end

-- Get save data for achievements
function AchievementService:GetSaveData(player)
	local data = self.PlayerAchievements[player.UserId]
	if not data then return nil end

	-- Update play time before saving
	data.Stats.PlayTime = data.Stats.PlayTime + (tick() - data.Stats.SessionStart)
	data.Stats.SessionStart = tick()

	return {
		Unlocked = data.Unlocked,
		Stats = data.Stats
	}
end

-- Update a stat and check for achievements
function AchievementService:UpdateStat(player, statName, value, isMax)
	local data = self.PlayerAchievements[player.UserId]
	if not data then return end

	-- Update the stat
	if isMax then
		data.Stats[statName] = math.max(data.Stats[statName] or 0, value)
	else
		data.Stats[statName] = (data.Stats[statName] or 0) + value
	end

	-- Check for any achievements unlocked
	self:CheckAchievements(player)
end

-- Check all achievements for a player
function AchievementService:CheckAchievements(player)
	local data = self.PlayerAchievements[player.UserId]
	if not data then return end

	for achievementId, achievement in pairs(self.Achievements) do
		-- Skip if already unlocked
		if data.Unlocked[achievementId] then
			continue
		end

		-- Check requirement
		local requirement = achievement.Requirement
		local currentValue = data.Stats[requirement.Type] or 0

		if currentValue >= requirement.Value then
			-- Unlock achievement!
			self:UnlockAchievement(player, achievementId)
		end
	end
end

-- Unlock an achievement
function AchievementService:UnlockAchievement(player, achievementId)
	local data = self.PlayerAchievements[player.UserId]
	if not data then return end

	local achievement = self.Achievements[achievementId]
	if not achievement then return end

	-- Mark as unlocked
	data.Unlocked[achievementId] = {
		UnlockedAt = os.time(),
		UnlockedAtFormatted = os.date("%Y-%m-%d %H:%M:%S")
	}

	-- Give reward
	if achievement.Reward then
		self:GiveReward(player, achievement.Reward)
	end

	-- Notify player
	local achievementUnlocked = ReplicatedStorage:FindFirstChild("AchievementUnlocked")
	if achievementUnlocked then
		achievementUnlocked:FireClient(player, {
			Id = achievementId,
			Name = achievement.Name,
			Description = achievement.Description,
			Icon = achievement.Icon,
			Tier = achievement.Tier,
			Reward = achievement.Reward
		})
	end

	-- Play achievement sound
	if self.SoundService then
		self.SoundService:PlayAchievementSound()
	end

	print(string.format("[Achievement] %s unlocked '%s'!", player.Name, achievement.Name))
end

-- Give achievement reward
function AchievementService:GiveReward(player, reward)
	if reward.Type == "Currency" then
		-- Try to find CurrencyService
		local success, err = pcall(function()
			local CurrencyService = require(script.Parent:WaitForChild("CurrencyService"))
			CurrencyService:AddCurrency(player, reward.Value)
		end)

		if not success then
			warn("Failed to give currency reward:", err)
		end
	end
end

-- Get all achievements for display
function AchievementService:GetAllAchievements(player)
	local data = self.PlayerAchievements[player.UserId]
	if not data then return {} end

	local achievements = {}

	for achievementId, achievement in pairs(self.Achievements) do
		local isUnlocked = data.Unlocked[achievementId] ~= nil
		local currentValue = data.Stats[achievement.Requirement.Type] or 0
		local requiredValue = achievement.Requirement.Value
		local progress = math.min(currentValue / requiredValue, 1)

		table.insert(achievements, {
			Id = achievementId,
			Name = achievement.Name,
			Description = achievement.Description,
			Icon = achievement.Icon,
			Tier = achievement.Tier,
			TierColor = self.TierColors[achievement.Tier],
			Reward = achievement.Reward,
			IsUnlocked = isUnlocked,
			Progress = progress,
			CurrentValue = currentValue,
			RequiredValue = requiredValue,
			UnlockedAt = isUnlocked and data.Unlocked[achievementId].UnlockedAtFormatted or nil
		})
	end

	-- Sort by tier (Platinum > Gold > Silver > Bronze), then by unlocked status
	local tierOrder = {Platinum = 4, Gold = 3, Silver = 2, Bronze = 1}
	table.sort(achievements, function(a, b)
		if a.IsUnlocked ~= b.IsUnlocked then
			return a.IsUnlocked -- Unlocked first
		end
		return tierOrder[a.Tier] > tierOrder[b.Tier]
	end)

	return achievements
end

-- Get player stats
function AchievementService:GetStats(player)
	local data = self.PlayerAchievements[player.UserId]
	if not data then return {} end

	-- Update play time
	local currentPlayTime = data.Stats.PlayTime + (tick() - data.Stats.SessionStart)

	return {
		ObjectsCollected = data.Stats.ObjectsCollected,
		TotalEarned = data.Stats.TotalEarned,
		MaxCombo = data.Stats.MaxCombo,
		GatesPassed = data.Stats.GatesPassed,
		UpgradesPurchased = data.Stats.UpgradesPurchased,
		PlayTime = currentPlayTime,
		AchievementsUnlocked = 0
	}
end

-- Count unlocked achievements
function AchievementService:GetUnlockedCount(player)
	local data = self.PlayerAchievements[player.UserId]
	if not data then return 0, 0 end

	local unlocked = 0
	local total = 0

	for _ in pairs(self.Achievements) do
		total = total + 1
	end

	for _ in pairs(data.Unlocked) do
		unlocked = unlocked + 1
	end

	return unlocked, total
end

-- Cleanup player data
function AchievementService:CleanupPlayer(player)
	self.PlayerAchievements[player.UserId] = nil
end

return AchievementService
