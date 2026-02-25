# Critical Fixes & Improvements - Priority List

**Review Date:** 2026-02-22
**Status:** Action Required Before Production Publish

---

## 🔴 CRITICAL (Fix Before Publishing)

### 1. Rate Limiting on Remote Events
**Risk:** Exploit vulnerability - players could spam remotes
**Impact:** Server performance degradation, potential exploits
**Effort:** 30 minutes

**Implementation:**
```lua
-- Add to init.server.lua at the top

local RateLimiter = {}
local RATE_LIMIT = 10 -- requests per second per player

local function CheckRateLimit(player, remoteName)
    local key = player.UserId .. "_" .. remoteName
    local now = tick()

    if not RateLimiter[key] then
        RateLimiter[key] = {count = 1, resetTime = now + 1}
        return true
    end

    if now >= RateLimiter[key].resetTime then
        RateLimiter[key] = {count = 1, resetTime = now + 1}
        return true
    end

    RateLimiter[key].count = RateLimiter[key].count + 1
    if RateLimiter[key].count > RATE_LIMIT then
        warn(string.format("[Security] %s rate limited on %s", player.Name, remoteName))
        return false
    end

    return true
end

-- Then wrap each remote handler:
purchaseUpgrade.OnServerInvoke = function(player, upgradeName)
    if not CheckRateLimit(player, "PurchaseUpgrade") then
        return {Success = false, Message = "Too many requests. Please slow down."}
    end

    local success, result = pcall(function()
        local purchaseSuccess, message = UpgradeService:PurchaseUpgrade(player, upgradeName)
        return {Success = purchaseSuccess, Message = message}
    end)

    if success then
        return result
    else
        warn("PurchaseUpgrade error:", result)
        return {Success = false, Message = "Server error"}
    end
end

-- Apply to ALL remote handlers: GetUpgrades, GetAchievements, GetLeaderboard, etc.
```

**Files to Modify:**
- `src/ServerScriptService/init.server.lua`

---

### 2. Remove Studio Auto-Admin Access
**Risk:** Security hole in production
**Impact:** Anyone could be admin
**Effort:** 2 minutes

**Implementation:**
```lua
-- In AdminCommands.lua
AdminCommands.AdminIds = {
    123456789,  -- Replace with YOUR actual Roblox UserId
    -- Add other trusted admin UserIds here
}

-- IMPORTANT: Remove this section for production
function AdminCommands:IsAdmin(player)
    -- Check if player is in admin list
    for _, adminId in ipairs(self.AdminIds) do
        if player.UserId == adminId then
            return true
        end
    end

    -- REMOVE THIS SECTION BEFORE PUBLISHING TO PRODUCTION
    -- Only allow in Studio for testing
    if game:GetService("RunService"):IsStudio() then
        return true
    end

    return false
end
```

**Better Production Version:**
```lua
function AdminCommands:IsAdmin(player)
    for _, adminId in ipairs(self.AdminIds) do
        if player.UserId == adminId then
            return true
        end
    end
    return false
end
```

**Files to Modify:**
- `src/ServerScriptService/AdminCommands.lua`

**How to Find Your UserId:**
1. Go to roblox.com
2. Log in to your account
3. Look at your profile URL: `https://www.roblox.com/users/123456789/profile`
4. The number is your UserId

---

### 3. Use UpdateAsync for DataStore Saves
**Risk:** Data loss in concurrent scenarios
**Impact:** Player progress could be lost
**Effort:** 15 minutes

