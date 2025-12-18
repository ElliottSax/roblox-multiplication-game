-- PathManager.lua
-- Manages the runway/path system and object movement

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ObjectManager = require(script.Parent:WaitForChild("ObjectManager"))
local CurrencyService = require(script.Parent:WaitForChild("CurrencyService"))

local PathManager = {}
PathManager.PathParts = {}

-- Create the main runway/path
function PathManager:CreatePath(startPosition)
	local path = Instance.new("Folder")
	path.Name = "GamePath"
	path.Parent = workspace

	-- Create starting platform (spawn area)
	local spawnPlatform = Instance.new("Part")
	spawnPlatform.Name = "SpawnPlatform"
	spawnPlatform.Size = Vector3.new(Config.Path.Width, 1, 20)
	spawnPlatform.Position = startPosition
	spawnPlatform.Anchored = true
	spawnPlatform.Color = Color3.fromRGB(100, 100, 100)
	spawnPlatform.Material = Enum.Material.Concrete
	spawnPlatform.Parent = path

	-- Create the main runway
	local runway = Instance.new("Part")
	runway.Name = "Runway"
	runway.Size = Vector3.new(Config.Path.Width, 1, Config.Path.Length)
	runway.Position = startPosition + Vector3.new(0, 0, -Config.Path.Length/2 - 10)
	runway.Anchored = true
	runway.Color = Color3.fromRGB(150, 150, 150)
	runway.Material = Enum.Material.Asphalt
	runway.Parent = path

	-- Add lane markers
	for i = 1, 3 do
		local marker = Instance.new("Part")
		marker.Name = "LaneMarker"
		marker.Size = Vector3.new(0.5, 0.2, Config.Path.Length)
		marker.Position = runway.Position + Vector3.new(i * 5 - 7.5, 0.6, 0)
		marker.Anchored = true
		marker.Color = Color3.fromRGB(255, 255, 255)
		marker.Material = Enum.Material.Neon
		marker.Parent = path
	end

	-- Create collection zone at the end
	local collectionZone = Instance.new("Part")
	collectionZone.Name = "CollectionZone"
	collectionZone.Size = Vector3.new(Config.Path.Width, 5, 10)
	collectionZone.Position = startPosition + Vector3.new(0, 2, -Config.Path.Length - 20)
	collectionZone.Anchored = true
	collectionZone.CanCollide = false
	collectionZone.Transparency = 0.5
	collectionZone.Color = Color3.fromRGB(0, 255, 0)
	collectionZone.Material = Enum.Material.Neon
	collectionZone.Parent = path

	-- Add collection text
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 100)
	billboardGui.StudsOffset = Vector3.new(0, 5, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = collectionZone

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "COLLECTION ZONE"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = billboardGui

	-- Set up collection zone touch detection
	collectionZone.Touched:Connect(function(hit)
		self:OnObjectCollected(hit)
	end)

	-- Create walls to keep objects on path
	self:CreatePathWalls(path, startPosition)

	table.insert(self.PathParts, path)
	return path, spawnPlatform
end

-- Create walls along the path
function PathManager:CreatePathWalls(path, startPosition)
	local wallHeight = 5
	local wallThickness = 1

	-- Left wall
	local leftWall = Instance.new("Part")
	leftWall.Name = "LeftWall"
	leftWall.Size = Vector3.new(wallThickness, wallHeight, Config.Path.Length + 40)
	leftWall.Position = startPosition + Vector3.new(-Config.Path.Width/2 - wallThickness/2, wallHeight/2, -Config.Path.Length/2 - 10)
	leftWall.Anchored = true
	leftWall.Transparency = 0.7
	leftWall.Color = Color3.fromRGB(100, 100, 100)
	leftWall.Material = Enum.Material.Glass
	leftWall.Parent = path

	-- Right wall
	local rightWall = leftWall:Clone()
	rightWall.Name = "RightWall"
	rightWall.Position = startPosition + Vector3.new(Config.Path.Width/2 + wallThickness/2, wallHeight/2, -Config.Path.Length/2 - 10)
	rightWall.Parent = path
end

-- Handle object collection
function PathManager:OnObjectCollected(hit)
	local objectType = hit:FindFirstChild("ObjectType")
	local objectValue = hit:FindFirstChild("ObjectValue")

	if not objectType or not objectValue then
		return -- Not a game object
	end

	-- Find the nearest player to give credit
	local nearestPlayer = self:FindNearestPlayer(hit.Position)
	if nearestPlayer then
		CurrencyService:CollectObject(nearestPlayer, hit)
	else
		-- No player nearby, just remove the object
		ObjectManager:RemoveObject(hit)
	end
end

-- Find the nearest player to a position
function PathManager:FindNearestPlayer(position)
	local Players = game:GetService("Players")
	local nearestPlayer = nil
	local shortestDistance = math.huge

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

-- Apply push force to objects near player
function PathManager:EnableObjectPushing()
	local Players = game:GetService("Players")

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

			-- Create a push zone around the player
			local pushZone = Instance.new("Part")
			pushZone.Name = "PushZone"
			pushZone.Size = Vector3.new(8, 8, 8)
			pushZone.Transparency = 1
			pushZone.CanCollide = false
			pushZone.Anchored = false
			pushZone.Parent = character

			-- Weld to player
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = humanoidRootPart
			weld.Part1 = pushZone
			weld.Parent = pushZone

			-- Apply force to objects in push zone
			pushZone.Touched:Connect(function(hit)
				local objectType = hit:FindFirstChild("ObjectType")
				if objectType and hit:IsA("BasePart") and not hit.Anchored then
					-- Apply forward push force
					local pushDirection = humanoidRootPart.CFrame.LookVector
					local bodyVelocity = hit:FindFirstChild("BodyVelocity")

					if not bodyVelocity then
						bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = Vector3.new(50000, 0, 50000)
						bodyVelocity.Parent = hit
					end

					bodyVelocity.Velocity = pushDirection * Config.Physics.PushForce
				end
			end)
		end)
	end)
end

-- Clear all path parts
function PathManager:ClearPath()
	for _, pathPart in ipairs(self.PathParts) do
		if pathPart and pathPart.Parent then
			pathPart:Destroy()
		end
	end
	self.PathParts = {}
end

return PathManager
