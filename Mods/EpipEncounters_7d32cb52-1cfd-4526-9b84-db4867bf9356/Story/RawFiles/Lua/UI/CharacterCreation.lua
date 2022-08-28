
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

    SELECTOR_CONTENT_IDS = {
        ORIGIN = 0,
        PRESET = 1,
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Finished = {}, ---@type SubscribableEvent<CharacterCreation_Event_Finished>
        SelectorScrolled = {}, ---@type SubscribableEvent<CharacterCreation_Event_SelectorScrolled>
        OriginChanged = {}, ---@type SubscribableEvent<CharacterCreation_Event_OriginChanged>
        PresetChanged = {}, ---@type SubscribableEvent<CharacterCreation_Event_PresetChanged>
    },
}
Client.UI.CharacterCreation = CharacterCreation
Epip.InitializeUI(Ext.UI.TypeID.characterCreation, "CharacterCreation", CharacterCreation)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class CharacterCreation_Event_Finished
---@field Character EclCharacter
---@field Cancelled boolean True if the player cancelled their respec.

---@class CharacterCreation_Event_SelectorScrolled
---@field SelectorID integer
---@field OptionID integer
---@field IsScrollingToRight boolean

---@class CharacterCreation_Event_OriginChanged
---@field Index integer 1-based.

---@class CharacterCreation_Event_PresetChanged
---@field Index integer 1-based.

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
CharacterCreation:RegisterCallListener("creationDone", function (ev)
    CharacterCreation.Events.Finished:Throw({
        Character = Client.GetCharacter(),
        Cancelled = false,
    })
end, "After")
CharacterCreation:RegisterCallListener("mainMenu", function (ev)
    CharacterCreation.Events.Finished:Throw({
        Character = Client.GetCharacter(),
        Cancelled = true,
    })
end, "After")

-- Listen for selectors being scrolled.
CharacterCreation:RegisterCallListener("selectOption", function (ev, selectorID, optionID, scrollingRight)
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