local Hotbar = {
    
}
Epip.AddFeature("HotbarManager", "HotbarManager", Hotbar)
Hotbar:Debug()

---@param char EsvCharacter
---@param item EsvItem
function Hotbar.UseItem(char, item)
    Osi.CharacterUseItem(char.MyGuid, item.MyGuid, "")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_UseItem", function(payload)
    Hotbar.UseItem(Character.Get(payload.CharNetID), Item.Get(payload.ItemNetID))
end)

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_UseTemplate", function(payload)
    Osi.PROC_PIP_Hotbar_UseTemplate(Ext.GetCharacter(payload.NetID).MyGuid, payload.Template)
end)