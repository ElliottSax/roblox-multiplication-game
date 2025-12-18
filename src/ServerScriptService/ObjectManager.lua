-- ObjectManager.lua
-- Manages spawning, cloning, and lifecycle of game objects

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local ObjectManager = {}
ObjectManager.ActiveObjects = {}
ObjectManager.ObjectCount = 0

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
	object.Material = Enum.Material.SmoothPlastic
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.CanCollide = true
	object.Anchored = false

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
	billboardGui.Size = UDim2.new(0, 50, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = object

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = objectConfig.Name
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui

	return object
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
