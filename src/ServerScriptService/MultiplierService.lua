-- MultiplierService.lua
-- Handles multiplier gates that clone/add objects when they pass through

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ObjectManager = require(script.Parent:WaitForChild("ObjectManager"))

local MultiplierService = {}
MultiplierService.Gates = {}
MultiplierService.ProcessedObjects = {} -- Track objects to prevent double-processing
MultiplierService.ComboService = nil -- Will be set by init script
MultiplierService.AchievementService = nil -- Will be set by init script
MultiplierService.SoundService = nil -- Will be set by init script

-- Create a multiplier gate in the world
function MultiplierService:CreateGate(gateConfig, position)
	-- Create gate frame
	local gate = Instance.new("Part")
	gate.Name = "MultiplierGate"
	gate.Size = Vector3.new(Config.Path.Width, 8, 1)
	gate.Position = position
	gate.Anchored = true
	gate.CanCollide = false
	gate.Transparency = 0.5
	gate.Color = gateConfig.Color
	gate.Material = Enum.Material.Neon
	gate.Parent = workspace

	-- Add gate configuration
	local gateType = Instance.new("StringValue")
	gateType.Name = "GateType"
	gateType.Value = gateConfig.Type
	gateType.Parent = gate

	local gateValue = Instance.new("IntValue")
	gateValue.Name = "GateValue"
	gateValue.Value = gateConfig.Value
	gateValue.Parent = gate

	-- Create visual text
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 100)
	billboardGui.StudsOffset = Vector3.new(0, 0, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = gate

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = gateConfig.Text
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = billboardGui

	-- Add particle effect
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(gateConfig.Color)
	particleEmitter.Size = NumberSequence.new(0.5)
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Lifetime = NumberRange.new(1, 2)
	particleEmitter.Rate = 20
	particleEmitter.Speed = NumberRange.new(2, 4)
	particleEmitter.Parent = gate

	-- Set up touch detection
	gate.Touched:Connect(function(hit)
		self:OnObjectTouched(gate, hit, gateConfig)
	end)

	table.insert(self.Gates, gate)
	return gate
end

-- Handle when an object touches a gate
function MultiplierService:OnObjectTouched(gate, hit, gateConfig)
	-- Check if the hit part is a game object
	local objectType = hit:FindFirstChild("ObjectType")
	local objectValue = hit:FindFirstChild("ObjectValue")

	if not objectType or not objectValue then
		return -- Not a game object
	end

	-- Prevent processing the same object multiple times on same gate
	local objectId = hit:GetDebugId()
	local gateId = gate:GetDebugId()
	local key = objectId .. "_" .. gateId

	if self.ProcessedObjects[key] then
		return -- Already processed this object through this gate
	end

	self.ProcessedObjects[key] = true

	-- Find nearest player for combo tracking
	local nearestPlayer = self:FindNearestPlayer(hit.Position)
	local comboMultiplier = 1.0

	-- Register combo hit if we have ComboService
	if nearestPlayer and self.ComboService then
		comboMultiplier = self.ComboService:RegisterGateHit(nearestPlayer, hit)

		-- Send combo update to client
		local comboUpdate = ReplicatedStorage:FindFirstChild("ComboUpdate")
		if comboUpdate then
			local comboInfo = self.ComboService:GetComboInfo(nearestPlayer)
			comboUpdate:FireClient(nearestPlayer, {
				Count = comboInfo.Count,
				Multiplier = comboMultiplier
			})
		end
	end

	-- Apply the multiplier effect (with combo bonus)
	local effectiveValue = math.floor(gateConfig.Value * comboMultiplier)
	local totalObjectsCreated = 0

	if gateConfig.Type == "Multiply" then
		totalObjectsCreated = self:MultiplyObject(hit, effectiveValue)
	elseif gateConfig.Type == "Add" then
		totalObjectsCreated = self:AddObjects(hit, effectiveValue)
	elseif gateConfig.Type == "Subtract" then
		totalObjectsCreated = self:SubtractObjects(hit, gateConfig.Value, gateConfig.ValueMultiplier or 1)
	elseif gateConfig.Type == "Divide" then
		totalObjectsCreated = self:DivideObjects(hit, effectiveValue, gateConfig.ValueMultiplier or 1)
	elseif gateConfig.Type == "Random" then
		totalObjectsCreated = self:RandomEffect(hit, comboMultiplier)
	elseif gateConfig.Type == "Power" then
		totalObjectsCreated = self:PowerObject(hit, effectiveValue)
	end

	-- Track single multiply achievement stat
	if totalObjectsCreated > 0 and nearestPlayer and self.AchievementService then
		self.AchievementService:UpdateStat(nearestPlayer, "SingleMultiply", totalObjectsCreated, true)
	end

	-- Visual and audio feedback
	self:PlayGateEffect(gate)
	if self.SoundService then
		self.SoundService:PlayGateSound(gateConfig.Type, gate.Position)
	end

	-- Clean up processed objects tracking after some time
	task.delay(5, function()
		self.ProcessedObjects[key] = nil
	end)
end

-- Multiply an object by cloning it
function MultiplierService:MultiplyObject(object, multiplier)
	local clones = ObjectManager:CloneObject(object, multiplier)

	-- Apply forward velocity to clones so they continue moving
	for _, clone in ipairs(clones) do
		if clone:IsA("BasePart") then
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new(0, 0, -Config.Physics.PathSpeed)
			bodyVelocity.MaxForce = Vector3.new(0, 0, 50000)
			bodyVelocity.Parent = clone

			-- Remove velocity after a short time
			task.delay(2, function()
				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity:Destroy()
				end
			end)
		end
	end

	print(string.format("Multiplied %s by %d (created %d clones)", object.Name, multiplier, #clones))
	return #clones
end

-- Add new objects at the gate position
function MultiplierService:AddObjects(referenceObject, count)
	local objectType = referenceObject:FindFirstChild("ObjectType")
	if not objectType then return 0 end

	local position = referenceObject.Position
	local newObjects = ObjectManager:AddObjects(objectType.Value, position, count)

	-- Apply forward velocity to new objects
	for _, object in ipairs(newObjects) do
		if object:IsA("BasePart") then
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new(0, 0, -Config.Physics.PathSpeed)
			bodyVelocity.MaxForce = Vector3.new(0, 0, 50000)
			bodyVelocity.Parent = object

			task.delay(2, function()
				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity:Destroy()
				end
			end)
		end
	end

	print(string.format("Added %d new %s objects", count, referenceObject.Name))
	return #newObjects
end

-- Subtract objects (remove percentage but increase remaining value)
function MultiplierService:SubtractObjects(referenceObject, percentage, valueMultiplier)
	-- Find all nearby objects of same type
	local objectType = referenceObject:FindFirstChild("ObjectType")
	if not objectType then return 0 end

	-- Get all game objects
	local objectsToRemove = {}
	local objectsToKeep = {}

	for _, obj in pairs(workspace:GetChildren()) do
		if obj:FindFirstChild("ObjectType") and obj:FindFirstChild("ObjectType").Value == objectType.Value then
			local distance = (obj.Position - referenceObject.Position).Magnitude
			if distance < 20 then -- Within 20 studs
				table.insert(objectsToRemove, obj)
			end
		end
	end

	-- Calculate how many to remove
	local removeCount = math.floor(#objectsToRemove * (percentage / 100))
	local keepCount = #objectsToRemove - removeCount

	-- Shuffle and remove
	for i = #objectsToRemove, 2, -1 do
		local j = math.random(i)
		objectsToRemove[i], objectsToRemove[j] = objectsToRemove[j], objectsToRemove[i]
	end

	for i = 1, removeCount do
		if objectsToRemove[i] and objectsToRemove[i].Parent then
			objectsToRemove[i]:Destroy()
		end
	end

	-- Increase value of remaining objects
	for i = removeCount + 1, #objectsToRemove do
		local obj = objectsToRemove[i]
		if obj and obj.Parent then
			local objValue = obj:FindFirstChild("ObjectValue")
			if objValue then
				objValue.Value = math.floor(objValue.Value * valueMultiplier)
			end
		end
	end

	print(string.format("Subtracted %d objects (-%d%%), remaining value x%.1f", removeCount, percentage, valueMultiplier))
	return keepCount
end

-- Divide objects (reduce count but multiply value)
function MultiplierService:DivideObjects(referenceObject, divisor, valueMultiplier)
	local objectType = referenceObject:FindFirstChild("ObjectType")
	if not objectType then return 0 end

	-- Find nearby objects
	local nearbyObjects = {}
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:FindFirstChild("ObjectType") and obj:FindFirstChild("ObjectType").Value == objectType.Value then
			local distance = (obj.Position - referenceObject.Position).Magnitude
			if distance < 20 then
				table.insert(nearbyObjects, obj)
			end
		end
	end

	-- Keep only 1/divisor of objects
	local keepCount = math.max(1, math.floor(#nearbyObjects / divisor))
	local removeCount = #nearbyObjects - keepCount

	-- Shuffle
	for i = #nearbyObjects, 2, -1 do
		local j = math.random(i)
		nearbyObjects[i], nearbyObjects[j] = nearbyObjects[j], nearbyObjects[i]
	end

	-- Remove excess and boost value of kept objects
	for i = 1, removeCount do
		if nearbyObjects[i] and nearbyObjects[i].Parent then
			nearbyObjects[i]:Destroy()
		end
	end

	for i = removeCount + 1, #nearbyObjects do
		local obj = nearbyObjects[i]
		if obj and obj.Parent then
			local objValue = obj:FindFirstChild("ObjectValue")
			if objValue then
				objValue.Value = math.floor(objValue.Value * valueMultiplier)
			end
		end
	end

	print(string.format("Divided by %d (kept %d, value x%.1f)", divisor, keepCount, valueMultiplier))
	return keepCount
end

-- Random effect gate
function MultiplierService:RandomEffect(referenceObject, comboMultiplier)
	local effects = {
		{Type = "Multiply", Value = math.random(2, 10), Chance = 30},
		{Type = "Add", Value = math.random(5, 25), Chance = 30},
		{Type = "Jackpot", Value = math.random(10, 50), Chance = 10}, -- Massive multiply!
		{Type = "Nothing", Value = 0, Chance = 15},
		{Type = "ValueBoost", Value = math.random(2, 5), Chance = 15},
	}

	-- Pick random effect based on weights
	local totalWeight = 0
	for _, effect in ipairs(effects) do
		totalWeight = totalWeight + effect.Chance
	end

	local roll = math.random(1, totalWeight)
	local cumulative = 0
	local selectedEffect = effects[1]

	for _, effect in ipairs(effects) do
		cumulative = cumulative + effect.Chance
		if roll <= cumulative then
			selectedEffect = effect
			break
		end
	end

	-- Apply the effect
	local effectiveValue = math.floor(selectedEffect.Value * comboMultiplier)

	if selectedEffect.Type == "Multiply" then
		print(string.format("Random: Lucky x%d multiply!", effectiveValue))
		return self:MultiplyObject(referenceObject, effectiveValue)
	elseif selectedEffect.Type == "Add" then
		print(string.format("Random: +%d objects!", effectiveValue))
		return self:AddObjects(referenceObject, effectiveValue)
	elseif selectedEffect.Type == "Jackpot" then
		print(string.format("Random: JACKPOT! x%d multiply!", effectiveValue))
		return self:MultiplyObject(referenceObject, effectiveValue)
	elseif selectedEffect.Type == "ValueBoost" then
		-- Boost value of this object
		local objValue = referenceObject:FindFirstChild("ObjectValue")
		if objValue then
			objValue.Value = objValue.Value * effectiveValue
			print(string.format("Random: Value boost x%d!", effectiveValue))
		end
		return 1
	else
		print("Random: Nothing happened...")
		return 0
	end
end

-- Power effect (square the count)
function MultiplierService:PowerObject(object, power)
	-- Count nearby objects
	local objectType = object:FindFirstChild("ObjectType")
	if not objectType then return 0 end

	local nearbyCount = 0
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:FindFirstChild("ObjectType") and obj:FindFirstChild("ObjectType").Value == objectType.Value then
			local distance = (obj.Position - object.Position).Magnitude
			if distance < 25 then
				nearbyCount = nearbyCount + 1
			end
		end
	end

	-- Square it (capped at 100 to prevent lag)
	local targetCount = math.min(nearbyCount ^ power, 100)
	local toCreate = math.max(0, targetCount - nearbyCount)

	if toCreate > 0 then
		local clones = ObjectManager:CloneObject(object, toCreate)

		for _, clone in ipairs(clones) do
			if clone:IsA("BasePart") then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new(0, 0, -Config.Physics.PathSpeed)
				bodyVelocity.MaxForce = Vector3.new(0, 0, 50000)
				bodyVelocity.Parent = clone

				task.delay(2, function()
					if bodyVelocity and bodyVelocity.Parent then
						bodyVelocity:Destroy()
					end
				end)
			end
		end

		print(string.format("Power gate: %d^%d = %d (created %d)", nearbyCount, power, targetCount, toCreate))
		return toCreate
	end

	return 0
end

-- Visual effect when gate is activated
function MultiplierService:PlayGateEffect(gate)
	local originalTransparency = gate.Transparency

	-- Flash effect
	gate.Transparency = 0.2
	task.wait(0.1)
	gate.Transparency = originalTransparency

	-- Boost particle emission
	local emitter = gate:FindFirstChild("ParticleEmitter")
	if emitter then
		emitter.Rate = 100
		task.wait(0.5)
		emitter.Rate = 20
	end
end

-- Pick a weighted random gate configuration
function MultiplierService:PickWeightedGate()
	-- Calculate total weight
	local totalWeight = 0
	for _, config in ipairs(Config.Multipliers) do
		totalWeight = totalWeight + (config.Weight or 10)
	end

	-- Pick random based on weight
	local roll = math.random(1, totalWeight)
	local cumulative = 0

	for _, config in ipairs(Config.Multipliers) do
		cumulative = cumulative + (config.Weight or 10)
		if roll <= cumulative then
			return config
		end
	end

	-- Fallback to first
	return Config.Multipliers[1]
end

-- Generate gates along a path
function MultiplierService:GenerateGatesOnPath(startPosition, pathLength)
	local gateCount = math.floor(pathLength / Config.Path.GateSpacing)

	for i = 1, gateCount do
		-- Pick a weighted random multiplier configuration
		local gateConfig = self:PickWeightedGate()

		-- Calculate gate position along the path
		local zPosition = startPosition.Z - (i * Config.Path.GateSpacing)
		local position = Vector3.new(startPosition.X, startPosition.Y + 4, zPosition)

		self:CreateGate(gateConfig, position)
	end

	print(string.format("Generated %d multiplier gates", gateCount))
end

-- Find the nearest player to a position
function MultiplierService:FindNearestPlayer(position)
	local nearestPlayer = nil
	local shortestDistance = 100 -- Max distance to count

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - position).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				nearestPlayer = player
			end
		end
	end

	return nearestPlayer
end

-- Clear all gates
function MultiplierService:ClearAllGates()
	for _, gate in ipairs(self.Gates) do
		if gate and gate.Parent then
			gate:Destroy()
		end
	end
	self.Gates = {}
	self.ProcessedObjects = {}
end

return MultiplierService
