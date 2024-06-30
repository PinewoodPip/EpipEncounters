
local Vanity = Client.UI.Vanity

---@class CharacterSheetCustomTab
---@field Icon string
---@field Name string
---@field ID string

---@class CharacterSheetCustomTab
local _CharacterSheetTab = {
    Icon = "unknown",
    Name = "NO NAME",
}
Vanity._Tab = _CharacterSheetTab

---@param data CharacterSheetCustomTab
---@return CharacterSheetCustomTab
function _CharacterSheetTab.Create(data)
    Inherit(data, _CharacterSheetTab)

    return data
end

function _CharacterSheetTab:Render() end

---@param event LegacyEvent
---@param handler fun(id:string, ...)
function _CharacterSheetTab:RegisterListener(event, handler)
    event:RegisterListener(function (tab, id, ...)
        if tab == self then
            handler(id, ...)
        end
    end)
end
