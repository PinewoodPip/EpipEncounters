
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
Net.RegisterListener(AnimCancel.NET_MESSAGE, function (payload)
    local char = Client.GetCharacter()

    if AnimCancel:IsEnabled() and AnimCancel.IsEligible(char, payload.SkillID) then
        local delay = AnimCancel.GetDelay(char, payload.SkillID)

        local func = function (_)
            Minimap:ExternalInterfaceCall("pingButtonPressed")

            Timer.StartTickTimer(AnimCancel.DEFAULT_DELAY, function (_)
                Client.Input.Inject("Key", "escape", "Pressed")
                Client.Input.Inject("Key", "escape", "Released")
            end)
        end

        Timer.Start(delay, func)
    end
end)