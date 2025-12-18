-- DataService.lua
-- Handles saving and loading player data using DataStore

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataService = {}
DataService.PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
DataService.AutoSaveInterval = 300 -- Save every 5 minutes
DataService.SessionData = {}

-- Default player data template
local function GetDefaultData()
	return {
		Currency = 0,
		ObjectsCollected = 0,
		TotalValue = 0,
		Upgrades = {},
		Stats = {
			PlayTime = 0,
			HighestMultiplier = 0,
			TotalObjectsSpawned = 0,
			LastPlayed = os.time()
		}
	}
end

-- Load player data
function DataService:LoadData(player)
	local userId = player.UserId
	local success, data

	-- Try to load data with retry logic
	for attempt = 1, 3 do
		success, data = pcall(function()
			return self.PlayerDataStore:GetAsync("Player_" .. userId)
		end)

		if success then break end
		wait(1)
	end

	if not success then
		warn(string.format("Failed to load data for %s: %s", player.Name, tostring(data)))
		data = nil
	end

	-- Use default data if load failed or no data exists
	local playerData = data or GetDefaultData()

	-- Validate data structure
	if type(playerData) ~= "table" then
		warn("Invalid data type loaded, using defaults")
		playerData = GetDefaultData()
	end

	-- Ensure all fields exist (in case new fields were added)
	local defaultData = GetDefaultData()
	for key, value in pairs(defaultData) do
		if playerData[key] == nil then
			playerData[key] = value
		end
	end

	-- Validate data types
	if type(playerData.Currency) ~= "number" then playerData.Currency = 0 end
	if type(playerData.ObjectsCollected) ~= "number" then playerData.ObjectsCollected = 0 end
	if type(playerData.TotalValue) ~= "number" then playerData.TotalValue = 0 end
	if type(playerData.Upgrades) ~= "table" then playerData.Upgrades = {} end
	if type(playerData.Stats) ~= "table" then playerData.Stats = defaultData.Stats end

	-- Store in session
	self.SessionData[userId] = playerData

	print(string.format("Loaded data for %s: %d currency, %d objects collected",
		player.Name, playerData.Currency, playerData.ObjectsCollected))

	return playerData
end

-- Save player data
function DataService:SaveData(player)
	local userId = player.UserId
	local data = self.SessionData[userId]

	if not data then
		warn("No session data found for " .. player.Name)
		return false
	end

	-- Update last played time
	data.Stats.LastPlayed = os.time()

	-- Try to save data with retry logic
	local success, error
	for attempt = 1, 3 do
		success, error = pcall(function()
			self.PlayerDataStore:SetAsync("Player_" .. userId, data)
		end)

		if success then
			print(string.format("Saved data for %s", player.Name))
			return true
		end

		warn(string.format("Save attempt %d failed for %s: %s", attempt, player.Name, tostring(error)))
		wait(1)
	end

	warn(string.format("Failed to save data for %s after 3 attempts", player.Name))
	return false
end

-- Update session data
function DataService:UpdateData(player, key, value)
	local userId = player.UserId
	if not self.SessionData[userId] then return end

	self.SessionData[userId][key] = value
end

-- Get session data
function DataService:GetData(player)
	return self.SessionData[player.UserId]
end

-- Increment a stat
function DataService:IncrementStat(player, statName, amount)
	local userId = player.UserId
	if not self.SessionData[userId] then return end

	if not self.SessionData[userId].Stats[statName] then
		self.SessionData[userId].Stats[statName] = 0
	end

	self.SessionData[userId].Stats[statName] += amount
end

-- Auto-save system
function DataService:StartAutoSave()
	task.spawn(function()
		while true do
			wait(self.AutoSaveInterval)

			print("Auto-saving all player data...")
			local saveCount = 0

			for _, player in ipairs(Players:GetPlayers()) do
				if self:SaveData(player) then
					saveCount += 1
				end
			end

			print(string.format("Auto-saved %d/%d players", saveCount, #Players:GetPlayers()))
		end
	end)
end

-- Handle player leaving (save their data)
function DataService:PlayerLeaving(player)
	print(string.format("Saving data for leaving player: %s", player.Name))
	self:SaveData(player)
	self.SessionData[player.UserId] = nil
end

-- Backup data (called on server shutdown)
function DataService:BackupAllData()
	print("Backing up all player data...")

	for _, player in ipairs(Players:GetPlayers()) do
		self:SaveData(player)
	end

	print("Backup complete")
end

-- Wipe player data (admin command)
function DataService:WipeData(player)
	local userId = player.UserId

	local success, error = pcall(function()
		self.PlayerDataStore:RemoveAsync("Player_" .. userId)
	end)

	if success then
		-- Reset session data
		self.SessionData[userId] = GetDefaultData()
		print(string.format("Wiped data for %s", player.Name))
		return true
	else
		warn(string.format("Failed to wipe data for %s: %s", player.Name, tostring(error)))
		return false
	end
end

-- Get leaderboard data
function DataService:GetLeaderboard(statName, limit)
	limit = limit or 10

	-- This is a simplified version - in production you'd use OrderedDataStore
	local leaderboard = {}

	for userId, data in pairs(self.SessionData) do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			table.insert(leaderboard, {
				Name = player.Name,
				Value = data[statName] or 0
			})
		end
	end

	-- Sort by value
	table.sort(leaderboard, function(a, b)
		return a.Value > b.Value
	end)

	-- Return top N
	local top = {}
	for i = 1, math.min(limit, #leaderboard) do
		table.insert(top, leaderboard[i])
	end

	return top
end

return DataService
