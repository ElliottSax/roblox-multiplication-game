# Game Features

## Current Features

### Core Gameplay
- **Object Pushing**: Walk into objects to push them down the runway
- **Automatic Spawning**: Objects spawn automatically at regular intervals
- **Multiplier Gates**: Objects passing through gates multiply (x2, x3, x5) or add (+5, +10)
- **Special Gates**: Subtract (-30%, -50%), Divide (/2), Random (???), Power (^2) gates
- **Collection System**: Objects convert to currency when they reach the end
- **Real-time Currency**: Track your earnings with live UI updates

### Object Types (9 Total)
| Object | Value | Unlock Requirement | Material |
|--------|-------|-------------------|----------|
| Goblin | $1 | Always | SmoothPlastic |
| Treasure | $5 | 100 currency | SmoothPlastic |
| Diamond | $10 | 500 currency | SmoothPlastic |
| Robot | $25 | 2,500 currency | Metal |
| Magic Orb | $50 | 10,000 currency | Neon |
| Crystal Shard | $75 | 25,000 currency | Glass |
| Legendary Gem | $150 | 100,000 currency | Neon |
| Ancient Relic | $250 | 500,000 currency | Marble |
| Cosmic Essence | $500 | 1,000,000 currency | ForceField |

### Gate Types
| Gate | Effect | Weight |
|------|--------|--------|
| x2 | Double objects | 30 |
| x3 | Triple objects | 20 |
| x5 | 5x objects | 10 |
| +5 | Add 5 objects | 25 |
| +10 | Add 10 objects | 15 |
| -30% | Remove 30%, 1.5x value | 10 |
| -50% | Remove 50%, 2x value | 8 |
| /2 | Halve objects, 3x value | 5 |
| ??? | Random effect | 7 |
| ^2 | Square the count | 3 |

### Achievement System (35+ Achievements)
- **Collection**: First Blood, Collector, Hoarder, Treasure Hunter, Legend
- **Currency**: Penny Pincher, Money Maker, Millionaire
- **Combo**: Combo Starter, Combo Master, Combo Legend
- **Gates**: Gate Runner, Gate Guru, Gate God
- **Multipliers**: Big Multiply, Mega Multiply
- **Upgrades**: First Upgrade, Fully Upgraded
- **Time**: Dedicated, Committed, Obsessed
- **Rebirth**: First Rebirth, Rebirth Master, Rebirth Legend
- **Quests**: Quest Beginner, Quest Expert, Quest Master
- **Pets**: First Pet, Pet Collector, Pet Hoarder, Rare Finder, Mythic Hunter

### Combo System
- Build combos by hitting gates quickly
- Tiers: Nice (5x), Great (10x), Amazing (25x), Incredible (50x), Legendary (100x)
- Higher combos = bonus currency multipliers
- Combo decay timer keeps you engaged

### Sound System
- Gate activation sounds
- Collection sounds
- Combo tier sounds
- Achievement unlock fanfare
- Background music
- Rebirth/Quest/Pet sounds

### Leaderboard System
- All-Time Currency earned
- All-Time Objects collected
- Highest Combo achieved
- Current Currency

### Boss Wave Events
| Boss | Value | Health | Spawn |
|------|-------|--------|-------|
| Goblin Horde | $25 each (x20) | 1 | 2 min |
| Goblin King | $100 | 3 | 5 min |
| Treasure Dragon | $250 | 5 | 10 min |
| Diamond Golem | $500 | 7 | 15 min |
| Golden Phoenix | $1000 | 10 | 20 min |

### Rebirth/Prestige System (NEW)
Reset your progress for permanent multipliers!

| Tier | Name | Required | Multiplier |
|------|------|----------|------------|
| 1 | Apprentice | 10K | 1.5x |
| 2 | Journeyman | 50K | 2.0x |
| 3 | Expert | 250K | 3.0x |
| 4 | Master | 1M | 5.0x |
| 5 | Grandmaster | 5M | 8.0x |
| 6 | Legend | 25M | 12.0x |
| 7 | Mythic | 100M | 20.0x |

**Rebirth Rewards**:
- Permanent currency multipliers
- Unlock object types early
- Speed boost
- Auto-collect
- Gate bonuses
- Mythic aura

### Daily Quest System (NEW)
- 3 random quests daily
- Quest types: Collection, Currency, Gates, Combos, Bosses, Time
- Streak bonuses (up to 70% extra rewards)
- Midnight UTC refresh

### Pet System (NEW)
Collectible pets with passive bonuses!

**Rarities**:
| Rarity | Chance | Multiplier Range |
|--------|--------|------------------|
| Common | 60% | 1.05x - 1.15x |
| Uncommon | 25% | 1.15x - 1.30x |
| Rare | 10% | 1.30x - 1.50x |
| Epic | 4% | 1.50x - 1.80x |
| Legendary | 0.9% | 1.80x - 2.50x |
| Mythic | 0.1% | 2.50x - 4.00x |

**Egg Types**:
- Basic Egg ($1K) - Standard rates
- Premium Egg ($5K) - Better uncommon/rare chances
- Legendary Egg ($25K) - Much better rare+ chances
- Mythic Egg ($100K) - Best Mythic chances

