
local Encumbrance = {
    enabled = false,

    STAT_MOVEMENT_PENALTIES = {
        Stats_Encumbered_Partial = -50,
        Stats_Encumbered_Full  = -100,
    },
    STATUS_ID = "ENCUMBERED",
    INFINITE_VALUE = 9999999,
}
Epip.AddFeature("Encumbrance", "Encumbrance", Encumbrance)

---------------------------------------------
-- METHODS
---------------------------------------------

function Encumbrance:IsEnabled()
    return Encumbrance.enabled
end

---@param enabled boolean
function Encumbrance.Toggle(enabled)
    Encumbrance:DebugLog("Toggled encumbrance: " .. tostring(enabled))

    local value = Stats.ExtraData.CarryWeightBase:GetDefaultValue(Mod.GUIDS.EE_CORE) -- TODO consider Derpy's mod, also set str scaling

    if enabled then
        value = Encumbrance.INFINITE_VALUE
    end

    Stats.Update("Data", "CarryWeightBase", value)

    Encumbrance.enabled = enabled
end