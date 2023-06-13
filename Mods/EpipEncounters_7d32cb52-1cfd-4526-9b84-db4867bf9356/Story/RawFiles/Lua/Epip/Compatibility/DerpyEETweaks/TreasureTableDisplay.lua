
---------------------------------------------
-- Adds Derpy's scripted treasures to the Treasure Table Display feature.
---------------------------------------------

local TTD = Epip.GetFeature("Feature_TreasureTableDisplay")

---@type Feature
local DerpyTreasures = {
    -- Alexander is a special case
    ALEXANDER_GUID = "03e6345f-1bd3-403c-80e2-a443a74f6349",
    CHARACTERS = {
        ["002_ab1ba23b-227b-4315-a096-b6c0b4bc8a5c"] = TTD.TREASURE_TABLES.MegaBoss, -- S_CoS_Temples_Animal
        ["e13fde00-fca4-494e-973b-7812c56a08d1"] = TTD.TREASURE_TABLES.MiniBoss, -- S_CON01_Elven_Scholar
        ["9369895e-df54-4613-8fd9-8e7a0e8f1339"] = TTD.TREASURE_TABLES.MiniBoss, -- S_CON00_ElvenScion_ARX
        ["dc614e64-d6ef-4b45-8864-73f2a92a1980"] = TTD.TREASURE_TABLES.MegaBoss, -- S_GLO_BurnishedOne
        ["c4d751d4-20ff-4281-baf4-8ddeb1383e7e"] = TTD.TREASURE_TABLES.MiniBoss_ProteanAlways, -- S_FTJ_ChapelMagister_Captain
        ["bd11bb31-959b-4154-9bdf-fc44e605925b"] = TTD.TREASURE_TABLES.MegaBoss, -- Derpy_FTJ_ChapelReinforcement_Rogue_002
        ["13bb467b-de20-4726-8afd-757705352361"] = TTD.TREASURE_TABLES.MegaBoss, -- S_RC_DW_UnderTavern_Voidwoken
        ["e607062b-d56e-4832-b414-b2a6899d60fe"] = TTD.TREASURE_TABLES.MiniBoss, -- RC_WH_RuinsCliff_Totem
        ["899212c1-3ba7-438d-981f-51ecf75c01a9"] = TTD.TREASURE_TABLES.MiniBoss, -- S_RC_DU_HeroicRescue_GiantInsect_Wings_01
        ["5362d05e-1cb2-451f-9f5a-69078100a01b"] = TTD.TREASURE_TABLES.MegaBoss, -- S_RC_DW_WC_BossFight_GiantInsect_Boss
        ["69b951dc-55a4-44b8-a2d5-5efedbd7d572"] = TTD.TREASURE_TABLES.MegaBoss, -- S_GLO_Dallis
        ["4014aee0-56f1-47e0-a8eb-89c4b5a1da83"] = TTD.TREASURE_TABLES.MiniBoss_ProteanAlways, -- S_FTJ_SW_Witch
    },

    REQUIRED_MODS = {
        [Mod.GUIDS.EE_DERPY] = "Derpy's EE2 Tweaks",
    },
}
Epip.RegisterFeature("DerpyTreasureDisplay", DerpyTreasures)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

TTD.Hooks.GetTreasureData:Subscribe(function (ev)
    local data = ev.Data
    local entity = ev.Entity

    if DerpyTreasures:IsEnabled() and Entity.IsCharacter(entity) then
        ---@cast entity EclCharacter
        local guid = entity.MyGuid

        -- Alexander is a special case
        if guid == DerpyTreasures.ALEXANDER_GUID then
            local level = Ext.Entity.GetCurrentLevel().LevelDesc.LevelName

            if level == "FJ_FortJoy_Main" then
                data = TTD.TREASURE_TABLES.MiniBoss
            else
                data = TTD.TREASURE_TABLES.MegaBoss
            end
        else
            data = DerpyTreasures.CHARACTERS[guid]
        end

        ev.Data = data or ev.Data
    end
end)