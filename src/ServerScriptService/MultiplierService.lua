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

	if gateConfig.Type == "Multiply" then
		self:MultiplyObject(hit, effectiveValue)
	elseif gateConfig.Type == "Add" then
		self:AddObjects(hit, effectiveValue)
	end

	-- Visual feedback
	self:PlayGateEffect(gate)

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
end

-- Add new objects at the gate position
function MultiplierService:AddObjects(referenceObject, count)
	local objectType = referenceObject:FindFirstChild("ObjectType")
	if not objectType then return end

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

-- Generate gates along a path
function MultiplierService:GenerateGatesOnPath(startPosition, pathLength)
	local gateCount = math.floor(pathLength / Config.Path.GateSpacing)

	for i = 1, gateCount do
		-- Pick a random multiplier configuration
		local gateConfig = Config.Multipliers[math.random(1, #Config.Multipliers)]

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
