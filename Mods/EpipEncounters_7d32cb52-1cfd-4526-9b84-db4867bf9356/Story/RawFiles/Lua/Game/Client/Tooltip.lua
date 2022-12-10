
-- April fools: scrollable tooltips... but sideways
Ext.Events.InputEvent:Subscribe(function(e)
    local scrollDirection = 0
    e = e.Event

    if e.EventId == 233 then
        scrollDirection = 1
    elseif e.EventId == 234 then
        scrollDirection = -1
    end

    if scrollDirection ~= 0 and Epip.IsAprilFools() then
        local ui = Ext.UI.GetByPath("Public/Game/GUI/tooltip.swf")
        local element = ui:GetRoot().tooltip_mc

        if element then
            local position = ui:GetPosition()

            ui:SetPosition(position[1] + scrollDirection * 30, position[2])
        end
    end
end)

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