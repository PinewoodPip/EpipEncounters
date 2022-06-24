
local Journal = {
    nextID = 0, -- For flash
    nextEntryID = 0,
    elementIDToFlashID = {},

    MAX_DEPTH = 2,
    MODE = "Docs",
    INPUT_DEVICE = "KeyboardMouse",
    ID = "PIP_Journal",
    PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/GMJournal.swf",
}
Epip.InitializeUI(nil, "Journal", Journal)
Journal:Debug()

---@type JournalEntry
local _Entry = {
    Label = "Missing Label",
}

---@type JournalLog
local _Log = {
    Paragraphs = {},
}
setmetatable(_Log, _Entry)

---@type JournalCategory
local _Category = {
    SubEntries = {},
}
setmetatable(_Category, _Entry)

-- TODO
-- Infinite nesting
-- Text for categories themselves
-- Hook chapter change func, add elements from lua so we have better control over things - also we must add text formatting
-- Three modes of functionality:
    -- Read static docs
    -- Take personal notes (and share them ?)
    -- Write docs for your own mod, export/import them as lua table / json
-- Embed images within the docs, with iggy icons

-- Categoires, chapters, paragrpahs
-- Categories contain chapters
-- entriesMap maps ids to mcs
-- on destroy, the subentries are destroyed recursively

---@class JournalEntry
---@field Label string

---@class JournalCategory : JournalEntry
---@field SubEntries JournalEntry[]

---@class JournalLog : JournalEntry
---@field Paragraphs JournalParagraph[] | string[]

---@class JournalParagraph
---@field Text string
---@field Type string

---@class JournalIconParagraph : JournalParagraph
---@field Icon string

function Journal.Setup()
    local root = Journal:GetRoot()
    local content = root.content_mc

    content.categories.clearElements()
    Journal.nextID = 0
    Journal.elementIDToFlashID = {}

    local tree = Journal:ReturnFromHooks("GetContentTree", {}, Journal.MODE)
    
    for i,entry in ipairs(tree) do
        Journal.RenderEntry(entry)
    end

    Journal:GetUI():Show()
    -- Needs a delay. Commented because unnecessary.
    -- Journal:SetFlag(Journal.UI_FLAGS.PLAYER_MODAL_1, true)
end

function Journal.GetElement(flashID)
    return Journal:GetRoot().entriesMap[flashID]
end

---@param entry JournalEntry
---@param parent? JournalEntry
---@param depth? integer
function Journal.RenderEntry(entry, parent, depth)
    local flashID
    local parentID = nil
    depth = depth or 0

    if parent then parentID = parent.LastFlashID end

    if depth > Journal.MAX_DEPTH then
        Journal:LogError("Maximum depth exceeded when adding entries by " .. entry.Label or "UNLABELED")
        return nil
    end

    if depth == 0 then
        flashID = Journal.RenderCategory(entry.Label)
    elseif depth == 1 then
        if not parentID then
            Journal:LogError("Tried to add chapter without parent ID form element " .. entry.Label)
            return nil
        end

        flashID = Journal.RenderChapter(parentID, entry.Label)

        -- Paragrpahs only supported for chapters for now
        if entry.Paragraphs then
            for i,str in ipairs(entry.Paragraphs) do
                if type(str) == "string" then
                    Journal.RenderParagraph(flashID, str)
                    -- Journal.RenderParagraph(flashID, " ")
                else
                    if str.Type == "Icon" then
                        Journal.RenderIcon(flashID, str.Icon, str.Size)
                    else
                        Journal.RenderParagraph(flashID, str.Text)
                        -- Journal.RenderParagraph(flashID, " ")
                    end
                end
            end
        end
    end

    entry.LastFlashID = flashID

    Journal:DebugLog("Rendered entry " .. entry.Label)

    if entry.SubEntries then
        for i,subEntry in ipairs(entry.SubEntries) do
            Journal.RenderEntry(subEntry, entry, depth + 1)
        end
    end
end

---@param tree JournalEntry[]
function Journal.AddEntries(tree)
    for i,entry in ipairs(tree) do
        Journal.AddEntry(entry)
    end
end

---@param entry JournalEntry
function Journal.AddEntry(entry)
    if entry.SubEntries then
        setmetatable(entry, _Category)
    else
        setmetatable(entry, _Log)
    end

    if not entry.ID then
        entry.ID = Journal.nextEntryID
        Journal.nextEntryID = Journal.nextEntryID + 1
    end

    table.insert(Journal.Tree, entry)
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

function Journal.RenderCategory(label, index, shared)
    local root = Journal:GetRoot()
    local id = Journal.nextID
    index = index or 0
    shared = shared or false

    root.createCategory(id, index, label, shared)

    Journal.nextID = Journal.nextID + 1
    return id
end

function Journal.RenderChapter(categoryID, label, index, shared)
    local root = Journal:GetRoot()
    local id = Journal.nextID
    index = index or #Journal.GetElement(categoryID)._chapters.content_array
    shared = shared or false

    -- TODO fix error spam from returning MovieClip
    root.createChapter(id, categoryID, index, label, shared)

    Journal.nextID = Journal.nextID + 1
    return id
end

