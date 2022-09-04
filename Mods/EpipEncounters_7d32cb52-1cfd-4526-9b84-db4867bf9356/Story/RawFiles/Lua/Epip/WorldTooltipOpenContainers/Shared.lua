
---@class Feature_WorldTooltipOpenContainers : Feature
local OpenContainers = {}
Epip.RegisterFeature("WorldTooltipOpenContainers", OpenContainers)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EPIPENCOUNTERS_Feature_WorldTooltipOpenContainers_OpenContainer : NetMessage
---@field CharacterNetID NetId
---@field ItemNetID NetId