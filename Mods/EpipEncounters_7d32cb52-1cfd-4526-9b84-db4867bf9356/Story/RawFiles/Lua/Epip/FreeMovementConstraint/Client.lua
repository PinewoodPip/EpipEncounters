
---------------------------------------------
-- Allows combat movement to be restricted to only use the character's remaining free movement distance
-- by shift+clicking the move-to position.
---------------------------------------------

local Tooltip = Client.Tooltip
local Input = Client.Input

---@type Feature
local FreeMovementConstraint = {
    REMAINING_MOVEMENT_THRESHOLD = 0.05, -- Remaining movement below which a character is considered to not have any free movement left, in meters.

    TranslatedStrings = {
        Label_TooltipHint = {
            Handle = "hdc84c8f0g3b0ag48d5g83e3gaa2f4acbd6bd",
            Text = "Shift+click to only use your free movement.",
            ContextDescription = [[Tooltip shown when holding shift in combat over a position to move to]],
        },
    },
}
Epip.RegisterFeature("Features.FreeMovementConstraint", FreeMovementConstraint)
local TSK = FreeMovementConstraint.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether char is previewing a movement character task.
---@param char EclCharacter
---@@return boolean
function FreeMovementConstraint.IsPreviewingMovement(char)
    local task = char.InputController.PreviewTask
    return task and task.ActionTypeId == 0 -- Move-to task
end

---Returns whether char is previewing a move-to task and has enough free movement for the constraint to be applicable.
---@param char EclCharacter
---@@return boolean
function FreeMovementConstraint.CanApply(char)
    return FreeMovementConstraint.IsPreviewingMovement(char) and char.RemainingMoveDistance > FreeMovementConstraint.REMAINING_MOVEMENT_THRESHOLD
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- When starting a move task through shift+click, cancel it when remaining movement drops below the threshold.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "left2" and ev.State == "Released" and Input.IsShiftPressed() then
        local char = Client.GetCharacter()
        if FreeMovementConstraint.CanApply(char) then
            local listenerID = Text.GenerateGUID()
            local timeElapsedMs = 0

            -- Cancel the movement once remaining movement drops below the threshold.
            GameState.Events.RunningTick:Subscribe(function (tickEv)
                char = Client.GetCharacter()
                timeElapsedMs = timeElapsedMs + tickEv.DeltaTime
                local partialAP = char.RemainingMoveDistance -- Note: the game only ever seems to decrement this in increments of 0.05m
                if partialAP <= FreeMovementConstraint.REMAINING_MOVEMENT_THRESHOLD then
                    Client.Input.Inject("Mouse", "right2", "Pressed")
                    Client.Input.Inject("Mouse", "right2", "Released")
                    GameState.Events.RunningTick:Unsubscribe(listenerID)
                elseif not Character.IsMoving(char) and timeElapsedMs > 100 then -- For sanity. IsMoving() is false on the first tick, so the time check is necessary.
                    GameState.Events.RunningTick:Unsubscribe(listenerID)
                end
            end, {StringID = listenerID})
        end
    end
end)

-- Show a control hint by the move-to cursor tooltip in combat while shift is pressed.
Tooltip.Hooks.RenderMouseTextTooltip:Subscribe(function (ev)
    if Input.IsShiftPressed() and FreeMovementConstraint.CanApply(Client.GetCharacter()) then
        ev.Text = ev.Text .. TSK.Label_TooltipHint:Format({Color = Color.LARIAN.LIGHT_GRAY, Size = 17}) .. "<br>" -- The end of the tooltip already has a line break.
    end
end)