**Implementation:**
```lua
-- In DataService.lua, replace SaveData function:

function DataService:SaveData(player)
    local userId = player.UserId
    local data = self.SessionData[userId]

    if not data then
        warn("No session data found for " .. player.Name)
        return false
    end

    data.Stats.LastPlayed = os.time()

    -- Try to save data with retry logic
    local success, error
    for attempt = 1, 3 do
        success, error = pcall(function()
            -- Use UpdateAsync instead of SetAsync for safer concurrent writes
            self.PlayerDataStore:UpdateAsync("Player_" .. userId, function(oldData)
                -- Merge with existing data to prevent data loss
                if oldData and type(oldData) == "table" then
                    -- Preserve any data that might have been written by another server
                    -- while keeping our session data as authoritative
                    for key, value in pairs(oldData) do
                        if data[key] == nil and key ~= "Stats" then
                            -- Keep data that doesn't exist in our session
                            data[key] = value
                        end
                    end

                    -- Merge stats carefully
                    if oldData.Stats and data.Stats then
                        -- Keep higher values for cumulative stats
                        data.Stats.PlayTime = math.max(oldData.Stats.PlayTime or 0, data.Stats.PlayTime or 0)
                        data.Stats.TotalObjectsSpawned = math.max(
                            oldData.Stats.TotalObjectsSpawned or 0,
                            data.Stats.TotalObjectsSpawned or 0
                        )
                    end
                end

                return data
            end)
        end)

        if success then
            print(string.format("Saved data for %s", player.Name))
            return true
        end

        warn(string.format("Save attempt %d failed for %s: %s", attempt, player.Name, tostring(error)))
        task.wait(1)
    end

    warn(string.format("Failed to save data for %s after 3 attempts", player.Name))
    return false
end
```

**Files to Modify:**
- `src/ServerScriptService/DataService.lua`

---

## 🟠 HIGH PRIORITY (Fix Within Week)

### 4. Add Data Versioning
**Benefit:** Future-proof data migration
**Impact:** Easier to add new features
**Effort:** 20 minutes

**Implementation:**
```lua
-- In DataService.lua

local DATA_VERSION = 2  -- Increment when structure changes

local function GetDefaultData()
    return {
        Version = DATA_VERSION,
        Currency = 0,
        ObjectsCollected = 0,
        TotalValue = 0,
        Upgrades = {},
        Achievements = {},
        Rebirth = {},
        Quests = {},
        Pets = {},
        Stats = {
            PlayTime = 0,
            HighestMultiplier = 0,
            TotalObjectsSpawned = 0,
            LastPlayed = os.time()
        }
    }
end

function DataService:MigrateData(playerData)
    local version = playerData.Version or 1

    if version < 2 then
        print("Migrating player data from v1 to v2")
        -- Add new fields that didn't exist in v1
        playerData.Rebirth = playerData.Rebirth or {}
        playerData.Quests = playerData.Quests or {}
        playerData.Pets = playerData.Pets or {}
        playerData.Achievements = playerData.Achievements or {}
        playerData.Version = 2
    end

    -- Future migrations would go here
    -- if version < 3 then
    --     -- Migrate to v3
    -- end

    return playerData
end

function DataService:LoadData(player)
    local userId = player.UserId
    local success, data

    -- Try to load data with retry logic
    for attempt = 1, 3 do
        success, data = pcall(function()
            return self.PlayerDataStore:GetAsync("Player_" .. userId)
        end)

        if success then break end
        wait(1)
    end

    if not success then
        warn(string.format("Failed to load data for %s: %s", player.Name, tostring(data)))
        data = nil
    end

    -- Use default data if load failed or no data exists
    local playerData = data or GetDefaultData()

    -- Validate data structure
    if type(playerData) ~= "table" then
        warn("Invalid data type loaded, using defaults")
        playerData = GetDefaultData()
    end

    -- MIGRATE DATA HERE
    playerData = self:MigrateData(playerData)

    -- Ensure all fields exist (in case new fields were added)
    local defaultData = GetDefaultData()
    for key, value in pairs(defaultData) do
        if playerData[key] == nil then
            playerData[key] = value
        end
    end

    -- Validate data types
    if type(playerData.Currency) ~= "number" then playerData.Currency = 0 end
    if type(playerData.ObjectsCollected) ~= "number" then playerData.ObjectsCollected = 0 end
    if type(playerData.TotalValue) ~= "number" then playerData.TotalValue = 0 end
    if type(playerData.Upgrades) ~= "table" then playerData.Upgrades = {} end
    if type(playerData.Stats) ~= "table" then playerData.Stats = defaultData.Stats end

    -- Store in session
    self.SessionData[userId] = playerData

    print(string.format("Loaded data for %s (v%d): %d currency, %d objects collected",
        player.Name, playerData.Version, playerData.Currency, playerData.ObjectsCollected))

    return playerData
end
```

