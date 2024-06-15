
---------------------------------------------
-- Implements a navigation component that emulates mouse events: mouse out/over when focus changes, and clicking.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation

---@class GenericUI.Navigation.Components.Generic : GenericUI.Navigation.Component
local GenericComponent = {
    CONSUMED_IGGY_EVENTS = {
        "UIAccept",
    },
}
Navigation:RegisterClass("GenericUI.Navigation.Components.Generic", GenericComponent, {"GenericUI.Navigation.Component"})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function GenericComponent:OnIggyEvent(event)
    -- Emulate clicks.
    if event.EventID == "UIAccept" and event.Timing == "Up" then
        local target = self.__Target
        target.Events.MouseDown:Throw()
        target.Events.MouseUp:Throw()

        if target.Type == "GenericUI_Element_Slot" then
            ---@cast target GenericUI_Element_Slot
            target.Events.Clicked:Throw()
        end

        return true
    end
end

---@override
function GenericComponent:OnFocusChanged(focused)
    -- Emulate mouse over/out.
    if focused then
        self.__Target.Events.MouseOver:Throw()
    else
        self.__Target.Events.MouseOut:Throw()
    end
end
