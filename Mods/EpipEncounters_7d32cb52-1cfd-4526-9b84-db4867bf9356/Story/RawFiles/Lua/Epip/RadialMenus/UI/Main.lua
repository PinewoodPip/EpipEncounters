
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local Input = Client.Input
local V = Vector.Create

---@class Features.RadialMenus
local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local RadialMenuPrefab = RadialMenus:GetClass("Features.RadialMenus.Prefabs.RadialMenu")
local TSK = RadialMenus.TranslatedStrings
local UI = Generic.Create("Features.RadialMenus") ---@class Features.RadialMenus.UI : GenericUI_Instance
UI.PANEL_SIZE = V(1200, 925)
UI.HEADER_SIZE = V(200, 30)
UI._CurrentMenuIndex = 1
UI._CurrentMenu = nil ---@type Features.RadialMenus.Prefabs.RadialMenu?

RadialMenus:RegisterInputAction("OpenRadialMenu", {
    Name = TSK.InputAction_Open_Name,
    Description = TSK.InputAction_Open_Description,
})

---@class Features.RadialMenus.UI.Events : GenericUI.Instance.Events
UI.Events = UI.Events
UI.Events.NewMenuRequested = UI:AddSubscribableEvent("NewMenuRequested") ---@type Event<Empty>
UI.Events.EditMenuRequested = UI:AddSubscribableEvent("EditMenuRequested") ---@type Event<{Menu:Features.RadialMenus.Menu}>
UI.Events.EditSlotRequested = UI:AddSubscribableEvent("EditSlotRequested") ---@type Event<{Menu:Features.RadialMenus.Menu, Index:integer, Slot:Features.RadialMenus.Slot}>

RadialMenus.UI = UI

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI.
function UI.Setup()
    UI._Initialize()
    UI.Refresh()
    UI._AnimateMainMenu()

    -- Position the UI
    UI:SetPositionRelativeToViewport("center", "center")
    UI:Move(V(0, -60))

    UI:Show()
end

---Sets the current active menu.
---@param menu Features.RadialMenus.Menu
function UI.SetCurrentMenu(menu)
    local index = table.reverseLookup(RadialMenus.GetMenus(), menu)
    if not index then UI:__Error("SetCurrentMenu", "Menu is not registered") end

    UI._CurrentMenuIndex = index

    if UI:IsVisible() then
        UI.Refresh()
    end
end

---Re-renders the current menu.
function UI.Refresh()
    UI._RenderCurrentMenu()
    UI._UpdateTopBar()
    UI.NoMenusLabel:SetVisible(UI._GetCurrentMenu() == nil)
end

---Updates the elements of the top bar.
function UI._UpdateTopBar()
    local header = UI.Header
    local menu = UI._GetCurrentMenu()
    if menu then
        header:SetText(menu.Name)
    end
    UI.EditMenuButton:SetVisible(menu ~= nil)
end

---Requests a new menu to be created.
---See `NewMenuRequested` event.
function UI.RequestNewMenu()
    UI.Events.NewMenuRequested:Throw()
end

---Initializes the static elements of the UI.
function UI._Initialize()
    if UI._Initialized then return end

    local uiObj = UI:GetUI()
    uiObj.SysPanelSize = {UI.PANEL_SIZE[1], UI.PANEL_SIZE[2]}

    local root = UI:CreateElement("Root", "GenericUI_Element_TiledBackground")
    root:SetBackground("Black", UI.PANEL_SIZE:unpack())
    root:SetAlpha(0.5)
    UI.Root = root

    -- "No menus" hint
    local noMenusLabel = TextPrefab.Create(UI, "NoMenusLabel", UI.Root, TSK.Label_NoMenus, "Center", V(500, 50))
    noMenusLabel:SetPositionRelativeToParent("Center")
    UI.NoMenusLabel = noMenusLabel

    -- Create top buttons & labels bar
    local topBar = root:AddChild("TopBar", "GenericUI_Element_HorizontalList")
    UI.TopBar = topBar

    -- Edit button
    local editButton = ButtonPrefab.Create(UI, "EditMenuButton", topBar, ButtonPrefab:GetStyle("EditGreen"))
    editButton.Events.Pressed:Subscribe(function (_)
        UI._EditCurrentMenu()
    end)
    UI.EditMenuButton = editButton

    local header = TextPrefab.Create(UI, "Header", topBar, "", "Center", UI.HEADER_SIZE)
    UI.Header = header

    local newMenuButton = ButtonPrefab.Create(UI, "NewMenuButton", topBar, ButtonPrefab:GetStyle("DOS1IncrementLarge"))
    newMenuButton.Events.Pressed:Subscribe(function (_)
        UI.RequestNewMenu()
    end)
    UI.NewMenuButton = newMenuButton

    topBar:RepositionElements()
    topBar:SetPositionRelativeToParent("Top", 0, 5)

    local buttonsBar = root:AddChild("ButtonList", "GenericUI_Element_HorizontalList")
    -- newMenuButton:SetLabel(TSK.Label_NewMenu)
    buttonsBar:RepositionElements()
    buttonsBar:SetPositionRelativeToParent("Bottom")

    UI._Initialized = true
