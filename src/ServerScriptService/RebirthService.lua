-- RebirthService.lua
-- Handles prestige/rebirth mechanics for permanent progression

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RebirthService = {}

-- Rebirth tier configurations
RebirthService.RebirthTiers = {
	{
		Tier = 1,
		Name = "Apprentice",
		RequiredCurrency = 10000,
		Multiplier = 1.5,
		Color = Color3.fromRGB(150, 200, 150),
		Rewards = {"UnlockTreasure"}
	},
	{
		Tier = 2,
		Name = "Journeyman",
		RequiredCurrency = 50000,
		Multiplier = 2.0,
		Color = Color3.fromRGB(100, 200, 255),
		Rewards = {"UnlockDiamond", "SpeedBoost"}
	},
	{
		Tier = 3,
		Name = "Expert",
		RequiredCurrency = 250000,
		Multiplier = 3.0,
		Color = Color3.fromRGB(200, 150, 255),
		Rewards = {"UnlockRobot", "AutoCollect"}
	},
	{
		Tier = 4,
		Name = "Master",
		RequiredCurrency = 1000000,
		Multiplier = 5.0,
		Color = Color3.fromRGB(255, 200, 100),
		Rewards = {"UnlockMagicOrb", "DoubleGates"}
	},
	{
		Tier = 5,
		Name = "Grandmaster",
		RequiredCurrency = 5000000,
		Multiplier = 8.0,
		Color = Color3.fromRGB(255, 100, 150),
		Rewards = {"UnlockLegendary", "BossBonus"}
	},
	{
		Tier = 6,
		Name = "Legend",
		RequiredCurrency = 25000000,
		Multiplier = 12.0,
		Color = Color3.fromRGB(255, 215, 0),
		Rewards = {"UnlockCosmic", "TripleGates"}
	},
	{
		Tier = 7,
		Name = "Mythic",
		RequiredCurrency = 100000000,
		Multiplier = 20.0,
		Color = Color3.fromRGB(255, 50, 255),
		Rewards = {"UnlockAll", "MythicAura"}
	}
}

-- Reward definitions
RebirthService.RewardEffects = {
	UnlockTreasure = {
		Description = "Treasure objects spawn more frequently",
		Effect = function(player) end -- Handled by spawn weight modifier
	},
	UnlockDiamond = {
		Description = "Diamond objects available from start",
		Effect = function(player) end
	},
	SpeedBoost = {
		Description = "+25% movement speed",
		Effect = function(player)
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = humanoid.WalkSpeed * 1.25
				end
			end
		end
	},
	UnlockRobot = {
		Description = "Robot objects available from start",
		Effect = function(player) end
	},
	AutoCollect = {
		Description = "Objects within range auto-collect",
		Effect = function(player) end -- Handled by collection system
	},
	UnlockMagicOrb = {
		Description = "Magic Orb objects available from start",
		Effect = function(player) end
	},
	DoubleGates = {
		Description = "Chance for gates to apply twice",
		Effect = function(player) end
	},
	UnlockLegendary = {
		Description = "Legendary Gem objects available from start",
		Effect = function(player) end
	},
	BossBonus = {
		Description = "+50% currency from boss waves",
		Effect = function(player) end
	},
	UnlockCosmic = {
		Description = "Cosmic Essence objects available from start",
		Effect = function(player) end
	},
	TripleGates = {
		Description = "Rare chance for gates to apply triple",
		Effect = function(player) end
	},
	UnlockAll = {
		Description = "All object types available from start",
		Effect = function(player) end
	},
	MythicAura = {
		Description = "Mythic aura that attracts objects",
		Effect = function(player) end
	}
}

-- Player rebirth data
RebirthService.PlayerData = {}

-- Service references
RebirthService.CurrencyService = nil
RebirthService.AchievementService = nil
RebirthService.SoundService = nil

-- Initialize player data
function RebirthService:InitializePlayer(player)
	self.PlayerData[player.UserId] = {
		RebirthCount = 0,
		CurrentTier = 0,
		TotalMultiplier = 1.0,
		UnlockedRewards = {},
		LifetimeCurrency = 0,
		LastRebirthTime = 0
	}
end

-- Get player's rebirth data
function RebirthService:GetPlayerData(player)
	return self.PlayerData[player.UserId]
end

