
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local SlicedTexturePrefab = Generic.GetPrefab("GenericUI.Prefabs.SlicedTexture")
local PanelSelect = Client.UI.Controller.PanelSelect
local GameMenu = Client.UI.GameMenu
local Tooltip = Client.Tooltip
local Input = Client.Input
local V = Vector.Create

---@class Features.RadialMenus
local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local RadialMenuPrefab = RadialMenus:GetClass("Features.RadialMenus.Prefabs.RadialMenu")
local TSK = RadialMenus.TranslatedStrings
local UI = Generic.Create("Features.RadialMenus", {Layer = 7, Visible = false}) ---@class Features.RadialMenus.UI : GenericUI_Instance
UI.HEADER_SIZE = V(200, 30)
UI.EDIT_SLOT_LABEL_SIZE = V(400, 30)
UI.OPEN_TWEEN_DURATION = 0.15 -- In seconds.
UI.OPEN_TWEEN_STARTING_SCALE = 0.4
UI.OPEN_TWEEN_STARTING_ALPHA = 0.2
UI.SOUNDS = {
    TOGGLE = "UI_Game_Journal_Close",
    CYCLE = "UI_Game_PartyFormation_Drop",
}
UI.PREVIEW_WIDGET_SPACING = 40
UI.CONTROLLER_STICK_SELECT_THRESHOLD = 0.3 -- In fraction of distance from center.
UI._CurrentMenuIndex = 1
UI._CurrentMenu = nil ---@type Features.RadialMenus.Prefabs.RadialMenu?
UI._NeedsResize = false

RadialMenus:RegisterInputAction("OpenRadialMenu", {
    Name = TSK.InputAction_Open_Name,
    Description = TSK.InputAction_Open_Description,
})
RadialMenus:RegisterInputAction("PreviousMenu", {
    Name = TSK.InputAction_PreviousMenu_Name,
    Description = TSK.InputAction_PreviousMenu_Description,
    DefaultInput1 = {Keys = {"wheel_yneg"}}
})
RadialMenus:RegisterInputAction("NextMenu", {
    Name = TSK.InputAction_NextMenu_Name,
    Description = TSK.InputAction_NextMenu_Description,
    DefaultInput1 = {Keys = {"wheel_ypos"}}
})

---@class Features.RadialMenus.UI.Events : GenericUI.Instance.Events
UI.Events = UI.Events
UI.Events.Initialized = UI:AddSubscribableEvent("Initialized") ---@type Event<Empty>
UI.Events.Opened = UI:AddSubscribableEvent("Opened") ---@type Event<Empty>
UI.Events.NewMenuRequested = UI:AddSubscribableEvent("NewMenuRequested") ---@type Event<Empty>
UI.Events.EditMenuRequested = UI:AddSubscribableEvent("EditMenuRequested") ---@type Event<{Menu:Features.RadialMenus.Menu}>
UI.Events.EditSlotRequested = UI:AddSubscribableEvent("EditSlotRequested") ---@type Event<Features.RadialMenus.UI.Events.SlotEvent>
UI.Events.SlotSelected = UI:AddSubscribableEvent("SlotSelected") ---@type Event<Features.RadialMenus.UI.Events.SlotEvent>
UI.Events.MenuChanged = UI:AddSubscribableEvent("MenuChanged") ---@type Event<{Menu:Features.RadialMenus.Menu}>

