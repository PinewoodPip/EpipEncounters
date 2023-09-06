
local functions = {
    ["UIObject"] = {
        ["ExternalInterfaceCall"] = {
            VarargParams = true,
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
}
return functions