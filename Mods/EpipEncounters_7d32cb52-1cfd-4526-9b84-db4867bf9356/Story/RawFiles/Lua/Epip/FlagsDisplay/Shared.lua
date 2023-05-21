
---------------------------------------------
-- Displays certain character flags in the EnemyHealthBar.
-- Unfortunately, Guarded flag is very unreliable on client and could not be used.
---------------------------------------------

---@class Feature_FlagsDisplay : Feature
local FlagsDisplay = {
    USERVAR = "Flags",

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    TranslatedStrings = {
        DeathResist = {
           Handle = "h75aa417egac92g4e00ga4b5g173f485c2f01",
           Text = "Comeback Kid Available",
        },
        AttackOfOpportunity = {
           Handle = "he42675fag827ag4189g9c55g0af27feb5fc2",
           Text = "Attack Of Opportunity Available",
        },
        CannotFight = {
           Handle = "h5a14d928gf5d6g48e6ga90egfdf2311276db",
           Text = "Cannot fight",
        },
        Guarded = {
           Handle = "h4c2e34f9g7feeg4303g9dfegcc0c44cf6011",
           Text = "Turn Delayed",
           ContextDescription = "",
        },
    },

    Hooks = {
        GetFlags = {}, ---@type Event<Feature_FlagsDisplay_Hook_GetFlags>
    },
}
Epip.RegisterFeature("FlagsDisplay", FlagsDisplay)

---------------------------------------------
-- EVENTS
---------------------------------------------

---Hook for GetFlags(). Client-only.
---@class Feature_FlagsDisplay_Hook_GetFlags
---@field Entity EclCharacter|EclItem
---@field Flags string[] Hookable. Defaults to empty table.

---------------------------------------------
-- SETUP
---------------------------------------------

FlagsDisplay:RegisterUserVariable(FlagsDisplay.USERVAR, {
    Persistent = true,
})