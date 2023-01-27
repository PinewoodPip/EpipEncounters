
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_GemModifier : I_Identifiable
local _Modifier = {}
Bedazzled:RegisterClass("Feature_Bedazzled_GemModifier", _Modifier)

---Creates a gem modifier descriptor.
---@param data Feature_Bedazzled_GemModifier
---@return Feature_Bedazzled_GemModifier
function _Modifier.Create(id, data)
    data.ID = id
    Inherit(data, _Modifier)
    Interfaces.Apply(data, "I_Identifiable")

    return data
end