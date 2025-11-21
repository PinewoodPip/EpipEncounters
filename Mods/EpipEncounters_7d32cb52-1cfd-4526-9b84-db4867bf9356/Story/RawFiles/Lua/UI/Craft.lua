
---------------------------------------------
-- APIs for the uiCraft.swf UI.
---------------------------------------------

local Flash = Client.Flash
local ParseFlashArray = Flash.ParseArray
local Set = DataStructures.Get("DataStructures_Set")

---@class CraftUI : UI
local Craft = {
    nextSetInventoryIsFromEngine = false,

    ---TODO move this elsewhere - this filter list is actually shared with inventory!
    ---@type table<integer, CraftUI_Filter>
    FILTERS = {
        [0] = {
            Handle = "h6675c3a8gbf70g4dc8gb7a5gef27b366fc6c",
            StringID = "All",
        },
        [1] = {
            Handle = "ha1ff7c28g1ddcg41d2g92e4g3b15371c596d",
            StringID = "Equipped",
        },
        [2] = {
            Handle = "h2d0c1120g4202g414dg9b9bg2e5e73e2b1aa",
            StringID = "Equipment",
        },
        [3] = {
            Handle = "ha9b9119fga6c1g44d6ga594g06661a275ee1",
            StringID = "Consumables",
        },
        [4] = {
            Handle = "h9da3be37gadf4g4777ga7e6g6ef0c1f907b0",
            StringID = "Magical",
        },
        [5] = {
            Handle = "h19daaa91gecafg451dgb193g29c64273332f",
            StringID = "Ingredients",
        },
        [6] = {
            Handle = "hb8ed2061ge5a3g4f64g9d54g9a9b65e27e1e",
            StringID = "Miscellaneous",
        },
        [7] = {
            Handle = "h3206d347ge18eg4123g8da5g057753be0d22",
            StringID = "BooksAndKeys",
        },
        [8] = {
            Handle = "h312452fbg64ddg44d0gaab4g5e3ed03689be",
            StringID = "Wares",
        },
    },

    FILTER_IDS = {
        ALL = 0,
        UNKNOWN = 1,
        EQUIPMENT = 2,
        CONSUMABLES = 3,
        MAGICAL = 4,
        INGREDIENTS = 5,
        MISCELLANEOUS = 6,
        BOOKS_AND_KEYS = 7,
        WARES = 8,
    },

    -- Filters used by the base game.
    VANILLA_FILTERS_IDS = Set.Create({0, 2, 3, 4, 5, 6}),

    USE_LEGACY_EVENTS = false,
    Events = {
        FilterSelected = {}, ---@type Event<CraftUI_Event_FilterSelected>
        CharacterSelected = {}, ---@type Event<CraftUI_Event_CharacterSelected>
        RecipesUpdated = {}, ---@type Event<CraftUI_Event_RecipesUpdated>
    }
}
Epip.InitializeUI(102, "Craft", Craft)

-- Set up ID field for filters
for id,filter in pairs(Craft.FILTERS) do
    filter.ID = id
end

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias CraftUI_Filter_Type "All"|"Equipped"|"Equipment"|"Consumables"|"Magical"|"Ingredients"|"Miscellaneous"|"BooksAndKeys"|"Wares"

---@class CraftUI_Filter
---@field Handle TranslatedStringHandle
---@field ID integer
---@field StringID CraftUI_Filter_Type

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
---@field Filter CraftUI_Filter_Type
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

---@param filter CraftUI_Filter_Type|integer
function Craft.SelectFilter(filter)
    if type(filter) == "string" then
        filter = Craft.FILTER_IDS[filter:upper()]
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
    local recipes = ParseFlashArray(arr, {
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

Craft:RegisterInvokeListener("setPlayer", function(_, handle, isAvatar)
    Craft.Events.CharacterSelected:Throw({
        Character = Character.Get(handle, true),
        IsAvatar = isAvatar,
    })

    Craft.nextSetInventoryIsFromEngine = true
end, "After")

Craft:RegisterCallListener("setInventoryView", function(_, index, scripted)
    local filterName = Craft.FILTERS[index].StringID

    Craft.Events.FilterSelected:Throw({
        Filter = filterName,
        Scripted = scripted or false,
        IsFromEngine = Craft.nextSetInventoryIsFromEngine or false,
    })
    
    Craft.nextSetInventoryIsFromEngine = false
end, "After")