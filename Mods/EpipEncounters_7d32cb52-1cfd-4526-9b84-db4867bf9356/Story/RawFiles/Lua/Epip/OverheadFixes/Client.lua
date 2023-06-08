
local OverheadUI = Client.UI.Overhead

---@class Feature_OverheadFixes
local OverheadFixes = Epip.GetFeature("Feature_OverheadFixes")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for undead healing overheads being sent from the server.
Net.RegisterListener(OverheadFixes.NETMSG_HEAL_OVERHEAD, function (payload)
    local char = payload:GetCharacter()
    local color

    OverheadFixes:DebugLog("Incoming overhead", char.DisplayName, payload.HealType, payload.Amount)

    if payload.HealType == "MagicArmor" then
        color = Color.MAGIC_ARMOR
    else
        color = Color.PHYSICAL_ARMOR
    end

    OverheadUI.ShowDamage(char, payload.Amount, color)
end)

-- Fix overheads blocking clicking.
GameState.Events.ClientReady:Subscribe(function (_)
    OverheadUI:TogglePlayerInput(false)
end)