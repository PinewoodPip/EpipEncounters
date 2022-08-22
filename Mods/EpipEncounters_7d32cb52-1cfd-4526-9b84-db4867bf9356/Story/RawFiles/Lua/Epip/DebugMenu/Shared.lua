
---@class Feature_DebugMenu : Feature
local DebugMenu = {
    SAVE_FILENAME = "Epip_DebugMenu.json",
    SAVE_VERSION = 0,

    ---@type table<string, table<string, DebugMenu_State>>
    State = {},
}
Epip.RegisterFeature("DebugMenu", DebugMenu)

---@class DebugMenu_State
---@field Debug boolean
---@field ShutUp boolean
---@field Enabled boolean

---------------------------------------------
-- METHODS
---------------------------------------------

---@param modTable string
---@param featureID string
function DebugMenu.GetState(modTable, featureID)
    local allStates = DebugMenu.State
    local state = {Debug = false, ShutUp = false, Enabled = true} ---@type DebugMenu_State
    setmetatable(state, {
        __index = function(self, key, ...)
            if key == "GetFeature" then
                return function(...) return Epip.GetFeature(modTable, featureID) end
            end
        end
    })

    if not allStates[modTable] then allStates[modTable] = {} end

    if allStates[modTable][featureID] then
        state = allStates[modTable][featureID]
    else -- Initialize state
        DebugMenu.State[modTable][featureID] = state
    end

    return state
end