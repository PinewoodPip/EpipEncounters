
function GetRuneSlots(item)
    local itemData = Ext.GetItem(item)

    local runeSlots = 0
    for i,v in pairs(itemData.Stats.DynamicStats) do
        runeSlots = runeSlots + v.RuneSlots
    end

    return runeSlots
end

function Test()
    Ext.Print("test2")
    return true
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

        local isTransmogged = itemData:HasTag("PIP_Vanity_Transmogged")

        local isMaxed = GetRuneSlots(itemId) >= limit
        if isMaxed then
            if limit == 3 then
                Osi.OpenMessageBox(char, "AMER_UI_Greatforge_AddSockets_InvalidSelection3Sockets")
            else
                Osi.OpenMessageBox(char, "AMER_UI_Greatforge_AddSockets_InvalidSelection2Sockets")
            end
        elseif isTransmogged then
            Osi.OpenMessageBox(char, "I must first restore the item to its original appearance - I cannot do this with transmogrified equipment.")
        end
        return isMaxed or isTransmogged
    end
    return false
end

Ext.Print("Loaded Epip Encounters Lua")