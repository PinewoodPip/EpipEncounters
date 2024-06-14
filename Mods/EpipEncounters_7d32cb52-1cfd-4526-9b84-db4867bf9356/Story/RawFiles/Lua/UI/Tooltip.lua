
---@class TooltipUI : UI
local Tooltip = {
    SIMPLE_TOOLTIP_DELAY = 0.5, -- Hardcoded delay for showing tooltips from addTooltip(), if delay parameter is `true`.
    COMPARE_TOOLTIP_DELAY = 0.6, -- Hardcoded delay for comparison tooltips.
    ALPHA_TWEEN_IN_TIME = 0.09, -- Hardcoded tween time for tooltip panel alpha.
}
Epip.InitializeUI(44, "Tooltip", Tooltip)
