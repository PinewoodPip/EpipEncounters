
---------------------------------------------
-- Implements a navigation component that emulates mouse events: mouse out/over when focus changes, and clicking.
---------------------------------------------

local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Component = Navigation:GetClass("GenericUI.Navigation.Component")

---@class GenericUI.Navigation.Components.Generic : GenericUI.Navigation.Component
local GenericComponent = {}
Navigation:RegisterClass("GenericUI.Navigation.Components.Generic", GenericComponent, {"GenericUI.Navigation.Component"})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
---@return GenericUI.Navigation.Components.Generic
function GenericComponent:Create(target)
    local instance = Component.Create(self, target) ---@cast instance GenericUI.Navigation.Components.Generic
    -- Register interact action
    instance:AddAction({
        ID = "Interact",
        Name = Text.CommonStrings.Interact,
        Inputs = {["UIAccept"] = true}, -- TODO make customizable
    })
    return instance
end

---@override
function GenericComponent:OnIggyEvent(event)
    if Component.OnIggyEvent(self, event) then return true end

    -- Emulate clicks.
    -- A pcall is used as the target might've been destroyed as a result of the click events.
    local success, consumed = pcall(function ()
        if self:CanConsumeInput("Interact", event.EventID) and event.Timing == "Up" then
            local target = self.__Target
            target.Events.MouseDown:Throw()
            target.Events.MouseUp:Throw()
            if target.Type == "GenericUI_Element_Slot" then
                ---@cast target GenericUI_Element_Slot
                target.Events.Clicked:Throw()
            end
            return true
        end
        return false
    end)
    return success and consumed or false
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
