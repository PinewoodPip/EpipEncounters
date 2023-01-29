
---@class Feature_AscensionShortcuts : Feature
local Shortcuts = {
    POP_PAGE_NET_MSG = "EPIP_AMERUI_GoBack",
}
Epip.RegisterFeature("AscensionShortcuts", Shortcuts)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIP_AMERUI_GoBack : NetLib_Message_Character