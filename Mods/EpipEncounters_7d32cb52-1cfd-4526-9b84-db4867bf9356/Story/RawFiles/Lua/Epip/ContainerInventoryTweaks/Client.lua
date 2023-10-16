
---------------------------------------------
-- Adds on-hover slot highlighting to empty slots in ContainerInventory.
---------------------------------------------

local ContainerInventory = Client.UI.ContainerInventory

---@class Features.ContainerInventoryTweaks : Feature
local Tweaks = {
    _PreviousSelectedCell = nil, ---@type FlashMovieClip

    TranslatedStrings = {
        Setting_HighlightEmptySlots_Name = {
            Handle = "h86148d3fg72feg42b1gacc8g8f1b57d5f975",
            Text = "Highlight Empty Container Slots",
            ContextDescription = "Setting name",
        },
        Setting_HighlightEmptySlots_Description = {
            Handle = "h9f74c097g9888g4f33gb296gd6286d108329",
            Text = "If enabled, hovering over empty slots in the container inventory UI will highlight them. This setting is purely cosmetic, and is intended to make the container UI consistent with how the party inventory UI behaves.",
            ContextDescription = "Setting description",
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.ContainerInventoryTweaks", Tweaks)
local TSK = Tweaks.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Tweaks.Settings.HighlightEmptySlots = Tweaks:RegisterSetting("HighlightEmptySlots", {
    Type = "Boolean",
    Name = TSK.Setting_HighlightEmptySlots_Name,
    DescriptionHandle = TSK.Setting_HighlightEmptySlots_Description,
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Highlights an inventory cell.
---@param cell FlashMovieClip
function Tweaks.HighlightCell(cell)
    cell.hl_mc.visible = true
    cell.hl_mc.alpha = 1
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Highlight empty cells being hovered.
ContainerInventory.Events.HoveredItemChanged:Subscribe(function (_)
    local cell, _ = ContainerInventory.GetSelectedCell()

    -- Only do this for empty cells. Cells with items are already handled by the UI and use tweens, which we cannot recreate easily.
    -- The UI also handles hovering out of the cell even if we're the ones to set the highlight.
    if cell and cell.itemHandle == 0 then
        Tweaks.HighlightCell(cell)
    end
end, {EnabledFunctor = function ()
    return Tweaks:GetSettingValue(Tweaks.Settings.HighlightEmptySlots) == true
end})
