-- AdminMessageHandler.lua
-- Receives admin messages from server and displays them

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- Wait for admin message remote
local adminMessageRemote = ReplicatedStorage:WaitForChild("AdminMessage", 30)

if not adminMessageRemote then
	warn("AdminMessage remote not found")
	return
end

-- Listen for admin messages
adminMessageRemote.OnClientEvent:Connect(function(message)
	-- Display in chat as system message
	local success, err = pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "[ADMIN] " .. message,
			Color = Color3.fromRGB(255, 200, 50),
			Font = Enum.Font.GothamBold,
			TextSize = 18
		})
	end)

	if not success then
		warn("Failed to display admin message:", err)
		-- Fallback: print to output
		print("[ADMIN]", message)
	end
end)

print("Admin message handler loaded")