**Files to Modify:**
- `src/ServerScriptService/DataService.lua`

---

### 5. Object Pooling for Performance
**Benefit:** Major performance improvement
**Impact:** Less lag with many objects
**Effort:** 45 minutes

**Implementation:**
```lua
-- In ObjectManager.lua, add at top:

ObjectManager.ObjectPool = {}
ObjectManager.PoolSizePerType = 20

function ObjectManager:InitializePool()
    print("Initializing object pool...")
    for objectType, _ in pairs(Config.Objects) do
        self.ObjectPool[objectType] = {}
        for i = 1, self.PoolSizePerType do
            local obj = self:CreateObjectTemplate(objectType)
            obj.Parent = nil
            table.insert(self.ObjectPool[objectType], obj)
        end
    end
    print("Object pool initialized")
end

function ObjectManager:GetFromPool(objectType)
    -- Check if pool exists for this type
    if not self.ObjectPool[objectType] then
        self.ObjectPool[objectType] = {}
    end

    -- Try to reuse from pool
    if #self.ObjectPool[objectType] > 0 then
        local obj = table.remove(self.ObjectPool[objectType])
        return obj
    end

    -- Create new if pool empty
    return self:CreateObjectTemplate(objectType)
end

function ObjectManager:ReturnToPool(object)
    local objectType = object:FindFirstChild("ObjectType")
    if not objectType then return end

    local typeName = objectType.Value

    -- Ensure pool exists
    if not self.ObjectPool[typeName] then
        self.ObjectPool[typeName] = {}
    end

    -- Return to pool if not full
    if #self.ObjectPool[typeName] < self.PoolSizePerType then
        object.Parent = nil
        object.Position = Vector3.new(0, -1000, 0)  -- Move far away

        -- Reset velocity
        local bodyVelocity = object:FindFirstChild("BodyVelocity")
        if bodyVelocity then
            bodyVelocity:Destroy()
        end

        table.insert(self.ObjectPool[typeName], object)
    else
        -- Pool is full, destroy
        object:Destroy()
    end
end

-- Modify SpawnObject to use pool:
function ObjectManager:SpawnObject(objectType, position)
    local template = self:GetFromPool(objectType)  -- Changed from CreateObjectTemplate
    if not template then return nil end

    -- Validate position
    if not position or typeof(position) ~= "Vector3" then
        warn("Invalid position for object spawn")
        position = Vector3.new(0, 10, 0)
    end

    if position.Y < 5 then
        position = Vector3.new(position.X, 10, position.Z)
    end

    template.Position = position
    template.Parent = workspace

    -- Track the object
    self.ObjectCount += 1
    table.insert(self.ActiveObjects, template)

    -- Clean up if object falls off the map
    template.Touched:Connect(function(hit)
        if hit.Name == "KillBrick" or hit.Parent.Name == "KillBricks" then
            self:RemoveObject(object)
        end
    end)

    return template
end

-- Modify RemoveObject to use pool:
function ObjectManager:RemoveObject(object)
    if object and object.Parent then
        self:ReturnToPool(object)  -- Changed from object:Destroy()
        self.ObjectCount -= 1

        -- Remove from active objects list
        for i, obj in ipairs(self.ActiveObjects) do
            if obj == object then
                table.remove(self.ActiveObjects, i)
                break
            end
        end
    end
end
```

**Then in init.server.lua, add after creating ObjectManager:**
```lua
-- Initialize object pool
ObjectManager:InitializePool()
```

**Files to Modify:**
- `src/ServerScriptService/ObjectManager.lua`
- `src/ServerScriptService/init.server.lua`

