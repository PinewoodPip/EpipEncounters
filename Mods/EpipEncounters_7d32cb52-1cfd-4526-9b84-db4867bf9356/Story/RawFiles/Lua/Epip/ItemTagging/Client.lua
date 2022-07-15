
local ItemTagging = Epip.Features.ItemTagging

---------------------------------------------
-- METHODS
---------------------------------------------

---@param tooltip TooltipData
---@param text string
function ItemTagging.AddTooltipFootnote(tooltip, text)
    local desc = tooltip:GetElement("ItemDescription")

    if desc then
        desc.Label = desc.Label .. "<br><br>" .. text
    else
        tooltip:AppendElement({
            Type = "WeaponDamagePenalty",
            Label = text,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Game.Tooltip.RegisterListener("Item", nil, function(item, tooltip)
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
        ItemTagging.AddTooltipFootnote(tooltip, text)
    end
end)