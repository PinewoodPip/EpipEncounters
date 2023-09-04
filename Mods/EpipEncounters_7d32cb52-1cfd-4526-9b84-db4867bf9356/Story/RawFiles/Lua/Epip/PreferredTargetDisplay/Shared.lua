
---------------------------------------------
-- Tracks and displays aggro-related information for characters.
---------------------------------------------

---@class Features.PreferredTargetDisplay : Feature
local PreferredTargetDisplay = {
    TAUNTING_TAG_PREFIX = "PIP_PreferredTargetDisplay_Taunting_",
    TAUNTED_TAG_PREFIX = "PIP_PreferredTargetDisplay_TauntedBy_",
}
Epip.RegisterFeature("PreferredTargetDisplay", PreferredTargetDisplay)