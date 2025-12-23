-- QuestService.lua
-- Handles daily quests and challenges

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestService = {}

-- Quest definitions
QuestService.QuestPool = {
	-- Collection quests
	{
		Id = "collect_objects",
		Name = "Object Collector",
		Description = "Collect %d objects",
		Type = "ObjectsCollected",
		BaseTarget = 50,
		ScalePerTier = 25,
		BaseReward = 100,
		RewardScalePerTier = 50,
		Icon = "C"
	},
	{
		Id = "collect_goblins",
		Name = "Goblin Hunter",
		Description = "Collect %d Goblins",
		Type = "GoblinsCollected",
		BaseTarget = 20,
		ScalePerTier = 10,
		BaseReward = 75,
		RewardScalePerTier = 25,
		Icon = "G"
	},
	{
		Id = "collect_treasures",
		Name = "Treasure Seeker",
		Description = "Collect %d Treasures",
		Type = "TreasuresCollected",
		BaseTarget = 10,
		ScalePerTier = 5,
		BaseReward = 150,
		RewardScalePerTier = 75,
		Icon = "T"
	},
	{
		Id = "collect_diamonds",
		Name = "Diamond Miner",
		Description = "Collect %d Diamonds",
		Type = "DiamondsCollected",
		BaseTarget = 5,
		ScalePerTier = 3,
		BaseReward = 200,
		RewardScalePerTier = 100,
		Icon = "D"
	},

	-- Currency quests
	{
		Id = "earn_currency",
		Name = "Money Maker",
		Description = "Earn %d currency",
		Type = "CurrencyEarned",
		BaseTarget = 500,
		ScalePerTier = 250,
		BaseReward = 150,
		RewardScalePerTier = 75,
		Icon = "$"
	},
	{
		Id = "earn_big",
		Name = "Big Spender",
		Description = "Earn %d currency in one run",
		Type = "SingleRunCurrency",
		BaseTarget = 1000,
		ScalePerTier = 500,
		BaseReward = 300,
		RewardScalePerTier = 150,
		Icon = "$"
	},

	-- Gate quests
	{
		Id = "use_multiply_gates",
		Name = "Multiplier Master",
		Description = "Pass through %d multiply gates",
		Type = "MultiplyGatesPassed",
		BaseTarget = 10,
		ScalePerTier = 5,
		BaseReward = 100,
		RewardScalePerTier = 50,
		Icon = "x"
	},
	{
		Id = "use_add_gates",
		Name = "Addition Expert",
		Description = "Pass through %d add gates",
		Type = "AddGatesPassed",
		BaseTarget = 8,
		ScalePerTier = 4,
		BaseReward = 100,
		RewardScalePerTier = 50,
		Icon = "+"
	},
	{
		Id = "use_special_gates",
		Name = "Risk Taker",
		Description = "Pass through %d special gates",
		Type = "SpecialGatesPassed",
		BaseTarget = 5,
		ScalePerTier = 2,
		BaseReward = 200,
		RewardScalePerTier = 100,
		Icon = "?"
	},

	-- Combo quests
	{
		Id = "reach_combo",
		Name = "Combo Champion",
		Description = "Reach a %dx combo",
		Type = "MaxComboReached",
		BaseTarget = 5,
		ScalePerTier = 2,
		BaseReward = 250,
		RewardScalePerTier = 125,
		Icon = "!"
	},
	{
		Id = "maintain_combo",
		Name = "Combo Keeper",
		Description = "Maintain a combo for %d seconds",
		Type = "ComboMaintained",
		BaseTarget = 10,
		ScalePerTier = 5,
		BaseReward = 175,
		RewardScalePerTier = 75,
		Icon = "!"
	},

	-- Boss quests
	{
		Id = "defeat_bosses",
		Name = "Boss Slayer",
		Description = "Collect %d boss objects",
		Type = "BossesDefeated",
		BaseTarget = 1,
		ScalePerTier = 1,
		BaseReward = 500,
		RewardScalePerTier = 250,
		Icon = "B"
	},

	-- Time quests
	{
		Id = "play_time",
		Name = "Dedicated Player",
		Description = "Play for %d minutes",
		Type = "PlayTime",
		BaseTarget = 15,
		ScalePerTier = 5,
		BaseReward = 100,
		RewardScalePerTier = 50,
		Icon = "T"
	}
}

-- Player quest data
QuestService.PlayerQuests = {}

-- Service references
QuestService.CurrencyService = nil
QuestService.AchievementService = nil
QuestService.SoundService = nil
QuestService.RebirthService = nil

-- Constants
QuestService.QUESTS_PER_DAY = 3
QuestService.REFRESH_HOUR = 0 -- Midnight UTC

-- Initialize player
function QuestService:InitializePlayer(player)
	self.PlayerQuests[player.UserId] = {
		ActiveQuests = {},
		CompletedToday = {},
		LastRefresh = 0,
		TotalQuestsCompleted = 0,
		DailyStreak = 0,
		LastPlayDate = ""
	}

	-- Generate initial quests
	self:RefreshQuestsIfNeeded(player)
