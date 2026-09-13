
---------------------------------------------
-- Allows scrolling the PlayerInfo UI to view party members that otherwise are overflowed
-- ex. When using expanded party size mods
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo
local Input = Client.Input

---@class Features.ScrollablePlayerInfo : Feature
local Scrolling = {
    MOUSE_X_THRESHOLD = 115, -- Area from the left of the screen where scrolling will possible when mouse is within.
    SCROLL_SENSITIVITY = 100, -- How much the portraits are scrolled with each scroll tick, in flash unit.
    PLAYERINFO_BOTTOM_MARGIN = -50, -- Screenspace at the bottom to consider non-visible/obstructed, in flash units. Determines how far down portraits must be scrolled for the last one to be considered fully on-screen.
    WHITELISTED_HOVER_UIS = {}, ---@type set<UIObjectHandle> UIs that can be hovered over without preventing scrolling.

    ---@type table<InputRawType, integer>
    _ScrollWheelToDir = {
        ["wheel_ypos"] = 1,
        ["wheel_yneg"] = -1,
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Scrolled = {}, ---@type Event<{Delta: number}>
    },
}
Epip.RegisterFeature("Features.ScrollablePlayerInfo", Scrolling)

---------------------------------------------
-- METHODS
---------------------------------------------

---Scrolls the portraits.
---@param delta number Ticks to scroll; positive values will scroll down.
---@return boolean -- Whether the portraits were scrolled (`false` in case the call was a no-op, ex. when already at the boundaries)
function Scrolling.Scroll(delta)
    local root = PlayerInfo:GetRoot()
    local container = root.container_mc
    local oldY = container.y

    -- Scroll the portraits
    local newY = math.clamp(container.y + delta * Scrolling.SCROLL_SENSITIVITY, -Scrolling._GetScrollHeightRange(), 0)
    container.y = newY

    local scrollChanged = oldY ~= container.y
    if scrollChanged then
        Scrolling.Events.Scrolled:Throw({
            Delta = delta,
        })
    end

    return scrollChanged
end

---Returns how far the UI has been scrolled from the top to bottom.
---@return number -- In range [0, 1], where 1 indicates scrolled to bottom.
function Scrolling.GetScrollProgress()
    local root = PlayerInfo:GetRoot()
    local container = root.container_mc
    local scrollRange = Scrolling._GetScrollHeightRange()
    return math.abs(container.y / scrollRange)
end

---Returns whether the mouse is over the PlayerInfo UI's portraits area,
---including gaps between unchained portraits.
function Scrolling.IsMouseWithinScrollArea()
    -- Note: bounds check is necessary because moving the cursor to be in the gap between unchained
    -- player portraits will not cause PlayerInfo to become the active UI.
    -- Additionally, we do not want to scroll when hovering over the statuses display.
    local xBounds = Scrolling.MOUSE_X_THRESHOLD * PlayerInfo:GetUI():GetUIScaleMultiplier()
    local uiManager = Ext.UI.GetUIObjectManager()
    local mouseX, _ = Client.GetMousePosition()
    local activeUIHandle = uiManager.PlayerStates[1].ActiveUIObjectHandle
    local isOverDifferentUI = Ext.Utils.IsValidHandle(activeUIHandle) and activeUIHandle ~= PlayerInfo:GetUI():GetHandle()
    return (not isOverDifferentUI or Scrolling.WHITELISTED_HOVER_UIS[activeUIHandle]) and mouseX < xBounds
end

---Returns how many scroll wheel ticks are required to fully scroll from one end to the other.
---@return number -- May have decimals.
function Scrolling.GetMaxScrollTicks()
    return Scrolling._GetScrollHeightRange() / Scrolling.SCROLL_SENSITIVITY
end

---Returns the height of the visible PlayerInfo viewport, in flash units,
---accounting for bottom screen area possibly being obstructed.
---Considers UI scaling.
---@return number -- In flash units.
function Scrolling._GetPlayerInfoFlashViewport()
    local uiScale = PlayerInfo:GetUI():GetUIScaleMultiplier()
    local viewportHeight = Client.GetViewportSize()[2]
    local flashViewportHeight = viewportHeight / uiScale
    return flashViewportHeight - Scrolling.PLAYERINFO_BOTTOM_MARGIN
end

---Returns how much the position of the PlayerInfo container can change as a result of scrolling.
---@return number -- Absolute value.
function Scrolling._GetScrollHeightRange()
    local root = PlayerInfo:GetRoot()
    local container = root.container_mc
    local containerHeight = container.height
    local flashViewportHeight = Scrolling._GetPlayerInfoFlashViewport()
    return math.max(0, containerHeight - flashViewportHeight)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Allow scrolling portraits with mouse wheel while hovering over them.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    local moveDir = Scrolling._ScrollWheelToDir[ev.InputID]
    if moveDir and Scrolling.IsMouseWithinScrollArea() then
        if Scrolling.Scroll(moveDir) then
            PlayerInfo:PlaySound("UI_Generic_Click")
        end
        ev:Prevent()
    end
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse}) -- We don't want to run this at all in controller UI, as it doesn't consider the split 2-player layout in splitscreen.
