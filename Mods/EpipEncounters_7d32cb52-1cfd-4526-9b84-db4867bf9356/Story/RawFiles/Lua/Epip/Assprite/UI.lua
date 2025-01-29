
local Generic = Client.UI.Generic
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
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
local V = Vector.Create

---@class Features.Assprite
local Assprite = Epip.GetFeature("Features.Assprite")
local TSK = Assprite.TranslatedStrings

---@class Features.Assprite.UI : GenericUI_Instance
local UI = Generic.Create("Features.Assprite.UI")
Assprite.UI = UI

UI.PANEL_SIZE = V(700, 700)
UI.PICKER_IMAGE_SIZE = V(64, 64)
UI.HEADER_SIZE = V(200, 50)
UI.SIDEBAR_WIDTH = 250
UI.SETTINGS_SIZE = V(UI.SIDEBAR_WIDTH, 50)
UI.TOOLBAR_COLUMNS = 3
---@type Features.Assprite.Tool[] Tools in order of appearance in the toolbar.
UI.TOOLS = {
    Assprite:GetClass("Features.Assprite.Tools.Brush"),
    Assprite:GetClass("Features.Assprite.Tools.ColorPicker"),
    Assprite:GetClass("Features.Assprite.Tools.Bucket"),
}

UI._CurrentTool = nil ---@type Features.Assprite.Tool?

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
    Assprite.SetColor(Settings.Color:GetValue())
    UI:SetPositionRelativeToViewport("center", "center")
    UI:Show()
end

---Sets the image being edited.
---@param img ImageLib_Image
function UI._SetImage(img)
    UI.Canvas:SetImage(img)
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
    -- TODO check if a tool is being used first?
    UI._CurrentTool = tool
end

