
local GreatforgeDragDrop = Epip.GetFeature("Feature_GreatforgeDragDrop")

---------------------------------------------
-- METHODS
---------------------------------------------

---Benches an item.
---@param char EsvCharacter
---@param item EsvItem
function GreatforgeDragDrop._BenchItem(char, item)
    local instance = Osi.DB_AMER_UI_UsersInUI:Get(nil, nil, char.MyGuid)[1][1]
    local map = Osi.DB_CurrentLevel:Get(nil)[1][1]
    Osi.QRY_AMER_UI_Greatforge_GetCraftObject(instance, char.MyGuid, map)

    Osi.DB_AMER_GEN_OUTPUT_Item:Delete(nil)
    Osi.DB_AMER_GEN_OUTPUT_Item(item.MyGuid)
    Osi.PROC_AMER_UI_Greatforge_ProcessCombine(char.MyGuid, 1)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to bench items.
Net.RegisterListener(GreatforgeDragDrop.REQUEST_BENCH_NET_MSG, function (payload)
    local char, item = Character.Get(payload.CharacterNetID), Item.Get(payload.ItemNetID)

    GreatforgeDragDrop._BenchItem(char, item)
end)