
---------------------------------------------
-- Hooks for the Examine UI.
---------------------------------------------

local Flash = Client.Flash
local ParseFlashArray, EncodeFlashArray = Flash.ParseArray, Flash.EncodeArray
local V = Vector.Create

---@class ExamineUI : UI
local Examine = {

    _FLASH_STATS_ARRAY_TEMPLATE = {
        "EntryType",
        "StatID",
        "IconID",
        "Label",
        "ValueLabel",
    },

    CATEGORIES = {
        RESISTANCES = 1, -- Entry type 1
        TALENTS = 3, -- Entry type 3
        STATS = 4, -- Entry type 2
    },

    ---@enum UI.Examine.Entry.Type
    ENTRY_TYPES = {
        PRIMARY_STAT = 1,
        SECONDARY_STAT = 2,
        TALENT = 3,
        STATUS = 7,
        IMMUNITY = 8,
    },

    -- IDs for embedded icons. Named after what they're used for in Character Sheet, if they appear there; otherwise they're named after appearance/DOS1 usage.
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

    _IsUpdatingArray = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Opened = {}, ---@type Event<ExamineUI_Event_Opened>
        TooltipRequested = {}, ---@type Event<UI.Examine.Events.TooltipRequested>
    },
    Hooks = {
        GetUpdateData = {}, ---@type Event<ExamineUI_Hook_GetUpdateData>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.examine, "Examine", Examine)

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when the UI is opened.
---@class ExamineUI_Event_Opened
---@field Data ExamineUI_UpdateData

---@class ExamineUI_Hook_GetUpdateData
---@field Data ExamineUI_UpdateData Hookable.

---@class UI.Examine.Events.TooltipRequested
---@field TooltipType UI.Examine.Entry.Type
---@field StatOrHandle number
---@field Position Vector2
---@field Size Vector2
---@field Alignment "right"

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class ExamineUI_UpdateData_Entry
---@field EntryType UI.Examine.Entry.Type
---@field StatID integer
---@field IconID integer
---@field Label string
---@field ValueLabel string

---@class ExamineUI_UpdateData_Category : Class
---@field Entries ExamineUI_UpdateData_Entry[]
---@field ID integer
---@field Label string
---@field EntryType integer
local _Category = {
    __name = "ExamineUI_UpdateData_Category"
}
OOP.RegisterClass("ExamineUI_UpdateData_Category", _Category)

---@param id integer
---@param label string
---@param entryType integer
---@return ExamineUI_UpdateData_Category
function _Category:Create(id, label, entryType)
    ---@type ExamineUI_UpdateData_Category
    local instance = {
        Entries = {},
        ID = id,
        Label = label,
        EntryType = entryType,
    }
    self:__Create(instance)

    return instance
end

---Adds an entry to the category.
---@param entry ExamineUI_UpdateData_Entry
function _Category:AddEntry(entry)
    table.insert(self.Entries, entry)
end

-- Represents the contents of an update to the UI.
---@class ExamineUI_UpdateData : Class
---@field Categories ExamineUI_UpdateData_Category[]
local _ExamineData = {}
OOP.RegisterClass("ExamineUI_UpdateData", _ExamineData)

---Creates a new instance of UpdateData.
---@return ExamineUI_UpdateData
function _ExamineData:Create()
    ---@type ExamineUI_UpdateData
    local instance = {
        Categories = {}
    }
    self:__Create(instance)

    return instance
end

---Adds a category.
---@param category ExamineUI_UpdateData_Category
function _ExamineData:AddCategory(category)
    table.insert(self.Categories, category)
end

---Get a category of entries by its id.
---@param id number
---@return ExamineUI_UpdateData_Category?
function _ExamineData:GetCategory(id)
    local foundCategory = nil
    for _,category in pairs(self.Categories) do
        if category.ID == id then
            foundCategory = category
            break
        end
    end
    return foundCategory
end

---Inserts an element into a category at the specified index, appending by default.
---@param category integer
---@param entry ExamineUI_UpdateData_Entry
---@param index? integer Defaults to appending.
function _ExamineData:AddEntry(category, entry, index)
    local categoryData = self:GetCategory(category)
    index = index or #categoryData.Entries

    if categoryData then
        table.insert(categoryData.Entries, index, entry)
    else
        Examine:Error("UpdateData:InsertElement", "Category not found for ExamineData:InsertElement(): " .. category)
    end
end

