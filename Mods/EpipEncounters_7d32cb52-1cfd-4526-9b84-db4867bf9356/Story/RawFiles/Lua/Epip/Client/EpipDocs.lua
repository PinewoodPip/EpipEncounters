
---------------------------------------------
-- Journal entries for Epip Encounters, including changelogs.
---------------------------------------------

---@type EpipDocsAPI
local Docs = Epip.Features.Docs
local Changelogs = Epip.Features.JournalChangelog

local PATH_PREFIX = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/Changelogs/"

Docs.RegisterCategory("EpipEncounters", {
    Name = "Epip Encounters",
})

---@class EpipChangelogEntry
---@field Version integer
---@field Date string

---@type EpipChangelogEntry[]
local VERSIONS = {
    {
        Version = 1027,
        Date = "30/07/21",
    },
    {
        Version = 1028,
        Date = "31/07/21",
    },
    {
        Version = 1029,
        Date = "06/08/21",
    },
    {
        Version = 1030,
        Date = "30/08/21",
    },
    {
        Version = 1032,
        Date = "05/09/21",
    },
    {
        Version = 1035,
        Date = "12/09/21",
    },
    {
        Version = 1036,
        Date = "01/10/21",
    },
    {
        Version = 1037,
        Date = "02/10/21",
    },
    {
        Version = 1038,
        Date = "16/10/21",
    },
    {
        Version = 1039,
        Date = "17/10/21",
    },
    {
        Version = 1040,
        Date = "19/10/21",
    },
    {
        Version = 1041,
        Date = "23/10/21",
    },
    {
        Version = 1042,
        Date = "14/12/21",
    },
    {
        Version = 1043,
        Date = "19/12/21",
    },
    {
        Version = 1044,
        Date = "27/12/21 - 19/02/22",
    },
    {
        Version = 1045,
        Date = "01/04/22",
    },
    {
        Version = 1046,
        Date = "14/04/22",
    },
    {
        Version = 1047,
        Date = "20/04/22",
    },
    {
        Version = 1048,
        Date = "14/05/22",
    },
    {
        Version = 1049,
        Date = "23/06/22",
    },
    {
        Version = 1050,
        Date = "26/06/22",
    },
    {
        Version = 1051,
        Date = "28/06/22",
    },
    {
        Version = 1052,
        Date = "4/07/22",
    },
    {
        Version = 1053,
        Date = "7/07/22",
    },
    {
        Version = 1054,
        Date = "13/07/22",
    },
    {
        Version = 1055,
        Date = "20/07/22",
    },
    {
        Version = 1056,
        Date = "22/07/22",
    },
    {
        Version = 1057,
        Date = "26/07/22",
    },
    {
        Version = 1058,
        Date = "29/08/22",
    },
    {
        Version = 1059,
        Date = "29/08/22",
    },
    {
        Version = 1060,
        Date = "3/09/22",
    },
    {
        Version = 1061,
        Date = "4/09/22",
    },
}

for i=#VERSIONS,1,-1 do
    local version = VERSIONS[i]
    Changelogs.AddChangelog("EpipEncounters", {
        VersionName = string.format("v%s", tostring(version.Version)),
        Date = version.Date,
        File = PATH_PREFIX .. tostring(version.Version) .. ".txt",
    })
end