function Journal.RenderParagraph(chapterID, text, index, shared, type)
    local root = Journal:GetRoot()
    local id = Journal.nextID
    index = index or #Journal.GetElement(chapterID).paragraphs
    shared = shared or false

    text = Journal:ReturnFromHooks("GetTextRender", text)

    root.createParagraph(id, chapterID, index, text, shared, type or "Text")
    
    Journal.nextID = Journal.nextID + 1
    return id
end

Journal:RegisterHook("GetTextRender", function(text)
    -- Bold
    text = string.gsub(text, "%*%*(.*)%*%*", "<font face='Ubuntu Mono'>%1</font>")

    -- Code
    text = string.gsub(text, "`(.*)`", "<font face='Averia Serif'>%1</font>")

    -- Headers (bold + bigger font)
    text = string.gsub(text, "^#+ (.*)$", "<font face='Ubuntu Mono' size='23'>%1</font>")

    -- Italic
    text = string.gsub(text, "%*(.*)%*", "<font face='Averia Serif'>%1</font>")

    return text
end)

function Journal.RenderIcon(chapterID, icon, size)
    local root = Journal:GetRoot()
    local id = Journal.RenderParagraph(chapterID, "", nil, nil, "Icon")
    local element = Journal.GetElement(id)
    size = size or 64

    element.heightOverride = size / 32 * 29

    element.name = "iggy_" .. icon
    Journal:GetUI():SetCustomIcon(icon, icon, size, size)

    return id
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open journal from update message box.
Ext.RegisterNetListener("EPIPENCOUNTERS_OpenChangelog", function(cmd, payload)
    Journal.Setup()
    -- TODO open specific category
end)

Journal:RegisterCallListener("pipParagraphsLayoutRebuilt", function(ev)
    local root = Journal:GetRoot()
    local container = root.paragraphs_mc
    local list = container._paragraphsList

    for i=0,#list.content_array-1,1 do
        local element = list.content_array[i]

        if element.elementType == "Icon" then
            element.x = 250 - (element.heightOverride/2)
        elseif element.elementType == "Text" then
            -- local str = element.editableElement_mc._text.htmlText

            -- element.editableElement_mc._text.htmlText = "<font size='17'>" .. str .. "</font>"
            -- element.onHeightChanged()
        end
    end

    -- list.positionElements()
end)

Journal:RegisterCallListener("closeUI", function(ev)
    Journal:GetUI():Hide()

    ev:PreventAction()
end)

-- Handle chapter being changed
Journal:RegisterCallListener("pipChapterSelected", function(ev)
    Journal:GetUI():ExternalInterfaceCall("PlaySound", "UI_Game_Book_PageFlip")
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Journal:__Setup()
    local ui = Ext.UI.Create(Journal.ID, Journal.PATH, 100)
    local root = ui:GetRoot()

    ui.Layer = Client.UI.MessageBox:GetUI().Layer - 1

    root.toggleEditButton_mc.visible = false -- TEMP
    root.caption_mc.text = "JOURNAL"
    ui:Hide()
    -- Journal.Setup()

    -- Ext.RegisterUICall(ui, "closeUI", function()
    --     local root = Journal:GetRoot()
    -- local container = root.paragraphs_mc
    -- local list = container._paragraphsList

    -- print("firing")

    -- for i=0,#list.content_array-1,1 do
    --     local element = list.content_array[i]

    --     print(element)
    -- end
    -- end)
end

---------------------------------------------
-- TESTING
---------------------------------------------

---@type JournalEntry[]
local testTree = {
    {
        Label = "Test Header",
        SubEntries = {
            {
                Label = "Test Entry",
                Paragraphs = {
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                    "By the way here's a second line.",
                },
            },
            {
                Label = "Test Entry 2",
                Paragraphs = {
                    "Test para 1",
                    "Test para 2",
                    {
                        Type = "Icon",
                        Icon = "AMER_DoS1_Skill_Rage",
                    },
                    "Test again",
                },
            },
        },
    },
    {
        Label = "Epic Encounters",
        SubEntries = {
            {
                Label = "Source Infusion, Source Generation",
                Paragraphs = {
                    {
                        Type = "Icon",
                        Icon = "AMER_statIcons_SourceInfusion_3",
                        Size = 64,
                    },
                    "Source Infusion is Epic Encounters' rework of the source point system.",
                    "You will find that almost every spell in the game has been rebalanced to cost zero source points, but they also have Source Infusions listed in their spell descriptions.",
                    "These \"infusion effects\" are the extra effects that the spell will produce when you have that many Source Infusion stacks (and if you satisfy the infusion requirement listed) before casting that spell.",
                    "You can select a Source Infusion amount (up to however many Source points you have) in combat by using the Source Infusion spell, which has no cooldown and costs no AP--so you can use it to cycle through any amount as many times as you wish.",
                    "Source Generation is Epic Encounters' primary means of granting Source points in combat--because Epic Encounters separates your combat and out-of-combat Source points.",
                    "By default, you begin combat with zero Source points, but Source Generation begins on a character's second turn, granting it one point. This continues for two more turns thereafter, for a total of three points on each character.",
                    "There are effects scattered about that can augment your Source point income, but you will generally need to strategize between early, marginal benefits of infusing with one Source point or saving-up for more powerful casts.",
                }
            }
        },
    },
}

-- Journal.AddEntries(testTree)