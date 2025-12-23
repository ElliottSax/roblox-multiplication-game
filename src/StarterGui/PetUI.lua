-- PetUI.lua
-- Client-side UI for the pet system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local PetUI = {}

-- Rarity colors
PetUI.RarityColors = {
	Common = Color3.fromRGB(150, 150, 150),
	Uncommon = Color3.fromRGB(100, 200, 100),
	Rare = Color3.fromRGB(100, 150, 255),
	Epic = Color3.fromRGB(200, 100, 255),
	Legendary = Color3.fromRGB(255, 200, 50),
	Mythic = Color3.fromRGB(255, 100, 150)
}

-- Create the UI
function PetUI:CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PetUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Pet button (right side)
	local petButton = Instance.new("TextButton")
	petButton.Name = "PetButton"
	petButton.Size = UDim2.new(0, 60, 0, 60)
	petButton.Position = UDim2.new(1, -80, 1, -220)
	petButton.BackgroundColor3 = Color3.fromRGB(180, 120, 50)
	petButton.Text = ""
	petButton.Parent = screenGui

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 12)
	buttonCorner.Parent = petButton

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 180, 100)
	buttonStroke.Thickness = 2
	buttonStroke.Parent = petButton

	local buttonIcon = Instance.new("TextLabel")
	buttonIcon.Size = UDim2.new(1, 0, 1, 0)
	buttonIcon.BackgroundTransparency = 1
	buttonIcon.Text = "P"
	buttonIcon.TextColor3 = Color3.new(1, 1, 1)
	buttonIcon.TextSize = 28
	buttonIcon.Font = Enum.Font.GothamBold
	buttonIcon.Parent = petButton

	-- Main panel
	local panel = Instance.new("Frame")
	panel.Name = "PetPanel"
	panel.Size = UDim2.new(0, 500, 0, 550)
	panel.Position = UDim2.new(0.5, -250, 0.5, -275)
	panel.BackgroundColor3 = Color3.fromRGB(30, 25, 20)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 16)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(200, 150, 100)
	panelStroke.Thickness = 3
	panelStroke.Parent = panel

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Color3.fromRGB(100, 70, 40)
	header.BorderSizePixel = 0
	header.Parent = panel

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 16)
	headerCorner.Parent = header

	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 20)
	headerFix.Position = UDim2.new(0, 0, 1, -20)
	headerFix.BackgroundColor3 = Color3.fromRGB(100, 70, 40)
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "PETS"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0.5, -20)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.TextSize = 20
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	-- Tab buttons
	local tabFrame = Instance.new("Frame")
	tabFrame.Name = "TabFrame"
	tabFrame.Size = UDim2.new(1, -20, 0, 40)
	tabFrame.Position = UDim2.new(0, 10, 0, 70)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Parent = panel

	local tabs = {"Inventory", "Hatch", "Equipped"}
	for i, tabName in ipairs(tabs) do
		local tabButton = Instance.new("TextButton")
		tabButton.Name = tabName .. "Tab"
		tabButton.Size = UDim2.new(1/#tabs, -5, 1, 0)
		tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
		tabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(100, 70, 40) or Color3.fromRGB(50, 40, 30)
		tabButton.Text = tabName
		tabButton.TextColor3 = Color3.new(1, 1, 1)
		tabButton.TextSize = 16
		tabButton.Font = Enum.Font.GothamBold
		tabButton.Parent = tabFrame

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 8)
		tabCorner.Parent = tabButton
	end

	-- Content frame
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -20, 1, -130)
	contentFrame.Position = UDim2.new(0, 10, 0, 120)
	contentFrame.BackgroundColor3 = Color3.fromRGB(40, 35, 30)
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = panel

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 12)
	contentCorner.Parent = contentFrame

	-- Inventory view
	local inventoryView = Instance.new("ScrollingFrame")
	inventoryView.Name = "InventoryView"
	inventoryView.Size = UDim2.new(1, -10, 1, -10)
	inventoryView.Position = UDim2.new(0, 5, 0, 5)
	inventoryView.BackgroundTransparency = 1
	inventoryView.ScrollBarThickness = 4
	inventoryView.CanvasSize = UDim2.new(0, 0, 0, 0)
	inventoryView.Visible = true
	inventoryView.Parent = contentFrame

	local invGrid = Instance.new("UIGridLayout")
	invGrid.CellSize = UDim2.new(0, 90, 0, 110)
	invGrid.CellPadding = UDim2.new(0, 5, 0, 5)
	invGrid.SortOrder = Enum.SortOrder.LayoutOrder
	invGrid.Parent = inventoryView

	-- Hatch view
	local hatchView = Instance.new("Frame")
	hatchView.Name = "HatchView"
	hatchView.Size = UDim2.new(1, 0, 1, 0)
	hatchView.BackgroundTransparency = 1
	hatchView.Visible = false
	hatchView.Parent = contentFrame

	-- Equipped view
	local equippedView = Instance.new("Frame")
	equippedView.Name = "EquippedView"
	equippedView.Size = UDim2.new(1, 0, 1, 0)
	equippedView.BackgroundTransparency = 1
	equippedView.Visible = false
	equippedView.Parent = contentFrame

	-- Store references
	self.ScreenGui = screenGui
	self.PetButton = petButton
	self.Panel = panel
	self.CloseButton = closeButton
	self.TabFrame = tabFrame
	self.ContentFrame = contentFrame
	self.InventoryView = inventoryView
	self.HatchView = hatchView
	self.EquippedView = equippedView
	self.CurrentTab = "Inventory"

	-- Set up events
	self:SetupEvents()
	self:CreateHatchView()
	self:CreateEquippedView()
