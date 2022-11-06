
---@class Feature_Vanity_Auras
local Auras = Epip.GetFeature("Feature_Vanity_Auras")

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EsvCharacter
---@param aura Feature_Vanity_Auras_Entry|string
---@param boneID string? Defaults to empty string.
function Auras.ApplyAura(char, aura, boneID)
    if type(aura) == "string" then aura = Auras.GetAura(aura) end
    boneID = boneID or ""

    Osiris.PROC_LoopEffect(aura.Effect, char, "PIP_VanityAura", "__ANY__", boneID)
    local _, handle, _, _, _, _ = Osiris.DB_LoopEffect:Get(char.MyGuid, nil, "PIP_VanityAura", "__ANY__", aura.Effect, nil)

    Auras:DebugLog("Applying aura", aura:GetID(), handle, "to bone", boneID)

    Osiris.DB_PIP_Vanity_AppliedAura:Set(char, aura:GetID(), handle)
    Osiris.SetTag(char, Auras._GetAuraTag(aura:GetID()))
end

---@param char EsvCharacter
---@param aura Feature_Vanity_Auras_Entry|string
function Auras.RemoveAura(char, aura)
    if type(aura) == "string" then aura = Auras.GetAura(aura) end
    local auraID = aura:GetID()

    local tuples = Osiris.DB_PIP_Vanity_AppliedAura:GetTuples(char, auraID, nil)
    if not tuples then Auras:LogError("Tried to remove an aura that is not applied! " .. auraID) return nil end
    for _,tuple in ipairs(tuples) do
        local handle = tuple[3]

        Auras:DebugLog("Stopping effect:", handle)

        Osiris.ProcStopLoopEffect(handle)
        Osiris.DB_LoopEffect:Delete(char, nil, "PIP_VanityAura", nil, aura.Effect, nil)
        Osiris.ClearTag(char, Auras._GetAuraTag(auraID))
    end

    Osiris.DB_PIP_Vanity_AppliedAura:Delete(char, auraID, nil)
end

---@param char EsvCharacter
function Auras.RemoveAuras(char)
    local tuples = Osiris.DB_PIP_Vanity_AppliedAura:GetTuples(char, nil, nil)

    for _,tuple in ipairs(tuples or {}) do
        local auraID = tuple[2]

        Auras.RemoveAura(char, auraID)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to apply auras.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_ApplyAura", function(payload)
    local char = Character.Get(payload.NetID)

    Auras.ApplyAura(char, payload.AuraID, payload.BoneID)
end)

-- Listen for aura removal requests.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_RemoveAura", function(payload)
    local char = Character.Get(payload.NetID)
    
    Auras.RemoveAura(char, payload.AuraID)
end)

-- Listen for requests to remove all auras.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_RemoveAuras", function(payload)
    local char = Character.Get(payload.NetID)

    Auras.RemoveAuras(char)
end)