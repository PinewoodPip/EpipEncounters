
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local GenericComponent = Navigation:GetClass("GenericUI.Navigation.Components.Generic")
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local ScrollListComponent = Navigation:GetClass("GenericUI.Navigation.Components.ScrollList")
local GridComponent = Navigation:GetClass("GenericUI.Navigation.Components.Grid")
local Navbar = Epip.GetFeature("Features.NavigationBar")
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local CommonStrings = Text.CommonStrings
local UI = QuickInventory.UI ---@class Features.QuickInventory.UI

local origInit = UI._Initialize
UI._Initialize = function ()
    local initialized = UI._Initialized
    origInit()

    if not initialized then
        local settings = ScrollListComponent:Create(UI.SettingsPanelList)
        settings.Events.ChildAdded:Subscribe(function (ev)
            GenericComponent:Create(ev.Child)
        end, {Priority = -999})
        local itemGrid = GridComponent:Create(UI.ItemGrid)
        itemGrid.Events.ChildAdded:Subscribe(function (ev)
            GenericComponent:Create(ev.Child)
        end, {Priority = -999})

        local root = ListComponent:Create(UI.Background.Background, {
            ScrollBackwardEvents = {"UISelectChar1", "UISelectSlot1", "PrevObject"},
            ScrollForwardEvents = {"UISelectChar2", "UISelectSlot2", "NextObject"},
            Wrap = false, -- There's just two tabs, it's better to think about switching from one to the other rather than scrolling.
        })
        -- Rename the default actions to clarify how to navigate the sections
        root:GetAction("Next").Name = CommonStrings.Settings
        root:GetAction("Previous").Name = CommonStrings.Items
        -- Add close action
        root:AddAction({
            ID = "Close",
            Inputs = {["ToggleInGameMenu"] = true, ["UICancel"] = true},
            Name = CommonStrings.Close,
        })
        root.Hooks.ConsumeInput:Subscribe(function (ev)
            if ev.Action.ID == "Close" then
                UI:Hide()
                ev.Consumed = true
            end
        end)

        root:SetChildren({
            itemGrid,
            settings,
        })

        Controller.Create(UI, root)

        -- Set default focus
        root:FocusByIndex(1)
    end
end

-- Show the navigation bar when the UI is opened.
local origSetup = UI.Setup
UI.Setup = function (...)
    origSetup(...)
    ---@cast UI +Features.NavigationBar.UI
    Navbar.Setup(UI, Vector.Create(0, -150))
end
