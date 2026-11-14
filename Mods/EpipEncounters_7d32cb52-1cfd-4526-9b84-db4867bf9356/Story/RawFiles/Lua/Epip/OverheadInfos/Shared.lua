
---@class Features.OverheadInfos : Feature
local OverheadInfos = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsEligible = {}, ---@type Event<Features.OverheadInfos.Hooks.IsEligible>
    },
    TranslatedStrings = {
        InputAction_Show_Name = {
           Handle = "hb98d5bd4g800cg4d76gb941g7c3c59bd9553",
           Text = "Show overhead health bars",
           ContextDescription = "Keybind name",
        },
        InputAction_Show_Description = {
           Handle = "he085d18bge863g4bf2ga811g562dcc358d76",
           Text = "While held, shows health bars and Battered/Harried amounts over the heads of characters in combat.",
           ContextDescription = "Keybind tooltip",
        },
    },
}
Epip.RegisterFeature("Features.OverheadInfos", OverheadInfos)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.OverheadInfos.Hooks.IsEligible
---@field Character EclCharacter
---@field IsEligible boolean Hookable. Defaults to `true`.