end

-- Create hatch view content
function PetUI:CreateHatchView()
	local eggs = {
		{Id = "basic_egg", Name = "Basic Egg", Cost = 1000, Color = Color3.fromRGB(150, 150, 150)},
		{Id = "premium_egg", Name = "Premium Egg", Cost = 5000, Color = Color3.fromRGB(100, 200, 100)},
		{Id = "legendary_egg", Name = "Legendary Egg", Cost = 25000, Color = Color3.fromRGB(255, 200, 50)},
		{Id = "mythic_egg", Name = "Mythic Egg", Cost = 100000, Color = Color3.fromRGB(255, 100, 150)}
	}

	for i, egg in ipairs(eggs) do
		local eggCard = Instance.new("Frame")
		eggCard.Name = egg.Id
		eggCard.Size = UDim2.new(0.5, -10, 0, 180)
		eggCard.Position = UDim2.new((i-1) % 2 * 0.5, 5, math.floor((i-1)/2) * 0.5, 5)
		eggCard.BackgroundColor3 = Color3.fromRGB(50, 45, 40)
		eggCard.Parent = self.HatchView

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 12)
		cardCorner.Parent = eggCard

		-- Egg visual
		local eggVisual = Instance.new("Frame")
		eggVisual.Size = UDim2.new(0, 60, 0, 80)
		eggVisual.Position = UDim2.new(0.5, -30, 0, 15)
		eggVisual.BackgroundColor3 = egg.Color
		eggVisual.Parent = eggCard

		local eggCorner = Instance.new("UICorner")
		eggCorner.CornerRadius = UDim.new(0, 30)
		eggCorner.Parent = eggVisual

		local eggStroke = Instance.new("UIStroke")
		eggStroke.Color = Color3.new(1, 1, 1)
		eggStroke.Thickness = 2
		eggStroke.Parent = eggVisual

		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -10, 0, 25)
		nameLabel.Position = UDim2.new(0, 5, 0, 100)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = egg.Name
		nameLabel.TextColor3 = egg.Color
		nameLabel.TextSize = 16
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Parent = eggCard

		-- Hatch button
		local hatchButton = Instance.new("TextButton")
		hatchButton.Name = "HatchButton"
		hatchButton.Size = UDim2.new(1, -20, 0, 35)
		hatchButton.Position = UDim2.new(0, 10, 1, -45)
		hatchButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
		hatchButton.Text = "$" .. egg.Cost
		hatchButton.TextColor3 = Color3.new(1, 1, 1)
		hatchButton.TextSize = 16
		hatchButton.Font = Enum.Font.GothamBold
		hatchButton.Parent = eggCard

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = hatchButton

		hatchButton.MouseButton1Click:Connect(function()
			self:HatchEgg(egg.Id)
		end)
	end
