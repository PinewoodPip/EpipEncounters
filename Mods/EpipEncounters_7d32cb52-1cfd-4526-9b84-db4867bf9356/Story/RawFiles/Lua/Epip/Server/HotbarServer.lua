local Hotbar = {
    
}
Epip.RegisterFeature("HotbarManager", Hotbar)
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
    Hotbar.UseItem(payload:GetCharacter(), payload:GetItem())
end)

Net.RegisterListener("EPIPENCOUNTERS_Hotbar_UseTemplate", function(payload)
    Osiris.PROC_PIP_Hotbar_UseTemplate(payload:GetCharacter(), payload.Template)
end)