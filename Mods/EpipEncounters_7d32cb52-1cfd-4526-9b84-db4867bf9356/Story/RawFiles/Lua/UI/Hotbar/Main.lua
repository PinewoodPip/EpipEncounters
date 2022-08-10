
---@meta HotbarUI, ContextClient

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
---@field UPDATE_DELAY integer Ticks to wait inbetween each hotbar update.
---@field COOLDOWN_UPDATE_DELAY integer Ticks to wait inbetween each cooldown animation update
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
    tickCounter = 0,
    lastClickedSlot = -1,
    wasVisible = false,
    timer = 0,

    ACTION_BUTTONS_COUNT = 12,
    SKILL_USE_TIME = 3000, -- Kept as a fallback.
    SLOT_SIZE = 50,
    SLOT_SPACING = 8,
    SLOTS_PER_ROW = 29,
    CUSTOM_RENDERING = false,
    SAVE_FILENAME = "Config_PIP_ImprovedHotbar.json",
    UPDATE_DELAY = 8,
    REFRESH_DELAY = 1400,
    COOLDOWN_UPDATE_DELAY = 3,

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

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        BarPlusMinusButtonPressed = {}, ---@type SubscribableEvent<HotbarUI_Event_BarPlusMinusButtonPressed>
    },
    Hooks = {
        IsBarVisible = {}, ---@type SubscribableEvent<HotbarUI_Hook_IsBarVisible>
        CanAddBar = {}, ---@type SubscribableEvent<HotbarUI_Hook_CanAddBar>
        CanRemoveBar = {}, ---@type SubscribableEvent<HotbarUI_Hook_CanRemoveBar>
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/hotBar.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/hotBar.swf",
    },
}
if IS_IMPROVED_HOTBAR then
    Hotbar.FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/hotBar.swf"] = "Public/ImprovedHotbar_53cdc613-9d32-4b1d-adaa-fd97c4cef22c/GUI/hotBar.swf",
    }
end
Client.UI.Hotbar = Hotbar
Epip.InitializeUI(Client.UI.Data.UITypes.hotBar, "Hotbar", Hotbar)
Hotbar:Debug()

for _=1,Hotbar.ACTION_BUTTONS_COUNT,1 do
    table.insert(Hotbar.ActionsState, {
        ActionID = "",
    })
end

---@class HotbarPreparedSkill
---@field SkillID string
---@field StartTime integer
---@field Casting boolean True if the spell is being cast.

---@class SkillBarItem
---@field Type string
---@field ItemHandle userdata
---@field SkillOrStatId string

---@class HotbarState
---@field Bars HotbarBarState[]

---@class HotbarBarState
---@field Row integer
---@field Visible boolean

---@class EclSkill
---@field ActiveCooldown number Cooldown remaining, in seconds.
---@field CanActivate boolean
---@field CauseListSize integer Amount of external sources of this skill currently active (ex. equipped items or statuses)
---@field Handle userdata
---@field HasCooldown boolean
---@field IsActivated boolean Whether the skill is learnt.
---@field IsLearned boolean Whether this skill is memorized.
---@field MaxCharges integer
---@field NetID integer
---@field NumCharges integer
---@field OwnerHandle userdata
---@field SkillId string
---@field Type string Skill archetype.
---@field ZeroMemory boolean

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

---------------------------------------------
-- METHODS
---------------------------------------------

---Get the real active row of the current char - the one the game remembers.
---@return integer
function Hotbar.GetCurrentRealRow()
    return Hotbar:GetRoot().hotbar_mc.cycleHotBar_mc.currentHotBarIndex
end

---Returns the skillbar data of the slot at index.
---@param char? EclCharacter
---@param index integer
---@return SkillBarItem
function Hotbar.GetSlotData(char, index)
    if not char then char = Client.GetCharacter() end
    return char.PlayerData.SkillBarItems[index]
end

---Returns the skill currently being prepared by char.
---@param char EclCharacter?
---@return HotbarPreparedSkill?
function Hotbar.GetPreparedSkill(char)
    char = char or Client.GetCharacter()

    return Hotbar.PreparedSkills[char.NetID]
end

function Hotbar.IsCasting(char)
    local skill = Hotbar.GetPreparedSkill(char)

    return skill and skill.Casting
end

