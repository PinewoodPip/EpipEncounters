
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