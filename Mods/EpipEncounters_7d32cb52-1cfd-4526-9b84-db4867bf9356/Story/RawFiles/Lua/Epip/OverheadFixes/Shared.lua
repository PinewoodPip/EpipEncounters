
---------------------------------------------
-- Fixes undead characters not displaying overheads for
-- armor restoration.
-- Additionally, fixes text from the UI blocking clicks onto the world.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_OverheadFixes : Feature
local OverheadFixes = {
    NETMSG_HEAL_OVERHEAD = "Feature_OverheadFixes_NetMsg_Overhead",

    ---@type DataStructures_Set<StatusHealType>
    UNDEAD_BUGGED_HEAL_TYPES = Set.Create({
        "PhysicalArmor",
        "MagicArmor",
        "AllArmor",
    })
}
Epip.RegisterFeature("OverheadFixes", OverheadFixes)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_OverheadFixes_NetMsg_Overhead : NetLib_Message_Character
---@field HealType StatusHealType
---@field Amount integer