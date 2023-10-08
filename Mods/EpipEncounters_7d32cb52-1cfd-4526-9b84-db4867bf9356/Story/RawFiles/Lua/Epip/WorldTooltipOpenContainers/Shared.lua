
---@class Feature_WorldTooltipOpenContainers : Feature
local OpenContainers = {
    NETMSG_OPEN_CONTAINER = "Features.WorldTooltipOpenContainers.NetMsg.OpenContainer",
    NETMSG_REQUEST_CANCEL = "Features.WorldTooltipOpenContainers.NetMsg.RequestCancel",
    NETMSG_TASK_FAILED = "Features.WorldTooltipOpenContainers.NetMsg.TaskFailed", -- Empty message, sent from server to client.
    TAG_TASK_RUNNING = "Features.WorldTooltipOpenContainers.Tag.TaskRunning",
}
Epip.RegisterFeature("WorldTooltipOpenContainers", OpenContainers)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.WorldTooltipOpenContainers.NetMsg.OpenContainer : NetMessage
---@field CharacterNetID NetId
---@field ItemNetID NetId

---@class Features.WorldTooltipOpenContainers.NetMsg.RequestCancel : NetLib_Message_Character

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the task is currently running on a character.
---@param char Character
function OpenContainers.IsTaskRunning(char)
    return char:HasTag(OpenContainers.TAG_TASK_RUNNING)
end
