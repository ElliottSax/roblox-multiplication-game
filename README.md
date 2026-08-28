# Multiplication Game

A Roblox game where players push objects through multiplier gates to increase their count and earn rewards.

## Game Mechanics

1. **Object Pushing**: Players push objects (goblins, treasure, etc.) down a runway
2. **Multiplier Gates**: Objects passing through gates get multiplied (x2, x3, +5, etc.)
3. **Collection**: Objects reach the end and convert to currency/points
4. **Upgrades**: Use currency to unlock better objects and multipliers

## Project Structure

```
src/
├── ServerScriptService/          - Game services (currency, multipliers, combos, quests, pets, boss waves, etc.)
├── ReplicatedStorage/             - Shared config (Config.lua)
├── StarterGui/                    - Player-facing UI for each system
└── StarterPlayer/StarterCharacterScripts/ - Per-character controller
```

See [FEATURES.md](FEATURES.md) for the full, current list of services and systems.

## Installation

1. Open Roblox Studio
2. Create a new place
3. Copy the contents of `src/` into the corresponding services
4. Create the physical game elements (runway, gates, spawn zones)
5. Test in Studio

## Configuration

Edit `ReplicatedStorage/Config.lua` to adjust:
- Starting object spawn rate
- Multiplier gate values
- Currency conversion rates
- Object types and properties
