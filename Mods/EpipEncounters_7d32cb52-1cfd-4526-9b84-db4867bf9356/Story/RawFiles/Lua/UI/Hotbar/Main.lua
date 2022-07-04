
---@meta HotbarUI, ContextClient

---@class HotbarUI
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

    ACTION_BUTTONS_COUNT = 12,
    SKILL_USE_TIME = 3000, -- Kept as a fallback.
    SLOT_SIZE = 50,
    SLOT_SPACING = 8,
    SLOTS_PER_ROW = 29,
    CUSTOM_RENDERING = false,
    SAVE_FILENAME = "Config_PIP_ImprovedHotbar.json",
    UPDATE_DELAY = 8,
    COOLDOWN_UPDATE_DELAY = 3,
    DEFAULT_ACTION_PROPERTIES = {
        IsActionVisibleInDrawer = true,
        IsActionEnabled = true,
        IsActionHighlighted = false,
    },

    FILEPATH_OVERRIDES = {
        -- ["Public/Game/GUI/hotBar.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/hotBar.swf",
        ["Public/Game/GUI/hotBar.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/hotBar.swf",
    },
}
if Epip.IS_IMPROVED_HOTBAR then
    Hotbar.FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/hotBar.swf"] = "Public/ImprovedHotbar_53cdc613-9d32-4b1d-adaa-fd97c4cef22c/GUI/hotBar.swf",
    }
end
Client.UI.Hotbar = Hotbar
Epip.InitializeUI(Client.UI.Data.UITypes.hotBar, "Hotbar", Hotbar)
Hotbar:Debug()

for i=1,Hotbar.ACTION_BUTTONS_COUNT,1 do
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

---@class HotbarLoadout
---@field Slots HotbarLoadoutSlot[]

---@class HotbarLoadoutSlot
---@field Type string
---@field ElementID string The skill, action or template ID.

---@class HotbarAction
---@field ID string Set automatically by RegisterAction()
---@field Name string
---@field Icon string
---@field Type? string Intended for use in events, to render groups of actions in a certain way.
---@field InputEventID? integer The vanilla input event for this action. If set, the keybind for it will be shown, rather than the keybind for the action button.
---@field VisibleInDrawer? boolean

---@class HotbarState
---@field Bars HotbarBarState[]

---@class HotbarBarState
---@field Row integer
---@field Visible boolean

---@class HotbarActionState
---@field ActionID string The action bound to this hotkey button.

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

---Unbinds a hotkey button by index.
---@param index integer
function Hotbar.UnbindActionButton(index)
    if index < 1 or index > Hotbar.ACTION_BUTTONS_COUNT then 
        Hotbar:LogError("Invalid index to UnbindActionButton(); must be between 1 and 12 inclusive.")
        return nil
    end

    local hotkeys = Hotbar.GetHotkeysHolder()
    local button = hotkeys.hotkeyButtons[index - 1]
    
    Hotbar.ActionsState[index].ActionID = ""
    button.setAction("")
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
            return bar.Visible
        end
    end

    return false
end

---Returns whether the hotbar is currently usable.
---The hotbar is unusable in combat if it is not the client char's turn, or while they are casting a skill.
---@return boolean
function Hotbar.CanUseHotbar()
    return (((not Client.IsInCombat() or (Client.IsActiveCombatant() and Client.GetCharacter().Stats.CurrentAP)))) and not Hotbar.IsCasting()
end

---Save a row loadout.
---@param row integer
---@param name string Name of the loadout. Saving under an existing name overrides the loadout.
function Hotbar.SaveLoadout(row, name)
    local skillBar = Client.GetCharacter().PlayerData.SkillBarItems
    ---@type HotbarLoadout
    local loadout = {
        Slots = {}
    }

    local startingIndex = (row - 1) * Hotbar.GetSlotsPerRow()
    for i=1,Hotbar.GetSlotsPerRow(),1 do
        local slotIndex = startingIndex + i
        local slot = skillBar[slotIndex]

        ---@type HotbarLoadoutSlot
        local data = {
            Type = "None",
            ElementID = "",
        }

        if slot.Type ~= "Item" then
            table.insert(loadout.Slots, {
                Type = slot.Type,
                ElementID = slot.SkillOrStatId,
            })
        end
    end

    Hotbar.Loadouts[name] = loadout

    Hotbar.SaveData()
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

