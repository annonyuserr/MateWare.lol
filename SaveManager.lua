-- SaveManager (estilo Linoria) para la MateWare UI Library
local HttpService = game:GetService('HttpService')

local SaveManager = {}
SaveManager.Folder = 'MateWareSettings'
SaveManager.Ignore = {}
SaveManager.Library = nil

local fs = (isfolder and makefolder and isfile and readfile and writefile)

SaveManager.Parser = {
	Toggle = {
		Save = function(idx, object) return { type = 'Toggle', idx = idx, value = object.Value } end,
		Load = function(idx, data) if SaveManager.Library.Toggles[idx] then SaveManager.Library.Toggles[idx]:SetValue(data.value) end end,
	},
	Slider = {
		Save = function(idx, object) return { type = 'Slider', idx = idx, value = tostring(object.Value) } end,
		Load = function(idx, data) if SaveManager.Library.Options[idx] then SaveManager.Library.Options[idx]:SetValue(tonumber(data.value)) end end,
	},
	Dropdown = {
		Save = function(idx, object) return { type = 'Dropdown', idx = idx, value = object.Value } end,
		Load = function(idx, data) if SaveManager.Library.Options[idx] then SaveManager.Library.Options[idx]:SetValue(data.value) end end,
	},
	ColorPicker = {
		Save = function(idx, object) return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex() } end,
		Load = function(idx, data) if SaveManager.Library.Options[idx] then SaveManager.Library.Options[idx]:SetValue(Color3.fromHex(data.value)) end end,
	},
}

function SaveManager:SetLibrary(lib) self.Library = lib end
function SaveManager:SetIgnoreIndexes(list) for _, key in next, list do self.Ignore[key] = true end end
function SaveManager:SetFolder(folder)
	self.Folder = folder
	if fs then
		local paths = { self.Folder, self.Folder .. '/settings' }
		for _, str in ipairs(paths) do if not isfolder(str) then pcall(makefolder, str) end end
	end
end

function SaveManager:Save(name)
	if not name then return false, 'no config name' end
	if not fs then return false, 'filesystem not available (Studio)' end
	local fullPath = self.Folder .. '/settings/' .. name .. '.json'
	local data = { objects = {} }
	for idx, toggle in next, self.Library.Toggles do
		if not self.Ignore[idx] and self.Parser[toggle.Type] then
			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end
	end
	for idx, option in next, self.Library.Options do
		if not self.Ignore[idx] and self.Parser[option.Type] then
			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end
	end
	local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
	if not ok then return false, 'encode error' end
	pcall(writefile, fullPath, encoded)
	return true
end

function SaveManager:Load(name)
	if not name then return false, 'no config name' end
	if not fs then return false, 'filesystem not available (Studio)' end
	local file = self.Folder .. '/settings/' .. name .. '.json'
	if not isfile(file) then return false, 'invalid file' end
	local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
	if not ok then return false, 'decode error' end
	for _, option in next, decoded.objects do
		if self.Parser[option.type] then
			task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
		end
	end
	return true
end

function SaveManager:RefreshConfigList()
	if not fs then return {} end
	local list = listfiles(self.Folder .. '/settings')
	local out = {}
	for _, file in ipairs(list) do
		if file:sub(-5) == '.json' then
			local pos = file:find('.json', 1, true)
			local start = pos
			local char = file:sub(pos, pos)
			while char ~= '/' and char ~= '\\' and char ~= '' do pos = pos - 1; char = file:sub(pos, pos) end
			if char == '/' or char == '\\' then table.insert(out, file:sub(pos + 1, start - 1)) end
		end
	end
	return out
end

function SaveManager:IgnoreThemeSettings()
	self:SetIgnoreIndexes({ 'BackgroundColor', 'MainColor', 'AccentColor', 'OutlineColor', 'FontColor', 'ThemeManager_ThemeList' })
end

function SaveManager:BuildConfigSection(tab)
	assert(self.Library, 'Must set SaveManager.Library')
	local section = tab:AddRightGroupbox('Configuration')
	section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), Default = 1 })
	section:AddDivider()
	section:AddButton({ Text = 'Create config', Func = function()
		local name = self.Library.Options.SaveManager_ConfigName and self.Library.Options.SaveManager_ConfigName.Value
		if not name then return end
		self:Save(name)
		self.Library:Notify('Created config ' .. name)
	end })
	section:AddButton({ Text = 'Load config', Func = function()
		local obj = self.Library.Options.SaveManager_ConfigList
		local name = obj and obj.Value
		if name then self:Load(name) end
	end })
end

return SaveManager