---Toggle visibility of the hotbar.
---@param requestID string
---@param visible boolean
function Hotbar.ToggleVisibility(visible, requestID)
    -- No longer using this as it disables hotkey listeners.
    -- Hotbar:GetRoot().showSkillBar(visible)
    -- hotbar:ToggleElements(visible)

    if not requestID then
        Hotbar:LogError("Must pass a requestID to ToggleVisiblity.")
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
    for request,state in pairs(Hotbar.modulesRequestingHide) do
        if state then
            return false
        end
    end

    return Hotbar.elementsToggled
end

---@param index integer
---@return boolean
function Hotbar.IsBarVisible(index)
    local bar = Hotbar.GetState().Bars[index]
    local event = {BarIndex = index, Visible = bar.Visible} ---@type HotbarUI_Hook_IsBarVisible

    Hotbar.Hooks.IsBarVisible:Throw(event)

    return event.Visible
end

---Returns the slotHolder movieclip.
---@return FlashMovieClip
function Hotbar.GetSlotHolder()
    return Hotbar:GetRoot().hotbar_mc.slotholder_mc
end

---@param char? EclCharacter
---@return HotbarState
function Hotbar.GetState(char)
    char = char or Client.GetCharacter()
    local guid = char.NetID
    local state = Hotbar.State[guid]
    
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
    end

    return state
end

---Set the state of a char's hotbar - its amount of bars, and their rows
---@param char EclCharacter
---@param state HotbarState
function Hotbar.SetState(char, state)
    Hotbar.State[char.NetID] = state

    Hotbar:DebugLog("Set state for " .. char.DisplayName)
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
    local isCasting = Hotbar.IsCasting()
    local canUse = true

    if Client.IsInCombat() then
        if Client.IsActiveCombatant() then
            canUse = Client.GetCharacter().Stats.CurrentAP > 0
        else
            canUse = false
        end
    end

    if isCasting and Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "HotbarCastingGreyOut") then
        canUse = false
    end

    return canUse
end

-- Returns a list of slots of a character's skillbar from a specific row.
---@param row integer
---@return SkillBarItem[]
function Hotbar.GetSkillBarRow(row)
    local skillBar = char.PlayerData.SkillBarItems
    local items = {}

    local startingIndex = (row - 1) * Hotbar.GetSlotsPerRow()
    for i=1,Hotbar.GetSlotsPerRow(),1 do
        local slotIndex = startingIndex + i
        local slot = skillBar[slotIndex]

        table.insert(items, slot)
    end

    return items
end

---Returns the SkillBarItems array of char, optionally filtered by predicate.
---@param char? EclCharacter
---@param predicate? fun(char: EclCharacter, slot: SkillBarItem, index:integer)
---@return table<integer, SkillBarItem>
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
        for i=1,145,1 do
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
        local row = Hotbar.GetRowForSlot(selectedSlot)
        local endSlot = 1 -- Slot to end the search at. Previously we bounded it to the same row; removed as it didn't feel necessary.

        if direction > 0 then
            endSlot = 145
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
        for i,slotIndex in ipairs(slots) do
            slotData[slotIndex] = {
                Type = skillBar[slotIndex].Type,
                SkillOrStatId = skillBar[slotIndex].SkillOrStatId,
                ItemHandle = skillBar[slotIndex].ItemHandle,
            }
        end

        -- Start shifting
        index = selectedSlot
        for i,slotIndex in ipairs(slots) do
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
---@param predicate fun(char: EclCharacter, slot: SkillBarItem)
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

    Utilities.SaveJson(Hotbar.SAVE_FILENAME, save)

    Hotbar:FireEvent("SaveDataSaved")
end

---Loads saved data from the disk: loadouts, hotkey buttons.
function Hotbar.LoadData()
    local save = Utilities.LoadJson(Hotbar.SAVE_FILENAME)

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

    for i,bar in ipairs(state.Bars) do
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

    Hotbar:GetUI():ExternalInterfaceCall("slotPressed", index - 1, isEnabled or true)

    Hotbar.lastClickedSlot = index

    Hotbar.ResyncEngineRow()
end

function Hotbar.UpdateActiveSkill()
    local char = Client.GetCharacter()
    local preparedSkill = Hotbar.GetPreparedSkill(char)
    local slotHolder = Hotbar.GetSlotHolder()
    local index = -1

    if preparedSkill and not preparedSkill.Casting then
        local items = Hotbar.GetSkillBarItems(char, function (char, slot, slotIndex)
            if slot.SkillOrStatId == preparedSkill.SkillID and (index == -1 or slotIndex == Hotbar.lastClickedSlot) then
                index = slotIndex - 1 -- Subtract one because we're sending to flash.
                return true
            end
        end)
    end
    slotHolder.showActiveSkill(index)
