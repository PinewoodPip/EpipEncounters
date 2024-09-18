
local Input = Client.Input

---@class HotbarUI : UI
---@field Actions table<string, HotbarAction>
---@field ActionsState HotbarActionState[]
---@field SLOTS_PER_ROW integer
---@field initialized boolean
---@field State table<string, HotbarState>
---@field SAVE_FILENAME string
---@field currentLoadoutRow number?
---@field Loadouts table<string, HotbarLoadout>
---@field PreparedSkills table<NetId, HotbarPreparedSkill> Tracks the prepared skill, as well as the skill being used.
---@field RegisteredActionOrder string[]
---@field CUSTOM_RENDERING boolean
---@field CurrentVanillaRows table<integer, integer>
---@field SLOT_SIZE number
---@field SLOT_SPACING number
---@field modulesRequestingHide table<string,boolean> Modules that are currently requesting the hotbar to stay hidden.
---@field ACTION_BUTTONS_COUNT integer Amount of action buttons available in total.
local Hotbar = {
    Actions = {},
    State = {

    },
    ActionsState = {

    },
    Loadouts = {},
    RegisteredActionOrder = {},
    CurrentVanillaRows = {

    },

    PreparedSkills = {},
    modulesRequestingHide = {},
    elementsToggled = true,
    initialized = false,
    currentLoadoutRow = nil,
    lastClickedSlot = -1,
    wasVisible = false,
    engineActionsCount = 3,

    _CooldownsUpdateTimer = 0,
    _CustomRequirementsCheckTimer = 0,
    _HotkeysUpdateTimer = 0,
    _HotkeyIcons = {}, ---@type table<integer, icon?> Map of icons currently used by hotkey buttons.
    _SlotIcons = {}, ---@type table<integer, icon?> Map of icons currently used by slots.
    _SkillsWithCustomRequirements = {}, ---@type set<skill>
    _SkillsCheckedForCustomRequirements = {}, ---@type set<skill>

    ACTION_BUTTONS_COUNT = 12,
    SKILL_USE_TIME = 3000, -- Kept as a fallback.
    SLOT_SIZE = 50,
    SLOT_SPACING = 8,
    SLOTS_PER_ROW = 29,
    CUSTOM_RENDERING = false,
    SAVE_FILENAME = "Config_PIP_ImprovedHotbar.json",
    HOTKEYS_UPDATE_DELAY = 500, -- In milliseconds.
    COOLDOWN_UPDATE_DELAY = 70, -- Milliseconds to wait inbetween each cooldown animations update.
    CUSTOM_REQUIREMENTS_UPDATE_DELAY = 200, -- Milliseconds to wait inbetween updates for skills with custom requirements.
    MAX_SLOTS = 145, -- The maximum amount of slots the game supports for PlayerData.

    DEFAULT_ACTION_PROPERTIES = {
        IsActionVisibleInDrawer = true,
        IsActionEnabled = true,
        IsActionHighlighted = false,
    },

    ACTION_ICONS = {
        ANNOUNCEMENT = "hotbar_icon_announcement",
        ACTION_POINT = "hotbar_icon_ap",
        BAG = "hotbar_icon_bag",
        BOOK = "hotbar_icon_book",
        BREWING = "hotbar_icon_brewing",
        CHARACTER_SHEET = "hotbar_icon_charsheet",
        CHAT = "hotbar_icon_chat",
        CLOVER = "hotbar_icon_clover",
        COMBAT_LOG = "hotbar_icon_combatlog",
        CRAFTING = "hotbar_icon_crafting",
        DIE = "hotbar_icon_die",
        DUMBELL = "hotbar_icon_dumbell",
        DYE = "hotbar_icon_dye",
        EMAIL = "hotbar_icon_email",
        FIST = "hotbar_icon_fist",
        HAND = "hotbar_icon_hand",
        HAT = "hotbar_icon_hat",
        HELM = "hotbar_icon_helm",
        INFINITY = "hotbar_icon_infinity",
        INTERNET = "hotbar_icon_internet",
        INVENTORY = "hotbar_icon_inventory",
        JOURNAL = "hotbar_icon_journal",
        KICK = "hotbar_icon_kick",
        LAUREATE = "hotbar_icon_laureate",
        LOCK = "hotbar_icon_lock",
        MAGIC = "hotbar_icon_magic",
        MAP = "hotbar_icon_map",
        MEMORY = "hotbar_icon_memory",
        MIXERS = "hotbar_icon_mixers",
        NON_GACHA_TRANSMUTE = "hotbar_icon_nongachatransmute",
        PAUSE = "hotbar_icon_pause",
        PING = "hotbar_icon_ping",
        REFRESH = "hotbar_icon_refresh",
        ROT = "hotbar_icon_rot",
        RUNE = "hotbar_icon_rune",
        SHOCK = "hotbar_icon_shock",
        SKILLS = "hotbar_icon_skills",
        SKULL = "hotbar_icon_skull",
        SOURCE_POINT = "hotbar_icon_sp",
        WAYPOINTS = "hotbar_icon_waypoints",
        WEAPON_EXPANSION = "hotbar_icon_weaponex",
        AEROTHEURGE = "hotbar_school_aerotheurge",
        GEOMANCER = "hotbar_school_geomancer",
        HUNTSMAN = "hotbar_school_huntsman",
        HYDROSOPHIST = "hotbar_school_hydrosophist",
        NECROMANCY = "hotbar_school_necromancy",
        POLYMORPH = "hotbar_school_polymorph",
        PYROKINETIC = "hotbar_school_pyrokinetic",
        SCOUNDREL = "hotbar_school_scoundrel",
        SOURCERY = "hotbar_school_sourcery",
        SPECIAL = "hotbar_school_special",
        SUMMONING = "hotbar_school_summoning",
        WARFARE = "hotbar_school_warfare",
    },

    ARRAY_ENTRY_TEMPLATES = {
        ACTIONS = {
            "ActionID",
            "Enabled",
        },
    },

    POSITIONING = {
        CYCLERS = {
            X = 315,
            Y = -55,
        },
        HOTKEYS = {
            PORTRAIT = {X = 17, Y = 27},
            PORTRAIT_SINGLE = {X = 17, Y = 62},
            BASEFRAME_POS = {X = -88, Y = -152+138}, -- -152
            BUTTON = {
                STARTING_POS = {X = 55, Y = 64.5},
                SPACING = 3,
                TEXT = {X = -17, Y = 27},
                SECOND_ROW_OFFSET_Y = -63,
                DRAG_THRESHOLD = 10,
            },
            DRAWER_BUTTON = {
                STARTING_POS = {X = 55, Y = -10, Y_SINGLE = 60},
                TEXT = {X = 20, Y = 0},
                TEXT_WIDTH = 200,
                ICON = {X = 2, Y = nil}, -- vertically centered
            },
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        BarPlusMinusButtonPressed = {}, ---@type Event<HotbarUI_Event_BarPlusMinusButtonPressed>
        SlotPressed = {}, ---@type Event<UI.Hotbar.Events.SlotEvent>
        SlotHovered = {}, ---@type Event<UI.Hotbar.Events.SlotEvent>
        ContentDraggedToHotkey = {Legacy = false}, ---@type Event<HotbarUI_Event_ContentDraggedToHotkey>
        StateChanged = {Legacy = false}, ---@type Event<HotbarUI_Event_StateChanged>
    },
    Hooks = {
        IsBarVisible = {}, ---@type Event<HotbarUI_Hook_IsBarVisible>
        CanAddBar = {}, ---@type Event<HotbarUI_Hook_CanAddBar>
        CanRemoveBar = {}, ---@type Event<HotbarUI_Hook_CanRemoveBar>
        UpdateEngineActions = {}, ---@type Event<HotbarUI_Hook_UpdateEngineActions>
        GetState = {Legacy = false}, ---@type Event<HotbarUI_Hook_GetState>
        GetSlotForIggyEvent = {Legacy = false}, ---@type Event<UI.Hotbar.Hooks.GetSlotForIggyEvent>
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/hotBar.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/hotBar.swf",
    },
}
Epip.InitializeUI(Ext.UI.TypeID.hotBar, "Hotbar", Hotbar)
Hotbar:Debug()

local _SlotElements = {} ---@type table<integer, FlashMovieClip> Cached references to slot elements. Index is 0-based. Local to be upvalued for better performance.
local _SlotHolder = nil ---@type FlashMovieClip?

for _=1,Hotbar.ACTION_BUTTONS_COUNT,1 do
    table.insert(Hotbar.ActionsState, {
        ActionID = "",
    })
end

---@class HotbarPreparedSkill
---@field SkillID string
---@field StartTime integer
---@field Casting boolean True if the spell is being cast.

---@class HotbarState
---@field Bars HotbarBarState[]

---@class HotbarBarState
---@field Row integer
---@field Visible boolean

---@class HotbarUI_ArrayEntry_EngineAction
---@field ActionID StatsLib_Action_ID
---@field Enabled boolean

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired after the corresponding procedures are ran.
---@class HotbarUI_Event_BarPlusMinusButtonPressed
---@field IsPlusButton boolean

---@class HotbarUI_Hook_IsBarVisible
---@field BarIndex integer
---@field Visible boolean Hookable.

---@class HotbarUI_Hook_CanAddBar
---@field BarToAddIndex integer
---@field CanAdd boolean Hookable.

---@class HotbarUI_Hook_CanRemoveBar
---@field BarToRemoveIndex integer
---@field CanRemove boolean Hookable.

---@class UI.Hotbar.Events.SlotEvent
---@field SlotData EocSkillBarItem
---@field IsEnabled boolean
---@field Index integer 1-based.

---Invoked when the engine updates the vanilla action holder.
---@class HotbarUI_Hook_UpdateEngineActions
---@field Actions HotbarUI_ArrayEntry_EngineAction[]

---Fired when content is dragged to the hotkey buttons.
---@class HotbarUI_Event_ContentDraggedToHotkey
---@field DragDrop DragDropManagerPlayerDragInfo
---@field Index integer

---@class HotbarUI_Event_StateChanged
---@field Character EclCharacter
---@field State HotbarState

---Thrown when a state is being initialized for a character that didn't have one instanced.
---@class HotbarUI_Hook_GetState
---@field Character EclCharacter
---@field State HotbarState Hookable.

---@class UI.Hotbar.Hooks.GetSlotForIggyEvent
---@field SlotKeyIndex integer 1-based. Index of the slot keybind used.
---@field SlotIndex integer? Hookable. 1-based. If `nil`, no slot will be used.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_Hotbar_SetLayout : NetLib_Message_Character
---@field Layout HotbarState

---@class EPIPENCOUNTERS_Hotbar_UseItem : NetLib_Message_Character, NetLib_Message_Item

---@class EPIPENCOUNTERS_Hotbar_UseTemplate : NetLib_Message_Character
---@field Template GUID

---------------------------------------------
-- METHODS
---------------------------------------------

local function CenterElement(element, parent, axis, elementSizeOverride)
    local elementSize = element.height
    local size = "height"
    if axis == "x" then size = "width" end
    if axis == "x" then
        elementSize = element.width
    end
    if elementSizeOverride then
        elementSize = elementSizeOverride
    end
    element[axis] = parent[size] / 2 - elementSize / 2
end

---Get the real active row of the current char - the one the game remembers.
---@return integer
function Hotbar.GetCurrentRealRow()
    return Hotbar:GetRoot().hotbar_mc.cycleHotBar_mc.currentHotBarIndex
end

---Returns the skillbar data of the slot at index.
---@param char EclCharacter? Defaults to client character.
---@param index integer
---@return EocSkillBarItem
function Hotbar.GetSlotData(char, index)
    char = char or Client.GetCharacter()
    return char.PlayerData.SkillBarItems[index]
end

---Toggle visibility of the hotbar.
---@param requestID string
---@param visible boolean
function Hotbar.ToggleVisibility(visible, requestID)
    -- No longer using this as it disables hotkey listeners.
    -- Hotbar:GetRoot().showSkillBar(visible)
    -- hotbar:ToggleElements(visible)

    if not requestID then
        Hotbar:__Error("ToggleVisibility", "Must pass a requestID to ToggleVisiblity.")
        return nil
    end

    Hotbar.modulesRequestingHide[requestID] = not visible

    if Hotbar.IsVisible() then
        Hotbar:GetRoot().y = 0

        -- Need to refresh or the bar becomes unresponsive
        Ext.OnNextTick(function() Hotbar.RenderSlots() end)
    else
        Hotbar:GetRoot().y = 6000
    end

    Hotbar.Refresh()
end

---Returns whether the hotbar is currently visible.
---Considers ToggleVisiblity() as well as vanilla hiding logic (ex. during dialogues)
---@return boolean
function Hotbar.IsVisible()
    for _,state in pairs(Hotbar.modulesRequestingHide) do
        if state then
            return false
        end
    end

    return Hotbar.elementsToggled
end

---@param index integer
---@return boolean
function Hotbar.IsBarVisible(index)
    local visible = index == 1 -- First bar is always considered visible.
    if index ~= 1 then
        local bar = Hotbar.GetState().Bars[index]
        visible = Hotbar.Hooks.IsBarVisible:Throw({
            BarIndex = index,
            Visible = bar.Visible
        }).Visible
    end
    return visible
end

function Hotbar.UpdateSlotTextures()
    Hotbar:GetUI():ExternalInterfaceCall("updateSlots", Hotbar.GetSlotsPerRow())
end

---Returns the slotHolder movieclip.
---@return FlashMovieClip
function Hotbar.GetSlotHolder()
    return _SlotHolder
end

---@param char? EclCharacter
---@return HotbarState
function Hotbar.GetState(char)
    char = char or Client.GetCharacter()
    local guid = char.NetID
    local state = Hotbar.State[guid]

    -- Create a new state
    if not state then
        Hotbar.State[guid] = {
            Bars = {
                {Row = 1, Visible = true},
                {Row = 2, Visible = false},
                {Row = 3, Visible = false},
                {Row = 4, Visible = false},
                {Row = 5, Visible = false},
            },
        }
        state = Hotbar.State[guid]

        state = Hotbar.Hooks.GetState:Throw({
            Character = char,
            State = state,
        }).State
    end

    return state
end

---Set the state of a char's hotbar - its amount of bars, and their rows
---@param char EclCharacter
---@param state HotbarState
function Hotbar.SetState(char, state)
    Hotbar.State[char.NetID] = state

    Hotbar:DebugLog("Set state for " .. char.DisplayName)

    if char.Handle == Client.GetCharacter().Handle then
        Hotbar.Refresh()
    end

    Hotbar.Events.StateChanged:Throw({
        Character = char,
        State = state,
    })
end

---Returns whether a row is visible for char.
---@param char? EclCharacter
---@param row integer
function Hotbar.IsRowVisible(char, row)
    local state = Hotbar.GetState(char)
    for i,bar in ipairs(state.Bars) do
        if bar.Row == row then
            return Hotbar.IsBarVisible(i)
        end
    end
    return false
end

---Returns whether the hotbar is currently usable.
---The hotbar is unusable in combat if it is not the client char's turn, or while they are casting a skill.
---@return boolean
function Hotbar.CanUseHotbar()
    local isCasting = Character.IsCastingSkill(Client.GetCharacter())
    local canUse = true

    if Client.IsInCombat() then
        if Client.IsActiveCombatant() then
            canUse = Client.GetCharacter().Stats.CurrentAP > 0
        else
            canUse = false
        end
    end

    if isCasting and Settings.GetSettingValue("Epip_Hotbar", "HotbarCastingGreyOut") == true then
        canUse = false
    end

    return canUse
end

---Returns the SkillBarItems array of char, optionally filtered by predicate.
---@param char? EclCharacter
---@param predicate? fun(char: EclCharacter, slot: EocSkillBarItem, index:integer):boolean
---@return table<integer, EocSkillBarItem>
function Hotbar.GetSkillBarItems(char, predicate)
    local slots = {}
    local skillBar

    if not char then
        char = Client.GetCharacter()
    end

    skillBar = char.PlayerData.SkillBarItems

    if predicate == nil then
        slots = skillBar
    else
        for i=1,Hotbar.MAX_SLOTS,1 do
            if predicate(char, skillBar[i], i) then
                slots[i] = skillBar[i]
            end
        end
    end

    return slots
end

---Returns whether a row is empty (has nothing slotted)
---@param index integer
---@param char? EclCharacter
function Hotbar.IsRowEmpty(index, char)
    local skillBar = Hotbar.GetSkillBarItems(char)
    local isEmpty = true

    for i=(index - 1) * Hotbar.GetSlotsPerRow() + 1,(index) * Hotbar.GetSlotsPerRow(),1 do
        if skillBar[i].Type ~= "None" then
            isEmpty = false
            break
        end
    end

    return isEmpty
end

---Get the row that a slot index is in.
---@param index integer Slot index.
---@return integer Row that the slot pertains to.
function Hotbar.GetRowForSlot(index)
    return math.floor((index - 1) / Hotbar.GetSlotsPerRow()) + 1
end

---Shift a group of slots to a side.
---@param selectedSlot integer Slot to start shifting from.
---@param direction string Direction to shift towards: "left" or "right"
function Hotbar.ShiftSlots(selectedSlot, direction)
    if type(direction) ~= "string" then
        Hotbar:LogError("Invalid direction for shift. Must be 'left' or 'right'.")
    else
        if direction == "left" then
            direction = -1
        else
            direction = 1
        end

        local skillBar = Hotbar.GetSkillBarItems()
        local endSlot = 1 -- Slot to end the search at. Previously we bounded it to the same row; removed as it didn't feel necessary.

        if direction > 0 then
            endSlot = Hotbar.MAX_SLOTS
        end

        -- If the slot is empty, find the closest one
        while skillBar[selectedSlot].Type == "None" do
            if selectedSlot <= 0 or selectedSlot > Hotbar.GetSlotsPerRow() * 5 or selectedSlot == endSlot then
                Hotbar:DebugLog("Can't shift out of bounds!")
                return nil
            else
                selectedSlot = selectedSlot + direction
            end
        end

        local index = selectedSlot
        local slots = {}
        local foundEmpty = false


        while not foundEmpty do
            local item = skillBar[index]

            -- Stop at the end of rows.
            if index == endSlot or item.Type == "None" then
                endSlot = index
                foundEmpty = true
            end
            if item.Type ~= "None" then
                table.insert(slots, index)
                index = index + direction

                if index <= 0 or index > Hotbar.GetSlotsPerRow() * 5 then
                    Hotbar:DebugLog("Can't shift out of bounds!")
                    return nil
                end
            end
        end

        -- Store slot data
        local slotData = {}
        for _,slotIndex in ipairs(slots) do
            slotData[slotIndex] = {
                Type = skillBar[slotIndex].Type,
                SkillOrStatId = skillBar[slotIndex].SkillOrStatId,
                ItemHandle = skillBar[slotIndex].ItemHandle,
            }
        end

        -- Start shifting
        index = selectedSlot
        for _,slotIndex in ipairs(slots) do
            local newIndex = slotIndex + direction
            local data = slotData[slotIndex]
            local slot = skillBar[newIndex]

            slot.Type = data.Type
            slot.ItemHandle = data.ItemHandle
            slot.SkillOrStatId = data.SkillOrStatId
        end

        -- Clear original slot
        skillBar[selectedSlot].Type = "None"
        Hotbar.contextMenuSlot = Hotbar.contextMenuSlot + direction

        Hotbar.RenderSlots()
    end
end

---Clear the skillbar data of char on a specific row, optionally filtering by a predicate function.
---@param char EclCharacter
---@param row integer
---@param predicate (fun(char: EclCharacter, slot: EocSkillBarItem):boolean)?
function Hotbar.ClearRow(char, row, predicate)
    local skillBar = char.PlayerData.SkillBarItems
    local startingIndex = (row - 1) * Hotbar.GetSlotsPerRow()
    for i=1,Hotbar.GetSlotsPerRow(),1 do
        local slotIndex = startingIndex + i
        local slot = skillBar[slotIndex]
        if predicate == nil or predicate(char, slot) then
            slot.Type = "None"
            slot.SkillOrStatId = ""
        end
    end
    Hotbar:DebugLog("Cleared row " .. row)
end

---Saves the persistent data related to the hotbar to disk immediately.
function Hotbar.SaveData()
    local save = {
        Hotkeys = Hotbar.ActionsState,
        Loadouts = Hotbar.Loadouts,
        Protocol = 1,
    }

    save = Hotbar:ReturnFromHooks("GetHotbarSaveData", save)

    IO.SaveFile(Hotbar.SAVE_FILENAME, save)

    Hotbar:FireEvent("SaveDataSaved")
end

---Loads saved data from the disk: loadouts, hotkey buttons.
function Hotbar.LoadData()
    local save = IO.LoadFile(Hotbar.SAVE_FILENAME)

    if save then
        for i,state in ipairs(save.Hotkeys) do
            Hotbar.SetHotkeyAction(i, state.ActionID)
        end

        if save.Loadouts then
            Hotbar.Loadouts = save.Loadouts -- TODO validation

            -- Ensure a name field is present (v1053+)
            for id,loadout in pairs(Hotbar.Loadouts) do
                if not loadout.Name then
                    loadout.Name = id
                end
            end
        end

        Hotbar:FireEvent("SaveDataLoaded", save)
    end
end

---Get the amount of visible bars that char has.
---@param char? EclCharacter Defaults to Client character
---@return integer
function Hotbar.GetBarCount(char)
    char = char or Client.GetCharacter()
    local state = Hotbar.GetState(char)
    local open = 0

    for i,_ in ipairs(state.Bars) do
        if Hotbar.IsBarVisible(i) then
            open = open + 1
        end
    end

    return open
end

---Attempts to fix desync between current engine row and our bar. The engine current row must be set to 1 at all times for correct functioning.
function Hotbar.ResyncEngineRow()
    local realRow = Hotbar.GetCurrentRealRow()
    while realRow > 1 do
        Hotbar:ExternalInterfaceCall("prevHotbar")
        realRow = realRow - 1
    end
end

---Uses a slot from the hotbar UI.
---@param index integer Slot to use.
---@param isEnabled boolean? Passed to the ExternalInterfaceCall. Purpose unknown.
function Hotbar.UseSlot(index, isEnabled)
    Hotbar:DebugLog("Pressed slot: " .. index)
    local slot = Hotbar.GetSlotHolder().slot_array[index - 1]
    local data = Client.GetCharacter().PlayerData.SkillBarItems[index]

    Hotbar:GetUI():ExternalInterfaceCall("slotPressed", index - 1, isEnabled or true)

    Hotbar.lastClickedSlot = index

    Hotbar.Events.SlotPressed:Throw({
        SlotData = data,
        Index = index,
        IsEnabled = slot.isEnabled,
    })

    -- Must wait for the skill state to be initialized.
    Timer.StartTickTimer(3, function ()
        Hotbar.UpdateActiveSkill()
    end)
end

---Updates the active skill visual.
---Not necessary to call when using skills via keyboard keys.
function Hotbar.UpdateActiveSkill()
    local char = Client.GetCharacter()
    local skillState = Character.GetSkillState(char)
    local slotHolder = Hotbar.GetSlotHolder()
    local index = -1
    if skillState and Character.IsPreparingSkill(char) then
        local skillID = Character.GetCurrentSkill(char)
        -- A strange use of the predicate, but whatever.
        Hotbar.GetSkillBarItems(char, function (_, slot, slotIndex)
            local valid = false
            -- If we clicked a slot recently, prioritize it.
            -- Otherwise use the last slot with the skill.
            -- A skill CAN be in multiple slots, particularly on different rows, or via shifting across rows.
            if slot.SkillOrStatId == skillID and (index == -1 or slotIndex == Hotbar.lastClickedSlot) then
                index = slotIndex - 1 -- Subtract one because we're sending to flash.
                valid = true
            end
            return valid
        end)
    end
    slotHolder.showActiveSkill(index)
end

---Adds an additional bar to char. Bars are added from bottom to top.
---@param char? EclCharacter
function Hotbar.AddBar(char)
    char = char or Client.GetCharacter()
    local count = Hotbar.GetBarCount(char)
    local state = Hotbar.GetState(char)
    local hook = {BarToAddIndex = count + 1, CanAdd = count < 5} ---@type HotbarUI_Hook_CanAddBar

    Hotbar.Hooks.CanAddBar:Throw(hook)

    -- Cannot have more than 5 bars.
    if hook.CanAdd and count < 5 then
        state.Bars[count + 1].Visible = true
    end

    if Hotbar.IsDrawerOpen() then
        Hotbar.PositionDrawer()
    end

    Hotbar.Refresh()
    Hotbar.RenderSlots()

    Hotbar.Events.StateChanged:Throw({
        Character = char,
        State = state,
    })
end

---Removes a bar from char. Bars are removed from top to bottom.
---@param char EclCharacter?
function Hotbar.RemoveBar(char)
    char = char or Client.GetCharacter()
    local count = Hotbar.GetBarCount(char)
    local state = Hotbar.GetState(char)
    local hook = {BarToRemoveIndex = count, CanRemove = count > 1} ---@type HotbarUI_Hook_CanRemoveBar

    Hotbar.Hooks.CanRemoveBar:Throw(hook)

    -- Can't remove the first bar! Not even if hooked.
    if hook.CanRemove and count > 1 then
        state.Bars[count].Visible = false

        -- Hide activeSkill highlight if it was in this row
        local slotHolder = Hotbar.GetSlotHolder()
        if slotHolder.activeSkillSlotNr >= (Hotbar.GetSlotsPerRow() * (count - 1)) then
            slotHolder.showActiveSkill(-1)
        end
    end

    if Hotbar.IsDrawerOpen() then
        Hotbar.PositionDrawer()
    end

    Hotbar.Refresh()

    Hotbar.Events.StateChanged:Throw({
        Character = char,
        State = state,
    })
end

---Cycles a bar's row.
---@param index integer Bar index.
---@param increment -1|1 Direction to cycle.
function Hotbar.CycleBar(index, increment)
    local char = Client.GetCharacter()
    local state = Hotbar.GetState(char)
    local bar = state.Bars[index]

    -- Can only cycle visible bars.
    if Hotbar.IsBarVisible(index) then
        local currentRowIndex = bar.Row
        local nextRowIndex = currentRowIndex + increment
        if nextRowIndex < 1 then nextRowIndex = 5 -- Loop index
        elseif nextRowIndex > 5 then nextRowIndex = 1 end
        local nextBar = nil

        for _,otherBar in ipairs(state.Bars) do
            if otherBar.Row == nextRowIndex then
                nextBar = otherBar
                break
            end
        end

        if nextBar then -- attempt to swap rows
            nextBar.Row = currentRowIndex
        end

        bar.Row = nextRowIndex

        Hotbar:DebugLog("Cycled bar " .. index)

        Hotbar.Events.StateChanged:Throw({
            Character = char,
            State = state,
        })
    end
end

---Returns whether the hotbar is locked.
---@return boolean
function Hotbar.IsLocked()
    return Hotbar:GetRoot().hotbar_mc.lockButton_mc.bIsLocked and not Hotbar:GetRoot().inSkillPane
end

---Returns the maximum amount of slots per hotbar row.
function Hotbar.GetSlotsPerRow()
    return Hotbar.SLOTS_PER_ROW
end

---@param char EclCharacter
---@param skillID string
---@param casting boolean
function Hotbar.SetPreparedSkill(char, skillID, casting)
    if not char then char = Client.GetCharacter() end

    if skillID then
        skillID = string.match(skillID, "^(.*)%_%-1$") -- remove the level suffix
    end

    if skillID then
        Hotbar.PreparedSkills[char.NetID] = {
            SkillID = skillID,
            StartTime = Ext.Utils.MonotonicTime(),
            Casting = casting,
        }

        Hotbar:FireEvent("SkillUseEntered", skillID)
        Hotbar:DebugLog("Using skill " .. skillID)

        -- Hotbar:GetRoot().showActiveSkill(-1)
    else
        Hotbar.PreparedSkills[char.NetID] = nil

        Hotbar:DebugLog("Exiting skill.")
        Hotbar:FireEvent("SkillUseExited")
    end

    Hotbar:FireEvent("SkillUseChanged", skillID)

    Hotbar.RenderSlots()
end

---Returns whether a slot is enabled.
---Enabled slots hold currently usable objects.
---Disabled slots appear greyed out.
---@param index integer 1-based.
---@return boolean
function Hotbar.IsSlotEnabled(index)
    return _SlotElements[index - 1].isEnabled
end

---Returns the slots currently being hovered.
---@return integer?, EocSkillBarItem? --Both `nil` if no slot is being hovered. Index is 1-based.
function Hotbar.GetHoveredSlot()
    local index = Hotbar.GetSlotHolder().currentHLSlot
    local slotData = nil
    if index >= 0 then
        slotData = Hotbar.GetSlotData(nil, index + 1)
        index = index + 1
    else
        index = nil
    end
    return index, slotData
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for cursor dragging ending on a hotkey button.
Hotbar:RegisterCallListener("pipStoppedDragOnButton", function (_, index)
    if Pointer.IsDragging() then
        Hotbar:DebugLog("Assigning slot to hotkey button!" .. index)

        Hotbar.Events.ContentDraggedToHotkey:Throw({
            DragDrop = Pointer.GetDragDropState(),
            Index = index + 1,
        })
    end
end)

-- Listen for context menu being requested.
Hotbar:RegisterCallListener("pipHotbarOpenContextMenu", function (_)
    Hotbar:DebugLog("Toggling drawer from hotkey")

    Hotbar.ToggleDrawer()
end)

-- Listen for slots being pressed.
Hotbar:RegisterCallListener("pipSlotPressed", function (_, index, isEnabled, _)
    Hotbar:DebugLog("Mouse pressed slot " .. index)

    Hotbar.UseSlot(index + 1, isEnabled)
end)

-- Listen for slots being hovered.
Hotbar:RegisterCallListener("SlotHover", function (_, index)
    local slotHolder = Hotbar.GetSlotHolder()
    local slotData = Hotbar.GetSlotData(nil, index + 1)

    slotHolder.setHighlightedSlot(index)

    Hotbar.Events.SlotHovered:Throw({
        SlotData = slotData,
        Index = index + 1,
        IsEnabled = Hotbar.IsSlotEnabled(index + 1),
    })
end)

-- Listen for the UI requesting a slots update.
Hotbar:RegisterCallListener("updateSlots", function (_, _)
    Hotbar.RenderSlots()
end)
Hotbar:RegisterCallListener("pipUpdateSlots", function (_, _) -- Fired from onEventResolution
    Hotbar.UpdateSlotTextures()
end, "After")

-- Listen for hotbar cyclers being pressed.
local function CycleHotbar(barIndex, increment)
    -- Use modifier keys to select higher hotbars
    -- Yes this is slightly ridiculous
    if Input.IsGUIPressed() then -- Cycle 5th bar
        barIndex = barIndex + 4
    elseif Input.IsAltPressed() then -- Cycle 4th bar
        barIndex = barIndex + 3
    elseif Input.IsCtrlPressed() then -- Cycle 3rd bar
        barIndex = barIndex + 2
    elseif Input.IsShiftPressed() then -- Cycle 2nd bar
        barIndex = barIndex + 1
    end

    Hotbar:DebugLog("Trying to cycle " .. barIndex)

    Hotbar.UpdateSlotTextures()
    Hotbar.CycleBar(barIndex, increment) -- cycle our own scripted bars

    Hotbar.RenderSlots()
end
Hotbar:RegisterCallListener("pipPrevHotbar", function (_, _, index)
    CycleHotbar(index, -1)
end)
Hotbar:RegisterCallListener("pipNextHotbar", function (_, _, index)
    CycleHotbar(index, 1)
end)

-- Listen for engine action holder being updated. Does not include setting the active action.
Hotbar:RegisterInvokeListener("updateActionSkills", function (ev)
    local array = ev.UI:GetRoot().actionSkillArray
    local hook = Hotbar.Hooks.UpdateEngineActions:Throw({
        Actions = Client.Flash.ParseArray(array, Hotbar.ARRAY_ENTRY_TEMPLATES.ACTIONS)
    })

    Client.Flash.EncodeArray(array, Hotbar.ARRAY_ENTRY_TEMPLATES.ACTIONS, hook.Actions)

    Hotbar.engineActionsCount = #hook.Actions

    Hotbar.UpdateActionHolder()
end, "Before")

-- Listen for the UI being toggled by the engine.
-- Unlike most UIs, the hotbar does not use Show() and Hide()
Hotbar:RegisterInvokeListener("showSkillBar", function (_, enabled)
    local root = Hotbar:GetRoot()
    local isSummon = Game.Character.IsSummon(Client.GetCharacter())

    Hotbar.GetHotkeysHolder().visible = enabled

    root.hotbar_mc.pip_baseframe.visible = enabled
    root.hotbar_mc.plusBtn_mc.visible = enabled and not isSummon
    root.hotbar_mc.minusBtn_mc.visible = enabled and not isSummon
    root.hotbar_mc.drawerBtn_mc.visible = enabled
    root.hotbar_mc.pip_baseframe2.visible = enabled

    if not enabled then
        root.hotbar_mc.cycleHotBar2_mc.visible = false
        root.hotbar_mc.cycleHotBar3_mc.visible = false
        root.hotbar_mc.cycleHotBar4_mc.visible = false
        root.hotbar_mc.cycleHotBar5_mc.visible = false
    else
        Hotbar.Refresh()
    end

    Hotbar.elementsToggled = enabled
end, "After")

-- Listen for engine requests to refresh slots.
Hotbar:RegisterInvokeListener("updateSlots", function (_, _, _)
    Hotbar.Refresh()
end)

-- Listen for player handle being set.
Hotbar:RegisterInvokeListener("setPlayerHandle", function (_, playerHandle)
    Hotbar.UpdateSlotTextures()

    Utilities.Hooks.FireEvent("Client", "ActiveCharacterChanged", playerHandle)

    Hotbar.ResyncEngineRow()

    Hotbar.RenderSlots()
end, "After")

-- Update slots whenever the engine would request so.
Hotbar:RegisterInvokeListener("updateSlots", function (_, _)
    Hotbar.RenderSlots()
end)

-- Listen for hotkey buttons being unbound.
Hotbar:RegisterCallListener("pipUnbindHotbarButton", function (_, index)
    Hotbar:DebugLog("Unbinding hotkey button", index)

    Hotbar.UnbindActionButton(index + 1)

    Hotbar.RenderHotkeys()
end)

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_SetLayout", function(payload)
    Hotbar.SetState(Character.Get(payload.CharacterNetID), payload.Layout)
end)

