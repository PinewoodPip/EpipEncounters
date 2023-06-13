

---@class Feature_FlagsDisplay
local FlagsDisplay = Epip.GetFeature("Feature_FlagsDisplay")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update the default flags tracked upon a turn starting.
Osiris.RegisterSymbolListener("ObjectTurnStarted", 1, "after", function (guid)
    local char = Character.Get(guid)

    -- Only update flags for main player characters, to reduce savegame bloat.
    if char and Character.IsPlayer(char) and not Character.HasOwner(char) then
        local vars = FlagsDisplay:GetUserVariable(char, FlagsDisplay.USERVAR)
        local combatComponent = Ext.Entity.GetCombatComponent(char.Base.Entity:GetComponent("Combat"))

        -- CanUseResistDeadTalent only seems to be set on server.
        if combatComponent then
            vars.CanUseResistDeadTalent = combatComponent.CanUseResistDeadTalent
        end

        FlagsDisplay:SetUserVariable(char, "Flags", vars)
        
        FlagsDisplay:DebugLog("Updated user vars for", char.DisplayName)
        FlagsDisplay:Dump(vars)
    end
end)