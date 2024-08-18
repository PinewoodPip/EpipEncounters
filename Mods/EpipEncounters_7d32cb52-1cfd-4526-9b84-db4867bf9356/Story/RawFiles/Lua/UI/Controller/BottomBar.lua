
---@class UI.Controller.BottomBar : UI
local BottomBar = {
    SLOTS_PER_ROW = 13,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        ActiveStateToggled = {}, ---@type Event<{Active:boolean}>
    }
}
Epip.InitializeUI(Ext.UI.TypeID.bottomBar_c, "BottomBarC", BottomBar, false)
Client.UI.Controller.BottomBar = BottomBar

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the bar is open and being interacted with.
---@return boolean
function BottomBar.IsActive()
    return BottomBar:GetRoot().active
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward events for activating & deactivating the bar.
BottomBar:RegisterInvokeListener("activateBar", function (_)
    BottomBar.Events.ActiveStateToggled:Throw({Active = true})
end, "After")
BottomBar:RegisterInvokeListener("deactivateBar", function (_)
    BottomBar.Events.ActiveStateToggled:Throw({Active = false})
end, "After")
