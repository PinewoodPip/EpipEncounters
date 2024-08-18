
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local GenericComponent = Navigation:GetClass("GenericUI.Navigation.Components.Generic")
local Navbar = Epip.GetFeature("Features.NavigationBar")
local CommonStrings = Text.CommonStrings
local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local TSK = RadialMenus.TranslatedStrings
local UI = RadialMenus.UI ---@cast UI +GenericUI.Navigation.UI

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create navigation controller when the UI is initialized.
UI.Events.Initialized:Subscribe(function (_)
    -- This UI is an unusual case;
    -- there's not really elements to move between.
    -- We handle the input events directly from 1 node instead.
    local root = GenericComponent:Create(UI.Root)
    root:AddAction({
        ID = "PreviousMenu",
        Name = TSK.Label_PreviousMenu,
        Inputs = {["UITabPrev"] = true},
    })
    root:AddAction({
        ID = "NextMenu",
        Name = TSK.Label_NextMenu,
        Inputs = {["UITabNext"] = true},
    })
    root:AddAction({
        ID = "EditMenu",
        Name = TSK.Label_EditMenu,
        Inputs = {["UITakeAll"] = true},
    })
    root:AddAction({
        ID = "NewMenu",
        Name = TSK.Label_NewMenu,
        Inputs = {["UISetSlot"] = true},
    })
    root:AddAction({
        ID = "Close",
        Name = CommonStrings.Close,
        Inputs = {["UIBack"] = true},
    })
    -- Rename interact action, make it only usable when there is a slot selected
    local interactAction = root:GetAction("Interact")
    interactAction.Name = CommonStrings.Use
    interactAction.IsConsumableFunctor = function (_)
        return UI.GetSelectedSlot() ~= nil
    end
    root.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Event.Timing == "Down" then
            if ev.Action.ID == "PreviousMenu" then
                UI.ScrollMenus(-1)
                ev.Consumed = true
            elseif ev.Action.ID == "NextMenu" then
                UI.ScrollMenus(1)
                ev.Consumed = true
            elseif ev.Action.ID == "Interact" then
                UI.InteractWithSlot()
                ev.Consumed = true
            elseif ev.Action.ID == "Close" then
                UI:Hide()
                ev.Consumed = true
            end
        elseif ev.Event.Timing == "Up" then -- Some of these events used are only fired by the game for "Up".
            if ev.Action.ID == "NewMenu" then
                UI.RequestNewMenu()
                ev.Consumed = true
            elseif ev.Action.ID == "EditMenu" then
                UI.EditCurrentMenu()
                ev.Consumed = true
            end
        end
    end)

    Controller.Create(UI, root)
end)

-- Show the navbar when the UI is opened.
UI.Events.Opened:Subscribe(function (_)
    Navbar.Setup(UI)
end)
