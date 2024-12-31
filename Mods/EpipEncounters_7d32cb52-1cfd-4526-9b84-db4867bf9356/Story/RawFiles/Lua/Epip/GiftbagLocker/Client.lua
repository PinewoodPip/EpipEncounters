
---------------------------------------------
-- Warns or disables giftbags incompatible with the user's mods and prepends compatibility warnings.
---------------------------------------------

local GBUI = Client.UI.GiftBagContent

---@class Features.GiftBagCompatibilityWarnings : Feature
local GBL = {
    INCOMPATIBLE_LABEL_COLOR = "992f2f",
    UNDESIRABLE_LABEL_COLOR = "945b00",

    _EnabledGiftbags = {},
    _WarnedGiftbags = {},

    TranslatedStrings = {
        MsgBox_UndesirableWarning_Header = {
            Handle = "hc14509ffgb0cdg4ef3g80a5gf6490f287073",
            Text = "Mod Compatibility Warning",
            ContextDescription = "Header for message box warning about undesirable giftbags",
        },
        MsgBox_UndesirableWarning_Body = {
            Handle = "hdcc2ff83gd864g4895gb15cg8101b9e83eed",
            Text = "This giftbag has been marked as unnecessary or potentially undesirable when used alongside other mods you currently have installed, and may negatively affect your experience.",
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
            ContextDescription = "Template for problematic giftbag descriptions; params are warning (incompatible/undesirable) and reason for the warning",
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
---These will be prevented from being chosen.
---@param modGUID GUID
---@return boolean, table<GUID.Mod, TextLib.String>? -- Incompatibility status and reasons, if incompatible.
function GBL.IsIncompatible(modGUID)
    local incompatibilityReasons = GBL.Hooks.IsIncompatible:Throw({
        ModGUID = modGUID,
        IncompatibilityReasons = {},
    }).IncompatibilityReasons
    local isIncompatible = next(incompatibilityReasons) ~= nil
    return isIncompatible, isIncompatible and incompatibilityReasons or nil
end

---Returns whether a giftbag is marked as potentially undesirable with the current mod setup.
---These will show warnings upon being chosen.
---@param modGUID GUID
---@return boolean, TextLib.String? -- Undesirability status and reason, if undesirable.
function GBL.IsUndesirable(modGUID)
    local undesirabilityReasons = GBL.Hooks.IsUndesirable:Throw({
        ModGUID = modGUID,
        UndesirabilityReasons = {},
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

            -- Prepend to description
            local originalDescription = entry.Description
            entry.Description = Text.Join(incompatibilityStrings, "<br>")
            entry.Description = entry.Description .. "<br><br>" .. originalDescription

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

            -- Prepend to description
            local originalDescription = entry.Description
            entry.Description = Text.Join(undesirabilityStrings, "<br>")
            entry.Description = entry.Description .. "<br><br>" .. originalDescription
        end
    end
end)
