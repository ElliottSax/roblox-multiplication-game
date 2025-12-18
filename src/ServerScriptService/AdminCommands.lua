-- AdminCommands.lua
-- Admin commands for testing and debugging

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ObjectManager = require(script.Parent:WaitForChild("ObjectManager"))
local CurrencyService = require(script.Parent:WaitForChild("CurrencyService"))
local UpgradeService = require(script.Parent:WaitForChild("UpgradeService"))

local AdminCommands = {}

-- List of admin user IDs (replace with your own)
AdminCommands.AdminIds = {
	-- Add your Roblox user ID here
	-- Example: 123456789,
}

-- Check if player is admin
function AdminCommands:IsAdmin(player)
	-- Check if player is in admin list
	for _, adminId in ipairs(self.AdminIds) do
		if player.UserId == adminId then
			return true
		end
	end

	-- Also allow in Studio for testing
	if game:GetService("RunService"):IsStudio() then
		return true
	end

	return false
end

-- Parse command and arguments
local function ParseCommand(message)
	local args = {}
	for word in message:gmatch("%S+") do
		table.insert(args, word)
	end
	return args
end

-- Command: Give currency
local function CommandGiveCurrency(player, amount)
	amount = tonumber(amount) or 1000
	CurrencyService:AddCurrency(player, amount)
	return string.format("Added %d currency", amount)
end

-- Command: Clear objects
local function CommandClearObjects(player)
	ObjectManager:ClearAllObjects()
	return "Cleared all objects"
end

-- Command: Spawn object
local function CommandSpawnObject(player, objectType, count)
	objectType = objectType or "Goblin"
	count = tonumber(count) or 1

	if not Config.Objects[objectType] then
		return "Invalid object type: " .. objectType
	end

	local character = player.Character
	if not character then return "Character not found" end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return "RootPart not found" end

	for i = 1, count do
		local offset = Vector3.new(
			math.random(-5, 5),
			2,
			math.random(-5, 5)
		)
		ObjectManager:SpawnObject(objectType, rootPart.Position + offset)
	end

	return string.format("Spawned %d %s(s)", count, objectType)
end

-- Command: Give upgrade
local function CommandGiveUpgrade(player, upgradeName, level)
	level = tonumber(level) or 1

	if not UpgradeService.Upgrades[upgradeName] then
		return "Invalid upgrade: " .. upgradeName
	end

	-- Set upgrade level directly
	if not UpgradeService.PlayerUpgrades[player.UserId] then
		UpgradeService:InitializePlayer(player)
	end

	UpgradeService.PlayerUpgrades[player.UserId][upgradeName] = level

	return string.format("Set %s to level %d", upgradeName, level)
end

-- Command: Teleport to spawn
local function CommandTeleportSpawn(player)
	local character = player.Character
	if not character then return "Character not found" end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return "RootPart not found" end

	rootPart.CFrame = CFrame.new(0, 10, 5)
	return "Teleported to spawn"
end

-- Command: Show stats
local function CommandShowStats(player)
	local currency = CurrencyService:GetCurrency(player)
	local objectCount = ObjectManager:GetObjectCount()

	local upgrades = UpgradeService.PlayerUpgrades[player.UserId]
	local upgradeCount = 0
	if upgrades then
		for _, level in pairs(upgrades) do
			upgradeCount += level
		end
	end

	return string.format(
		"Currency: %d | Active Objects: %d | Total Upgrades: %d",
		currency,
		objectCount,
		upgradeCount
	)
end

-- Command: Help
local function CommandHelp()
	return [[
Admin Commands:
/give [amount] - Give currency
/clear - Clear all objects
/spawn [type] [count] - Spawn objects
/upgrade [name] [level] - Set upgrade level
/tp - Teleport to spawn
/stats - Show game stats
/help - Show this message

Object types: Goblin, Treasure, Diamond
Upgrade names: PushForce, SpawnRate, AutoPush, CurrencyBonus, etc.
]]
end

-- Command registry
local Commands = {
	give = CommandGiveCurrency,
	clear = CommandClearObjects,
	spawn = CommandSpawnObject,
	upgrade = CommandGiveUpgrade,
	tp = CommandTeleportSpawn,
	stats = CommandShowStats,
	help = CommandHelp,
}

-- Process command
function AdminCommands:ProcessCommand(player, message)
	if not self:IsAdmin(player) then
		return false
	end

	-- Check if message is a command
	if not message:match("^/") then
		return false
	end

	-- Parse command
	local args = ParseCommand(message:sub(2)) -- Remove leading /
	local commandName = args[1]
	if not commandName then return false end

	commandName = commandName:lower()
	local command = Commands[commandName]

	if not command then
		return true -- Was a command, but invalid
	end

	-- Execute command
	local success, result = pcall(function()
		return command(player, unpack(args, 2))
	end)

	if success and result then
		-- Send result to player
		self:SendMessage(player, result)
	elseif not success then
		self:SendMessage(player, "Error: " .. tostring(result))
	end

	return true
end

-- Send message to player
function AdminCommands:SendMessage(player, message)
	-- Send via RemoteEvent to client
	local adminMessageRemote = game:GetService("ReplicatedStorage"):FindFirstChild("AdminMessage")
	if adminMessageRemote then
		adminMessageRemote:FireClient(player, message)
	else
		warn("AdminMessage remote not found")
	end
end

-- Initialize admin system
function AdminCommands:Initialize()
	-- Listen for player chat
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			self:ProcessCommand(player, message)
		end)
	end)

	print("Admin commands initialized")
end

return AdminCommands
