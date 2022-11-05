
---@class Feature_Vanity_Auras
local Auras = Epip.GetFeature("Feature_Vanity_Auras")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_Vanity_ApplyAura", function(payload)
    local char = Character.Get(payload.NetID)
    local aura = Auras.GetAura(payload.AuraID)

    Osi.PROC_LoopEffect(aura.Effect, char.MyGuid, "PIP_VanityAura", "__ANY__", "")
    local _, handle = Osiris.DB_LoopEffect:Get(char.MyGuid, nil, "PIP_VanityAura", "__ANY__", aura.Effect, nil)

    Osi.DB_PIP_Vanity_AppliedAura(char.MyGuid, aura.Effect, handle)
    Osiris.DB_PIP_Vanity_AppliedAura:Set(char.MyGuid, aura.Effect, handle)
    Osiris.SetTag(char, Auras._GetAuraTag(payload.AuraID))
end)

Net.RegisterListener("EPIPENCOUNTERS_Vanity_RemoveAura", function(payload)
    local char = Character.Get(payload.NetID)
    local tuples = Osiris.DB_PIP_Vanity_AppliedAura:GetTuples(char.MyGuid, nil, nil)

    for _,tuple in ipairs(tuples or {}) do
        local auraID = tuple[2]
        local handle = tuple[3]

        Auras:DebugLog("Stopping effect:", handle)

        Osi.ProcStopLoopEffect(handle)
        Osiris.ClearTag(char, Auras._GetAuraTag(auraID))
    end

    Osiris.DB_PIP_Vanity_AppliedAura:Delete(char.MyGuid, nil, nil)
end)