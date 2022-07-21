
---@class ModLib
Mod = {
    GUIDS = {
        EE_CORE = "63bb9b65-2964-4c10-be5b-55a63ec02fa0",
        EE_ORIGINS = "d2d724e6-13c2-47c3-b356-19c3ff8bc622",
        EPIP_ENCOUNTERS = "7d32cb52-1cfd-4526-9b84-db4867bf9356",
        EE_DERPY = "0701303b-719f-40e6-b554-3f6515b08268",

        GB_8AP = "9b45f7e5-d4e2-4fc2-8ef7-3b8e90a5256c",
        GB_SPRINT = "ec27251d-acc0-4ab8-920e-dbc851e79bb4",
        GB_HERBS = "38608c30-1658-4f6a-8adf-e826a5295808",
        GB_CRAFTING = "68a99fef-d125-4ed0-893f-bb6751e52c5e",
        GB_PETPAL = "423fae51-61e3-469a-9c1f-8ad3fd349f02",
        GB_RESPEC = "2d42113c-681a-47b6-96a1-d90b3b1b07d3",
        GB_CAT = "015de505-6e7f-460c-844c-395de6c2ce34",
        GB_BARTER = "f33ded5d-23ab-4f0c-b71e-1aff68eee2cd",
        GB_RANDOMIZER = "f30953bb-10d3-4ba4-958c-0f38d4906195",
        GB_LEVELUP_ITEMS = "a945eefa-530c-4bca-a29c-a51450f8e181",
        GB_ORGANIZATION = "f243c84f-9322-43ac-96b7-7504f990a8f0",
        GB_SUMMONING = "d2507d43-efce-48b8-ba5e-5dd136c715a7",
        GB_REST_SOURCE = "1273be96-6a1b-4da9-b377-249b98dc4b7e",
        GB_RESTSURRECT = "af4b3f9c-c5cb-438d-91ae-08c5804c1983",
        GB_TALENTS = "ca32a698-d63e-4d20-92a7-dd83cba7bc56",
        GB_SPIRIT_VISION = "8fe1719c-ef8f-4cb7-84bd-5a474ff7b6c1",

        CRAFTING_OVERHAUL = "6aaa43a9-3a72-e82e-a6f6-8c367fd82117",
        IMPROVED_HOTBAR = "53cdc613-9d32-4b1d-adaa-fd97c4cef22c",
        LEADERLIB = "7e737d2f-31d2-4751-963f-be6ccc59cd0c",
        CONFLUX = "723ad06b-0241-4a2e-a9f3-4d2b419e0fe3",
        ODIN_SUMMONING_SCALING = "0e8fce66-abd2-486c-b0c7-40e8fe71c236",
        BETTER_CLOUDS = "5cd57d24-f53b-c6a5-1561-a9e44ee14faf",
        IMPROVED_GWYDIAN_RINCE = "23007beb-a1cf-48b3-a6e5-e361a0228c07",
        CITIZENS_OF_DIVINITY = "9b414960-1272-4674-a18f-cb230a842160",
        POLYMORPH_RECRUITING_FIX = "b77bc380-dad7-4118-9c8f-84a65cd82886",
        INITIATIVE_TURN_ORDER = "6ad8b4b4-8379-4ae9-b0e7-5ea6ffb4fd19",
        WILDFIRE = "16d5503c-6b3f-4a93-96f9-ea34753e40f5",
        RELICS_OF_RIVELLON_FIX = "9950574f-2228-415f-b756-66e061688825",

        PORTABLE_RESPEC_MIRROR = "2034f42a-b09b-4c02-846d-91c4c03fc423",
        MAJORA_FASHION_SINS = "2dd896dc-28eb-443e-8405-0d339375d2c8",
        WEAPON_EXPANSION = "c60718c3-ba22-4702-9c5d-5ad92b41ba5f",
        RENDAL_NPC_ARMOR = "4dfe4bfe-2f7c-772f-9ce9-a83052a39ad2",
        VISITORS_FROM_CYSEAL = "f21e7a68-c39c-4387-9a3f-04dfd216caba",
    },
}
Epip.InitializeLibrary("Mods", Mod)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param guid GUID
function Mod.IsLoaded(guid)
    return Ext.Mod.IsModLoaded(guid)
end

---@param guid GUID
---@return integer?, integer?, integer?, integer? --Major, minor, revision, build version. Fails if the mod is not loaded.
function Mod.GetStoryVersion(guid)
    local info = Ext.Mod.GetModInfo(guid)
    local major, minor, revision, build
    local version = info.Version

    major = version // 268435456
    version = version - major * 268435456

    minor = version // 16777216
    version = version - minor * 16777216

    revision = version // 65536
    version = version - revision * 65536

    build = version

    return major, minor, revision, build
end