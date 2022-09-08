
---------------------------------------------
-- Hooks for characterSheet.swf.
---------------------------------------------

---@class CharacterSheetUI : UI
local CharacterSheet = {
    StatsTab = {}, -- See StatsTab.lua

    DEFAULT_LAYER = 9,
    DEFAULT_RENDER_ORDER = 11,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    ARRAY_ENTRY_TEMPLATES = {
        PRIMARY_STAT = {
            "StatID",
            "Label",
            "ValueLabel",
            "TooltipStatID",
        },
        SECONDARY_STAT = {
            -- Spacing
            [true] = {
                Name = "Spacing",
                Template = {
                    "ID",
                    "Height",
                },
            },
            -- Real entry
            [false] = {
                Name = "Stat",
                Template = {
                    "Type",
                    "Label",
                    "ValueLabel",
                    "StatID",
                    "IconID",
                    "BoostValue",
                },
            },
        },
        ABILITY_STAT = {
            "IsCivil",
            "GroupID",
            "StatID",
            "Label",
            "ValueLabel",
            "PlusButtonTooltip",
            "MinusButtonTooltip",
        },
        TALENT = {
            "Label",
            "StatID",
            {
                Name = "State",
                Enum = {
                    [0] = "Active",
                    [1] = "GrantedExternally",
                    [2] = "Available",
                    [3] = "Unavailable"
                }
            }
        }
    },

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

    Events = {
        HelmetToggled = {}, ---@type SubscribableEvent<CharacterSheetUI_Event_HelmetToggled>
        TabChanged = {}, ---@type SubscribableEvent<CharacterSheetUI_Event_TabChanged>
    },
    Hooks = {
        UpdateSecondaryStats = {}, ---@type SubscribableEvent<CharacterSheetUI_Hook_UpdateSecondaryStats>
        UpdatePrimaryStats = {}, ---@type SubscribableEvent<CharacterSheetUI_Hook_UpdatePrimaryStats>
        UpdateAbilityStats = {}, ---@type SubscribableEvent<CharacterSheetUI_Hook_UpdateAbilityStats>
        UpdateTalents = {}, ---@type SubscribableEvent<CharacterSheetUI_Hook_UpdateTalents>
    }
}
if IS_IMPROVED_HOTBAR then
    CharacterSheet.FILEPATH_OVERRIDES = {}
end
Epip.InitializeUI(Client.UI.Data.UITypes.characterSheet, "CharacterSheet", CharacterSheet)

---@alias SecondaryStatGroup table<string, number>

---@class SecondaryStatBase

---@class SecondaryStat : SecondaryStatBase
---@field EntryTypeID "Stat"
---@field Type SecondaryStatGroup Determines where the stat is rendered.
---@field Label string Text on the left.
---@field ValueLabel string Text on the right.
---@field StatID number Used for the tooltip.
---@field IconID number
---@field BoostValue number Unknown. Used for editText_txt, possibly a GM feature.

---@class SecondaryStatSpacing : SecondaryStatBase
---@field EntryTypeID "Spacing"
---@field ElementId number
---@field Height number

---@class CharacterSheetUI_PrimaryStat
---@field StatID integer
---@field Label string
---@field ValueLabel string
---@field TooltipStatID integer

---@class CharacterSheetUI_AbilityStat
---@field IsCivil boolean
---@field GroupID integer
---@field StatID integer
---@field Label string
---@field ValueLabel string
---@field PlusButtonTooltip string
---@field MinusButtonTooltip string

---@class CharacterSheetUI_Talent
---@field Label string
---@field StatID integer
---@field State "Active"|"GrantedExternally"|"Available"|"Unavailable"

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class CharacterSheetUI_Event_TabChanged
---@field TabID integer

---@class CharacterSheetUI_Event_HelmetToggled
---@field Character EclCharacter
---@field Active boolean

---@class _CharacterSheetUI_Hook_UpdateStat
---@field Character EclCharacter

---Hook to manipulate a secondary stats update (dodge chance, crit, etc.).
---@class CharacterSheetUI_Hook_UpdateSecondaryStats : _CharacterSheetUI_Hook_UpdateStat
---@field Stats SecondaryStatBase[] Hookable.

---Hook to manipulate a primary stat update (attributes)
---@class CharacterSheetUI_Hook_UpdatePrimaryStats : _CharacterSheetUI_Hook_UpdateStat
---@field Stats CharacterSheetUI_PrimaryStat[] Hookable.

---@class CharacterSheetUI_Hook_UpdateAbilityStats : _CharacterSheetUI_Hook_UpdateStat
---@field Stats CharacterSheetUI_AbilityStat[] Hookable.

---@class CharacterSheetUI_Hook_UpdateTalents : _CharacterSheetUI_Hook_UpdateStat
---@field Stats CharacterSheetUI_Talent[] Hookable.

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

---@param UI UIObject
---@return SecondaryStatBase[]
function CharacterSheet.DecodeSecondaryStats(ui)
    local root = ui:GetRoot()
    local arr = root.secStat_array

    return Client.Flash.ParseArray(arr, CharacterSheet.ARRAY_ENTRY_TEMPLATES.SECONDARY_STAT, true, 7)
end

---@param ui UIObject
---@param stats SecondaryStatBase[]
function CharacterSheet.EncodeSecondaryStats(ui, stats)
    Client.Flash.EncodeArray(ui:GetRoot().secStat_array, CharacterSheet.ARRAY_ENTRY_TEMPLATES.SECONDARY_STAT, stats, true, 7)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

CharacterSheet:RegisterCallListener("selectedTab", function (_, id)
    CharacterSheet.Events.TabChanged:Throw({TabID = id})
end)

-- Listen for player changing helmet visual preference.
CharacterSheet:RegisterCallListener("setHelmetOption", function (_, state)
    CharacterSheet.Events.HelmetToggled:Throw({
        Character = Client.GetCharacter(),
        Active = state == 1,
    })
end, "After")

-- Listen for array system updates.
CharacterSheet:RegisterInvokeListener("updateArraySystem", function (ev)
    local char = CharacterSheet.GetCharacter()
    local stats = CharacterSheet.DecodeSecondaryStats(ev.UI)
    
    local hook = CharacterSheet.Hooks.UpdateSecondaryStats:Throw({
        Character = char,
        Stats = stats,
    })

    CharacterSheet.EncodeSecondaryStats(ev.UI, hook.Stats)

    -- Primary stats
    local root = ev.UI:GetRoot()
    local primaryStatsArray = root.primStat_array
    local primaryStats = Client.Flash.ParseArray(primaryStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.PRIMARY_STAT)

    local primaryStatsHook = CharacterSheet.Hooks.UpdatePrimaryStats:Throw({
        Character = char,
        Stats = primaryStats,
    })
    Client.Flash.EncodeArray(primaryStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.PRIMARY_STAT, primaryStatsHook.Stats)

    -- Ability stats
    local abilityStatsArray = root.ability_array
    local abilityStats = Client.Flash.ParseArray(abilityStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.ABILITY_STAT)

    local abilityStatsHook = CharacterSheet.Hooks.UpdateAbilityStats:Throw({
        Character = char,
        Stats = abilityStats,
    })
    Client.Flash.EncodeArray(abilityStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.ABILITY_STAT, abilityStatsHook.Stats)

    -- Talents
    local talentsArray = root.talent_array
    local talents = Client.Flash.ParseArray(talentsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.TALENT)
    local talentsHook = CharacterSheet.Hooks.UpdateTalents:Throw({
        Character = char,
        Stats = talents,
    })
    Client.Flash.EncodeArray(talentsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.TALENT, talentsHook.Stats)
end, "Before")