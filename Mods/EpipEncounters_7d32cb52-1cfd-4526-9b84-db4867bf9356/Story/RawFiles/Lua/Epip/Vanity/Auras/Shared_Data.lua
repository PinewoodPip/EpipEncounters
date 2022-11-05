
local Auras = Epip.GetFeature("Feature_Vanity_Auras")

---@type Feature
local EpipAuras = {
    TranslatedStrings = {
        ["h2afb4a12gfb71g47c5g9abdg87b5a642637c"] = {
            Text = "Prince Darkness",
            LocalKey = "RS3_FX_GP_ScriptedEvent_FJ_RedPrinceO_DarknessFadeIn_Looping_01",
        },
        ["h39d23b3bg188dg4cd8g9e94gd9697fe9130d"] = {
            Text = "Purple Vortex",
            LocalKey = "RS3_FX_ScriptedEvent_ARX_KemmsGarden_Transform_Loop_01",
        },
        ["hf72184f1g53fdg4103g81d3gc3cf433c3bfb"] = {
            Text = "Arcane Mist",
            LocalKey = "RS3_FX_Skills_Air_FreeFall_Prepare_01",
        },
        ["h50d46bf5ge806g4c7bg9780ga9627d9fc3f3"] = {
            Text = "Intense Smoke",
            LocalKey = "RS3_FX_Skills_Air_Prepare_Air_ThunderStorm_BodyFX_01",
        },
        ["h72991da3gbe87g41c2g8a34gab6e730f4c75"] = {
            Text = "Wind Elemental",
            LocalKey = "RS3_FX_Skills_Air_Prepare_Divine_UncannyEvasion_Ground_01",
        },
        ["h738fac7bg150bg4545g87a9ge3ae1ea94791"] = {
            Text = "Voodoo",
            LocalKey = "RS3_FX_Skills_Air_Voodoo_Prepare_VacuumAura_Root_01",
        },
        ["he515233eg586eg44d4gb0bcg9d971e85e198"] = {
            Text = "Encouraging",
            LocalKey = "RS3_FX_Skills_Divine_Prepare_Shout_Root_01",
        },
        ["h1549cdd8gf0b8g4c64gb887ge3dc98ecf9e3"] = {
            Text = "Poison Ring",
            LocalKey = "RS3_FX_Skills_Earth_Prepare_Throw_Line_Root_01",
        },
        ["h15aafc75g75b8g47b1g94a5g354f7f168120"] = {
            Text = "Midnight Oil",
            LocalKey = "RS3_FX_Skills_Earth_Prepare_Water_Earth_Root_01",
        },
        ["h782c75b8g42c3g4aa0gb3d4g3bfb2a2ce067"] = {
            Text = "Divine Blast",
            LocalKey = "RS3_FX_Skills_Fire_Prepare_Divine_Overhead_01",
        },
        ["h3aca822bgfa26g4005ga288g20b6a22a48ec"] = {
            Text = "Laser Focus",
            LocalKey = "RS3_FX_Skills_Fire_Prepare_LaserRay_Overhead_Texkey",
        },
        ["h40a5107fg6bcdg41a4g8535ga841f2b6f199"] = {
            Text = "Whirlwind",
            LocalKey = "RS3_FX_Skills_Fire_Prepare_Weapon_Root_SkyShot_01",
        },
        ["ha3e9b3f3g2186g4cb3gb212g3938e0bb7779"] = {
            Text = "Violent Strikes",
            LocalKey = "RS3_FX_GP_ScriptedEvent_VoidwokenAncestorTree_PrepareBlood_01",
        },
        ["h0838a5f5gb835g47dcg80d7g29807777a94a"] = {
            Text = "Cherry Blossom",
            LocalKey = "RS3_FX_Environment_FallingBlossomPetals_02",
        },
        ["h81b14740g9bb2g49c8ga4cfgbee3b5b383a8"] = {
            Text = "Sparks",
            LocalKey = "RS3_FX_Environment_FlyingSparks_01",
        },
        ["h0e766045g43afg47d8gb307g97120772d1f6"] = {
            Text = "Fog B",
            LocalKey = "RS3_FX_Environment_GroundFog_B",
        },
        ["hf008175bgcf6fg4232g9d11g99a45cf7be11"] = {
            Text = "Fog A",
            LocalKey = "RS3_FX_Environment_GroundFog_A",
        },
        ["h643da49ag6a17g4b0agbe26g7f416cc33c6f"] = {
            Text = "Sandstorm A",
            LocalKey = "RS3_FX_Environment_GroundWind_C",
        },
        ["h48bab667g8c0ag4263g8622g450aba3d0f94"] = {
            Text = "Sandstorm B",
            LocalKey = "RS3_FX_Environment_GroundWind_D",
        },
        ["h962abab4gaa4eg42c7gaa0eg3f0e83649f94"] = {
            Text = "Smoke",
            LocalKey = "RS3_FX_Environment_SmokeTrail_Big_01",
        },
        ["h1d9df2d8g34d0g44e2ga589g7c2366258b4e"] = {
            Text = "Blood Waterfall",
            LocalKey = "RS3_FX_Environment_Waterfall_Blood_Day_Bottom_Thin_01",
        },
        ["ha9257a90g9b52g4277g83b2g74acf74f50a8"] = {
            Text = "Waterfall",
            LocalKey = "RS3_FX_Environment_Waterfall_Night_Hit_01",
        },
    }
}
Epip.RegisterFeature("EpipAuras", EpipAuras)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Define and register built-in auras.
---@type table<string, Feature_Vanity_Auras_Entry>
local effs = {
    "RS3_FX_GP_ScriptedEvent_FJ_RedPrinceO_DarknessFadeIn_Looping_01",
    "RS3_FX_ScriptedEvent_ARX_KemmsGarden_Transform_Loop_01",
    "RS3_FX_Skills_Air_FreeFall_Prepare_01",
    "RS3_FX_Skills_Air_Prepare_Air_ThunderStorm_BodyFX_01",
    "RS3_FX_Skills_Air_Prepare_Divine_UncannyEvasion_Ground_01",
    "RS3_FX_Skills_Air_Voodoo_Prepare_VacuumAura_Root_01",
    "RS3_FX_Skills_Divine_Prepare_Shout_Root_01",
    "RS3_FX_Skills_Earth_Prepare_Throw_Line_Root_01",
    "RS3_FX_Skills_Earth_Prepare_Water_Earth_Root_01",
    "RS3_FX_Skills_Fire_Prepare_Divine_Overhead_01",
    "RS3_FX_Skills_Fire_Prepare_LaserRay_Overhead_Texkey",
    "RS3_FX_Skills_Fire_Prepare_Weapon_Root_SkyShot_01",
    "RS3_FX_GP_ScriptedEvent_VoidwokenAncestorTree_PrepareBlood_01",
    "RS3_FX_Environment_FallingBlossomPetals_02",
    "RS3_FX_Environment_FlyingSparks_01",
    "RS3_FX_Environment_GroundFog_B",
    "RS3_FX_Environment_GroundFog_A",
    "RS3_FX_Environment_GroundWind_C",
    "RS3_FX_Environment_GroundWind_D",
    "RS3_FX_Environment_SmokeTrail_Big_01",
    "RS3_FX_Environment_Waterfall_Blood_Day_Bottom_Thin_01",
    "RS3_FX_Environment_Waterfall_Night_Hit_01",
}
for _,eff in ipairs(effs) do
    Auras.RegisterAura({Name = EpipAuras.TSK[eff], Effect = eff})
end