
---@class Feature_BHOverheads : Feature
local BHOverheads = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsEligible = {}, ---@type Event<Feature_BHOverheads_Hook_IsEligible>
    },
}
Epip.RegisterFeature("BHOverheads", BHOverheads)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_BHOverheads_Hook_IsEligible
---@field Character EclCharacter
---@field IsEligible boolean Hookable. Defaults to `true`.