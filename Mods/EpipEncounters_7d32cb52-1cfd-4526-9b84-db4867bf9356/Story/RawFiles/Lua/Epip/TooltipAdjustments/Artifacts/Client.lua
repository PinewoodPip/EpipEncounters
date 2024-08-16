
---------------------------------------------
-- Adds a special rarity color for artifact items
-- and clarifies valid equip slots for Artifact foci.
---------------------------------------------

local Tooltip = Client.Tooltip
local CommonStrings = Text.CommonStrings

---@class Features.TooltipAdjustments.Artifacts : Feature
local ArtifactTooltips = {
    RUNE_CANNOT_EQUIP_COLOR = "7b8087",
    RARITY_COLOR = "a34114", -- This color was colored by the EE team, all thanks go to Ameranth and Elric!
    -- Other colors we tried:
    -- #c7a758
    -- #9c561e
    -- #9e4b06
    -- #9c561e -- PoE color, iirc?
    TranslatedStrings = {
        Label_CannotEquip = {
            Handle = "h54e102a8ge257g41c9g91ecgf19525348e6e",
            Text = "Cannot equip.",
            ContextDescription = [[Tooltip for invalid Artifact focus rune slots]],
        },
    },
}
Epip.RegisterFeature("Features.TooltipAdjustments.Artifacts", ArtifactTooltips)
local TSK = ArtifactTooltips.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---Changes the rarity color of an Artifact item tooltip.
---@param ev TooltipLib_Hook_RenderItemTooltip
function ArtifactTooltips.ModifyArtifactTooltip(ev)
    ArtifactTooltips._ModifyRarityColors(ev)

    -- Change rarity name
    -- This element is not present for runes, and cannot be added to them (causes an error in flash)
    local tooltip = ev.Tooltip
    local rarityElement = tooltip:GetFirstElement("ItemRarity")
    local rarityString = CommonStrings.Artifact:Format({
        Color = ArtifactTooltips.RARITY_COLOR,
    })
    rarityElement.Label = rarityString
end

---Adds hints on valid slots for an Artifact focus tooltip
---and modifies the rarity color.
---@param ev TooltipLib_Hook_RenderItemTooltip
function ArtifactTooltips.ModifyFocusTooltip(ev)
    ArtifactTooltips._ModifyRarityColors(ev)

    -- Add a "Cannot equip" hint to empty rune effects
    local tooltip = ev.Tooltip
    local runeEffectElement = tooltip:GetFirstElement("RuneEffect")
    if runeEffectElement then
        local keys = {"Rune1", "Rune2", "Rune3"}
        for _,key in pairs(keys) do
            if runeEffectElement[key] == "" then
                runeEffectElement[key] = TSK.Label_CannotEquip:GetString()
            end
        end
    end
end

---Modifies the color of the item name and rarity element.
---@param ev TooltipLib_Hook_RenderItemTooltip Must be an Artifact or focus tooltip.
function ArtifactTooltips._ModifyRarityColors(ev)
    local item, tooltip = ev.Item, ev.Tooltip
    local itemNameElement = tooltip:GetFirstElement("ItemName")

    -- Change item name
    local header
    if Item.IsIdentified(item) then
        header = Text.StripFontTags(itemNameElement.Label)
    else
        -- Replace "Unidentified Unique Item" with "Unidentified Artifact"
        header = Text.ReplaceLarianPlaceholders(Text.GetTranslatedString(Item.UNIDENTIFIED_ITEM_TSKHANDLE), CommonStrings.Artifact:GetString())
    end
    itemNameElement.Label = Text.Format(header, {
        Color = ArtifactTooltips.RARITY_COLOR,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Apply changes to artifact item tooltips.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item
    if Artifact.IsArtifact(item) then
        ArtifactTooltips.ModifyArtifactTooltip(ev)
    elseif Artifact.IsArtifactFocus(item) then
        ArtifactTooltips.ModifyFocusTooltip(ev)
    end
end, {StringID = "Features.TooltipAdjustments.Artifacts"})
