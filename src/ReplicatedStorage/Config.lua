-- Game Configuration
local Config = {}

-- Object Settings
Config.Objects = {
	Goblin = {
		Name = "Goblin",
		Color = Color3.fromRGB(34, 139, 34),
		Size = Vector3.new(2, 2, 2),
		Value = 1, -- Base currency value
		SpawnRate = 2, -- Seconds between spawns
	},
	Treasure = {
		Name = "Treasure",
		Color = Color3.fromRGB(255, 215, 0),
		Size = Vector3.new(1.5, 1.5, 1.5),
		Value = 5,
		SpawnRate = 5,
	},
	Diamond = {
		Name = "Diamond",
		Color = Color3.fromRGB(0, 191, 255),
		Size = Vector3.new(1, 1, 1),
		Value = 10,
		SpawnRate = 10,
	}
}

-- Multiplier Gate Settings
Config.Multipliers = {
	{Type = "Multiply", Value = 2, Color = Color3.fromRGB(255, 100, 100), Text = "x2"},
	{Type = "Multiply", Value = 3, Color = Color3.fromRGB(255, 150, 100), Text = "x3"},
	{Type = "Multiply", Value = 5, Color = Color3.fromRGB(255, 200, 100), Text = "x5"},
	{Type = "Add", Value = 5, Color = Color3.fromRGB(100, 255, 100), Text = "+5"},
	{Type = "Add", Value = 10, Color = Color3.fromRGB(100, 255, 150), Text = "+10"},
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