---Requests an image to be loaded from disk.
function UI.RequestLoad()
    MessageBox.Open({
        ID = "Features.Assprite.UI.Load",
        Header = CommonStrings.Load:GetString(),
        Message = TSK.MsgBox_Load_Body:GetString(),
        Type = "Input",
    })
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
    closeButton:SetPositionRelativeToParent("TopRight")
    closeButton.Events.Pressed:Subscribe(function (_)
        -- TODO confirm to close
        Assprite.CompleteRequest()
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
        ContextMenu.Setup({
            menu = {
                id = "main",
                entries = {
                    {id = "Features.Assprite.UI.Undo", type = "button", text = TSK.Label_Undo:GetString(), disabled = not canUndo, selectable = canUndo, faded = not canUndo},
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
    UI.Canvas = canvas

    -- Dummy element to have hover events be more reliable (which they aren't while the underlying Image prefab elements are being recreated)
    local canvasClickArea = canvas.Root:AddChild("CanvasClickArea", "GenericUI_Element_TiledBackground")
    canvasClickArea:SetBackground("Black", 260, 260)
    canvasClickArea:SetAlpha(0.2)
    canvasClickArea:SetMouseMoveEventEnabled(true)
    -- Update cursor while moving mouse over the click area
    canvasClickArea.Events.MouseMove:Subscribe(function (_)
        local pos = canvasClickArea:GetMousePosition()
        pos[1], pos[2] = pos[1] / canvas:GetWidth(), pos[2] / canvas:GetHeight()
        pos[1], pos[2] = math.clamp(pos[1], 0, 1), math.clamp(pos[2], 0, 1)
        local image = Assprite.GetImage()
        local pixelPos = V(math.ceil(pos[2] * image.Height), math.ceil(pos[1] * image.Width)) -- Convert x & y to row & column coordinates.
        Assprite.SetCursor(pixelPos)
    end)
    canvas:SetPositionRelativeToParent("TopLeft")

    -- Stop using the tool when M1 is released.
    -- This must be done via an input listener as MouseUp events are not reliable when elements are being recreated under the cursor, as is the case when the image is re-rendered. This also covers the key being released while the mouse is not over the element anymore.
    Input.Events.KeyReleased:Subscribe(function (ev)
        if ev.InputID == "left2" and Assprite.GetActiveTool() ~= nil then
            Assprite.EndToolUse()
        end
    end)

    -- Undo button
    local undoButton = ButtonPrefab.Create(UI, "UndoButton", contentArea, ButtonPrefab.STYLES.SmallRed)
    undoButton:SetLabel(TSK.Label_Undo)
    undoButton:Move(0, canvas:GetHeight())
    -- Disable button if no more snapshots remain.
    undoButton.Events.Pressed:Subscribe(function (_)
        Assprite.Undo()
        undoButton:SetEnabled(Assprite.CanUndo())
    end)
    -- Enable button when snapshots are added.
    Assprite.Events.ToolUseStarted:Subscribe(function (_)
        undoButton:SetEnabled(Assprite.CanUndo())
    end)

    -- Side panel
    local sidePanel = contentArea:AddChild("SidePanel", "GenericUI_Element_VerticalList")

    -- Toolbar
    local toolBar = sidePanel:AddChild("ToolbarContainer", "GenericUI_Element_VerticalList")
    local _ = TextPrefab.Create(UI, "ToolbarHeader", toolBar, CommonStrings.Tools, "Center", V(UI.SIDEBAR_WIDTH, 35)) -- Header
    local toolbarGrid = toolBar:AddChild("ToolbarGrid", "GenericUI_Element_Grid")
    toolbarGrid:SetGridSize(UI.TOOLBAR_COLUMNS, -1)

    -- Render tools
    for _,tool in ipairs(UI.TOOLS) do
        local toolButton = ButtonPrefab.Create(UI, "Tool." .. tool:GetClassName(), toolbarGrid, ButtonPrefab.STYLES.TabCharacterSheet)
        toolButton:SetIcon(tool.ICON, V(32, 32))
        toolButton:SetTooltip("Simple", tool.Name:GetString())
        toolButton.Events.Pressed:Subscribe(function (_)
            UI.SelectTool(tool)
        end)
    end
    toolbarGrid:RepositionElements()
    UI.ToolGrid = toolbarGrid

    -- Global settings
    local globalSettingsList = sidePanel:AddChild("GlobalSettings", "GenericUI_Element_VerticalList")

    -- Selected color
    local colorWidget = SettingWidgets.RenderSetting(UI, globalSettingsList, Settings.Color, UI.SETTINGS_SIZE, function (value)
        Assprite.SetColor(value)
    end) ---@cast colorWidget GenericUI.Prefab.Form.Color
    -- Synchronize the setting value with the context color
    Assprite.Events.ColorChanged:Subscribe(function (ev)
        colorWidget:SetColor(ev.Context.Color)
    end)

    -- Update the image when it is edited.
    Assprite.Events.ImageChanged:Subscribe(function (ev)
        UI._SetImage(ev.Context.Image)
    end)

    globalSettingsList:RepositionElements()
    sidePanel:RepositionElements()
    sidePanel:SetPositionRelativeToParent("TopRight")

    -- Setup UIObject panel size
    UI:GetUI().SysPanelSize = UI.PANEL_SIZE

    UI._Initialized = true
end

---@override
function UI:Hide()
    Assprite.CancelRequest()
    Client.UI._BaseUITable.Hide(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the UI when image editing is requested.
Assprite.Events.EditorRequested:Subscribe(function (ev)
    UI.Setup(ev)
end)

-- Handle context menus interactions.
ContextMenu.RegisterElementListener("Features.Assprite.UI.Load", "buttonPressed", function ()
    UI.RequestLoad()
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.Exit", "buttonPressed", function ()
    MessageBox.Open({
        ID = "Features.Assprite.UI.Exit",
        Header = TSK.MsgBox_Exit_Header:GetString(),
        Message = TSK.MsgBox_Exit_Body:GetString(),
        Buttons = {
            {ID = 1, Text = CommonStrings.Exit:GetString()},
            {ID = 2, Text = CommonStrings.Cancel:GetString()},
        }
    })
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.Undo", "buttonPressed", function ()
    Assprite.Undo()
end)
ContextMenu.RegisterElementListener("Features.Assprite.UI.About", "buttonPressed", function ()
    MessageBox.Open({
        Header = TSK.Assprite:GetString(),
        Message = TSK.MsgBox_About_Body:GetString(),
    })
end)

-- Handle load prompts.
MessageBox.RegisterMessageListener("Features.Assprite.UI.Load", MessageBox.Events.InputSubmitted, function (path, _, _)
    local img = nil ---@type ImageLib_Image?
    local success, trace = pcall(function ()
        local decoder = ImageLib.GetDecoder("ImageLib_Decoder_PNG"):Create(path .. ".png")
        img = decoder:Decode()
    end)
    if success then
        Assprite.SetImage(img)
        Notification.ShowNotification(TSK.Notification_Load_Success:GetString())
    else
        Notification.ShowWarning(TSK.Notification_Load_Error:GetString())
        Assprite:__LogWarning("Failed to load image", trace)
    end
end)
-- Handle "Exit" message box.
MessageBox.RegisterMessageListener("Features.Assprite.UI.Exit", MessageBox.Events.ButtonPressed, function(buttonID)
    if buttonID == 1 then
        UI:Hide()
    end
end)

-- Quick debug snippet to open the UI on load. TODO remove
GameState.Events.ClientReady:Subscribe(function ()
    local img = Client.Image.GetDecoder("ImageLib_Decoder_PNG"):Create("test_rgb_64x.png")
    Assprite.RequestEditor("Debug", img:Decode())
    Assprite.SetColor(Color.Create(120, 120, 30))
end, {EnabledFunctor = function ()
    return Epip.IsDeveloperMode(true)
end})