-- Save when the game is saved
Utilities.Hooks.RegisterListener("Saving", "SavingStarted", function()
    Hotbar.SaveData()
end)

-- Save when the pause menu is opened.
Client.UI.GameMenu.Events.Opened:Subscribe(function (_)
    if GameState.IsInSession() then
        Hotbar.SaveData()
    end
end)

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting.ModTable == "Epip_Hotbar" and ev.Setting.ID == "HotbarCombatLogLegacyBehaviour" then
        Hotbar.PositionCombatLogButton()
    end
end)

Hotbar:RegisterCallListener("pipAddHotbar", function(_)
    Hotbar.AddBar()

    Hotbar.Events.BarPlusMinusButtonPressed:Throw({IsPlusButton = true})
end)

Hotbar:RegisterCallListener("pipRemoveHotbar", function(_)
    Hotbar.RemoveBar()

    Hotbar.Events.BarPlusMinusButtonPressed:Throw({IsPlusButton = false})
end)

-- Redirect keyboard hotkeys to point to the expected slot.
Hotbar:RegisterCallListener("pipSlotKeyAttempted", function(_, index)
    local state = Hotbar.GetState()
    local firstBarRow = state.Bars[1].Row
    local keyIndex = index + 1
    index = index + 1

    -- Do not use slots by default if modifier keys are held, as
    -- they will likely conflict with Input action bindings. 
    if not Input.AreModifierKeysPressed() then
        index = index + (firstBarRow - 1) * Hotbar.GetSlotsPerRow()
    else
        index = nil
    end

    index = Hotbar.Hooks.GetSlotForIggyEvent:Throw({
        SlotKeyIndex = keyIndex,
        SlotIndex = index,
    }).SlotIndex

    if index then
        Hotbar:DebugLog("Used slot from keyboard: " .. index .. " redirected to index " .. index)
        Hotbar:GetRoot().useSlotFromKey(index - 1) -- Uses 0-based indexing.
    end
end)

