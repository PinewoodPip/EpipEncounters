
local Generic = Client.UI.Generic

---@class MouseTracker : Feature
local MouseTracker = {
    UI = nil, ---@type GenericUI_Instance
}
Epip.AddFeature("MouseTracker", "MouseTracker", MouseTracker)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the global position of the mouse, in pixel coordinates.
---@return integer, integer
function MouseTracker.GetMousePosition()
    MouseTracker.UI:GetUI():SetPosition(0, 0)
    local root = MouseTracker.UI:GetRoot()
    local vp = Ext.UI.GetViewportSize()
    local width, height = vp[1], vp[2]
    local stage = root.stage
    local x = stage.mouseX
    local y = stage.mouseY
    local xScale = (width / height) / 1.777 

    x = x / xScale

    x = (x / 1920) * width
    y = (y / 1080) * height

    return Ext.Round(x), Ext.Round(y)
end

---------------------------------------------
-- SETUP
---------------------------------------------

function MouseTracker:__Setup()
    MouseTracker.UI = Generic.Create("PIP_MouseTracker")
    MouseTracker.UI:GetUI():SetPosition(0, 0)

    if MouseTracker:IsDebug() then
        MouseTracker.UI:CreateElement("_", "TiledBackground")
    end
end

---------------------------------------------
-- TESTS
---------------------------------------------

-- Ext.Events.Tick:Subscribe(function (e)
--     local x, y = MouseTracker.GetMousePosition()

--     MouseTracker:DebugLog("Stage Mouse pos", x, y)
-- end)