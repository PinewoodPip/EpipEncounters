
---@type Feature
local MovementCosts = {
    TSKHANDLE_AP_COST = "h984df648geba3g4eaagb035g2088d0e58f72", -- "[1]AP"
    TSKHANDLE_MOVEMENT_DISTANCE = "hd589d36bg8be6g49ceg90adg6b6b338fa76d", -- "[1]m"

    _currentMouseText = nil, ---@type string?

    TranslatedStrings = {
        Template_FreeMovementRemaining = {
            Handle = "hb7eede78gae41g4816g8ddeg08502b5e2e77",
            Text = "%s%s free movement remaining",
            ContextDescription = "Tooltip for movement costs in combat while holding shift. Parameters are distance and meter suffix ('m' in English)",
        },
    },
}
Epip.RegisterFeature("TooltipAdjustments.MovementCosts", MovementCosts)

---------------------------------------------
-- METHODS
---------------------------------------------

---Modifies a movement cost tooltip to show partial AP costs and remaining free movement..
---@param text string
---@return string? `nil` if the passed text is not a movement cost tooltip.
function MovementCosts._GetExpandedMovementCostText(text)
    local apLabel = Text.Replace(Text.GetTranslatedString(MovementCosts.TSKHANDLE_AP_COST, "[1]AP"), "[1]", "")
    local movementLabel = Text.ReplaceLarianPlaceholders(Text.GetTranslatedString(MovementCosts.TSKHANDLE_MOVEMENT_DISTANCE, "[1]m"))
    local pattern = "(%d+)" .. apLabel .. "<br><font color=\"#DBDBDB\">(.+)" .. movementLabel .. "</font><br><font color=\"#C80030\">(.*)</font>"
    local shownAPCost, distance, extraText = text:match(pattern)
    local newText = nil

    if distance and Client.Input.IsShiftPressed() then
        local char = Client.GetCharacter()
        local movement = Character.GetMovement(char) / 100
        local apCost = tonumber(distance) / movement
        local partialAP = char.RemainingMoveDistance
        local freeMovementLabelTemplate = MovementCosts.TranslatedStrings.Template_FreeMovementRemaining:GetString()
        local freeMovementLabel = string.format(freeMovementLabelTemplate, Text.Round(partialAP * movement, 1), movementLabel)
        if apCost < 0.1 then
            apCost = Text.Round(apCost, 2)
        else
            apCost = Text.Round(apCost, 1)
        end
        apLabel = apLabel:gsub("^ ", "") -- Remove the leading space if there already was one (ex. in languages such as Polish)

        newText = Text.Format("%s %s (%s %s; %s)<br><font color=\"#DBDBDB\">%s%s</font><br><font color=\"#C80030\">%s</font>", {
            FormatArgs = {shownAPCost, apLabel, apCost, apLabel, freeMovementLabel, distance, movementLabel, extraText}
        })
    elseif distance and movementLabel:sub(1, 1) ~= " " then -- Add a space between the amount of AP and the text anyways, cuz it's prettier that way. Some game languages already have this.
        newText = Text.Format("%s %s<br><font color=\"#DBDBDB\">%s%s</font><br><font color=\"#C80030\">%s</font>", {
            FormatArgs = {shownAPCost, apLabel, distance, movementLabel, extraText}
        })
    end

    return newText
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Keep track of the current mouse text, for instant re-rendering when shift is toggled.
Client.Tooltip.Hooks.RenderMouseTextTooltip:Subscribe(function (ev)
    MovementCosts._currentMouseText = ev.Text

    ev.Text = MovementCosts._GetExpandedMovementCostText(ev.Text) or ev.Text
end)
Client.Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "lshift" and MovementCosts._currentMouseText then
        local label = MovementCosts._GetExpandedMovementCostText(MovementCosts._currentMouseText) or MovementCosts._currentMouseText

        Client.Tooltip.ShowMouseTextTooltip(label)
    end
end)
Client.UI.TextDisplay.Events.TextRemoved:Subscribe(function (_)
    MovementCosts._currentMouseText = nil
end)