
---@class EpipDocsAPI
---@field Categories table<string, DocsCategoryData>
---@field CategoryOrder string[]
---@field JOURNAL_MODE string

---@type EpipDocsAPI
local Docs = {
    Categories = {},
    CategoryOrder = {},
    JOURNAL_MODE = "Docs",
}
Epip.AddFeature("Docs", "Docs", Docs)
Docs:Debug()

local Journal = Client.UI.Journal

---@class DocsCategoryData
---@field Name string
---@field Entries JournalLog[]

---Register a category for use with the journal docs system.
---@param categoryID string
---@param data? DocsCategoryData Data to initialize the category with.
function Docs.RegisterCategory(categoryID, data)
    if Docs.Categories[categoryID] ~= nil then
        Docs:LogError("Category already registered with ID: " .. categoryID)
        return nil
    end

    data = data or {}
    data.Name = data.Name or categoryID
    data.Entries = data.Entries or {}

    Docs.Categories[categoryID] = data
    table.insert(Docs.CategoryOrder, categoryID)
end

---Add entries to a category.
---@param categoryID string
---@param entries JournalLog[]
function Docs.AddEntries(categoryID, entries)
    for i,entry in ipairs(entries) do
        Docs.AddEntry(categoryID, entry)
    end
end

---Add an entry to a mod.
---@param categoryID string
---@param entry JournalEntry
function Docs.AddEntry(categoryID, entry)
    if Docs.Categories[categoryID] == nil then
        Docs:LogError("Category must be registered with RegisterCategory before adding entries: " .. categoryID)
        return nil
    end

    table.insert(Docs.Categories[categoryID].Entries, entry)

    -- TODO re-render UI
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

---Get all categories as a tree to render onto the journal UI.
---@return JournalEntry[]
function Docs.GetTreeRender()
    local tree = {}

    for i,categoryID in ipairs(Docs.CategoryOrder) do
        local category = Docs.Categories[categoryID]

        Docs:DebugLog("Rendering " .. categoryID)

        local subEntries = {}

        for i,v in ipairs(category.Entries) do
            table.insert(subEntries, v)
        end

        ---@type JournalCategory
        local categoryRender = {
            Label = category.Name,
            SubEntries = subEntries,
        }

        categoryRender = Docs:ReturnFromHooks("GetCategoryRender", categoryRender, categoryID, category)

        table.insert(tree, categoryRender)
    end

    return tree
end

---Returns whether a category is registered.
---@param categoryID string
function Docs.CategoryExists(categoryID)
    return Docs.Categories[categoryID] ~= nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Journal:RegisterHook("GetContentTree", function(tree, mode)
    if mode == Docs.JOURNAL_MODE then
        tree = Docs.GetTreeRender()
    end

    return tree
end)