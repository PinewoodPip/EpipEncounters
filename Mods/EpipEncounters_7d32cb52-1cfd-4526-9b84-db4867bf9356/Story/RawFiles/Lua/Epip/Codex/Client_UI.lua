
---------------------------------------------
-- UI for the Codex feature.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local Codex = Epip.GetFeature("Feature_Codex")
local Input = Client.Input
local TSK = Codex.TranslatedStrings
local V = Vector.Create

---@class Feature_Codex_UI : GenericUI_Instance
local UI = Generic.Create("Epip_Feature_Codex")
UI._Initialized = false
UI._CurrentSection = nil ---@type Feature_Codex_Section?
UI._SectionContents = {} ---@type table<string, GenericUI_Element_Empty> Root elements of each section.

UI.HEADER_FONT_SIZE = 27
UI.SIZE = V(1360, 944) -- Same as the journal texture
UI.HEADER_HEIGHT = 50
UI.HEADER_SIZE = V(436, UI.HEADER_HEIGHT)
UI.SECTION_HEADER_SIZE = V(875, UI.HEADER_HEIGHT)
UI.CONTENT_CONTAINER_SIZE = V(812, 777)

UI.INDEX_CONTAINER_OFFSET = V(-630, -320)
UI.INDEX_ENTRY_SIZE = V(400, 32)
---@type GenericUI_Prefab_Button_Style
UI.INDEX_ENTRY_STYLE_INACTIVE = {
    IdleTexture = Textures.BUTTONS.LABEL.POINTY.IDLE,
    HighlightedTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    Size = UI.INDEX_ENTRY_SIZE,
}
UI.INDEX_ENTRY_STYLE_ACTIVE = {
    IdleTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    HighlightedTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    Size = UI.INDEX_ENTRY_SIZE,
}
UI.INDEX_ENTRY_LABEL_OFFSET = V(40, 0)
UI.INDEX_ICON_SIZE = V(24, 24)
UI.INDEX_ENTRY_ICON_OFFSET = V(10, 0)
UI.INDEX_FRAME_SIZE = V(400, 700)
UI.INDEX_FRAME_SCROLLBAR_SPACING = -13

UI.SETTING_ELEMENT_SIZE = V(UI.INDEX_ENTRY_SIZE[1] - 20, 50)

Codex.UI = UI

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function UI:Show()
    UI._Init()
    UI.UpdateIndex()
    UI._UpdateSection()
    Client.UI._BaseUITable.Show(self)
end

---Sets the active section.
---@param section Feature_Codex_Section
function UI.SetSection(section)
    local contentContainer = UI.ContentContainer
    local sectionID = section:GetID()
    local sectionRoot = UI._GetSectionRoot(sectionID)
    local previousSection = UI._CurrentSection

    Codex:DebugLog("Setting section to", sectionID)

    -- Hide previous section
    if previousSection then
        local previousSectionRoot = UI._GetSectionRoot(previousSection:GetID())
        previousSectionRoot:SetVisible(false)
    end

    -- Create root element if necessary
    if not sectionRoot then
        sectionRoot = contentContainer:AddChild(sectionID, "GenericUI_Element_Empty")
        UI._SectionContents[sectionID] = sectionRoot

        section:Render(sectionRoot)
    end

    UI._CurrentSection = section

    -- Update header
    local header = UI.SectionHeader
    header:SetText(Text.Format(section:GetName(), {Size = UI.HEADER_FONT_SIZE}))

    -- Update index and section
    UI:UpdateIndex()
    UI:_UpdateSection()
    sectionRoot:SetVisible(true)
end

---------------------------------------------
-- PRIVATE METHODS
---------------------------------------------

