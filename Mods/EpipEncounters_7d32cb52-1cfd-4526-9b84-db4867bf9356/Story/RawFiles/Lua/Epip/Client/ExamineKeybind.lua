
local ContextMenu = Client.UI.ContextMenu

---@class Feature_ExamineKeybind : Feature
local ExamineKeybind = {
    _opening = false,

    DELAY = 0.05,
    ACTION_ID = "EpipEncounters_Examine",
}
Epip.RegisterFeature("ExamineKeybind", ExamineKeybind)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the hotkey being pressed.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == ExamineKeybind.ACTION_ID then
        ExamineKeybind:DebugLog("Opening examine context menu")

        ExamineKeybind._opening = true

        -- Clearing previous inputs is necessary to simulate mouse events properly - otherwise it will either fail, or result in esc/enter being sent instead for reasons unknown.
        for inputID,_ in pairs(Client.Input.pressedKeys) do
            Client.Input.Inject("Key", inputID, "Released")
        end

        -- Open context menu.
        Client.Input.Inject("Mouse", "right2", "Pressed")
        Client.Input.Inject("Mouse", "right2", "Released")

        Timer.Start(ExamineKeybind.DELAY, function (_)
            if ContextMenu:IsVisible() then
                local data = ContextMenu.vanillaContextData
                local hasExamineButton = false

                -- Look for Examine button.
                for _,entry in ipairs(data) do
                    if entry.ActionID == ContextMenu.VANILLA_ACTIONS.EXAMINE then
                        ContextMenu:ExternalInterfaceCall("buttonPressed", entry.Index, entry.ActionID)

                        hasExamineButton = true
                        break
                    end
                end

                -- Close the UI ourselves if we have not found the button.
                if not hasExamineButton then
                    ContextMenu.Close()
                end
            end

            Timer.Start(ExamineKeybind.DELAY, function (_)
                ExamineKeybind._opening = false
            end)
        end)
    end
end)

-- Prevent sounds from playing in the context menu while we're opening it.
ContextMenu:RegisterCallListener("PlaySound", function (ev)
    if ExamineKeybind._opening then
        ev:PreventAction()
    end
end, "Vanilla")