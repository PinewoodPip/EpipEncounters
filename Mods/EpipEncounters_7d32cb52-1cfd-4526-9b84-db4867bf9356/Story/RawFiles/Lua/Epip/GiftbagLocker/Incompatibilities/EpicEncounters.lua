
---------------------------------------------
-- Marks giftbags incompatibile/undesirable with Epic Encounters.
---------------------------------------------

local MODS = Mod.GUIDS
local EE_GUID = MODS.EE_CORE

local GBL = Epip.GetFeature("Features.GiftBagCompatibilityWarnings") ---@class Features.GiftBagCompatibilityWarnings

---Auxiliary function.
---@param tsk Library_TranslatedString
---@return Library_TranslatedString
local RegisterTSK = function(tsk)
    return GBL:RegisterTranslatedString(tsk)
end

local TSK = {
    Warning_8AP = RegisterTSK({
        Handle = "he5cba61ag9a66g44d3gaf5cg43c1f5dbf53a",
        Text = "The value of an action point has been halved, meaning characters have a maximum of 12 AP by default.",
        ContextDescription = "EE compatibility warning for 8AP giftbag",
    }),
    Warning_Crafting = RegisterTSK({
        Handle = "h05eeb4f1gee14g43ddgb1ddg44ac6112f92b",
        Text = "Breaks dual-wielding AP cost and reintroduces removed gear perks.",
        ContextDescription = "EE compatibility warning for crafting giftbag",
    }),
    Warning_PetPal = RegisterTSK({
        Handle = "hb7d3ca9eg7516g4af3g9616g98aa4db5947d",
        Text = "Pet Pal is already innate in EE.",
        ContextDescription = "EE compatibility warning for innate pet pal giftbag",
    }),
    Warning_LevelUpItems = RegisterTSK({
        Handle = "h757b89dbg52a1g401cgb040gc6a0489ac60b",
        Text = "Breaks item statistics and is unnecessary due to the Greatforge already having a way to level up items.",
        ContextDescription = "EE compatibility warning for item levelling giftbag",
    }),
    Warning_Summoning = RegisterTSK({
        Handle = "h0fa608ccgd3d8g4af1ga48agd1a51e1a4d95",
        Text = "Reverts EE's changes to summoning.",
        ContextDescription = "EE compatibility warning for summoning giftbag",
    }),
    Warning_Talents = RegisterTSK({
        Handle = "h9e2fea9age009g42ccg8828g5ea0bfa6fb0f",
        Text = "Prevents you from choosing Glass Cannon. The new talents are unsupported.",
        ContextDescription = "EE compatibility warning for talents giftbag",
    }),
    Warning_SpiritVision = RegisterTSK({
        Handle = "h653f684ag7015g46b0ga945ge473bea2fc04",
        Text = "Spirit Vision is already infinite by default in EE.",
        ContextDescription = "EE compatibility warning for talents giftbag",
    }),
    Warning_Randomizer = RegisterTSK({
        Handle = "h5cd299ccg2753g4c7fgbb43g33ec950e8954",
        Text = "Not designed for EE, and is buggy, bestowing permanent resistance boosts to your characters.",
        ContextDescription = "EE compatibility warning for randomizer giftbag",
    }),
    Warning_Rest = RegisterTSK({
        Handle = "h5d55674cg8400g4039gb640ga7498b5b8e09",
        Text = "Unnecessary due to the new Source system.",
        ContextDescription = "EE compatibility warning for resting giftbag",
    }),
    Warning_Organization = RegisterTSK({
        Handle = "hefaa5c7cga265g4789gb95ag974dd3365ea0",
        Text = "Poorly implemented, creates a lot of tedium and inconvenience.",
        ContextDescription = "EE compatibility warning for organization bags giftbag",
    }),
    Warning_Barter = RegisterTSK({
        Handle = "hf1e6fd47gefadg47b9ga523gd997e9e33e0d",
        Text = "Buggy in multiplayer, prevents trading.",
        ContextDescription = "EE compatibility warning for bartering giftbag",
    }),
}

-- Setup warnings for giftbags.
---@type table<GUID.Mod, TextLib_TranslatedString>
GBL.EE_INCOMPATIBLE_GIFTBAGS = { -- 
    [MODS.GB_8AP] = TSK.Warning_8AP,
    [MODS.GB_CRAFTING] = TSK.Warning_Crafting,
    [MODS.GB_PETPAL] = TSK.Warning_PetPal,
    [MODS.GB_LEVELUP_ITEMS] = TSK.Warning_LevelUpItems,
    [MODS.GB_SUMMONING] = TSK.Warning_Summoning,
    [MODS.GB_TALENTS] = TSK.Warning_Talents,
    [MODS.GB_SPIRIT_VISION] = TSK.Warning_SpiritVision,
}
---@type table<GUID.Mod, TextLib_TranslatedString>
GBL.EE_UNDESIRABLE_GIFTBAGS = {
    [MODS.GB_RANDOMIZER] = TSK.Warning_Randomizer,
    [MODS.GB_REST_SOURCE] = TSK.Warning_Rest,
    [MODS.GB_ORGANIZATION] = TSK.Warning_Organization,
    [MODS.GB_BARTER] = TSK.Warning_Barter,
}

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Mark problematic giftbags as incompatible or undesirable.
GBL.Hooks.IsIncompatible:Subscribe(function (ev)
    local reason = GBL.EE_INCOMPATIBLE_GIFTBAGS[ev.ModGUID]
    if reason then
        ev.IncompatibilityReasons[EE_GUID] = reason
    end
end)
GBL.Hooks.IsUndesirable:Subscribe(function (ev)
    local reason = GBL.EE_UNDESIRABLE_GIFTBAGS[ev.ModGUID]
    if reason then
        ev.UndesirabilityReasons[EE_GUID] = reason
    end
end)
