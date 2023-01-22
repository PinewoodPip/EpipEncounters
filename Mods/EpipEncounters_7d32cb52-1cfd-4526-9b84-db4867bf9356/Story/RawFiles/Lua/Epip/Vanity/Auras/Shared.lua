

---@class Feature_Vanity_Auras : Feature
local Auras = {
    APPLIED_AURA_TAG_PREFIX = "EPIP_Vanity_Auras_Applied_",

    ---@type Feature_Vanity_Auras_Bone[]
    BONES = {
        {BoneID = "Dummy_Root", Name = "Root"},
        {BoneID = "Dummy_BodyFX", Name = "Torso"},
        {BoneID = "Dummy_NeckFX", Name = "Neck"},
        {BoneID = "Dummy_OverheadFX", Name = "Overhead"},
        {BoneID = "Dummy_StatusFX", Name = "Head"},
        {BoneID = "Dummy_WingFX", Name = "Wings"},
        {BoneID = "Dummy_L_Hand", Name = "Left Hand"},
        {BoneID = "Dummy_R_Hand", Name = "Right Hand"},
        {BoneID = "Dummy_ProjectileFX", Name = "Projectile"},
    },

    _RegisteredAuras = {}, ---@type table<string, Feature_Vanity_Auras_Entry>
}
Epip.RegisterFeature("Vanity_Auras", Auras)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Vanity_Auras_Bone
---@field BoneID string
---@field Name string

---@class Feature_Vanity_Auras_Entry
---@field Name string
---@field Effect string
local _Aura = {}

---@return string
function _Aura:GetID()
    return self.Effect
end

function _Aura:GetName()
    return self.Name
end

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_Vanity_ApplyAura : NetMessage, NetLib_Message_NetID
---@field AuraID string
---@field BoneID string

---@class EPIPENCOUNTERS_Vanity_RemoveAura : NetMessage, NetLib_Message_NetID
---@field AuraID string

---@class EPIPENCOUNTERS_Vanity_RemoveAuras : NetMessage, NetLib_Message_NetID

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_Vanity_Auras_Entry
function Auras.RegisterAura(data)
    Inherit(data, _Aura)
    
    Auras._RegisteredAuras[data.Effect] = data
end

---@param id string
---@return Feature_Vanity_Auras_Entry
function Auras.GetAura(id)
    return Auras._RegisteredAuras[id]
end

---@return table<string, Feature_Vanity_Auras_Entry> -- Mutable.
function Auras.GetRegisteredAuras()
    return Auras._RegisteredAuras
end

---@param char Character
---@param aura string
---@return boolean
function Auras.HasAura(char, aura)
    return char:IsTagged(Auras._GetAuraTag(aura))
end

---@return string
function Auras._GetAuraTag(auraID)
    return Auras.APPLIED_AURA_TAG_PREFIX .. auraID
end