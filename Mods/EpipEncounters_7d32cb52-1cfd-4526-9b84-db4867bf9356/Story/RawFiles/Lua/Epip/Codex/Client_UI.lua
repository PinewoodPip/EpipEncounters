
---------------------------------------------
-- UI for the Codex feature.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local Codex = Epip.GetFeature("Feature_Codex")
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
---@type GenericUI_Prefab_Button_Style
UI.INDEX_ENTRY_STYLE_INACTIVE = {
    IdleTexture = Textures.BUTTONS.LABEL.POINTY.IDLE,
    HighlightedTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    Size = V(400, 32),
}
UI.INDEX_ENTRY_STYLE_ACTIVE = {
    IdleTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    HighlightedTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    Size = V(400, 32),
}
UI.INDEX_ENTRY_SIZE = V(200, 30)
UI.INDEX_ENTRY_LABEL_OFFSET = V(40, 0)
UI.INDEX_ICON_SIZE = V(24, 24)
UI.INDEX_ENTRY_ICON_OFFSET = V(10, 0)

Codex.UI = UI

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function UI:Show()
    UI._Init()
    UI._UpdateIndex()
    UI._UpdateSection()
    Client.UI._BaseUITable.Show(self)
end

---Sets the active section.
---@param section Feature_Codex_Section
function UI.SetSection(section)
    local contentContainer = UI.ContentContainer
    local sectionID = section:GetID()
    local sectionRoot = UI._GetSectionRoot(sectionID)

    Codex:DebugLog("Setting section to", sectionID)

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
    UI:_UpdateIndex()
    UI:_UpdateSection()
end

---Updates the index, which shows all registered sections.
function UI._UpdateIndex()
    local list = UI.IndexList
    list:Clear()

    for _,section in ipairs(Codex.GetSections()) do
        local name = section:GetName()
        local description = section:GetTooltip()

        local entry = ButtonPrefab.Create(UI, section:GetID(), list, UI.INDEX_ENTRY_STYLE_INACTIVE)
        entry:SetActiveStyle(UI.INDEX_ENTRY_STYLE_ACTIVE)
        entry:SetActivated(UI._CurrentSection == section) -- Current section shows as activated
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

    UI.SectionHeader = sectionHeader
end

---Initializes the close button.
function UI._SetupCloseButton()
    local button = CloseButtonPrefab.Create(UI, "CloseButton", UI.Root, ButtonPrefab:GetStyle("CloseStone"))
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
        indexContainer:SetPositionRelativeToParent("Center", -630, -320)
        UI.IndexContainer = indexContainer

        local indexList = indexContainer:AddChild("IndexList", "GenericUI_Element_ScrollList")
        UI.IndexList = indexList

        UI._Initialized = true
    end
end