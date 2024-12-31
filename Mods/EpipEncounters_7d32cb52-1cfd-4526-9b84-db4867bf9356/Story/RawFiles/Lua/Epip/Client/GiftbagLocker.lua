
---------------------------------------------
-- Locks giftbags incompatible with EE and prepends compatibility warnings.
---------------------------------------------

local MODS = Mod.GUIDS

---@class Features.GiftBagCompatibilityWarnings : Feature
local GBL = {
    INCOMPATIBLE_LABEL_COLOR = "992f2f",
    UNDESIRABLE_LABEL_COLOR = "945b00",

    _EnabledGiftbags = {},
    _WarnedGiftbags = {},

    TranslatedStrings = {
        MsgBox_UndesirableWarning_Header = {
            Handle = "hc14509ffgb0cdg4ef3g80a5gf6490f287073",
            Text = "Epic Encounters Warning",
            ContextDescription = "Header for message box warning about undesirable giftbags",
        },
        MsgBox_UndesirableWarning_Body = {
            Handle = "hdcc2ff83gd864g4895gb15cg8101b9e83eed",
            Text = "This giftbag has been marked as unnecessary or potentially undesirable and may negatively affect the EE experience. See the Discord FAQ channel for more information.",
            ContextDescription = "Message box for warning about undesirable giftbags",
        },
        Label_Incompatible = {
            Handle = "hf7564e88g6db5g4f04g9471g668f0f2902a1",
            Text = "Incompatible with %s.",
            ContextDescription = "Shown for incompatible giftbags",
        },
        Label_Undesirable = {
            Handle = "h799a3ec0g65bdg4b30ga240gf12d6aca29c2",
            Text = "Undesirable with %s.",
            ContextDescription = "Shown for undesirable/unnecessary giftbags",
        },
        Label_GiftbagDescription = {
            Handle = "h2883c225g0406g48ffg8c39g1439bdf66f38",
            Text = "%s<br>Reason:<br>%s",
            ContextDescription = "Template for problematic giftbag descriptions; params are warning (incompatible/undesirable), reason for the warning and original description",
        },
        Warning_8AP = {
            Handle = "he5cba61ag9a66g44d3gaf5cg43c1f5dbf53a",
            Text = "The value of an action point has been halved, meaning characters have a maximum of 12 AP by default.",
            ContextDescription = "EE compatibility warning for 8AP giftbag",
        },
        Warning_Crafting = {
            Handle = "h05eeb4f1gee14g43ddgb1ddg44ac6112f92b",
            Text = "Breaks dual-wielding AP cost and reintroduces removed gear perks.",
            ContextDescription = "EE compatibility warning for crafting giftbag",
        },
        Warning_PetPal = {
            Handle = "hb7d3ca9eg7516g4af3g9616g98aa4db5947d",
            Text = "Pet Pal is already innate in EE.",
            ContextDescription = "EE compatibility warning for innate pet pal giftbag",
        },
        Warning_LevelUpItems = {
            Handle = "h757b89dbg52a1g401cgb040gc6a0489ac60b",
            Text = "Breaks item statistics and is unnecessary due to the Greatforge already having a way to level up items.",
            ContextDescription = "EE compatibility warning for item levelling giftbag",
        },
        Warning_Summoning = {
            Handle = "h0fa608ccgd3d8g4af1ga48agd1a51e1a4d95",
            Text = "Reverts EE's changes to summoning.",
            ContextDescription = "EE compatibility warning for summoning giftbag",
        },
        Warning_Talents = {
            Handle = "h9e2fea9age009g42ccg8828g5ea0bfa6fb0f",
            Text = "Prevents you from choosing Glass Cannon. The new talents are unsupported.",
            ContextDescription = "EE compatibility warning for talents giftbag",
        },
        Warning_SpiritVision = {
            Handle = "h653f684ag7015g46b0ga945ge473bea2fc04",
            Text = "Spirit Vision is already infinite by default in EE.",
            ContextDescription = "EE compatibility warning for talents giftbag",
        },
        Warning_Randomizer = {
            Handle = "h5cd299ccg2753g4c7fgbb43g33ec950e8954",
            Text = "Not designed for EE, and is buggy, bestowing permanent resistance boosts to your characters.",
            ContextDescription = "EE compatibility warning for randomizer giftbag",
        },
        Warning_Rest = {
            Handle = "h5d55674cg8400g4039gb640ga7498b5b8e09",
            Text = "Unnecessary due to the new Source system.",
            ContextDescription = "EE compatibility warning for resting giftbag",
        },
        Warning_Organization = {
            Handle = "hefaa5c7cga265g4789gb95ag974dd3365ea0",
            Text = "Poorly implemented, creates a lot of tedium and inconvenience.",
            ContextDescription = "EE compatibility warning for organization bags giftbag",
        },
        Warning_Barter = {
            Handle = "hf1e6fd47gefadg47b9ga523gd997e9e33e0d",
            Text = "Buggy in multiplayer, prevents trading.",
            ContextDescription = "EE compatibility warning for bartering giftbag",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsIncompatible = {}, ---@type Hook<Features.GiftBagCompatibilityWarnings.Hooks.IsIncompatible>
        IsUndesirable = {}, ---@type Hook<Features.GiftBagCompatibilityWarnings.Hooks.IsUndesirable>
    }
}
Epip.RegisterFeature("Features.GiftBagCompatibilityWarnings", GBL)
local TSK = GBL.TranslatedStrings

-- Setup warnings for giftbags.
---@type table<GUID, TextLib_TranslatedString>
GBL.INCOMPATIBLE_GIFTBAGS = { -- Prevented from being chosen.
    [MODS.GB_8AP] = TSK.Warning_8AP,
    [MODS.GB_CRAFTING] = TSK.Warning_Crafting,
    [MODS.GB_PETPAL] = TSK.Warning_PetPal,
    [MODS.GB_LEVELUP_ITEMS] = TSK.Warning_LevelUpItems,
    [MODS.GB_SUMMONING] = TSK.Warning_Summoning,
    [MODS.GB_TALENTS] = TSK.Warning_Talents,
    [MODS.GB_SPIRIT_VISION] = TSK.Warning_SpiritVision,
}
---@type table<GUID, TextLib_TranslatedString>
GBL.UNDESIRABLE_GIFTBAGS = { -- Show warnings upon being chosen.
    [MODS.GB_RANDOMIZER] = TSK.Warning_Randomizer,
    [MODS.GB_REST_SOURCE] = TSK.Warning_Rest,
    [MODS.GB_ORGANIZATION] = TSK.Warning_Organization,
    [MODS.GB_BARTER] = TSK.Warning_Barter,
}

local GBUI = Client.UI.GiftBagContent

---------------------------------------------
-- EVENTS & HOOKS
---------------------------------------------

---@class Features.GiftBagCompatibilityWarnings.Hooks.IsIncompatible
---@field ModGUID GUID
---@field IncompatibilityReasons table<GUID.Mod, TextLib.String> Defaults to `{}`. The giftbag is considered incomaptible if any key is present.

---@class Features.GiftBagCompatibilityWarnings.Hooks.IsUndesirable
---@field ModGUID GUID
---@field UndesirabilityReasons table<GUID.Mod, TextLib.String>? Defaults to `{}`. The mod is considered undesirable if key is present.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether a giftbag is marked as incompatible with the current mod setup.
---@param modGUID GUID
---@return boolean, table<GUID.Mod, TextLib.String>? -- Incompatibility status and reasons, if incompatible.
function GBL.IsIncompatible(modGUID)
    local eeReason = GBL.INCOMPATIBLE_GIFTBAGS[modGUID]
    local incompatibilityReasons = GBL.Hooks.IsIncompatible:Throw({
        ModGUID = modGUID,
        IncompatibilityReasons = {[Mod.GUIDS.EE_CORE] = eeReason},
    }).IncompatibilityReasons
    local isIncompatible = next(incompatibilityReasons) ~= nil
    return isIncompatible, isIncompatible and incompatibilityReasons or nil
end

---Returns whether a giftbag is marked as potentially undesirable with the current mod setup.
---@param modGUID GUID
---@return boolean, TextLib.String? -- Undesirability status and reason, if undesirable.
function GBL.IsUndesirable(modGUID)
    local eeReason = GBL.UNDESIRABLE_GIFTBAGS[modGUID]
    local undesirabilityReasons = GBL.Hooks.IsUndesirable:Throw({
        ModGUID = modGUID,
        UndesirabilityReasons = {[Mod.GUIDS.EE_CORE] = eeReason},
    }).UndesirabilityReasons
    local isUndesirable = next(undesirabilityReasons) ~= nil
    return isUndesirable, isUndesirable and undesirabilityReasons or nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Prevent choosing incompatible giftbags and warn about undesirable ones.
GBUI:RegisterCallListener("buttonPressed", function(ev)
    local _, id = ev.Args[1],ev.Args[2]
    local mod = GBUI.GetModGUID(id)
    local isEnabled = GBL._EnabledGiftbags[id]
    local isIncompatible = GBL.IsIncompatible(mod)
    local isUnwanted = GBL.IsUndesirable(mod)
    if not isEnabled then -- Don't prevent disabling already-enabled giftbags.
        if isIncompatible then
            ev:PreventAction()
        elseif isUnwanted and not GBL._WarnedGiftbags[id] then -- Only show warning once per session.
            GBL._WarnedGiftbags[id] = true
            Client.UI.MessageBox.Open({
                Header = TSK.MsgBox_UndesirableWarning_Header:GetString(),
                Message = TSK.MsgBox_UndesirableWarning_Body:GetString(),
            })
        end
    end
end)

-- Append warnings to giftbag descriptions.
GBUI.Hooks.GetContent:Subscribe(function (ev)
    GBL._WarnedGiftbags = {} -- Reset warning tracking anything the content updates (when the UI opens)

    local content = ev.Content
    for _,entry in ipairs(content) do
        GBL._EnabledGiftbags[entry.ID] = entry.Enabled -- Track which giftbags are enabled

        -- Prepend incompatibility warnings
        local isIncompatible, incompatibilityReasons = GBL.IsIncompatible(entry.Mod)
        local isUndesirable, undesirabilityReasons = GBL.IsUndesirable(entry.Mod)
        if isIncompatible then
            -- Gather incompatibility reasons
            local incompatibilityStrings = {} ---@type string
            for modGUID,reason in pairs(incompatibilityReasons) do
                local modData = Mod.Get(modGUID)
                local modName = modData and modData.Info.Name or modGUID -- Fallback to GUID - ugly, but also allows a "hack" to display any string as the incomaptibility source.
                if modGUID == Mod.GUIDS.EE_CORE then -- Special case.
                    modName = "Epic Encounters"
                end

                table.insert(incompatibilityStrings, TSK.Label_GiftbagDescription:Format({
                    FormatArgs = {
                        {Text = TSK.Label_Incompatible:Format(modName), Color = GBL.INCOMPATIBLE_LABEL_COLOR},
                        reason,
                    },
                }))
            end

            -- Preppend to description
            local originalDescription = entry.Description
            entry.Description = Text.Join(incompatibilityStrings, "<br>")
            entry.Description = entry.Description .. "<br>" .. originalDescription

            -- Only lock giftbags that are not already enabled - this is so they can still be disabled (if possible)
            if not entry.Enabled then
                entry.Locked = true
            end
        end
        -- Also show undesirability reasons, even if the mod is already deemed incompatible for any other reasons.
        if isUndesirable then
            -- Gather undesirability reasons
            local undesirabilityStrings = {} ---@type string
            for modGUID,reason in pairs(undesirabilityReasons) do
                local modData = Mod.Get(modGUID)
                local modName = modData and modData.Info.Name or modGUID -- Fallback to GUID - ugly, but also allows a "hack" to display any string as the incomaptibility source.
                if modGUID == Mod.GUIDS.EE_CORE then -- Special case.
                    modName = "Epic Encounters"
                end

                table.insert(undesirabilityStrings, TSK.Label_GiftbagDescription:Format({
                    FormatArgs = {
                        {Text = TSK.Label_Undesirable:Format(modName), Color = GBL.UNDESIRABLE_LABEL_COLOR},
                        reason,
                    },
                }))
            end

            -- Preppend to description
            local originalDescription = entry.Description
            entry.Description = Text.Join(undesirabilityStrings, "<br>")
            entry.Description = entry.Description .. "<br>" .. originalDescription
        end
    end
end)