RadialMenus.UI = UI

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.RadialMenus.UI.Events.SlotEvent
---@field Menu Features.RadialMenus.Menu
---@field Slot Features.RadialMenus.Slot
---@field Index integer

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI.
function UI.Setup()
    UI._Initialize()

    -- Update panel size if the UI is dirty.
    -- Should be done before any positioning operations.
    if UI._NeedsResize then
        UI._ResizePanel()
    end

    UI.Refresh()
    UI._AnimateMainMenu()

    Client.UI.Input.SetMouseWheelBlocked(true) -- Prevent the default cycler bindings (mouse wheel) from altering camera zoom.

    -- Make the UI modal on controllers to block character and camera movement with sticks.
    -- Needs to be re-set on each open as the creator UI modifies it.
    if Client.IsUsingController() then
        UI:GetUI().OF_PlayerModal1 = true
    end

    UI:Show()
    UI:PlaySound(UI.SOUNDS.TOGGLE)
    UI.Events.Opened:Throw()
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
    local headerLabel = menu and menu.Name or TSK.Label_RadialMenus
    header:SetText(headerLabel)
    header:SetPositionRelativeToParent("Center")
    UI.EditMenuButton:SetVisible(menu ~= nil)
    UI.EditSlotHintLabel:SetPositionRelativeToParent("Top", 0, 100)
    UI.EditSlotHintLabel:SetVisible(menu and menu:GetClassName() == "Features.RadialMenus.Menu.Custom" and Client.IsUsingKeyboardAndMouse() or false) -- TODO use a better check, per-slot
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
    local noMenusLabel = TextPrefab.Create(UI, "NoMenusLabel", root, TSK.Label_NoMenus, "Center", V(500, 50))
    UI.NoMenusLabel = noMenusLabel

    -- Create top buttons & labels bar
    local topBar = SlicedTexturePrefab.Create(UI, "TopBar", root, SlicedTexturePrefab.STYLES.SimpleTooltip, V(500, 75))
    UI.TopBar = topBar

    -- Edit button
    local editButton = ButtonPrefab.Create(UI, "EditMenuButton", topBar:GetRootElement(), ButtonPrefab.STYLES.EditGreen)
    editButton:SetPositionRelativeToParent("Left", 20, 0)
    editButton.Events.Pressed:Subscribe(function (_)
        UI.EditCurrentMenu()
    end)
    UI.EditMenuButton = editButton

    local header = TextPrefab.Create(UI, "Header", topBar:GetRootElement(), "", "Center", UI.HEADER_SIZE)
    UI.Header = header

    local newMenuButton = ButtonPrefab.Create(UI, "NewMenuButton", topBar:GetRootElement(), ButtonPrefab.STYLES.DOS1IncrementLarge)
    newMenuButton:SetPositionRelativeToParent("Right", -20, 0)
    newMenuButton.Events.Pressed:Subscribe(function (_)
        UI.RequestNewMenu()
    end)
    UI.NewMenuButton = newMenuButton

    local buttonsBar = root:AddChild("ButtonList", "GenericUI_Element_HorizontalList")
    buttonsBar:RepositionElements()
    buttonsBar:SetPositionRelativeToParent("Bottom")

    local editSlotLabel = TextPrefab.Create(UI, "EditSlotLabel", root, TSK.Label_EditSlotHint, "Center", UI.EDIT_SLOT_LABEL_SIZE)
    UI.EditSlotHintLabel = editSlotLabel

    UI._ResizePanel()

    UI._Initialized = true
    UI.Events.Initialized:Throw()
end

---Switches to a neighbour menu.
---@param offset integer Index offset.
---@param canWrap boolean? Defaults to `false`.
function UI.ScrollMenus(offset, canWrap)
    local menusCount = #RadialMenus:GetMenus()
    local newIndex = UI._CurrentMenuIndex
    if canWrap then
        newIndex = math.indexmodulo(UI._CurrentMenuIndex + offset, menusCount)
    else
        local unclampedNewIndex = UI._CurrentMenuIndex + offset
        if unclampedNewIndex >= 1 and unclampedNewIndex <= menusCount then
            newIndex = unclampedNewIndex
        end
    end
    if UI:IsVisible() and newIndex ~= UI._CurrentMenuIndex then
        UI._CurrentMenuIndex = newIndex
        UI:PlaySound(UI.SOUNDS.CYCLE)
        UI.Refresh()
        UI.Events.MenuChanged:Throw({
            Menu = UI._GetCurrentMenu(),
        })
    end
end