end

---Adds an additional bar to char. Bars are added from bottom to top.
---@param char? EclCharacter
function Hotbar.AddBar(char)
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
end

---Removes a bar from char. Bars are removed from top to bottom.
---@param char EclCharacter?
function Hotbar.RemoveBar(char)
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
end

---Cycles a bar's row.
---@param index integer Bar index.
---@param increment -1|1 Direction to cycle.
function Hotbar.CycleBar(index, increment)
    local state = Hotbar.GetState()
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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Hotbar:RegisterInvokeListener("updateActionSkills", function(ev)
    Ext.OnNextTick(Hotbar.UpdateActionHolder)
end, "After")

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_SetLayout", function(_, payload)
    Hotbar.SetState(Ext.GetCharacter(payload.NetID), payload.Layout)
end)

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_SkillUseChanged", function(_, payload)
    Hotbar.SetPreparedSkill(Ext.Entity.GetCharacter(payload.NetID), payload.SkillID, payload.Casting)
end)

-- Reposition combat log button
Hotbar:RegisterListener("Refreshed", function(barAmount)
    Hotbar:GetRoot().showLog_mc.y = 874 - (barAmount - 1) * (50 + 8)
end)

-- Save when the game is saved
Utilities.Hooks.RegisterListener("Saving", "SavingStarted", function()
    Hotbar.SaveData()
end)

-- Save when the game is paused
Utilities.Hooks.RegisterListener("GameState", "GamePaused", function()
    Hotbar.SaveData()

    Net.PostToServer("EPIPENCOUNTERS_Hotbar_SaveLayout", Hotbar.State)
end)

Client.UI.OptionsSettings:RegisterListener("OptionSet", function(data, value)
    if data.ID == "HotbarCombatLogLegacyBehaviour" then
        Hotbar.PositionCombatLogButton()
    end
end)

local function OnRequestUnbind(ui, method, index)
    Hotbar:DebugLog("Unbinding!")

    Hotbar.UnbindActionButton(index + 1)

    Hotbar.RenderHotkeys()
end

local function OnToggleSkillBar(ui, method, bool)
    local root = Hotbar:GetRoot()
    local isSummon = Game.Character.IsSummon(Client.GetCharacter())

    Hotbar.GetHotkeysHolder().visible = bool

    root.hotbar_mc.pip_baseframe.visible = bool
    root.hotbar_mc.plusBtn_mc.visible = bool and not isSummon
    root.hotbar_mc.minusBtn_mc.visible = bool and not isSummon
    root.hotbar_mc.drawerBtn_mc.visible = bool
    root.hotbar_mc.pip_baseframe2.visible = bool

    if not bool then
        root.hotbar_mc.cycleHotBar2_mc.visible = false
        root.hotbar_mc.cycleHotBar3_mc.visible = false
        root.hotbar_mc.cycleHotBar4_mc.visible = false
        root.hotbar_mc.cycleHotBar5_mc.visible = false
    else
        Hotbar.Refresh()
    end

    Hotbar.elementsToggled = bool
end

local function OnSlotHover(ui, method, id)
    local slotHolder = Hotbar.GetSlotHolder()
    local slot = slotHolder.slot_array[id]

    slotHolder.setHighlightedSlot(id)
end

Hotbar:RegisterCallListener("pipAddHotbar", function(_)
    Hotbar.AddBar()

    Hotbar.Events.BarPlusMinusButtonPressed:Throw({IsPlusButton = true})
end)

Hotbar:RegisterCallListener("pipRemoveHotbar", function(_)
    Hotbar.RemoveBar()

    Hotbar.Events.BarPlusMinusButtonPressed:Throw({IsPlusButton = false})
end)

-- Redirect keyboard hotkeys to point to the expected slot.
Hotbar:RegisterCallListener("pipSlotKeyAttempted", function(_, id)
    local state = Hotbar.GetState()
    local firstBarRow = state.Bars[1].Row

    if not Client.Input.AreModifierKeysPressed() then
        id = id + (firstBarRow - 1) * Hotbar.GetSlotsPerRow()

        Hotbar:DebugLog("Used slot from keyboard: " .. id .. " redirected to row " .. firstBarRow)
        
        Hotbar:GetRoot().useSlotFromKey(id)
    end
end)