-- Refresh on reset.
GameState.Events.GameReady:Subscribe(function ()
    Hotbar.initialized = true
    Hotbar.LoadData()
    Hotbar.Refresh()
end, {EnabledFunctor = function () return not Client.IsUsingController() end})

Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    local actionPattern = "EpipEncounters_Hotbar_(%d+)"
    local index = ev.Action.ID:match(actionPattern)
    if index then
        Hotbar.PressHotkey(tonumber(index))
    end
end)

-- Refresh the hotbar elements preiodically.
GameState.Events.RunningTick:Subscribe(function (e)
    if Client.IsUsingController() then return end

    -- Refresh the hotbar when it comes into view.
    local visible = Hotbar:IsVisible()
    if visible ~= Hotbar.wasVisible then
        Hotbar.wasVisible = visible
        if visible then -- Update slots when the hotbar becomes visible again.
            Timer.Start(0.1, function()
                Hotbar.RenderSlots()
            end)
        end

        Hotbar.PositionCombatLogButton()
    end

    -- Update cooldowns and hotkeys
    if Hotbar.initialized then
        Hotbar._CooldownsUpdateTimer = Hotbar._CooldownsUpdateTimer - e.DeltaTime
        if Hotbar._CooldownsUpdateTimer <= 0 then
            Hotbar.RenderCooldowns()
            Hotbar._CooldownsUpdateTimer = Hotbar.COOLDOWN_UPDATE_DELAY
        end
        Hotbar._CustomRequirementsCheckTimer = Hotbar._CustomRequirementsCheckTimer - e.DeltaTime
        if Hotbar._CustomRequirementsCheckTimer <= 0 then
            Hotbar.UpdateSkillsWithCustomRequirements()
            Hotbar._CustomRequirementsCheckTimer = Hotbar.CUSTOM_REQUIREMENTS_UPDATE_DELAY
        end
        Hotbar._HotkeysUpdateTimer = Hotbar._HotkeysUpdateTimer - e.DeltaTime
        if Hotbar._HotkeysUpdateTimer <= 0 then
            Hotbar.RenderHotkeys()
            Hotbar._HotkeysUpdateTimer = Hotbar.HOTKEYS_UPDATE_DELAY
        end
    end
end)

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

