-- ThemeManager (estilo Linoria) para la MateWare UI Library
local HttpService = game:GetService('HttpService')

local ThemeManager = {}
ThemeManager.Folder = 'MateWareSettings'
ThemeManager.Library = nil
ThemeManager.BuiltInThemes = {
	['Default'] = { 1, { FontColor = 'ffffff', MainColor = '1b1b21', AccentColor = '00ff00', BackgroundColor = '0e0e11', OutlineColor = '444453' } },
	['BBot'] = { 2, { FontColor = 'ffffff', MainColor = '1e1e1e', AccentColor = '7e48a3', BackgroundColor = '232323', OutlineColor = '141414' } },
	['Fatality'] = { 3, { FontColor = 'ffffff', MainColor = '1e1842', AccentColor = 'c50754', BackgroundColor = '191335', OutlineColor = '3c355d' } },
	['Jester'] = { 4, { FontColor = 'ffffff', MainColor = '242424', AccentColor = 'db4467', BackgroundColor = '1c1c1c', OutlineColor = '373737' } },
	['Mint'] = { 5, { FontColor = 'ffffff', MainColor = '242424', AccentColor = '3db488', BackgroundColor = '1c1c1c', OutlineColor = '373737' } },
	['Tokyo Night'] = { 6, { FontColor = 'ffffff', MainColor = '191925', AccentColor = '6759b3', BackgroundColor = '16161f', OutlineColor = '323232' } },
	['Ubuntu'] = { 7, { FontColor = 'ffffff', MainColor = '3e3e3e', AccentColor = 'e2581e', BackgroundColor = '323232', OutlineColor = '191919' } },
	['Quartz'] = { 8, { FontColor = 'ffffff', MainColor = '232330', AccentColor = '426e87', BackgroundColor = '1d1b26', OutlineColor = '27232f' } },
}

local fs = (isfolder and makefolder and isfile and readfile and writefile and listfiles)

function ThemeManager:ApplyTheme(theme)
	local customThemeData = self:GetCustomTheme(theme)
	local data = customThemeData or self.BuiltInThemes[theme]
	if not data then return end
	local scheme = customThemeData or data[2]
	for idx, col in next, scheme do
		self.Library[idx] = Color3.fromHex(col)
		if self.Library.Options[idx] then
			self.Library.Options[idx]:SetValue(Color3.fromHex(col))
		end
	end
	self:ThemeUpdate()
end

function ThemeManager:ThemeUpdate()
	local options = { 'FontColor', 'MainColor', 'AccentColor', 'BackgroundColor', 'OutlineColor' }
	for _, field in next, options do
		if self.Library.Options[field] then
			self.Library[field] = self.Library.Options[field].Value
		end
	end
	local lib = self.Library
	if lib.GetDarkerColor then
		lib.AccentColorDark = lib:GetDarkerColor(lib.AccentColor)
	else
		lib.AccentColorDark = lib.AccentColor
	end
	lib:UpdateColors()
end

function ThemeManager:CreateThemeManager(groupbox)
	groupbox:AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor, Text = 'Background color' })
	groupbox:AddColorPicker('MainColor', { Default = self.Library.MainColor, Text = 'Main color' })
	groupbox:AddColorPicker('AccentColor', { Default = self.Library.AccentColor, Text = 'Accent color' })
	groupbox:AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor, Text = 'Outline color' })
	groupbox:AddColorPicker('FontColor', { Default = self.Library.FontColor, Text = 'Font color' })

	local ThemesArray = {}
	for Name in next, self.BuiltInThemes do table.insert(ThemesArray, Name) end
	table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

	groupbox:AddDivider()
	local themeDropdown = groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })
	themeDropdown:OnChanged(function(Value) self:ApplyTheme(Value) end)

	local function UpdateTheme() self:ThemeUpdate() end
	self.Library.Options.BackgroundColor:OnChanged(UpdateTheme)
	self.Library.Options.MainColor:OnChanged(UpdateTheme)
	self.Library.Options.AccentColor:OnChanged(UpdateTheme)
	self.Library.Options.OutlineColor:OnChanged(UpdateTheme)
	self.Library.Options.FontColor:OnChanged(UpdateTheme)
end

function ThemeManager:SetLibrary(lib) self.Library = lib end
function ThemeManager:SetFolder(folder)
	self.Folder = folder
	if fs then
		local paths = { self.Folder, self.Folder .. '/themes', self.Folder .. '/settings' }
		for _, str in ipairs(paths) do if not isfolder(str) then pcall(makefolder, str) end end
	end
end
function ThemeManager:GetCustomTheme(file)
	if not fs then return nil end
	local path = self.Folder .. '/themes/' .. file
	if not isfile(path) then return nil end
	local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	return ok and decoded or nil
end

local function getTab(tab)
	assert(ThemeManager.Library, 'Must set ThemeManager.Library first!')
	return tab:AddLeftGroupbox('Themes')
end
function ThemeManager:ApplyToTab(tab)
	ThemeManager:CreateThemeManager(getTab(tab))
end
function ThemeManager:ApplyToGroupbox(groupbox)
	ThemeManager:CreateThemeManager(groupbox)
end

return ThemeManager
