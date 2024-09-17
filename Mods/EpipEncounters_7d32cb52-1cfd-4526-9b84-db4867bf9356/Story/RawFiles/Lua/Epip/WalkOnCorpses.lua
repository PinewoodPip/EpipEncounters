
---------------------------------------------
-- Allows you to walk onto lootable corpses in combat.
-- Disabled while shift is held.
---------------------------------------------

---@class WalkOnCorpses : Feature
local WalkOnCorpses = {
    SETTING_ID = "Feature_WalkOnCorpses",
}
Epip.RegisterFeature("WalkOnCorpses", WalkOnCorpses)

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function WalkOnCorpses:IsEnabled()
    return not Client.Input.IsShiftPressed() and _Feature.IsEnabled(self) and Client.IsInCombat() and Settings.GetSettingValue("EpipEncounters", WalkOnCorpses.SETTING_ID)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

GameState.Events.RunningTick:Subscribe(function (_)
    local char = Pointer.GetCurrentCorpse()
    if char and char.Dead and char.CorpseLootable and WalkOnCorpses:IsEnabled() and not WalkOnCorpses.currentEntityHandle then
        WalkOnCorpses:DebugLog("Disabling corpse looting on ", char.DisplayName)
        char.CorpseLootable = false
        WalkOnCorpses.currentEntityHandle = char.Handle

        -- Re-enable looting once the pointer is moved away from the corpse.
        GameState.Events.RunningTick:Subscribe(function (_)
            local pointerChar = Pointer.GetCurrentCorpse()
            if not pointerChar or pointerChar.Handle ~= WalkOnCorpses.currentEntityHandle or not WalkOnCorpses:IsEnabled() then
                char = Character.Get(WalkOnCorpses.currentEntityHandle)
                if char then -- The character might've been deleted.
                    WalkOnCorpses:DebugLog("Re-enabling corpse looting on ", char.DisplayName)
                    char.CorpseLootable = true
                end

                WalkOnCorpses.currentEntityHandle = nil
                GameState.Events.RunningTick:Unsubscribe("WalkOnCorpses")
            end
        end, {StringID = "WalkOnCorpses"})
    end
end)