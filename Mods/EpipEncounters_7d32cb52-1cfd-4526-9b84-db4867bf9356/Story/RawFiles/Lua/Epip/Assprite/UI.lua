
local Generic = Client.UI.Generic
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local ColorPicker = Epip.GetFeature("Features.ColorPicker")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local ImagePrefab = Generic.GetPrefab("GenericUI.Prefabs.Image")
local DraggingArea = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local TooltipPanel = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local Notification = Client.UI.Notification
local ContextMenu = Client.UI.ContextMenu
local MessageBox = Client.UI.MessageBox
local ImageLib = Client.Image
local Input = Client.Input
local CommonStrings = Text.CommonStrings
local SettingsLib = Settings
local V = Vector.Create

---@class Features.Assprite
local Assprite = Epip.GetFeature("Features.Assprite")
local TSK = Assprite.TranslatedStrings
local tools = {
    Brush = Assprite:GetClass("Features.Assprite.Tools.Brush"),
    ColorPicker = Assprite:GetClass("Features.Assprite.Tools.ColorPicker"),
    Bucket = Assprite:GetClass("Features.Assprite.Tools.Bucket"),
    Blur = Assprite:GetClass("Features.Assprite.Tools.Blur"),
    Noise = Assprite:GetClass("Features.Assprite.Tools.Noise"),
}

---@class Features.Assprite.UI : GenericUI_Instance
local UI = Generic.Create("Features.Assprite.UI")
Assprite.UI = UI

UI.PANEL_SIZE = V(850, 800)
UI.HEADER_SIZE = V(200, 50)
UI.SIDEBAR_WIDTH = 375
UI.SETTINGS_SIZE = V(UI.SIDEBAR_WIDTH, 50)
UI.TOOLBAR_COLUMNS = 8
UI.STATUS_BAR_LABEL_SIZE = V(100, 50)
---@type Features.Assprite.Tool[] Tools in order of appearance in the toolbar.
UI.TOOLS = {
    tools.Brush,
    tools.ColorPicker,
    tools.Bucket,
    tools.Blur,
    tools.Noise,
}
UI.DEFAULT_TOOL = Assprite:GetClass("Features.Assprite.Tools.Brush")

---@type GenericUI_Prefab_Button_Style
UI.TOOL_BUTTON_ACTIVE_STYLE = table.shallowCopy(ButtonPrefab.STYLES.TabCharacterSheet)
-- Swap some textures around to create a cheap active button style
UI.TOOL_BUTTON_ACTIVE_STYLE.IdleTexture = UI.TOOL_BUTTON_ACTIVE_STYLE.HighlightedTexture

UI.Events.CursorUpdated = UI:AddSubscribableEvent("CursorUpdated") ---@type Event<{Pos: vec2}> -- Thrown when the cursor was repositioned and needs to be re-rendered.

UI._CurrentTool = nil ---@type Features.Assprite.Tool?
UI._CanvasHovered = false