---@param i integer
---@param state HotbarActionState
function Hotbar.RenderHotkey(i, state)
    local hotkeys = Hotbar.GetHotkeysHolder()
    local element = hotkeys.hotkeyButtons[i - 1]
    local hasAction = Hotbar.HasBoundAction(i)
    local keyString
    local enabled = Hotbar.IsActionEnabled(state.ActionID, i)
    local actionID = state.ActionID or ""
    local actionData = Hotbar.GetActionData(state.ActionID)

    if actionID ~= "" and actionData == nil then
        Hotbar:Log("Unbinding unregistered action: " .. state.ActionID)

        Hotbar.UnbindActionButton(i)
    else
        local index = (i - 1) % 6 -- index on each row
        -- Update action
        element.setAction(actionID)
        element.action = actionID
        element.mouseChildren = false
        element.text_mc.x = -17
        element.text_mc.y = 27
        element.icon_mc.mouseEnabled = false
        element.setActionEnabled(enabled)
        element.setHighlighted(Hotbar.IsActionHighlighted(actionID))

        if hasAction then
            -- Icon
            local icon = Hotbar.GetActionIcon(actionID, i)
            Hotbar._SetHotkeyIcon(i, icon)

            -- Keybind text
            keyString = Hotbar.GetKeyString(i)

            if keyString ~= "" and Settings.GetSettingValue("Epip_Hotbar", "HotbarHotkeysText") then
                element.text_mc.htmlText = "<font size='14.5' align='center'>" .. keyString .. "</font>" -- TODO
                element.icon_mc.y = 4
            else
                element.text_mc.htmlText = ""
                CenterElement(element.icon_mc, element, "y", 32)
            end

            local tooltipKeyString = Hotbar.GetKeyString(i, false)
            local tooltip = Hotbar.GetActionName(actionData.ID, i)
            if tooltipKeyString ~= "" then
                tooltip = Text.Format("%s (%s)", {
                    FormatArgs = {
                        Hotbar.GetActionName(actionData.ID, i),
                        tooltipKeyString
                    }
                })
            end

            element.tooltip = tooltip
            element.tooltipString = tooltip
        else
            element.text_mc.htmlText = ""
            element.tooltipString = ""
            element.tooltip = ""
        end

        -- Hide buttons on second row if the row is hidden
        if i >= 7 and not Hotbar.HasSecondHotkeysRow() then
            element.visible = false
            element.x = -5000
        else
            element.visible = true
            element.x = 72 + (index * 34) + (3 * index)
        end

        element.iconY = element.icon_mc.y

        element.y = 64.5
        if i > 6 then
            element.y = element.y - 63
        end

        element.icon_mc.x = 1

        element.icon_mc.visible = hasAction
        element.text_mc.visible = hasAction
    end
