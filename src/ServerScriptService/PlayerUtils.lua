-- PlayerUtils.lua
-- Small shared helpers used by more than one service, kept here instead of
-- duplicated per-file (MultiplierService and PathManager each had their own
-- copy of FindNearestPlayer with the same loop and no way to keep them from
-- silently drifting apart).

local Players = game:GetService("Players")

local PlayerUtils = {}

-- Find the nearest player to a position, within maxDistance studs.
-- Callers pass their own radius: a tight one for "is a player standing right
-- at this gate", a generous one for "who gets credit for this collection".
function PlayerUtils.FindNearestPlayer(position, maxDistance)
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

	return nearestPlayer
end

return PlayerUtils
