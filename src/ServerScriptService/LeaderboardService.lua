-- LeaderboardService.lua
-- Global leaderboards using OrderedDataStore

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LeaderboardService = {}

-- Leaderboard stores
LeaderboardService.Leaderboards = {
	AllTimeCurrency = {
		Store = nil,
		Name = "AllTimeCurrency_v1",
		DisplayName = "All-Time Earnings",
		StatKey = "TotalEarned",
		Icon = "rbxassetid://7072706620"
	},
	AllTimeCollected = {
		Store = nil,
		Name = "AllTimeCollected_v1",
		DisplayName = "Total Objects Collected",
		StatKey = "ObjectsCollected",
		Icon = "rbxassetid://7072718362"
	},
	HighestCombo = {
		Store = nil,
		Name = "HighestCombo_v1",
		DisplayName = "Best Combo",
		StatKey = "MaxCombo",
		Icon = "rbxassetid://7072725342"
	},
	CurrentCurrency = {
		Store = nil,
		Name = "CurrentCurrency_v1",
		DisplayName = "Richest Players",
		StatKey = "Currency",
		Icon = "rbxassetid://7072706620"
	}
}

-- Cache for leaderboard data
LeaderboardService.Cache = {}
LeaderboardService.CacheExpiry = {}
LeaderboardService.CacheDuration = 60 -- 60 seconds cache

-- Initialize leaderboard stores
function LeaderboardService:Initialize()
	for leaderboardId, config in pairs(self.Leaderboards) do
		local success, store = pcall(function()
			return DataStoreService:GetOrderedDataStore(config.Name)
		end)

		if success then
			config.Store = store
			print("[LeaderboardService] Initialized store:", config.Name)
		else
			warn("[LeaderboardService] Failed to initialize store:", config.Name, store)
		end
	end
end

-- Update a player's score on a leaderboard
function LeaderboardService:UpdateScore(player, leaderboardId, score)
	local config = self.Leaderboards[leaderboardId]
	if not config or not config.Store then return false end

	local key = "user_" .. tostring(player.UserId)

	local success, err = pcall(function()
		config.Store:SetAsync(key, math.floor(score))
	end)

	if success then
		-- Invalidate cache
		self.CacheExpiry[leaderboardId] = 0
		return true
	else
		warn("[LeaderboardService] Failed to update score:", err)
		return false
	end
end

-- Update all leaderboards for a player
function LeaderboardService:UpdateAllLeaderboards(player, stats)
	for leaderboardId, config in pairs(self.Leaderboards) do
		local score = stats[config.StatKey]
		if score and score > 0 then
			self:UpdateScore(player, leaderboardId, score)
		end
	end
end

-- Get leaderboard entries
function LeaderboardService:GetLeaderboard(leaderboardId, count)
	count = count or 100

	local config = self.Leaderboards[leaderboardId]
	if not config or not config.Store then
		return {}
	end

	-- Check cache
	local currentTime = tick()
	if self.Cache[leaderboardId] and self.CacheExpiry[leaderboardId] and currentTime < self.CacheExpiry[leaderboardId] then
		return self.Cache[leaderboardId]
	end

	-- Fetch from DataStore
	local entries = {}

	local success, pages = pcall(function()
		return config.Store:GetSortedAsync(false, count)
	end)

	if not success then
		warn("[LeaderboardService] Failed to get leaderboard:", pages)
		return entries
	end

	local pageData = pages:GetCurrentPage()

	for rank, entry in ipairs(pageData) do
		local userId = tonumber(string.match(entry.key, "user_(%d+)"))
		local playerName = "[Unknown]"

		-- Try to get username
		if userId then
			local nameSuccess, name = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)

			if nameSuccess then
				playerName = name
			end
		end

		table.insert(entries, {
			Rank = rank,
			UserId = userId,
			PlayerName = playerName,
			Score = entry.value
		})
	end

	-- Update cache
	self.Cache[leaderboardId] = entries
	self.CacheExpiry[leaderboardId] = currentTime + self.CacheDuration

	return entries
end

-- Get player's rank on a leaderboard
function LeaderboardService:GetPlayerRank(player, leaderboardId)
	local config = self.Leaderboards[leaderboardId]
	if not config or not config.Store then
		return nil, nil
	end

	local key = "user_" .. tostring(player.UserId)

	local score, rank

	-- Get player's score
	local success1, result1 = pcall(function()
		return config.Store:GetAsync(key)
	end)

	if success1 then
		score = result1 or 0
	end

	-- Getting rank requires iterating through leaderboard
	local entries = self:GetLeaderboard(leaderboardId, 1000)

	for i, entry in ipairs(entries) do
		if entry.UserId == player.UserId then
			rank = i
			break
		end
	end

	return rank, score
end

-- Get all leaderboard info for UI
function LeaderboardService:GetAllLeaderboardInfo()
	local info = {}

	for leaderboardId, config in pairs(self.Leaderboards) do
		table.insert(info, {
			Id = leaderboardId,
			DisplayName = config.DisplayName,
			Icon = config.Icon,
			StatKey = config.StatKey
		})
	end

	return info
end

-- Get player's rankings on all leaderboards
function LeaderboardService:GetPlayerRankings(player)
	local rankings = {}

	for leaderboardId, config in pairs(self.Leaderboards) do
		local rank, score = self:GetPlayerRank(player, leaderboardId)

		rankings[leaderboardId] = {
			Id = leaderboardId,
			DisplayName = config.DisplayName,
			Rank = rank,
			Score = score
		}
	end

	return rankings
end

-- Format large numbers
function LeaderboardService:FormatNumber(number)
	if number >= 1000000000 then
		return string.format("%.1fB", number / 1000000000)
	elseif number >= 1000000 then
		return string.format("%.1fM", number / 1000000)
	elseif number >= 1000 then
		return string.format("%.1fK", number / 1000)
	else
		return tostring(math.floor(number))
	end
end

return LeaderboardService
