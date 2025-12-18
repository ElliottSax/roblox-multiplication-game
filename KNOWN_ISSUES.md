# Known Issues & Fixes

## Issues Identified and Fixed

### 🐛 Issue #1: AdminCommands SendMessage (CRITICAL)
**Problem:** AdminCommands tries to call `StarterGui:SetCore` from server, which only works on client.

**Impact:** Admin command responses don't show to players.

**Status:** ✅ FIXED

**Solution:** Created RemoteEvent system for server-to-client messaging.

---

### 🐛 Issue #2: Shop UI Remote Event Timing
**Problem:** ShopUI waits for remotes but might timeout if server is slow to create them.

**Impact:** Shop might not load in some cases.

**Status:** ✅ FIXED

**Solution:** Increased wait timeout and added retry logic.

---

### 🐛 Issue #3: Missing Error Handling
**Problem:** Some services don't handle edge cases (nil players, missing data, etc.).

**Impact:** Could cause script errors and crashes.

**Status:** ✅ FIXED

**Solution:** Added comprehensive nil checks and error handling.

---

### 🐛 Issue #4: Combo UI Initialization
**Problem:** ComboUI tries to connect events before they exist.

**Impact:** Combo display might not work initially.

**Status:** ✅ FIXED

**Solution:** Added proper waiting and error handling for remote events.

---

### 🐛 Issue #5: DataStore Validation
**Problem:** No validation when loading corrupted or old version data.

**Impact:** Could load invalid data and cause errors.

**Status:** ✅ FIXED

**Solution:** Added data validation and migration logic.

---

### 🐛 Issue #6: Object Spawning at Wrong Position
**Problem:** If SpawnPosition is invalid, objects spawn at 0,0,0 and fall.

**Impact:** Objects disappear immediately.

**Status:** ✅ FIXED

**Solution:** Added position validation with fallback defaults.

---

### 🐛 Issue #7: Shop Purchase Race Condition
**Problem:** Rapid clicking shop buttons could cause double-purchase.

**Impact:** Players could lose currency unfairly.

**Status:** ✅ FIXED

**Solution:** Added debounce logic to purchase button.

---

### 🐛 Issue #8: Combo Timeout Not Per-Player
**Problem:** ComboService checks all players' combos at once, inefficient.

**Impact:** Slight performance overhead.

**Status:** ✅ FIXED

**Solution:** Optimized combo checking with per-player timers.

---

## Testing Checklist

Use this checklist to verify all systems work:

### Basic Functionality
- [ ] Game loads without errors in Output
- [ ] Player spawns at correct position
- [ ] Objects spawn automatically
- [ ] Objects move down the runway
- [ ] Gates appear along the path

### Multiplication System
- [ ] Objects multiply when hitting x2, x3, x5 gates
- [ ] Objects are added when hitting +5, +10 gates
- [ ] Gate visual effects play
- [ ] Cloned objects continue moving

### Collection System
- [ ] Objects collected at end zone
- [ ] Currency increases when collected
- [ ] Particle effects play on collection
- [ ] Objects are removed after collection

### UI Systems
- [ ] Game UI shows currency and collected count
- [ ] Shop button appears and is clickable
- [ ] Shop opens with upgrade list
- [ ] Upgrade cards show correct info
- [ ] Purchase buttons work (green when affordable)

### Combo System
- [ ] Combo counter appears when hitting gates
- [ ] Combo increases with each gate hit
- [ ] Combo resets after 3 seconds
- [ ] Tier notifications appear (Nice!, Great!, etc.)
- [ ] Multiplier applies to gate effects

### Data Persistence
- [ ] Currency saves when leaving
- [ ] Currency loads when rejoining
- [ ] Upgrades persist between sessions
- [ ] No data loss on server shutdown

### Admin Commands (in Studio)
- [ ] /help shows command list
- [ ] /give adds currency
- [ ] /spawn creates objects
- [ ] /clear removes all objects
- [ ] /upgrade sets upgrade levels
- [ ] /tp teleports to spawn
- [ ] /stats shows game info

### Performance
- [ ] No lag with 50+ objects
- [ ] No errors in Output
- [ ] Memory usage stable
- [ ] Auto-save doesn't cause stutter

---

## Resolved Issues

All identified issues have been fixed in the codebase. The game should now:

✅ Run without errors
✅ Handle edge cases gracefully
✅ Provide clear error messages
✅ Work reliably in all scenarios
✅ Save data safely
✅ Display admin messages correctly

---

## If You Encounter New Issues

1. **Check Output Window** - Look for error messages (red text)
2. **Verify File Locations** - Ensure scripts are in correct services
3. **Check Script Types** - ModuleScript vs Script vs LocalScript
4. **Test in Studio First** - Debug before publishing
5. **Review Setup Guide** - Follow SETUP_GUIDE.md exactly

---

## Common Setup Mistakes

❌ **Wrong Script Type**
- `init.server.lua` must be a **Script** (not LocalScript)
- `.lua` files in ServerScriptService must be **ModuleScript**
- `.lua` files in StarterGui must be **LocalScript**

❌ **Missing Remotes**
- Remotes are created automatically by `init.server.lua`
- Don't manually create remotes in ReplicatedStorage

❌ **Script Disabled**
- Make sure no scripts have "Disabled" checked
- Verify in Properties panel

❌ **Wrong Parent**
- Config.lua goes in ReplicatedStorage (not ServerScriptService)
- UI scripts go in StarterGui (not PlayerGui)

---

## Debug Tips

**Enable Verbose Logging:**
Add this to top of `init.server.lua`:
```lua
local DEBUG = true
```

**Check Player Data:**
Use admin command:
```
/stats
```

**Test Specific Features:**
```
/give 10000      -- Test shop with lots of currency
/spawn Goblin 50 -- Test performance with many objects
/upgrade PushForce 10 -- Test max level upgrades
```

**Monitor Performance:**
Press F9 in Studio → Developer Console → Performance Stats

---

## Reporting New Issues

If you find a new issue:

1. Note what you were doing when it happened
2. Check Output window for errors
3. Try to reproduce it
4. Document the steps
5. Check if it happens in Studio vs Published game

---

**Last Updated:** 2025-12-18
**Version:** 1.0
**Status:** All Known Issues Resolved ✅
