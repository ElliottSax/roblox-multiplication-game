-- ComboService.lua
-- Tracks consecutive gate hits and applies combo multipliers

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComboService = {}
ComboService.PlayerCombos = {}
ComboService.ComboTimeout = 3 -- Seconds before combo resets
ComboService.AchievementService = nil -- Set by init.server.lua
ComboService.SoundService = nil -- Set by init.server.lua

-- Combo tier thresholds and multipliers
ComboService.ComboTiers = {
	{Gates = 3, Multiplier = 1.5, Name = "Nice!"},
	{Gates = 5, Multiplier = 2.0, Name = "Great!"},
	{Gates = 10, Multiplier = 2.5, Name = "Amazing!"},
	{Gates = 15, Multiplier = 3.0, Name = "INCREDIBLE!"},
	{Gates = 25, Multiplier = 4.0, Name = "LEGENDARY!"},
}

-- Initialize player combo tracking
function ComboService:InitializePlayer(player)
	self.PlayerCombos[player.UserId] = {
		Count = 0,
		LastGateTime = 0,
		CurrentMultiplier = 1.0,
		HighestCombo = 0,
		TotalGatesHit = 0
	}
end

-- Register a gate hit
function ComboService:RegisterGateHit(player, object)
	local combo = self.PlayerCombos[player.UserId]
	if not combo then return 1.0 end

	local currentTime = tick()
	local timeSinceLastHit = currentTime - combo.LastGateTime

	-- Reset combo if too much time passed
	if timeSinceLastHit > self.ComboTimeout and combo.Count > 0 then
		print(string.format("%s combo broken! (%d gates)", player.Name, combo.Count))
		self:ResetCombo(player)
	end

	-- Increment combo
	combo.Count += 1
	combo.LastGateTime = currentTime
	combo.TotalGatesHit += 1

	-- Update highest combo
	if combo.Count > combo.HighestCombo then
		combo.HighestCombo = combo.Count
	end

	-- Update achievement stats
	if self.AchievementService then
		self.AchievementService:UpdateStat(player, "MaxCombo", combo.Count, true)
		self.AchievementService:UpdateStat(player, "GatesPassed", 1, false)
	end

	-- Calculate multiplier
	local multiplier = self:GetComboMultiplier(combo.Count)
	combo.CurrentMultiplier = multiplier

	-- Check for tier achievements
	local tier = self:GetComboTier(combo.Count)
	if tier and combo.Count == tier.Gates then
		print(string.format("%s reached combo tier: %s (x%.1f)", player.Name, tier.Name, tier.Multiplier))
		self:ShowComboNotification(player, tier)

		-- Play combo sound
		if self.SoundService then
			self.SoundService:PlayComboSound(tier.Name)
		end
	end

	return multiplier
end

-- Get combo multiplier for a combo count
function ComboService:GetComboMultiplier(comboCount)
	local multiplier = 1.0

	-- Find the highest tier reached
	for _, tier in ipairs(self.ComboTiers) do
		if comboCount >= tier.Gates then
			multiplier = tier.Multiplier
		else
			break
		end
	end

	return multiplier
end

-- Get combo tier for a combo count
function ComboService:GetComboTier(comboCount)
	for i = #self.ComboTiers, 1, -1 do
		local tier = self.ComboTiers[i]
		if comboCount >= tier.Gates then
			return tier
		end
	end
	return nil
end

-- Reset player combo
function ComboService:ResetCombo(player)
	local combo = self.PlayerCombos[player.UserId]
	if not combo then return end

	combo.Count = 0
	combo.CurrentMultiplier = 1.0
end

-- Get current combo info for player
function ComboService:GetComboInfo(player)
	return self.PlayerCombos[player.UserId]
end

-- Show combo notification to player
function ComboService:ShowComboNotification(player, tier)
	-- Fire a remote event to show UI notification
	local remoteEvent = ReplicatedStorage:FindFirstChild("ComboNotification")
	if not remoteEvent then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = "ComboNotification"
		remoteEvent.Parent = ReplicatedStorage
	end

	remoteEvent:FireClient(player, {
		TierName = tier.Name,
		Multiplier = tier.Multiplier,
		ComboCount = self.PlayerCombos[player.UserId].Count
	})
end

-- Check combo timeout (run periodically)
function ComboService:CheckCombos()
	local currentTime = tick()

	for userId, combo in pairs(self.PlayerCombos) do
		if combo.Count > 0 then
			local timeSinceLastHit = currentTime - combo.LastGateTime

			if timeSinceLastHit > self.ComboTimeout then
				local player = Players:GetPlayerByUserId(userId)
				if player then
					self:ResetCombo(player)
				end
			end
		end
	end
end

-- Start combo timeout checker
function ComboService:StartComboChecker()
	task.spawn(function()
		while true do
			wait(1)
			self:CheckCombos()
		end
	end)
end

-- Cleanup player data
function ComboService:CleanupPlayer(player)
	self.PlayerCombos[player.UserId] = nil
end

return ComboService
