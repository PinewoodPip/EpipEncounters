
---------------------------------------------
-- Show consumable effects by default.
---------------------------------------------

local Consumables = {} ---@type Feature
Epip.RegisterFeature("ShowConsumableEffects", Consumables)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function (_)
    if Consumables:IsEnabled() then
        local stats = Ext.Stats.GetStats("Potion")

        for _,statID in ipairs(stats) do
            local stat = Stats.Get("Potion", statID)

            stat.UnknownBeforeConsume = "No"
        end
    end
end)