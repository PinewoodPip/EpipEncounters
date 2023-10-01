
---@class Features.ItemTagging
local ItemTagging = Epip.Features.ItemTagging
local TSK = ItemTagging.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---Appends a notice to a tooltip.
---@param tooltip TooltipLib_FormattedTooltip
---@param text string
function ItemTagging.AddTooltipFootnote(tooltip, text)
    local desc = tooltip:GetFirstElement("ItemDescription")
    if desc then
        desc.Label = desc.Label .. "<br><br>" .. text
    else
        tooltip:InsertElement({
            Type = "ItemDescription",
            Label = text,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Append tag-related notices to tagged items's tooltips.
Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item
    local bookRead = item:HasTag(ItemTagging.BOOK_READ_TAG)
    local keyUsed = item:HasTag(ItemTagging.KEY_USED_TAG)
    local text = nil

    if bookRead then
        text = TSK.Hint_UsedItem_Book:GetString()
    elseif keyUsed then
        text = TSK.Hint_UsedItem_Key:GetString()
    end

    if text then
        text = Text.Format(text, {Color = ItemTagging.USED_ITEM_HINT_COLOR}) -- Formatting is done here rather than within the TSK itself to make the color simpler to change by other scripts.
        ItemTagging.AddTooltipFootnote(ev.Tooltip, text)
    end
end)