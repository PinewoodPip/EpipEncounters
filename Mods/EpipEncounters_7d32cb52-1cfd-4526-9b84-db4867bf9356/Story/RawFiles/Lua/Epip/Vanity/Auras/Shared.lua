

---@class Feature_Vanity_Auras : Feature
local Auras = {
    APPLIED_AURA_TAG_PREFIX = "EPIP_Vanity_Auras_Applied_",

    _RegisteredAuras = {}, ---@type table<string, Feature_Vanity_Auras_Entry>
}
Epip.RegisterFeature("Vanity_Auras", Auras)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Vanity_Auras_Entry
---@field Name string
---@field Effect string

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_Vanity_ApplyAura : NetMessage, Net_SimpleMessage_NetID
---@field AuraID string

---@class EPIPENCOUNTERS_Vanity_RemoveAura : NetMessage, Net_SimpleMessage_NetID

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_Vanity_Auras_Entry
function Auras.RegisterAura(data)
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

---------------------------------------------
-- TESTING
---------------------------------------------

local effs = {
    "RS3_FX_GP_ScriptedEvent_CameraShake_Loop_00-50",
    "RS3_FX_GP_ScriptedEvent_FJ_RedPrinceO_DarknessFadeIn_Looping_01",
    "RS3_FX_ScriptedEvent_ARX_KemmsGarden_Transform_Loop_01",
    "RS3_FX_Skills_Air_FreeFall_Prepare_01",
    "RS3_FX_Skills_Air_Prepare_Air_ThunderStorm_BodyFX_01",
    "RS3_FX_Skills_Air_Prepare_Divine_Root_02",
    "RS3_FX_Skills_Air_Prepare_Divine_UncannyEvasion_Ground_01",
    "RS3_FX_Skills_Air_Voodoo_Prepare_VacuumAura_Root_01",
    "RS3_FX_Skills_Divine_Prepare_Shout_Root_01",
    "RS3_FX_Skills_Earth_Prepare_Throw_Line_Root_01",
    "RS3_FX_Skills_Earth_Prepare_Throw_Line_Root_02",
    "RS3_FX_Skills_Earth_Prepare_Throw_Line_Root_03",
    "RS3_FX_Skills_Earth_Prepare_Water_Earth_Root_01",
    "RS3_FX_Skills_Fire_Prepare_Divine_Overhead_01",
    "RS3_FX_Skills_Fire_Prepare_Divine_Root_01",
    "RS3_FX_Skills_Fire_Prepare_Divine_Root_03",
    "RS3_FX_Skills_Fire_Prepare_LaserRay_Overhead_Texkey",
    "RS3_FX_Skills_Fire_Prepare_Weapon_Root_SkyShot_01",
    "RS3_FX_GP_ScriptedEvent_VoidwokenAncestorTree_PrepareBlood_01",
    "RS3_FX_GP_ScriptedEvents_ARX_Prison_TheMistake_01",
    "RS3_FX_GP_ScriptedEvent_S_ARX_TheDoctor_FishBarrel_01",
    "RS3_FX_Environment_FallingBlossomPetals_02",
    "RS3_FX_Environment_FlyingSparks_01",
    "RS3_FX_Environment_GroundFog_B",
    "RS3_FX_Environment_GroundFog_A",
    "RS3_FX_Environment_GroundWind_C",
    "RS3_FX_Environment_GroundWind_D",
    "RS3_FX_Environment_SmokeTrail_Big_01",
    "RS3_FX_Environment_Waterfall_Blood_Day_Bottom_Thin_01",
    "RS3_FX_Environment_Waterfall_fume_03",
    "RS3_FX_Environment_Waterfall_Night_Hit_01",
}
for _,eff in ipairs(effs) do
    Auras.RegisterAura({Name = eff, Effect = eff})
end