---Apply a saved loadout to a row.
---@param char EclCharacter
---@param loadout string Loadout ID.
---@param row integer
---@param replaceUsedSlots boolean If false, only empty slots will be filled.
function Hotbar.ApplyLoadout(char, loadout, row, replaceUsedSlots)
    local data = Hotbar.Loadouts[loadout]

    if data then
        local skillBar = char.PlayerData.SkillBarItems

        local startingIndex = (row - 1) * Hotbar.GetSlotsPerRow()
        for i=1,Hotbar.GetSlotsPerRow(),1 do
            local slotIndex = startingIndex + i
            local slot = skillBar[slotIndex]

            local savedSlot = data.Slots[i]

            if savedSlot and (replaceUsedSlots or slot.Type == "None") then
                slot.Type = savedSlot.Type
                slot.SkillOrStatId = savedSlot.ElementID
            end
        end

        Hotbar:DebugLog("Applied loadout: " .. loadout .. ", on row " .. row)
        UpdateSlotTextures()
    else
        Hotbar:LogError("Loadout does not exist: " .. loadout)
    end
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
        end

        
        Hotbar:FireEvent("SaveDataLoaded", save)
    end
end

---Register an action for the hotkeys area and action drawer.
---@param id string
---@param data HotbarAction
function Hotbar.RegisterAction(id, data)
    if Hotbar.Actions[id] ~= nil then
        Hotbar:LogError("Action already registered: " .. id)
    else
        data.Type = data.Type or "Normal"
        data.ID = id or data.ID

        Hotbar.Actions[id] = data

        table.insert(Hotbar.RegisteredActionOrder, id)

        Hotbar:FireEvent("ActionRegistered", data) -- TODO refresh drawer if this happens while it's open
    end
end

---Get the icon for an action.
---@param id string Action ID.
---@return icon string Defaults to "unknown".
function Hotbar.GetActionIcon(id)
    local icon = "unknown"
    local data = Hotbar.Actions[id]

    if data then
        icon = Hotbar:ReturnFromHooks("GetActionIcon_" .. id, data.Icon, data)
        icon = Hotbar:ReturnFromHooks("GetActionIcon", icon, id, data)
    end

    return icon
end

---Gets the string display for an action button's keybinding.
---@param index integer Index of the action hotkey button.
---@param shortName boolean? Whether to use short names. Defaults to true.
---@return string Empty if the button is unbound.
function Hotbar.GetKeyString(index, shortName)
    if shortName == nil then shortName = true end
    local state = Hotbar.ActionsState[index]
    local key = ""

    if state.ActionID ~= "" then
        local actionData = Hotbar.Actions[state.ActionID]
        local inputEvent = nil

        -- Manually-defined inputevent takes priority
        if actionData.InputEventID then
            inputEvent = actionData.InputEventID
            key = OptionsMenu:GetKey(inputEvent, true)
        else -- Use the hotbar keybinds
            local bindableAction = Client.UI.OptionsInput.GetKeybinds("EpipEncounters_Hotbar_" .. RemoveTrailingZeros(index))

            if bindableAction then
                if bindableAction.Input1 then
                    if shortName then
                        key = bindableAction:GetShortInputString(1)
                    else
                        key = bindableAction.Input1
                    end
                else
                    if shortName then
                        key = bindableAction:GetShortInputString(2)
                    else
                        key = bindableAction.Input2
                    end
                end
            end
        end

    end

    return key or ""
end

---@param index integer
---@return boolean
function Hotbar.HasBoundAction(index)
    return Hotbar.ActionsState[index].ActionID ~= "" and Hotbar.ActionsState[index].ActionID ~= nil
end

---@param action string
---@return integer
function Hotbar.GetHotkeyIndex(action)
    local state = Hotbar.ActionsState
    local index

    for i,state in ipairs(state) do
        if state.ActionID == action then
            index = i
            break
        end
    end

    return index
end

