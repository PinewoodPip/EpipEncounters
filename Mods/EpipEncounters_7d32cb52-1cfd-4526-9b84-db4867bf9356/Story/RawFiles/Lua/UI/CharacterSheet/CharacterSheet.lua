
---------------------------------------------
-- Hooks for characterSheet.swf.
---------------------------------------------

---@meta CharacterSheetUI, ContextClient

---@class CharacterSheetUI
---@field StatsTab CharacterSheetStatsTab
---@field SECONDARY_STAT_GROUPS table<string, number> IDs of secondarystat groups.

---@type CharacterSheetUI
local CharacterSheet = {
    StatsTab = {}, -- See StatsTab.lua

    ---@type SecondaryStatGroup
    SECONDARY_STAT_GROUPS = {
        BELOW_CHARACTER = 0,
        SECONDARY = 1,
        RESISTANCE = 2,
        MISCELLANEOUS = 3,
    },
    TABS = {
        ATTRIBUTES = 0,
        ABILITIES = 1,
        CIVILS = 2,
        TALENTS = 3,
        CUSTOM_STATS = 8,
    },
    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/characterSheet.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/characterSheet.swf",
    },
}
if IS_IMPROVED_HOTBAR then
    CharacterSheet.FILEPATH_OVERRIDES = {}
end
Epip.InitializeUI(Client.UI.Data.UITypes.characterSheet, "CharacterSheet", CharacterSheet)

---@alias SecondaryStatGroup table<string, number>

---@class SecondaryStatBase

---@class SecondaryStat : SecondaryStatBase
---@field IsSpacingElement boolean
---@field Group SecondaryStatGroup Determines where the stat is rendered.
---@field Label string Text on the left.
---@field Value string Text on the right.
---@field EngineStat number Used for the tooltip.
---@field Icon number
---@field Unknown1 number

---@class SecondaryStatSpacing : SecondaryStatBase
---@field IsSpacingElement boolean
---@field ElementId number
---@field Height number

---------------------------------------------
-- EVENTS
---------------------------------------------

---Hook to manipulate a secondary stats update.
---@class CharacterSheetUI_SecondaryStatUpdate : Hook
---@field stats SecondaryStatBase[]
---@field char EclCharacter

---------------------------------------------
-- METHODS
---------------------------------------------

---Get the current character on the sheet.  
---Defaults to client character if the sheet is uninitialized.
---@return EclCharacter
function CharacterSheet.GetCharacter()
    local handle = CharacterSheet:GetUI():GetPlayerHandle()

    if handle then
        return Ext.GetCharacter(handle)
    else -- fallback to client char - can happen when sheet hasn't been opened yet in a session
        return Client.GetCharacter()
    end
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

---@return SecondaryStatBase[]
function CharacterSheet.DecodeSecondaryStats(ui)
    local root = ui:GetRoot()
    local secStats = Game.Tooltip.TableFromFlash(ui, "secStat_array")
    local arr = root.secStat_array

    local stats = {}
    for i=0,#arr-1,7 do
        if arr[i] then -- Spacing element
            table.insert(stats, {
                IsSpacingElement = true, -- Adds spacing instead of a stat. Height is the Label prop value. Group becomes id.
                ElementId = arr[i + 1],
                Height = arr[i + 2],
            })
        else -- Stat element
            table.insert(stats, {
                IsSpacingElement = false,
                Group = arr[i + 1], -- which group this stat belongs to. See SECONDARY_STAT_GROUPS
                Label = arr[i + 2], -- Left label
                Value = arr[i + 3], -- Right label
                EngineStat = arr[i + 4], -- tooltip stat enum
                Icon = arr[i + 5], -- icon enum. The phys one here is slightly different resolution, so it does not center properly. todo fix
                Unknown1 = arr[i + 6], -- Used for editText_txt, possibly a GM feature.
            })
        end
    end

    return stats
end

function CharacterSheet.EncodeSecondaryStats(ui, stats)
    local arr = {}

    local attributeOrder = {
        "IsSpacingElement",
        "Group",
        "Label",
        "Value",
        "EngineStat",
        "Icon",
        "Unknown1",
    }

    for i,stat in ipairs(stats) do
        if stat.IsSpacingElement then
            table.insert(arr, stat.IsSpacingElement)
            table.insert(arr, stat.ElementId)
            table.insert(arr, stat.Height)

            table.insert(arr, 0)
            table.insert(arr, 0)
            table.insert(arr, 0)
            table.insert(arr, 0)
        else
            for z,attribute in ipairs(attributeOrder) do
                table.insert(arr, stat[attribute])
            end
        end
    end

    Game.Tooltip.TableToFlash(ui, "secStat_array", arr)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local function OnTabOpen(ui, method, id)
    CharacterSheet:FireEvent("TabChanged", id)
end

local function OnUpdateArraySystem(ui, method)
    local char = CharacterSheet.GetCharacter()
    local stats = CharacterSheet.DecodeSecondaryStats(ui)
    
    -- Hook to manipulate secStats_array, parsed into an array, one stat per entry.
    stats = CharacterSheet:ReturnFromHooks("SecondaryStatUpdate", stats, char)

    CharacterSheet.EncodeSecondaryStats(ui, stats)
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoading:Subscribe(function()
    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.characterSheet, "updateArraySystem", OnUpdateArraySystem, "Before")
    Ext.RegisterUITypeCall(Client.UI.Data.UITypes.characterSheet, "selectedTab", OnTabOpen, "After") -- tab open handler
end)