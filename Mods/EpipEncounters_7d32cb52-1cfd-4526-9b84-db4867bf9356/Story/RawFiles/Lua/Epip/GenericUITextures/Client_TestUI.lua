
---------------------------------------------
-- Implements a UI that displays registered Generic textures,
-- useful for previewing them.
---------------------------------------------

local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")
local Generic = Client.UI.Generic
local Button = Generic.GetPrefab("GenericUI_Prefab_Button")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local SlicedTexture = Generic.GetPrefab("GenericUI.Prefabs.SlicedTexture")
local V = Vector.Create

---@class Feature_GenericUITextures
local GenericUITextures = Epip.GetFeature("Feature_GenericUITextures")
local Textures = GenericUITextures.TEXTURES

local UI = Generic.Create("StyleTest")
GenericUITextures.TestUI = UI

UI.CONTAINER_OFFSET = V(100, 150)
UI.SCROLLLIST_FRAME_SIZE = V(680, 800)
UI.IGGY_ICON_SIZE = V(40, 40)
UI.SLICED_TEXTURE_SIZE = V(200, 100)
UI._currentPanelIndex = 1

---------------------------------------------
-- SETTINGS, ACTIONS AND RESOURCES
---------------------------------------------

GenericUITextures.TranslatedStrings.Action_UI_Open_Name = GenericUITextures:RegisterTranslatedString("h8db61443g39bfg45f1g8c0cga6ab56bb12b7", {
    Text = "Open Generic UI Texture Test UI",
    ContextDescription = "Debug keybind",
})