---Use a hotbar action. Ignores whether the action is enabled!
---@param id string
function Hotbar.UseAction(id, buttonIndex)
    local actionData = Hotbar.Actions[id]
    local char = Client.GetCharacter()

    if actionData then
        Hotbar:DebugLog("Action used: " .. id)
        Hotbar:FireEvent("ActionUsed", id, char, actionData, buttonIndex)
        Hotbar:FireEvent("ActionUsed_" .. id, char, actionData, buttonIndex)
    else
        Hotbar:LogError("Tried to use an action that is not registered: " .. id)
    end
end

---Register a listener for a specific action.
---@param action string Action ID.
---@param event string Event ID.
---@param handler function
function Hotbar.RegisterActionListener(action, event, handler)
    Hotbar:RegisterListener(event .. "_" .. action, handler)
end

---Register a hook for a specific action.
---@param action string Action ID.
---@param event string Hook event ID.
---@param handler function
function Hotbar.RegisterActionHook(action, event, handler)
    Hotbar:RegisterHook(event .. "_" .. action, handler)
end

---Returns whether an action is enabled (usable, not greyed out)
---@param id string Action ID.
---@vararg Additional arguments passed to the hooks.
---@return boolean Defaults to true.
function Hotbar.IsActionEnabled(id, ...)
    local actionData = Hotbar.Actions[id]

    if actionData then
        local enabled = Hotbar:ReturnFromHooks("IsActionEnabled_" .. actionData.ID, true, Client.GetCharacter(), actionData, ...)
        enabled = Hotbar:ReturnFromHooks("IsActionEnabled", enabled, actionData.ID, Client.GetCharacter(), actionData, ...) -- Generic listeners go last!

        return enabled
    else
        return false
    end
end

---Returns whether an action should show up in the drawer.
---@param id string Action ID.
---@return boolean Defaults to true.
function Hotbar.IsActionVisibleInDrawer(id)
    local actionData = Hotbar.Actions[id]

    if actionData then
        local visible = Hotbar:ReturnFromHooks("IsActionVisibleInDrawer_" .. actionData.ID, true, Client.GetCharacter(), actionData)
        visible = Hotbar:ReturnFromHooks("IsActionVisibleInDrawer", visible, actionData.ID, Client.GetCharacter(), actionData) -- Generic listeners go last!

        return visible
    else
        return false
    end
end

-- Shorthand property on ActionData for IsActionVisibleInDrawer().
Hotbar:RegisterHook("IsActionVisibleInDrawer", function(visible, actionID, char, actionData)
    if visible and actionData.VisibleInDrawer == false then
        visible = false
    end
    return visible
end)

---Returns a property from an action's data through hooks.
---@param id string Action ID.
---@param prop string Hook event ot call.
---@param defaultValue any
---@return any
function Hotbar.GetActionProperty(id, prop, defaultValue, ...)
    local actionData = Hotbar.Actions[id]
    local defaultValue = defaultValue or Hotbar.DEFAULT_ACTION_PROPERTIES[prop]

    if actionData and defaultValue ~= nil then
        local value = Hotbar:ReturnFromHooks(prop .. "_" .. actionData.ID, defaultValue, Client.GetCharacter(), actionData, ...)
        value = Hotbar:ReturnFromHooks(prop, value, actionData.ID, Client.GetCharacter(), actionData, ...) -- Generic listeners go last!

        return value
    else
        return defaultValue
    end
end

---Returns whether an action is "active" (highlighted in action buttons)
---@param id string Action ID.
---@return boolean Defaults to false.
function Hotbar.IsActionHighlighted(id)
    return Hotbar.GetActionProperty(id, "IsActionHighlighted")
end

---Returns the icon for an action.
---@param id string Action ID.
---@return string Defaults to "unknown"
function Hotbar.GetActionIcon(id, ...)
    local data = Hotbar.Actions[id]

    if data then
        return Hotbar.GetActionProperty(id, "GetActionIcon", data.Icon, ...)
    else
        return "unknown"
    end
end

---Returns the name for an action.
---@param id string Action ID.
---@vararg Additional params passed to hooks.
---@return string Defaults to "Unknown"
function Hotbar.GetActionName(id, ...)
    local data = Hotbar.Actions[id]

    if data then
        return Hotbar.GetActionProperty(id, "GetActionName", data.Name, ...)
    else
        return "Unknown"
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
        if bar.Visible then
            open = open + 1
        end
    end

    return open
end

