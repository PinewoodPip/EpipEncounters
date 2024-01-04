
---------------------------------------------
-- The characterCreation UI is used during charater creation as well as respeccing, and only exists during those 2 contexts.
---------------------------------------------

---@class CharacterCreationUI : UI
local CharacterCreation = {
    -- If your mod adds more presets, you should add them here,
    -- in the order they appear in Character Creation.
    -- This will be used in the future to pull up preset descriptions,
    -- as from the UI we can only get the index of the preset.
    PRESET_ORDER = {
        "Witch",
        "Battlemage",
        "Cleric",
        "Conjurer",
        "Enchanter",
        "Fighter",
        "Inquisitor",
        "Knight",
        "Metamorph",
        "Ranger",
        "Rogue",
        "Shadowblade",
        "Wizard",
        "Wayfarer",
    },

    ARRAY_ENTRY_TEMPLATES = {
        TALENT_NORMAL = {
            "TalentID",
            "Label",
            "State",
            "Available",
        },
        TALENT_RACIAL = {
            "TalentID",
            "Label",
        },
        ABILITY = {
            "GroupID",
            "GroupLabel",
            "StatID",
            "Label",
            "ValueLabel",
            "Delta",
            "IsCivil",
        }
    },

    SELECTOR_CONTENT_IDS = {
        ORIGIN = 0,
        PRESET = 1,
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Finished = {}, ---@type Event<CharacterCreationUI_Event_Finished>
        SelectorScrolled = {}, ---@type Event<CharacterCreationUI_Event_SelectorScrolled>
        OriginChanged = {}, ---@type Event<CharacterCreationUI_Event_OriginChanged>
        PresetChanged = {}, ---@type Event<CharacterCreationUI_Event_PresetChanged>
        Opened = {}, ---@type Event<EmptyEvent>
    },
    Hooks = {
        UpdateTalents = {}, ---@type Event<CharacterCreationUI_Hook_UpdateTalents>
        UpdateAbilities = {}, ---@type Event<CharacterCreationUI_Hook_UpdateAbilities>
    }
}
Epip.InitializeUI(Ext.UI.TypeID.characterCreation, "CharacterCreation", CharacterCreation)

---------------------------------------------
-- CLASSES
---------------------------------------------

---Base class for a talent entry.
---@class _CharacterCreationUI_Talent
---@field TalentID integer
---@field Label string

---@class CharacterCreationUI_Talent : _CharacterCreationUI_Talent
---@field State integer
---@field Available boolean

---@class CharacterCreationUI_RacialTalent : _CharacterCreationUI_Talent

---@class CharacterCreationUI_Ability
---@field GroupID number
---@field GroupLabel string
---@field StatID integer
---@field Label string
---@field ValueLabel string
---@field Delta number
---@field IsCivil any

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class CharacterCreationUI_Event_Finished
---@field Character EclCharacter
---@field Cancelled boolean True if the player cancelled their respec.

---@class CharacterCreationUI_Event_SelectorScrolled
---@field SelectorID integer
---@field OptionID integer
---@field IsScrollingToRight boolean

---@class CharacterCreationUI_Event_OriginChanged
---@field Index integer 1-based.

---@class CharacterCreationUI_Event_PresetChanged
---@field Index integer 1-based.

---@class CharacterCreationUI_Hook_UpdateTalents
---@field Talents CharacterCreationUI_Talent[] Hookable.
---@field RacialTalents CharacterCreationUI_RacialTalent[] Hookable.
---@field TalentPoints integer Hookable.
---@field Character EclCharacter

---@class CharacterCreationUI_Hook_UpdateAbilities
---@field Abilities CharacterCreationUI_Ability[]
---@field Character EclCharacter

---------------------------------------------
-- METHODS
---------------------------------------------

-- Returns true if the Character Creation UI currently exists.
---@return boolean
function CharacterCreation.IsInCharacterCreation()
    return CharacterCreation:Exists()
end

---Convert a 1-based index to the preset string ID, as defined in PRESET_ORDER.
---@param index integer
---@return string
function CharacterCreation.IndexToPreset(index)
    return CharacterCreation.PRESET_ORDER[index]
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for character creation/respec being finished.
CharacterCreation:RegisterCallListener("creationDone", function (_)
    CharacterCreation.Events.Finished:Throw({
        Character = Client.GetCharacter(),
        Cancelled = false,
    })
end, "After")
local function _OnConfirmPressed(_)
    CharacterCreation.Events.Finished:Throw({
        Character = Client.GetCharacter(),
        Cancelled = true,
    })
end
CharacterCreation:RegisterCallListener("mainMenu", _OnConfirmPressed, "After") -- Button in actual character *creation*.
CharacterCreation:RegisterCallListener("startGame", _OnConfirmPressed, "After") -- Button in respec.

-- Listen for selectors being scrolled.
CharacterCreation:RegisterCallListener("selectOption", function (_, selectorID, optionID, scrollingRight)
    CharacterCreation.Events.SelectorScrolled:Throw({
        SelectorID = selectorID,
        OptionID = optionID,
        IsScrollingToRight = scrollingRight,
    })

    if selectorID == CharacterCreation.SELECTOR_CONTENT_IDS.ORIGIN then
        CharacterCreation.Events.OriginChanged:Throw({
            Index = optionID,
        })
    elseif selectorID == CharacterCreation.SELECTOR_CONTENT_IDS.PRESET then
        CharacterCreation.Events.PresetChanged:Throw({
            Index = optionID,
        })
    end
end)

-- Listen for talents being updated.
CharacterCreation:RegisterInvokeListener("updateTalents", function (ev)
    local root = ev.UI:GetRoot()
    local talentsArray = root.talentArray
    local racialTalentsArray = root.racialTalentArray

    local points = talentsArray[1]

    local talentsHook = CharacterCreation.Hooks.UpdateTalents:Throw({
        Character = Client.GetCharacter(),
        TalentPoints = points,
        Talents = Client.Flash.ParseArray(talentsArray, CharacterCreation.ARRAY_ENTRY_TEMPLATES.TALENT_NORMAL, false, nil, 1),
        RacialTalents = Client.Flash.ParseArray(racialTalentsArray, CharacterCreation.ARRAY_ENTRY_TEMPLATES.TALENT_RACIAL),
    })

    Client.Flash.EncodeArray(talentsArray, CharacterCreation.ARRAY_ENTRY_TEMPLATES.TALENT_NORMAL, talentsHook.Talents, false, nil, 1)
    Client.Flash.EncodeArray(racialTalentsArray, CharacterCreation.ARRAY_ENTRY_TEMPLATES.TALENT_RACIAL, talentsHook.RacialTalents)

    talentsArray[1] = talentsHook.TalentPoints
end)

-- Listen for abilities being updated.
CharacterCreation:RegisterInvokeListener("updateAbilities", function (ev)
    local root = ev.UI:GetRoot()
    local array = root.abilityArray

    local hook = CharacterCreation.Hooks.UpdateAbilities:Throw({
        Character = Client.GetCharacter(),
        Abilities = Client.Flash.ParseArray(array, CharacterCreation.ARRAY_ENTRY_TEMPLATES.ABILITY)
    })

    Client.Flash.EncodeArray(array, CharacterCreation.ARRAY_ENTRY_TEMPLATES.ABILITY, hook.Abilities)
end)

-- Listen for the UI being initialized and forward the event.
CharacterCreation:RegisterCallListener("setAnchor", function (_, _, _, _)
    CharacterCreation.Events.Opened:Throw()
end)
