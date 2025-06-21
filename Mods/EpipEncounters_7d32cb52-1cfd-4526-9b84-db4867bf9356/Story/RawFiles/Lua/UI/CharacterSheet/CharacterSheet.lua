
---------------------------------------------
-- Hooks for characterSheet.swf.
---------------------------------------------

local UIOverrideToggles = Epip.GetFeature("Features.UIOverrideToggles")

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

    ---@enum UI.CharacterSheet.SecondaryStatGroup
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
    STAT_ICONS = {
        VITALITY = 1,
        ACTION_POINTS = 2,
        SOURCE_POINTS = 3,
        TENEBRIUM_RESISTANCE = 4, -- DOS1 leftover.
        FIRE_RESISTANCE = 5,
        WATER_RESISTANCE = 6,
        EARTH_RESISTANCE = 7,
        AIR_RESISTANCE = 8,
        POISON_RESISTANCE = 9,
        PHYSICAL_ARMOR = 10,
        MAGIC_ARMOR = 11,
        -- Frame 12 is empty (RemoveObject tag)
        ACCURACY = 13,
        DAMAGE = 14, -- 2 crossed swords.
        DODGE = 15,
        INITIATIVE = 16,
        NEXT_LEVEL = 17,
        MOVEMENT = 18,
        EXPERIENCE = 19,
    },

    -- Handles used for the custom stats tab tooltip.
    CUSTOM_STATS_TAB_TSKHANDLES = {
        "h409bfd42g2257g4cb8gb3fbgedcb8adecaed",
        "ha62e1eccgc1c2g4452g8d78g65ea010f3d85",
    },

    TranslatedStrings = {
        Label_KeywordsTab = {
            Handle = "h1a027d33g636fg4a2dga363gfc9f755c6c93",
            Text = "Keywords & Misc.",
            ContextDescription = [[Tooltip for tab with keywords & character stats.]],
        },
    },

    Events = {
        HelmetToggled = {}, ---@type Event<CharacterSheetUI_Event_HelmetToggled>
        TabChanged = {}, ---@type Event<CharacterSheetUI_Event_TabChanged>
    },
    Hooks = {
        UpdateSecondaryStats = {}, ---@type Event<CharacterSheetUI_Hook_UpdateSecondaryStats>
        UpdatePrimaryStats = {}, ---@type Event<CharacterSheetUI_Hook_UpdatePrimaryStats>
        UpdateAbilityStats = {}, ---@type Event<CharacterSheetUI_Hook_UpdateAbilityStats>
        UpdateTalents = {}, ---@type Event<CharacterSheetUI_Hook_UpdateTalents>
    }
}
Epip.InitializeUI(Ext.UI.TypeID.characterSheet, "CharacterSheet", CharacterSheet)

-- Apply .swf override
if UIOverrideToggles.Settings.EnableCharacterSheetOverride:GetValue() == true then
    Ext.IO.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/characterSheet.swf")
end

---@class SecondaryStatBase

---@class SecondaryStat : SecondaryStatBase
---@field EntryTypeID "Stat"
---@field Type UI.CharacterSheet.SecondaryStatGroup Determines where the stat is rendered.
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

---Gets the currently selected character on the character sheet.  
---Defaults to client character if the sheet is uninitialized.
---@return EclCharacter
function CharacterSheet.GetCharacter()
    local handle = CharacterSheet:GetUI():GetPlayerHandle()

    if handle then
        return Character.Get(handle)
    else -- Fallback to client char - can happen when sheet hasn't been opened yet in a session.
        return Client.GetCharacter()
    end
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

---@param ui UIObject
---@return SecondaryStatBase[]
function CharacterSheet._DecodeSecondaryStats(ui)
    local root = ui:GetRoot()
    local arr = root.secStat_array

    return Client.Flash.ParseArray(arr, CharacterSheet.ARRAY_ENTRY_TEMPLATES.SECONDARY_STAT, true, 7)
end

---@param ui UIObject
---@param stats SecondaryStatBase[]
function CharacterSheet._EncodeSecondaryStats(ui, stats)
    Client.Flash.EncodeArray(ui:GetRoot().secStat_array, CharacterSheet.ARRAY_ENTRY_TEMPLATES.SECONDARY_STAT, stats, true, 7)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward tab change events.
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
    local root = ev.UI:GetRoot()

    -- Primary stats
    local primaryStatsArray = root.primStat_array
    local primaryStats = Client.Flash.ParseArray(primaryStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.PRIMARY_STAT)

    -- Only fire this hook if the engine is re-rendeing stats. It is possible for this array to be empty and the primary stats is cleared by engine and does not support replacing info on existing entries, thus firing this when there is no update can lead to unexpected behaviour if a script is adding a new stat through the hook.
    if primaryStats[1] then
        local primaryStatsHook = CharacterSheet.Hooks.UpdatePrimaryStats:Throw({
            Character = char,
            Stats = primaryStats,
        })
        Client.Flash.EncodeArray(primaryStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.PRIMARY_STAT, primaryStatsHook.Stats)
    end

    local secondaryStats = CharacterSheet._DecodeSecondaryStats(ev.UI)
    if secondaryStats[1] then -- Fired only when changes occur, same reasoning as with primary stats.
        local hook = CharacterSheet.Hooks.UpdateSecondaryStats:Throw({
            Character = char,
            Stats = secondaryStats,
        })
        CharacterSheet._EncodeSecondaryStats(ev.UI, hook.Stats)
    end

    -- Ability stats
    local abilityStatsArray = root.ability_array
    local abilityStats = Client.Flash.ParseArray(abilityStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.ABILITY_STAT)
    if abilityStats[1] then -- Fired only when changes occur, same reasoning as with primary stats.
        local abilityStatsHook = CharacterSheet.Hooks.UpdateAbilityStats:Throw({
            Character = char,
            Stats = abilityStats,
        })
        Client.Flash.EncodeArray(abilityStatsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.ABILITY_STAT, abilityStatsHook.Stats)
    end

    -- Talents
    local talentsArray = root.talent_array
    local talents = Client.Flash.ParseArray(talentsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.TALENT)
    if talents[1] then -- Fired only when changes occur, same reasoning as with primary stats.
        local talentsHook = CharacterSheet.Hooks.UpdateTalents:Throw({
            Character = char,
            Stats = talents,
        })
        Client.Flash.EncodeArray(talentsArray, CharacterSheet.ARRAY_ENTRY_TEMPLATES.TALENT, talentsHook.Stats)
    end
end, "Before")

-- Update stats tab translated string to use the Epip localized string.
GameState.Events.ClientReady:Subscribe(function()
    local label = CharacterSheet.TranslatedStrings.Label_KeywordsTab:GetString()
    for _,handle in ipairs(CharacterSheet.CUSTOM_STATS_TAB_TSKHANDLES) do
        Text.SetTranslatedString(handle, label)
    end
end)
