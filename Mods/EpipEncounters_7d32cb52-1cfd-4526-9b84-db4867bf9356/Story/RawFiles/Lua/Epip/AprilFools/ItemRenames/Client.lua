
---------------------------------------------
-- Renames certain items to gags during April Fools.
---------------------------------------------

local Tooltip = Client.Tooltip

local ItemRenames = {
    NAME_REPLACEMENTS = {
        ["Paragon"] = "Paragon Fiskalny",
        ["Protean Artifact"] = "Protein Artifact",
    }
}
Epip.RegisterFeature("Features.AprilFools.ItemRenames", ItemRenames)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Rename items in tooltips.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local itemName = ev.Tooltip:GetFirstElement("ItemName")
    if not itemName then return end
    for oldName,newName in pairs(ItemRenames.NAME_REPLACEMENTS) do
        if string.match(itemName.Label, oldName) then
            itemName.Label = string.gsub(itemName.Label, oldName, newName)
        end
    end
end, {EnabledFunctor = Epip.IsAprilFools})
