
---@class Feature_AutoUnlockPartyInventory : Feature
local AutoUnlock = {}
Epip.RegisterFeature("AutoUnlockPartyInventory", AutoUnlock)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EPIPENCOUNTERS_ToggleInventoryLock : Net_SimpleMessage_NetID
---@field State boolean