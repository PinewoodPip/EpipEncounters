
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
-- EVENT LISTENERS
---------------------------------------------

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