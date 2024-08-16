
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local Input = Client.Input
local V = Vector.Create

---@class Features.RadialMenus
local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local RadialMenuPrefab = RadialMenus:GetClass("Features.RadialMenus.Prefabs.RadialMenu")
local TSK = RadialMenus.TranslatedStrings
local UI = Generic.Create("Features.RadialMenus", 7) ---@class Features.RadialMenus.UI : GenericUI_Instance
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

    local root = UI:CreateElement("Root", "GenericUI_Element_TiledBackground")
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
    header:SetCenterInLists(true)
    UI.Header = header

    local newMenuButton = ButtonPrefab.Create(UI, "NewMenuButton", topBar, ButtonPrefab:GetStyle("DOS1IncrementLarge"))
    newMenuButton.Events.Pressed:Subscribe(function (_)
        UI.RequestNewMenu()
    end)
    UI.NewMenuButton = newMenuButton

    local buttonsBar = root:AddChild("ButtonList", "GenericUI_Element_HorizontalList")
    -- newMenuButton:SetLabel(TSK.Label_NewMenu)
    buttonsBar:RepositionElements()
    buttonsBar:SetPositionRelativeToParent("Bottom")

    topBar:RepositionElements()
    UI._ResizePanel()

    UI._Initialized = true
end

---Switches to a neighbour menu.
---@param offset integer Index offset.
function UI.ScrollMenus(offset)
    UI._CurrentMenuIndex = math.indexmodulo(UI._CurrentMenuIndex + offset, #RadialMenus:GetMenus())
    UI.Refresh()
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

        UI._CurrentMenu = instance
    end
    instance:SetMenu(menu)
    UI.Header:SetText(menu.Name)
end

---Renders the next/previous menus.
function UI._RenderAdjacentMenus()
    -- Fetch neighbour menus
    local menus = RadialMenus:GetMenus()
    local previousMenu, nextMenu = nil, nil
    if #menus == 2 then -- Do not show the other menu on both sides.
        if UI._CurrentMenuIndex == 1 then
            nextMenu = menus[2]
        else -- Current index 2.
            previousMenu = menus[1]
        end
    elseif #menus >= 3 then
        local previousMenuIndex, nextMenuIndex = math.indexmodulo(UI._CurrentMenuIndex - 1, #menus), math.indexmodulo(UI._CurrentMenuIndex + 1, #menus)
        previousMenu, nextMenu = menus[previousMenuIndex], menus[nextMenuIndex]
    end

    -- Initialize preview widgets
    local leftMenuInstance = UI._LeftMenuPreview
    if not leftMenuInstance then
        leftMenuInstance = UI._InitializePreviewWidget("LeftMenuPreview")
        UI._LeftMenuPreview = leftMenuInstance

        -- Setup click area
        local clickbox = UI._InitializeClickbox("LeftMenuPreviewClickbox", leftMenuInstance)
        UI._LeftMenuPreviewClickbox = clickbox

        -- Scroll menus when the area is clicked.
        clickbox.Events.MouseUp:Subscribe(function (_)
            UI.ScrollMenus(-1)
        end)
    end
    local rightMenuInstance = UI._RightMenuPreview
    if not rightMenuInstance then
        rightMenuInstance = UI._InitializePreviewWidget("RightMenuPreview")
        UI._RightMenuPreview = rightMenuInstance

        -- Setup click area
        local clickbox = UI._InitializeClickbox("RightMenuPreviewClickbox", rightMenuInstance)
        UI._RightMenuPreviewClickbox = clickbox

        -- Scroll menus when the area is clicked.
        clickbox.Events.MouseUp:Subscribe(function (_)
            UI.ScrollMenus(1)
        end)
    end

    -- Set preview widgets
    UI._UpdateMenuPreview(UI._LeftMenuPreview, UI._LeftMenuPreviewClickbox, previousMenu)
    UI._UpdateMenuPreview(UI._RightMenuPreview, UI._RightMenuPreviewClickbox, nextMenu)
end

---Updates a menu preview widget.
---@param previewInstance Features.RadialMenus.Prefabs.RadialMenu
---@param clickbox GenericUI_Element
---@param menu Features.RadialMenus.Menu
function UI._UpdateMenuPreview(previewInstance, clickbox, menu)
    previewInstance:SetVisible(menu ~= nil)
    clickbox:SetVisible(menu ~= nil)
    if menu then
        previewInstance:SetMenu(menu)
    end
end

---Re-renders the current menu.
function UI._RenderCurrentMenu()
    local menu = UI._GetCurrentMenu()
    if menu then
        UI._RenderMenu(menu)
        UI._RenderAdjacentMenus()
        UI._RepositionMenus()
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

---Returns the size of the panel.
---@return Vector2
function UI._GetPanelSize()
    local viewport = Client.GetViewportSize()
    local uiObj = UI:GetUI()
    local panelSize = Vector.ScalarProduct(viewport, 1 / uiObj:GetUIScaleMultiplier())
    return panelSize
end

---Resizes the panel and UI to take up the whole viewport.
function UI._ResizePanel()
    local panelSize = UI._GetPanelSize()
    local uiObj = UI:GetUI()
    local root = UI.Root
    local topBar = UI.TopBar
    uiObj.SysPanelSize = panelSize
    uiObj:Resize(panelSize[1], panelSize[2], uiObj:GetUIScaleMultiplier()) -- Necessary to avoid cropping on ultrawide resolutions. Resizing is done in flash space.
    root:SetBackground("Black", UI._GetPanelSize():unpack())
    UI._RepositionMenus()
    topBar:SetPositionRelativeToParent("Top", 0, 5)
    UI:SetPositionRelativeToViewport("topleft", "topleft")
end

---Repositions the menu widgets.
function UI._RepositionMenus()
    local panelSize = UI._GetPanelSize()
    local instance = UI._CurrentMenu
    if instance then
        -- Center the menu;
        -- the menu is center-anchored, so SetPositionRelativeToParent() doesn't work.
        instance:SetPosition(panelSize[1] / 2, panelSize[2] / 2)

        -- Position preview widgets
        local leftPreview, rightPreview = UI._LeftMenuPreview, UI._RightMenuPreview
        local currentMenuWidth = instance:GetScaledRadius()
        if leftPreview then
            leftPreview:SetPosition(panelSize[1] / 2 - currentMenuWidth - leftPreview:GetScaledRadius(), panelSize[2] / 2)
            UI._PositionPreviewClickbox(UI._LeftMenuPreviewClickbox, leftPreview)
        end
        if rightPreview then
            rightPreview:SetPosition(panelSize[1] / 2 + currentMenuWidth + rightPreview:GetScaledRadius(), panelSize[2] / 2)
            UI._PositionPreviewClickbox(UI._RightMenuPreviewClickbox, rightPreview)
        end
    end
end

---Repositions a clickbox for a preview widget.
---@param clickbox GenericUI_Element
---@param previewWidget Features.RadialMenus.Prefabs.RadialMenu
function UI._PositionPreviewClickbox(clickbox, previewWidget)
    local clickAreaX, clickAreaY = previewWidget:GetPosition()
    clickAreaX, clickAreaY = clickAreaX - previewWidget:GetWidth() / 2, clickAreaY - previewWidget:GetHeight() / 2
    clickbox:SetPosition(clickAreaX, clickAreaY)
end

---Initializes a menu preview widget.
---@param id string
---@return Features.RadialMenus.Prefabs.RadialMenu
function UI._InitializePreviewWidget(id)
    local instance = RadialMenuPrefab.Create(UI, id, UI.Root, {
        Menu = UI._GetCurrentMenu(), -- Temporarily initialize to current menu, to simplify handling initialization if there are no neighbours.
    })
    instance:SetScale(V(0.5, 0.5))
    instance:SetMouseChildren(false)
    return instance
end

---Initializes a clickbox for a menu preview widget.
---@param id string
---@param previewWidget Features.RadialMenus.Prefabs.RadialMenu
---@return GenericUI_Element
function UI._InitializeClickbox(id, previewWidget)
    local clickArea = UI.Root:AddChild(id, "GenericUI_Element_TiledBackground")
    clickArea:SetBackground("Black", previewWidget:GetSize():unpack())
    clickArea:SetAlpha(0)

    -- Add visual feedback on hover
    clickArea.Events.MouseOver:Subscribe(function (_)
        clickArea:SetAlpha(0.3)
    end)
    clickArea.Events.MouseOut:Subscribe(function (_)
        clickArea:SetAlpha(0)
    end)

    return clickArea
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

-- Resize the panel when viewport changes.
Client.Events.ViewportChanged:Subscribe(function (_)
    if UI._Initialized then
        UI._ResizePanel()
    end
end)
