
---------------------------------------------
-- Implements customizable delays for formatted tooltips and compare tooltips.
---------------------------------------------

local TooltipLib = Client.Tooltip
local TooltipUI = Client.UI.Tooltip
local PartyInventory = Client.UI.PartyInventory
local ContainerInventory = Client.UI.ContainerInventory

---@class Features.TooltipAdjustments.TooltipDelay : Feature
local TooltipDelay = {
    _TIMERID_DELAY = "Features.TooltipAdjustments.TooltipDelay.Delay",

    TranslatedStrings = {
        Setting_ItemTooltipDelay_Name = {
            Handle = "h1da3e55cg3534g4e65gb5f1g66d514505862",
            Text = "Inventory Item Tooltip Delay",
            ContextDescription = "Setting name",
        },
        Setting_ItemTooltipDelay_Description = {
            Handle = "he421bb33gea54g44b3ga90bg5fff2fae3383",
            Text = "Controls the delay in seconds before item tooltips display upon hovering over items in the Party Inventory and Container Inventory UIs.",
            ContextDescription = "Setting tooltip",
        },
        Setting_CompareTooltipDelay_Name = {
            Handle = "h4a54f1a3gad5eg4855g9b9cge11cad401d59",
            Text = "Item Comparison Tooltip Delay",
            ContextDescription = "Setting name",
        },
        Setting_CompareTooltipDelay_Description = {
            Handle = "hbed9b7bcgbbebg428cgbbf2g566a6033f281",
            Text = [[Controls the delay in seconds before item comparison tooltips are shown. This delay is additive with the "Inventory Item Tooltip Delay" setting.<br><br>Default value is %s seconds.]],
            ContextDescription = "Setting tooltip",
            FormatOptions = {
                FormatArgs = {TooltipUI.COMPARE_TOOLTIP_DELAY},
            },
        },
    },
    Settings = {},
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsApplicable = {}, ---@type Hook<Features.TooltipAdjustments.TooltipDelay.Hooks.IsApplicable>
    }
}
Epip.RegisterFeature("Features.TooltipAdjustments.TooltipDelay", TooltipDelay)
local TSK = TooltipDelay.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

TooltipDelay.Settings.ItemTooltipDelay = TooltipDelay:RegisterSetting("ItemTooltipDelay", {
    Type = "ClampedNumber",
    Name = TSK.Setting_ItemTooltipDelay_Name,
    Description = TSK.Setting_ItemTooltipDelay_Description,
    Min = 0,
    Max = 1.5,
    Step = 0.1,
    HideNumbers = false,
    DefaultValue = 0,
})
TooltipDelay.Settings.CompareTooltipDelay = TooltipDelay:RegisterSetting("CompareTooltipDelay", {
    Type = "ClampedNumber",
    Name = TSK.Setting_CompareTooltipDelay_Name,
    Description = TSK.Setting_CompareTooltipDelay_Description,
    Min = 0,
    Max = 1.5,
    Step = 0.1,
    HideNumbers = false,
    DefaultValue = 0.6,
})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.TooltipAdjustments.TooltipDelay.Hooks.IsApplicable
---@field TooltipSourceData TooltipLib_TooltipSourceData
---@field IsApplicable boolean Hookable. Defaults to `false`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether delays are applicable for a tooltip based on its source.
---@see Features.TooltipAdjustments.TooltipDelay.Hooks.IsApplicable
---@param sourceData TooltipLib_TooltipSourceData
---@return boolean
function TooltipDelay.IsDelayApplicable(sourceData)
    return TooltipDelay.Hooks.IsApplicable:Throw({
        TooltipSourceData = sourceData,
        IsApplicable = false,
    }).IsApplicable
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

TooltipLib.Events.TooltipPositioned:Subscribe(function (_)
    local source = TooltipLib.GetCurrentTooltipSourceData()
    local root = TooltipUI:GetRoot()

    -- Delay showing the tooltip, if applicable
    if source and TooltipDelay.IsDelayApplicable(source) then
        local tooltipDelay = TooltipDelay.Settings.ItemTooltipDelay:GetValue()
        local compareTooltipDelay = TooltipDelay.Settings.CompareTooltipDelay:GetValue()
        if tooltipDelay > 0 then -- Do nothing if the setting is set to 0, so as not to modify vanilly behaviour in any way.
            local timer = Timer.GetTimer(TooltipDelay._TIMERID_DELAY)
            if timer then
                timer:Cancel()
            end
            root.visible = false
            Timer.Start(TooltipDelay._TIMERID_DELAY, tooltipDelay, function (_) -- TODO emulate the alpha tween?
                root.visible = true
            end)
        end

        -- Modify compare tooltip timer
        local compareTimerDelay = tooltipDelay + compareTooltipDelay
        local timer = root.compareShowTimer
        timer.delay = compareTimerDelay * 1000
    end
end)

TooltipLib.Events.TooltipHidden:Subscribe(function (_)
    local root = TooltipUI:GetRoot()
    root.visible = true -- Undo any previous visibility modification.
end)

-- Default implementation of IsApplicable.
TooltipDelay.Hooks.IsApplicable:Subscribe(function (ev)
    local uiType = ev.TooltipSourceData.UIType
    local applicable = false

    applicable = applicable or (PartyInventory:Exists() and PartyInventory:GetUI():GetTypeId() == uiType)
    applicable = applicable or (ContainerInventory:Exists() and ContainerInventory:GetUI():GetTypeId() == uiType)

    ev.IsApplicable = ev.IsApplicable or applicable
end, {StringID = "DefaultImplementation"})
