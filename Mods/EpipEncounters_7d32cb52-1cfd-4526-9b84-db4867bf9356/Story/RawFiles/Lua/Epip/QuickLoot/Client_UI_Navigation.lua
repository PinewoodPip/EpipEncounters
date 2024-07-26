
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local GenericComponent = Navigation:GetClass("GenericUI.Navigation.Components.Generic")
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local ScrollListComponent = Navigation:GetClass("GenericUI.Navigation.Components.ScrollList")
local GridComponent = Navigation:GetClass("GenericUI.Navigation.Components.Grid")
local Navbar = Epip.GetFeature("Features.NavigationBar")
local CommonStrings = Text.CommonStrings
local QuickLoot = Epip.GetFeature("Features.QuickLoot")
local TSK = QuickLoot.TranslatedStrings

---@class Features.QuickLoot.UI
local UI = QuickLoot.UI
UI.NavigationComponents = {}

UI.Events.Initialized:Subscribe(function (_)
    local settings = ScrollListComponent:Create(UI.SettingsPanelList)
    settings.Events.ChildAdded:Subscribe(function (ev)
        GenericComponent:Create(ev.Child)
    end, {Priority = -999})

    local itemGrid = GridComponent:Create(UI.ItemGrid.Container)
    itemGrid.Events.ChildAdded:Subscribe(function (ev)
        GenericComponent:Create(ev.Child)
    end, {Priority = -999})

    local root = ListComponent:Create(UI.Background.Background, {
        ScrollBackwardEvents = {"UISelectChar1", "UISelectSlot1", "PrevObject"},
        ScrollForwardEvents = {"UISelectChar2", "UISelectSlot2", "NextObject"},
        Wrap = false, -- There's just two tabs, it's better to think about switching from one to the other rather than scrolling.
    })

    -- Rename the default actions to clarify how to navigate the sections
    root:GetAction("Next").Name = CommonStrings.Filters
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
        elseif ev.Action.ID == "Next" then -- Toggle the settings panel when navigating in & out of it.
            UI.SettingsPanel:SetVisible(true)
        elseif ev.Action.ID == "Previous" then
            UI.SettingsPanel:SetVisible(false)
        end
    end)

    -- Add "loot all" action
    root:AddAction({
        ID = "LootAll",
        Inputs = {["UITakeAll"] = true},
        Name = TSK.Label_LootAll,
    })
    root.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Action.ID == "LootAll" and ev.Event.Timing == "Up" then -- Timing needs to be up to avoid the hotbar from being opened afterwards.
            UI.LootAll()
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

    UI.NavigationComponents.Root = root
end)

-- Show the navigation bar when the UI is opened
-- and reset foci.
UI.Events.Opened:Subscribe(function (_)
    ---@cast UI +Features.NavigationBar.UI
    Navbar.Setup(UI, Vector.Create(0, -150)) -- Show navbar.
    UI.NavigationComponents.Root:FocusByIndex(1) -- Default the focus to the item list.
end)
