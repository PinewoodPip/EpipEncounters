
---------------------------------------------
-- Adds an Input Action to delay your turn in combat.
---------------------------------------------

local StatusConsole = Client.UI.StatusConsole
local Input = Client.Input

---@type Feature
local DelayTurnKeybind = {
    TranslatedStrings = {
        InputAction_DelayTurn_Name = {
            Handle = "hb6cd5759g32d7g4bcag8808g0d46643d48dc",
            Text = "Delay turn",
            ContextDescription = [[Keybind name]],
        },
        InputAction_DelayTurn_Description = {
            Handle = "hfa03eb8cgcea2g4cb3g9584gf849f2b12a4f",
            Text = "In combat, delays your active character's turn.",
            ContextDescription = [[]],
        },
    }
}
Epip.RegisterFeature("Features.DelayTurnKeybind", DelayTurnKeybind)
local TSK = DelayTurnKeybind.TranslatedStrings

local DelayTurnInputAction = DelayTurnKeybind:RegisterInputAction("Undo", {
    Name = TSK.InputAction_DelayTurn_Name,
    Description = TSK.InputAction_DelayTurn_Description,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Emulate pressing the delay turn button when the input action is used.
Input.RegisterActionExecutedListener(DelayTurnInputAction, function (_)
    local root = StatusConsole:GetRoot()
    local fightButtons = root.fightButtons_mc
    local duoButtons = fightButtons.duoBtns_mc
    local delayButton = duoButtons.waitBtn_mc

    -- If the character has delayed their turn,
    -- sending the UICall again will bug out their turn, preventing them from acting,
    -- thus this sanity check is necessary.
    local canDelay = delayButton.visible and not delayButton.disabled_mc.visible
    if canDelay then
        StatusConsole:ExternalInterfaceCall("GuardPressed")
    end
end, {EnabledFunctor = function ()
    return StatusConsole:Exists()
end})
