
---@class Feature_OverheadFixes
local OverheadFixes = Epip.GetFeature("Feature_OverheadFixes")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for HEAL statuses being applied and forwarded ones that would result in missing overheads to *all* clients.
Ext.Events.StatusGetEnterChance:Subscribe(function (ev)
    local status = ev.Status
    if status.StatusType ~= "HEAL" then return end
    ---@cast status EsvStatusHeal
    local target = Character.Get(status.OwnerHandle)

    if target and target.Stats.TALENT_Zombie then
        local healType = status.HealType

        if healType == "AllArmor" then
            Net.Broadcast(OverheadFixes.NETMSG_HEAL_OVERHEAD, {CharacterNetID = target.NetID, Amount = status.HealAmount, HealType = "PhysicalArmor"})
            Net.Broadcast(OverheadFixes.NETMSG_HEAL_OVERHEAD, {CharacterNetID = target.NetID, Amount = status.HealAmount, HealType = "MagicArmor"})
        elseif healType == "PhysicalArmor" or healType == "MagicArmor" then
            Net.Broadcast(OverheadFixes.NETMSG_HEAL_OVERHEAD, {CharacterNetID = target.NetID, Amount = status.HealAmount, HealType = healType})
        end
    end
end)