-- Refresh on reset.
GameState.Events.GameReady:Subscribe(function ()
    Hotbar.initialized = true
    Hotbar.LoadData()
    Hotbar.Refresh()
end)

local function OnSlotPressed(ui, method, id, isEnabled, fromKeyboard)
    Hotbar:DebugLog("Mouse pressed slot " .. id)

    Hotbar.UseSlot(id + 1, isEnabled)
end

local function OnHotkeyRightClick(ui, method)
    Hotbar:DebugLog("Toggling drawer from hotkey")
    Hotbar.ToggleDrawer()
end

Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function (action, _)
    local actionPattern = "EpipEncounters_Hotbar_(%d+)"
    local index = action:match(actionPattern)

    if index then
        Hotbar.PressHotkey(tonumber(index))
    end
end)

local function OnUpdateSlots(ui, method)
    Hotbar.RenderSlots()
end

local function OnStopDragging(ui, method, slot)
    Hotbar:DebugLog("Stopping drag")
    Hotbar.currentDraggedSlot = nil
end

-- Refresh the hotbar every X ticks.
-- Utilities.Hooks.RegisterListener("Game", "Loaded", function()
GameState.Events.RunningTick:Subscribe(function (e)
    if Client.IsUsingController() then return nil end

    -- Refresh the hotbar when it comes into view.
    local visible = Hotbar:IsVisible()
    if visible ~= Hotbar.wasVisible then
        Hotbar.wasVisible = visible

        if visible then
            Timer.Start("", 0.1, function()
                Hotbar.RenderSlots()
            end)
        end
    end

    if Hotbar.initialized then
        if Hotbar.tickCounter % Hotbar.COOLDOWN_UPDATE_DELAY == 0 then
            Hotbar.RenderCooldowns()
        end
        if Hotbar.tickCounter % Hotbar.UPDATE_DELAY == 0 then
            Hotbar.RenderHotkeys()
        end

        Hotbar.timer = Hotbar.timer + e.DeltaTime
        if Hotbar.timer > Hotbar.REFRESH_DELAY then
            Hotbar.RenderSlots()
            Hotbar.timer = 0
        end

        Hotbar.tickCounter = Hotbar.tickCounter + 1

        if Hotbar.tickCounter > math.maxinteger - 10 then
            Hotbar.tickCounter = 0
        end
    end

    -- Failsafe for skill use greyout
    local preparedSkill = Hotbar.GetPreparedSkill()
    if preparedSkill and preparedSkill.Casting then
        if Ext.MonotonicTime() - preparedSkill.StartTime > Hotbar.SKILL_USE_TIME then
            Hotbar.SetPreparedSkill(nil, nil, false)
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
            Hotbar:GetUI():SetCustomIcon("pip_hotkey_" .. (i - 1), icon, 32, 32)

            -- Keybind text
            keyString = Hotbar.GetKeyString(i)

            if keyString and (Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "HotbarHotkeysText") or IS_IMPROVED_HOTBAR) then
                element.text_mc.htmlText = "<font size='14.5' align='center'>" .. keyString .. "</font>" -- TODO
            else
                element.text_mc.htmlText = ""
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

        if hasAction and keyString ~= "" then
            element.icon_mc.y = 4
        else
            CenterElement(element.icon_mc, element, "y", 32)
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

    for i,id in ipairs(Hotbar.RegisteredActionOrder) do
        local data = Hotbar.Actions[id]
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
    local slotHolder = Hotbar.GetSlotHolder()
    local slot = slotHolder.slot_array[index]
    local row = Hotbar.GetRowForSlot(index + 1)

    -- Only update visible slots
    if Hotbar.IsRowVisible(nil, row) then
        -- Icon
        local icon = Hotbar.GetIconForSlot(index)
        if icon then
            Hotbar:GetUI():SetCustomIcon("pip_hotbar_slot_" .. index, icon, 48, 48)
            slot.icon_mc.visible = true
        else
            slot.icon_mc.visible = false
        end

        -- Source frame
        slot.source_frame_mc.visible = Hotbar.ShouldShowSourceFrame(index)
    end
end

function Hotbar.GetIconForSlot(index)
    local bar = Client.GetCharacter().PlayerData.SkillBarItems
    local slot = bar[index + 1]
    local icon

    if slot.Type == "Skill" then
        local stat = Stats.Get("SkillData", slot.SkillOrStatId)

        if stat then
            icon = stat.Icon
        end
    elseif slot.Type == "Item" then
        local item = Ext.GetItem(slot.ItemHandle)

        icon = item.RootTemplate.Icon
    elseif slot.Type == "Action" then
        icon = Data.Game.HOTBAR_ACTIONS[slot.SkillOrStatId]

        if not icon then
            Hotbar:LogError("Unknown hotbar action " .. slot.SkillOrStatId)
        end
    end

    return icon
end

-- TODO remove
function Hotbar.CanRenderExtraSlots()
    if Hotbar.ready or Hotbar.CUSTOM_RENDERING then
        return true
    end

    local players = Client.UI.PlayerInfo:GetRoot().player_array
    local count = 0
    

    for i=0,#players-1,1 do
        local char = Ext.GetCharacter(Ext.UI.DoubleToHandle(players[i].characterHandle))

        count = count + 1
    end

    for netID,row in pairs(Hotbar.CurrentVanillaRows) do
        if row ~= 1 then
            return false
        else
            count = count - 1
        end
    end

    return count == 0 and true
end

function Hotbar.UpdateActionHolder()
    local dualLayout = Hotbar.HasSecondHotkeysRow()
    local actionSkillHolder = Hotbar:GetRoot().actionSkillHolder_mc

    if dualLayout then
        actionSkillHolder.y = 742 - 70
    else
        actionSkillHolder.y = 742
    end
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

    local slotHolder = Hotbar.GetSlotHolder()
    local char = Client.GetCharacter()
    local startingBar = 2
    local canUseHotbar = Hotbar.CanUseHotbar()

    if not Hotbar:GetRoot().useArrays then
        startingBar = 1
    end

    for rowIndex=startingBar,5,1 do
        if Hotbar.IsRowVisible(char, rowIndex) then
            for i=0,Hotbar.GetSlotsPerRow() - 1,1 do
                local slotIndex = (rowIndex - 1) * Hotbar.GetSlotsPerRow() + i
                local slot = slotHolder.slot_array[slotIndex]
                local data = Hotbar.GetSlotData(char, slotIndex + 1)
        
                local cooldown = 0

                if data.Type == "Skill" then
                    ---@type EclSkill
                    local skill = char.SkillManager.Skills[data.SkillOrStatId]
        
                    if skill then
                        cooldown = skill.ActiveCooldown / 6
                    else 
                        -- Hotbar:LogError("Trying to update skill not in skillmanager! " .. data.SkillOrStatId)
                        cooldown = 0
                    end
                end

                -- If this slot was changed away from a skill,
                -- remove the cooldown without playing the finished animation.
                if data.Type ~= "Skill" and slot.oldCD > 0 then
                    cooldown = -1
                end
                
                slot.setCoolDown(cooldown, true) -- Used to be true

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
    local slot = skillBar[145]
    local previousSkill

    if GetExtType(skill) == "ecl::Item" then
        Net.PostToServer("EPIPENCOUNTERS_Hotbar_UseItem", {
            ItemNetID = skill.NetID,
            CharNetID = char.NetID,
        })
    else
        if slot.Type == "Skill" then
            previousSkill = slot.SkillOrStatId
        end
    
        if type(skill) == "string" then
            skillBar[145].SkillOrStatId = skill
            skillBar[145].Type = "Skill"
        else
            skillBar[145].ItemHandle = skill.Handle
            skillBar[145].Type = "Item"
        end
    
        UpdateSlotTextures()
    
        Timer.Start("UseHotbarSlot", 0.05, function()
            Hotbar.UseSlot(145)
    
            -- Rebind the auxiliary slot back to its original skill
            if previousSkill ~= nil then
                Ext.OnNextTick(function()
                    char = Client.GetCharacter()
                    char.PlayerData.SkillBarItems[145].SkillOrStatId = previousSkill
                    -- char.PlayerData.SkillBarItems[145].ItemHandle = nil
                    Hotbar.lastClickedSlot = nil
                    UpdateSlotTextures()
                    Hotbar.Refresh()
                    Hotbar.RenderSlots()
                    Hotbar.UpdateSlot(145)
                end)
    
            else
                Ext.OnNextTick(function()
                    char = Client.GetCharacter()
                    char.PlayerData.SkillBarItems[145].Type = "None"
                    -- char.PlayerData.SkillBarItems[145].ItemHandle = nil
                    Hotbar.lastClickedSlot = nil
                    UpdateSlotTextures()
                    Hotbar.Refresh()
                    Hotbar.RenderSlots()
                    Hotbar.UpdateSlot(145)
                end)
                
            end
        end)
    end
end

---@param char EclCharacter
---@param canUseHotbar boolean
---@param slotIndex integer 1-based.
function Hotbar.RenderSlot(char, canUseHotbar, slotIndex)
    local slotHolder = Hotbar.GetSlotHolder()
    slotIndex = slotIndex - 1 -- SIKE YA THOUGHT!!!!

    local slot = slotHolder.slot_array[slotIndex]
    local data = Hotbar.GetSlotData(char, slotIndex + 1)

    local inUse = true -- Whether the slot holds anything.
    local amount = 0
    local slotType = 0
    local handle = 0
    local tooltip = "" -- TODO is this only for skills?
    local isEnabled = false -- TODO
    local cooldown = 0
    local unavailable = false

    -- types: 0 empty, 1 skill, 2 item
    if data.Type == "Skill" then
        ---@type EclSkill
        local skill = char.SkillManager.Skills[data.SkillOrStatId]
        tooltip = data.SkillOrStatId
        slotType = 1

        if skill then
            cooldown = skill.ActiveCooldown / 6

            handle = Ext.HandleToDouble(skill.OwnerHandle)

            isEnabled = Character.CanUseSkill(char, data.SkillOrStatId)

            if not skill.IsLearned then
                unavailable = true
            end
        else 
            -- Hotbar:LogError("Trying to update skill not in skillmanager! " .. data.SkillOrStatId)
            cooldown = 0
            handle = Ext.HandleToDouble(char.Handle)
            isEnabled = false
            unavailable = Stats.Get("SkillData", data.SkillOrStatId) ~= nil -- Only show warning if the skill exists in the current session
        end
    elseif data.Type == "Item" then
        slotType = 2

        local item = Ext.GetItem(data.ItemHandle)

        handle = Ext.HandleToDouble(item.Handle)
        amount = item.Amount
        isEnabled = Item.CanUse(char, item)
    elseif data.Type == "Action" then
        isEnabled = true
        slotType = 1
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
    
    -- print(slotIndex, tooltip, isEnabled, inUse, handle, slotType, amount)

    -- slot.unavailable_mc.visible = false -- Leftover from DOS1. (SetSlotPreviewEnabledMC)

    -- We no longer rely on this as it fucks with the cooldown values. Apparently the original code is optimized enough to only update this when needed.
    -- slotHolder.setSlot(slotIndex, tooltip, isEnabled and cooldown <= 0, handle, slotType, amount)
end

function Hotbar.RenderSlots()
    local char = Client.GetCharacter()

    if not Hotbar.CUSTOM_RENDERING or not char then return nil end

    local slotHolder = Hotbar.GetSlotHolder()
    local startingBar = 2
    local canUseHotbar = Hotbar.CanUseHotbar()

    Hotbar.UpdateActiveSkill()

    if not canUseHotbar or not Hotbar:GetRoot().useArrays then
        startingBar = 1
    end

    for rowIndex=startingBar,5,1 do
        if Hotbar.IsRowVisible(char, rowIndex) then
            for i=0,Hotbar.GetSlotsPerRow() - 1,1 do
                local slotIndex = (rowIndex - 1) * Hotbar.GetSlotsPerRow() + i
                local success, msg = pcall(Hotbar.RenderSlot, char, canUseHotbar, slotIndex + 1)
                
                if not success then
                    local data = Hotbar.GetSkillBarItems(char)[slotIndex + 1]

                    Hotbar:LogError("Error rendering slot " .. (slotIndex + 1))
                    Hotbar:LogError(msg)
                    Hotbar:LogError(string.format("Slot data: type %s skillID %s", data.Type, data.SkillOrStatId))
                end
            end
        end
    end
end

function Hotbar.PositionBar(index, row)
    local slotHolder = Hotbar.GetSlotHolder()
    
    -- Position cyclers
    if index > 1 then
        local buttons = Hotbar:GetRoot().hotbar_mc["cycleHotBar" .. (index) .. "_mc"]

        buttons.barIndex = index
        buttons.x = hotbar.POSITIONING.CYCLERS.X
        buttons.y = (index - 2) * hotbar.POSITIONING.CYCLERS.Y
        buttons.visible = Hotbar.elementsToggled
        buttons.text_txt.htmlText = tostring(row)
        buttons.text_txt.align = "center"
        buttons.text_txt.autoSize = "center"
        buttons.text_txt.mouseEnabled = false
    else
        local buttons = Hotbar:GetRoot().hotbar_mc.cycleHotBar_mc
        buttons.text_txt.htmlText = tostring(row)
        buttons.x = hotbar.POSITIONING.CYCLERS.X
    end

    local SLOTSIZE = Hotbar.SLOT_SIZE
    local SLOTSPACING = Hotbar.SLOT_SPACING

    -- Position slots
    for i=0,Hotbar.GetSlotsPerRow()-1,1 do
        local slotIndex = ((row - 1) * Hotbar.GetSlotsPerRow()) + i
        local slot = slotHolder.slot_array[slotIndex]

        slot.x = (i * SLOTSIZE) + (i * SLOTSPACING) + 1

        slot.y = (-(SLOTSIZE + SLOTSPACING * 2) + 7) * (index - 1)
        slot.y = slot.y + (index - 2)

        Hotbar.UpdateSlot(slotIndex)
    end
end

function Hotbar.HideBar(index, row)
    local slotHolder = Hotbar.GetSlotHolder()

    -- Hide slots
    for i=0,Hotbar.GetSlotsPerRow()-1,1 do
        local slotIndex = ((row - 1) * Hotbar.GetSlotsPerRow()) + i
        local slot = slotHolder.slot_array[slotIndex]

        slot.y = 500
    end

    if index > 1 then
        local buttons = Hotbar:GetRoot().hotbar_mc["cycleHotBar" .. (index) .. "_mc"]
        buttons.visible = false
    end
end

function Hotbar.PositionCombatLogButton()
    Hotbar:GetRoot().showLog_mc.visible = (Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "HotbarCombatLogButton") or IS_IMPROVED_HOTBAR) and Hotbar.IsVisible()
