-- PetService.lua
-- Manages collectible pets with passive bonuses

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetService = {}

-- Pet rarity levels
PetService.Rarities = {
	Common = {
		Name = "Common",
		Color = Color3.fromRGB(150, 150, 150),
		Chance = 60,
		MultiplierRange = {1.05, 1.15}
	},
	Uncommon = {
		Name = "Uncommon",
		Color = Color3.fromRGB(100, 200, 100),
		Chance = 25,
		MultiplierRange = {1.15, 1.30}
	},
	Rare = {
		Name = "Rare",
		Color = Color3.fromRGB(100, 150, 255),
		Chance = 10,
		MultiplierRange = {1.30, 1.50}
	},
	Epic = {
		Name = "Epic",
		Color = Color3.fromRGB(200, 100, 255),
		Chance = 4,
		MultiplierRange = {1.50, 1.80}
	},
	Legendary = {
		Name = "Legendary",
		Color = Color3.fromRGB(255, 200, 50),
		Chance = 0.9,
		MultiplierRange = {1.80, 2.50}
	},
	Mythic = {
		Name = "Mythic",
		Color = Color3.fromRGB(255, 100, 150),
		Chance = 0.1,
		MultiplierRange = {2.50, 4.00}
	}
}

-- Pet definitions
PetService.PetTypes = {
	-- Common pets
	{
		Id = "goblin_buddy",
		Name = "Goblin Buddy",
		Rarity = "Common",
		BonusType = "CurrencyMultiplier",
		Description = "A friendly goblin that helps collect coins",
		Icon = "G"
	},
	{
		Id = "coin_sprite",
		Name = "Coin Sprite",
		Rarity = "Common",
		BonusType = "CurrencyMultiplier",
		Description = "A magical sprite attracted to shiny things",
		Icon = "S"
	},
	{
		Id = "treasure_bug",
		Name = "Treasure Bug",
		Rarity = "Common",
		BonusType = "ObjectValue",
		Description = "Sniffs out valuable objects",
		Icon = "B"
	},

	-- Uncommon pets
	{
		Id = "lucky_cat",
		Name = "Lucky Cat",
		Rarity = "Uncommon",
		BonusType = "LuckBoost",
		Description = "Brings good fortune to its owner",
		Icon = "C"
	},
	{
		Id = "speed_hare",
		Name = "Speed Hare",
		Rarity = "Uncommon",
		BonusType = "SpeedBoost",
		Description = "Makes objects move faster",
		Icon = "H"
	},
	{
		Id = "combo_fox",
		Name = "Combo Fox",
		Rarity = "Uncommon",
		BonusType = "ComboExtender",
		Description = "Helps maintain combos longer",
		Icon = "F"
	},

	-- Rare pets
	{
		Id = "diamond_turtle",
		Name = "Diamond Turtle",
		Rarity = "Rare",
		BonusType = "CurrencyMultiplier",
		Description = "Slow but brings great wealth",
		Icon = "T"
	},
	{
		Id = "gate_guardian",
		Name = "Gate Guardian",
		Rarity = "Rare",
		BonusType = "GateBonus",
		Description = "Increases gate multiplier effects",
		Icon = "G"
	},
	{
		Id = "magnet_moth",
		Name = "Magnet Moth",
		Rarity = "Rare",
		BonusType = "CollectionRange",
		Description = "Attracts nearby objects automatically",
		Icon = "M"
	},

	-- Epic pets
	{
		Id = "golden_phoenix",
		Name = "Golden Phoenix",
		Rarity = "Epic",
		BonusType = "CurrencyMultiplier",
		Description = "A majestic bird of pure gold",
		Icon = "P"
	},
	{
		Id = "void_serpent",
		Name = "Void Serpent",
		Rarity = "Epic",
		BonusType = "ObjectValue",
		Description = "From the depths of the void",
		Icon = "V"
	},
	{
		Id = "time_keeper",
		Name = "Time Keeper",
		Rarity = "Epic",
		BonusType = "ComboExtender",
		Description = "Slows down combo decay",
		Icon = "T"
	},

	-- Legendary pets
	{
		Id = "dragon_hoard",
		Name = "Dragon of the Hoard",
		Rarity = "Legendary",
		BonusType = "CurrencyMultiplier",
		Description = "An ancient dragon with vast treasure",
		Icon = "D"
	},
	{
		Id = "celestial_wolf",
		Name = "Celestial Wolf",
		Rarity = "Legendary",
		BonusType = "AllBonus",
		Description = "A wolf from the stars themselves",
		Icon = "W"
	},

	-- Mythic pets
	{
		Id = "cosmic_entity",
		Name = "Cosmic Entity",
		Rarity = "Mythic",
		BonusType = "AllBonus",
		Description = "A being of pure cosmic energy",
		Icon = "C"
	}
}

