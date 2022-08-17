
local Empower = {}
Epip.RegisterFeature("EmpowerImprovements", Empower)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update the item's Generation Level after empowering, to correct the armor values. Unfortunately, a reload is still necessary to recalculate the armor values.
Osiris.RegisterSymbolListener("PROC_AMER_UI_Greatforge_DoCraft", 11, "after", function(_, _, _, item, _, _, _, _, _, _, craftOperation)
    if craftOperation == "LevelUp" then
        item = Item.Get(item)
        
        item.Generation.Level = item.Stats.Level
    end
end)