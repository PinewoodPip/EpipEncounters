
local RadialMenus = Epip.GetFeature("Features.RadialMenus")

---@class Features.RadialMenus.Menu : Class
---@field GUID GUID
---@field Name string Can be user-defined, thus untranslatable.
local _Menu = {}
RadialMenus:RegisterClass("Features.RadialMenus.Menu", _Menu)

---@class Features.RadialMenus.Menu.SaveData
---@field ClassName classname
---@field GUID GUID
---@field Name string

---------------------------------------------
-- METHODS
---------------------------------------------

---Base constructor. Initializes the GUID field.
---@param name string
---@return Features.RadialMenus.Menu
function _Menu:Create(name)
    local instance = self:__Create() ---@cast instance Features.RadialMenus.Menu
    instance.Name = name
    instance.GUID = Text.GenerateGUID()
    return instance
end

---Creates a menu from saved data.
---Overrides should call the base method.
---@virtual
---@param saveData Features.RadialMenus.Menu.SaveData
---@return Features.RadialMenus.Menu
function _Menu:CreateFromSaveData(saveData)
    local instance = _Menu.Create(self, saveData.Name)
    instance.GUID = saveData.GUID
    return instance
end

---Returns the slots of the menu.
---@abstract
---@return Features.RadialMenus.Slot[]
---@diagnostic disable-next-line: missing-return
function _Menu:GetSlots() end

---Returns the save data for the menu.
---Overrides should call the base method.
---@virtual
---@return Features.RadialMenus.Menu.SaveData
function _Menu:GetSaveData()
    ---@type Features.RadialMenus.Menu.SaveData
    local data = {
        ClassName = self:GetClassName(),
        Name = self.Name,
        GUID = self.GUID,
    }
    return data
end

---Returns a user-friendly name for this kind of menu.
---@abstract
---@return TextLib_String
---@diagnostic disable-next-line: missing-return
function _Menu:GetTypeName() end
