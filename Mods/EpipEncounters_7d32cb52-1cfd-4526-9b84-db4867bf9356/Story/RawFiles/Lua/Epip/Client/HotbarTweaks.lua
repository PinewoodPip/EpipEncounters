
local Hotbar = Client.UI.Hotbar
local Notification = Client.UI.Notification

---@type Feature
local Tweaks = {
    TOGGLE_BARS_KEYBIND = "EpipEncounters_Hotbar_ToggleVisibility",
    NOTIFICATION_SKILL_UNKNOWN_HANDLE = "hc06b03e5gb780g42dfgb39ege54c7aeac8a8",

    barsVisible = true,
    _CurrentHoveredSlotIndex = nil,

    TranslatedStrings = {
        Setting_AllowDraggingUnlearntSkills_Name = {
            Handle = "h1608e07agf046g4d0dg8298gcfd263df903e",
            Text = "Allow dragging in unlearnt skills",
            ContextDescription = "Setting name",
        },
        Setting_AllowDraggingUnlearntSkills_Description = {
            Handle = "hfcebd9e1g7fa9g4176g81b4g7cb089ba65ba",
            Text = "If enabled, you will be able to drag skills the character doesn't know onto the hotbar.\nThis does not allow the skills to be used, but is useful for creating placeholders.",
            ContextDescription = "Setting tooltip",
        },
    },
    Settings = {},
}
Epip.RegisterFeature("HotbarTweaks", Tweaks)

---------------------------------------------
-- SETTINGS
---------------------------------------------

Tweaks.Settings.AllowDraggingUnlearntSkills = Tweaks:RegisterSetting("AllowDraggingUnlearntSkills", {
    Type = "Boolean",
    NameHandle = Tweaks.TranslatedStrings.Setting_AllowDraggingUnlearntSkills_Name,
    DescriptionHandle = Tweaks.TranslatedStrings.Setting_AllowDraggingUnlearntSkills_Description,
    DefaultValue = false,
})

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
    local draggedSkill = Pointer.GetDraggedSkill()
    if ev.InputID == "left2" and draggedSkill and Tweaks:GetSettingValue(Tweaks.Settings.AllowDraggingUnlearntSkills) == true then
        local hoveredSlotIndex, _ = Hotbar.GetHoveredSlot()
        local char = Client.GetCharacter()
        if hoveredSlotIndex and not Character.IsSkillLearnt(char, draggedSkill) then -- Only do this for unlearnt skills.
            local slot = char.PlayerData.SkillBarItems[hoveredSlotIndex]

            slot.Type = "Skill"
            slot.SkillOrStatId = draggedSkill
            slot.ItemHandle = Ext.Entity.NullHandle()

            Hotbar.Refresh()
            Hotbar.RenderSlot(char, Hotbar.CanUseHotbar(), hoveredSlotIndex)
        end
    end
end)

-- Prevent "X doesn't know this skill" notifications if dragging unlearnt skills is enabled.
Client.UI.Notification.Events.TextNotificationShown:Subscribe(function (ev)
    local skillUnknownMsg = Text.Replace(Text.GetTranslatedString(Tweaks.NOTIFICATION_SKILL_UNKNOWN_HANDLE), "[1]", "") -- Placeholder must be removed for matching.

    if ev.Label:match(skillUnknownMsg) and Tweaks:GetSettingValue(Tweaks.Settings.AllowDraggingUnlearntSkills) == true then
        Tweaks:DebugLog("Prevented skill unknown notification")
        ev:Prevent()
    end
end)