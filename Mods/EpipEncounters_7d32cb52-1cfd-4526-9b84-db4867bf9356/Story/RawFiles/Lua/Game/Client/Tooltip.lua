
-- Fixes item comparisons passing the wrong EclItem by always fetching Client char rather than getting the UI's character (which doesn't work for all UIs)
Game.Tooltip.TooltipHooks.GetCompareItem = function(self, ui, item, offHand)
    local owner = Client.GetCharacter() 
    if owner == nil then
        owner = item:GetOwnerCharacter()
    end

    if owner == nil then
        Ext.PrintError("Tooltip compare render failed: Couldn't find owner of item")
        return nil
    end

    --- @type EclCharacter
    local char = owner

    if item.Stats.ItemSlot == "Weapon" then
        if offHand then
            return char:GetItemBySlot("Shield")
        else
            return char:GetItemBySlot("Weapon")
        end
    elseif item.Stats.ItemSlot == "Ring" or item.Stats.ItemSlot == "Ring2" then
        if offHand then
            return char:GetItemBySlot("Ring2")
        else
            return char:GetItemBySlot("Ring")
        end
    else
        return char:GetItemBySlot(item.Stats.ItemSlot)
    end
end