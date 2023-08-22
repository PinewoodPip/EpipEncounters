
---@class Feature_BHOverheads : Feature
local BHOverheads = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsEligible = {}, ---@type Event<Feature_BHOverheads_Hook_IsEligible>
    },
    TranslatedStrings = {
        InputAction_Show_Name = {
           Handle = "hb98d5bd4g800cg4d76gb941g7c3c59bd9553",
           Text = "Show B/H",
           ContextDescription = "Keybind name",
        },
        InputAction_Show_Description = {
           Handle = "he085d18bge863g4bf2ga811g562dcc358d76",
           Text = "Shows B/H amounts over the heads of characters in combat.",
           ContextDescription = "Keybind tooltip",
        },
    },
}
Epip.RegisterFeature("BHOverheads", BHOverheads)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_BHOverheads_Hook_IsEligible
---@field Character EclCharacter
---@field IsEligible boolean Hookable. Defaults to `true`.