local Settings = {
    Color =  Assprite:RegisterSetting("Color", {
        Type = "Color",
        Name = CommonStrings.Color,
        DefaultValue = Color.CreateFromHex(Color.WHITE),
    })
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI to handle an editing request.
---@param request Features.Assprite.Events.EditorRequested
function UI.Setup(request)
    UI._Initialize(request.Image)
    UI._SetImage(request.Image)

    -- Synchronize color in UI to the Assprite context
    Assprite.SetColor(Settings.Color:GetValue())

    -- Select default tool
    UI.SelectTool(UI.DEFAULT_TOOL)

    -- Update buttons
    UI.ConfirmButton:SetVisible(request.ConfirmLabel ~= nil)
    if request.ConfirmLabel then
        UI.ConfirmButton:SetLabel(Text.Resolve(request.ConfirmLabel))
    end
    UI.UndoButton:SetEnabled(Assprite.CanUndo())
    UI.RedoButton:SetEnabled(Assprite.CanRedo())

    UI:SetPositionRelativeToViewport("center", "center")
    UI:Show()
end

---Updates the canvas image being edited.
---@param img ImageLib_Image? Defaults to refreshing the current image.
function UI._SetImage(img)
    img = img or Assprite.GetImage()
    local acceleration = Assprite.Settings.HardwareAcceleration:GetValue()
    local hardwareCanvas = UI.AcceleratedCanvas
    local canvas = UI.Canvas

    -- Update the current canvas
    if acceleration then
        local char = Client.GetCharacter()
        local currentPortrait = Ext.Entity.GetPortrait(char.Handle)
        local imgDDS = Image.ToDDS(img)

        Ext.Entity.SetPortrait(char.Handle, img.Width, img.Height, imgDDS)

        ---@diagnostic disable-next-line: invisible TODO! Need to access the container as graphics stretches the element width/height
        UI:GetUI():SetCustomPortraitIcon("HardwareAcceleratedCanvas", char.Handle, math.ceil(canvas._ImageContainer:GetWidth()) + 4, math.ceil(canvas._ImageContainer:GetHeight()) + 4) -- Extra size to fit the canvas better and align with cursors
        Ext.Entity.SetPortrait(char.Handle, 80, 100, currentPortrait) -- TODO fetch previous width/height
    else
        canvas:SetImage(img)
    end

    hardwareCanvas:SetVisible(acceleration)
end

---Applies the current tool's effects, if a tool is selected.
function UI.UseCurrentTool()
    if UI._CurrentTool then
        Assprite.BeginToolUse(UI._CurrentTool)
    end
end

---Sets the active tool.
---@param tool Features.Assprite.Tool
function UI.SelectTool(tool)
    -- Deactivate the button of previous tool
    if UI._CurrentTool then
        local toolElement = UI.ToolButtons[UI._CurrentTool:GetClassName()]
        toolElement:SetActivated(false)
    end

    UI._CurrentTool = tool

    -- Activate button of the new tool
    local toolElement = UI.ToolButtons[tool:GetClassName()]
    toolElement:SetActivated(true)

    -- Update label
    UI.ToolLabel:SetText(Text.Resolve(tool.Name))

    UI._UpdateToolSettings()
end

---Completes the current request and closes the UI.
function UI.CompleteRequest()
    Assprite.CompleteRequest()
    UI:Hide()
end

---Requests an image to be saved to disk.
function UI.RequestSave()
    MessageBox.Open({
        ID = "Features.Assprite.UI.Save",
        Header = CommonStrings.Save:GetString(),
        Message = TSK.MsgBox_Save_Body:GetString(),
        Type = "Input",
        Buttons = {
            {ID = 1, Type = "Yes", Text = CommonStrings.Accept:GetString()}
        },
    })
end

---Requests an image to be loaded from disk.
function UI.RequestLoad()
    MessageBox.Open({
        ID = "Features.Assprite.UI.Load",
        Header = CommonStrings.Load:GetString(),
        Message = TSK.MsgBox_Load_Body:GetString(),
        Type = "Input",
        Buttons = {
            {ID = 1, Type = "Yes", Text = CommonStrings.Accept:GetString()}
        },
    })
end

---Prompts the user to confirm closing the UI.
function UI.RequestExit()
    MessageBox.Open({
        ID = "Features.Assprite.UI.Exit",
        Header = TSK.MsgBox_Exit_Header:GetString(),
        Message = TSK.MsgBox_Exit_Body:GetString(),
        Buttons = {
            {ID = 1, Text = CommonStrings.Exit:GetString()},
            {ID = 2, Text = CommonStrings.Cancel:GetString()},
        }
    })
end

---Re-renders the tool settings list.
function UI._UpdateToolSettings()
    local toolSettingList = UI.ToolSettingsList

    toolSettingList:Clear()

    -- Render tool-specific settings
    local tool = UI._CurrentTool
    if tool then
        local toolSettings = tool:GetSettings()
        for _,setting in ipairs(toolSettings) do
            SettingWidgets.RenderSetting(UI, toolSettingList, setting, UI.SETTINGS_SIZE)
        end
    end

    toolSettingList:RepositionElements()
end

---Initializes the static elements of the UI.
---@param img ImageLib_Image Initial image to display.
function UI._Initialize(img)
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    local panel = TooltipPanel.Create(UI, "Background", root, UI.PANEL_SIZE, Assprite.TranslatedStrings.Assprite:Format({Size = 24}), UI.HEADER_SIZE):GetRootElement()

    -- Dragging area
    DraggingArea.Create(UI, "DraggingArea", panel, V(UI.PANEL_SIZE[1], UI.HEADER_SIZE[2]))

    -- Close button
    local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", panel)
    closeButton:SetPositionRelativeToParent("TopRight", -10, 10)
    closeButton.Events.Pressed:Subscribe(function (_)
        UI.RequestExit()
    end)
    closeButton.Hooks.CanClose:Subscribe(function (ev)
        ev.CanClose = false -- Closing is handled by prompt instead.
    end)

    -- Top buttons bar
    local topBar = panel:AddChild("TopBar", "GenericUI_Element_HorizontalList")
    topBar:SetPositionRelativeToParent("TopLeft", 20, UI.HEADER_SIZE[2] + 30)
    topBar:SetElementSpacing(0)

    -- "File" button
    local fileButton = ButtonPrefab.Create(UI, "TopButton.File", topBar, ButtonPrefab.STYLES.BrownSimple_Inactive)
    fileButton:SetLabel(TSK.Label_File)
    -- Open context menu on click
    fileButton.Events.Pressed:Subscribe(function (_)
        local x, y = fileButton:GetScreenPosition(true):unpack()
        y = y + fileButton:GetHeight()
        ContextMenu.RequestMenu(x, y, "Features.Assprite.UI.File")
    end)
    ContextMenu.RegisterMenuHandler("Features.Assprite.UI.File", function()
        ContextMenu.Setup({
            menu = {
                id = "main",
                entries = {
                    {id = "Features.Assprite.UI.Save", type = "button", text = CommonStrings.Save:GetString()},
                    {id = "Features.Assprite.UI.Load", type = "button", text = CommonStrings.Load:GetString()},
                    {id = "Features.Assprite.UI.Exit", type = "button", text = CommonStrings.Exit:GetString()},
                }
            }
        })
        ContextMenu.Open()
    end)
    -- "Edit" button
    local editButton = ButtonPrefab.Create(UI, "TopButton.Edit", topBar, ButtonPrefab.STYLES.BrownSimple_Inactive)
    editButton:SetLabel(CommonStrings.Edit)
    -- Open context menu on click
    editButton.Events.Pressed:Subscribe(function (_)
        local x, y = editButton:GetScreenPosition(true):unpack()
        y = y + editButton:GetHeight()
        ContextMenu.RequestMenu(x, y, "Features.Assprite.UI.Edit")
    end)
    ContextMenu.RegisterMenuHandler("Features.Assprite.UI.Edit", function()
        local canUndo = Assprite.CanUndo()
        local undoKeybind = Input.GetActionBindings(Assprite.InputActions.Undo.ID)
        local undoKeybindLabel = undoKeybind[1] and string.format(" (%s)", Input.StringifyBinding(undoKeybind[1], true)) or ""
        local undoLabel = string.format("%s%s", TSK.Label_Undo:GetString(), undoKeybindLabel)

        local canRedo = Assprite.CanRedo()
        local redoKeybind = Input.GetActionBindings(Assprite.InputActions.Redo.ID)
        local redoKeybindLabel = redoKeybind[1] and string.format(" (%s)", Input.StringifyBinding(redoKeybind[1], true)) or ""
        local redoLabel = string.format("%s%s", TSK.Label_Redo:GetString(), redoKeybindLabel)

        ContextMenu.Setup({
            menu = {
                id = "main",
                entries = {
                    {id = "Features.Assprite.UI.Undo", type = "button", text = undoLabel, disabled = not canUndo, selectable = canUndo, faded = not canUndo},
                    {id = "Features.Assprite.UI.Redo", type = "button", text = redoLabel, disabled = not canRedo, selectable = canRedo, faded = not canRedo},
                }
            }
        })
        ContextMenu.Open()
    end)
    -- "Settings" button
    local settingsButton = ButtonPrefab.Create(UI, "TopButton.Settings", topBar, ButtonPrefab.STYLES.BrownSimple_Inactive)
    settingsButton:SetLabel(CommonStrings.Settings)
    -- Open context menu on click
    settingsButton.Events.Pressed:Subscribe(function (_)
        local x, y = settingsButton:GetScreenPosition(true):unpack()
        y = y + settingsButton:GetHeight()
        ContextMenu.RequestMenu(x, y, "Features.Assprite.UI.Settings")
    end)
    ContextMenu.RegisterMenuHandler("Features.Assprite.UI.Settings", function()
        local hardwareAcceleration = Assprite.Settings.HardwareAcceleration:GetValue()
        ContextMenu.Setup({
            menu = {
                id = "main",
                entries = {
                    {id = "Features.Assprite.UI.HardwareAcceleration", type = "button", text = TSK.Label_HardwareAcceleration:Format(hardwareAcceleration and CommonStrings.On:GetString() or CommonStrings.Off:GetString())},
                }
            }
        })
        ContextMenu.Open()
    end)
    -- "Help" button
    local helpButton = ButtonPrefab.Create(UI, "TopButton.Help", topBar, ButtonPrefab.STYLES.BrownSimple_Inactive)
    helpButton:SetLabel(CommonStrings.Help)
    -- Open context menu on click
    helpButton.Events.Pressed:Subscribe(function (_)
        local x, y = helpButton:GetScreenPosition(true):unpack()
        y = y + helpButton:GetHeight()
        ContextMenu.RequestMenu(x, y, "Features.Assprite.UI.Help")
    end)
    ContextMenu.RegisterMenuHandler("Features.Assprite.UI.Help", function()
        ContextMenu.Setup({
            menu = {
                id = "main",
                entries = {
                    {id = "Features.Assprite.UI.About", type = "button", text = CommonStrings.About:GetString()},
                }
            }
        })
        ContextMenu.Open()
    end)

    topBar:RepositionElements()
    UI.TopBar = topBar

    -- Content container
    local contentArea = panel:AddChild("ContentContainer", "GenericUI_Element_TiledBackground")
    contentArea:SetAlpha(0)
    contentArea:SetBackground("Black", UI.PANEL_SIZE[1] - 40, UI.PANEL_SIZE[2] - UI.HEADER_SIZE[2])
    contentArea:SetPositionRelativeToParent("Top", 0, UI.HEADER_SIZE[2] + 30 + topBar:GetHeight())

    -- Canvas
    local canvas = ImagePrefab.Create(UI, "CanvasImage", contentArea, img)
    canvas:SetMouseMoveEventEnabled(true)
    -- Activate tool when clicking on the canvas
    canvas.Root.Events.MouseDown:Subscribe(function (_)
        UI.UseCurrentTool()
    end)
    -- Update cursor while moving mouse over the canvas
    canvas.Root.Events.MouseMove:Subscribe(function (_)
        local pos = canvas.Root:GetMousePosition()
        pos[1], pos[2] = pos[1] / canvas:GetWidth(), pos[2] / canvas:GetHeight()
        pos[1], pos[2] = math.clamp(pos[1], 0, 1), math.clamp(pos[2], 0, 1)
        local image = Assprite.GetImage()
        local pixelPos = V(math.ceil(pos[2] * image.Height), math.ceil(pos[1] * image.Width)) -- Convert x & y to row & column coordinates.
        Assprite.SetCursor(pixelPos)
        UI._CanvasHovered = true
    end)
    canvas.Root.Events.MouseOut:Subscribe(function (_)
        UI._CanvasHovered = false

        -- Hide cursor and update status bar label
        UI._UpdateCursorLabel()
        UI.Cursor:SetVisible(false)
    end)
    canvas:SetPositionRelativeToParent("TopLeft")
    UI.Canvas = canvas

    -- Hardware-accelerated canvas
    local acceleratedCanvas = canvas:AddChild("HardwareAcceleratedCanvasIcon", "GenericUI_Element_Empty")
    acceleratedCanvas:SetMouseEnabled(false)
    acceleratedCanvas:GetMovieClip().name = "iggy_HardwareAcceleratedCanvas"
    UI.AcceleratedCanvas = acceleratedCanvas

    -- Cursor; graphics-driven
    local cursor = canvas:AddChild("CanvasCursor", "GenericUI_Element_Empty")
    cursor:SetMouseEnabled(false)
    Assprite.Events.CursorPositionChanged:Subscribe(function (ev)
        local i, j = ev.Context.CursorPos:unpack()
        local canvasSize = canvas:GetSize()
        local contextImg = ev.Context.Image

        cursor:SetPosition(j / contextImg.Width * canvasSize[1], i / contextImg.Height * canvasSize[2])
        cursor:SetVisible(true)

        -- Throw hook to repaint cursor graphics
        UI.Events.CursorUpdated:Throw({
            pos = ev.Context.CursorPos,
        })
    end)
    UI.Cursor = cursor

    -- Stop using the tool when M1 is released.
    -- This must be done via an input listener as MouseUp events are not reliable when elements are being recreated under the cursor, as is the case when the image is re-rendered. This also covers the key being released while the mouse is not over the element anymore.
    Input.Events.KeyReleased:Subscribe(function (ev)
        if ev.InputID == "left2" and Assprite.GetActiveTool() ~= nil then
            Assprite.EndToolUse()
        end
    end)

    -- Status bar
    local statusBar = contentArea:AddChild("StatusBarList", "GenericUI_Element_HorizontalList")
    statusBar:Move(0, canvas:GetHeight())
    UI.StatusBarList = statusBar

    -- Cursor position label
    local cursorPosLabel = TextPrefab.Create(UI, "StatusBarCursorPosLabel", statusBar, "", "Center", UI.STATUS_BAR_LABEL_SIZE)
    -- Update label when cursor is changed
    Assprite.Events.CursorPositionChanged:Subscribe(function (_)
        UI._UpdateCursorLabel()
    end)
    UI.CursorPosLabel = cursorPosLabel

    -- Undo button
    local undoButton = ButtonPrefab.Create(UI, "UndoButton", statusBar, ButtonPrefab.STYLES.SmallRed)
    undoButton:SetLabel(TSK.Label_Undo)
    -- Disable button if no more snapshots remain.
    undoButton.Events.Pressed:Subscribe(function (_)
        Assprite.Undo()
        undoButton:SetEnabled(Assprite.CanUndo())
    end)
    -- Enable button when snapshots are added.
    Assprite.Events.ImageChanged:Subscribe(function (_)
        undoButton:SetEnabled(Assprite.CanUndo())
    end)
    UI.UndoButton = undoButton

    -- Redo button
    local redoButton = ButtonPrefab.Create(UI, "RedoButton", statusBar, ButtonPrefab.STYLES.SmallRed)
    redoButton:SetLabel(TSK.Label_Redo)
    redoButton.Events.Pressed:Subscribe(function (_)
        Assprite.Redo()
        redoButton:SetEnabled(Assprite.CanRedo())
    end)
    Assprite.Events.ImageChanged:Subscribe(function (_)
        redoButton:SetEnabled(Assprite.CanRedo())
    end)
    UI.RedoButton = redoButton

    statusBar:RepositionElements()

    -- Confirm button; only visible when opening Assprite for a particular purpose
    local confirmButton = ButtonPrefab.Create(UI, "ConfirmButton", panel, ButtonPrefab.STYLES.GreenMedium)
    confirmButton:SetPositionRelativeToParent("Bottom", 0, -65)
    confirmButton:SetVisible(false)
    confirmButton.Events.Pressed:Subscribe(function (_)
        UI.CompleteRequest()
    end)
    UI.ConfirmButton = confirmButton

    -- Side panel
    local sidePanel = contentArea:AddChild("SidePanel", "GenericUI_Element_VerticalList")

    -- Toolbar
    local toolBar = sidePanel:AddChild("ToolbarContainer", "GenericUI_Element_VerticalList")
    local _ = TextPrefab.Create(UI, "ToolbarHeader", toolBar, CommonStrings.Tools, "Center", V(UI.SIDEBAR_WIDTH, 35)) -- Header
    local toolbarGrid = toolBar:AddChild("ToolbarGrid", "GenericUI_Element_Grid")
    toolbarGrid:SetGridSize(UI.TOOLBAR_COLUMNS, -1)

    -- Render tools
    local toolButtons = {} ---@type table<classname, GenericUI_Prefab_Button>
    for _,tool in ipairs(UI.TOOLS) do
        local toolButton = ButtonPrefab.Create(UI, "Tool." .. tool:GetClassName(), toolbarGrid, ButtonPrefab.STYLES.TabCharacterSheet)
        local toolKeybind = tool:GetKeybind()
        toolButton:SetActiveStyle(UI.TOOL_BUTTON_ACTIVE_STYLE)
        toolButton:SetIcon(tool.ICON, V(32, 32))
        toolButton:SetTooltip("Custom", {
            ID = string.format("Assprite.UI.Tool.%s", tool:GetClassName()),
            Elements = {
                {
                    Type = "ItemName",
                    Label = Text.Resolve(tool.Name),
                },
                {
                    Type = "ItemDescription",
                    Label = Text.Resolve(tool.Description),
                },
                {
                    Type = "ItemRarity",
                    Label = Text.Format(toolKeybind and CommonStrings.KeybindHint:Format(Input.StringifyBinding(toolKeybind)) or "", {
                        Color = Color.LARIAN.GRAY
                    }),
                },
            },
        })
        toolButton.Events.Pressed:Subscribe(function (_)
            UI.SelectTool(tool)
        end)
        toolButtons[tool:GetClassName()] = toolButton
    end
    toolbarGrid:RepositionElements()
    UI.ToolGrid = toolbarGrid
    UI.ToolButtons = toolButtons

    -- Tool label
    local toolLabel = TextPrefab.Create(UI, "ToolLabel", sidePanel, "", "Center", V(UI.SETTINGS_SIZE[1], 30))
    UI.ToolLabel = toolLabel

    -- Tool settings
    local toolSettingsList = sidePanel:AddChild("ToolSettingsList", "GenericUI_Element_VerticalList")
    UI.ToolSettingsList = toolSettingsList

    sidePanel:RepositionElements()
    sidePanel:SetPositionRelativeToParent("TopRight")

    -- Update the image when it is edited.
    Assprite.Events.ImageChanged:Subscribe(function (ev)
        UI._SetImage(ev.Context.Image)
    end)

    -- Setup UIObject panel size
    UI:GetUI().SysPanelSize = UI.PANEL_SIZE

    UI._Initialized = true
end

---Updates the cursor label in the status bar.
function UI._UpdateCursorLabel()
    local label = UI.CursorPosLabel
    local context = Assprite.GetContext()
    local pos = context.CursorPos
    if UI._CanvasHovered then
        label:SetText(string.format("(%d, %d)", pos:unpack()))
    else
        label:SetText("")
    end
end

---@override
function UI:Hide()
    if Assprite.IsEditing() then
        Assprite.CancelRequest()
    end
    Client.UI._BaseUITable.Hide(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the UI when image editing is requested.
Assprite.Events.EditorRequested:Subscribe(function (ev)
    UI.Setup(ev)
end)

-- Re-render the cursor when its position changes based on the current tool.
UI.Events.CursorUpdated:Subscribe(function (_)
    local cursor = UI.Cursor
    local context = Assprite.GetContext()
    local graphics = cursor:GetMovieClip().graphics
    local color = Assprite.GetContext().Color
    local tool = UI._CurrentTool
    local toolClass = tool:GetClassName()

    -- Some tools may use a contrasting color versus the pixel underneath the cursor
    local pixel = context.Image:GetPixel(context.CursorPos)
    local _, _, value = pixel:ToHSV()
    local contrastingColor = value >= ColorPicker.UI.CROSSHAIR_INVERT_COLOR_THRESHOLD and Color.CreateFromHex(Color.BLACK) or Color.CreateFromHex(Color.WHITE)

    -- Determine flash graphics params to use
    local size = 1 ---@type number In canvas pixels.
    local pixelSize = 6 ---@type number Rough size of a canvas pixel in flash graphics space.
    local shape = "rect" ---@type "rect"|"circle"
    local opacity = 1
    if toolClass == tools.Brush:GetClassName() then
        size = tools.Brush.Settings.Size:GetValue()
        shape = tools.Brush.Settings.Shape:GetValue()

        -- Set shape
        local SHAPES = tools.Brush.SHAPES
        if shape == SHAPES.SQUARE then
            shape = "rect"
        elseif shape == SHAPES.ROUND then
            shape = "circle"
        end
    elseif toolClass == tools.ColorPicker:GetClassName() then
        opacity = 0.3
        color = contrastingColor
    elseif toolClass == tools.Bucket:GetClassName() then
        -- Pass.
    elseif toolClass == tools.Blur:GetClassName() then
        size = tools.Blur.Settings.AreaOfEffectSize:GetValue() + 2
        opacity = 0.2
        shape = "circle"
        color = contrastingColor
    elseif toolClass == tools.Noise:GetClassName() then
        size = tools.Noise.Settings.AreaOfEffectSize:GetValue() + 2
        opacity = 0.2
        shape = "circle"
        color = contrastingColor
    end

    -- Repaint cursor
    graphics.clear()
    graphics.beginFill(color:ToDecimal(), opacity)
    if shape == "rect" then
        pixelSize = size * 6
        graphics.drawRect(-pixelSize/2, -pixelSize/2, pixelSize, pixelSize)
    elseif shape == "circle" then
        pixelSize = size * 3
        graphics.drawCircle(0, 0, pixelSize)
    end
end, {StringID = "DefaultImplementation"})

-- Synchronize the setting value with the context color
local ignoreColorEvent = false -- Necessary to avoid an infinite loop due to the "two-way data binding".
SettingsLib.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting == Settings.Color then
        ignoreColorEvent = true
        Assprite.SetColor(ev.Value)
        ignoreColorEvent = false
    end
end, {EnabledFunctor = function ()
    return not ignoreColorEvent
end})
Assprite.Events.ColorChanged:Subscribe(function (ev)
    ignoreColorEvent = true
    Settings.Color:SetValue(ev.Context.Color)
    ignoreColorEvent = false
    UI._UpdateToolSettings() -- Necessary for the setting widget to update.
end, {EnabledFunctor = function ()
    return not ignoreColorEvent
end})

-- Handle context menus interactions.
ContextMenu.RegisterElementListener("Features.Assprite.UI.Save", "buttonPressed", function ()
    UI.RequestSave()
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.Load", "buttonPressed", function ()
    UI.RequestLoad()
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.Exit", "buttonPressed", function ()
    UI.RequestExit()
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.Undo", "buttonPressed", function ()
    Assprite.Undo()
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.Redo", "buttonPressed", function ()
    Assprite.Redo()
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.HardwareAcceleration", "buttonPressed", function ()
    local accelerated = Assprite.Settings.HardwareAcceleration:GetValue()
    if accelerated then
        Assprite.Settings.HardwareAcceleration:SetValue(false)
        UI._SetImage()
    else
        MessageBox.Open({
            ID = "Features.Assprite.UI.HardwareAcceleration",
            Header = Assprite.Settings.HardwareAcceleration:GetName(),
            Message = TSK.MsgBox_HardwareAcceleration_Body:GetString(),
            Buttons = {
                {ID = 1, Type = "Yes", Text = CommonStrings.Enable:GetString()},
                {ID = 2, Text = CommonStrings.Cancel:GetString()},
            },
        })

    end
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.About", "buttonPressed", function ()
    MessageBox.Open({
        Header = TSK.Assprite:GetString(),
        Message = TSK.MsgBox_About_Body:GetString(),
    })
end)

-- Handle save prompts.
MessageBox.RegisterMessageListener("Features.Assprite.UI.Save", MessageBox.Events.InputSubmitted, function (path, _, _)
    local img = Assprite.GetImage()
    local data = Image.ToDDS(img)
    IO.SaveFile(path .. ".dds", data, true)
    Notification.ShowNotification(TSK.Notification_Save_Success:GetString())
end)
-- Handle load prompts.
MessageBox.RegisterMessageListener("Features.Assprite.UI.Load", MessageBox.Events.InputSubmitted, function (path, _, _)
    local success, failureMsg = true, nil ---@type TextLib.String
    local img = nil ---@type ImageLib_Image?

    -- Check either file exists
    local pngPath = path .. ".png"
    local ddsPath = path .. ".dds"
    local pngContents = IO.LoadFile(pngPath, "user", true)
    local ddsContents = IO.LoadFile(ddsPath, "user", true)
    if not pngContents and not ddsContents then
        success, failureMsg = false, TSK.Notification_Load_Error_FileDoesntExist:Format(path, path)
    end

    if not failureMsg then
        -- Parse image
        success, failureMsg = pcall(function ()
            local decoder = pngContents and ImageLib.GetDecoder("ImageLib_Decoder_PNG") or ImageLib.GetDecoder("ImageLib.Decoders.DDS")
            local decoderIntance = decoder:Create(pngContents and pngPath or ddsPath)
            img = decoderIntance:Decode()
        end)
    end

    -- Set image, which may fail for user-defined reasons
    if success then
        success, failureMsg = Assprite.SetImage(img)
    end

    -- Notify success/failure
    if success then
        Notification.ShowNotification(TSK.Notification_Load_Success:GetString())
    else
        Notification.ShowWarning(TSK.Notification_Load_Error:Format(Text.Resolve(failureMsg)))
        Assprite:__LogWarning("Failed to load image", failureMsg)
    end
end)
-- Handle "Exit" message box.
MessageBox.RegisterMessageListener("Features.Assprite.UI.Exit", MessageBox.Events.ButtonPressed, function(buttonID)
    if buttonID == 1 then
        UI:Hide()
    end
end)
-- Handle hardware acceleration toggle prompts.
MessageBox.RegisterMessageListener("Features.Assprite.UI.HardwareAcceleration", MessageBox.Events.ButtonPressed, function(buttonID)
    if buttonID == 1 then
        Assprite.Settings.HardwareAcceleration:SetValue(true)
        UI._SetImage()
    end
end)
