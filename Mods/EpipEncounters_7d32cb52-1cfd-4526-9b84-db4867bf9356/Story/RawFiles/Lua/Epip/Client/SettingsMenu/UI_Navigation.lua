
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local GenericComponent = Navigation:GetClass("GenericUI.Navigation.Components.Generic")
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local ScrollListComponent = Navigation:GetClass("GenericUI.Navigation.Components.ScrollList")
local CommonStrings = Text.CommonStrings
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
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
        -- PrevObject/NextObject correspond to bumpers on controller
        ScrollBackwardEvents = {"UILeft", "PrevObject", "UIBack"},
        ScrollForwardEvents = {"UIRight", "NextObject"},
    })
    -- Rename the default actions to reduce ambiguity
    root:GetAction("Next").Name = CommonStrings.NextSection
    root:GetAction("Previous").Name = CommonStrings.PreviousSection
    -- Add action for closing the UI
    root:AddAction({
        ID = "Exit",
        Name = CommonStrings.Close,
        Inputs = {["ToggleInGameMenu"] = true},
    })
    root.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Event.Timing == "Up" and root:CanConsumeInput("Exit", ev.Event.EventID) then
            SettingsMenu.Close()
            ev.Consumed = true
        end
    end)

    -- Tab buttons
    local tabButtons = ScrollListComponent:Create(UI.TabButtonsList)
    tabButtons.Events.ChildAdded:Subscribe(function (ev)
        -- Create generic components for all tab buttons so they can be interacted with
        local component = GenericComponent:Create(ev.Child)

        -- Automatically focus the settings list after changing tabs
        component.Hooks.ConsumeInput:Subscribe(function (inputEv)
            if inputEv.Event.Timing == "Up" and component:CanConsumeInput("Interact", inputEv.Event.EventID) then
                Ext.OnNextTick(function() root:FocusByIndex(2) end) -- Needs be delayed to have the button finish handling the Up event
                -- Should not consume the event so the default Button component logic does so
            end
        end)
    end, {Priority = -999})

    -- Settings list
    local rightPanel = ScrollListComponent:Create(UI.List, {
        ScrollDownEvents = {"CameraZoomOut"},
        ScrollUpEvents = {"CameraZoomIn"},
    })

    -- Bottom buttons
    local bottomButtons = ListComponent:Create(UI.BottomButtonList, {
        -- The buttons list is horizontal, thus the default up/down would not be intuitive
        ScrollBackwardEvents = {"UILeft"},
        ScrollForwardEvents = {"UIRight"},
    })
    GenericComponent:Create(UI.AcceptButton)
    GenericComponent:Create(UI.ApplyButton)

    -- Root navigation
    root:SetChildren({
        tabButtons,
        rightPanel,
        bottomButtons,
    })

    Controller.Create(UI, root)

    -- Set default foci for the lists
    root:FocusByIndex(1) -- Tab buttons
    rightPanel:SetFocusedIndex(1)
    bottomButtons:SetFocusedIndex(2) -- FocusByIndex() is not used as it would immediately highlight the button
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
    if Navbar.Setup(UI, Vector.Create(0, UI.NAVIGATION_BAR_OFFSET)) then
        UI:GetUI().Top = -UI.OFFSET_WITH_NAVIGATION_BAR
        UI:Move(Vector.Create(0, UI.OFFSET_WITH_NAVIGATION_BAR))
    end
end