end

Hotbar:RegisterListener("Refreshed", function(barCount)
    Hotbar.PositionCombatLogButton()
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Position a slot's visuals.
function Hotbar.SetupSlot(index)
    local slotHolder = Hotbar.GetSlotHolder()
    local slot = slotHolder.slot_array[index]

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
    local ui = Hotbar:GetUI()
    local skillbook = Ext.UI.GetByPath("Public/Game/GUI/skills.swf")

    Client.UI.CharacterSheet:GetUI().Layer = 9
    ui.Layer = 10
    skillbook.Layer = 9

    Ext.RegisterUICall(ui, "startDragging", function(ui, method, slot)
        Hotbar:DebugLog("Now dragging slot " .. slot)
        local slotData = Client.GetCharacter().PlayerData.SkillBarItems[slot + 1]
        Hotbar.currentDraggedSlot = {
            ItemHandle = slotData.ItemHandle,
            SkillOrStatId = slotData.SkillOrStatId,
            Type = slotData.Type,
        }
    end)

    -- Clear the dragged slot data when we drag out of bounds
    Ext.Events.InputEvent:Subscribe(function(ev)
        ev = ev.Event
        if (ev.EventId == 1 or ev.EventId == 4) and ev.Release then
            Hotbar.currentDraggedSlot = nil
        end
    end)

    Ext.RegisterUICall(ui, "pipStoppedDragOnButton", function(ui, method, index)
        if Hotbar.currentDraggedSlot then
            Hotbar:DebugLog("Assigning slot to hotkey button!" .. index)
            _D(Hotbar.currentDraggedSlot)
            Hotbar:FireEvent("SlotDraggedToHotkeyButton", index + 1, Hotbar.currentDraggedSlot)
            Hotbar.currentDraggedSlot = nil
            Client.Input._SetFocused(false)
        end
    end)

    Ext.RegisterUICall(ui, "stopDragging", OnStopDragging, "After")
    Ext.RegisterUICall(ui, "cancelDragging", OnStopDragging, "After")
    Ext.RegisterUICall(ui, "pipPrevHotbar", OnHotbarCyclePrev)
    Ext.RegisterUICall(ui, "pipNextHotbar", OnHotbarCycleNext)
    Ext.RegisterUICall(ui, "pipUpdateSlots", OnVanillaUpdateSlots)
    Ext.RegisterUIInvokeListener(ui, "updateSlots", OnUpdateSlots, "After")
    -- Ext.RegisterUIInvokeListener(ui, "updateSlotData", OnUpdateSlotData, "After")
    Ext.RegisterUICall(ui, "pipHotbarOpenContextMenu", OnHotkeyRightClick)
    Ext.RegisterUICall(ui, "pipUnbindHotbarButton", OnRequestUnbind)
    Ext.RegisterUICall(ui, "pipSlotPressed", OnSlotPressed)
    Ext.RegisterUICall(ui, "SlotHover", OnSlotHover)
    Ext.RegisterUIInvokeListener(ui, "showSkillBar", OnToggleSkillBar, "After")

    for i=0,144,1 do
        Hotbar.SetupSlot(i)
    end

    Hotbar.PositionElements()

    -- Hide vanilla buttons
    Hotbar:GetRoot().hotbar_mc.minusBtn_mc.visible = false
    Hotbar:GetRoot().hotbar_mc.plusBtn_mc.visible = false

    Hotbar.CUSTOM_RENDERING = true
    Hotbar:GetRoot().useArrays = false

    local slotHolder = Hotbar.GetSlotHolder()

    slotHolder.iggy_slots.visible = false
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
    bottombar.pip_baseframe.x = hotbar.POSITIONING.HOTKEYS.BASEFRAME_POS.X
    bottombar.pip_baseframe.y = hotbar.POSITIONING.HOTKEYS.BASEFRAME_POS.Y

    bottombar.pip_baseframe2.x = 0
    bottombar.pip_baseframe2.y = 53

    -- apparently this is just a black overlay ???
    bottombar.iconBg_mc.visible = false
end

-----------

function Hotbar.Refresh()
    if Ext.Client.GetGameState() ~= "Running" then
        return nil
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

hotbar = {
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
            }
        }
    }
}
setmetatable(hotbar, {__index = Client.UI._BaseUITable})

