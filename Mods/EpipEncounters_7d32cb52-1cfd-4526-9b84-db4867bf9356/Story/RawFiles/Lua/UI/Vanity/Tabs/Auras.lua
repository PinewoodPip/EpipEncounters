
local Vanity = Client.UI.Vanity
local Auras = {
    AURAS = {}, ---@type table<string, VanityAura>
    Tab = Vanity.CreateTab({
        Name = "Auras",
        ID = "PIP_Auras",
        Icon = "hotbar_icon_magic",
    })
}
Epip.AddFeature("VanityAuras", "VanityAuras", Auras)
local Tab = Auras.Tab

---@class VanityAura
---@field Name string
---@field Effect string

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data VanityAura
function Auras.RegisterAura(data)
    Auras.AURAS[data.Effect] = data

    -- Vanity.Refresh()
end

---@param id string
---@return VanityAura
function Auras.GetAura(id)
    return Auras.AURAS[id]
end

---@param aura VanityAura|string
function Auras.ApplyAura(aura)
    if type(aura) == "string" then aura = Auras.GetAura(aura) end

    -- Auras.RemoveCurrentAura()

    Game.Net.PostToServer("EPIPENCOUNTERS_Vanity_ApplyAura", {
        NetID = Client.GetCharacter().NetID,
        Aura = aura,
    })
end

function Auras.RemoveCurrentAura()
    Game.Net.PostToServer("EPIPENCOUNTERS_Vanity_RemoveAura", {
        NetID = Client.GetCharacter().NetID,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---------------------------------------------
-- TAB RENDERING
---------------------------------------------

function Tab:Render()
    Vanity.RenderButton("RemoveAura", "Remove Aura", true)

    local open = Vanity.IsCategoryOpen("Auras")
    Vanity.RenderEntry("Auras", "Auras", true, open, false, false, nil, false, nil)

    if open then
        for id,effect in pairs(Auras.AURAS) do
            Vanity.RenderEntry(effect.Effect, effect.Name, false, false, false, false, nil, false, nil)
        end
    end
end

Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "RemoveAura" then
        Auras.RemoveCurrentAura()
    end
end)

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Auras.ApplyAura(id)
end)

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

for i,eff in ipairs(effs) do
    Auras.RegisterAura({Name = eff, Effect = eff})
end