---Returns the currently-selected slot, if any.
---@return Features.RadialMenus.Slot?, integer? -- Slot, index.
function UI.GetSelectedSlot()
    local menu = UI._CurrentMenu
    local slot, index = nil, nil
    if menu then
        slot, index = menu:GetSelectedSlot()
    end
    return slot, index
end

---Attempts to use a slot.
---@param slot Features.RadialMenus.Slot? Defaults to currently-selected slot.
function UI.InteractWithSlot(slot)
    if UI._TweeningMainMenu then return end -- Do nothing while the UI is being opened.
    local menu = UI._GetCurrentMenu()
    slot = slot or UI.GetSelectedSlot()
    if slot then
        if slot.Type == "Empty" and menu:IsSlotEditable(slot) then -- Edit empty slots.
            UI.RequestEditSlot(table.reverseLookup(menu:GetSlots(), slot))
        else -- Otherwise use the slot.
            UI:TryHide() -- Needs to be done first for input actions to work, as they are not normally executable in modal UIs (which the radial menu is when using a controller)
            RadialMenus.UseSlot(Client.GetCharacter(), slot)
        end
    end
end

---Returns the current menu.
---@return Features.RadialMenus.Menu?
function UI._GetCurrentMenu()
    local menus = RadialMenus.GetMenus()
    UI._CurrentMenuIndex = math.clamp(UI._CurrentMenuIndex, 1, #menus)
    return menus[UI._CurrentMenuIndex]
end

---Opens the edit UI for the current menu, if any.
function UI.EditCurrentMenu()
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
            UI.InteractWithSlot(slot)
        end)
        -- Handle requests to edit slots
        instance.Events.SegmentRightClicked:Subscribe(function (ev)
            menu = UI._CurrentMenu:GetMenu()
            UI.RequestEditSlot(ev.Index)
        end)

        UI._CurrentMenu = instance

        -- Forward slot selection events.
        instance.Events.SegmentSelected:Subscribe(function (ev)
            UI.Events.SlotSelected:Throw({
                Menu = UI._GetCurrentMenu(),
                Slot = UI.GetSelectedSlot(),
                Index = ev.Index
            })
        end)
    end
    instance:SetMenu(menu)
    UI.Header:SetText(menu.Name)
end

---Requests to edit a slot from the current menu.
---@param index integer
function UI.RequestEditSlot(index)
    if UI.CanEditSlot(index) then
        local menu = UI._GetCurrentMenu()
        local slots = menu:GetSlots()
        local slot = slots[index]
        UI.Events.EditSlotRequested:Throw({
            Menu = menu,
            Index = index,
            Slot = slot,
        })
    end
end

---Returns whether a slot of the current menu can be edited.
---@param index integer
---@return boolean
function UI.CanEditSlot(index)
    local menu = UI._GetCurrentMenu()
    local canEdit = menu and RadialMenus.CanEditSlot(menu, index) or false
    return canEdit
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
    if UI._CurrentMenu then -- Toggle visibility of the menu if it has been initialized
        UI._CurrentMenu:SetVisible(menu ~= nil)
    end
end