-- Egg types for hatching
PetService.EggTypes = {
	{
		Id = "basic_egg",
		Name = "Basic Egg",
		Cost = 1000,
		RarityBoosts = {} -- No boosts
	},
	{
		Id = "premium_egg",
		Name = "Premium Egg",
		Cost = 5000,
		RarityBoosts = {Uncommon = 1.5, Rare = 1.3}
	},
	{
		Id = "legendary_egg",
		Name = "Legendary Egg",
		Cost = 25000,
		RarityBoosts = {Rare = 2.0, Epic = 1.5, Legendary = 1.3}
	},
	{
		Id = "mythic_egg",
		Name = "Mythic Egg",
		Cost = 100000,
		RarityBoosts = {Epic = 2.0, Legendary = 2.0, Mythic = 5.0}
	}
}

-- Player data
PetService.PlayerPets = {}

-- Service references
PetService.CurrencyService = nil
PetService.AchievementService = nil
PetService.SoundService = nil

-- Constants
PetService.MAX_EQUIPPED = 3
PetService.MAX_INVENTORY = 50

-- Initialize player
function PetService:InitializePlayer(player)
	self.PlayerPets[player.UserId] = {
		Inventory = {},
		Equipped = {},
		TotalHatched = 0,
		LegendaryCount = 0,
		MythicCount = 0
	}
end

-- Hatch a pet from an egg
function PetService:HatchEgg(player, eggId)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return false, "No data found" end

	-- Find egg type
	local eggConfig = nil
	for _, egg in ipairs(self.EggTypes) do
		if egg.Id == eggId then
			eggConfig = egg
			break
		end
	end

	if not eggConfig then
		return false, "Invalid egg type"
	end

	-- Check inventory space
	if #playerData.Inventory >= self.MAX_INVENTORY then
		return false, "Pet inventory is full!"
	end

	-- Check currency
	if self.CurrencyService then
		local currencyData = self.CurrencyService.PlayerData[player.UserId]
		if not currencyData or currencyData.Currency < eggConfig.Cost then
			return false, "Not enough currency"
		end

		-- Deduct cost
		self.CurrencyService:RemoveCurrency(player, eggConfig.Cost)
	end

	-- Determine rarity
	local rarity = self:RollRarity(eggConfig.RarityBoosts)

	-- Pick random pet of that rarity
	local pet = self:RollPet(rarity)
	if not pet then
		return false, "No pet available"
	end

	-- Generate pet instance
	local petInstance = self:CreatePetInstance(pet, rarity)

	-- Add to inventory
	table.insert(playerData.Inventory, petInstance)
	playerData.TotalHatched = playerData.TotalHatched + 1

	-- Track legendary/mythic
	if rarity == "Legendary" then
		playerData.LegendaryCount = playerData.LegendaryCount + 1
	elseif rarity == "Mythic" then
		playerData.MythicCount = playerData.MythicCount + 1
	end

	-- Play sound
	if self.SoundService then
		local soundName = rarity == "Mythic" and "MythicHatch" or
			rarity == "Legendary" and "LegendaryHatch" or
			rarity == "Epic" and "EpicHatch" or "Hatch"
		self.SoundService:PlaySound(soundName, player)
	end

	-- Achievement tracking
	if self.AchievementService then
		self.AchievementService:UpdateStat(player, "PetsHatched", playerData.TotalHatched, true)
		if rarity == "Legendary" or rarity == "Mythic" then
			self.AchievementService:UpdateStat(player, "RarePetsHatched",
				playerData.LegendaryCount + playerData.MythicCount, true)
		end
	end

	print(string.format("[PetService] %s hatched a %s %s (%.2fx)",
		player.Name, rarity, pet.Name, petInstance.Multiplier))

	return true, petInstance
end

-- Roll for rarity
function PetService:RollRarity(boosts)
	boosts = boosts or {}

	-- Calculate adjusted chances
	local adjustedChances = {}
	local totalChance = 0

	for rarityName, rarityData in pairs(self.Rarities) do
		local chance = rarityData.Chance
		local boost = boosts[rarityName] or 1.0
		local adjustedChance = chance * boost
		adjustedChances[rarityName] = adjustedChance
		totalChance = totalChance + adjustedChance
	end

	-- Roll
	local roll = math.random() * totalChance
	local cumulative = 0

	-- Order from rarest to common
	local order = {"Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"}

	for _, rarityName in ipairs(order) do
		cumulative = cumulative + adjustedChances[rarityName]
		if roll <= cumulative then
			return rarityName
		end
	end

	return "Common"