end

-- Get current day string
function QuestService:GetDayString()
	return os.date("!%Y-%m-%d")
end

-- Check if quests need refresh
function QuestService:NeedsRefresh(player)
	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then return true end

	local currentDay = self:GetDayString()
	local lastDay = os.date("!%Y-%m-%d", playerData.LastRefresh)

	return currentDay ~= lastDay
end

-- Refresh quests if new day
function QuestService:RefreshQuestsIfNeeded(player)
	if not self:NeedsRefresh(player) then return false end

	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then return false end

	-- Check streak
	local currentDay = self:GetDayString()
	local lastPlayDate = playerData.LastPlayDate

	if lastPlayDate ~= "" then
		-- Calculate if yesterday was played
		local yesterday = os.date("!%Y-%m-%d", os.time() - 86400)
		if lastPlayDate == yesterday then
			playerData.DailyStreak = playerData.DailyStreak + 1
		else
			playerData.DailyStreak = 1
		end
	else
		playerData.DailyStreak = 1
	end

	playerData.LastPlayDate = currentDay
	playerData.LastRefresh = os.time()
	playerData.CompletedToday = {}

	-- Generate new quests
	self:GenerateQuests(player)

	print(string.format("[QuestService] Refreshed quests for %s (Day %d streak)",
		player.Name, playerData.DailyStreak))

	return true
end

