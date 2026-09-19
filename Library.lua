local UILibrary = {}
UILibrary.__index = UILibrary

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Colores base
local activeTextColor = Color3.fromHex("#FFFFFF")
local inactiveTextColor = Color3.fromHex("#626262")

local activeColorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHex("#000000")),
	ColorSequenceKeypoint.new(1, Color3.fromHex("#121218"))
})

local inactiveColorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHex("#121218")),
	ColorSequenceKeypoint.new(1, Color3.fromHex("#000000"))
})

function UILibrary.new(titleText)
	local self = setmetatable({}, UILibrary)
	
	-- ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "CustomUILibrary"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Intentar parent a CoreGui si es posible, sino a PlayerGui
	local success = pcall(function()
		self.ScreenGui.Parent = CoreGui
	end)
	if not success then
		local players = game:GetService("Players")
		local player = players.LocalPlayer
		if player then
			self.ScreenGui.Parent = player:WaitForChild("PlayerGui")
		else
			self.ScreenGui.Parent = game:GetService("StarterGui")
		end
	end

	-- Main Frame
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.new(0, 724, 0, 626)
	self.MainFrame.Position = UDim2.new(0.3, 0, 0.1, 0)
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.Parent = self.ScreenGui

	-- Contenedor de Pestañas (Tabs Container)
	self.TabsContainer = Instance.new("Frame")
	self.TabsContainer.Name = "TabsContainer"
	self.TabsContainer.Size = UDim2.new(0, 200, 1, 0)
	self.TabsContainer.BackgroundTransparency = 1
	self.TabsContainer.Parent = self.MainFrame

	self.TabsLayout = Instance.new("UIListLayout")
	self.TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.TabsLayout.Parent = self.TabsContainer

	-- Contenedor de Páginas
	self.PagesContainer = Instance.new("Frame")
	self.PagesContainer.Name = "PagesContainer"
	self.PagesContainer.Size = UDim2.new(1, -210, 1, -20)
	self.PagesContainer.Position = UDim2.new(0, 210, 0, 10)
	self.PagesContainer.BackgroundTransparency = 1
	self.PagesContainer.Parent = self.MainFrame

	self.ActiveTab = nil
	self.Tabs = {}

	return self
end