end

---Sets the icon for a hotkey button.
---@param index integer 1-based.
---@param icon icon
function Hotbar._SetHotkeyIcon(index, icon)
    if Hotbar._HotkeyIcons[index] == icon then return end -- Do nothing if the icon hasn't changed, as setting iggy icons is expensive.
    Hotbar:GetUI():SetCustomIcon("pip_hotkey_" .. (index - 1), icon, 32, 32)
    Hotbar._HotkeyIcons[index] = icon
end

function Hotbar.RenderHotkeys()
    for i,state in ipairs(Hotbar.GetActionButtons()) do
        local success, error = pcall(Hotbar.RenderHotkey, i, state)

        if not success then
            Hotbar:LogError("Error rendering hotkey " .. i .. " " .. state.ActionID)
            Hotbar:LogError(error)

            Hotbar.UnbindActionButton(i)
        end
    end
end

function Hotbar.GetHotkeysHolder()
    return Hotbar:GetRoot().hotbar_mc.hotkeys_pip_mc
end

function Hotbar.RenderDrawerButtons()
    local hotkeys = Hotbar.GetHotkeysHolder()
    local drawerButtonArray = hotkeys.drawer_mc.content_array

    for _,id in ipairs(Hotbar.RegisteredActionOrder) do
        local enabled = Hotbar.IsActionEnabled(id)
        local visible = Hotbar.IsActionVisibleInDrawer(id)
        local button

        if visible then
            hotkeys.addDrawerButton()
            button = drawerButtonArray[#drawerButtonArray - 1]

            button.text_mc.htmlText = Hotbar.GetActionName(id)
            button.text_mc.width = 100
            button.text_mc.x = 25
            button.text_mc.autoSize = "left"
            CenterElement(button.text_mc, button, "y")
            button.action = id
            -- button.tooltipString = data.Name
            button.tooltipString = "" -- TODO
            button.setEnabled(enabled)
            button.internal_disabled_mc.visible = not enabled -- Wtf man. Why can we not get this to work in flash?

            CenterElement(button.icon_mc, button, "y", 32)
            button.iconY = button.icon_mc.y
            button.icon_mc.x = 5

            button.icon_mc.width = 32
            button.icon_mc.height = 32

            Hotbar:GetUI():SetCustomIcon("pip_drawerButton_" .. Text.RemoveTrailingZeros(button.index), Hotbar.GetActionIcon(id), 32, 32)
        end
    end
end

function Hotbar.ShouldShowSourceFrame(index)
    local bar = Client.GetCharacter().PlayerData.SkillBarItems
    local slot = bar[index + 1]
    local show = false

    if slot.Type == "Skill" then
        local stat = Stats.Get("SkillData", slot.SkillOrStatId)

        if stat then
            show = stat["Magic Cost"] > 0
        end
    end

    return show
end

function Hotbar.UpdateSlot(index)
    local slot = _SlotElements[index]
    local row = Hotbar.GetRowForSlot(index + 1)

    -- Only update visible slots
    if Hotbar.IsRowVisible(nil, row) then
        -- Icon
        local icon = Hotbar.GetIconForSlot(index)
        if icon then
            Hotbar._SetSlotIcon(index, icon)
            slot.icon_mc.visible = true
        else
            slot.icon_mc.visible = false
        end

        -- Source frame
        slot.source_frame_mc.visible = Hotbar.ShouldShowSourceFrame(index)
    end
end

---Sets the icon for a slot.
---@param index integer 1-based.
---@param icon icon
function Hotbar._SetSlotIcon(index, icon)
    if Hotbar._SlotIcons[index] == icon then return end -- Do nothing if the icon hasn't changed, as setting iggy icons is expensive.
    Hotbar:GetUI():SetCustomIcon("pip_hotbar_slot_" .. index, icon, 48, 48)
    Hotbar._SlotIcons[index] = icon
end

function Hotbar.GetIconForSlot(index)
    local bar = Client.GetCharacter().PlayerData.SkillBarItems
    local slot = bar[index + 1]
    local icon
    if slot.Type == "Skill" then
        local stat = Stats.Get("StatsLib_StatsEntry_SkillData", slot.SkillOrStatId)
        if stat then
            icon = stat.Icon
        end
    elseif slot.Type == "Item" then
        local item = Item.Get(slot.ItemHandle)
        icon = Item.GetIcon(item)
    elseif slot.Type == "Action" then
        local action = Stats.GetAction(slot.SkillOrStatId)
        icon = action.Icon
    end
    return icon
end

---Returns the amount of slots visible per row,
---determined by resolution and UI scaling.
---Transcribed from `MainTimeline.as3`.
---@return integer
function Hotbar.GetVisibleSlotsPerRow()
    local root = Hotbar:GetRoot()
    local viewport = Client.GetViewportSize()
    viewport[1] = viewport[1] / root.uiScaling
    viewport[2] = viewport[2] / root.uiScaling
    local scaledUIWidth = math.floor(viewport[1] / viewport[2] * (root.designResolution.y / root.uiScaling))
    local slots
    if scaledUIWidth < root.designResolution.x then
        if scaledUIWidth > root.baseBarWidth then
            slots = math.floor((scaledUIWidth - root.baseBarWidth) / root.visualSlotWidth)
        end
    else
        slots = Hotbar.SLOTS_PER_ROW
    end
    return slots
end

function Hotbar.UpdateActionHolder()
    local dualLayout = Hotbar.HasSecondHotkeysRow()
    local actionSkillHolder = Hotbar:GetRoot().actionSkillHolder_mc
    local y = 742 - (Hotbar.engineActionsCount - 3) * 55

    if dualLayout then
        y = y - 70
    end

    actionSkillHolder.y = y
end

function Hotbar.UpdateFrame()
    local dualLayout = Hotbar.HasSecondHotkeysRow()
    local bottomBar = Hotbar:GetRoot().hotbar_mc

    if Hotbar.elementsToggled then
        bottomBar.drawerBtn_mc.visible = dualLayout
        bottomBar.pip_baseframe2.visible = not dualLayout
        bottomBar.pip_baseframe.visible = dualLayout
    end

    bottomBar.iggy_ci.x = 17 -- TODO move
    bottomBar.portraitHitBox_mc.x = 17

    if dualLayout then
        bottomBar.iggy_ci.y = 27
        bottomBar.portraitHitBox_mc.y = 27
    else
        bottomBar.iggy_ci.y = 62
        bottomBar.portraitHitBox_mc.y = 62
    end

    Hotbar.UpdateActionHolder()
end

function Hotbar.PositionDrawer()
    local hotkeys = Hotbar.GetHotkeysHolder()
    local dualLayout = Hotbar.HasSecondHotkeysRow()

    if dualLayout then
        hotkeys.drawer_mc.y = -10 - hotkeys.drawer_mc.height
    else
        hotkeys.drawer_mc.y = 60 - hotkeys.drawer_mc.height
    end
end

function Hotbar.RenderCooldowns()
    if not Hotbar.CUSTOM_RENDERING then return nil end
    local SLOTS_PER_ROW = Hotbar.SLOTS_PER_ROW
    local char = Client.GetCharacter()
    local skillBar = char.PlayerData.SkillBarItems
    local skills = char.SkillManager.Skills
    local startingBar = 2
    local canUseHotbar = Hotbar.CanUseHotbar()

    if not Hotbar:GetRoot().useArrays then
        startingBar = 1
    end

    for rowIndex=startingBar,5,1 do
        if Hotbar.IsRowVisible(char, rowIndex) then
            for i=0,SLOTS_PER_ROW-1,1 do
                local slotIndex = (rowIndex - 1) * SLOTS_PER_ROW + i
                local slot = _SlotElements[slotIndex]
                local data = skillBar[slotIndex + 1]
                local previousCooldown = slot.oldCD
                local cooldown = 0

                if data.Type == "Skill" then
                    ---@type EclSkill
                    local skill = skills[data.SkillOrStatId]
                    if skill then
                        cooldown = skill.ActiveCooldown / 6
                    else -- The skill was removed from the character.
                        cooldown = 0
                    end
                end

                -- If this slot was changed away from a skill,
                -- remove the cooldown without playing the finished animation.
                if data.Type ~= "Skill" and previousCooldown > 0 then
                    cooldown = -1
                end

                -- Avoid running the AS method if the cooldown hasn't changed.
                if previousCooldown ~= cooldown then
                    slot.setCoolDown(cooldown, true)
                end

                if not canUseHotbar then -- TODO figure out what is fucking with this - it must be the setCooldown function somehow. Slots get enabled when they shouldn't be
                    slot.disable_mc.alpha = 1
                end
            end
        end
    end
end

---@param skill string|EclItem
function Hotbar.UseSkill(skill)
    local char = Client.GetCharacter()
    local skillBar = char.PlayerData.SkillBarItems
    local slotIndex = Hotbar.MAX_SLOTS
    local slot = skillBar[slotIndex]
    local previousSkill

    if GetExtType(skill) == "ecl::Item" then
        Net.PostToServer("EPIPENCOUNTERS_Hotbar_UseItem", {
            ItemNetID = skill.NetID,
            CharacterNetID = char.NetID,
        })
    else
        if slot.Type == "Skill" then
            previousSkill = slot.SkillOrStatId
        end

        if type(skill) == "string" then
            skillBar[slotIndex].SkillOrStatId = skill
            skillBar[slotIndex].Type = "Skill"
        else
            skillBar[slotIndex].ItemHandle = skill.Handle
            skillBar[slotIndex].Type = "Item"
        end

        Hotbar.UpdateSlotTextures()

        Timer.Start("UseHotbarSlot", 0.05, function()
            Hotbar.UseSlot(slotIndex)

            -- Rebind the auxiliary slot back to its original skill
            -- Clearing the item handle field appears to be unnecessary.
            if previousSkill ~= nil then
                Ext.OnNextTick(function()
                    char = Client.GetCharacter()
                    char.PlayerData.SkillBarItems[slotIndex].SkillOrStatId = previousSkill
                    Hotbar.lastClickedSlot = nil
                    Hotbar.UpdateSlotTextures()
                    Hotbar.Refresh()
                    Hotbar.RenderSlots()
                    Hotbar.UpdateSlot(slotIndex)
                end)
            else
                Ext.OnNextTick(function()
                    char = Client.GetCharacter()
                    char.PlayerData.SkillBarItems[slotIndex].Type = "None"
                    Hotbar.lastClickedSlot = nil
                    Hotbar.UpdateSlotTextures()
                    Hotbar.Refresh()
                    Hotbar.RenderSlots()
                    Hotbar.UpdateSlot(slotIndex)
                end)
            end
        end)
    end
end

---@param char EclCharacter
---@param canUseHotbar boolean
---@param slotIndex integer 1-based.
---@param skillBarSlot EocSkillBarItem? Fetched via `slotIndex` if necessary. Passable for performance reasons.
function Hotbar.RenderSlot(char, canUseHotbar, slotIndex, skillBarSlot)
    local slotHolder = Hotbar.GetSlotHolder()
    skillBarSlot = skillBarSlot or char.PlayerData.SkillBarItems[slotIndex]
    slotIndex = slotIndex - 1 -- SIKE YA THOUGHT!!!!

    local slot = _SlotElements[slotIndex]
    local data = skillBarSlot

    local inUse = true -- Whether the slot holds anything.
    local amount = 0
    local slotType = 0
    local handle = 0
    local tooltip = "" -- TODO is this only for skills?
    local isEnabled = false -- TODO
    local cooldown = 0
    local unavailable = false

    -- Types: 0 empty, 1 skill, 2 item
    if data.Type == "Skill" then
        local skill = char.SkillManager.Skills[data.SkillOrStatId]
        slotType = 1
        tooltip = data.SkillOrStatId

        if skill then
            cooldown = skill.ActiveCooldown / 6

            handle = Ext.HandleToDouble(skill.OwnerHandle)

            isEnabled = Character.CanUseSkill(char, data.SkillOrStatId)

            if not skill.IsLearned then
                unavailable = true
            end
        else -- The skill was removed from the character.
            cooldown = 0
            handle = Ext.HandleToDouble(char.Handle)
            isEnabled = false
            unavailable = Stats.Get("SkillData", data.SkillOrStatId) ~= nil -- Only show warning if the skill exists in the current session
        end
    elseif data.Type == "Item" then
        local item = Item.Get(data.ItemHandle)
        slotType = 2
        handle = Ext.HandleToDouble(item.Handle)
        amount = item.Amount
        isEnabled = Item.CanUse(char, item)
    elseif data.Type == "Action" then
        slotType = 1
        isEnabled = true
        tooltip = data.SkillOrStatId
        handle = Ext.HandleToDouble(char.Handle)
    elseif data.Type == "None" then
        inUse = false
    end

    slot.SetUnavailable(unavailable)

    -- Disable using any slots during combat, outside your turn, or while casting a skill.
    if not canUseHotbar then
        isEnabled = false
    end

    -- print(inUse, slot.tooltip, slot.isEnabled, "isUpdate", slot.isUpdated, "type", slot.type, "handle", slot.handle, slot.oldCD, slot.setCoolDown)
    slotHolder.pipSetSlot(slotIndex, tooltip, isEnabled and cooldown <= 0, inUse, handle, slotType, amount)
    slot.isUpdated = true

    if not isEnabled and cooldown <= 0 then
        slot.disable_mc.alpha = 1
    end

    -- slot.unavailable_mc.visible = false -- Leftover from DOS1. (SetSlotPreviewEnabledMC)

    -- We no longer rely on this as it fucks with the cooldown values. Apparently the original code is optimized enough to only update this when needed.
    -- slotHolder.setSlot(slotIndex, tooltip, isEnabled and cooldown <= 0, handle, slotType, amount)
end

---Attempts to update a slot.
---@param char EclCharacter
---@param slotIndex integer 1-based.
---@param skillBar EocSkillBarItem[]
---@param canUseHotbar boolean
function Hotbar._TryRenderSlot(char, slotIndex, skillBar, canUseHotbar)
    local success, msg = pcall(Hotbar.RenderSlot, char, canUseHotbar, slotIndex, skillBar[slotIndex])
    if not success then
        local data = Hotbar.GetSkillBarItems(char)[slotIndex]
        Hotbar:__LogError("Error rendering slot " .. (slotIndex))
        Hotbar:__LogError(msg)
        Hotbar:__LogError(string.format("Slot data: type %s skillID %s", data.Type, data.SkillOrStatId))
    end
end

function Hotbar.RenderSlots()
    local SLOTS_PER_ROW = Hotbar.SLOTS_PER_ROW
    local char = Client.GetCharacter()

    if not Hotbar.CUSTOM_RENDERING or not char then return nil end
    local skillBar = char.PlayerData.SkillBarItems

    local startingBar = 2
    local canUseHotbar = Hotbar.CanUseHotbar()

    if not canUseHotbar or not Hotbar:GetRoot().useArrays then
        startingBar = 1
    end

    for rowIndex=startingBar,5,1 do
        if Hotbar.IsRowVisible(char, rowIndex) then
            for i=0,SLOTS_PER_ROW - 1,1 do
                local slotIndex = (rowIndex - 1) * SLOTS_PER_ROW + i
                Hotbar._TryRenderSlot(char, slotIndex + 1, skillBar, canUseHotbar)
            end
        end
    end
end

---Updates all slots that contain skills with custom requirements.
function Hotbar.UpdateSkillsWithCustomRequirements()
    local SLOTS_PER_ROW = Hotbar.SLOTS_PER_ROW
    local char = Client.GetCharacter()
    local canUseHotbar = Hotbar.CanUseHotbar()
    local skillBar = char.PlayerData.SkillBarItems

    for rowIndex=1,5,1 do
        if Hotbar.IsRowVisible(char, rowIndex) then
            for i=0,SLOTS_PER_ROW - 1,1 do
                local slotIndex = (rowIndex - 1) * SLOTS_PER_ROW + i
                local skillbarItem = skillBar[slotIndex + 1]
                if skillbarItem.Type == "Skill" then
                    local skillID = skillbarItem.SkillOrStatId

                    -- Track skills with custom requirements,
                    -- as these require the hotbar to update periodically to validate them.
                    if not Hotbar._SkillsCheckedForCustomRequirements[skillID] then
                        local stat = Stats.GetSkillData(skillID)
                        if stat then -- Skills from removed mods are not removed from the skillbar.
                            for _,req in ipairs(stat.Requirements) do -- Memorization requirements should be unnecessary to check.
                                if req.Requirement.Value > Stats.Enums.REQUIREMENT_TYPE_HIGHEST_VANILLA_ID then
                                    Hotbar._SkillsWithCustomRequirements[skillID] = true
                                end
                            end
                        end
                        Hotbar._SkillsCheckedForCustomRequirements[skillID] = true
                    end

                    if Hotbar._SkillsWithCustomRequirements[skillbarItem.SkillOrStatId] then
                        Hotbar._TryRenderSlot(char, slotIndex + 1, skillBar, canUseHotbar)
                    end
                end
            end
        end
    end
end

function Hotbar.PositionBar(index, row)
    -- Position cyclers
    if index > 1 then
        local buttons = Hotbar:GetRoot().hotbar_mc["cycleHotBar" .. (index) .. "_mc"]

        buttons.barIndex = index
        buttons.x = Hotbar.POSITIONING.CYCLERS.X
        buttons.y = (index - 2) * Hotbar.POSITIONING.CYCLERS.Y
        buttons.visible = Hotbar.elementsToggled
        buttons.text_txt.htmlText = tostring(row)
        buttons.text_txt.align = "center"
        buttons.text_txt.autoSize = "center"
        buttons.text_txt.mouseEnabled = false
    else
        local buttons = Hotbar:GetRoot().hotbar_mc.cycleHotBar_mc
        buttons.text_txt.htmlText = tostring(row)
        buttons.x = Hotbar.POSITIONING.CYCLERS.X
    end

    local SLOTSIZE = Hotbar.SLOT_SIZE
    local SLOTSPACING = Hotbar.SLOT_SPACING

    -- Position slots
    local visibleSlotsPerRow = Hotbar.GetVisibleSlotsPerRow()
    for i=0,Hotbar.GetSlotsPerRow()-1,1 do
        local slotIndex = ((row - 1) * Hotbar.GetSlotsPerRow()) + i
        local slot = _SlotElements[slotIndex]

        slot.x = (i * SLOTSIZE) + (i * SLOTSPACING) + 1

        slot.y = (-(SLOTSIZE + SLOTSPACING * 2) + 7) * (index - 1)
        slot.y = slot.y + (index - 2)

        Hotbar.UpdateSlot(slotIndex)
        slot.visible = i < visibleSlotsPerRow
    end
end

function Hotbar.HideBar(index, row)
    -- Hide slots
    for i=0,Hotbar.GetSlotsPerRow()-1,1 do
        local slotIndex = ((row - 1) * Hotbar.GetSlotsPerRow()) + i
        local slot = _SlotElements[slotIndex]

        slot.y = 500
    end
    -- Hide cycler
    if index > 1 then
        local buttons = Hotbar:GetRoot().hotbar_mc["cycleHotBar" .. (index) .. "_mc"]
        buttons.visible = false
    end
end

function Hotbar.PositionCombatLogButton()
    local logButton = Hotbar:GetRoot().showLog_mc
    local barAmount = Hotbar.GetBarCount()
    local offset = barAmount > 1 and 0 or -4

    logButton.visible = Settings.GetSettingValue("Epip_Hotbar", "HotbarCombatLogButton") and Hotbar.IsVisible()
    logButton.y = 878 - (barAmount - 1) * 58 + offset -- Likely not worth it performance-wise to use an if-then here.
end

-- Reposition combat log button when the hotbar updates.
Hotbar:RegisterListener("Refreshed", function(_)
    Hotbar.PositionCombatLogButton()
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Position a slot's visuals.
function Hotbar.SetupSlot(index)
    local slot = _SlotElements[index]

    slot.icon_mc.y = 1
    slot.icon_mc.x = 1
    slot.frame_mc.x = -3
    slot.frame_mc.y = -3
    slot.source_frame_mc.x = -3
    slot.source_frame_mc.y = -3
    slot.bg_mc.x = -3
    slot.bg_mc.y = -3
end

Ext.Events.SessionLoaded:Subscribe(function()
    if Client.IsUsingController() then return end
    local ui, root = Hotbar:GetUI(), Hotbar:GetRoot()
    local skillbook = Client.UI.Skills:GetUI()

    -- Adjust UI layers to make additional rows easier to use.
    Client.UI.CharacterSheet:GetUI().Layer = 9
    ui.Layer = 10
    skillbook.Layer = 9

    -- Initialize slots and element cache
    _SlotHolder = root.hotbar_mc.slotholder_mc
    for i=0,Hotbar.MAX_SLOTS-1,1 do
        local slot = _SlotHolder.slot_array[i]
        _SlotElements[i] = slot
        Hotbar.SetupSlot(i)
    end

    Hotbar.PositionElements()

    -- Hide vanilla buttons
    root.hotbar_mc.minusBtn_mc.visible = false
    root.hotbar_mc.plusBtn_mc.visible = false

    Hotbar.CUSTOM_RENDERING = true
    root.useArrays = false

    _SlotHolder.iggy_slots.visible = false
end)

function Hotbar.PositionElements()
    local root = Hotbar:GetRoot()
    local hotbar_mc = root.hotbar_mc

    hotbar_mc.minusBtn_mc.x = 295
    hotbar_mc.minusBtn_mc.y = 83
    hotbar_mc.plusBtn_mc.y = 64
    hotbar_mc.plusBtn_mc.x = 295

    hotbar_mc.lockButton_mc.x = 294
    hotbar_mc.lockButton_mc.y = 100
    hotbar_mc.lockButton_mc.disabled_mc.width = 16
    hotbar_mc.lockButton_mc.disabled_mc.height = 16
    hotbar_mc.minusBtn_mc.bg_mc.stop()

    -- always center the icon on the dragging preview
    local previewButton = hotbar_mc.hotkeys_pip_mc.draggingPreview
    CenterElement(previewButton.icon_mc, previewButton, "y", 32)
    previewButton.text_mc.htmlText = ""

    root.hotbar_mc.hotkeys_pip_mc.dragThreshold = 10

    root.hotbar_mc.drawerBtn_mc.x = 294
    root.hotbar_mc.drawerBtn_mc.y = 2

    if not Hotbar.initialized then return nil end

    -- hide vanilla stuff
    local bottombar = hotbar_mc
    bottombar.btnContainer_mc.visible = false
    bottombar.btnContainer_mc.y = 300 -- no clue what insists on this being rendered
    bottombar.actionsButton_mc.visible = false
    bottombar.chatBtn_mc.visible = false

    -- base frame
    bottombar.pip_baseframe.x = Hotbar.POSITIONING.HOTKEYS.BASEFRAME_POS.X
    bottombar.pip_baseframe.y = Hotbar.POSITIONING.HOTKEYS.BASEFRAME_POS.Y

    bottombar.pip_baseframe2.x = 0
    bottombar.pip_baseframe2.y = 53

    -- apparently this is just a black overlay ???
    bottombar.iconBg_mc.visible = false
end

-----------

---Refreshes the visuals of the UI, as well as hotkeys.
function Hotbar.Refresh()
    if not GameState.IsInSession() or Client.IsUsingController() then
        return
    end

    local slotHolder = Hotbar.GetSlotHolder()
    local char = Client.GetCharacter()

    if not char then return nil end

    -- Hide the +/- buttons on summons. They're unsupported due to savefile bloat.
    local isPlayer = not Game.Character.IsSummon(char)

    Hotbar:GetRoot().hotbar_mc.minusBtn_mc.visible = isPlayer and Hotbar.elementsToggled
    Hotbar:GetRoot().hotbar_mc.plusBtn_mc.visible = isPlayer and Hotbar.elementsToggled

    Hotbar.PositionElements()
    Hotbar.UpdateFrame()
    Hotbar.RenderHotkeys()

    local state = Hotbar.GetState()
    for i,bar in ipairs(state.Bars) do
        -- let flash know which bar holds which row, for correct slot-selection in slotHolder.getSlotOnXY() TODO remove - not used anymore
        slotHolder.rowOrder_array[i - 1] = bar.Row - 1

        if Hotbar.IsBarVisible(i) then
            Hotbar.PositionBar(i, bar.Row)
        else
            Hotbar.HideBar(i, bar.Row)
        end
    end

    Hotbar:FireEvent("Refreshed", Hotbar.GetBarCount())
end

Ext.Events.SessionLoaded:Subscribe(function()
    if Client.IsUsingController() then return end
    local ui, root = Hotbar:GetUI(), Hotbar:GetRoot()

    Hotbar.GetSlotHolder().rowHeight = 65

    -- Hide the original iggy icon.
    root.actionSkillHolder_mc.iggy_actions.visible = false

    -- Setup custom icons for all engine actions.
    for id,entry in pairs(Stats.Actions) do
        ui:SetCustomIcon(id, entry.Icon, 50, 50)
    end

    -- Widen the vanilla keybinds text a bit,
    -- else they will slightly clip into the slot borders (especially on languages with the fallback font).
    -- This is somehow an issue caused by Epip's swf changes.
    local keysHolder = root.hotbar_mc.hotkeys_mc
    for i=1,12,1 do
        local key = "key" .. tostring(i) .. "_mc"
        local element = keysHolder[key]
        if not element._pipPositionAdjusted then
            element.width = Text.FALLBACK_FONT_LANGUAGES[Text.GetCurrentLanguage(false)] and 15 or 14 -- Use higher width for languages with the large fallback font.
            element._pipPositionAdjusted = true -- Mark the element as moved so as to avoid shifting the position further on lua reset.
        end
    end

    Hotbar.initialized = true
end)

-- Update slots after casting skills if the "Disable slots while casting" setting is enabled,
-- as the engine will not trigger an update from this.
Client.Events.SkillStateChanged:Subscribe(function (ev)
    if not ev.State then
        Hotbar.RenderSlots()
    end
end, {EnabledFunctor = function ()
    return Settings.GetSettingValue("Epip_Hotbar", "HotbarCastingGreyOut") == true
end})