-- Generate daily quests
function QuestService:GenerateQuests(player)
	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then return end

	-- Get player tier for scaling
	local tier = 1
	if self.RebirthService then
		local rebirthData = self.RebirthService:GetPlayerData(player)
		if rebirthData then
			tier = rebirthData.CurrentTier + 1
		end
	end

	-- Clear old quests
	playerData.ActiveQuests = {}

	-- Pick random quests
	local availableQuests = {}
	for i, quest in ipairs(self.QuestPool) do
		table.insert(availableQuests, i)
	end

	-- Shuffle
	for i = #availableQuests, 2, -1 do
		local j = math.random(i)
		availableQuests[i], availableQuests[j] = availableQuests[j], availableQuests[i]
	end

	-- Select quests
	for i = 1, math.min(self.QUESTS_PER_DAY, #availableQuests) do
		local questIndex = availableQuests[i]
		local questTemplate = self.QuestPool[questIndex]

		-- Calculate scaled values
		local target = questTemplate.BaseTarget + (questTemplate.ScalePerTier * (tier - 1))
		local reward = questTemplate.BaseReward + (questTemplate.RewardScalePerTier * (tier - 1))

		-- Apply streak bonus
		local streakMultiplier = 1 + (math.min(playerData.DailyStreak, 7) * 0.1)
		reward = math.floor(reward * streakMultiplier)

		local quest = {
			Id = questTemplate.Id .. "_" .. os.time() .. "_" .. i,
			TemplateId = questTemplate.Id,
			Name = questTemplate.Name,
			Description = string.format(questTemplate.Description, target),
			Type = questTemplate.Type,
			Target = target,
			Progress = 0,
			Reward = reward,
			Icon = questTemplate.Icon,
			Completed = false,
			Claimed = false
		}

		table.insert(playerData.ActiveQuests, quest)
	end
end

-- Update quest progress
function QuestService:UpdateProgress(player, questType, amount, setAbsolute)
	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then return end

	for _, quest in ipairs(playerData.ActiveQuests) do
		if quest.Type == questType and not quest.Completed then
			if setAbsolute then
				quest.Progress = amount
			else
				quest.Progress = quest.Progress + amount
			end

			-- Check completion
			if quest.Progress >= quest.Target then
				quest.Progress = quest.Target
				quest.Completed = true
				self:OnQuestCompleted(player, quest)
			end

			-- Notify client
			self:NotifyQuestUpdate(player, quest)
		end
	end
end

-- Handle quest completion
function QuestService:OnQuestCompleted(player, quest)
	print(string.format("[QuestService] %s completed quest: %s", player.Name, quest.Name))

	-- Play sound
	if self.SoundService then
		self.SoundService:PlaySound("QuestComplete", player)
	end

	-- Notify client
	local questRemote = ReplicatedStorage:FindFirstChild("QuestCompleted")
	if not questRemote then
		questRemote = Instance.new("RemoteEvent")
		questRemote.Name = "QuestCompleted"
		questRemote.Parent = ReplicatedStorage
	end

	questRemote:FireClient(player, {
		QuestId = quest.Id,
		QuestName = quest.Name,
		Reward = quest.Reward
	})
end

-- Claim quest reward
function QuestService:ClaimReward(player, questId)
	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then return false, "No data found" end

	for i, quest in ipairs(playerData.ActiveQuests) do
		if quest.Id == questId then
			if not quest.Completed then
				return false, "Quest not completed"
			end

			if quest.Claimed then
				return false, "Already claimed"
			end

			-- Mark as claimed
			quest.Claimed = true
			table.insert(playerData.CompletedToday, quest.TemplateId)
			playerData.TotalQuestsCompleted = playerData.TotalQuestsCompleted + 1

			-- Give reward
			if self.CurrencyService then
				self.CurrencyService:AddCurrency(player, quest.Reward, "Quest: " .. quest.Name)
			end

			-- Achievement tracking
			if self.AchievementService then
				self.AchievementService:UpdateStat(player, "QuestsCompleted", playerData.TotalQuestsCompleted, true)
			end

			-- Play sound
			if self.SoundService then
				self.SoundService:PlaySound("QuestClaim", player)
			end

			print(string.format("[QuestService] %s claimed %d for quest: %s",
				player.Name, quest.Reward, quest.Name))

			return true, quest.Reward
		end
	end

	return false, "Quest not found"
end

-- Notify client of quest update
function QuestService:NotifyQuestUpdate(player, quest)
	local questRemote = ReplicatedStorage:FindFirstChild("QuestUpdate")
	if not questRemote then
		questRemote = Instance.new("RemoteEvent")
		questRemote.Name = "QuestUpdate"
		questRemote.Parent = ReplicatedStorage
	end

	questRemote:FireClient(player, {
		QuestId = quest.Id,
		Progress = quest.Progress,
		Target = quest.Target,
		Completed = quest.Completed
	})
end

-- Get all quests for player
function QuestService:GetQuests(player)
	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then return {} end

	-- Check for refresh
	self:RefreshQuestsIfNeeded(player)

	return {
		ActiveQuests = playerData.ActiveQuests,
		DailyStreak = playerData.DailyStreak,
		TotalCompleted = playerData.TotalQuestsCompleted,
		RefreshTime = self:GetTimeUntilRefresh()
	}
end

-- Get time until next refresh
function QuestService:GetTimeUntilRefresh()
	local now = os.time()
	local tomorrow = os.time({
		year = os.date("!*t").year,
		month = os.date("!*t").month,
		day = os.date("!*t").day + 1,
		hour = 0,
		min = 0,
		sec = 0
	})

	return tomorrow - now
end

-- Load saved data
function QuestService:LoadData(player, savedData)
	if not savedData then return end

	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then
		self:InitializePlayer(player)
		playerData = self.PlayerQuests[player.UserId]
	end

	playerData.TotalQuestsCompleted = savedData.TotalQuestsCompleted or 0
	playerData.DailyStreak = savedData.DailyStreak or 0
	playerData.LastPlayDate = savedData.LastPlayDate or ""
	playerData.LastRefresh = savedData.LastRefresh or 0

	-- Load active quests if same day
	if savedData.ActiveQuests and not self:NeedsRefresh(player) then
		playerData.ActiveQuests = savedData.ActiveQuests
		playerData.CompletedToday = savedData.CompletedToday or {}
	else
		self:RefreshQuestsIfNeeded(player)
	end
end

-- Get save data
function QuestService:GetSaveData(player)
	local playerData = self.PlayerQuests[player.UserId]
	if not playerData then return nil end

	return {
		ActiveQuests = playerData.ActiveQuests,
		CompletedToday = playerData.CompletedToday,
		TotalQuestsCompleted = playerData.TotalQuestsCompleted,
		DailyStreak = playerData.DailyStreak,
		LastPlayDate = playerData.LastPlayDate,
		LastRefresh = playerData.LastRefresh
	}
end

-- Cleanup
function QuestService:CleanupPlayer(player)
	self.PlayerQuests[player.UserId] = nil
end

-- Track specific quest types from other services
function QuestService:TrackObjectCollected(player, objectType)
	self:UpdateProgress(player, "ObjectsCollected", 1)

	-- Track specific types
	if objectType == "Goblin" then
		self:UpdateProgress(player, "GoblinsCollected", 1)
	elseif objectType == "Treasure" then
		self:UpdateProgress(player, "TreasuresCollected", 1)
	elseif objectType == "Diamond" then
		self:UpdateProgress(player, "DiamondsCollected", 1)
	end

	-- Boss tracking
	if objectType == "Boss" or string.find(objectType, "Boss") then
		self:UpdateProgress(player, "BossesDefeated", 1)
	end
end

function QuestService:TrackCurrencyEarned(player, amount)
	self:UpdateProgress(player, "CurrencyEarned", amount)
end

function QuestService:TrackGatePassed(player, gateType)
	if gateType == "Multiply" then
		self:UpdateProgress(player, "MultiplyGatesPassed", 1)
	elseif gateType == "Add" then
		self:UpdateProgress(player, "AddGatesPassed", 1)
	elseif gateType == "Subtract" or gateType == "Divide" or gateType == "Random" or gateType == "Power" then
		self:UpdateProgress(player, "SpecialGatesPassed", 1)
	end
end

function QuestService:TrackCombo(player, comboValue, duration)
	self:UpdateProgress(player, "MaxComboReached", comboValue, true)
	if duration then
		self:UpdateProgress(player, "ComboMaintained", duration, true)
	end
end

function QuestService:TrackPlayTime(player, minutes)
	self:UpdateProgress(player, "PlayTime", minutes, true)
end

return QuestService