---Returns the first entry with a specific stat ID.
---@param statID integer
---@param category integer? If `nil`, all categories are searched.
---@return ExamineUI_UpdateData_Entry?, integer?, integer? --Entry, category ID, index within category.
function _ExamineData:GetEntry(statID, category)
    local foundEntry = nil
    local categoryID, categoryIndex = nil, nil

    for _,searchCategory in ipairs(self.Categories) do
        if not category or searchCategory.ID == category then
            for entryIndex,entry in pairs(searchCategory.Entries) do
                if entry.StatID == statID then
                    foundEntry = entry
                    categoryID = searchCategory.ID
                    categoryIndex = entryIndex
                    goto End
                end
            end
        end
    end
    ::End::

    return foundEntry, categoryID, categoryIndex
end

---Encodes the data to be sent back to Flash.
---@return table[]
function _ExamineData:Encode()
    local newArray = {}
    for _,category in ipairs(self.Categories) do
        table.insert(newArray, {
            EntryType = category.EntryType,
            StatID = category.ID,
            IconID = 0,
            Label = category.Label,
            ValueLabel = 0,
        })

        for _,entry in ipairs(category.Entries) do
            table.insert(newArray, {
                EntryType = entry.EntryType,
                StatID = entry.StatID,
                IconID = entry.IconID,
                Label = entry.Label,
                ValueLabel = entry.ValueLabel,
            })
        end
    end

    return newArray
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the character currently being examined.
---@return EclCharacter? -- `nil` if no character is being examined, such as when an item is being examined or the UI is hidden.
function Examine.GetCharacter()
    local char = nil
    if Examine:IsVisible() or Examine._IsUpdatingArray then
        char = Ext.Entity.GetGameObject(Examine:GetUI():GetPlayerHandle()) ---@cast char EclCharacter|EclItem
        if not Entity.IsCharacter(char) then
            char = nil
        end
    end
    return char
end

---Returns the item currently being examined.
---@return EclItem? -- `nil` if no item is being examined, such as when a character is being examined or the UI is hidden.
function Examine.GetItem()
    local item = nil
    if Examine:IsVisible() or Examine._IsUpdatingArray then
        -- Yes. You're reading this right.
        item = Ext.Entity.GetGameObject(Examine:GetUI():GetPlayerHandle())  ---@cast item EclCharacter|EclItem
        if not Entity.IsItem(item) then
            item = nil
        end
    end
    return item
end

---Parses the current contents of the Flash update arrays.
---@return ExamineUI_UpdateData
function Examine._ParseEntries()
    local root = Examine:GetRoot()
    local statsArray = root.addStats_array

    ---@type ExamineUI_UpdateData_Entry[]
    local array = ParseFlashArray(statsArray, Examine._FLASH_STATS_ARRAY_TEMPLATE)

    local updateData = _ExamineData:Create()
    for _,entry in ipairs(array) do
        if entry.EntryType == 5 then
            updateData:AddCategory(_Category:Create(entry.StatID, entry.Label, entry.EntryType))
        else
            updateData.Categories[#updateData.Categories]:AddEntry(entry)
        end
    end

    Examine:Dump(updateData)

    return updateData
end

-- Sends update info back to Flash.
---@param data ExamineUI_UpdateData
function Examine._EncodeEntries(data)
    local root = Examine:GetRoot()
    local statsArray = root.addStats_array
    local newArray = data:Encode()

    EncodeFlashArray(statsArray, Examine._FLASH_STATS_ARRAY_TEMPLATE, newArray)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Hook the update method.
Examine:RegisterInvokeListener("update", function (_)
    local updateData = Examine._ParseEntries()

    -- Necessary flag for GetCharacter() and GetItem() to work as intended, since at this point the UI might not be visible, but the player handle is already set - and stays even after the UI is closed.
    Examine._IsUpdatingArray = true

    updateData = Examine.Hooks.GetUpdateData:Throw({
        Data = updateData,
    }).Data


    Examine._EncodeEntries(updateData)

    Examine.Events.Opened:Throw({
        Data = updateData
    })

    Examine._IsUpdatingArray = false
end)

-- Forward events for tooltips being requested; useful to handle custom stat entries.
Examine:RegisterCallListener("showTooltip", function (ev, tooltipType, statID, x, y, w, h, alignment)
    if #ev.Args > 1 then -- Arg count of 1 is used for user tooltip.
        Examine.Events.TooltipRequested:Throw({
            TooltipType = tooltipType,
            StatOrHandle = statID,
            Position = V(x, y),
            Size = V(w, h),
            Alignment = alignment,
        })
    end
end)
