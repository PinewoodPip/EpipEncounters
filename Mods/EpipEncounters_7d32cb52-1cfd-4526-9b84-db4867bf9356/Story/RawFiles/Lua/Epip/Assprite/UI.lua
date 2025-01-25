
local Generic = Client.UI.Generic
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local ImagePrefab = Generic.GetPrefab("GenericUI.Prefabs.Image")
local DraggingArea = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local TooltipPanel = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local CommonStrings = Text.CommonStrings
local Input = Client.Input
local V = Vector.Create

---@class Features.Assprite
local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.UI : GenericUI_Instance
local UI = Generic.Create("Features.Assprite.UI")
Assprite.UI = UI

UI.PANEL_SIZE = V(700, 700)
UI.PICKER_IMAGE_SIZE = V(64, 64)
UI.HEADER_SIZE = V(200, 50)
UI.SIDEBAR_WIDTH = 250
UI.SETTINGS_SIZE = V(UI.SIDEBAR_WIDTH, 50)
UI.TOOLBAR_COLUMNS = 3

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

---Initializes the static elements of the UI.
---@param img ImageLib_Image Initial image to display.
function UI._Initialize(img)
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    local panel = TooltipPanel.Create(UI, "Background", root, UI.PANEL_SIZE, Assprite.TranslatedStrings.Assprite:Format({Size = 24}), UI.HEADER_SIZE):GetRootElement()

    -- Dragging area
    DraggingArea.Create(UI, "DraggingArea", panel, V(UI.PANEL_SIZE[1], UI.HEADER_SIZE[2]))

    -- Content container
    local contentArea = panel:AddChild("ContentContainer", "GenericUI_Element_TiledBackground")
    contentArea:SetAlpha(0)
    contentArea:SetBackground("Black", UI.PANEL_SIZE[1] - 40, UI.PANEL_SIZE[2] - UI.HEADER_SIZE[2])
    contentArea:SetPositionRelativeToParent("Top", 0, UI.HEADER_SIZE[2] + 30)

    -- Close button
    local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", panel)
    closeButton:SetPositionRelativeToParent("TopRight")
    closeButton.Events.Pressed:Subscribe(function (_)
        -- TODO confirm to close
        Assprite.CompleteRequest()
    end)

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

    -- Side panel
    local sidePanel = contentArea:AddChild("SidePanel", "GenericUI_Element_VerticalList")

    -- Toolbar
    local toolBar = sidePanel:AddChild("ToolbarContainer", "GenericUI_Element_VerticalList")
    local _ = TextPrefab.Create(UI, "ToolbarHeader", toolBar, CommonStrings.Tools, "Center", V(UI.SIDEBAR_WIDTH, 35)) -- Header
    local toolbarGrid = toolBar:AddChild("ToolbarGrid", "GenericUI_Element_Grid")
    toolbarGrid:SetGridSize(UI.TOOLBAR_COLUMNS, -1)

    -- Render tools
    local tools = {Assprite:GetClass("Features.Assprite.Tools.Brush")} -- TODO extract
    for _,tool in ipairs(tools) do
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
    local _ = SettingWidgets.RenderSetting(UI, globalSettingsList, Settings.Color, UI.SETTINGS_SIZE, function (value)
        Assprite.SetColor(value)
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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the UI when image editing is requested.
Assprite.Events.EditorRequested:Subscribe(function (ev)
    UI.Setup(ev)
end)

-- Quick debug snippet to open the UI on load. TODO remove
GameState.Events.ClientReady:Subscribe(function ()
    local img = Client.Image.GetDecoder("ImageLib_Decoder_PNG"):Create("test_rgb_64x.png")
    Assprite.RequestEditor("Debug", img:Decode())
    Assprite.SetColor(Color.Create(120, 120, 30))
end, {EnabledFunctor = function ()
    return Epip.IsDeveloperMode(true)
end})