end

-- Create equipped view content
function PetUI:CreateEquippedView()
	-- Equipped slots header
	local slotsLabel = Instance.new("TextLabel")
	slotsLabel.Name = "SlotsLabel"
	slotsLabel.Size = UDim2.new(1, 0, 0, 30)
	slotsLabel.BackgroundTransparency = 1
	slotsLabel.Text = "Equipped Pets (0/3)"
	slotsLabel.TextColor3 = Color3.new(1, 1, 1)
	slotsLabel.TextSize = 18
	slotsLabel.Font = Enum.Font.GothamBold
	slotsLabel.Parent = self.EquippedView

	-- Equipped slots
	local slotsFrame = Instance.new("Frame")
	slotsFrame.Name = "SlotsFrame"
	slotsFrame.Size = UDim2.new(1, 0, 0, 120)
	slotsFrame.Position = UDim2.new(0, 0, 0, 35)
	slotsFrame.BackgroundTransparency = 1
	slotsFrame.Parent = self.EquippedView

	for i = 1, 3 do
		local slot = Instance.new("Frame")
		slot.Name = "Slot" .. i
		slot.Size = UDim2.new(0.33, -10, 1, 0)
		slot.Position = UDim2.new((i-1) * 0.33, 5, 0, 0)
		slot.BackgroundColor3 = Color3.fromRGB(50, 45, 40)
		slot.Parent = slotsFrame

		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 12)
		slotCorner.Parent = slot

		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Name = "Empty"
		emptyLabel.Size = UDim2.new(1, 0, 1, 0)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.Text = "Empty"
		emptyLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
		emptyLabel.TextSize = 14
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.Parent = slot
	end

	-- Bonuses section
	local bonusLabel = Instance.new("TextLabel")
	bonusLabel.Name = "BonusLabel"
	bonusLabel.Size = UDim2.new(1, 0, 0, 30)
	bonusLabel.Position = UDim2.new(0, 0, 0, 165)
	bonusLabel.BackgroundTransparency = 1
	bonusLabel.Text = "Active Bonuses"
	bonusLabel.TextColor3 = Color3.new(1, 1, 1)
	bonusLabel.TextSize = 18
	bonusLabel.Font = Enum.Font.GothamBold
	bonusLabel.Parent = self.EquippedView

	local bonusFrame = Instance.new("Frame")
	bonusFrame.Name = "BonusFrame"
	bonusFrame.Size = UDim2.new(1, 0, 0, 200)
	bonusFrame.Position = UDim2.new(0, 0, 0, 200)
	bonusFrame.BackgroundColor3 = Color3.fromRGB(50, 45, 40)
	bonusFrame.Parent = self.EquippedView

	local bonusCorner = Instance.new("UICorner")
	bonusCorner.CornerRadius = UDim.new(0, 12)
	bonusCorner.Parent = bonusFrame

	local bonusList = Instance.new("UIListLayout")
	bonusList.Padding = UDim.new(0, 5)
	bonusList.Parent = bonusFrame

	self.SlotsLabel = slotsLabel
	self.SlotsFrame = slotsFrame
	self.BonusFrame = bonusFrame
end