---Animates the main menu opening with a tween.
function UI._AnimateMainMenu()
    local menu = UI._CurrentMenu
    if menu then
        menu:Tween({
            EventID = "Opening",
            StartingValues = {
                scaleX = UI.OPEN_TWEEN_STARTING_SCALE,
                scaleY = UI.OPEN_TWEEN_STARTING_SCALE,
                alpha = UI.OPEN_TWEEN_STARTING_ALPHA,
            },
            FinalValues = {
                scaleX = 1,
                scaleY = 1,
                alpha = 1,
            },
            Function = "Cubic",
            Ease = "EaseIn",
            Duration = UI.OPEN_TWEEN_DURATION,
            OnComplete = function (_)
                UI._TweeningMainMenu = false
            end
        })
        UI._TweeningMainMenu = true
    end
    -- For preview widgets, animate only alpha
    local previewWidgets = table.pack(UI._LeftMenuPreview, UI._RightMenuPreview)
    for i=1,previewWidgets.n,1 do
        local widget = previewWidgets[i]
        if widget then
            widget:Tween({
                EventID = "Opening",
                StartingValues = {
                    alpha = UI.OPEN_TWEEN_STARTING_ALPHA,
                },
                FinalValues = {
                    alpha = 1,
                },
                Function = "Cubic",
                Ease = "EaseIn",
                Duration = UI.OPEN_TWEEN_DURATION,
            })
        end
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
    root:SetBackground("Black", panelSize:unpack())
    UI._RepositionMenus()
    topBar:SetPositionRelativeToParent("Top", 0, 20)
    UI:SetPositionRelativeToViewport("topleft", "topleft")
    UI.NoMenusLabel:SetPositionRelativeToParent("Center")
    UI._NeedsResize = false
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
            leftPreview:SetPosition(panelSize[1] / 2 - currentMenuWidth - leftPreview:GetScaledRadius() - UI.PREVIEW_WIDGET_SPACING, panelSize[2] / 2)
            UI._PositionPreviewClickbox(UI._LeftMenuPreviewClickbox, leftPreview)
        end
        if rightPreview then
            rightPreview:SetPosition(panelSize[1] / 2 + currentMenuWidth + rightPreview:GetScaledRadius() + UI.PREVIEW_WIDGET_SPACING, panelSize[2] / 2)
            UI._PositionPreviewClickbox(UI._RightMenuPreviewClickbox, rightPreview)
        end
    end
end

---Repositions a clickbox for a preview widget.
---@param clickbox GenericUI_Element
---@param previewWidget Features.RadialMenus.Prefabs.RadialMenu
function UI._PositionPreviewClickbox(clickbox, previewWidget)
    local clickAreaX, clickAreaY = previewWidget:GetPosition()
    local widgetRadius = previewWidget:GetScaledRadius()
    clickAreaX, clickAreaY = clickAreaX - widgetRadius, clickAreaY - widgetRadius
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
    local diameter = previewWidget:GetScaledRadius() * 2
    clickArea:SetBackground("Black", diameter, diameter)
    clickArea:SetAlpha(0)

    -- Add highlight for visual feedback on hover
    clickArea.Events.MouseOver:Subscribe(function (_)
        local graphics = clickArea:GetMovieClip().graphics
        local w, h = clickArea:GetSize():unpack()
        graphics.clear()
        graphics.beginFill(Color.CreateFromHex(Color.LARIAN.GRAY):ToDecimal(), 0.4)
        graphics.drawCircle(w / 2, h / 2, w / 2) -- Draw from center (coincides with preview widget center)
    end)
    clickArea.Events.MouseOut:Subscribe(function (_)
        local graphics = clickArea:GetMovieClip().graphics
        graphics.clear()
    end)

    return clickArea
end

---@override
function UI:Hide()
    if UI._CurrentMenu then
        UI._CurrentMenu:DeselectSegment()
    end
    Client.UI._BaseUITable.Hide(UI)
    Client.UI.Input.SetMouseWheelBlocked(false) -- Unblock mouse wheel.
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

-- Scroll menus when the actions are used.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == RadialMenus.InputActions.NextMenu.ID then
        UI.ScrollMenus(1)
    elseif ev.Action.ID == RadialMenus.InputActions.PreviousMenu.ID then
        UI.ScrollMenus(-1)
    end
end, {EnabledFunctor = function ()
    return UI:IsVisible()
end})
Input.Hooks.CanExecuteAction:Subscribe(function (ev)
    -- Only consume cycler input actions when the UI is visible.
    if ev.Action.ID == RadialMenus.InputActions.NextMenu.ID or ev.Action.ID == RadialMenus.InputActions.PreviousMenu.ID then
        ev.CanExecute = ev.CanExecute and UI:IsVisible() and not RadialMenus.MenuCreatorUI:IsVisible() -- The creator UI must also be closed. It cannot be made modal as that interferes with the skill picker.
    elseif ev.Action.ID == RadialMenus.InputActions.OpenRadialMenu.ID then
        ev.CanExecute = ev.CanExecute and not RadialMenus.MenuCreatorUI:IsVisible() -- Disallow this input while editing menus/slots.
    end
end)

