
local Hotbar = Client.UI.Hotbar
local OptionsInput = Client.UI.OptionsInput
local Notification = Client.UI.Notification

local Tweaks = {
    barsVisible = true,

    TOGGLE_BARS_KEYBIND = "EpipEncounters_Hotbar_ToggleVisibility",
}
Epip.RegisterFeature("HotbarTweaks", Tweaks)

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

-- Listen for keybind.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == Tweaks.TOGGLE_BARS_KEYBIND then
        Tweaks.barsVisible = not Tweaks.barsVisible

        Tweaks:DebugLog("Toggling bar visibility")
        Hotbar.Refresh()

        local notif = "Toggled extra bars visibility on."
        if not Tweaks.barsVisible then notif = "Toggled extra bars visibility off." end
        Notification.ShowNotification(notif)
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

-- Prevent adding/removing bars while visibility is toggled off.
---@param ev HotbarUI_Hook_CanAddBar|HotbarUI_Hook_CanRemoveBar
local function CanModifyBarCount(ev)
    if not Tweaks.barsVisible then
        ev.CanAdd = false
        ev.CanRemove = false
    end
end
Hotbar.Hooks.CanAddBar:Subscribe(CanModifyBarCount)
Hotbar.Hooks.CanRemoveBar:Subscribe(CanModifyBarCount)