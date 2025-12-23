-- SoundService.lua
-- Manages game audio and sound effects

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SoundModule = {}

-- Sound IDs (Roblox asset IDs - you can replace with your own)
SoundModule.Sounds = {
	-- Gate sounds
	GateMultiply = "rbxassetid://9114846874", -- Woosh/power-up sound
	GateAdd = "rbxassetid://9114841892", -- Pop/spawn sound
	GateSpecial = "rbxassetid://9114844538", -- Magic sound

	-- Collection sounds
	CollectObject = "rbxassetid://9114843169", -- Coin pickup
	CollectBonus = "rbxassetid://9114848871", -- Bonus pickup

	-- Combo sounds
	ComboNice = "rbxassetid://9114831185", -- Soft chime
	ComboGreat = "rbxassetid://9114831530", -- Medium chime
	ComboAmazing = "rbxassetid://9114832079", -- Larger chime
	ComboIncredible = "rbxassetid://9114832494", -- Grand chime
	ComboLegendary = "rbxassetid://9114833042", -- Epic fanfare

	-- UI sounds
	ButtonClick = "rbxassetid://9114819261", -- Click sound
	PurchaseSuccess = "rbxassetid://9114821284", -- Cha-ching
	PurchaseFail = "rbxassetid://9114821706", -- Error buzz
	ShopOpen = "rbxassetid://9114819716", -- Menu open
	ShopClose = "rbxassetid://9114820160", -- Menu close

	-- Achievement sounds
	AchievementUnlocked = "rbxassetid://9114840327", -- Fanfare

	-- Game sounds
	ObjectSpawn = "rbxassetid://9114827340", -- Pop sound
	Push = "rbxassetid://9114827831", -- Whoosh
	LevelUp = "rbxassetid://9114835632", -- Level up jingle

	-- Rebirth sounds
	Rebirth = "rbxassetid://9114833042", -- Epic transformation
	RebirthReady = "rbxassetid://9114832494", -- Notification chime

	-- Quest sounds
	QuestComplete = "rbxassetid://9114832079", -- Quest done fanfare
	QuestClaim = "rbxassetid://9114821284", -- Reward claim

	-- Pet sounds
	Hatch = "rbxassetid://9114841892", -- Basic hatch pop
	EpicHatch = "rbxassetid://9114832079", -- Epic pet reveal
	LegendaryHatch = "rbxassetid://9114833042", -- Legendary reveal
	MythicHatch = "rbxassetid://9114840327", -- Mythic epic fanfare
	PetEquip = "rbxassetid://9114819261", -- Pet equipped

	-- Boss sounds
	BossSpawn = "rbxassetid://9114844538", -- Boss appears
	BossDefeat = "rbxassetid://9114848871", -- Boss defeated

	-- Ambient
	BackgroundMusic = "rbxassetid://1837755543" -- Peaceful background
}

-- Sound settings
SoundModule.Settings = {
	MasterVolume = 1.0,
	SFXVolume = 0.8,
	MusicVolume = 0.3,
	MusicEnabled = true,
	SFXEnabled = true
}

-- Sound folder in ReplicatedStorage
local soundFolder = nil
local backgroundMusic = nil

-- Initialize sound service
function SoundModule:Initialize()
	-- Create sound folder
	soundFolder = Instance.new("Folder")
	soundFolder.Name = "GameSounds"
	soundFolder.Parent = ReplicatedStorage

	-- Pre-load all sounds
	for soundName, soundId in pairs(self.Sounds) do
		local sound = Instance.new("Sound")
		sound.Name = soundName
		sound.SoundId = soundId
		sound.Volume = self.Settings.SFXVolume * self.Settings.MasterVolume
		sound.Parent = soundFolder
	end

	print("[SoundService] Initialized with " .. self:CountSounds() .. " sounds")
end

-- Count sounds
function SoundModule:CountSounds()
	local count = 0
	for _ in pairs(self.Sounds) do
		count = count + 1
	end
	return count
end

