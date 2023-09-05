
---------------------------------------------
-- Displays the names of the first X items within a container in its tooltip.
---------------------------------------------

local Tooltip = Client.Tooltip

---@type Feature
local ContainerPreview = {
    INFO_COLOR = Color.LARIAN.ORANGE,

    Settings = {},
    TranslatedStrings = {
        Tooltip_Contains = {
           Handle = "hba2e720bg358cg4f56g93ecgea7847f1cea3",
           Text = "Contains %s.",
           ContextDescription = "Tooltip for contained items. Parameter is the item names (there may be multiple, becoming comma-separated)",
        },
        Tooltip_Etcetera = {
           Handle = "h5cb6c524ge5a5g4184g8354g9386bbfdc00c",
           Text = "and %d more items", -- TODO consider singular?
           ContextDescription = "Appended to the tooltip if the container has many items. Parameter is amount of extra items.",
        },
        Setting_DetailedItemsAmount_Name = {
           Handle = "hb6fcd193g708cg460bg88d6gd0cfb64de8ea",
           Text = "Preview Container Items",
           ContextDescription = "Setting name",
        },
        Setting_DetailedItemsAmount_Description = {
           Handle = "h524c03d2g797cg4038g98d4gbc36024b7649",
           Text = "Displays the names of the first few items in containers within their tooltips. Set to 0 to disable.",
           ContextDescription = "Setting description",
        },
    },
}
Epip.RegisterFeature("TooltipAdjustments.ContainerPreview", ContainerPreview)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.TooltipAdjustments.ContainerPreview.Info
---@field PreviewedItemNames string[]
---@field RemainingItems integer Amount of non-previewed items.

---------------------------------------------
-- SETTINGS
---------------------------------------------

-- Controls the amount of items whose names are shown.
ContainerPreview.Settings.DetailedItemsAmount = ContainerPreview:RegisterSetting("DetailedItemsAmount", {
    Type = "ClampedNumber",
    NameHandle = ContainerPreview.TranslatedStrings.Setting_DetailedItemsAmount_Name,
    DescriptionHandle = ContainerPreview.TranslatedStrings.Setting_DetailedItemsAmount_Description,
    Min = 0,
    Max = 10,
    Step = 1,
    HideNumbers = false,
    DefaultValue = 3,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the labels for items within a container, determined by the feature's settings.
---@param container EclItem Must be a container.
---@return Features.TooltipAdjustments.ContainerPreview.Info
function ContainerPreview.GetInfo(container)
    ---@type Features.TooltipAdjustments.ContainerPreview.Info
    local info = {PreviewedItemNames = {}, RemainingItems = 0}

    local items = Item.GetContainedItems(container)
    local previewedItemsCount = ContainerPreview:GetSettingValue(ContainerPreview.Settings.DetailedItemsAmount)
    for i=1,math.clamp(previewedItemsCount, 0, #items),1 do
        local item = items[i]
        info.PreviewedItemNames[i] = Item.GetDisplayName(item)
    end

    info.RemainingItems = math.max(0, #items - previewedItemsCount)

    return info
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Insert previewed item names into container item tooltips.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if Item.IsContainer(ev.Item) then
        local info = ContainerPreview.GetInfo(ev.Item)
        if info.PreviewedItemNames[1] then -- Do not insert any label if there were no previewed items (ex. empty container or setting at 0).
            -- Append "and X more items" if need be. Mutating is fine here as we do not pass the info table elsewhere.
            -- We do not insert it into the table so as not to have a comma inserted inbetween.
            if info.RemainingItems > 0 then
                info.PreviewedItemNames[#info.PreviewedItemNames] = info.PreviewedItemNames[#info.PreviewedItemNames] .. " " .. string.format(ContainerPreview.TranslatedStrings.Tooltip_Etcetera:GetString(), info.RemainingItems)
            end

            local label = Text.Format(ContainerPreview.TranslatedStrings.Tooltip_Contains:GetString(), {
                FormatArgs = {Text.Join(info.PreviewedItemNames, ", ")},
                Color = ContainerPreview.INFO_COLOR,
            })

            local element = ev.Tooltip:GetFirstElement("ItemDescription")
            if element then -- Append if possible.
                element.Label = element.Label .. "\n\n" .. label
            else
                ev.Tooltip:InsertElement({
                    Type = "ItemDescription",
                    Label = label,
                })
            end
        end
    end
end)