-- Load saved rebirth data
function RebirthService:LoadData(player, savedData)
	if not savedData then return end

	local playerData = self.PlayerData[player.UserId]
	if not playerData then
		self:InitializePlayer(player)
		playerData = self.PlayerData[player.UserId]
	end

	playerData.RebirthCount = savedData.RebirthCount or 0
	playerData.CurrentTier = savedData.CurrentTier or 0
	playerData.TotalMultiplier = savedData.TotalMultiplier or 1.0
	playerData.UnlockedRewards = savedData.UnlockedRewards or {}
	playerData.LifetimeCurrency = savedData.LifetimeCurrency or 0
	playerData.LastRebirthTime = savedData.LastRebirthTime or 0

	-- Apply any passive effects from unlocked rewards
	self:ApplyRewardEffects(player)
end

-- Get save data for player
function RebirthService:GetSaveData(player)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return nil end

	return {
		RebirthCount = playerData.RebirthCount,
		CurrentTier = playerData.CurrentTier,
		TotalMultiplier = playerData.TotalMultiplier,
		UnlockedRewards = playerData.UnlockedRewards,
		LifetimeCurrency = playerData.LifetimeCurrency,
		LastRebirthTime = playerData.LastRebirthTime
	}
end

-- Check if player can rebirth
function RebirthService:CanRebirth(player)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return false, "No data found" end

	-- Check cooldown (5 minutes between rebirths)
	local cooldown = 300 -- 5 minutes
	if tick() - playerData.LastRebirthTime < cooldown then
		local remaining = math.ceil(cooldown - (tick() - playerData.LastRebirthTime))
		return false, string.format("Cooldown: %d seconds remaining", remaining)
	end

	-- Get next tier
	local nextTier = playerData.CurrentTier + 1
	if nextTier > #self.RebirthTiers then
		return false, "Maximum tier reached!"
	end

	-- Check currency requirement
	local tierConfig = self.RebirthTiers[nextTier]
	local currencyData = self.CurrencyService and self.CurrencyService.PlayerData[player.UserId]
	local currentCurrency = currencyData and currencyData.TotalValue or 0

	if currentCurrency < tierConfig.RequiredCurrency then
		return false, string.format("Need %s total earned (have %s)",
			self:FormatNumber(tierConfig.RequiredCurrency),
			self:FormatNumber(currentCurrency))
	end

	return true, tierConfig
end

-- Perform rebirth
function RebirthService:Rebirth(player)
	local canRebirth, result = self:CanRebirth(player)
	if not canRebirth then
		return false, result
	end

	local tierConfig = result
	local playerData = self.PlayerData[player.UserId]

	-- Update rebirth data
	playerData.RebirthCount = playerData.RebirthCount + 1
	playerData.CurrentTier = tierConfig.Tier
	playerData.TotalMultiplier = tierConfig.Multiplier
	playerData.LastRebirthTime = tick()

	-- Track lifetime currency before reset
	local currencyData = self.CurrencyService and self.CurrencyService.PlayerData[player.UserId]
	if currencyData then
		playerData.LifetimeCurrency = playerData.LifetimeCurrency + currencyData.TotalValue
	end

	-- Unlock rewards
	for _, reward in ipairs(tierConfig.Rewards) do
		if not table.find(playerData.UnlockedRewards, reward) then
			table.insert(playerData.UnlockedRewards, reward)
		end
	end

	-- Reset player progress (but keep rebirth data)
	self:ResetPlayerProgress(player)

	-- Apply reward effects
	self:ApplyRewardEffects(player)

	-- Play rebirth sound
	if self.SoundService then
		self.SoundService:PlaySound("Rebirth", player)
	end

	-- Achievement tracking
	if self.AchievementService then
		self.AchievementService:UpdateStat(player, "RebirthCount", playerData.RebirthCount, true)
		self.AchievementService:UpdateStat(player, "RebirthTier", playerData.CurrentTier, true)
	end

	-- Announce rebirth
	self:AnnounceRebirth(player, tierConfig)

	print(string.format("[RebirthService] %s rebirthed to %s (Tier %d, %.1fx multiplier)",
		player.Name, tierConfig.Name, tierConfig.Tier, tierConfig.Multiplier))

	return true, tierConfig
end

