
---------------------------------------------
-- Allows animation cancelling via Right Shift + R + Delete key cord,
-- like in Stardew Valley. 
---------------------------------------------

local Input = Client.Input
local AnimationCancelling = Epip.GetFeature("Feature_AnimationCancelling")

---@type Feature
local AnimCancelHotkey = {}
Epip.RegisterFeature("Features.AprilFools.AnimationCancellingHotkey", AnimCancelHotkey)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Request the client character's animation to be cancelled
-- when the key coord is executed.
Input.Events.KeyPressed:Subscribe(function (ev)
    if ev.InputID == "delete_key" and Input.IsKeyPressed("rshift") and Input.IsKeyPressed("r") then -- Press order of rshift and R keys doesn't matter.
        AnimationCancelling.CancelAnimation()
    end
end, {EnabledFunctor = Epip.IsAprilFools})
