
local function GetRuneSlots(item)
    local itemData = Item.Get(item)

    local runeSlots = 0
    for _,v in pairs(itemData.Stats.DynamicStats) do
        runeSlots = runeSlots + v.RuneSlots
    end

    return runeSlots
end

function ItemHasMaxSockets(char, mode)
    if mode == "AddSockets" then
        local db = Osi.DB_AMER_UI_Greatforge_BenchedItem:Get(nil, nil, nil, nil, nil, nil, nil, nil, nil)

        local itemId = db[1][3]
        local limit = 3
        local itemData = Ext.GetItem(itemId)

        if (itemData.Stats.ItemSlot == "Weapon" and not itemData.Stats.IsTwoHanded) then
            limit = 2
        end

        local isMaxed = GetRuneSlots(itemId) >= limit
        if isMaxed then
            if limit == 3 then
                Osi.OpenMessageBox(char, "AMER_UI_Greatforge_AddSockets_InvalidSelection3Sockets")
            else
                Osi.OpenMessageBox(char, "AMER_UI_Greatforge_AddSockets_InvalidSelection2Sockets")
            end
        end
        return isMaxed
    end
    return false
end