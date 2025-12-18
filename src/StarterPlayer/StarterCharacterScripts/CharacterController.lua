-- CharacterController.lua
-- Handles character-specific behavior and interactions

local player = game.Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Increase walk speed slightly for better gameplay
humanoid.WalkSpeed = 20

-- Add jump power boost
humanoid.JumpPower = 60

-- Optional: Add a visual effect to show push zone
local function CreatePushZoneVisual()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- Create a subtle indicator ring
	local pushIndicator = Instance.new("Part")
	pushIndicator.Name = "PushIndicator"
	pushIndicator.Shape = Enum.PartType.Cylinder
	pushIndicator.Size = Vector3.new(0.2, 8, 8)
	pushIndicator.Transparency = 0.8
	pushIndicator.Color = Color3.fromRGB(0, 255, 255)
	pushIndicator.Material = Enum.Material.Neon
	pushIndicator.CanCollide = false
	pushIndicator.Anchored = false
	pushIndicator.Parent = character

	-- Rotate cylinder to be horizontal
	pushIndicator.Orientation = Vector3.new(0, 0, 90)

	-- Weld to player
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = humanoidRootPart
	weld.Part1 = pushIndicator
	weld.Parent = pushIndicator

	-- Pulse effect
	task.spawn(function()
		while pushIndicator.Parent do
			for transparency = 0.8, 0.95, 0.05 do
				if not pushIndicator.Parent then break end
				pushIndicator.Transparency = transparency
				task.wait(0.1)
			end
			for transparency = 0.95, 0.8, -0.05 do
				if not pushIndicator.Parent then break end
				pushIndicator.Transparency = transparency
				task.wait(0.1)
			end
		end
	end)
end

-- Create the push zone visual
CreatePushZoneVisual()

print("Character controller loaded for", player.Name)