---Returns whether the hotbar currently shows a second row of action buttons.
---@return boolean
function Hotbar.HasSecondHotkeysRow()
    local dualLayout = false
    local setting = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "HotbarHotkeysLayout")

    -- Force dual-row layout
    if setting == 3 then
        dualLayout = true
    -- Otherwise, if the setting does not force single-row, use dual for 2+ bars
    elseif Hotbar.GetBarCount() > 1 and setting ~= 2 then
        dualLayout = true
    end

    return dualLayout
end

---Uses a slot from the hotbar UI.
---@param index integer Slot to use.
---@param isEnabled boolean Passed to the ExternalInterfaceCall. Purpose unknown.
function Hotbar.UseSlot(index, isEnabled)
    Hotbar:DebugLog("Pressed slot: " .. index)
    local slot = Hotbar.GetSlotHolder().slot_array[index - 1]

    Hotbar:GetUI():ExternalInterfaceCall("slotPressed", index - 1, isEnabled or true)

    -- if slot.isEnabled and slot.inUse then
    --     local slotHolder = Hotbar.GetSlotHolder()
    --     if Hotbar.GetSkillBarItems()[index].Type == "Skill" then
    --         slotHolder.showActiveSkill(index - 1)
    --     else
    --         slotHolder.showActiveSkill(-1)
    --     end
    -- end
end

function Hotbar.UpdateActiveSkill()
    local char = Client.GetCharacter()
    local preparedSkill = Hotbar.GetPreparedSkill(char)
    local slotHolder = Hotbar.GetSlotHolder()
    local index = -1

    print(preparedSkill)
    if preparedSkill and not preparedSkill.Casting then
        local items = Hotbar.GetSkillBarItems(char, function (char, slot, slotIndex)
            if slot.SkillOrStatId == preparedSkill.SkillID then
                index = slotIndex - 1 -- Subtract one because we're sending to flash.
                return true
            end
        end)
        print(index)
    end
    slotHolder.showActiveSkill(index)
end

---Sets the action for a hotkey button.
---@param index integer Index of the hotkey button to set.
---@param action string Action ID.
function Hotbar.SetHotkeyAction(index, action)
    if index >= 1 and index <= 12 then
        Hotbar.ActionsState[index] = {
            ActionID = action
        }

        Hotbar:FireEvent("ActionHotkeySet", index, action) -- TODO refresh
    else
        Hotbar:LogError("Invalid index for SetHotkeyAction: " .. tostring(index))
    end
end

---Activates an action from a hotkey.
---@param index integer Index of the hotkey button.
---@return boolean #Whether the action was executed.
function Hotbar.PressHotkey(index) -- TODO distinguish mouse/kb
    local hotkeyState = Hotbar.ActionsState[index]
    local usedAction = false

    if Hotbar.HasBoundAction(index) and Client.Input.IsAcceptingInput() then
        local enabled = Hotbar.IsActionEnabled(hotkeyState.ActionID, index)

        if enabled then
            usedAction = true
            Hotbar.UseAction(hotkeyState.ActionID, index)
        end
    end

    return usedAction
end

---Adds an additional bar to char. Bars are added from bottom to top.
---@param char? EclCharacter
function Hotbar.AddBar(char)
    local count = Hotbar.GetBarCount(char)
    local state = Hotbar.GetState(char)

    if count < 5 then
        state.Bars[count + 1].Visible = true -- TODO rows update

        -- TODO update activeSkill highlight
    end

    if Hotbar.IsDrawerOpen() then
        Hotbar.PositionDrawer()
    end

    Hotbar.Refresh()
    Hotbar.RenderSlots()
end

---Returns whether the actions drawer is open.
---@return boolean
function Hotbar.IsDrawerOpen()
    return Hotbar.GetHotkeysHolder().drawer_mc.visible
end

