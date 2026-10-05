
local Generic = Client.UI.Generic
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local Hotbar = Client.UI.Hotbar
local Trade = Client.UI.Trade

---@class Features.ScrollableTradePortraits
local Scrolling = Epip.GetFeature("Features.ScrollableTradePortraits")

---@class Features.ScrollableTradePortraits.Overlay : GenericUI_Instance
local Overlay = Generic.Create("Features.ScrollableTradePortraits")
Overlay.BUTTON_MARGIN = 5
Overlay.BUTTONS_Y = -5 -- Relative to the portraits container.
Overlay.DISABLED_BUTTON_ALPHA = 0.4
Overlay._TICK_EVENT_ID = "Features.ScrollableTradePortraits.Overlay"

---------------------------------------------
-- METHODS
---------------------------------------------

---Positions and shows the overlay, if the party portraits overflow.
function Overlay.Setup()
    if Scrolling.GetMaxScrollOffset() <= 0 then return end

    Overlay._Initialize()

    -- Position the overlay
    -- The overlay is anchored to the left of the portraits
    local portraitsContainer = Scrolling.GetPortraitsContainer()
    local pos = Vector.Create(Scrolling.DEFAULT_PORTRAITS_CONTAINER_X - Overlay.BUTTON_MARGIN - Overlay.ScrollLeftButton:GetWidth(), portraitsContainer.y)
    Overlay:SetPosition(Trade:FlashPositionToScreen(pos, true))

    Overlay._UpdateButtons()
    Overlay:TryShow()

    -- Hide the overlay when the Trade UI is closed.
    GameState.Events.Tick:Unsubscribe(Overlay._TICK_EVENT_ID) -- Avoid duplicate listeners, as Setup() is re-run when the viewport changes.
    GameState.Events.Tick:Subscribe(function (_)
        if not Trade:IsVisible() then
            Overlay:TryHide()
            GameState.Events.Tick:Unsubscribe(Overlay._TICK_EVENT_ID)
        end
    end, {StringID = Overlay._TICK_EVENT_ID})
end

---Updates the enabled state of the buttons based on scroll progress.
function Overlay._UpdateButtons()
    local offset = Scrolling.GetScrollOffset()
    local canScrollLeft = offset > 0
    local canScrollRight = offset < Scrolling.GetMaxScrollOffset()

    -- TODO add disabled textures for the buttons
    Overlay.ScrollLeftButton:SetEnabled(canScrollLeft)
    Overlay.ScrollLeftButton:GetRootElement():SetAlpha(canScrollLeft and 1 or Overlay.DISABLED_BUTTON_ALPHA)
    Overlay.ScrollRightButton:SetEnabled(canScrollRight)
    Overlay.ScrollRightButton:GetRootElement():SetAlpha(canScrollRight and 1 or Overlay.DISABLED_BUTTON_ALPHA)
end

---Returns the size of the area of the visible portraits, in flash units.
---@return Vector2
function Overlay._GetPortraitsAreaSize()
    local charactersList = Scrolling.GetPartyMembersList()
    local portrait = charactersList.content_array[0]
    local width = Scrolling.VISIBLE_PARTY_MEMBERS * (portrait.width + charactersList.EL_SPACING) - charactersList.EL_SPACING
    return Vector.Create(width, portrait.height)
end

---Creates the overlay's elements.
function Overlay._Initialize()
    if Overlay._Initialized then return end

    local root = Overlay:CreateElement("Root", "GenericUI_Element_Empty")

    local scrollLeftButton = ButtonPrefab.Create(Overlay, "ScrollButton.Left", root, ButtonPrefab.STYLES.LeftTall)
    scrollLeftButton.Events.Pressed:Subscribe(function (_)
        Scrolling.Scroll(-1)
    end)
    Overlay.ScrollLeftButton = scrollLeftButton

    local scrollRightButton = ButtonPrefab.Create(Overlay, "ScrollButton.Right", root, ButtonPrefab.STYLES.RightTall)
    scrollRightButton.Events.Pressed:Subscribe(function (_)
        Scrolling.Scroll(1)
    end)
    Overlay.ScrollRightButton = scrollRightButton

    -- Position buttons on the sides of the portrait slots
    local portraitsAreaSize = Overlay._GetPortraitsAreaSize()
    scrollLeftButton:SetPosition(0, Overlay.BUTTONS_Y)
    scrollRightButton:SetPosition(scrollLeftButton:GetWidth() + 2 * Overlay.BUTTON_MARGIN + portraitsAreaSize[1] - 8, Overlay.BUTTONS_Y) -- The RightTall button style has a margin(?) which makes the -8 offset necessary

    Overlay._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show the overlay when the Trade UI is opened.
Trade:RegisterCallListener("setAnchor", function (ev)
    -- We must disable the modal flag to allow the overlay's buttons to be used.
    local ui = ev.UI
    ui.OF_PlayerModal1 = false
    ui.OF_PreventCameraMove = true -- Needed to prevent camera rotation; since most other UIs are already placed below the Trade UI, this roughly replicates the behaviour of it being truly modal

    -- Delayed as the party portraits are set a tick after the Trade UI is created.
    Ext.OnNextTick(function ()
        Overlay.Setup()
    end)
end)

-- Reposition the overlay when the viewport changes.
Client.Events.ViewportChanged:Subscribe(function (_)
    if Overlay:IsVisible() then
        Overlay.Setup()
    end
end)

-- Update button states when the portraits are scrolled.
Scrolling.Events.Scrolled:Subscribe(function (_)
    if Overlay._Initialized then
        Overlay._UpdateButtons()
    end
end)

-- Disable Hotbar slots while the overlay is visible.
-- Necessary since we remove the Modal flag;
-- otherwise the player can strangely queue skill prepares through the slot hotkeys while in Trade.
Hotbar.Hooks.CanUseHotbar:Subscribe(function (ev)
    ev.CanUse = ev.CanUse and not Overlay:IsVisible()
end)
