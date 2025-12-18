# Multiplication Game - Setup Guide

## Quick Start

Follow these steps to get your multiplication game running in Roblox Studio.

### Step 1: Create a New Place

1. Open **Roblox Studio**
2. Create a new **Baseplate** template
3. Save your place with a name like "Multiplication Game"

### Step 2: Import the Scripts

You'll need to manually copy the scripts into Roblox Studio:

#### ServerScriptService

Copy these files into **ServerScriptService**:
- `init.server.lua` - Main server initialization
- `ObjectManager.lua` - ModuleScript
- `MultiplierService.lua` - ModuleScript
- `CurrencyService.lua` - ModuleScript
- `PathManager.lua` - ModuleScript

#### ReplicatedStorage

1. Create a folder called **ReplicatedStorage** (if it doesn't exist)
2. Copy `Config.lua` as a ModuleScript

#### StarterGui

Copy `GameUI.lua` as a **LocalScript** into **StarterGui**

#### StarterPlayer

1. Navigate to **StarterPlayer** > **StarterCharacterScripts**
2. Copy `CharacterController.lua` as a **LocalScript**

### Step 3: Configure the Game

No physical parts are required! The scripts will automatically create:
- ✅ The runway/path
- ✅ Multiplier gates
- ✅ Collection zone
- ✅ Spawn platforms

Just press **Play** and it will generate everything!

### Step 4: Test the Game

1. Click **Play** (F5) in Roblox Studio
2. Your character should spawn near the starting platform
3. Objects (Goblins) will automatically spawn
4. Walk into objects to push them forward
5. Watch them multiply as they pass through gates!
6. Objects are collected at the end for currency

## Customization

### Changing Spawn Position

Edit `init.server.lua` line 17:
```lua
SpawnPosition = Vector3.new(0, 10, 0), -- Change X, Y, Z coordinates
```

### Adding New Object Types

Edit `Config.lua` and add new entries to `Config.Objects`:
```lua
Robot = {
    Name = "Robot",
    Color = Color3.fromRGB(128, 128, 128),
    Size = Vector3.new(2, 3, 2),
    Value = 15,
    SpawnRate = 8,
},
```

### Adjusting Multiplier Gates

Edit `Config.lua` to modify the `Config.Multipliers` table:
```lua
{Type = "Multiply", Value = 10, Color = Color3.fromRGB(255, 0, 0), Text = "x10"},
```

### Changing Push Force

Edit `Config.lua` line 26:
```lua
PushForce = 50, -- Increase for stronger push
```

## Troubleshooting

### Objects Not Spawning
- Check that `init.server.lua` is in **ServerScriptService**
- Make sure `Config.lua` is in **ReplicatedStorage**
- Check the Output window for error messages

### Objects Not Multiplying
- Ensure `MultiplierService.lua` is a **ModuleScript**
- Check that gates are being generated (look for green/red glowing gates)
- Verify objects have "ObjectType" and "ObjectValue" tags

### UI Not Showing
- Make sure `GameUI.lua` is a **LocalScript** in **StarterGui**
- Check that it's not set to "Disabled"

### Objects Falling Through Floor
- The runway is automatically created, but if you have a custom baseplate, make sure it doesn't interfere
- Check that the spawn position Y coordinate is high enough (default: 10)

## Advanced Features (Future Enhancements)

Want to add more features? Here are some ideas:

1. **Upgrades Shop**: Use currency to buy better objects and multipliers
2. **Different Paths**: Create multiple runways with different rewards
3. **Boss Objects**: Special rare objects worth tons of currency
4. **Combo System**: Multiply faster for hitting multiple gates in a row
5. **Leaderboards**: Track top players by currency or objects collected

## File Structure Overview

```
multiplication-game/
├── README.md                          # Project overview
├── SETUP_GUIDE.md                     # This file
└── src/
    ├── ServerScriptService/
    │   ├── init.server.lua           # Main initialization
    │   ├── ObjectManager.lua         # Spawning & cloning objects
    │   ├── MultiplierService.lua     # Multiplier gate logic
    │   ├── CurrencyService.lua       # Player currency system
    │   └── PathManager.lua           # Runway and collection
    ├── ReplicatedStorage/
    │   └── Config.lua                # Game configuration
    ├── StarterGui/
    │   └── GameUI.lua                # Player UI
    └── StarterPlayer/
        └── StarterCharacterScripts/
            └── CharacterController.lua  # Player movement
```

## Support

For issues or questions:
1. Check the Roblox Output window for errors
2. Review this guide's troubleshooting section
3. Make sure all scripts are in the correct locations
4. Verify ModuleScripts vs LocalScripts vs Scripts are correct

Happy game development! 🎮
