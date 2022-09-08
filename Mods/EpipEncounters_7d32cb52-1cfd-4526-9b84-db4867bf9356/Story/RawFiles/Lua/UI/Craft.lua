
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
        RecipesUpdated = {}, ---@type SubscribableEvent<CraftUI_Event_RecipesUpdated>
    }
}
Epip.InitializeUI(102, "Craft", Craft)

---@alias CraftUI_Filter "All"|"Unknown"|"Equipment"|"Consumables"|"Magical"|"Ingredients"|"Miscellaneous"

---@class CraftUI_RecipeUpdate
---@field GroupID number
---@field RecipeID number
---@field Name string
---@field Tooltip string
---@field Value number
---@field IsNew boolean

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

---@class CraftUI_Event_RecipesUpdated
---@field Recipes CraftUI_RecipeUpdate

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

Craft:RegisterInvokeListener("updateArraySystem", function(_)
    local arr = Craft:GetRoot().recipe_array
    
    ---@type CraftUI_RecipeUpdate[]
    local recipes = Client.Flash.ParseArray(arr, {
        "GroupID",
        "RecipeID",
        "Name",
        "Tooltip",
        "Value",
        "IsNew",
    })

    Craft.Events.RecipesUpdated:Throw({
        Recipes = recipes,
    })
end)

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