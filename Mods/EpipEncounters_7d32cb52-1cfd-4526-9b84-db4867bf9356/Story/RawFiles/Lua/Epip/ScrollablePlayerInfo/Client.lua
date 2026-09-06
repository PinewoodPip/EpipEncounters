
---------------------------------------------
-- Allows scrolling the PlayerInfo UI to view party members that otherwise are overflowed
-- ex. When using expanded party size mods
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo
local Input = Client.Input

---@type Feature
local Scrolling = {
    MOUSE_X_THRESHOLD = 600,

    ---@type table<InputRawType, integer>
    _ScrollWheelToDir = {
        ["wheel_ypos"] = 1,
        ["wheel_yneg"] = -1,
    },
    _PlayerInfoOrigY = nil, ---@type number
}
Epip.RegisterFeature("Features.ScrollablePlayerInfo", Scrolling)

---------------------------------------------
-- METHODS
---------------------------------------------

---Scrolls the portraits.
---@param delta number Positive values will scroll down.
---@return boolean -- Whether the portraits were scrolled (`false` in case the call was a no-op, ex. when already at the boundaries)
function Scrolling.Scroll(delta)
    local root = PlayerInfo:GetRoot()
    Scrolling._PlayerInfoOrigY = Scrolling._PlayerInfoOrigY or root.y
    local oldY = root.y
    local container = root.container_mc
    local containerHeight = container.height - 500 -- Magic constant is to account for hotbar obscuring bottom part of the viewport

    -- Scroll the portraits
    local flashViewportHeight = PlayerInfo:GetUI():GetUIScaleMultiplier() * containerHeight -- Determine how much of the portraits container is visible
    local newY = math.clamp(root.y + delta * 100, containerHeight + -flashViewportHeight, Scrolling._PlayerInfoOrigY)
    root.y = newY

    return oldY ~= root.y
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Allow scrolling portraits with mouse wheel while hovering over them.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    local moveDir = Scrolling._ScrollWheelToDir[ev.InputID]
    if moveDir then
        -- Note: bounds check is necessary because moving the cursor to be in the gap between unchained
        -- player portraits will not cause PlayerInfo to become the active UI.
        local xBounds = 115 * PlayerInfo:GetUI():GetUIScaleMultiplier()
        local uiManager = Ext.UI.GetUIObjectManager()
        local mouseX, _ = Client.GetMousePosition()
        if uiManager.PlayerStates[1].ActiveUIObjectHandle == PlayerInfo:GetUI():GetHandle() and mouseX < xBounds then
            if Scrolling.Scroll(moveDir) then
                PlayerInfo:PlaySound("UI_Generic_Click")
            end
            ev:Prevent()
        end
    end
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse}) -- We don't want to run this at all in controller UI, as it doesn't consider the split 2-player layout in splitscreen.