end

---Returns the current menu.
---@return Features.RadialMenus.Menu?
function UI._GetCurrentMenu()
    local menus = RadialMenus.GetMenus()
    UI._CurrentMenuIndex = math.clamp(UI._CurrentMenuIndex, 1, #menus)
    return menus[UI._CurrentMenuIndex]
end

---Opens the edit UI for the current menu, if any.
function UI._EditCurrentMenu()
    local menu = UI._GetCurrentMenu()
    if menu then
        UI.Events.EditMenuRequested:Throw({
            Menu = menu,
        })
    end
end

---Renders a menu.
---@param menu Features.RadialMenus.Menu
function UI._RenderMenu(menu)
    local slots = menu:GetSlots()
    local instance = UI._CurrentMenu
    if not UI._CurrentMenu then
        instance = RadialMenuPrefab.Create(UI, "CurrentMenu", UI.Root, {
            Menu = menu,
        })

        -- Center the menu;
        -- the menu is center-anchored, so SetPositionRelativeToParent() doesn't work.
        instance:Move(UI.PANEL_SIZE[1] / 2, UI.PANEL_SIZE[2] / 2)

        -- Use slots when they're interacted with and close the UI.
        instance.Events.SegmentClicked:Subscribe(function (ev)
            menu = UI._CurrentMenu:GetMenu()
            slots = menu:GetSlots() -- Must re-fetch slots, as they might've changed.
            local slot = slots[ev.Index]
            RadialMenus.UseSlot(Client.GetCharacter(), slot)
            UI:Hide()
        end)
        -- Handle requests to edit slots
        instance.Events.SegmentRightClicked:Subscribe(function (ev)
            menu = UI._CurrentMenu:GetMenu()
            -- Can only edit slots of custom menus
            if menu:GetClassName() == "Features.RadialMenus.Menu.Custom" then
                slots = menu:GetSlots() -- Must re-fetch slots, as they might've changed.
                local index = ev.Index
                local slot = slots[index]
                UI.Events.EditSlotRequested:Throw({
                    Menu = menu,
                    Index = index,
                    Slot = slot,
                })
            end
        end)
    end
    instance:SetMenu(menu)
    UI.Header:SetText(menu.Name)
    UI._CurrentMenu = instance
end

---Re-renders the current menu.
function UI._RenderCurrentMenu()
    local menu = UI._GetCurrentMenu()
    if menu then
        UI._RenderMenu(menu)
    end
end

---Animates the main menu opening with a tween.
function UI._AnimateMainMenu()
    local menu = UI._CurrentMenu
    if menu then
        menu:Tween({
            EventID = "Opening",
            StartingValues = {
                scaleX = 0.4,
                scaleY = 0.4,
                alpha = 0.2,
            },
            FinalValues = {
                scaleX = 1,
                scaleY = 1,
                alpha = 1,
            },
            Function = "Cubic",
            Ease = "EaseIn",
            Duration = 0.15,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Toggle the UI when the action is used.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == RadialMenus.InputActions.OpenRadialMenu.ID then
        if UI:IsVisible() then
            UI:Hide()
        else
            UI.Setup()
        end
    end
end)
