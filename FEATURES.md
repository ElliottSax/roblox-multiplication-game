# Game Features

## Current Features ✅

### Core Gameplay
- **Object Pushing**: Walk into objects to push them down the runway
- **Automatic Spawning**: Objects spawn automatically at regular intervals
- **Multiplier Gates**: Objects passing through gates multiply (x2, x3, x5) or add (+5, +10)
- **Collection System**: Objects convert to currency when they reach the end
- **Real-time Currency**: Track your earnings with live UI updates

### Visual Effects
- **Neon Gates**: Colorful multiplier gates with text labels
- **Particle Effects**: Visual feedback when gates activate
- **Push Zone Indicator**: Glowing ring around player showing push range
- **Lane Markers**: Clear path visualization
- **Collection Zone**: Bright green zone at the end

### Physics & Movement
- **Natural Physics**: Objects use realistic physics for movement
- **Push Mechanics**: Player proximity pushes objects forward
- **Velocity System**: Objects maintain momentum through gates
- **Wall Boundaries**: Invisible walls keep objects on the path

### UI Elements
- **Currency Display**: Shows current currency with icon
- **Collection Counter**: Tracks total objects collected
- **Instructions**: In-game help text
- **Leaderstats**: Visible stats for all players

## Planned Features 🔮

### Upgrades System
- **Speed Boost**: Increase push force
- **Auto Push**: Objects move automatically
- **Better Spawns**: Unlock higher-value objects
- **Gate Upgrades**: Increase multiplier values

### Additional Object Types
- **Goblins** ✅ (Current)
- **Treasure** ✅ (Configured)
- **Diamonds** ✅ (Configured)
- **Robots** (Future)
- **Magic Orbs** (Future)
- **Rare Legendary Objects** (Future)

### Gameplay Enhancements
- **Multiple Paths**: Different difficulty runways
- **Combo System**: Bonus for hitting consecutive gates
- **Power-ups**: Temporary boosts and abilities
- **Challenges**: Daily/weekly objectives
- **Boss Waves**: Special high-value object events

### Social Features
- **Leaderboards**: Compete with other players
- **Team Mode**: Collaborative object collection
- **Trading**: Exchange objects between players
- **Guilds**: Create teams and compete

### Visual Improvements
- **Better Graphics**: Enhanced particle effects
- **Animations**: Object spin/bounce animations
- **Sound Effects**: Gate activation sounds
- **Music**: Background music tracks
- **Weather Effects**: Dynamic environment

## Game Mechanics Explained

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
  ↓
x2 Gate: 2 Goblins (Value: 2)
  ↓
x3 Gate: 6 Goblins (Value: 6)
  ↓
+5 Gate: 11 Goblins (Value: 11)
  ↓
x2 Gate: 22 Goblins (Value: 22)
  ↓
Collection: +22 Currency!
```

### Object Values

Each object type has a base value:
- **Goblin**: 1 currency
- **Treasure**: 5 currency
- **Diamond**: 10 currency

The more valuable the object, the slower it spawns!

### Gate Types

- **Multiply Gates** (x2, x3, x5): Clone the object N times
- **Addition Gates** (+5, +10): Spawn N new objects
- **Future: Subtraction Gates** (-50%): Reduce objects but increase value
- **Future: Special Gates**: Rainbow gates with random effects

## Configuration

All game values can be adjusted in `Config.lua`:

- Spawn rates
- Object values
- Multiplier gate types
- Path dimensions
- Physics settings
- Currency bonuses

## Performance Notes

The game is optimized for:
- **Up to 100 simultaneous objects** on screen
- **Multiple players** pushing objects together
- **Automatic cleanup** of collected objects
- **Efficient gate detection** with debouncing

For better performance on lower-end devices:
- Reduce spawn rates in Config.lua
- Decrease particle emission rates
- Limit the number of gates

## Future Expansion Ideas

### Game Modes
- **Endless Mode**: See how far you can go
- **Time Attack**: Collect as much as possible in 60 seconds
- **Precision Mode**: Gates appear and disappear
- **Chaos Mode**: Random everything!

### Progression System
- **Levels**: Unlock new features as you progress
- **Achievements**: Complete challenges for rewards
- **Prestige**: Reset for permanent bonuses
- **Battle Pass**: Seasonal rewards

### Monetization (Optional)
- **Game Passes**: Auto-collect, double currency, VIP area
- **Developer Products**: Currency packs, temporary boosts
- **Cosmetics**: Custom object skins, trail effects

Enjoy building and expanding your multiplication game! 🚀
