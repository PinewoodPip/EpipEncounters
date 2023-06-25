
---@class Feature_GreatforgeEngrave
local Engrave = Epip.GetFeature("Feature_GreatforgeEngrave")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Osiris.RegisterSymbolListener('PROC_AMER_UI_Greatforge_DoCraft', 11, "after", function(_, char, _, item, _, _, _, _, _, _, craftOperation)
    if (craftOperation == Engrave.OPTION_ID) then
        item = Item.Get(item)
        char = Character.Get(char)

        Net.PostToCharacter(char, Engrave.NETMSG_ENGRAVE_START, {
            ItemNetID = item.NetID,
            CharacterNetID = char.NetID,
        })

        Engrave:DebugLog("Sent engrave request to " .. char.DisplayName)
    end
end)

Net.RegisterListener(Engrave.NETMSG_ENGRAVE_CONFIRM, function(payload)
    local item = payload:GetItem()
    local text = payload.NewItemName

    item.CustomDisplayName = text

    Engrave:DebugLog("Item engraved: " .. item.DisplayName .. " to " .. item.CustomDisplayName)
end)