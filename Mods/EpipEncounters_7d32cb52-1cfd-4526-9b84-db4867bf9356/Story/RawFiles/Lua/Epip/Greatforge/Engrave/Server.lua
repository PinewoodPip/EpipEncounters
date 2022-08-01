
---@class Feature_GreatforgeEngrave
local Engrave = Epip.Features.GreatforgeEngrave

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Osiris.RegisterSymbolListener('PROC_AMER_UI_Greatforge_DoCraft', 11, "after", function(_, char, _, item, _, _, _, _, _, _, craftOperation)
    if (craftOperation == Engrave.OPTION_ID) then
        item = Item.Get(item)
        char = Character.Get(char)

        Net.PostToCharacter(char, "EPIPENCOUNTERS_GreatforgeEngrave", {
            ItemNetID = item.NetID,
            CharNetID = char.NetID,
        })

        Engrave:DebugLog("Sent engrave request to " .. char.DisplayName)
    end
end)

Net.RegisterListener("EPIPENCOUNTERS_GreatforgeEngrave_Confirm", function(_, payload)
    local item = Item.Get(payload.ItemNetID)
    local text = payload.Name

    item.CustomDisplayName = text

    Engrave:DebugLog("Item engraved: " .. item.DisplayName .. " to " .. item.CustomDisplayName)
end)