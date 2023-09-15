
---------------------------------------------
-- Implements a navigation component that emulates mouse events: mouse out/over when focus changes, and clicking.
---------------------------------------------

local Generic = Client.UI.Generic

---@class GenericUI.Navigation.Components.Generic : GenericUI.Navigation.Component
local GenericComponent = {
    CONSUMED_IGGY_EVENTS = {
        "UIAccept",
    },
}
Generic:RegisterClass("GenericUI.Navigation.Components.Generic", GenericComponent, {"GenericUI.Navigation.Component"})

---------------------------------------------
-- METHODS
---------------------------------------------

function GenericComponent:OnIggyEvent(event)
    -- Emulate clicks.
    if event.EventID == "UIAccept" and event.Timing == "Up" then
        self.__Target.Events.MouseDown:Throw()
        self.__Target.Events.MouseUp:Throw()
    end
end

function GenericComponent:OnFocusChanged(focused)
    -- Emulate mouse over/out.
    if focused then
        self.__Target.Events.MouseOver:Throw()
    else
        self.__Target.Events.MouseOut:Throw()
    end
end
