# Quick Start - 5 Minute Setup

Get your multiplication game running in **5 minutes**!

## Step 1: Open Roblox Studio (30 seconds)
1. Launch Roblox Studio
2. Click "New" → "Baseplate"
3. Save as "Multiplication Game"

## Step 2: Copy Server Scripts (2 minutes)

### In ServerScriptService:

1. **Create init.server.lua** (Script)
   - Copy from: `src/ServerScriptService/init.server.lua`

2. **Create 4 ModuleScripts**:
   - `ObjectManager` - Copy from `ObjectManager.lua`
   - `MultiplierService` - Copy from `MultiplierService.lua`
   - `CurrencyService` - Copy from `CurrencyService.lua`
   - `PathManager` - Copy from `PathManager.lua`

### In ReplicatedStorage:

3. **Create Config** (ModuleScript)
   - Copy from: `src/ReplicatedStorage/Config.lua`

## Step 3: Copy Client Scripts (1 minute)

### In StarterGui:

4. **Create GameUI** (LocalScript)
   - Copy from: `src/StarterGui/GameUI.lua`

### In StarterPlayer → StarterCharacterScripts:

5. **Create CharacterController** (LocalScript)
   - Copy from: `src/StarterPlayer/StarterCharacterScripts/CharacterController.lua`

## Step 4: Play! (30 seconds)

1. Press **F5** or click **Play**
2. Watch the magic happen!

## What You Should See:

✅ A gray runway appears
✅ Colorful multiplier gates spawn (x2, x3, +5, etc.)
✅ Green collection zone at the end
✅ UI in top-left showing currency
✅ Goblins spawn automatically
✅ Walk into goblins to push them!

## Controls:

- **WASD** or **Arrow Keys**: Move
- **Spacebar**: Jump
- **Walk into objects**: Push them forward

## Troubleshooting:

**Nothing appears?**
- Check Output window for errors
- Make sure `Config` is in ReplicatedStorage
- Verify all ModuleScripts are named correctly

**Can't push objects?**
- Make sure CharacterController is in StarterCharacterScripts
- Check that it's a LocalScript (not Script)

**No UI?**
- GameUI must be a LocalScript in StarterGui
- Not disabled (check the checkbox)

## Next Steps:

🎨 **Customize** - Edit `Config.lua` to change values
🚀 **Expand** - Add new features from `FEATURES.md`
📖 **Learn** - Read `README.md` for full details

**That's it! You're done!** 🎮

Now watch those objects multiply! Each goblin that passes through a x2 gate becomes 2 goblins, then 4, then 8... it's exponential growth at its finest!

---

**Pro Tip**: Try walking alongside the objects as they go through gates to push them faster! The more objects you collect, the more currency you earn!
