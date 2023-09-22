
---@class Feature_WorldTooltipOpenContainers
local OpenContainers = Epip.GetFeature("WorldTooltipOpenContainers")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to open containers.
Net.RegisterListener("EPIPENCOUNTERS_Feature_WorldTooltipOpenContainers_OpenContainer", function (payload)
    local char = Character.Get(payload.CharacterNetID)
    local item = Item.Get(payload.ItemNetID)

    -- We need to queue moving first, otherwise the character will only walk.
    Osiris.CharacterMoveTo(char, item, true, "", 0)
    Osiris.CharacterUseItem(char, item, "")
end)

-- Listen for requests to cancel the task.
Net.RegisterListener(OpenContainers.NETMSG_REQUEST_CANCEL, function (payload)
    local char = payload:GetCharacter()
    local controller = char.OsirisController
    local task1, task2 = controller.Tasks[1], controller.Tasks[2]
    if controller.Tasks[3] == nil and task1 and task2 and task1.TaskTypeId == "MoveToObject" and task2.TaskTypeId == "UseItem" then
        Osiris.CharacterPurgeQueue(char)
        OpenContainers:DebugLog("Canceled task for", char.DisplayName)
    end
end)