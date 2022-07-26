
---@class CraftUI : UI
local Craft = {
    nextSetInventoryIsFromEngine = false,

    FILTERS = {
        ALL = 0,
        UNKNOWN = 1,
        EQUIPMENT = 2,
        CONSUMABLES = 3,
        MAGICAL = 4,
        INGREDIENTS = 5,
        MISCELLANEOUS = 6,
    },

    USE_LEGACY_EVENTS = false,
    Events = {
        FilterSelected = {}, ---@type SubscribableEvent<CraftUI_Event_FilterSelected>
        CharacterSelected = {}, ---@type SubscribableEvent<CraftUI_Event_CharacterSelected>
    }
}
Epip.InitializeUI(102, "Craft", Craft)
Client.UI.Craft = Craft

---@alias CraftUI_Filter "All"|"Unknown"|"Equipment"|"Consumables"|"Magical"|"Ingredients"|"Miscellaneous"

---------------------------------------------
-- EVENTS
---------------------------------------------

---Invoked when a filter is selected.
---@class CraftUI_Event_FilterSelected
---@field Filter CraftUI_Filter
---@field Scripted boolean True if the filter was set by script.
---@field IsFromEngine boolean

---Fired when a character is selected. Also fires upon the UI being open.
---@class CraftUI_Event_CharacterSelected
---@field Character EclCharacter
---@field IsAvatar boolean

---------------------------------------------
-- METHODS
---------------------------------------------

---@param filter CraftUI_Filter|integer
function Craft.SelectFilter(filter)
    if type(filter) == "string" then
        filter = Craft.FILTERS[filter:upper()]
    end

    Craft:ExternalInterfaceCall("setInventoryView", filter, true)
    Craft:GetRoot().selectFilterTab(filter)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Craft:RegisterInvokeListener("setPlayer", function(e, handle, isAvatar)
    Craft.Events.CharacterSelected:Throw({
        Character = Character.Get(handle, true),
        IsAvatar = isAvatar,
    })

    Craft.nextSetInventoryIsFromEngine = true
end, "After")

Craft:RegisterCallListener("setInventoryView", function(ev, index, scripted)
    local filterName = Text.Capitalize(table.reverseLookup(Craft.FILTERS, index))

    Craft.Events.FilterSelected:Throw({
        Filter = filterName,
        Scripted = scripted or false,
        IsFromEngine = Craft.nextSetInventoryIsFromEngine or false,
    })
    
    Craft.nextSetInventoryIsFromEngine = false
end, "After")