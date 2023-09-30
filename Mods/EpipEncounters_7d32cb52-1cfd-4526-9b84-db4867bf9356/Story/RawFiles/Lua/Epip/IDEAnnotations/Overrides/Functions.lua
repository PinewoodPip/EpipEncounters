
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
}
return functions