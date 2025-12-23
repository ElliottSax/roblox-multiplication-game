-- Game Configuration
local Config = {}

-- Object Settings
Config.Objects = {
	-- Basic Objects (Early Game)
	Goblin = {
		Name = "Goblin",
		Color = Color3.fromRGB(34, 139, 34),
		Size = Vector3.new(2, 2, 2),
		Value = 1,
		SpawnRate = 2,
		SpawnWeight = 40,
		UnlockRequirement = 0, -- Always available
	},
	Treasure = {
		Name = "Treasure",
		Color = Color3.fromRGB(255, 215, 0),
		Size = Vector3.new(1.5, 1.5, 1.5),
		Value = 5,
		SpawnRate = 5,
		SpawnWeight = 25,
		UnlockRequirement = 100, -- Need 100 currency to unlock
	},
	Diamond = {
		Name = "Diamond",
		Color = Color3.fromRGB(0, 191, 255),
		Size = Vector3.new(1, 1, 1),
		Value = 10,
		SpawnRate = 10,
		SpawnWeight = 15,
		UnlockRequirement = 500,
	},

	-- Mid-Game Objects
	Robot = {
		Name = "Robot",
		Color = Color3.fromRGB(150, 150, 150),
		Size = Vector3.new(2.5, 2.5, 2.5),
		Value = 25,
		SpawnRate = 15,
		SpawnWeight = 10,
		UnlockRequirement = 2500,
		Material = "Metal",
	},
	MagicOrb = {
		Name = "Magic Orb",
		Color = Color3.fromRGB(200, 100, 255),
		Size = Vector3.new(1.8, 1.8, 1.8),
		Value = 50,
		SpawnRate = 20,
		SpawnWeight = 6,
		UnlockRequirement = 10000,
		Material = "Neon",
	},
	CrystalShard = {
		Name = "Crystal Shard",
		Color = Color3.fromRGB(100, 255, 200),
		Size = Vector3.new(1.2, 2.4, 1.2),
		Value = 75,
		SpawnRate = 25,
		SpawnWeight = 4,
		UnlockRequirement = 25000,
		Material = "Glass",
	},

	-- Late-Game Objects
	LegendaryGem = {
		Name = "Legendary Gem",
		Color = Color3.fromRGB(255, 50, 100),
		Size = Vector3.new(1.5, 1.5, 1.5),
		Value = 150,
		SpawnRate = 30,
		SpawnWeight = 2,
		UnlockRequirement = 100000,
		Material = "Neon",
	},
	AncientRelic = {
		Name = "Ancient Relic",
		Color = Color3.fromRGB(139, 90, 43),
		Size = Vector3.new(2, 3, 2),
		Value = 250,
		SpawnRate = 45,
		SpawnWeight = 1,
		UnlockRequirement = 500000,
		Material = "Marble",
	},
	CosmicEssence = {
		Name = "Cosmic Essence",
		Color = Color3.fromRGB(50, 0, 100),
		Size = Vector3.new(2, 2, 2),
		Value = 500,
		SpawnRate = 60,
		SpawnWeight = 0.5,
		UnlockRequirement = 1000000,
		Material = "ForceField",
	},
}

-- Multiplier Gate Settings
Config.Multipliers = {
	-- Multiplication gates
	{Type = "Multiply", Value = 2, Color = Color3.fromRGB(255, 100, 100), Text = "x2", Weight = 30},
	{Type = "Multiply", Value = 3, Color = Color3.fromRGB(255, 150, 100), Text = "x3", Weight = 20},
	{Type = "Multiply", Value = 5, Color = Color3.fromRGB(255, 200, 100), Text = "x5", Weight = 10},

	-- Addition gates
	{Type = "Add", Value = 5, Color = Color3.fromRGB(100, 255, 100), Text = "+5", Weight = 25},
	{Type = "Add", Value = 10, Color = Color3.fromRGB(100, 255, 150), Text = "+10", Weight = 15},

	-- Subtraction gates (risky but high value boost)
	{Type = "Subtract", Value = 50, Color = Color3.fromRGB(255, 50, 150), Text = "-50%", Weight = 8, ValueMultiplier = 2},
	{Type = "Subtract", Value = 30, Color = Color3.fromRGB(255, 100, 180), Text = "-30%", Weight = 10, ValueMultiplier = 1.5},

	-- Division gates (very risky, very high value)
	{Type = "Divide", Value = 2, Color = Color3.fromRGB(200, 50, 200), Text = "/2", Weight = 5, ValueMultiplier = 3},

	-- Random gates (exciting unpredictability)
	{Type = "Random", Value = 0, Color = Color3.fromRGB(150, 100, 255), Text = "???", Weight = 7},

	-- Power gates (square the count - rare but powerful)
	{Type = "Power", Value = 2, Color = Color3.fromRGB(255, 255, 100), Text = "^2", Weight = 3},
}

-- Physics Settings
Config.Physics = {
	PushForce = 50, -- Force applied when player touches objects
	ObjectMass = 1,
	Friction = 0.3,
	PathSpeed = 10, -- Speed objects move down the runway
}

-- Path Settings
Config.Path = {
	Width = 20, -- Width of the runway
	Length = 200, -- Total length of runway
	GateSpacing = 30, -- Distance between multiplier gates
}

-- Currency Settings
Config.Currency = {
	StartingAmount = 0,
	CollectionBonus = 1.0, -- Multiplier for collected objects
}

-- Upgrade Settings
Config.Upgrades = {
	SpeedBoost = {
		Cost = 100,
		Multiplier = 1.5,
		Description = "Increase push force by 50%",
	},
	AutoPush = {
		Cost = 500,
		Description = "Objects automatically move forward",
	},
	BetterSpawns = {
		Cost = 250,
		Description = "Spawn higher value objects",
	}
}

return Config
