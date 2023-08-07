
---------------------------------------------
-- Implements a Codex section that displays text documents, optionally organized in tree hierarchies.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")
local Generic = Client.UI.Generic
local Codex = Epip.GetFeature("Feature_Codex")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local V = Vector.Create

---@class Features.Codex.Info : Feature
local Info = {
    _Entries = {}, ---@type Features.Codex.Info.Entry[]

    TranslatedStrings = {
        Section_Description = {
           Handle = "hde789445g157eg4ecbg962bg1cb03cdfdc80",
           Text = "View all sort of information from enabled mods.",
           ContextDescription = "Section description",
        },
    },
}
Epip.RegisterFeature("Codex.Info", Info)
local TSK = Info.TranslatedStrings

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Thrown when an entry line needs to be rendered.
---@class Features.Codex.Info.Section.Events.RenderEntryLine
---@field Entry Features.Codex.Info.Entry
---@field Line string
---@field Root GenericUI_Element_ScrollList

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Codex.Info.Entry : I_Identifiable
---@field Name string Initializable.
---@field Content string? Initializable. If not present, the entry will only act as a collapsable folder and will not be selectable.
---@field SubEntries Features.Codex.Info.Entry[] Initializable, omitable. Will be initialized recursively.
local Entry = {}
Interfaces.Apply(Entry, "I_Identifiable")

---Creates an entry.
---@param data Features.Codex.Info.Entry
---@return Features.Codex.Info.Entry
function Entry.Create(data)
    data.SubEntries = data.SubEntries or {}
    Inherit(data, Entry)

    for i,entry in ipairs(data.SubEntries) do -- Initialize sub-entries recursively
        data.SubEntries[i] = Entry.Create(entry)
    end

    return data
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers an entry.
---@param entry Features.Codex.Info.Entry
function Info.RegisterEntry(entry)
    table.insert(Info._Entries, Entry.Create(entry))
end

---Returns a list of the top-level entries.
---@return Features.Codex.Info.Entry[]
function Info.GetEntries()
    return Info._Entries -- TODO make order hookable
end

---------------------------------------------
-- SECTION
---------------------------------------------

---@class Features.Codex.Info.Section : Feature_Codex_Section
local Section = {
    Name = Text.CommonStrings.Info,
    Description = TSK.Section_Description,
    Icon = "hotbar_icon_journal",

    CONTAINER_OFFSET = V(35, 35),
    CONTAINER_FRAME = V(Codex.UI.CONTENT_CONTAINER_SIZE[1] - 50, 640),

    SIDEBAR_ENTRY_HEIGHT = 25,
    SIDEBAR_ENTRY_SPACING = 5, -- Vertical margin between entries
    SIDEBAR_ENTRY_DEPTH_POSITION_OFFSET = 8,

    ---@type GenericUI_Prefab_Button_Style
    INDEX_ENTRY_STYLE_INACTIVE = {
        IdleTexture = Textures.BUTTONS.LABEL.POINTY.IDLE,
        HighlightedTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    },
    ---@type GenericUI_Prefab_Button_Style
    INDEX_ENTRY_STYLE_ACTIVE = {
        IdleTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
        HighlightedTexture = Textures.BUTTONS.LABEL.POINTY.HIGHLIGHTED,
    },

    _CurrentEntry = nil, ---@type Features.Codex.Info.Entry
    _CollapsedEntries = Set.Create({}), ---@type DataStructures_Set<string>

    Events = {
        RenderEntryLine = SubscribableEvent:New("RenderEntryLine"), ---@type Event<Features.Codex.Info.Section.Events.RenderEntryLine>
        EntrySelected = SubscribableEvent:New("EntrySelected"), ---@type Event<{Entry:Features.Codex.Info.Entry?}>
    }
}
Codex:RegisterClass("Features.Codex.Info.Section", Section, {"Feature_Codex_Section"})
Codex.RegisterSection("Info", Section)

---Sets the selected entry.
---@param entry Features.Codex.Info.Entry? Use `nil` to clear.
function Section:SetEntry(entry)
    self._CurrentEntry = entry
    self:Update()
    self.Events.EntrySelected:Throw({
        Entry = entry,
    })
end

---@override
---@param root GenericUI_Element_Empty
function Section:Render(root)
    local contentList = root:AddChild("Info_ContentList", "GenericUI_Element_ScrollList")

    contentList:SetFrame(self.CONTAINER_FRAME:unpack())
    contentList:Move(self.CONTAINER_OFFSET:unpack())
    contentList:SetScrollbarSpacing(4)
    contentList:SetMouseWheelEnabled(true)

    self.ContentList = contentList
end