-- Set up UI events
function PetUI:SetupEvents()
	self.PetButton.MouseButton1Click:Connect(function()
		self:TogglePanel()
	end)

	self.CloseButton.MouseButton1Click:Connect(function()
		self:ClosePanel()
	end)

	-- Tab switching
	for _, tab in ipairs(self.TabFrame:GetChildren()) do
		if tab:IsA("TextButton") then
			tab.MouseButton1Click:Connect(function()
				self:SwitchTab(tab.Name:gsub("Tab", ""))
			end)
		end
	end

	-- Hover effects
	self.PetButton.MouseEnter:Connect(function()
		TweenService:Create(self.PetButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(200, 140, 70)
		}):Play()
	end)

	self.PetButton.MouseLeave:Connect(function()
		TweenService:Create(self.PetButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(180, 120, 50)
		}):Play()
	end)
end

-- Switch tabs
function PetUI:SwitchTab(tabName)
	self.CurrentTab = tabName

	-- Update tab visuals
	for _, tab in ipairs(self.TabFrame:GetChildren()) do
		if tab:IsA("TextButton") then
			local isActive = tab.Name == tabName .. "Tab"
			tab.BackgroundColor3 = isActive and Color3.fromRGB(100, 70, 40) or Color3.fromRGB(50, 40, 30)
		end
	end

	-- Show correct view
	self.InventoryView.Visible = tabName == "Inventory"
	self.HatchView.Visible = tabName == "Hatch"
	self.EquippedView.Visible = tabName == "Equipped"

	-- Refresh content
	if tabName == "Inventory" then
		self:RefreshInventory()
	elseif tabName == "Equipped" then
		self:RefreshEquipped()
	end
end

-- Toggle panel
function PetUI:TogglePanel()
	if self.Panel.Visible then
		self:ClosePanel()
	else
		self:OpenPanel()
	end
end

-- Open panel
function PetUI:OpenPanel()
	self.Panel.Visible = true
	self.Panel.Position = UDim2.new(0.5, -250, 0.5, -225)
	self.Panel.BackgroundTransparency = 1

	TweenService:Create(self.Panel, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, -250, 0.5, -275),
		BackgroundTransparency = 0
	}):Play()

	self:RefreshInventory()
end

-- Close panel
function PetUI:ClosePanel()
	TweenService:Create(self.Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0.5, -250, 0.5, -225),
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.2, function()
		self.Panel.Visible = false
	end)
end

-- Refresh inventory
function PetUI:RefreshInventory()
	local getPetData = ReplicatedStorage:FindFirstChild("GetPetData")
	if not getPetData then return end

	local success, petData = pcall(function()
		return getPetData:InvokeServer()
	end)

	if not success or not petData then return end

	-- Clear existing
	for _, child in ipairs(self.InventoryView:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Create pet cards
	for i, pet in ipairs(petData.Inventory) do
		self:CreatePetCard(pet, i)
	end

	-- Update canvas size
	local grid = self.InventoryView:FindFirstChild("UIGridLayout")
	if grid then
		local rows = math.ceil(#petData.Inventory / 5)
		self.InventoryView.CanvasSize = UDim2.new(0, 0, 0, rows * 115)
	end
end

-- Create pet card
function PetUI:CreatePetCard(pet, order)
	local rarityColor = self.RarityColors[pet.Rarity] or Color3.fromRGB(150, 150, 150)

	local card = Instance.new("Frame")
	card.Name = "Pet_" .. pet.Id
	card.Size = UDim2.new(0, 90, 0, 110)
	card.BackgroundColor3 = Color3.fromRGB(50, 45, 40)
	card.LayoutOrder = order
	card.Parent = self.InventoryView

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = rarityColor
	cardStroke.Thickness = pet.Equipped and 3 or 1
	cardStroke.Parent = card

	-- Icon
	local icon = Instance.new("Frame")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0.5, -25, 0, 5)
	icon.BackgroundColor3 = rarityColor
	icon.Parent = card

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	local iconText = Instance.new("TextLabel")
	iconText.Size = UDim2.new(1, 0, 1, 0)
	iconText.BackgroundTransparency = 1
	iconText.Text = pet.Icon
	iconText.TextColor3 = Color3.new(1, 1, 1)
	iconText.TextSize = 24
	iconText.Font = Enum.Font.GothamBold
	iconText.Parent = icon

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -4, 0, 20)
	nameLabel.Position = UDim2.new(0, 2, 0, 58)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = pet.Name
	nameLabel.TextColor3 = rarityColor
	nameLabel.TextSize = 10
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Parent = card

	-- Multiplier
	local multLabel = Instance.new("TextLabel")
	multLabel.Size = UDim2.new(1, 0, 0, 15)
	multLabel.Position = UDim2.new(0, 0, 0, 75)
	multLabel.BackgroundTransparency = 1
	multLabel.Text = string.format("%.2fx", pet.Multiplier)
	multLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	multLabel.TextSize = 12
	multLabel.Font = Enum.Font.GothamBold
	multLabel.Parent = card

	-- Click to equip/unequip
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = card

	button.MouseButton1Click:Connect(function()
		if pet.Equipped then
			self:UnequipPet(pet.Id)
		else
			self:EquipPet(pet.Id)
		end
	end)

	-- Equipped indicator
	if pet.Equipped then
		local equipped = Instance.new("TextLabel")
		equipped.Size = UDim2.new(1, 0, 0, 15)
		equipped.Position = UDim2.new(0, 0, 1, -15)
		equipped.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
		equipped.Text = "EQUIPPED"
		equipped.TextColor3 = Color3.new(1, 1, 1)
		equipped.TextSize = 10
		equipped.Font = Enum.Font.GothamBold
		equipped.Parent = card

		local eqCorner = Instance.new("UICorner")
		eqCorner.CornerRadius = UDim.new(0, 4)
		eqCorner.Parent = equipped
	end
