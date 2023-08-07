
local Codex = Epip.GetFeature("Feature_Codex")
local Info = Epip.GetFeature("Features.Codex.Info")

---@class Features.EpipInfoCodex
local EpipInfo = Epip.GetFeature("Features.EpipInfoCodex")
EpipInfo._LatestChangelogEntry = nil ---@type Features.Codex.Info.Entry

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the Codex Info section and select the latest patchnotes when "View Patch Notes" in the notification message box is clicked.
Net.RegisterListener(EpipInfo.NETMSG_OPEN_CHANGELOG, function (_)
    local section = Codex.GetSection("Info") ---@cast section Features.Codex.Info.Section
    Codex.Open()
    Codex.UI.SetSection(section)
    section:SetEntry(EpipInfo._LatestChangelogEntry)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

---Register entries.
---@diagnostic disable-next-line: invisible
function EpipInfo:__Initialize()
    ---@type Features.Codex.Info.Entry
    local changelogsEntry = {
        ID = "Epip_Changelogs",
        Name = EpipInfo.TranslatedStrings.Changelogs:GetString(),
        SubEntries = {}
    }

    -- Register changelogs from newest to oldest.
    for i=#EpipInfo.CHANGELOGS,1,-1 do
        local changelog = EpipInfo.CHANGELOGS[i]
        local path = EpipInfo.CHANGELOG_PATH_PREFIX .. tostring(changelog.Version) .. ".txt"
        ---@type Features.Codex.Info.Entry
        local entry = {
            ID = "Epip_Changelog_" .. tostring(changelog.Version),
            Name = string.format("v%s (%s)", tostring(changelog.Version), changelog.Date),
            Content = IO.LoadFile(path, "data", true),
        }
        table.insert(changelogsEntry.SubEntries, entry)

        if i == #EpipInfo.CHANGELOGS then
            EpipInfo._LatestChangelogEntry = entry
        end
    end

    Info.RegisterEntry(changelogsEntry)
end