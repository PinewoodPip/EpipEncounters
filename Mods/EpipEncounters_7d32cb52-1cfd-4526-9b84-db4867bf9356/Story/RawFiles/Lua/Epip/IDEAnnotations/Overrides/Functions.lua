
local functions = {
    ["UIObject"] = {
        ["ExternalInterfaceCall"] = {
            VarargParams = true,
        },
    },
    ["Ext_ClientUI"] = {
        ["GetMouseFlashPos"] = {
            Params = {
                {Name = "ui", Type = "UIObject?", Comment = "If passed, returned coordinates will be floats. Otherwise, global pixel coordinates will be returned."},
            },
        },
    },
    ["Ext_ServerOsiris"] = {
        ["RegisterListener"] = {
            Params = {
                {Name = "symbol", Type = "string", Comment = "Event, query, DB, PROC or user query name."},
                {Name = "arity", Type = "integer"},
                {Name = "timing", Type = "\"before\"|\"after\"|\"beforeDelete\"|\"afterDelete\""},
                {Name = "handler", Type = "fun(...)"},
            },
        },
    },
    ["Ext_L10N"] = {
        ["GetTranslatedStringFromKey"] = {
            ReturnValues = {
                {Type = "string"},
                {Type = "TranslatedStringHandle?"},
            },
        },
    },
    ["EsvItem"] = {
        ["SetDeltaMods"] = {
            Params = {
                {Name = "deltaMods", Type = "string[]"},
            },
        },
    },
    ["Ext_Stats_ItemColor"] = {
        ["GetAll"] = {
            ReturnValues = {
                {Type = "table<string, StatsItemColorDefinition>"},
            },
        },
    },
    ["Ext_Stats_SkillSet"] = {
        ["GetLegacy"] = {
            ReturnValues = {
                {Type = "StatSkillSet"},
            },
        },
    },
}
return functions