---@override
function Section:Update()
    -- Render current entry
    local entry = self._CurrentEntry
    local contentList = self.ContentList

    contentList:Clear()

    if entry and entry.Content then -- TODO collapsing
        local lines = Text.Split(entry.Content, "\n")
        for _,line in ipairs(lines) do
            self.Events.RenderEntryLine:Throw({
                Entry = entry,
                Line = line,
                Root = contentList
            })
        end
    end
end

---Render entry hierarchy onto the sidebar.
---@param root GenericUI_Element_VerticalList
---@override
function Section:RenderSidebar(root)
    self._TotalEntries = 0
    local parent = root:AddChild("Info_Sidebar_Container", "GenericUI_Element_Empty")
    local entries = Info.GetEntries()

    for _,entry in ipairs(entries) do
        self:_RenderEntry(parent, entry)
    end
end

---Renders an entry onto the sidebar.
---@param root GenericUI_Element
---@param entry Features.Codex.Info.Entry
---@param depth integer? Defaults to `1`.
function Section:_RenderEntry(root, entry, depth)
    depth = depth or 1
    local inactiveStyle = table.shallowCopy(self.INDEX_ENTRY_STYLE_INACTIVE) ---@type GenericUI_Prefab_Button_Style
    inactiveStyle.Size = V(Codex.UI.INDEX_ENTRY_SIZE[1] - depth * self.SIDEBAR_ENTRY_DEPTH_POSITION_OFFSET, self.SIDEBAR_ENTRY_HEIGHT)
    local activeStyle = table.shallowCopy(self.INDEX_ENTRY_STYLE_ACTIVE) ---@type GenericUI_Prefab_Button_Style
    activeStyle.Size = V(Codex.UI.INDEX_ENTRY_SIZE[1] - depth * self.SIDEBAR_ENTRY_DEPTH_POSITION_OFFSET, self.SIDEBAR_ENTRY_HEIGHT)

    local elementID = "Info_Entry_" .. entry:GetID()
    local button = ButtonPrefab.Create(Codex.UI, elementID, root, inactiveStyle)
    button:SetActiveStyle(activeStyle)
    button:SetPosition(depth * self.SIDEBAR_ENTRY_DEPTH_POSITION_OFFSET, self._TotalEntries * (self.SIDEBAR_ENTRY_HEIGHT + self.SIDEBAR_ENTRY_SPACING))
    button:SetLabel("   " .. entry.Name, "Left")
    button:SetActivated(self._CurrentEntry == entry)

    -- Select entry upon click.
    button.Events.Pressed:Subscribe(function (_)
        self:SetEntry(entry)
        if entry.SubEntries[1] then
            self:SetEntryCollapsed(entry, not self:IsEntryCollapsed(entry))
            Codex.UI.UpdateIndex()
        end
    end)

    -- Update active state when an entry is selected.
    self.Events.EntrySelected:Subscribe(function (ev)
        button:SetActivated(ev.Entry == entry)
    end)

    self._TotalEntries = self._TotalEntries + 1

    -- Render subentries
    if not self:IsEntryCollapsed(entry) then
        for _,subEntry in ipairs(entry.SubEntries) do
            self:_RenderEntry(root, subEntry, depth + 1)
        end
    end
end

---Returns whether an entry is currently collapsed.
---Collapsed entries do not show subentries.
---@param entry Features.Codex.Info.Entry
---@return boolean
function Section:IsEntryCollapsed(entry)
    return self._CollapsedEntries:Contains(entry.ID)
end

---Sets whether an entry is collapsed.
---@param entry Features.Codex.Info.Entry
---@param collapsed boolean
function Section:SetEntryCollapsed(entry, collapsed)
    if collapsed then
        self._CollapsedEntries:Add(entry.ID)
    else
        self._CollapsedEntries:Remove(entry.ID)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Default implementation of RenderEntryLine.
Section.Events.RenderEntryLine:Subscribe(function (ev)
    local label = ev.Line
    local fontSizeOverride = nil

    -- Format certain Markdown syntax.
    label = label:gsub("`([^`]*)`", Text.Format("%1", {FontType = Text.FONTS.ITALIC})) -- Code
    label = label:gsub("%*%*([^*]*)%*%*", Text.Format("%1", {FontType = Text.FONTS.BOLD})) -- Bold
    label = label:gsub("%*([^*]*)%*", Text.Format("%1", {FontType = Text.FONTS.ITALIC})) -- Italics
    if ev.Line:match("^#") then -- Use bigger font size for headers. Pattern should be checked against unformatted line.
        fontSizeOverride = 25
    end

    -- Use black font color
    label = Text.Format(label, {
        Color = Color.BLACK,
        Size = fontSizeOverride,
    })

    -- Create text element
    local text = TextPrefab.Create(Codex.UI, ev.Entry.ID, ev.Root, label, "Left", V(Section.CONTAINER_FRAME[1], 50))
    text:SetSize(text:GetTextSize():unpack())
end, {StringID = "DefaultImplementation"})