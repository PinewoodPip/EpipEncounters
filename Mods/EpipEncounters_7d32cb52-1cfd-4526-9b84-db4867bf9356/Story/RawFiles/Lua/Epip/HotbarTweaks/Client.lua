
local Hotbar = Client.UI.Hotbar
local Notification = Client.UI.Notification

---@class Features.HotbarTweaks
local Tweaks = Epip.GetFeature("Features.HotbarTweaks")
local TSK = Tweaks.TranslatedStrings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add all actions to the action holder.
Hotbar.Hooks.UpdateEngineActions:Subscribe(function (ev)
    local actionOrder = {
        "ActionAttackGround",
        "ActionSkillSheathe",
        "ActionSkillSneak",
        "ActionSkillIdentify",
        "ActionSkillLockpick",
        "ActionSkillDisarm",
        "ActionSkillRepair",
        "ActionSkillEndTurn",
        "ActionSkillGuard",
    }
    local requiresCombat = {
        ActionSkillFlee = true,
        ActionSkillGuard = true,
        ActionSkillEndTurn = true,
    }
    local actions = {} ---@type HotbarUI_ArrayEntry_EngineAction[]

    -- Flee is not shown in EE.
    if not EpicEncounters.IsEnabled() then
        table.insert(actionOrder, "ActionSkillFlee")
    end

    for _,id in ipairs(actionOrder) do
        local action = Stats.GetAction(id)
        local enabled = true

        if requiresCombat[action.ID] then
            enabled = Client.IsActiveCombatant()
        end

        table.insert(actions, {ActionID = action.ID, Enabled = enabled})
    end

    ev.Actions = actions
end)

-- Listen for keybinds to toggle bar visibility.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == Tweaks.TOGGLE_BARS_KEYBIND then
        Tweaks.barsVisible = not Tweaks.barsVisible

        Tweaks:DebugLog("Toggling bar visibility")
        Hotbar.Refresh()

        -- Show notification for new state
        local notification = Tweaks.barsVisible and TSK.Notification_ToggleBarVisibility_On or TSK.Notification_ToggleBarVisibility_Off
        notification = notification:GetString()
        Notification.ShowNotification(notification)
    end
end)

-- Toggle visibility back on when the +/- buttons are pressed.
Hotbar.Events.BarPlusMinusButtonPressed:Subscribe(function (_)
    if not Tweaks.barsVisible then
        Tweaks.barsVisible = true
        Hotbar.Refresh()
    end
end)

-- Hook bar visibility. First bar remains visible.
Hotbar.Hooks.IsBarVisible:Subscribe(function (ev)
    if not Tweaks.barsVisible and ev.BarIndex > 1 then
        ev.Visible = false
    end
end)

---Prevent adding/removing bars while visibility is toggled off.
---@param ev HotbarUI_Hook_CanAddBar|HotbarUI_Hook_CanRemoveBar
local function CanModifyBarCount(ev)
    if not Tweaks.barsVisible then
        ev.CanAdd = false
        ev.CanRemove = false
    end
end
Hotbar.Hooks.CanAddBar:Subscribe(CanModifyBarCount)
Hotbar.Hooks.CanRemoveBar:Subscribe(CanModifyBarCount)

-- Force-set skills unlearnt skills onto the hotbar, if enabled.
Client.Input.Events.KeyReleased:Subscribe(function (ev)
    if ev.InputID == "left2" and Tweaks:IsEnabled() then
        local draggedSkill = Pointer.GetDraggedSkill()
        local hoveredSlotIndex, _ = Hotbar.GetHoveredSlot()

        if hoveredSlotIndex then
            local char = Client.GetCharacter()
            local slot = char.PlayerData.SkillBarItems[hoveredSlotIndex]

            -- Allow dragging unlearnt skills if the setting is enabled.
            -- Only do this for unlearnt skills; learnt skills are handled by engine.
            if draggedSkill and Tweaks:GetSettingValue(Tweaks.Settings.AllowDraggingUnlearntSkills) == true and not Character.IsSkillLearnt(char, draggedSkill) then
                slot.Type = "Skill"
                slot.SkillOrStatId = draggedSkill
                slot.ItemHandle = Ext.Entity.NullHandle()

                Hotbar.Refresh()
                Hotbar.RenderSlot(char, Hotbar.CanUseHotbar(), hoveredSlotIndex, slot)
            end
        end
    end
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse}) -- This feature is irrelevant to controller (no hotbar UI that can be dragged into)

-- Prevent "X doesn't know this skill" notifications if dragging unlearnt skills is enabled.
Client.UI.Notification.Events.TextNotificationShown:Subscribe(function (ev)
    local skillUnknownMsg = Text.Replace(Text.GetTranslatedString(Tweaks.NOTIFICATION_SKILL_UNKNOWN_HANDLE), "[1]", "") -- Placeholder must be removed for matching.

    if ev.Label:match(skillUnknownMsg) and Tweaks:GetSettingValue(Tweaks.Settings.AllowDraggingUnlearntSkills) == true then
        Tweaks:DebugLog("Prevented skill unknown notification")
        ev:Prevent()
    end
end)

-- Redirect slot keybind presses to upper visible bars, if modifier keys are held and the setting is enabled.
Hotbar.Hooks.GetSlotForIggyEvent:Subscribe(function (ev)
    if Tweaks:GetSettingValue(Tweaks.Settings.SlotKeyboardModifiers) == true then
        local barIndex = nil
        if Client.Input.IsShiftPressed() then
            barIndex = 2
        elseif Client.Input.IsCtrlPressed() then
            barIndex = 3
        elseif Client.Input.IsAltPressed() then
            barIndex = 4
        elseif Client.Input.IsGUIPressed() then
            barIndex = 5
        end

        if barIndex then
            local bar = Hotbar.GetState().Bars[barIndex]
            if bar.Visible then -- Can only redirect to visible bars.
                ev.SlotIndex = ev.SlotKeyIndex + (Hotbar.GetSlotsPerRow() * (bar.Row - 1))
            end
        end
    end
end)