GenericUITextures.InputActions.OpenTestUI = GenericUITextures:RegisterInputAction("OpenTestUI", {
    Name = GenericUITextures.TranslatedStrings.Action_UI_Open_Name:GetString(),
    DefaultInput1 = {Keys = {"lctrl", "l"}},
    DeveloperOnly = true,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function UI:Show()
    UI._Initialize()
    Client.UI._BaseUITable.Show(self)
end

---Initializes the elements of the UI.
function UI._Initialize()
    if UI._Initialized then return end
    local buttonStyle = Button.STYLES.SmallRed
    local bg = UI:CreateElement("Root", "GenericUI_Element_Texture")
    bg:SetTexture(Textures.PANELS.CLIPBOARD_LARGE)

    local header = TextPrefab.Create(UI, "Header", bg, Text.Format("Texture Test UI", {Color = Color.BLACK}), "Center", V(bg:GetWidth(), 50))
    header:SetPositionRelativeToParent("Top", 0, 70)

    local buttonList = bg:AddChild("RootButtonList", "GenericUI_Element_HorizontalList")
    buttonList:SetPositionRelativeToParent("TopLeft", 100, 100)

    UI.Background = bg

    UI._SetupButtonList()
    UI._SetupFrameList()
    UI._SetupInputIconList()
    UI._SetupIconList()
    UI._SetupSlicedTextureList()

    ---@type {Element:GenericUI_Element, Name:string}[]
    local buttons = {
        {
            Element = UI.ButtonList,
            Name = "Buttons",
        },
        {
            Element = UI.FrameList,
            Name = "Frames",
        },
        {
            Element = UI.InputIconsList,
            Name = "Input Icons",
        },
        {
            Element = UI.IconList,
            Name = "Icons",
        },
        {
            Element = UI.SlicedTexturesList,
            Name = "Sliced",
        },
    }

    for _,buttonData in ipairs(buttons) do
        local button = Button.Create(UI, "RootButton_" .. buttonData.Name, buttonList, buttonStyle)

        button:SetLabel(buttonData.Name, "Center")

        -- Toggle off previous container(s) and show new one when pressed
        button.Events.Pressed:Subscribe(function (_)
            for _,bData in ipairs(buttons) do
                bData.Element:SetVisible(false)
            end
            buttonData.Element:SetVisible(true)
        end)
    end

    -- Add button to cycle panels
    local panelButton = Button.Create(UI, "RootButton_Panel", buttonList, buttonStyle)
    panelButton:SetLabel("Panel")
    panelButton.Events.Pressed:Subscribe(function (_)
        local panels = {}
        local panelNames = {}
        for name,panel in pairs(Textures.PANELS) do
            table.insert(panels, panel)
            table.insert(panelNames, name)
        end

        UI._currentPanelIndex = UI._currentPanelIndex + 1
        if UI._currentPanelIndex > #panels then
            UI._currentPanelIndex = 1
        end

        bg:SetTexture(panels[UI._currentPanelIndex])
        -- Show panel name and copy to clipboard
        print(panelNames[UI._currentPanelIndex])
        Client.CopyToClipboard(panelNames[UI._currentPanelIndex])
    end)

    UI:SetIggyEventCapture("UICancel", true)

    -- Close the UI through IggyEvents
    UI.Events.IggyEventUpCaptured:Subscribe(function (ev)
        if ev.EventID == "UICancel" then
            UI:SetIggyEventCapture("UICancel", false)
            UI:Hide()
        end
    end)
    UI._Initialized = true
end

function UI._SetupFrameList()
    local frameList = UI._SetupScrollList("FrameList")

    local frameTextures = UI._FindTexturesRecursively(Textures.FRAMES)
    for _,texture in ipairs(frameTextures) do
        local element = frameList:AddChild(texture.GUID, "GenericUI_Element_Texture")
        element:SetTexture(texture)

        -- Show texture name and GUID on click and copy to clipboard
        element.Events.MouseUp:Subscribe(function (_)
            print(texture.Name, texture.GUID)
            Client.CopyToClipboard(texture.Name)
        end)
    end

    UI.FrameList = frameList
    frameList:RepositionElements()
    frameList:SetVisible(false)
end

---Creates the list of input icons.
function UI._SetupInputIconList()
    local list = UI._SetupScrollList("InputIconsList")
    local textures = UI._FindTexturesRecursively(Textures.INPUT)
    UI._RenderTextures(list, textures)
    UI.InputIconsList = list
end

---Creates the list of buttons.
function UI._SetupButtonList()
    local list = UI._SetupScrollList("ButtonList")
    local stateButtonStyles = DefaultTable.Create({}) ---@type table<string, {InactiveStyle: GenericUI_Prefab_Button_Style, ActiveStyle: GenericUI_Prefab_Button_Style}>

    local styles = {} ---@type GenericUI_I_Stylable_Style[]
    for id,style in pairs(Button:GetStyles()) do
        ---@cast style GenericUI_Prefab_Button_Style
        local activeStyleMatch = id:match("(.+)_Active$")
        local inactiveStyleMatch = id:match("(.+)_Inactive$")
        style.___ID = id

        if activeStyleMatch then
            stateButtonStyles[activeStyleMatch].ActiveStyle = style
        elseif inactiveStyleMatch then
            stateButtonStyles[inactiveStyleMatch].InactiveStyle = style
        else
            table.insert(styles, style)
        end
    end

    table.sortByProperty(styles, "___ID")

    for i,style in ipairs(styles) do
        ---@diagnostic disable: undefined-field
        local button = Button.Create(UI, style.___ID, list, style)

        button:SetLabel(tostring(i))
        button.Events.Pressed:Subscribe(function (_)
            print(style.___ID)
            Client.CopyToClipboard(style.___ID)
        end)
        ---@diagnostic enable: undefined-field
    end
    for id,styleSet in pairs(stateButtonStyles) do
        local button = Button.Create(UI, id, list, styleSet.InactiveStyle)

        button:SetActiveStyle(styleSet.ActiveStyle)
        button:SetLabel("")
    end

    UI.ButtonList = list
    list:RepositionElements()
    list:SetVisible(false)
end

---Creates the grid of IggyIcons.
function UI._SetupIconList()
    local bg = UI.Background
    local iconList = bg:AddChild("IconList", "GenericUI_Element_Grid")
    iconList:SetGridSize(10, -1)
    iconList:SetPositionRelativeToParent("TopLeft", UI.CONTAINER_OFFSET:unpack())

    local icons = UI._FindIconsRecursively(GenericUITextures.ICONS)
    for _,icon in ipairs(icons) do
        local element = iconList:AddChild(icon, "GenericUI_Element_IggyIcon")
        element:SetIcon(icon, UI.IGGY_ICON_SIZE:unpack())
        element.Events.MouseUp:Subscribe(function (_)
            Client.CopyToClipboard(icon)
        end)
    end

    UI.IconList = iconList
    iconList:RepositionElements()
    iconList:SetVisible(false)
end

---Creates the list of sliced textures.
function UI._SetupSlicedTextureList()
    local list = UI._SetupScrollList("SlicedTextures")

    for id,style in pairs(SlicedTexture:GetStyles()) do
        ---@cast style GenericUI.Prefabs.SlicedTexture.Style
        local instance = SlicedTexture.Create(UI, id, list, style, UI.SLICED_TEXTURE_SIZE)

        instance.Events.MouseUp:Subscribe(function (_)
            print(id)
            Client.CopyToClipboard(id)
        end)
    end

    UI.SlicedTexturesList = list
    list:RepositionElements()
end

---Initializes a scroll list.
---@param id string
---@return GenericUI_Element_ScrollList
function UI._SetupScrollList(id)
    local bg = UI.Background
    local list = bg:AddChild(id, "GenericUI_Element_ScrollList")
    list:SetFrame(UI.SCROLLLIST_FRAME_SIZE:unpack())
    list:SetMouseWheelEnabled(true)

    list:SetPositionRelativeToParent("TopLeft", UI.CONTAINER_OFFSET:unpack())
    list:SetVisible(false)

    return list
end

---Renders textures onto a list.
---@param list GenericUI_ContainerElement
---@param textures TextureLib_Texture[]
function UI._RenderTextures(list, textures)
    for _,texture in ipairs(textures) do
        local element = list:AddChild(texture.GUID, "GenericUI_Element_Texture")
        element:SetTexture(texture)

        -- Show texture name and GUID on click and copy to clipboard
        element.Events.MouseUp:Subscribe(function (_)
            print(texture.Name, texture.GUID)
            Client.CopyToClipboard(texture.Name)
        end)
    end
end

---Returns a list of textures found recursively within a table.
---@param tbl table<string, table|TextureLib_Texture>
---@return TextureLib_Texture[]
function UI._FindTexturesRecursively(tbl)
    local textures = {}

    for _,frame in pairs(tbl) do
        if frame.GUID then
            table.insert(textures, frame)
        else
            textures = table.join(textures, UI._FindTexturesRecursively(frame))
        end
    end

    return textures
end

---Returns a list of Iggy icons found recursively within a table.
---@param tbl table<string, table|TextureLib_Texture>
---@return icon[]
function UI._FindIconsRecursively(tbl)
    local icons = {} ---@type icon[]
    for _,v in pairs(tbl) do
        if type(v) == "table" then
            icons = table.join(icons, UI._FindIconsRecursively(v))
        else
            table.insert(icons, v)
        end
    end
    return icons
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the UI through a console command.
Ext.RegisterConsoleCommand("genericstyles", function (_, _)
    UI:Show()
end)

-- Open the UI through the Input action.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action == GenericUITextures.InputActions.OpenTestUI then
        UI:Show()
    end
end)