function UpdateSlotTextures()
    if Hotbar.CanRenderExtraSlots() then
        Hotbar:GetUI():ExternalInterfaceCall("updateSlots", Hotbar.GetSlotsPerRow())
        -- Ext.UI.SetDirty(Client.GetCharacter().Handle, 524288)
        -- Ext.UI.SetDirty(Client.GetCharacter().Handle, 2)
    else
        Hotbar:GetUI():ExternalInterfaceCall("updateSlots", Hotbar.GetSlotsPerRow())
    end
end

function OnHotbarSetHandle(uiObj, methodName, handle)
    UpdateSlotTextures()

    Utilities.Hooks.FireEvent("Client", "ActiveCharacterChanged", handle)

    Hotbar.ResyncEngineRow()
end

-- handle switching hotbars the normal way (buttons and hotkeys)
function CycleHotbar(ui, current, index, increment)
    -- Use modifier keys to select higher hotbars
    -- Yes this is slightly ridiculous
    if Client.Input.IsGUIPressed() then -- Cycle 5th bar
        index = index + 4
    elseif Client.Input.IsAltPressed() then -- Cycle 4th bar
        index = index + 3
    elseif Client.Input.IsCtrlPressed() then -- Cycle 3rd bar
        index = index + 2
    elseif Client.Input.IsShiftPressed() then -- Cycle 2nd bar
        index = index + 1
    end

    Hotbar:DebugLog("Trying to cycle " .. index)

    UpdateSlotTextures()
    Hotbar.CycleBar(index, increment) -- cycle our own scripted bars
end

function OnHotbarCyclePrev(ui, method, current, index)
    CycleHotbar(ui, current, index, -1)
end

function OnHotbarCycleNext(ui, method, current, index)
    CycleHotbar(ui, current, index, 1)
end

-- Fired from onEventResolution
function OnVanillaUpdateSlots(ui, method, slots)
    UpdateSlotTextures()
end

function handleUpdateSlots(uiObj, methodName, param3, slotsAmount)
    Hotbar.Refresh()
end

Ext.Events.SessionLoaded:Subscribe(function()
    Hotbar.GetSlotHolder().rowHeight = 65

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.hotBar, "setPlayerHandle", OnHotbarSetHandle, "After")
    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.hotBar, "updateSlots", handleUpdateSlots, "Before")

    Hotbar.initialized = true
end)