---

### 6. Optimize FindNearestPlayer with Caching
**Benefit:** Reduce CPU usage
**Impact:** Better performance with many players
**Effort:** 20 minutes

**Implementation:**
```lua
-- In MultiplierService.lua, add at top:

MultiplierService.PlayerPositionCache = {}
MultiplierService.CacheUpdateInterval = 0.5

function MultiplierService:StartPlayerCacheUpdates()
    task.spawn(function()
        while true do
            self.PlayerPositionCache = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    self.PlayerPositionCache[player.UserId] = {
                        Player = player,
                        Position = player.Character.HumanoidRootPart.Position
                    }
                end
            end
            task.wait(self.CacheUpdateInterval)
        end
    end)
end

-- Replace FindNearestPlayer function:
function MultiplierService:FindNearestPlayer(position)
    local nearestPlayer = nil
    local shortestDistance = 100

    for userId, data in pairs(self.PlayerPositionCache) do
        local distance = (data.Position - position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            nearestPlayer = data.Player
        end
    end

    return nearestPlayer
end
```

**Then in init.server.lua, add after initializing services:**
```lua
-- Start player position caching
MultiplierService:StartPlayerCacheUpdates()
```

**Files to Modify:**
- `src/ServerScriptService/MultiplierService.lua`
- `src/ServerScriptService/init.server.lua`

---

## 🟢 MEDIUM PRIORITY (Nice to Have)

### 7. Create Shared Utility Modules
**Benefit:** Reduce code duplication
**Impact:** Easier maintenance
**Effort:** 30 minutes

Create `src/ReplicatedStorage/Shared/PlayerUtils.lua`:
```lua
local PlayerUtils = {}

function PlayerUtils:FindNearestPlayer(position, maxDistance)
    maxDistance = maxDistance or 100
    local Players = game:GetService("Players")
    local nearestPlayer = nil
    local shortestDistance = maxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end

    return nearestPlayer, shortestDistance
end

function PlayerUtils:GetPlayerPosition(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart.Position
    end
    return nil
end

return PlayerUtils
```

Create `src/ReplicatedStorage/Shared/FormatUtils.lua`:
```lua
local FormatUtils = {}

function FormatUtils:FormatNumber(num)
    if num >= 1000000000 then
        return string.format("%.1fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    end
    return tostring(math.floor(num))
end

function FormatUtils:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%d:%02d", minutes, secs)
    end
end

return FormatUtils
```

Then update services to use these utilities.

---

## 📋 Testing Checklist Before Publishing

After implementing critical fixes:

- [ ] Test rate limiting by rapidly clicking shop buttons
- [ ] Verify admin commands only work for whitelisted UserIds
- [ ] Test data saves/loads correctly 5 times in a row
- [ ] Create multiple concurrent players (use alt accounts)
- [ ] Verify no errors appear in Output window
- [ ] Test with 50+ objects spawned
- [ ] Verify memory usage stays under 100MB per player
- [ ] Test all shop purchases work correctly
- [ ] Test all admin commands work
- [ ] Verify combos work and reset properly
- [ ] Test DataStore saves on player leave
- [ ] Test graceful shutdown (stop server)

---

## 🚀 Deployment Steps

1. **Implement Critical Fixes** (Items 1-3)
2. **Test Thoroughly** (Complete testing checklist)
3. **Update Documentation** (Update README with any changes)
4. **Publish to Roblox** (Use Game Settings → Publish)
5. **Monitor** (Check Server Stats in Roblox Developer Portal)

---

## 📊 Performance Targets

After implementing all fixes:
- Server CPU: <15% with 20 players
- Memory: <80MB per player
- DataStore API calls: <100 per minute
- Average FPS: >30 for all players
- Network receive: <50 KB/s per player

---

**Status:** Ready to implement
**Total Implementation Time:** ~2.5 hours
**Priority Order:** 1 → 2 → 3 → 4 → 5 → 6 → 7

