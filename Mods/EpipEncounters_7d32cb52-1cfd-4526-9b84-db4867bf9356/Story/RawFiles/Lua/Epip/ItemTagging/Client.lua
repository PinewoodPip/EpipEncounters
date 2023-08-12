
---@class Features.ItemTagging
local ItemTagging = Epip.Features.ItemTagging

---------------------------------------------
-- METHODS
---------------------------------------------

---Appends a notice to a tooltip.
---@param tooltip TooltipLib_FormattedTooltip
---@param text string
function ItemTagging.AddTooltipFootnote(tooltip, text)
    local desc = tooltip:GetFirstElement("ItemDescription")
    if desc then -- Use ItemDescription if available.
        desc.Label = desc.Label .. "<br><br>" .. text
    else
        tooltip:InsertElement({
            Type = "WeaponDamagePenalty",
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
    local text

    if bookRead then
        text = Text.Format("Book read.", {
            Color = "488f1f",
        })
    elseif keyUsed then
        text = Text.Format("Key used.", {
            Color = "488f1f",
        })
    end

    if text then
        ItemTagging.AddTooltipFootnote(ev.Tooltip, text)
    end
end)