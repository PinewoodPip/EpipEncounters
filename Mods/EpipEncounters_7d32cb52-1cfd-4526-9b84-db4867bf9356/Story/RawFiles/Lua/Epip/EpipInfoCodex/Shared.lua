
---------------------------------------------
-- Displays Epip-related information in the Codex Info section, such as patch notes.
---------------------------------------------

---@class Features.EpipInfoCodex : Feature
local EpipInfo = {
    NETMSG_OPEN_CHANGELOG = "Features.EpipInfoCodex.NetMsg.OpenChangelog",
    MSGBOX_OPEN_PATCHNOTES = "Open Patch Notes", -- TODO unhardcode

    CHANGELOG_PATH_PREFIX = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/Changelogs/",

    ---@type {Version:integer, Date:date}[]
    CHANGELOGS = {
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
        {
            Version = 1062,
            Date = "16/09/22",
        },
        {
            Version = 1063,
            Date = "19/09/22",
        },
        {
            Version = 1064,
            Date = "05/03/23",
        },
        {
            Version = 1065,
            Date = "07/05/23",
        },
        {
            Version = 1066,
            Date = "30/09/23",
        },
        {
            Version = 1067,
            Date = "18/10/23",
        },
        {
            Version = 1068,
            Date = "26/11/23",
        },
        {
            Version = 1069,
            Date = "2/1/24",
        },
        {
            Version = 1070,
            Date = "1/4/24",
        },
        {
            Version = 1071,
            Date = "28/07/24",
        },
        {
            Version = 1072,
            Date = "20/10/24",
        },
    },

    TranslatedStrings = {
        Changelogs = {
           Handle = "h8e3df1d3g4284g4630ga169g58c1191b1f18",
           Text = "Epip Patch Notes",
           ContextDescription = "Category header",
        },
    },
}
Epip.RegisterFeature("EpipInfoCodex", EpipInfo)