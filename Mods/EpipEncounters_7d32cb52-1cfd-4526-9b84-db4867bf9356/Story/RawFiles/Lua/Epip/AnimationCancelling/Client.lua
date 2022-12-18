
local Minimap = Client.UI.Minimap

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")

---------------------------------------------
-- METHODS
---------------------------------------------

-- Require setting to be enabled.
function AnimCancel:IsEnabled()
    return _Feature.IsEnabled(self) and self:GetSettingValue(AnimCancel.Settings.Enabled) == true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the server notifying us it's safe to cancel an animation.
Net.RegisterListener(AnimCancel.NET_MESSAGE, function (_)
    if AnimCancel:IsEnabled() then
        Minimap:ExternalInterfaceCall("pingButtonPressed")
        
        -- Needs a 2-tick delay.
        Timer.StartTickTimer(2, function (_)
            Client.Input.Inject("Key", "escape", "Pressed")
            Client.Input.Inject("Key", "escape", "Released")
        end)
    end
end)