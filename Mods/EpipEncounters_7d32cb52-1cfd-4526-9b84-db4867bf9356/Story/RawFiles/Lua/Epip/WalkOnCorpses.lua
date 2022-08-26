
---------------------------------------------
-- Allows you to walk onto lootable corpses in combat.
-- Disabled while shift is held.
---------------------------------------------

---@class WalkOnCorpses : Feature
local WalkOnCorpses = {
    currentCharHandle = nil, ---@type EntityHandle

    SETTING_ID = "Feature_WalkOnCorpses",
}
Epip.RegisterFeature("WalkOnCorpses", WalkOnCorpses)

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function WalkOnCorpses:IsEnabled()
    return not Client.Input.IsShiftPressed() and _Feature.IsEnabled(self) and Client.IsInCombat() and Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", WalkOnCorpses.SETTING_ID)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

GameState.Events.RunningTick:Subscribe(function (_)
    local state = Ext.UI.GetPickingState()
    local char

    if state.HoverCharacter2 then
        char = Character.Get(state.HoverCharacter2)
    end

    if char and char.Dead and char.CorpseLootable and WalkOnCorpses:IsEnabled() then
        WalkOnCorpses:DebugLog("Disabling corpse looting on ", char.DisplayName)

        char.CorpseLootable = false

        WalkOnCorpses.currentEntityHandle = char.Handle

        -- Re-enable looting once we move our cursor away from the corpse.
        GameState.Events.RunningTick:Subscribe(function (ev)
            local state = Ext.UI.GetPickingState()
            local barChar = nil

            if state.HoverCharacter2 then
                barChar = Character.Get(state.HoverCharacter2)
            end

            if not barChar or barChar.Handle ~= WalkOnCorpses.currentEntityHandle or not WalkOnCorpses:IsEnabled() then
                local char = Character.Get(WalkOnCorpses.currentEntityHandle)

                WalkOnCorpses:DebugLog("Re-enabling corpse looting on ", char.DisplayName)
        
                char.CorpseLootable = true

                GameState.Events.RunningTick:Unsubscribe("WalkOnCorpses")
            end
        end, {StringID = "WalkOnCorpses"})
    end
end)