
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local GenericComponent = Navigation:GetClass("GenericUI.Navigation.Components.Generic")
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local ScrollListComponent = Navigation:GetClass("GenericUI.Navigation.Components.ScrollList")
local Overlay = Epip.GetFeature("Feature_SettingsMenuOverlay")
local Navbar = Epip.GetFeature("Features.NavigationBar")
local UI = Overlay.UI ---@cast UI +GenericUI.Navigation.UI

UI.OFFSET_WITH_NAVIGATION_BAR = -40 -- Vertical position offset for the UI when the navigation bar is shown.
UI.NAVIGATION_BAR_OFFSET = 40 -- Vertical offset for navigation bar.

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the navigation controller for the UI.
function UI.SetupNavigation()
    local root = ListComponent:Create(UI:GetElementByID("Root"), {
        ScrollBackwardEvents = {"UISelectChar1", "UISelectSlot1", "PrevObject"},
        ScrollForwardEvents = {"UISelectChar2", "UISelectSlot2", "NextObject"},
    })
    local tabButtons = ScrollListComponent:Create(UI.TabButtonsList)
    tabButtons.Events.ChildAdded:Subscribe(function (ev)
        GenericComponent:Create(ev.Child)
    end, {Priority = -999})
    local rightPanel = ScrollListComponent:Create(UI.List, {
        ScrollDownEvents = {"ShowSneakCones", "CameraZoomOut"},
        ScrollUpEvents = {"DestructionToggle", "CameraZoomIn"},
    })

    root:SetChildren({
        tabButtons,
        rightPanel,
    })

    Controller.Create(UI, root)
    root:FocusByIndex(1)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Initialize navigation after the UI is initialized.
---@diagnostic disable: invisible
local origInit = Overlay._Initialize
Overlay._Initialize = function ()
    ---@diagnostic enable: invisible
    origInit()
    local navigation = UI.___NavigationController
    if navigation == nil then
        UI.SetupNavigation()
    end
end

-- Setup the navigation bar when the UI is opened.
local origSetup = Overlay.Setup
Overlay.Setup = function (...)
    origSetup(...)
    Navbar.Setup(UI, Vector.Create(0, UI.NAVIGATION_BAR_OFFSET))
    UI:GetUI().Top = -UI.OFFSET_WITH_NAVIGATION_BAR
    UI:Move(Vector.Create(0, UI.OFFSET_WITH_NAVIGATION_BAR))
end