-- Reset player progress (currency, objects, etc.)
function RebirthService:ResetPlayerProgress(player)
	-- Reset currency
	if self.CurrencyService then
		local currencyData = self.CurrencyService.PlayerData[player.UserId]
		if currencyData then
			currencyData.Currency = 0
			currencyData.ObjectsCollected = 0
			currencyData.TotalValue = 0

			-- Update leaderstats
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local currency = leaderstats:FindFirstChild("Currency")
				local collected = leaderstats:FindFirstChild("Collected")
				if currency then currency.Value = 0 end
				if collected then collected.Value = 0 end
			end
		end
	end

	-- Reset upgrades (optional - could keep some)
	-- For now, we keep upgrades as a reward for rebirthing
end

-- Apply reward effects to player
function RebirthService:ApplyRewardEffects(player)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return end

	for _, rewardName in ipairs(playerData.UnlockedRewards) do
		local reward = self.RewardEffects[rewardName]
		if reward and reward.Effect then
			pcall(function()
				reward.Effect(player)
			end)
		end
	end
end

-- Check if player has a specific reward
function RebirthService:HasReward(player, rewardName)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return false end

	return table.find(playerData.UnlockedRewards, rewardName) ~= nil
end

-- Get player's currency multiplier from rebirth
function RebirthService:GetMultiplier(player)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return 1.0 end

	return playerData.TotalMultiplier
end

-- Get unlock requirement reduction (for object unlocks)
function RebirthService:GetUnlockReduction(player)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return 1.0 end

	-- Each tier reduces unlock requirements
	local reductions = {
		[1] = 0.9,  -- 10% reduction
		[2] = 0.75, -- 25% reduction
		[3] = 0.5,  -- 50% reduction
		[4] = 0.3,  -- 70% reduction
		[5] = 0.15, -- 85% reduction
		[6] = 0.05, -- 95% reduction
		[7] = 0,    -- No requirements
	}

	return reductions[playerData.CurrentTier] or 1.0
end

-- Announce rebirth to server
function RebirthService:AnnounceRebirth(player, tierConfig)
	local rebirthRemote = ReplicatedStorage:FindFirstChild("RebirthAnnouncement")
	if not rebirthRemote then
		rebirthRemote = Instance.new("RemoteEvent")
		rebirthRemote.Name = "RebirthAnnouncement"
		rebirthRemote.Parent = ReplicatedStorage
	end

	-- Notify all players
	rebirthRemote:FireAllClients({
		PlayerName = player.Name,
		TierName = tierConfig.Name,
		Tier = tierConfig.Tier,
		Multiplier = tierConfig.Multiplier,
		Color = tierConfig.Color
	})
end

-- Get rebirth info for UI
function RebirthService:GetRebirthInfo(player)
	local playerData = self.PlayerData[player.UserId]
	if not playerData then return nil end

	local currencyData = self.CurrencyService and self.CurrencyService.PlayerData[player.UserId]
	local currentEarned = currencyData and currencyData.TotalValue or 0

	local nextTier = playerData.CurrentTier + 1
	local nextTierConfig = self.RebirthTiers[nextTier]

	local canRebirth, _ = self:CanRebirth(player)

	return {
		CurrentTier = playerData.CurrentTier,
		CurrentTierName = playerData.CurrentTier > 0 and self.RebirthTiers[playerData.CurrentTier].Name or "None",
		RebirthCount = playerData.RebirthCount,
		TotalMultiplier = playerData.TotalMultiplier,
		UnlockedRewards = playerData.UnlockedRewards,
		LifetimeCurrency = playerData.LifetimeCurrency,
		CanRebirth = canRebirth,
		NextTier = nextTierConfig and {
			Name = nextTierConfig.Name,
			Required = nextTierConfig.RequiredCurrency,
			Current = currentEarned,
			Progress = math.min(1, currentEarned / nextTierConfig.RequiredCurrency),
			Multiplier = nextTierConfig.Multiplier,
			Rewards = nextTierConfig.Rewards
		} or nil,
		AllTiers = self.RebirthTiers
	}
end

-- Format large numbers
function RebirthService:FormatNumber(num)
	if num >= 1000000000 then
		return string.format("%.1fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	end
	return tostring(math.floor(num))
end

-- Cleanup when player leaves
function RebirthService:CleanupPlayer(player)
	self.PlayerData[player.UserId] = nil
end

return RebirthService