**Pet Types** (15 pets):
- Common: Goblin Buddy, Coin Sprite, Treasure Bug
- Uncommon: Lucky Cat, Speed Hare, Combo Fox
- Rare: Diamond Turtle, Gate Guardian, Magnet Moth
- Epic: Golden Phoenix, Void Serpent, Time Keeper
- Legendary: Dragon of the Hoard, Celestial Wolf
- Mythic: Cosmic Entity

**Bonus Types**:
- Currency Multiplier
- Object Value
- Luck Boost
- Speed Boost
- Combo Extender
- Gate Bonus
- Collection Range
- All Bonus (stacks with everything)

### Visual Effects
- **Neon Gates**: Colorful multiplier gates with text labels
- **Particle Effects**: Visual feedback when gates activate
- **Push Zone Indicator**: Glowing ring around player showing push range
- **Lane Markers**: Clear path visualization
- **Collection Zone**: Bright green zone at the end
- **High-Value Object Effects**: Glow and particles for valuable objects
- **Pet Followers**: Equipped pets orbit around you

### UI Elements
- **Currency Display**: Shows current currency with icon
- **Collection Counter**: Tracks total objects collected
- **Combo Display**: Shows current combo and tier
- **Achievement Notifications**: Popup when achievements unlock
- **Leaderboard Panel**: View global rankings
- **Shop/Upgrade Panel**: Purchase upgrades
- **Rebirth Panel**: View prestige progress
- **Quest Panel**: Track daily quests
- **Pet Panel**: Manage pet collection
- **Boss Wave Announcements**: Dramatic boss spawn alerts

## Data Persistence

All player data is saved:
- Currency and total earned
- Objects collected
- Purchased upgrades
- Achievements unlocked
- Rebirth tier and progress
- Daily quests and streaks
- Pet inventory and equipped pets

## Architecture

### Server Services
- `CurrencyService` - Handles all currency transactions
- `MultiplierService` - Manages gate effects
- `ComboService` - Tracks and rewards combos
- `UpgradeService` - Player upgrades
- `DataService` - Save/load player data
- `AchievementService` - Achievement tracking
- `SoundService` - Audio management
- `LeaderboardService` - Global leaderboards
- `BossWaveService` - Boss event spawning
- `RebirthService` - Prestige system
- `QuestService` - Daily quests
- `PetService` - Pet collection and bonuses
- `ObjectManager` - Object spawning and lifecycle
- `PathManager` - Game path and physics
- `AdminCommands` - Developer commands

### Client UI Scripts
- `AchievementUI` - Achievement display
- `LeaderboardUI` - Leaderboard viewing
- `BossWaveUI` - Boss announcements
- `RebirthUI` - Rebirth panel
- `QuestUI` - Quest tracking
- `PetUI` - Pet management

## Game Mechanics

### How Multiplication Works

1. **Object Spawns**: A goblin spawns at the starting platform
2. **Player Pushes**: Walk into the goblin to push it forward
3. **Hits Multiplier Gate**:
   - If it's a "x2" gate, the goblin clones into 2 goblins
   - If it's a "+5" gate, 5 new goblins spawn
4. **Continues Forward**: All objects keep moving down the path
5. **More Gates**: Each object can pass through multiple gates
6. **Collection**: All objects reach the end and convert to currency

### Example Multiplication Chain

```
Start: 1 Goblin (Value: 1)
  |
x2 Gate: 2 Goblins (Value: 2)
  |
x3 Gate: 6 Goblins (Value: 6)
  |
+5 Gate: 11 Goblins (Value: 11)
  |
x2 Gate: 22 Goblins (Value: 22)
  |
Collection: +22 Currency!
```

### Bonus Stacking

Currency earned is multiplied by:
1. Base object value
2. Rebirth multiplier (up to 20x)
3. Pet bonuses (stacking multipliers)
4. Combo multiplier (up to 2x)

Example: $1 Goblin x 5x Rebirth x 1.5x Pet x 1.5x Combo = $11.25!

## Configuration

All game values can be adjusted in `Config.lua`:
- Spawn rates and weights
- Object values and unlock requirements
- Gate types and probabilities
- Path dimensions
- Physics settings
- Currency bonuses

## Performance Notes

The game is optimized for:
- **Up to 100 simultaneous objects** on screen
- **Multiple players** pushing objects together
- **Automatic cleanup** of collected objects
- **Efficient gate detection** with debouncing
- **Cached leaderboard data** (60-second refresh)

## Future Ideas

### Game Modes
- **Endless Mode**: See how far you can go
- **Time Attack**: Collect as much as possible in 60 seconds
- **Precision Mode**: Gates appear and disappear
- **Chaos Mode**: Random everything!

### Potential Additions
- Multiple parallel paths
- Team/guild system
- Trading between players
- Seasonal events
- Battle pass rewards
- Custom pet skins

### Monetization (Optional)
- **Game Passes**: Auto-collect, double currency, VIP area
- **Developer Products**: Currency packs, egg bundles
- **Cosmetics**: Custom object skins, trail effects
