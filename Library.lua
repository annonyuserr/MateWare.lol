-- ==============================================================
-- MateWare UI Library (estructura estilo Linoria)
-- ==============================================================
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local TextService = game:GetService('TextService')
local CoreGui = game:GetService('CoreGui')
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

-- FUENTES
local FontsToDownload = {
	['Tahoma'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/fs-tahoma-8px.ttf' },
	['ProggyTiny'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/ProggyTiny.ttf' },
	['Templehook'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/Templehook.ttf' },
	['PixelSans'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/fs-pixel-sans-unicode-regular.regular.ttf' },
	['Micro'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/Pixel.ttf' },
	['Minecraftia'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/minecraftia.ttf' },
	['Nokia'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/nokia.ttf' },
	['SmallestPixel7'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/smallest_pixel-7.ttf' },
	['Monaco'] = { TTF = 'https://github.com/annonyuserr/Fonts/raw/main/monaco.ttf' },
}
local ESPFonts = { Loaded = {} }
local DEFAULT_FONT = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local function LoadFont(name)
	if not name or ESPFonts.Loaded[name] then return ESPFonts.Loaded[name] or DEFAULT_FONT end
	local info = FontsToDownload[name]
	if not info or not (writefile and isfile and getcustomasset) then return DEFAULT_FONT end
	local path = 'mateware_fonts/' .. name .. '.ttf'
	task.spawn(function()
		if not isfile(path) then
			local ok, data = pcall(function() return game:HttpGet(info.TTF) end)
			if ok and data then pcall(writefile, path, data) end
		end
		if isfile(path) then
			local ok2, font = pcall(function() return Font.new(getcustomasset(path)) end)
			if ok2 then ESPFonts.Loaded[name] = font end
		end
	end)
	return DEFAULT_FONT
end
local function getFont(name)
	if name and ESPFonts.Loaded[name] then return ESPFonts.Loaded[name] end
	return LoadFont(name) or DEFAULT_FONT
end

-- ESTILO
local Library = {
	Registry = {}, RegistryMap = {},
	FontColor = Color3.fromRGB(255,255,255),
	MainColor = Color3.fromRGB(27,27,33),
	BackgroundColor = Color3.fromRGB(14,14,17),
	AccentColor = Color3.fromRGB(0,255,0),
	OutlineColor = Color3.fromRGB(68,68,83),
	Black = Color3.new(0,0,0),
	Toggles = {}, Options = {}, OpenedFrames = {}, Signals = {},
}
Library.AccentColorDark = Color3.fromRGB(0,60,0)
local genv = getgenv or function() return _G end
genv().Toggles = Library.Toggles
genv().Options = Library.Options

local ScreenGui = Instance.new('ScreenGui')
ProtectGui(ScreenGui)
ScreenGui.Name = 'MateWareLib'
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui
Library.ScreenGui = ScreenGui

function Library:Create(class, props)
	local inst = typeof(class) == 'string' and Instance.new(class) or class
	for k, v in pairs(props or {}) do inst[k] = v end
	return inst
end
function Library:CreateLabel(props)
	local lbl = Library:Create('TextLabel', { BackgroundTransparency = 1, FontFace = Library.Font, TextColor3 = Library.FontColor, TextSize = 12 })
	for k, v in pairs(props or {}) do lbl[k] = v end
	return lbl
end
function Library:MakeDraggable(inst, cutoff)
	inst.Active = true
	inst.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local objPos = Vector2.new(Mouse.X - inst.AbsolutePosition.X, Mouse.Y - inst.AbsolutePosition.Y)
			if objPos.Y > (cutoff or 20) then return end
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				inst.Position = UDim2.new(0, Mouse.X - objPos.X, 0, Mouse.Y - objPos.Y)
				RunService.RenderStepped:Wait()
			end
		end
	end)
end

function Library:GetDarkerColor(color)
	local h, s, v = Color3.toHSV(color)
	return Color3.fromHSV(h, s, v / 1.5)
end

function Library:UpdateColors()
	for _, obj in ipairs(Library.Registry) do
		for prop, key in pairs(obj.Properties) do
			if type(key) == 'string' then obj.Instance[prop] = Library[key] end
		end
	end
end

function Library:CreateWindow(config)
	config = config or {}
	local win = { Tabs = {} }
	local outer = Library:Create('Frame', {
		Name = 'Window',
		AnchorPoint = config.Center and Vector2.new(0.5,0.5) or Vector2.zero,
		Position = config.Center and UDim2.fromScale(0.5,0.5) or (config.Position or UDim2.fromOffset(200,100)),
		Size = config.Size or UDim2.fromOffset(700,600),
		BackgroundColor3 = Library.OutlineColor, BorderSizePixel = 0, Parent = ScreenGui,
	})
	Library:MakeDraggable(outer, 20)
	local inner = Library:Create('Frame', { Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1), BackgroundColor3 = Library.MainColor, BorderSizePixel = 0, Parent = outer })
	Library:CreateLabel({ Text = config.Title or 'MateWare', Position = UDim2.new(0,8,0,2), Size = UDim2.new(0,300,0,18), TextXAlignment = Enum.TextXAlignment.Left, Parent = inner })
	local tabBar = Library:Create('Frame', { Position = UDim2.new(0,4,0,20), Size = UDim2.new(1,-8,0,26), BackgroundTransparency = 1, Parent = inner })
	Library:Create('UIListLayout', { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabBar })
	local tabContainer = Library:Create('Frame', { Position = UDim2.new(0,4,0,48), Size = UDim2.new(1,-8,1,-52), BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Parent = inner })

	function win:AddTab(name)
		local tab = { Groupboxes = {} }
		local btn = Library:Create('TextButton', { Text = name, FontFace = Library.Font, TextSize = 12, TextColor3 = Color3.fromRGB(180,180,180), BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Size = UDim2.new(0,140,1,0), AutoButtonColor = false, Parent = tabBar })
		local page = Library:Create('Frame', { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, Parent = tabContainer })
		local left = Library:Create('ScrollingFrame', { Position = UDim2.new(0,4,0,4), Size = UDim2.new(0.5,-6,1,-8), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0,0,0,0), Parent = page })
		local right = Library:Create('ScrollingFrame', { Position = UDim2.new(0.5,2,0,4), Size = UDim2.new(0.5,-6,1,-8), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0,0,0,0), Parent = page })
		Library:Create('UIListLayout', { Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = left })
		Library:Create('UIListLayout', { Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = right })
		local function refresh(side) local s = side == 1 and left or right; s.CanvasSize = UDim2.new(0,0,0,s.UIListLayout.AbsoluteContentSize.Y + 8) end
		left.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() refresh(1) end)
		right.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() refresh(2) end)
		tab.__left, tab.__right, tab.__refresh, tab.Button, tab.Page = left, right, refresh, btn, page
		btn.MouseButton1Click:Connect(function()
			for _, t in ipairs(win.Tabs) do t.Page.Visible = false; t.Button.TextColor3 = Color3.fromRGB(180,180,180) end
			page.Visible = true; btn.TextColor3 = Library.AccentColor
		end)
		table.insert(win.Tabs, tab)
		if #win.Tabs == 1 then page.Visible = true; btn.TextColor3 = Library.AccentColor end
		tab.AddLeftGroupbox = function(_, title) return win:__AddGroup(tab, title, 1) end
		tab.AddRightGroupbox = function(_, title) return win:__AddGroup(tab, title, 2) end
		return tab
	end

	function win:__AddGroup(tab, title, side)
		local col = side == 1 and tab.__left or tab.__right
		local panel = Library:Create('Frame', { BackgroundColor3 = Library.MainColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Size = UDim2.new(1,0,0,24), AutomaticSize = Enum.AutomaticSize.Y, Parent = col })
		local pinner = Library:Create('Frame', { Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1), BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, Parent = panel })
		Library:CreateLabel({ Text = title or 'Groupbox', Position = UDim2.new(0,6,0,3), Size = UDim2.new(1,-12,0,12), TextColor3 = Library.AccentColor, TextXAlignment = Enum.TextXAlignment.Left, Parent = pinner })
		local list = Library:Create('Frame', { Position = UDim2.new(0,6,0,18), Size = UDim2.new(1,-12,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = pinner })
		Library:Create('UIListLayout', { Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
		local gb = { List = list, __refresh = tab.__refresh, __side = side }
		gb.__index = gb

		function gb:AddLabel(text, font) local l = Library:CreateLabel({ Text = text, FontFace = getFont(font), Size = UDim2.new(1,0,0,14), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Parent = self.List }); self.__refresh(self.__side); return l end
		function gb:AddDivider() Library:Create('Frame', { Size = UDim2.new(1,0,0,1), BackgroundColor3 = Library.OutlineColor, BorderSizePixel = 0, Parent = self.List }); self.__refresh(self.__side) end
		function gb:AddButton(opt)
			opt = opt or {}
			local b = Library:Create('TextButton', { Text = opt.Text or 'Button', FontFace = getFont(opt.Font), TextColor3 = Library.FontColor, BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Size = UDim2.new(1,0,0,22), AutoButtonColor = false, Parent = self.List })
			b.MouseButton1Click:Connect(function() if opt.Func then task.spawn(opt.Func) end end)
			self.__refresh(self.__side); return b
		end
		function gb:AddToggle(idx, opt)
			opt = opt or {}
			local row = Library:Create('TextButton', { Text = '', BackgroundTransparency = 1, Size = UDim2.new(1,0,0,16), AutoButtonColor = false, Parent = self.List })
			local box = Library:Create('Frame', { Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,0,0,1), BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Parent = row })
			local fill = Library:Create('Frame', { Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1), BackgroundColor3 = Color3.fromRGB(44,44,44), BorderSizePixel = 0, Parent = box })
			Library:CreateLabel({ Text = opt.Text or idx, FontFace = getFont(opt.Font), Position = UDim2.new(0,20,0,0), Size = UDim2.new(1,-20,1,0), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
			local value = opt.Default == true; local tw
			local function apply(anim) local target = value and Library.AccentColor or Color3.fromRGB(44,44,44); if tw then tw:Cancel() end; if anim then tw = TweenService:Create(fill, TweenInfo.new(0.75, Enum.EasingStyle.Quad), { BackgroundColor3 = target }); tw:Play() else fill.BackgroundColor3 = target end end
			apply(false)
			row.MouseButton1Click:Connect(function() value = not value; apply(true); if opt.Callback then task.spawn(opt.Callback, value) end end)
			local obj = { Value = value, SetValue = function(_, v) value = v; apply(true) end, OnChanged = function(_, fn) row.MouseButton1Click:Connect(function() fn(value) end) end, Type = 'Toggle' }
			Library.Toggles[idx] = obj; self.__refresh(self.__side); return obj
		end
		function gb:AddSlider(idx, opt)
			opt = opt or {}
			local min, max = opt.Min or 0, opt.Max or 100; local value = opt.Default or min
			local row = Library:Create('Frame', { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,26), Parent = self.List })
			Library:CreateLabel({ Text = opt.Text or idx, FontFace = getFont(opt.Font), Size = UDim2.new(0.6,0,0,12), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
			local valLbl = Library:CreateLabel({ Text = tostring(value), FontFace = getFont(opt.Font), Size = UDim2.new(0.4,0,0,12), Position = UDim2.new(0.6,0,0,0), TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
			local bo = Library:Create('Frame', { Size = UDim2.new(1,0,0,8), Position = UDim2.new(0,0,0,16), BackgroundColor3 = Library.OutlineColor, BorderSizePixel = 0, Parent = row })
			local bar = Library:Create('Frame', { Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1), BackgroundColor3 = Library.Black, Parent = bo })
			local fill = Library:Create('Frame', { Size = UDim2.new((value-min)/(max-min),0,1,0), BackgroundColor3 = Library.FontColor, BorderSizePixel = 0, Parent = bar })
			local dragging = false
			local function update(input) local pos, size = bar.AbsolutePosition, bar.AbsoluteSize; local fx = math.clamp((input.Position.X - pos.X)/size.X, 0, 1); value = math.floor((min+(max-min)*fx)+0.5); fill.Size = UDim2.new(fx,0,1,0); valLbl.Text = tostring(value); if opt.Callback then task.spawn(opt.Callback, value) end end
			bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input) end end)
			UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
			local changed
			local obj = { Value = value, SetValue = function(_, v) value = v; valLbl.Text = tostring(v); fill.Size = UDim2.new((v-min)/(max-min),0,1,0); if changed then task.spawn(changed, value) end end, OnChanged = function(_, fn) changed = fn end, Type = 'Slider' }
			Library.Options[idx] = obj; self.__refresh(self.__side); return obj
		end
		function gb:AddDropdown(idx, opt)
			opt = opt or {}
			local values = opt.Values or {}
			local value = opt.Default or values[1]
			if type(value) == 'number' then value = values[value] end
			local row = Library:Create('Frame', { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,34), Parent = self.List })
			Library:CreateLabel({ Text = opt.Text or idx, FontFace = getFont(opt.Font), Size = UDim2.new(1,0,0,12), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
			local btn = Library:Create('TextButton', { Text = tostring(value), FontFace = getFont(opt.Font), TextColor3 = Library.FontColor, BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Size = UDim2.new(1,0,0,18), Position = UDim2.new(0,0,0,14), AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
			Library:Create('UIPadding', { PaddingLeft = UDim.new(0,4), Parent = btn })
			local list = Library:Create('ScrollingFrame', { Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,1,0), BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Visible = false, ZIndex = 60, ScrollBarThickness = 3, CanvasSize = UDim2.new(0,0,0,0), Parent = btn })
			Library:Create('UIListLayout', { Padding = UDim.new(0,0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
			local open = false
			local function select(v) value = v; btn.Text = tostring(v); open = false; list.Visible = false; if opt.Callback then task.spawn(opt.Callback, v) end end
			for i, v in ipairs(values) do
				local item = Library:Create('TextButton', { Text = tostring(v), FontFace = getFont(opt.Font), TextColor3 = Library.FontColor, BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 0, Size = UDim2.new(1,0,0,16), LayoutOrder = i, AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = list })
				Library:Create('UIPadding', { PaddingLeft = UDim.new(0,4), Parent = item })
				item.MouseButton1Click:Connect(function() select(v) end)
			end
			list.CanvasSize = UDim2.new(0,0,0,#values*16)
			btn.MouseButton1Click:Connect(function() open = not open; list.Visible = open; list.Size = UDim2.new(1,0,0, math.min(#values*16, 100)) end)
			local obj = { Value = value, SetValue = function(_, v) select(v) end, OnChanged = function(_, fn) btn.MouseButton1Click:Connect(function() fn(value) end) end, Type = 'Dropdown' }
			Library.Options[idx] = obj; self.__refresh(self.__side); return obj
		end
		function gb:AddColorPicker(idx, opt)
			opt = opt or {}
			local value = opt.Default or Color3.new(1,0,0)
			local row = Library:Create('Frame', { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Parent = self.List })
			Library:CreateLabel({ Text = opt.Text or idx, FontFace = getFont(opt.Font), Size = UDim2.new(0.7,0,1,0), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
			local swatch = Library:Create('TextButton', { Text = '', BackgroundColor3 = value, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Size = UDim2.new(0,24,0,14), Position = UDim2.new(1,-24,0,3), AutoButtonColor = false, Parent = row })
			local popup = Library:Create('Frame', { Size = UDim2.new(0,140,0,20), Position = UDim2.new(0,0,1,2), BackgroundColor3 = Library.BackgroundColor, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, Visible = false, ZIndex = 60, Parent = swatch })
			Library:Create('UIGridLayout', { CellSize = UDim2.new(0,16,0,16), CellPadding = UDim2.new(0,2,0,2), Parent = popup })
			local palette = { Color3.fromRGB(255,0,0), Color3.fromRGB(255,128,0), Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255), Color3.fromRGB(128,0,255), Color3.fromRGB(255,0,255), Color3.new(1,1,1), Color3.new(0,0,0), Color3.fromRGB(128,128,128), Color3.fromRGB(50,50,50) }
			local function setColor(c) value = c; swatch.BackgroundColor3 = c; popup.Visible = false; if opt.Callback then task.spawn(opt.Callback, c) end end
			for _, c in ipairs(palette) do
				local b = Library:Create('TextButton', { Text = '', BackgroundColor3 = c, BorderSizePixel = 1, BorderColor3 = Library.OutlineColor, AutoButtonColor = false, Parent = popup })
				b.MouseButton1Click:Connect(function() setColor(c) end)
			end
			swatch.MouseButton1Click:Connect(function() popup.Visible = not popup.Visible end)
			local obj = { Value = value, SetValue = function(_, v) setColor(v) end, OnChanged = function(_, fn) end, Type = 'ColorPicker' }
			Library.Options[idx] = obj; self.__refresh(self.__side); return obj
		end

		return gb
	end

	return win
end

return Library
