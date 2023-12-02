
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
    ["Ext_Stats_DeltaMod"] = {
        ["GetLegacy"] = {
            Params = {
                {Name = "statID", Type = "string"},
                {Name = "modifierType", Type = "\"Weapon\"|\"Armor\"|\"Shield\""}
            },
            ReturnValues = {
                {Type = "DeltaMod"},
            },
        },
    },
    ["Ext_Vars"] = {
        ["RegisterUserVariable"] = {
            Params = {
                {Name = "id", Type = "string"},
                {Name = "options", Type = "table"}, -- TODO!
            },
        },
        ["RegisterModVariable"] = {
            Params = {
                {Name = "modGUID", Type = "GUID"},
                {Name = "id", Type = "string"},
                {Name = "options", Type = "table"}, -- TODO!
            },
        },
    },
}
return functions