---Removes a bar from char. Bars are removed from top to bottom.
---@param char EclCharacter
function Hotbar.RemoveBar(char)
    local count = Hotbar.GetBarCount(char)
    local state = Hotbar.GetState(char)

    -- Can't remove the first bar!
    if count > 1 then
        state.Bars[count].Visible = false

        -- Update activeSkill highlight
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
---@param increment integer Direction to cycle: 1 or -1.
function Hotbar.CycleBar(index, increment)
    local state = Hotbar.GetState()

    local bar = state.Bars[index]

    local currentRowIndex = bar.Row
    local nextRowIndex = currentRowIndex + increment

    -- Loop
    if nextRowIndex < 1 then nextRowIndex = 5 end
    if nextRowIndex > 5 then nextRowIndex = 1 end

    local nextBar = nil

    for i,bar in ipairs(state.Bars) do
        if bar.Row == nextRowIndex then
            nextBar = bar
        end
    end

    if nextBar ~= nil then -- attempt to swap rows
        nextBar.Row = currentRowIndex
    end
    
    bar.Row = nextRowIndex

    Hotbar:DebugLog("Cycled bar " .. index)
end

---Returns whether the hotbar is locked.
---@return boolean
function Hotbar.IsLocked()
    return Hotbar:GetRoot().hotbar_mc.lockButton_mc.bIsLocked and not Hotbar:GetRoot().inSkillPane
end

---Toggles the action drawer.
---@param state boolean True for open.
function Hotbar.ToggleDrawer(state)
    local hotkeys = Hotbar.GetHotkeysHolder()

    if state == nil then
        state = not hotkeys.drawer_mc.visible
    end

    hotkeys.toggleDrawer(state)
end

---Returns the data for an action.
---@param id string Action ID.
---@return HotbarAction
function Hotbar.GetActionData(id)
    if id then
        return Hotbar.Actions[id]
    end
end

---Returns the actions bound to the hotkey buttons.
---@return HotbarActionState[]
function Hotbar.GetActionButtons()
    local btns = {}
    for i=1,Hotbar.ACTION_BUTTONS_COUNT,1 do
        table.insert(btns, Hotbar.ActionsState[i] or {
            ActionID = "",
        })
    end

    return btns
end

---Returns the maximum amount of slots per hotbar row.
function Hotbar.GetSlotsPerRow()
    local slots = Hotbar.SLOTS_PER_ROW

    -- if Epip.IsAprilFools() then
    --     slots = (slots) / (math.max(Hotbar.GetBarCount(), 5) / 5)
    --     slots = math.floor(slots)
    -- end

    return slots
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Game.Net.RegisterListener("EPIPENCOUNTERS_Hotbar_SetLayout", function(cmd, payload)
    Hotbar.SetState(Ext.GetCharacter(payload.NetID), payload.Layout)
end)

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

Game.Net.RegisterListener("EPIPENCOUNTERS_Hotbar_SkillUseChanged", function(cmd, payload)
    Hotbar.SetPreparedSkill(Ext.Entity.GetCharacter(payload.NetID), payload.SkillID, payload.Casting)
end)

-- TODO figure something out for items? Listen for item use?
-- Hotbar:RegisterListener("SkillUseChanged", function(skill)
--     if Hotbar.CUSTOM_RENDERING then
--         if skill then
--             local slots = Hotbar.GetSkillBarItems(Client.GetCharacter(), function(char, slot)
--                 return slot.SkillOrStatId == skill
--             end)
--             local index
--             local slot
    
--             -- Pick first valid slot.
--             for i,data in pairs(slots) do
--                 index = i
--                 slot = data
--                 break
--             end

--             if index then
--                 local skill = Client.GetCharacter().SkillManager.Skills[slot.SkillOrStatId]
--                 canHighlight = skill.ActiveCooldown <= 0
--                 Hotbar:GetRoot().showActiveSkill(index - 1)
--             end
--         else
--             Hotbar:GetRoot().showActiveSkill(-1)
--         end
--     end
-- end)

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

    Game.Net.PostToServer("EPIPENCOUNTERS_Hotbar_SaveLayout", Hotbar.State)
end)

local function OnRearrangeStart(ui, method, index, action)
    Hotbar:DebugLog("Now dragging " .. action .. " from index " .. index)

    if action ~= "" and not Hotbar.IsLocked() then 
        local draggingPreview = Hotbar.GetHotkeysHolder().draggingPreview
        local actionData = Hotbar.GetActionData(action)

        draggingPreview.index = index
        draggingPreview.visible = true
        draggingPreview.icon_mc.name = "iggy_pip_hotbar_preview"
        draggingPreview.action = action
        draggingPreview.setHighlighted(false)

        Hotbar:GetUI():SetCustomIcon("pip_hotbar_preview", Hotbar.GetActionIcon(action), 32, 32)
    end
