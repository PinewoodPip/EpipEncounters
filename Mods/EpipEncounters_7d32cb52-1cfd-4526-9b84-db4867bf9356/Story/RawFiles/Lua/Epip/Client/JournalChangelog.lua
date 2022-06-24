
local Changelog = {
    Changelogs = {},
}
Epip.AddFeature("JournalChangelog", "JournalChangelog", Changelog)

local Docs = Epip.Features.Docs

---@class JournalChangelogEntry
---@field VersionName string
---@field Date string
---@field Paragraphs JournalEntry[] | string[]
---@field File? string Path for changelog contents, relative to Public folder. If provided, its contents will be parsed and assigned to Paragraphs.

---@param modTable string Can be an existing Docs category, or a new one will be created for it.
---@param changelog JournalChangelogEntry
function Changelog.AddChangelog(modTable, changelog)
    if not Changelog.Changelogs[modTable] then
        Changelog.Changelogs[modTable] = {} 
    end

    if not Docs.CategoryExists(modTable) then
        Docs.RegisterCategory(modTable)
    end

    if changelog.File then
        changelog.Paragraphs = Changelog.ParseFromFile(changelog.File)
    end

    table.insert(Changelog.Changelogs[modTable], changelog)
end

function Changelog.GetChangelogLabel(changelog)
    local label = string.format("%s - %s", changelog.VersionName, changelog.Date)

    return Docs:ReturnFromHooks("GetChangelogLabel", label, changelog)
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

function split(inputstr, sep) sep=sep or '%s' local t={}  for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do table.insert(t,field)  if s=="" then return t end end end

function Changelog.ParseFromFile(path)
    ---@type JournalParagraph[]
    local paragraphs = {}

    local contents = Ext.IO.LoadFile(path, "data")
    local currentIndex = 1
    local nextLineIndex = string.find(contents, "\n")

    paragraphs = split(contents, "\n")

    return paragraphs
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Docs:RegisterHook("GetCategoryRender", function(categoryRender, categoryID, categoryData)
    if Changelog.Changelogs[categoryID] then
        for i,changelog in ipairs(Changelog.Changelogs[categoryID]) do
            table.insert(categoryRender.SubEntries, {
                Label = Changelog.GetChangelogLabel(changelog),
                Paragraphs = changelog.Paragraphs,
            })
        end
    end

    return categoryRender
end)