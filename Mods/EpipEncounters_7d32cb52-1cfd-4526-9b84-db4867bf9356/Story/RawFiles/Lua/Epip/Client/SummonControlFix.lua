
local PlayerInfo = Client.UI.PlayerInfo

---@type Feature
local Fix = {

}
Epip.AddFeature("SummonControlFix", "SummonControlFix", Fix)
Fix:Debug()

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

PlayerInfo.Events.ActiveCharacterChanged:Subscribe(function (e)
    local newChar = e.NewCharacter
    local prevChar = e.PreviousCharacter

    -- Ignore manual character changes
    if newChar and prevChar and not e.Manual then

        -- Only swap if it is not the new char's turn
        if Client.IsInCombat() and not Client.IsActiveCombatant() then
            local previousCharacter = Character.Get(prevChar.Handle)

            Fix:DebugLog("Restoring control to previous character", previousCharacter.DisplayName)

            PlayerInfo.SelectCharacter(previousCharacter.Handle)
        end
    end
end)