-- Play a sound effect (server-side)
function SoundModule:PlaySound(soundName, position, volume)
	if not self.Settings.SFXEnabled then return end

	local sound = soundFolder and soundFolder:FindFirstChild(soundName)
	if not sound then
		warn("[SoundService] Sound not found:", soundName)
		return
	end

	-- Create a clone to allow multiple instances
	local soundClone = sound:Clone()
	soundClone.Volume = (volume or 1) * self.Settings.SFXVolume * self.Settings.MasterVolume

	-- If position is provided, make it 3D
	if position then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.Position = position
		part.Parent = workspace
		soundClone.Parent = part

		soundClone.Ended:Connect(function()
			part:Destroy()
		end)
	else
		soundClone.Parent = soundFolder
		soundClone.Ended:Connect(function()
			soundClone:Destroy()
		end)
	end

	soundClone:Play()
	return soundClone
end

-- Play gate sound based on type
function SoundModule:PlayGateSound(gateType, position)
	local soundName = "GateMultiply"

	if gateType == "Add" then
		soundName = "GateAdd"
	elseif gateType == "Special" or gateType == "Random" then
		soundName = "GateSpecial"
	end

	self:PlaySound(soundName, position)
end

-- Play combo sound based on tier
function SoundModule:PlayComboSound(tierName)
	local soundName = "ComboNice"

	if tierName == "Great!" then
		soundName = "ComboGreat"
	elseif tierName == "Amazing!" then
		soundName = "ComboAmazing"
	elseif tierName == "INCREDIBLE!" then
		soundName = "ComboIncredible"
	elseif tierName == "LEGENDARY!" then
		soundName = "ComboLegendary"
	end

	self:PlaySound(soundName)
end

-- Play collection sound
function SoundModule:PlayCollectionSound(position, isBonus)
	if isBonus then
		self:PlaySound("CollectBonus", position)
	else
		self:PlaySound("CollectObject", position)
	end
end

-- Play achievement sound
function SoundModule:PlayAchievementSound()
	self:PlaySound("AchievementUnlocked", nil, 1.0)
end

-- Start background music
function SoundModule:StartBackgroundMusic()
	if not self.Settings.MusicEnabled then return end

	local musicSound = soundFolder and soundFolder:FindFirstChild("BackgroundMusic")
	if not musicSound then return end

	backgroundMusic = musicSound:Clone()
	backgroundMusic.Volume = self.Settings.MusicVolume * self.Settings.MasterVolume
	backgroundMusic.Looped = true
	backgroundMusic.Parent = soundFolder
	backgroundMusic:Play()

	print("[SoundService] Background music started")
end

-- Stop background music
function SoundModule:StopBackgroundMusic()
	if backgroundMusic then
		backgroundMusic:Stop()
		backgroundMusic:Destroy()
		backgroundMusic = nil
	end
end

-- Set music volume
function SoundModule:SetMusicVolume(volume)
	self.Settings.MusicVolume = math.clamp(volume, 0, 1)

	if backgroundMusic then
		backgroundMusic.Volume = self.Settings.MusicVolume * self.Settings.MasterVolume
	end
end

-- Set SFX volume
function SoundModule:SetSFXVolume(volume)
	self.Settings.SFXVolume = math.clamp(volume, 0, 1)
end

-- Toggle music
function SoundModule:ToggleMusic(enabled)
	self.Settings.MusicEnabled = enabled

	if enabled then
		self:StartBackgroundMusic()
	else
		self:StopBackgroundMusic()
	end
end

-- Toggle SFX
function SoundModule:ToggleSFX(enabled)
	self.Settings.SFXEnabled = enabled
end

-- Get sound settings
function SoundModule:GetSettings()
	return {
		MasterVolume = self.Settings.MasterVolume,
		SFXVolume = self.Settings.SFXVolume,
		MusicVolume = self.Settings.MusicVolume,
		MusicEnabled = self.Settings.MusicEnabled,
		SFXEnabled = self.Settings.SFXEnabled
	}
end

return SoundModule
