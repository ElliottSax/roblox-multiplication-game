-- CurrencyService.lua
-- Manages player currency and collection of objects

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local CurrencyService = {}
CurrencyService.PlayerData = {}
CurrencyService.AchievementService = nil -- Set by init.server.lua
CurrencyService.SoundService = nil -- Set by init.server.lua

-- Initialize player data when they join
function CurrencyService:InitializePlayer(player)
	if not player or not player.UserId then
		warn("Invalid player passed to InitializePlayer")
		return
	end

	if not self.PlayerData[player.UserId] then
		self.PlayerData[player.UserId] = {
			Currency = Config.Currency.StartingAmount,
			ObjectsCollected = 0,
			TotalValue = 0
		}
	end

	-- Create leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local currency = Instance.new("IntValue")
	currency.Name = "Currency"
	currency.Value = self.PlayerData[player.UserId].Currency
	currency.Parent = leaderstats

	local collected = Instance.new("IntValue")
	collected.Name = "Collected"
	collected.Value = self.PlayerData[player.UserId].ObjectsCollected
	collected.Parent = leaderstats

	print(string.format("Initialized player %s with %d currency", player.Name, currency.Value))
end

-- Add currency to a player
function CurrencyService:AddCurrency(player, amount)
	if not player or not player.UserId then
		warn("Invalid player passed to AddCurrency")
		return
	end

	local data = self.PlayerData[player.UserId]
	if not data then
		warn("Player data not found for AddCurrency")
		return
	end

	-- Validate amount
	amount = tonumber(amount) or 0
	if amount < 0 then
		warn("Negative currency amount blocked:", amount)
		return
	end

	data.Currency += amount
	data.TotalValue += amount

	-- Update leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local currency = leaderstats:FindFirstChild("Currency")
		if currency then
			currency.Value = data.Currency
		end
	end

	print(string.format("Added %d currency to %s (total: %d)", amount, player.Name, data.Currency))
end

-- Collect an object and convert it to currency
function CurrencyService:CollectObject(player, object)
	local objectValue = object:FindFirstChild("ObjectValue")
	if not objectValue then return end

	local data = self.PlayerData[player.UserId]
	if not data then return end

	-- Calculate currency with bonus
	local currencyGained = math.floor(objectValue.Value * Config.Currency.CollectionBonus)

	-- Update stats
	data.ObjectsCollected += 1
	self:AddCurrency(player, currencyGained)

	-- Update collected count in leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local collected = leaderstats:FindFirstChild("Collected")
		if collected then
			collected.Value = data.ObjectsCollected
		end
	end

	-- Update achievement stats
	if self.AchievementService then
		self.AchievementService:UpdateStat(player, "ObjectsCollected", 1, false)
		self.AchievementService:UpdateStat(player, "TotalEarned", currencyGained, false)
	end

	-- Visual and audio feedback
	self:PlayCollectionEffect(object)
	if self.SoundService then
		self.SoundService:PlayCollectionSound(object.Position, currencyGained >= 5)
	end

	-- Remove the object
	object:Destroy()

	return currencyGained
end

-- Visual effect when object is collected
function CurrencyService:PlayCollectionEffect(object)
	-- Create a particle burst
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(object.Color)
	particles.Size = NumberSequence.new(1)
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Rate = 100
	particles.Speed = NumberRange.new(5, 10)
	particles.Parent = object

	particles:Emit(20)

	task.delay(1, function()
		if particles and particles.Parent then
			particles:Destroy()
		end
	end)
end

-- Get player currency
function CurrencyService:GetCurrency(player)
	local data = self.PlayerData[player.UserId]
	return data and data.Currency or 0
end

-- Spend currency (returns true if successful)
function CurrencyService:SpendCurrency(player, amount)
	local data = self.PlayerData[player.UserId]
	if not data then return false end

	if data.Currency >= amount then
		data.Currency -= amount

		-- Update leaderstats
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local currency = leaderstats:FindFirstChild("Currency")
			if currency then
				currency.Value = data.Currency
			end
		end

		return true
	end

	return false
end

-- Clean up player data when they leave
function CurrencyService:CleanupPlayer(player)
	-- In a real game, you'd save this to DataStore here
	self.PlayerData[player.UserId] = nil
	print(string.format("Cleaned up data for player %s", player.Name))
end

return CurrencyService
