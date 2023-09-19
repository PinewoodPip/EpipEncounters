
---------------------------------------------
-- Makes the background of formatted tooltips fully opaque.
-- Unfortunately due to the way the UI textures are setup,
-- replacing the background entirely is difficult;
-- this opts to instead overlay a color via MovieClip graphics.
---------------------------------------------

local Tooltip = Client.Tooltip

---@type Feature
local OpaqueBackground = {
    COLOR = Color.BLACK,

    Settings = {},
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h8f54bda9g54cdg4390gb819g7d0af8b9d0ef",
            Text = "Opaque Background",
            ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
            Handle = "h176a0a5cgce9dg4cd7gbf2bg053624c85791",
            Text = "If enabled, skill, item, status and custom tooltips will use an opaque background.",
            ContextDescription = "Setting tooltip",
        },
    }
}
Epip.RegisterFeature("TooltipAdjustments.OpaqueBackground", OpaqueBackground)
local TSK = OpaqueBackground.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

OpaqueBackground.Settings.Enabled = OpaqueBackground:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function OpaqueBackground:IsEnabled()
    return self:GetSettingValue(OpaqueBackground.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Draw an opaque background for formatted tooltips.
Client.UI.Tooltip:RegisterInvokeListener("showFormattedTooltipAfterPos", function (ev)
    if OpaqueBackground:IsEnabled() then
        local root = ev.UI:GetRoot()
        local tooltip = root.formatTooltip.tooltip_mc
        local bg = tooltip.middleBg_mc ---@type FlashMovieClip This has bg_mc
        local header = tooltip.header_mc ---@type FlashMovieClip
        local extraHeight = 40
        local footer = tooltip.footer_mc
        if footer and footer.myType == 3 then
            extraHeight = extraHeight + 30
        end

        header.graphics.clear()
        header.graphics.beginFill(Color.CreateFromHex(Color.BLACK):ToDecimal(), 1)
        header.graphics.drawRect(10, 60, bg.width - 20, bg.height + extraHeight)
        header.graphics.endFill()
    end
end, "After")

-- Clear our background when tooltips are hidden.
Tooltip.Events.TooltipHidden:Subscribe(function (_)
    local root = Client.UI.Tooltip:GetRoot()
    local tooltip = root.formatTooltip.tooltip_mc
    local header = tooltip.header_mc ---@type FlashMovieClip

    header.graphics.clear()
end)