function UILibrary:CreateTab(name)
	local tabObj = {}
	local tabIndex = #self.Tabs + 1

	-- Crear contenedor de botón de pestaña
	local tabButtonFrame = Instance.new("Frame")
	tabButtonFrame.Name = "tab" .. tabIndex
	tabButtonFrame.Size = UDim2.new(1, 0, 0, 50)
	tabButtonFrame.BackgroundTransparency = 1
	tabButtonFrame.Parent = self.TabsContainer

	local innerFrame = Instance.new("Frame")
	innerFrame.Size = UDim2.new(1, 0, 1, 0)
	innerFrame.BackgroundTransparency = 1
	innerFrame.Parent = tabButtonFrame

	local textLabel = Instance.new("TextButton")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = name
	textLabel.TextColor3 = inactiveTextColor
	textLabel.TextSize = 16
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = innerFrame

	local sombra = Instance.new("ImageLabel")
	sombra.Name = "sombra"
	sombra.Size = UDim2.new(1, 0, 1, 0)
	sombra.BackgroundTransparency = 1
	sombra.Visible = false
	sombra.Parent = innerFrame

	local gradient = Instance.new("UIGradient")
	gradient.Color = inactiveColorSequence
	gradient.Parent = sombra

	local linea = Instance.new("Frame")
	linea.Name = "Linea invisible"
	linea.Size = UDim2.new(0, 4, 1, 0)
	linea.BackgroundColor3 = Color3.fromRGB(0, 136, 220)
	linea.BorderSizePixel = 0
	linea.Visible = false
	linea.Parent = tabButtonFrame

	-- Página de contenido
	local tabPage = Instance.new("ScrollingFrame")
	tabPage.Name = "Page_" .. name
	tabPage.Size = UDim2.new(1, 0, 1, 0)
	tabPage.BackgroundTransparency = 1
	tabPage.Visible = false
	tabPage.CanvasSize = UDim2.new(0, 0, 2, 0)
	tabPage.ScrollBarThickness = 4
	tabPage.Parent = self.PagesContainer

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 10)
	pageLayout.Parent = tabPage

	local function updateTabVisuals(isSelected)
		linea.Visible = isSelected
		local targetTextColor = isSelected and activeTextColor or inactiveTextColor
		TweenService:Create(textLabel, tweenInfo, {TextColor3 = targetTextColor}):Play()

		sombra.Visible = true
		gradient.Color = isSelected and activeColorSequence or inactiveColorSequence
		local targetOffset = isSelected and Vector2.new(0, 0) or Vector2.new(1, 0)
		TweenService:Create(gradient, tweenInfo, {Offset = targetOffset}):Play()
		
		tabPage.Visible = isSelected
	end

	textLabel.MouseButton1Click:Connect(function()
		if self.ActiveTab == tabObj then return end
		
		if self.ActiveTab then
			self.ActiveTab:Select(false)
		end
		
		self.ActiveTab = tabObj
		tabObj:Select(true)
	end)

	function tabObj:Select(state)
		updateTabVisuals(state)
	end

	if #self.Tabs == 0 then
		self.ActiveTab = tabObj
		tabObj:Select(true)
	end

	table.insert(self.Tabs, tabObj)

	-- Métodos para agregar elementos a la página de esta pestaña
	function tabObj:AddToggle(title, callback)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Name = "Checkbox_Item"
		toggleFrame.Size = UDim2.new(1, 0, 0, 40)
		toggleFrame.BackgroundTransparency = 0.8
		toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		toggleFrame.Parent = tabPage

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -50, 1, 0)
		titleLabel.Position = UDim2.new(0, 10, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Font = Enum.Font.Gotham
		titleLabel.TextSize = 14
		titleLabel.Parent = toggleFrame

		local checkBoxContainer = Instance.new("Frame")
		checkBoxContainer.Name = "checkBox"
		checkBoxContainer.Size = UDim2.new(0, 24, 0, 24)
		checkBoxContainer.Position = UDim2.new(1, -34, 0.5, -12)
		checkBoxContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
		checkBoxContainer.BorderSizePixel = 0
		checkBoxContainer.Parent = toggleFrame

		local innerBox = Instance.new("Frame")
		innerBox.Name = "checkBox"
		innerBox.Size = UDim2.new(1, 0, 1, 0)
		innerBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
		innerBox.BorderSizePixel = 0
		innerBox.Parent = checkBoxContainer

		local isChecked = false
		local clickBtn = Instance.new("TextButton")
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.BackgroundTransparency = 1
		clickBtn.Text = ""
		clickBtn.Parent = toggleFrame

		clickBtn.MouseButton1Click:Connect(function()
			isChecked = not isChecked
			local targetBg = isChecked and Color3.fromRGB(0, 136, 220) or Color3.fromRGB(24, 24, 32)
			TweenService:Create(innerBox, tweenInfo, {BackgroundColor3 = targetBg}):Play()
			if callback then
				callback(isChecked)
			end
		end)
	end

	function tabObj:AddSlider(title, min, max, callback)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Name = "Slider_Item"
		sliderFrame.Size = UDim2.new(1, 0, 0, 50)
		sliderFrame.BackgroundTransparency = 1
		sliderFrame.Parent = tabPage

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, 20)
		titleLabel.Position = UDim2.new(0, 10, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Font = Enum.Font.Gotham
		titleLabel.TextSize = 14
		titleLabel.Parent = sliderFrame

		local percentLabel = Instance.new("TextLabel")
		percentLabel.Name = "Porcentaje"
		percentLabel.Size = UDim2.new(0, 100, 0, 20)
		percentLabel.Position = UDim2.new(1, -110, 0, 0)
		percentLabel.BackgroundTransparency = 1
		percentLabel.Text = min .. " / " .. max
		percentLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		percentLabel.TextXAlignment = Enum.TextXAlignment.Right
		percentLabel.Font = Enum.Font.Gotham
		percentLabel.TextSize = 12
		percentLabel.Parent = sliderFrame

		local barFrame = Instance.new("Frame")
		barFrame.Size = UDim2.new(1, -20, 0, 10)
		barFrame.Position = UDim2.new(0, 10, 0, 30)
		barFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		barFrame.BorderSizePixel = 0
		barFrame.Parent = sliderFrame

		local fillFrame = Instance.new("Frame")
		fillFrame.Name = "Arrastrar"
		fillFrame.Size = UDim2.new(0, 0, 1, 0)
		fillFrame.BackgroundColor3 = Color3.fromRGB(0, 136, 220)
		fillFrame.BorderSizePixel = 0
		fillFrame.Parent = barFrame

		local clickArea = Instance.new("TextButton")
		clickArea.Size = UDim2.new(1, 0, 1, 0)
		clickArea.BackgroundTransparency = 1
		clickArea.Text = ""
		clickArea.Parent = barFrame

		local isDragging = false

		local function updateSlider(input)
			local barAbsPos = barFrame.AbsolutePosition.X
			local barAbsSize = barFrame.AbsoluteSize.X
			if barAbsSize == 0 then return end

			local relativeX = math.clamp(input.Position.X - barAbsPos, 0, barAbsSize)
			local percentage = relativeX / barAbsSize
			local value = math.floor(min + (max - min) * percentage)

			fillFrame.Size = UDim2.new(percentage, 0, 1, 0)
			percentLabel.Text = value .. " / " .. max

			if callback then
				callback(value)
			end
		end

		clickArea.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = true
				updateSlider(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input)
			end
		end)
	end

	return tabObj
end

return UILibrary