-- Resize the panel when viewport changes.
Client.Events.ViewportChanged:Subscribe(function (_)
    if UI._Initialized then
        UI._ResizePanel()
    end
end)

-- Open the menu when the controller bottom face button is pressed
-- while in the vanilla radial menu.
Input.Events.KeyReleased:Subscribe(function (ev)
    if ev.InputID == "controller_a" and PanelSelect:IsVisible() then -- This input can only happen when a controller is used, so an explicit controller check is unnecessary. 
        UI.Setup()
        PanelSelect:Hide()
    end
end)

-- Select segments of the menu
-- while using the left or right sticks on a controller.
Input.Events.StickMoved:Subscribe(function (ev)
    local direction = V(table.unpack(ev.NewState))
    if Vector.GetLength(direction) >= UI.CONTROLLER_STICK_SELECT_THRESHOLD and not RadialMenus.MenuCreatorUI:IsVisible() then -- Consider a deadzone and do not select anything on the wheel while the creator is open.
        local menuWidget = UI._CurrentMenu
        local menu = menuWidget:GetMenu()
        local slotsAmount = #menu:GetSlots()
        local anglePerSlot = (2 * math.pi) / slotsAmount
        local firstSegmentStart = V(0, -1) -- Top of the stick is (0, -1)
        firstSegmentStart = Vector.Rotate(firstSegmentStart, -math.deg(anglePerSlot / 2)) -- But the first segment's left boundary does not necessarily start at (0, -1)
        local angle = Vector.Angle(direction, firstSegmentStart)

        -- Determine if the stick is on the other side of the wheel (past the 180 deg point) to calculate the 360 angle
        local crossProd = firstSegmentStart[1] * direction[2] - firstSegmentStart[2] * direction[1]
        if crossProd < 0 then
            angle = math.rad(360) - angle
        end
        local fraction = angle / (2 * math.pi)
        local slotIndex = math.floor(slotsAmount * fraction) + 1
        slotIndex = math.clamp(slotIndex, 1, slotsAmount)
        menuWidget:SelectSegment(slotIndex)
    end
end, {EnabledFunctor = function ()
    return UI:IsVisible() and UI._GetCurrentMenu() ~= nil
end})

-- Hide any old tooltip when selected slot changes.
UI.Events.SlotSelected:Subscribe(function (_)
    Tooltip.HideTooltip()
end, {StringID = "DefaultImplementation.HideOldTooltip"})

-- Show skill tooltips for Skill slots.
UI.Events.SlotSelected:Subscribe(function (ev)
    local slot = ev.Slot
    if slot.Type == "Skill" then
        ---@cast slot Features.RadialMenus.Slot.Skill
        local slotCount = #ev.Menu:GetSlots()
        local isOnLeftHalf = ev.Index > slotCount // 2
        local radialMenuPos = UI._CurrentMenu:GetScreenPosition()
        local radialMenuRadius = UI._CurrentMenu:GetScaledRadius()

        -- Show tooltips on the side of the selected slot, with a bit of extra margin.
        local posOffset = (isOnLeftHalf and V(-radialMenuRadius - 430, -radialMenuRadius) or V(radialMenuRadius + 20, -radialMenuRadius))
        posOffset = posOffset * UI:GetScaleMultiplier()
        local tooltipPos = radialMenuPos + posOffset
        Tooltip.ShowSkillTooltip(Client.GetCharacter(), slot.SkillID, tooltipPos)
    end
end, {StringID = "DefaultImplementation.SkillTooltips"})

-- Hide tooltips when menu changes.
UI.Events.MenuChanged:Subscribe(function (_)
    Tooltip.HideTooltip()
end)

-- Unpausing the game screws with the flash size override for some reason,
-- thus we must mark the UI as dirty in this regard.
GameMenu.Events.Opened:Subscribe(function (_)
    UI._NeedsResize = true
end)
