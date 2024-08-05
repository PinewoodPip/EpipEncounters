
local RadialMenus = Epip.GetFeature("Features.RadialMenus")

---@class Features.RadialMenus.Menu : Class
---@field Name string Can be user-defined, thus untranslatable.
local _Menu = {}
RadialMenus:RegisterClass("Features.RadialMenus.Menu", _Menu)

---Returns the slots of the menu.
---@abstract
---@return Features.RadialMenus.Slot[]
---@diagnostic disable-next-line: missing-return
function _Menu:GetSlots() end

---Returns a user-friendly name for this kind of menu.
---@abstract
---@return TextLib_String
---@diagnostic disable-next-line: missing-return
function _Menu:GetTypeName() end
