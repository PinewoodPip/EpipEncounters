
---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

MultiSelect.NETMSG_TOGGLE_WARES = "Features.InventoryMultiSelect.NetMsg.ToggleWares"
MultiSelect.NETMSG_SEND_TO_HOMESTEAD = "Features.InventoryMultiSelect.NetMsg.SendToHomestead"

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.InventoryMultiSelect.NetMsg.ToggleWares : NetMessage
---@field ItemNetIDs NetId[]
---@field MarkAsWares boolean

---@class Features.InventoryMultiSelect.NetMsg.SendToHomestead : NetLib_Message_Character
---@field ItemNetIDs NetId[]