end

local function OnRearrangeStop(ui, method, index)
    index = index + 1
    Hotbar:DebugLog("Stopped dragging on " .. index)
    
    if not Hotbar.IsLocked() then 
        local draggingPreview = Hotbar.GetHotkeysHolder().draggingPreview
        local previousIndex = draggingPreview.index + 1

        draggingPreview.visible = false
        draggingPreview.text_mc.htmlText = ""

        -- Do nothing if button was dragged out of bounds
        if index > 0 then
            local hotkeys = Hotbar.GetHotkeysHolder()
            local finalButton = hotkeys.hotkeyButtons[index]

            local previousAction = Hotbar.ActionsState[index].ActionID -- Action that was on new button

            Hotbar:FireEvent("ActionsSwapped", {
                Index = previousIndex,
                Action = draggingPreview.action,
            }, {
                Index = index,
                Action = previousAction,
            })

            Hotbar.SetHotkeyAction(index, draggingPreview.action)
            Hotbar.SetHotkeyAction(previousIndex, previousAction)
        end

        -- Hide tooltip; otherwise if you keep the cursor on the button you've just dragged an action onto, it shows the old one
        Hotbar:GetUI():ExternalInterfaceCall("hideTooltip")
        Hotbar.ToggleDrawer(false)
    end

    Hotbar.RenderHotkeys()
end

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

local function OnHotkey(ui, method, action, index)
    Hotbar:DebugLog("Using action from hotkey button: " .. action)

    if index then
        index = index + 1
    end

    if Hotbar.IsActionEnabled(action, index) then
        Hotbar.UseAction(action, index)
    end
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

local function OnDrawerToggle(ui, method, open)
    local hotkeys = Hotbar.GetHotkeysHolder()

    if open then
        local buttonWidth = 181

        hotkeys.drawer_mc.x = 70
        hotkeys.drawer_mc.setFrame(buttonWidth, 400)
        Hotbar:GetRoot().hotbar_mc.hotkeys_pip_mc.drawer_mc.clearElements()
        hotkeys.drawer_mc.m_scrollbar_mc.x = buttonWidth - 3

        Hotbar.RenderDrawerButtons()
        Hotbar.PositionDrawer()
    else
        Hotbar:GetRoot().hotbar_mc.hotkeys_pip_mc.drawer_mc.clearElements()
    end
end

local function OnAddHotbar(ui, method)
    Hotbar.AddBar()
end

local function OnRemoveHotbar(ui, method)
    Hotbar.RemoveBar()
end

-- Redirect keyboard hotkeys to point to the expected slot.
local function OnSlotKeyPressed(ui, method, id)
    local state = Hotbar.GetState()
    local firstBarRow = state.Bars[1].Row

    id = id + (firstBarRow - 1) * Hotbar.GetSlotsPerRow()

    Hotbar:DebugLog("Used slot from keyboard: " .. id .. " redirected to row " .. firstBarRow)
    Hotbar:GetRoot().useSlotFromKey(id)
end

