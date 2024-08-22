
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local GenericComponent = Navigation:GetClass("GenericUI.Navigation.Components.Generic")
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local Navbar = Epip.GetFeature("Features.NavigationBar")
local CommonStrings = Text.CommonStrings
local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local UI = RadialMenus.MenuCreatorUI ---@cast UI +GenericUI.Navigation.UI

local RootComponent ---@type GenericUI.Navigation.Components.List

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create navigation controller when the UI is initialized.
UI.Events.Initialized:Subscribe(function (_)
    local settings = ListComponent:Create(UI.SettingsList)
    local buttonsList = ListComponent:Create(UI.ButtonsBar, {
        ScrollBackwardEvents = {"UILeft"},
        ScrollForwardEvents = {"UIRight"},
    })

    -- Create components for the buttons at the bottom bar
    GenericComponent:Create(UI.CreateButton)
    GenericComponent:Create(UI.DeleteButton)

    local root = ListComponent:Create(UI.Root)
    root:SetChildren({
        settings,
        buttonsList,
    })

    -- Add save/cancel/delete actions
    root:AddAction({
        ID = "Cancel",
        Name = CommonStrings.Cancel,
        Inputs = {["UIBack"] = true, ["ToggleInGameMenu"] = true},
    })
    root:AddAction({
        ID = "Save",
        Name = CommonStrings.Save,
        Inputs = {["UITakeAll"] = true},
    })
    root:AddAction({
        ID = "Delete",
        Name = CommonStrings.Delete,
        Inputs = {["UISetSlot"] = true},
        IsConsumableFunctor = function (_)
            return UI.IsEditingMenu()
        end
    })

    root.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Event.Timing == "Up" then -- Some of these events used are only fired by the game for "Up".
            if ev.Action.ID == "Save" then
                UI.Finish()
                ev.Consumed = true
            elseif ev.Action.ID == "Delete" then
                UI.RequestDeleteMenu()
                ev.Consumed = true
            elseif ev.Action.ID == "Cancel" then
                UI:Hide()
                ev.Consumed = true
            end
        end
    end)

    RootComponent = root

    Controller.Create(UI, root)
    root:FocusByIndex(1)
    buttonsList:FocusByIndex(1)
end)

-- Show the navbar when the UI is opened.
UI.Events.Opened:Subscribe(function (_)
    RootComponent:FocusByIndex(1) -- Focus the settings list, so the focus doesn't get restored to other elements like the buttons bar.
    Navbar.Setup(UI)
end)