end

-- Roll for specific pet
function PetService:RollPet(rarity)
	local available = {}

	for _, pet in ipairs(self.PetTypes) do
		if pet.Rarity == rarity then
			table.insert(available, pet)
		end
	end

	if #available == 0 then
		-- Fallback to any pet
		return self.PetTypes[math.random(#self.PetTypes)]
	end

	return available[math.random(#available)]
end

-- Create pet instance with stats
function PetService:CreatePetInstance(petType, rarity)
	local rarityData = self.Rarities[rarity]
	local minMult, maxMult = rarityData.MultiplierRange[1], rarityData.MultiplierRange[2]
	local multiplier = minMult + math.random() * (maxMult - minMult)

	return {
		Id = petType.Id .. "_" .. os.time() .. "_" .. math.random(1000, 9999),
		TypeId = petType.Id,
		Name = petType.Name,
		Rarity = rarity,
		BonusType = petType.BonusType,
		Description = petType.Description,
		Icon = petType.Icon,
		Multiplier = math.floor(multiplier * 100) / 100, -- Round to 2 decimals
		Level = 1,
		Experience = 0,
		Equipped = false
	}
end

-- Equip a pet
function PetService:EquipPet(player, petId)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return false, "No data found" end

	-- Check equipped limit
	if #playerData.Equipped >= self.MAX_EQUIPPED then
		return false, "Maximum pets equipped"
	end

	-- Find pet in inventory
	local pet = nil
	for _, p in ipairs(playerData.Inventory) do
		if p.Id == petId then
			pet = p
			break
		end
	end

	if not pet then
		return false, "Pet not found"
	end

	if pet.Equipped then
		return false, "Pet already equipped"
	end

	-- Equip
	pet.Equipped = true
	table.insert(playerData.Equipped, pet.Id)

	-- Create visual pet follower
	self:CreatePetFollower(player, pet)

	print(string.format("[PetService] %s equipped %s", player.Name, pet.Name))
	return true, pet
end

-- Unequip a pet
function PetService:UnequipPet(player, petId)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return false, "No data found" end

	-- Find and unequip
	for i, equippedId in ipairs(playerData.Equipped) do
		if equippedId == petId then
			table.remove(playerData.Equipped, i)

			-- Update pet
			for _, p in ipairs(playerData.Inventory) do
				if p.Id == petId then
					p.Equipped = false
					break
				end
			end

			-- Remove visual
			self:RemovePetFollower(player, petId)

			return true
		end
	end

	return false, "Pet not equipped"
end

-- Delete a pet
function PetService:DeletePet(player, petId)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return false, "No data found" end

	-- Unequip first if equipped
	self:UnequipPet(player, petId)

	-- Remove from inventory
	for i, pet in ipairs(playerData.Inventory) do
		if pet.Id == petId then
			table.remove(playerData.Inventory, i)
			return true
		end
	end

	return false, "Pet not found"
end

-- Create visual pet follower
function PetService:CreatePetFollower(player, pet)
	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local rarityData = self.Rarities[pet.Rarity]

	-- Create pet model
	local petModel = Instance.new("Part")
	petModel.Name = "Pet_" .. pet.Id
	petModel.Size = Vector3.new(1.5, 1.5, 1.5)
	petModel.Color = rarityData.Color
	petModel.Material = Enum.Material.Neon
	petModel.CanCollide = false
	petModel.Anchored = false

	-- Attachment to follow player
	local attachment = Instance.new("Attachment")
	attachment.Parent = petModel

	local alignPos = Instance.new("AlignPosition")
	alignPos.Attachment0 = attachment
	alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPos.MaxForce = 10000
	alignPos.Responsiveness = 10
	alignPos.Parent = petModel

	-- Add pet name billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 1.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = petModel

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = pet.Name
	nameLabel.TextColor3 = rarityData.Color
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Parent = billboard

	-- Pet icon
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = pet.Icon
	iconLabel.TextColor3 = Color3.new(1, 1, 1)
	iconLabel.TextSize = 24
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = petModel

	-- Highlight effect
	local highlight = Instance.new("Highlight")
	highlight.FillColor = rarityData.Color
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.5
	highlight.Parent = petModel

	-- Particle effect for rare pets
	if pet.Rarity == "Legendary" or pet.Rarity == "Mythic" then
		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(rarityData.Color)
		particles.Size = NumberSequence.new(0.2)
		particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particles.Lifetime = NumberRange.new(0.5, 1)
		particles.Rate = 20
		particles.Speed = NumberRange.new(1, 2)
		particles.Parent = petModel
	end

	-- Position near player
	local petFolder = workspace:FindFirstChild("Pets") or Instance.new("Folder", workspace)
	petFolder.Name = "Pets"

	petModel.Position = rootPart.Position + Vector3.new(3, 2, 0)
	petModel.Parent = petFolder

	-- Orbit behavior
	task.spawn(function()
		local angle = 0
		local radius = 3
		local height = 2
		local speed = 2

		while petModel and petModel.Parent and character and character.Parent do
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				angle = angle + speed * 0.016 -- ~60fps
				local x = math.cos(angle) * radius
				local z = math.sin(angle) * radius
				alignPos.Position = hrp.Position + Vector3.new(x, height, z)
			end
			task.wait()
		end
	end)
end

-- Remove pet follower
function PetService:RemovePetFollower(player, petId)
	local petFolder = workspace:FindFirstChild("Pets")
	if petFolder then
		local petModel = petFolder:FindFirstChild("Pet_" .. petId)
		if petModel then
			petModel:Destroy()
		end
	end
end

-- Calculate total bonus from equipped pets
function PetService:GetTotalBonus(player, bonusType)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return 1.0 end

	local totalBonus = 1.0

	for _, petId in ipairs(playerData.Equipped) do
		for _, pet in ipairs(playerData.Inventory) do
			if pet.Id == petId then
				if pet.BonusType == bonusType or pet.BonusType == "AllBonus" then
					totalBonus = totalBonus * pet.Multiplier
				end
				break
			end
		end
	end

	return totalBonus
end

-- Get all equipped pet bonuses
function PetService:GetAllBonuses(player)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return {} end

	local bonuses = {
		CurrencyMultiplier = 1.0,
		ObjectValue = 1.0,
		LuckBoost = 1.0,
		SpeedBoost = 1.0,
		ComboExtender = 1.0,
		GateBonus = 1.0,
		CollectionRange = 1.0
	}

	for _, petId in ipairs(playerData.Equipped) do
		for _, pet in ipairs(playerData.Inventory) do
			if pet.Id == petId then
				if pet.BonusType == "AllBonus" then
					for key, _ in pairs(bonuses) do
						bonuses[key] = bonuses[key] * pet.Multiplier
					end
				elseif bonuses[pet.BonusType] then
					bonuses[pet.BonusType] = bonuses[pet.BonusType] * pet.Multiplier
				end
				break
			end
		end
	end

	return bonuses
end

-- Get player's pet data for UI
function PetService:GetPetData(player)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return nil end

	return {
		Inventory = playerData.Inventory,
		Equipped = playerData.Equipped,
		TotalHatched = playerData.TotalHatched,
		MaxInventory = self.MAX_INVENTORY,
		MaxEquipped = self.MAX_EQUIPPED,
		EggTypes = self.EggTypes,
		Bonuses = self:GetAllBonuses(player)
	}
end

-- Load saved data
function PetService:LoadData(player, savedData)
	if not savedData then return end

	local playerData = self.PlayerPets[player.UserId]
	if not playerData then
		self:InitializePlayer(player)
		playerData = self.PlayerPets[player.UserId]
	end

	playerData.Inventory = savedData.Inventory or {}
	playerData.Equipped = savedData.Equipped or {}
	playerData.TotalHatched = savedData.TotalHatched or 0
	playerData.LegendaryCount = savedData.LegendaryCount or 0
	playerData.MythicCount = savedData.MythicCount or 0

	-- Recreate equipped pet visuals
	task.delay(2, function()
		if player.Character then
			for _, petId in ipairs(playerData.Equipped) do
				for _, pet in ipairs(playerData.Inventory) do
					if pet.Id == petId then
						self:CreatePetFollower(player, pet)
						break
					end
				end
			end
		end
	end)
end

-- Get save data
function PetService:GetSaveData(player)
	local playerData = self.PlayerPets[player.UserId]
	if not playerData then return nil end

	return {
		Inventory = playerData.Inventory,
		Equipped = playerData.Equipped,
		TotalHatched = playerData.TotalHatched,
		LegendaryCount = playerData.LegendaryCount,
		MythicCount = playerData.MythicCount
	}
end

-- Cleanup
function PetService:CleanupPlayer(player)
	-- Remove all pet visuals
	local petFolder = workspace:FindFirstChild("Pets")
	if petFolder then
		for _, child in ipairs(petFolder:GetChildren()) do
			if child.Name:find("Pet_") then
				child:Destroy()
			end
		end
	end

	self.PlayerPets[player.UserId] = nil
end

return PetService