-- Refresh on reset.
-- Used to be Game Loaded, but that one has been borked forever apparently.
-- Utilities.Hooks.RegisterListener("Game", "Loaded", function()
Utilities.Hooks.RegisterListener("GameState", "ClientReady", function()
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

local function OnSlotRightClicked(ui, method, index)
    index = index + 1

    local ui = Hotbar:GetUI()
    local root = ui:GetRoot()

    -- We don't pull up the context menu if a skill is being cast.
    if not Hotbar.GetSlotHolder().activeSkill_mc.visible then
        Hotbar:DebugLog("Opening context menu for slots")

        Hotbar.contextMenuSlot = index

        Hotbar.currentLoadoutRow = math.floor((index - 1) / Hotbar.GetSlotsPerRow()) + 1
        ui:ExternalInterfaceCall("pipRequestContextMenu", "hotbarSlot", root.stage.mouseX + 10, root.stage.mouseY - 110)
    end
end

Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function (action, binding)
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
Ext.Events.Tick:Subscribe(function()
    if Ext.Client.GetGameState() ~= "Running" or Client.IsUsingController() then return nil end

    if Hotbar.initialized then
        if Hotbar.tickCounter % Hotbar.COOLDOWN_UPDATE_DELAY == 0 then
            Hotbar.RenderCooldowns()
        end
        if Hotbar.tickCounter % Hotbar.UPDATE_DELAY == 0 then
            Hotbar.RenderHotkeys()
            -- Hotbar.RenderSlots()
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
-- end)

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

function Hotbar.RenderHotkeys()
    local hotkeys = Hotbar.GetHotkeysHolder()

    for i,state in ipairs(Hotbar.GetActionButtons()) do
        local element = hotkeys.hotkeyButtons[i - 1]
        local hasAction = Hotbar.HasBoundAction(i)
        local keyString
        local enabled = Hotbar.IsActionEnabled(state.ActionID, i)
        local actionID = state.ActionID or ""
        local actionData = Hotbar.GetActionData(state.ActionID)

        if actionID ~= "" and actionData == nil then
            Hotbar:Log("Unbinding unregistered action: " .. state.ActionID)

            Hotbar.UnbindActionButton(i)
            break
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

                if keyString and (Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "HotbarHotkeysText") or Epip.IS_IMPROVED_HOTBAR) then
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

            Hotbar:GetUI():SetCustomIcon("pip_drawerButton_" .. RemoveTrailingZeros(button.index), Hotbar.GetActionIcon(id), 32, 32)
        end
    end
end

function Hotbar.ShouldShowSourceFrame(index)
    local bar = Client.GetCharacter().PlayerData.SkillBarItems
    local slot = bar[index + 1]
    local show = false

    if slot.Type == "Skill" then
        local stat = Ext.Stats.Get(slot.SkillOrStatId)

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
        local stat = Ext.Stats.Get(slot.SkillOrStatId)
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
                    local skillData = Ext.Stats.Get(data.SkillOrStatId)
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
            end
        end
    end
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
                local slot = slotHolder.slot_array[slotIndex]
                local data = Hotbar.GetSlotData(char, slotIndex + 1)
        
                local inUse = true -- Whether the slot holds anything.
                local amount = 0
                local slotType = 0
                local handle = 0
                local tooltip = "" -- TODO is this only for skills?
                local isEnabled = false -- TODO
                local cooldown = 0
        
                -- types: 0 empty, 1 skill, 2 item
                if data.Type == "Skill" then
                    local skillData = Ext.Stats.Get(data.SkillOrStatId)
                    ---@type EclSkill
                    local skill = char.SkillManager.Skills[data.SkillOrStatId]
                    tooltip = data.SkillOrStatId
                    slotType = 1
        
                    if skill then
                        cooldown = skill.ActiveCooldown / 6

                        handle = Ext.HandleToDouble(skill.OwnerHandle)
        
                        isEnabled = Game.Character.CanUseSkill(char, data.SkillOrStatId)
                    else 
                        -- Hotbar:LogError("Trying to update skill not in skillmanager! " .. data.SkillOrStatId)
                        cooldown = 0
                        handle = Ext.HandleToDouble(char.Handle)
                        isEnabled = false
                    end
                elseif data.Type == "Item" then
                    slotType = 2
        
                    local item = Ext.GetItem(data.ItemHandle)
        
                    handle = Ext.HandleToDouble(item.Handle)
                    amount = item.Amount
                    isEnabled = true
        
                    if item.Stats then
                        isEnabled = Game.Stats.MeetsRequirements(char, item.Stats.Name, true)
                    end
                elseif data.Type == "Action" then
                    isEnabled = true
                    slotType = 1
                    tooltip = data.SkillOrStatId
                    handle = Ext.HandleToDouble(char.Handle)
                elseif data.Type == "None" then
                    inUse = false
                end
        
                -- Disable using any slots during combat, outside your turn, or while casting a skill.
                if not canUseHotbar then
                    isEnabled = false
                end
        
                -- print(inUse, slot.tooltip, slot.isEnabled, "isUpdate", slot.isUpdated, "type", slot.type, "handle", slot.handle, slot.oldCD, slot.setCoolDown)
                slotHolder.pipSetSlot(slotIndex, tooltip, isEnabled and cooldown <= 0, inUse, handle, slotType, amount)
                slot.isUpdated = true
                
                if not isEnabled and slot.disable_mc.alpha == 0 then -- TODO figure out what is fucking with this - it must be the setCooldown function somehow. Slots get enabled when they shouldn't be
                    slot.disable_mc.alpha = 1
                end
                -- print(slotIndex, tooltip, isEnabled, inUse, handle, slotType, amount)

                -- slot.unavailable_mc.visible = false -- Leftover from DOS1. (SetSlotPreviewEnabledMC)

                -- We no longer rely on this as it fucks with the cooldown values. Apparently the original code is optimized enough to only update this when needed.
                -- slotHolder.setSlot(slotIndex, tooltip, isEnabled and cooldown <= 0, handle, slotType, amount)
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
    Hotbar:GetRoot().showLog_mc.visible = (Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "HotbarCombatLogButton") or Epip.IS_IMPROVED_HOTBAR) and Hotbar.IsVisible()
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
            Client.Input.SetFocus(false)
        end
    end)

    Ext.RegisterUICall(ui, "stopDragging", OnStopDragging, "After")
    Ext.RegisterUICall(ui, "cancelDragging", OnStopDragging, "After")
    Ext.RegisterUICall(ui, "pipPrevHotbar", OnHotbarCyclePrev)
    Ext.RegisterUICall(ui, "pipNextHotbar", OnHotbarCycleNext)
    Ext.RegisterUICall(ui, "pipUpdateSlots", OnVanillaUpdateSlots)
    Ext.RegisterUIInvokeListener(ui, "updateSlots", OnUpdateSlots, "After")
    -- Ext.RegisterUIInvokeListener(ui, "updateSlotData", OnUpdateSlotData, "After")
    Ext.RegisterUICall(ui, "pipAddHotbar", OnAddHotbar)
    Ext.RegisterUICall(ui, "pipRemoveHotbar", OnRemoveHotbar)
    Ext.RegisterUICall(ui, "pipHotbarHotkeyPressed", OnHotkey)
    Ext.RegisterUICall(ui, "pipHotbarStartRearrange", OnRearrangeStart)
    Ext.RegisterUICall(ui, "pipHotbarStopRearrange", OnRearrangeStop)
    Ext.RegisterUICall(ui, "pipHotbarOpenContextMenu", OnHotkeyRightClick)
    Ext.RegisterUICall(ui, "pipUnbindHotbarButton", OnRequestUnbind)
    Ext.RegisterUICall(ui, "pipSlotPressed", OnSlotPressed)
    Ext.RegisterUICall(ui, "pipSlotKeyAttempted", OnSlotKeyPressed)
    Ext.RegisterUICall(ui, "pipSlotRightClicked", OnSlotRightClicked)
    Ext.RegisterUICall(ui, "pipDrawerToggled", OnDrawerToggle)
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

        if bar.Visible then
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
end

