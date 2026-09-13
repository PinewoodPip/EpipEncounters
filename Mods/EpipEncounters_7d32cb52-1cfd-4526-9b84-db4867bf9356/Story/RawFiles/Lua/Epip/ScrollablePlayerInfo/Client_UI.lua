
local Generic = Client.UI.Generic
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local Input = Client.Input

local Scrolling = Epip.GetFeature("Features.ScrollablePlayerInfo")

---@class Features.ScrollablePlayerInfo.Overlay : GenericUI_Instance
local Overlay = Generic.Create("Features.ScrollablePlayerInfo")
Overlay.SCROLLBAR_HEIGHT = 900 -- In flash units.
Overlay.TOP_MARGIN = 15
Overlay.SCROLLBAR_SENSITIVITY = 1.1 -- Multiplier for scroll amount when dragging the handle.
Overlay._IsUsingScrollbar = false

---Shows the scrollbar overlay.
function Overlay.Setup()
    Overlay._Initialize()
    Overlay._UpdateScrollBar()
    Overlay:SetPosition(Vector.zero2)
    Overlay._UpdateVisibility() -- Will Show/Hide the overlay appropriately
end

---Updates the position of the scrollbar based on scroll progress.
function Overlay._UpdateScrollBar()
    local scrollbarRoot = Overlay.ScrollBarRoot
    local scrollbar = Overlay.ScrollBar
    local progress = Scrolling.GetScrollProgress()
    local scrollUpButtonHeight = Overlay.ScrollUpButton:GetHeight()
    local y = scrollUpButtonHeight + progress * (Overlay.SCROLLBAR_HEIGHT - scrollbar:GetHeight() - Overlay.ScrollDownButton:GetHeight())
    scrollbarRoot:SetPosition(0, y)
end

---Updates the visibility of the overlay based on mouse position.
function Overlay._UpdateVisibility()
    local isOverPortraits = Overlay._IsUsingScrollbar or Scrolling.IsMouseWithinScrollArea()
    if isOverPortraits then
        Overlay:SetPositionRelativeToViewport("topleft", "topleft") -- For some reason, if this is done only on Setup(), then the position will gain a horizontal margin upon doing a Lua reset
        Overlay:Move(Vector.Create(0, Overlay.TOP_MARGIN * Overlay:GetUI():GetUIScaleMultiplier()))
        Overlay:TryShow()
    else
        Overlay:TryHide()
    end
end

---Creates the overlay's elements.
function Overlay._Initialize()
    if Overlay._Initialized then return end

    local root = Overlay:CreateElement("Root", "GenericUI_Element_Empty")

    local scrollUpButtonRoot = root:AddChild("ScrollButton.Up.Root", "GenericUI_Element_Empty")
    local scrollUpButton = ButtonPrefab.Create(Overlay, "ScrollButton.Up", scrollUpButtonRoot, ButtonPrefab.STYLES.ScrollLeft)
    scrollUpButton:SetRotation(90)
    scrollUpButtonRoot:SetPosition(scrollUpButton:GetWidth(), 0)
    scrollUpButton.Events.Pressed:Subscribe(function (_)
        Scrolling.Scroll(1)
    end)
    Overlay.ScrollUpButtonRoot = scrollUpButtonRoot -- TODO remove these auxiliary roots when vertical scrollbar assets are imported
    Overlay.ScrollUpButton = scrollUpButton

    local scrollBarButtonRoot = root:AddChild("ScrollBarRoot", "GenericUI_Element_Empty")
    local scrollBarButton = ButtonPrefab.Create(Overlay, "ScrollBar", scrollBarButtonRoot, ButtonPrefab.STYLES.ScrollBarHorizontal)
    scrollBarButton:SetRotation(90)
    scrollBarButton:SetPosition(scrollBarButton:GetWidth(), 0)
    scrollBarButton:GetRootElement().Events.MouseDown:Subscribe(function (_)
        Overlay._IsUsingScrollbar = true
        Overlay:GetUI().OF_PlayerModal1 = true
    end)
    Overlay.ScrollBarRoot = scrollBarButtonRoot
    Overlay.ScrollBar = scrollBarButton

    local scrollDownButtonRoot = root:AddChild("ScrollButton.Down.Root", "GenericUI_Element_Empty")
    local scrollDownButton = ButtonPrefab.Create(Overlay, "ScrollButton.Down", scrollDownButtonRoot, ButtonPrefab.STYLES.ScrollRight)
    scrollDownButton:SetRotation(90)
    scrollDownButton:SetPosition(scrollDownButton:GetWidth(), 0)
    scrollDownButtonRoot:SetPosition(0, Overlay.SCROLLBAR_HEIGHT)
    scrollDownButton.Events.Pressed:Subscribe(function (_)
        Scrolling.Scroll(-1)
    end)
    Overlay.ScrollDownButtonRoot = scrollDownButtonRoot
    Overlay.ScrollDownButton = scrollDownButton

    -- Register this UI as not preventing scrolling when hovered over
    Scrolling.WHITELISTED_HOVER_UIS[Overlay:GetUI():GetHandle()] = true

    Overlay._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create the overlay when the client is ready.
GameState.Events.ClientReady:Subscribe(function (_)
    Overlay.Setup()
    Input.Events.MouseMoved:Subscribe(function (_)
        Overlay._UpdateVisibility()
    end)
end)

-- Handle scrolling through the scrollbar handle.
-- MouseUp event is not used as it would not be able to detect the case of releasing
-- the click while the cursor is no longer over the handle.
Input.Events.MouseMoved:Subscribe(function (ev)
    local yDelta = ev.Vector[2]
    local ticksRequired = Scrolling.GetMaxScrollTicks()
    local startPos = Overlay.ScrollUpButtonRoot:GetScreenPosition()
    local endPos = Overlay.ScrollDownButtonRoot:GetScreenPosition()
    local distance = endPos[2] - startPos[2]
    local scrollTicks = Overlay.SCROLLBAR_SENSITIVITY * (-yDelta * ticksRequired) / (distance)
    Scrolling.Scroll(scrollTicks)
end, {EnabledFunctor = function ()
    return Overlay._IsUsingScrollbar
end})
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if Overlay._IsUsingScrollbar and ev.InputID == "left2" and ev.State == "Released" then
        Overlay._IsUsingScrollbar = false
        -- Needs to be delayed to prevent the mouse release from being processed by the game this tick.
        Ext.OnNextTick(function ()
            Overlay:GetUI().OF_PlayerModal1 = false
        end)
    end
end)

-- Update scrollbar when scroll position is changed.
Scrolling.Events.Scrolled:Subscribe(function (_)
    Overlay._UpdateScrollBar()
end)