end

-- Refresh equipped view
function PetUI:RefreshEquipped()
	local getPetData = ReplicatedStorage:FindFirstChild("GetPetData")
	if not getPetData then return end

	local success, petData = pcall(function()
		return getPetData:InvokeServer()
	end)

	if not success or not petData then return end

	-- Update slots label
	self.SlotsLabel.Text = string.format("Equipped Pets (%d/%d)", #petData.Equipped, petData.MaxEquipped)

	-- Clear and populate slots
	local equippedPets = {}
	for _, pet in ipairs(petData.Inventory) do
		if pet.Equipped then
			table.insert(equippedPets, pet)
		end
	end

	for i = 1, 3 do
		local slot = self.SlotsFrame:FindFirstChild("Slot" .. i)
		if slot then
			-- Clear slot
			for _, child in ipairs(slot:GetChildren()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") then
					child:Destroy()
				end
			end

			local pet = equippedPets[i]
			if pet then
				local rarityColor = self.RarityColors[pet.Rarity]

				local icon = Instance.new("TextLabel")
				icon.Size = UDim2.new(0, 40, 0, 40)
				icon.Position = UDim2.new(0.5, -20, 0, 10)
				icon.BackgroundColor3 = rarityColor
				icon.Text = pet.Icon
				icon.TextColor3 = Color3.new(1, 1, 1)
				icon.TextSize = 24
				icon.Font = Enum.Font.GothamBold
				icon.Parent = slot

				local iconCorner = Instance.new("UICorner")
				iconCorner.CornerRadius = UDim.new(0, 8)
				iconCorner.Parent = icon

				local name = Instance.new("TextLabel")
				name.Size = UDim2.new(1, -10, 0, 20)
				name.Position = UDim2.new(0, 5, 0, 55)
				name.BackgroundTransparency = 1
				name.Text = pet.Name
				name.TextColor3 = rarityColor
				name.TextSize = 11
				name.Font = Enum.Font.GothamBold
				name.TextScaled = true
				name.Parent = slot

				local mult = Instance.new("TextLabel")
				mult.Size = UDim2.new(1, 0, 0, 15)
				mult.Position = UDim2.new(0, 0, 0, 75)
				mult.BackgroundTransparency = 1
				mult.Text = string.format("%.2fx", pet.Multiplier)
				mult.TextColor3 = Color3.fromRGB(100, 255, 100)
				mult.TextSize = 12
				mult.Font = Enum.Font.GothamBold
				mult.Parent = slot

				local unequipBtn = Instance.new("TextButton")
				unequipBtn.Size = UDim2.new(1, -10, 0, 20)
				unequipBtn.Position = UDim2.new(0, 5, 1, -25)
				unequipBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
				unequipBtn.Text = "Remove"
				unequipBtn.TextColor3 = Color3.new(1, 1, 1)
				unequipBtn.TextSize = 11
				unequipBtn.Font = Enum.Font.GothamBold
				unequipBtn.Parent = slot

				local btnCorner = Instance.new("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 4)
				btnCorner.Parent = unequipBtn

				unequipBtn.MouseButton1Click:Connect(function()
					self:UnequipPet(pet.Id)
				end)
			else
				local empty = Instance.new("TextLabel")
				empty.Name = "Empty"
				empty.Size = UDim2.new(1, 0, 1, 0)
				empty.BackgroundTransparency = 1
				empty.Text = "Empty"
				empty.TextColor3 = Color3.fromRGB(100, 100, 100)
				empty.TextSize = 14
				empty.Font = Enum.Font.Gotham
				empty.Parent = slot
			end
		end
	end

	-- Update bonuses
	self:RefreshBonuses(petData.Bonuses)
end

-- Refresh bonus display
function PetUI:RefreshBonuses(bonuses)
	-- Clear existing
	for _, child in ipairs(self.BonusFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local bonusNames = {
		CurrencyMultiplier = "Currency",
		ObjectValue = "Object Value",
		LuckBoost = "Luck",
		SpeedBoost = "Speed",
		ComboExtender = "Combo Duration",
		GateBonus = "Gate Effects",
		CollectionRange = "Collection Range"
	}

	local y = 5
	for bonusType, value in pairs(bonuses) do
		if value > 1.0 then
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -20, 0, 25)
			label.Position = UDim2.new(0, 10, 0, y)
			label.BackgroundTransparency = 1
			label.Text = string.format("%s: %.2fx", bonusNames[bonusType] or bonusType, value)
			label.TextColor3 = Color3.fromRGB(100, 255, 100)
			label.TextSize = 14
			label.Font = Enum.Font.Gotham
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = self.BonusFrame

			y = y + 28
		end
	end

	if y == 5 then
		local noBonus = Instance.new("TextLabel")
		noBonus.Size = UDim2.new(1, 0, 1, 0)
		noBonus.BackgroundTransparency = 1
		noBonus.Text = "No active bonuses\nEquip pets to get bonuses!"
		noBonus.TextColor3 = Color3.fromRGB(150, 150, 150)
		noBonus.TextSize = 14
		noBonus.Font = Enum.Font.Gotham
		noBonus.Parent = self.BonusFrame
	end
end

-- Hatch egg
function PetUI:HatchEgg(eggId)
	local hatchEgg = ReplicatedStorage:FindFirstChild("HatchEgg")
	if not hatchEgg then return end

	local success, result = pcall(function()
		return hatchEgg:InvokeServer(eggId)
	end)

	if success and result then
		if result.Success then
			self:ShowHatchAnimation(result.Pet)
		else
			self:ShowMessage(result.Message or "Failed to hatch")
		end
	end
end

-- Show hatch animation
function PetUI:ShowHatchAnimation(pet)
	local rarityColor = self.RarityColors[pet.Rarity] or Color3.fromRGB(150, 150, 150)

	-- Flash effect
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = rarityColor
	flash.BackgroundTransparency = 0
	flash.ZIndex = 100
	flash.Parent = self.ScreenGui

	TweenService:Create(flash, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.5, function()
		flash:Destroy()
	end)

	-- Show pet reveal
	local reveal = Instance.new("Frame")
	reveal.Size = UDim2.new(0, 250, 0, 200)
	reveal.Position = UDim2.new(0.5, -125, 0.4, -100)
	reveal.BackgroundColor3 = Color3.fromRGB(40, 35, 30)
	reveal.ZIndex = 100
	reveal.Parent = self.ScreenGui

	local revealCorner = Instance.new("UICorner")
	revealCorner.CornerRadius = UDim.new(0, 16)
	revealCorner.Parent = reveal

	local revealStroke = Instance.new("UIStroke")
	revealStroke.Color = rarityColor
	revealStroke.Thickness = 3
	revealStroke.Parent = reveal

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, 0, 0, 30)
	rarityLabel.Position = UDim2.new(0, 0, 0, 10)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = pet.Rarity:upper()
	rarityLabel.TextColor3 = rarityColor
	rarityLabel.TextSize = 20
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Parent = reveal

	local petIcon = Instance.new("Frame")
	petIcon.Size = UDim2.new(0, 80, 0, 80)
	petIcon.Position = UDim2.new(0.5, -40, 0, 45)
	petIcon.BackgroundColor3 = rarityColor
	petIcon.Parent = reveal

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 12)
	iconCorner.Parent = petIcon

	local iconText = Instance.new("TextLabel")
	iconText.Size = UDim2.new(1, 0, 1, 0)
	iconText.BackgroundTransparency = 1
	iconText.Text = pet.Icon
	iconText.TextColor3 = Color3.new(1, 1, 1)
	iconText.TextSize = 40
	iconText.Font = Enum.Font.GothamBold
	iconText.Parent = petIcon

	local petName = Instance.new("TextLabel")
	petName.Size = UDim2.new(1, 0, 0, 25)
	petName.Position = UDim2.new(0, 0, 0, 130)
	petName.BackgroundTransparency = 1
	petName.Text = pet.Name
	petName.TextColor3 = Color3.new(1, 1, 1)
	petName.TextSize = 18
	petName.Font = Enum.Font.GothamBold
	petName.Parent = reveal

	local petMult = Instance.new("TextLabel")
	petMult.Size = UDim2.new(1, 0, 0, 25)
	petMult.Position = UDim2.new(0, 0, 0, 155)
	petMult.BackgroundTransparency = 1
	petMult.Text = string.format("%.2fx Bonus", pet.Multiplier)
	petMult.TextColor3 = Color3.fromRGB(100, 255, 100)
	petMult.TextSize = 16
	petMult.Font = Enum.Font.GothamBold
	petMult.Parent = reveal

	task.delay(2.5, function()
		TweenService:Create(reveal, TweenInfo.new(0.3), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(revealStroke, TweenInfo.new(0.3), {
			Transparency = 1
		}):Play()

		task.delay(0.3, function()
			reveal:Destroy()
			self:RefreshInventory()
		end)
	end)
end

-- Equip pet
function PetUI:EquipPet(petId)
	local equipPet = ReplicatedStorage:FindFirstChild("EquipPet")
	if not equipPet then return end

	local success, result = pcall(function()
		return equipPet:InvokeServer(petId)
	end)

	if success then
		self:RefreshInventory()
		if self.CurrentTab == "Equipped" then
			self:RefreshEquipped()
		end
	end
end

-- Unequip pet
function PetUI:UnequipPet(petId)
	local unequipPet = ReplicatedStorage:FindFirstChild("UnequipPet")
	if not unequipPet then return end

	local success, result = pcall(function()
		return unequipPet:InvokeServer(petId)
	end)

	if success then
		self:RefreshInventory()
		if self.CurrentTab == "Equipped" then
			self:RefreshEquipped()
		end
	end
end

-- Show message
function PetUI:ShowMessage(message)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 250, 0, 40)
	label.Position = UDim2.new(0.5, -125, 0.7, 0)
	label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 150, 100)
	label.TextSize = 16
	label.Font = Enum.Font.Gotham
	label.ZIndex = 100
	label.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	task.delay(2, function()
		TweenService:Create(label, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()

		task.delay(0.3, function()
			label:Destroy()
		end)
	end)
end

-- Initialize
function PetUI:Initialize()
	self:CreateUI()
	print("PetUI initialized")
end

-- Start
PetUI:Initialize()

return PetUI