-- handle switching hotbars the normal way (buttons and hotkeys)
function CycleHotbar(ui, current, index, increment)
    Hotbar:DebugLog("Trying to cycle " .. index)
    local next = current + increment

    -- add modifier keys to select higher hotbars
    if Client.Input.KeyHeld(285) then -- cycle 2nd bar
        index = index + 1
    -- elseif Input:KeyHeld(220) then -- cycle 3rd bar
    --     index = index + 2
    end

    UpdateSlotTextures()
    Hotbar.CycleBar(index, increment) -- cycle our own scripted bars
end

function OnHotbarCyclePrev(ui, method, current, index)
    CycleHotbar(ui, current, index, -1)
end

function OnHotbarCycleNext(ui, method, current, index)
    CycleHotbar(ui, current, index, 1)
end

function OnVanillaUpdateSlots(ui, method, slots)
    UpdateSlotTextures()
end

function handleUpdateSlots(uiObj, methodName, param3, slotsAmount)
    local root = uiObj:GetRoot()
    Hotbar.Refresh()
end

Ext.Events.SessionLoaded:Subscribe(function()
    Hotbar.GetSlotHolder().rowHeight = 65

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.hotBar, "setPlayerHandle", OnHotbarSetHandle, "After")
    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.hotBar, "updateSlots", handleUpdateSlots, "Before")

    Hotbar.initialized = true
end)