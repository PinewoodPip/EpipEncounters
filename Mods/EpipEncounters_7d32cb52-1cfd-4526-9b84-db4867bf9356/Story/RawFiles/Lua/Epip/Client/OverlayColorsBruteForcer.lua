
---------------------------------------------
-- Brute-forces overlay colors from GlobalSwitches.
-- Upon running the command, all overlays will be set to black
-- and each of them in order will be highlighted
-- every X seconds, with their index being logged to the console.
---------------------------------------------

---@type Feature
local OverlayColors = {
    DELAY = 1, -- Default delay, in seconds.
    TIMER_ID = "OverlayColorsBruteForcer",
    HIGHLIGHT_COLOR = Color.Create(256, 0, 0),

    _Index = 1,
}
Epip.RegisterFeature("OverlayColorsBruteForcer", OverlayColors)

---------------------------------------------
-- METHODS
---------------------------------------------

---Highlights the next color and advances the index.
function OverlayColors.CycleColor()
    local colors = Ext.Utils.GetGlobalSwitches().OverlayColors

    -- Set all colors to black
    for i,_ in ipairs(colors) do
        colors[i] = Vector.Create(0, 0, 0, 1)
    end

    -- Set current color to the highlight color
    colors[OverlayColors._Index] = {OverlayColors.HIGHLIGHT_COLOR:ToFloats()}

    -- Log the index of the current color
    OverlayColors:Log("Current index highlighted: " .. OverlayColors._Index)
    
    OverlayColors._Index = OverlayColors._Index + 1

    -- Loop around the list
    if OverlayColors._Index > #colors then
        OverlayColors._Index = 1
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Starts the brute-forcing from a console command.
Ext.RegisterConsoleCommand("bruteforceoverlaycolors", function (_, delay, startIndex)
    OverlayColors:Log("Brute forcing overlay colors...")

    OverlayColors._Index = startIndex and tonumber(startIndex) or OverlayColors._Index

    local oldTimer = Timer.GetTimer(OverlayColors.TIMER_ID)
    if oldTimer then
        oldTimer:Cancel()
    end

    local timer = Timer.Start(OverlayColors.TIMER_ID, tonumber(delay) or OverlayColors.DELAY, function (_)
        OverlayColors.CycleColor()
    end)
    timer:SetRepeatCount(-1)
end)