---Updates the index, which shows all registered sections.
function UI.UpdateIndex()
    local list = UI.IndexList
    list:Clear()

    for _,section in ipairs(Codex.GetSections()) do
        local name = section:GetName()
        local description = section:GetTooltip()
        local isActive = UI._CurrentSection == section

        local entry = ButtonPrefab.Create(UI, section:GetID(), list, UI.INDEX_ENTRY_STYLE_INACTIVE)
        entry:SetActiveStyle(UI.INDEX_ENTRY_STYLE_ACTIVE)
        entry:SetActivated(isActive) -- Current section shows as activated
        entry:SetLabel(name, "Left")
        entry.Label:Move(UI.INDEX_ENTRY_LABEL_OFFSET:unpack())
        entry:SetTooltip("Simple", description)

        if section.Icon then
            entry:SetIcon(section.Icon, UI.INDEX_ICON_SIZE, "Left", UI.INDEX_ENTRY_ICON_OFFSET)
        end

        -- Select the section upon click.
        entry.Events.Pressed:Subscribe(function (_)
            UI.SetSection(section)
        end)

        -- Render section settings
        if isActive then
            local settingsList = list:AddChild(Text.GenerateGUID(), "GenericUI_Element_VerticalList")
            settingsList:SetCenterInLists(true)

            for _,setting in ipairs(section.Settings or {}) do
                SettingWidgets.RenderSetting(UI, settingsList, setting, UI.SETTING_ELEMENT_SIZE, function (_)
                    -- Update the section when a setting value changes from a widget
                    section:Update(UI._GetSectionRoot(section:GetID()))
                end)
            end

            section:RenderSidebar(settingsList)
            settingsList:RepositionElements()
        end
    end

    list:RepositionElements()
end

---Updates the current section, if any.
function UI._UpdateSection()
    local section = UI._CurrentSection
    if section then
        local sectionRoot = UI._GetSectionRoot(section:GetID())
        section:Update(sectionRoot)
    end
end

---Returns the root element of a section.
---@param id string
---@return GenericUI_Element_Empty
function UI._GetSectionRoot(id)
    return UI._SectionContents[id]
end

---Initializes header elements.
function UI._SetupHeaders()
    local bg = UI.Root
    local headerLabel = Text.Format(TSK.Title:GetString(), {
        Size = UI.HEADER_FONT_SIZE,
    })
    local header = TextPrefab.Create(UI, "Header", bg, headerLabel, "Center", UI.HEADER_SIZE)
    header:SetStroke(0, 2, 1, 20, 10)
    header:SetPositionRelativeToParent("TopLeft", 25, 20)

    local sectionHeader = TextPrefab.Create(UI, "SectionHeader", bg, "", "Center", UI.SECTION_HEADER_SIZE)
    sectionHeader:SetStroke(0, 2, 1, 20, 10)
    sectionHeader:SetPositionRelativeToParent("Top", 223, 20)

    UI.IndexHeader = header
    UI.SectionHeader = sectionHeader
end

---Initializes the close button.
function UI._SetupCloseButton()
    local button = CloseButtonPrefab.Create(UI, "CloseButton", UI.Root, ButtonPrefab.STYLES.CloseStone)
    button:SetPositionRelativeToParent("TopRight", -45, 20)
end

---Initializes the core UI elements, if necessary.
function UI._Init()
    if not UI._Initialized then
        local bg = UI:CreateElement("Background", "GenericUI_Element_Texture")
        bg:SetTexture(Textures.PANELS.JOURNAL, UI.SIZE)
        UI.Root = bg

        UI._SetupHeaders()
        UI._SetupCloseButton()

        UI:SetPanelSize(UI.SIZE)
        UI:SetPositionRelativeToViewport("center", "center")
        -- TODO move slightly up

        local contentContainer = bg:AddChild("ContentContainer", "GenericUI_Element_Empty")
        contentContainer:SetPositionRelativeToParent("Center", -180, -400) -- Top-left of the right page in the background texture
        UI.ContentContainer = contentContainer

        local indexContainer = bg:AddChild("IndexContainer", "GenericUI_Element_Empty")
        indexContainer:SetPositionRelativeToParent("Center", UI.INDEX_CONTAINER_OFFSET:unpack())
        UI.IndexContainer = indexContainer

        local indexList = indexContainer:AddChild("IndexList", "GenericUI_Element_ScrollList")
        indexList:SetMouseWheelEnabled(true)
        indexList:SetFrame(UI.INDEX_FRAME_SIZE:unpack())
        indexList:SetScrollbarSpacing(UI.INDEX_FRAME_SCROLLBAR_SPACING)
        UI.IndexList = indexList

        -- Close the UI when escape is pressed.
        Input.Events.KeyStateChanged:Subscribe(function (ev)
            if ev.InputID == "escape" and UI:IsVisible() then
                UI:Hide()
                ev:Prevent()
            end
        end)

        UI._Initialized = true
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update the section when the active client character changes.
Client.Events.ActiveCharacterChanged:Subscribe(function (_)
    UI._UpdateSection()
end)