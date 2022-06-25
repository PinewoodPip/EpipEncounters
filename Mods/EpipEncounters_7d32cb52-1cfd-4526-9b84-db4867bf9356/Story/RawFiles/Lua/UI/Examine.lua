
---------------------------------------------
-- Hooks for the Examine UI.
---------------------------------------------

---@meta Library: ExamineUI, ContextClient

---@class ExamineUI
---@field CATEGORIES table<string, number>
---@field ENTRY_TYPES table<string, number>
---@field ICONS table<string, number> IDs for embedded icons.

---@type ExamineUI
local Examine = {

    CATEGORIES = {
        RESISTANCES = 1, -- Entry type 1
        TALENTS = 3, -- Entry type 3
        STATS = 4, -- Entry type 2
    },

    ENTRY_TYPES = {
        STAT = 1, -- TODO is this only res?
        TALENT = 3,
        -- STAT = 2,
    },

    -- Named after what they're used for in Character Sheet, if they appear there; otherwise they're named after appearance/DOS1 usage.
    ICONS = {
        NONE = 0,
        ACTION_POINT = 1,
        PHYSICAL_ARMOR = 2,
        MAGIC_ARMOR = 3,
        CONSTITUTION = 4,
        CRITICAL_CHANCE = 5,
        DAMAGE = 6,
        SHIELD = 7,
        FINESSE = 8,
        HEARING = 9,
        INITIATIVE = 10,
        INTELLIGENCE = 11,
        MOVEMENT = 12,
        WARAXE = 13,
        WITS = 14,
        STAR_DOS1 = 15,
        AIR_RESISTANCE = 16,
        EARTH_RESISTANCE = 17,
        FIRE_RESISTANCE = 18,
        POISON_RESISTANCE = 19,
        ROT = 20,
        WATER_RESISTANCE = 21,
        SIGHT = 22,
        DODGE = 23,
        STRENGTH = 24,
        VITALITY = 25,
        TARGET = 29, -- DOS1 Accuracy icon.
        STAR = 30,
        BODYBUILDING = 31,
        WILLPOWER = 32,
        ACCURACY = 33,
        LOCK = 34,
        MEMORY = 36,
        DIAMOND = 37,
        AEROTHEURGE = 38,
        WARFARE = 39,
        GEOMANCER = 40,
        PYROKINETIC = 41,
        NECROMANCER = 42,
        POLYMORPH = 43,
        HUNTSMAN = 44,
        SCOUNDREL = 45,
        UNKNOWN_CLASS = 46,
        SUMMONING = 47,
        HYDROSOPHIST = 48,
        SOURCERY = 49,
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/examine.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/examine.swf",
    },
}
Client.UI.Examine = Examine
Epip.InitializeUI(Client.UI.Data.UITypes.examine, "Examine", Examine)

-- Represents the contents of an update to the UI.
---@class ExamineData
---@field Categories table[]

---@type ExamineData
local ExamineData = {}

---Get a category of entries by its id.
---@param id number
function ExamineData:GetCategory(id)
    for i,category in pairs(self.Categories) do
        if category.id == id then
            return category
        end
    end
    return nil
end

---Inserts an element into a category at the specified index, appending by default.
---@param category id
---@param element table
---@param index? number
function ExamineData:InsertElement(category, element, index)
    local categoryData = self:GetCategory(category) -- TODO accept category obj as param
    if categoryData then
        table.insert(categoryData.entries, index or #categoryData.entries, element)
    else
        Examine:LogError("Category not found for ExamineData:InsertElement(): " .. category)
    end
end

---Returns the first element, its index and category, using the engine statID.
---@param category? number If nil, all categories are searched.
---@param statID number
function ExamineData:GetElement(category, statID)
    category = self:GetCategory(category)

    local categories = self.Categories -- search all categories if category requested is nil
    if category then categories = {category} end
    
    for id,category in pairs(categories) do
        for index,element in pairs(category.entries) do
            if element.id == statID then
                return element, index, category
            end
        end
    end
end

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when the UI is opened.
---@class ExamineUI_ExamineOpened : Event
---@field categories ExamineData

---Hook to manipulate the update data.
---@class ExamineUI_Update : Hook
---@field data ExamineData

---------------------------------------------
-- METHODS
---------------------------------------------

---Get the character currently being examined.
---@return EclCharacter
function Examine.GetCharacter()
    return Ext.GetCharacter(Examine:GetUI():GetPlayerHandle())
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

-- Parse the current contents of the Flash update arrays.
function Examine.ParseEntries()
    local root = Examine:GetRoot()
    local statsArray = root.addStats_array

    local categories = {}

    -- Parse entries.
    -- We sort them into categories (delimited by the header elements)
    local currentCategory = nil
    for i=0,#statsArray-1,5 do
        local type = statsArray[i]
        local entry = {}

        -- Keys ordered by parameter order in ActionScript.
        if type == 5 then
            entry = {
                id = statsArray[i + 1], -- Stat ID, loc3
                label = statsArray[i + 3], -- wrong?, loc5
                type = statsArray[i], -- loc2
            }

            -- Insert category
            table.insert(categories, {
                id = entry.id,
                label = entry.label,
                type = entry.type,

                entries = {},
            })

            currentCategory = entry.id
        else
            entry = {
                id = statsArray[i + 1], -- loc3
                iconID = statsArray[i + 2], -- 
                label = statsArray[i + 3], -- loc5
                value = statsArray[i + 4], -- 
                type = statsArray[i], -- loc2
            }

            table.insert(categories[#categories].entries, entry)
        end
    end

    categories = {
        Categories = categories
    }
    setmetatable(categories, {__index = ExamineData})

    if Examine.IS_DEBUG then
        Ext.Dump(categories)
    end

    return categories
end

-- Send entry info back to Flash.
function Examine.EncodeEntries(categories)
    local newArray = {}
    for index,category in pairs(categories.Categories) do
        -- Add category header
        local entry = {
            category.type, -- loc2
            category.id, -- loc3
            0,
            category.label, -- loc5
            0,
        }
        for z,value in pairs(entry) do
            table.insert(newArray, value)
        end

        -- Add category entries
        for i,data in pairs(category.entries) do
            entry = {
                data.type, -- loc2
                data.id, -- loc3
                data.iconID, -- loc4
                data.label, -- loc5
                data.value, --loc6
            }
    
            for z,value in pairs(entry) do
                table.insert(newArray, value)
            end
        end
    end

    Game.Tooltip.TableToFlash(Examine:GetUI(), "addStats_array", newArray)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Hook the update method.
Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.examine, "update", function(ui, method)
    local categories = Examine.ParseEntries()

    -- Gather modifications from hooks
    categories = Examine:ReturnFromHooks("Update", categories)

    -- Send back to Flash
    Examine.EncodeEntries(categories)

    Examine:FireEvent("ExamineOpened", categories)
end, "Before")