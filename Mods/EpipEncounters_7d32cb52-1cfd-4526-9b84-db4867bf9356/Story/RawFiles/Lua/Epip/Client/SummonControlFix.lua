
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
        
        -- Only restore control if switching from a character to summon. We do not check if the char is the summoner as this bug can cause the control to be switched to other char's summons as well.
        if newChar.HasOwner then
            local summonerHandle = prevChar.Handle

            -- And only within combat if the summon does not have its turn
            if Client.IsInCombat() and not Client.IsActiveCombatant() then
                local summoner = Character.Get(summonerHandle)

                Fix:DebugLog("Restoring control to summoner", summoner.DisplayName)

                PlayerInfo.SelectCharacter(summoner.Handle)
            end
        end
    end
end)