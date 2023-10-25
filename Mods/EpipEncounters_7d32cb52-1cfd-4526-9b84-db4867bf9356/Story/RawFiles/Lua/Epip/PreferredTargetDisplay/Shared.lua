
---------------------------------------------
-- Tracks and displays aggro-related information for characters.
---------------------------------------------

---@class Features.PreferredTargetDisplay : Feature
local PreferredTargetDisplay = {
    TAUNTING_TAG_PREFIX = "PIP_PreferredTargetDisplay_Taunting_",
    TAUNTED_TAG_PREFIX = "PIP_PreferredTargetDisplay_TauntedBy_",

    TranslatedStrings = {
        AggroEffect_TauntedBy = {
            Handle = "h2400de7fg95e3g49b3g9a75g136e8d4303e5",
            Text = "Taunted by %s",
            ContextDescription = "Param is character name",
        },
        AggroEffect_Taunting = {
            Handle = "hbc425a35g7325g4a39g89c8g4f53a12292c9",
            Text = "Taunting %s",
            ContextDescription = "Param is character name",
        },
        AggroEffect_Preferred = {
            Handle = "hd72e9e3age9b3g4c47g8009gf7daca531c13",
            Text = "Preferred by enemies",
        },
        AggroEffect_Unpreferred = {
            Handle = "h5fa60300g587ag423cg8f3fg903b327fb9ba",
            Text = "Unpreferred by enemies",
        },
        AggroEffect_Ignored = {
            Handle = "ha69d5b19g97b2g4465gab85g9fbd86817303",
            Text = "Ignored by enemies",
        },
    }
}
Epip.RegisterFeature("PreferredTargetDisplay", PreferredTargetDisplay)