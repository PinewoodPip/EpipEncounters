
local Mods = Mod.GUIDS
local Warnings = {
    INCOMPATIBLE_MODS = {
        [Mods.EE_CORE] = {
            -- I don't have the mental energy to get the GUIDs of all the Odin mods atm. This is the only one I had on hand
            Mods.ODIN_SUMMONING_SCALING,
            Mods.CONFLUX,
            Mods.CRAFTING_OVERHAUL,
            Mods.BETTER_CLOUDS,
            Mods.IMPROVED_GWYDIAN_RINCE,
            Mods.CITIZENS_OF_DIVINITY,
            Mods.POLYMORPH_RECRUITING_FIX,
            Mods.INITIATIVE_TURN_ORDER,
            Mods.WILDFIRE,
            Mods.RELICS_OF_RIVELLON_FIX,
        },
        [Mods.EPIP_ENCOUNTERS] = {
            Mods.IMPROVED_HOTBAR,
            Mods.LEADERLIB,
        },
    },
    MESSAGE = "Mod '%s' is incompatible with '%s' and it is not recommended to use them together.",
}
Epip.AddFeature("IncompatibleModsWarning", "IncompatibleModsWarning", Warnings)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Osiris.RegisterSymbolListener("SavegameLoaded", 4, "after", function(_, _, _, _)
    for baseModGuid,list in pairs(Warnings.INCOMPATIBLE_MODS) do
        if Mod.IsLoaded(baseModGuid) then
            for _,incompatibleModGUID in pairs(list) do
                if Mod.IsLoaded(incompatibleModGUID) then
                    local val1, val2 = Osiris.DB_PIP_IncompatibleModWarningSeen(baseModGuid, incompatibleModGUID)
                    local warningSeen = val1 ~= nil and val2 ~= nil
        
                    -- Only show this warning once per mod pair.
                    if not warningSeen then
                        local mod = Ext.Mod.GetModInfo(incompatibleModGUID)
                        local baseMod = Ext.Mod.GetModInfo(baseModGuid)
                        local message = string.format(Warnings.MESSAGE, mod.Name, baseMod.Name)
                
                        Osi.PROC_AMER_GEN_OpenMessageBoxForPlayers_Queued(message)
            
                        Osi.DB_PIP_IncompatibleModWarningSeen(baseModGuid, incompatibleModGUID)
                    end
                end
            end
        end
    end
end)