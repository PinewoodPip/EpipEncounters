
---@class Feature_ExtraDataConfig : Feature
local DataConfig = Epip.Features.ExtraDataConfig

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_SetExtraData", function(payload)
    local key = payload.Key
    local value = payload.Value

    DataConfig.SetValue(key, value)
end)