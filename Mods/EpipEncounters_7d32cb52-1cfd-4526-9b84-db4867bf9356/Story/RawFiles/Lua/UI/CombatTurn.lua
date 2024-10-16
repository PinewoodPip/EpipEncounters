
---@class CombatTurnUI : UI
local CombatTurn = {
    ARRAY_ENTRY_TEMPLATES = {
        TURN = {
            "ID",
            "IggyIconID",
            "CombatantName",
            {
                Name = "CharacterType",
                Enum = {
                    [0] = "Neutral",
                    [1] = "Unknown1",
                    [2] = "Unknown2",
                    [3] = "Ally",
                    [4] = "Enemy",
                    -- Unsure if more exist
                    [5] = "Unknown5",
                    [6] = "Unknown6",
                    [7] = "Unknown7",
                    [8] = "Unknown8",
                },
            },
            "VitalityPercentage",
            "PhysicalArmourPercentage",
            "MagicArmourPercentage",
            "Unknown8_lPos",
        },
    },

    -- From `getCharTypeColour()`, in decimal.
    ---@enum UI.CombatTurn.HighlightColor
    HIGHLIGHT_COLORS = {
        ACTIVE = 16777215, -- Active combatant.
        UNKNOWN2 = 41981, -- Blue
        ALLY = 1169530,
        ENEMY = 14090271,
        FRIENDLY = 4697160,
        UNKNOWN6 = 1142406, -- Dark blue
        NEUTRAL = 13016101,
        UNKNOWN8 = 9247788, -- Dark red
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        UpdateTurnList = {}, ---@type Event<CombatTurnUI_Hook_UpdateTurnList>
    }
}
Epip.InitializeUI(Ext.UI.TypeID.combatTurn, "CombatTurn", CombatTurn)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class CombatTurnUI_ArrayEntry_Turn
---@field ID integer
---@field IggyIconID integer
---@field CombatantName string
---@field CharacterType "Neutral"|"Ally"|"Enemy"
---@field VitalityPercentage number
---@field PhysicalArmourPercentage number
---@field MagicArmourPercentage number
---@field Unknown8_lPos number

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class CombatTurnUI_Hook_UpdateTurnList
---@field CurrentRoundEntries CombatTurnUI_ArrayEntry_Turn[]
---@field NextRoundEntries CombatTurnUI_ArrayEntry_Turn[]

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the elements for an entity.
---@param entity CombatLib_CombatCompatibleEntity
---@return FlashMovieClip?, FlashMovieClip? -- Current round and next round entries. `nil` if the entity has no entry in the UI. **The active character will not be returned for the current round**.
function CombatTurn.GetEntityElement(entity)
    local root = CombatTurn:GetRoot()
    local currentRoundList = root.list
    local nextRoundList = root.nextRoundList
    return CombatTurn._GetEntityElement(entity, currentRoundList), CombatTurn._GetEntityElement(entity, nextRoundList)
end

---Returns the first (from either current or next round) element for an entity.
---@param entity CombatLib_CombatCompatibleEntity
---@return FlashMovieClip? -- Current round element takes priority.
function CombatTurn.GetFirstEntityElement(entity)
    local currentRoundElement, nextRoundElement = CombatTurn.GetEntityElement(entity)
    return currentRoundElement or nextRoundElement
end

---Returns the element of an entity within a list.
---@param entity CombatLib_CombatCompatibleEntity
---@param list FlashMovieClip
---@return FlashMovieClip? -- `nil` if the entity has no entry in the UI.
function CombatTurn._GetEntityElement(entity, list)
    for i=0,#list.content_array-1,1 do
        local entry = list.content_array[i]
        local entryEntity = Combat.GetEntityByCombinedID(entry.id) -- IDs within the UI are combined combat IDs.
        if entryEntity.Handle == entity.Handle then
            return entry
        end
    end
    return nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Hook entry updates.
CombatTurn:RegisterInvokeListener("updateTurnList", function (ev)
    local root = ev.UI:GetRoot()
    local currentRoundArray = root.currentTurn_Array
    local nextRoundArray = root.nextTurn_Array

    local success1, currentRoundEntries = pcall(Client.Flash.ParseArray, currentRoundArray, CombatTurn.ARRAY_ENTRY_TEMPLATES.TURN)
    local success2, nextRoundEntries = pcall(Client.Flash.ParseArray, nextRoundArray, CombatTurn.ARRAY_ENTRY_TEMPLATES.TURN)

    if success1 and success2 then
        local hook = CombatTurn.Hooks.UpdateTurnList:Throw({
            CurrentRoundEntries = currentRoundEntries,
            NextRoundEntries = nextRoundEntries,
        })

        Client.Flash.EncodeArray(currentRoundArray, CombatTurn.ARRAY_ENTRY_TEMPLATES.TURN, hook.CurrentRoundEntries)
        Client.Flash.EncodeArray(nextRoundArray, CombatTurn.ARRAY_ENTRY_TEMPLATES.TURN, hook.NextRoundEntries)
    else
        CombatTurn:LogError("Error parsing turn list; an enum is possibly erroneous? " .. currentRoundEntries or nextRoundEntries)
    end
end)