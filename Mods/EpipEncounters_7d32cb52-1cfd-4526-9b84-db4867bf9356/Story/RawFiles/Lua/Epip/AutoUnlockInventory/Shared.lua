
---@class Feature_AutoUnlockPartyInventory : Feature
local AutoUnlock = {}
Epip.RegisterFeature("AutoUnlockPartyInventory", AutoUnlock)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EPIPENCOUNTERS_ToggleInventoryLock : NetLib_Message_NetID
---@field State boolean