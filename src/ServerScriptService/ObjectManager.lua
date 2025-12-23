-- ObjectManager.lua
-- Manages spawning, cloning, and lifecycle of game objects

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local ObjectManager = {}
ObjectManager.ActiveObjects = {}
ObjectManager.ObjectCount = 0

-- Get material from config or default
local function getMaterial(materialName)
	local materials = {
		SmoothPlastic = Enum.Material.SmoothPlastic,
		Metal = Enum.Material.Metal,
		Neon = Enum.Material.Neon,
		Glass = Enum.Material.Glass,
		Marble = Enum.Material.Marble,
		ForceField = Enum.Material.ForceField,
		Diamond = Enum.Material.DiamondPlate,
		Granite = Enum.Material.Granite,
		Ice = Enum.Material.Ice,
	}
	return materials[materialName] or Enum.Material.SmoothPlastic
end

-- Create a template object based on config
function ObjectManager:CreateObjectTemplate(objectType)
	local objectConfig = Config.Objects[objectType]
	if not objectConfig then
		warn("Unknown object type:", objectType)
		return nil
	end

	local object = Instance.new("Part")
	object.Name = objectConfig.Name
	object.Size = objectConfig.Size
	object.Color = objectConfig.Color
	object.Material = getMaterial(objectConfig.Material)
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.CanCollide = true
	object.Anchored = false

	-- Add special effects for high-value objects
	if objectConfig.Value >= 50 then
		-- Add glow effect
		local highlight = Instance.new("Highlight")
		highlight.FillColor = objectConfig.Color
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 0.7
		highlight.Parent = object
	end

	-- Add particle effects for very high value objects
	if objectConfig.Value >= 100 then
		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(objectConfig.Color)
		particles.Size = NumberSequence.new(0.3)
		particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particles.Lifetime = NumberRange.new(0.5, 1)
		particles.Rate = 10
		particles.Speed = NumberRange.new(1, 2)
		particles.Parent = object
	end

	-- Add custom properties
	local valueTag = Instance.new("IntValue")
	valueTag.Name = "ObjectValue"
	valueTag.Value = objectConfig.Value
	valueTag.Parent = object

	local typeTag = Instance.new("StringValue")
	typeTag.Name = "ObjectType"
	typeTag.Value = objectType
	typeTag.Parent = object

	-- Add visual identifier
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 80, 0, 40)
	billboardGui.StudsOffset = Vector3.new(0, objectConfig.Size.Y / 2 + 1.5, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = object

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = objectConfig.Name
	textLabel.TextColor3 = objectConfig.Color
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = billboardGui

	-- Show value on label for high value objects
	if objectConfig.Value >= 25 then
		local valueLabel = Instance.new("TextLabel")
		valueLabel.Size = UDim2.new(1, 0, 0.4, 0)
		valueLabel.Position = UDim2.new(0, 0, 0.7, 0)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = "$" .. objectConfig.Value
		valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		valueLabel.TextScaled = true
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.Parent = billboardGui
	end

	return object
end

-- Get available object types based on player progress
function ObjectManager:GetAvailableObjects(totalEarned)
	local available = {}

	for objectType, config in pairs(Config.Objects) do
		local requirement = config.UnlockRequirement or 0
		if totalEarned >= requirement then
			table.insert(available, {
				Type = objectType,
				Config = config,
				Weight = config.SpawnWeight or 10
			})
		end
	end

	return available
end

-- Pick a weighted random object type
function ObjectManager:PickWeightedObjectType(availableObjects)
	if #availableObjects == 0 then
		return "Goblin" -- Fallback
	end

	-- Calculate total weight
	local totalWeight = 0
	for _, obj in ipairs(availableObjects) do
		totalWeight = totalWeight + obj.Weight
	end

	-- Pick random
	local roll = math.random() * totalWeight
	local cumulative = 0

	for _, obj in ipairs(availableObjects) do
		cumulative = cumulative + obj.Weight
		if roll <= cumulative then
			return obj.Type
		end
	end

	return availableObjects[1].Type
end

-- Spawn a random object based on player progress
function ObjectManager:SpawnRandomObject(position, totalEarned)
	totalEarned = totalEarned or 0
	local available = self:GetAvailableObjects(totalEarned)
	local objectType = self:PickWeightedObjectType(available)
	return self:SpawnObject(objectType, position)
end

-- Spawn an object at a specific position
function ObjectManager:SpawnObject(objectType, position)
	local template = self:CreateObjectTemplate(objectType)
	if not template then return nil end

	-- Validate position
	if not position or typeof(position) ~= "Vector3" then
		warn("Invalid position for object spawn")
		position = Vector3.new(0, 10, 0) -- Default fallback
	end

	-- Ensure position is above ground
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
			self:RemoveObject(template)
		end
	end)

	return template
end

-- Clone/multiply an object
function ObjectManager:CloneObject(originalObject, count)
	local clones = {}
	local objectType = originalObject:FindFirstChild("ObjectType")

	if not objectType then
		warn("Object missing ObjectType tag")
		return clones
	end

	-- Create multiple clones
	for i = 1, count - 1 do -- count - 1 because original still exists
		local clone = originalObject:Clone()

		-- Offset position slightly to avoid overlap
		local offset = Vector3.new(
			math.random(-2, 2),
			0,
			math.random(-2, 2)
		)
		clone.Position = originalObject.Position + offset
		clone.Parent = workspace

		-- Track the clone
		self.ObjectCount += 1
		table.insert(self.ActiveObjects, clone)
		table.insert(clones, clone)
	end

	return clones
end

-- Add objects to existing count (for +5, +10 gates)
function ObjectManager:AddObjects(objectType, position, count)
	local newObjects = {}

	for i = 1, count do
		local offset = Vector3.new(
			math.random(-3, 3),
			0,
			math.random(-3, 3)
		)
		local object = self:SpawnObject(objectType, position + offset)
		if object then
			table.insert(newObjects, object)
		end
	end

	return newObjects
end

-- Remove an object from the game
function ObjectManager:RemoveObject(object)
	if object and object.Parent then
		object:Destroy()
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

-- Get total count of active objects
function ObjectManager:GetObjectCount()
	return self.ObjectCount
end

-- Clear all objects
function ObjectManager:ClearAllObjects()
	for _, object in ipairs(self.ActiveObjects) do
		if object and object.Parent then
			object:Destroy()
		end
	end
	self.ActiveObjects = {}
	self.ObjectCount = 0
end

return ObjectManager
