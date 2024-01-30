
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local UI = Bedazzled.GameUI
local V = Vector.Create

local Overlays = {
    LABEL_SIZE = V(UI.BACKGROUND_SIZE[1] * 0.8, 30)
}

local TSK = {
    Label_MovesLeft = Bedazzled:RegisterTranslatedString("h9692b408ge89fg4f6cgb5d6gc0554e9fdd0c", {
        Text = "%d Moves Left",
        ContextDescription = "Label for move limit; first parameter is amount of moves left",
    })
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Initializes the overlays based on the current board.
function Overlays.Setup()
    local board = UI.Board

    -- Cleanup should be run first due to the _Initialized check.
    Overlays._Cleanup()
    Overlays._Initialize()

    -- Create a map of modifiers for quicker lookups
    local modifiers = board:GetModifiers()
    local modifiersSet = {} ---@type table<string, Features.Bedazzled.Board.Modifier>
    for _,mod in ipairs(modifiers) do
        modifiersSet[mod:GetClassName()] = mod
    end

    -- Setup time limit display
    local timeLimitMod = modifiersSet["Features.Bedazzled.Board.Modifiers.TimeLimit"]
    if timeLimitMod then
        ---@cast timeLimitMod Features.Bedazzled.Board.Modifiers.TimeLimit
        Overlays._SetupTimeLimitDisplay(timeLimitMod)
    end

    -- Setup move limit display
    local moveLimitMod = modifiersSet["Features.Bedazzled.Board.Modifiers.MoveLimit"]
    if moveLimitMod then
        ---@cast moveLimitMod Features.Bedazzled.Board.Modifiers.MoveLimit
        Overlays._SetupMoveLimitDisplay(moveLimitMod)
    end
end

---Sets up the time limit label.
---@param modifier Features.Bedazzled.Board.Modifiers.TimeLimit
function Overlays._SetupTimeLimitDisplay(modifier)
    local list = Overlays.LabelList
    local label = TextPrefab.Create(UI, "Modifiers.TimeLimit.Label", list, "", "Center", Overlays.LABEL_SIZE)

    -- Update the label when the board updates.
    UI.Board.Events.Updated:Subscribe(function (_)
        local minutes = modifier.RemainingTime // 60
        local seconds = math.ceil(modifier.RemainingTime % 60)
        if seconds == 60 then -- Round up to a whole minute.
            minutes = minutes + 1
            seconds = 0
        end
        local color = minutes > 0 and Color.WHITE or Color.LARIAN.RED -- Show time left below a minute in red.

        minutes, seconds = Text.RemoveTrailingZeros(minutes), tostring(seconds) -- RemoveTrailingZeros is necessary as even an integer division afterwards can produce ex. "1.0"
        label:SetText(Text.Format("%s:%s", {
            FormatArgs = {
                Text.AddPadding(minutes, 2, "0", "front"),
                Text.AddPadding(seconds, 2, "0", "front"),
            },
            Color = color,
        }))
    end, {Priority = -1}) -- Not strictly necessary as the modifier should've been applied prior to this.
end

---Sets up the move limit label.
---@param modifier Features.Bedazzled.Board.Modifiers.MoveLimit
function Overlays._SetupMoveLimitDisplay(modifier)
    local list = Overlays.LabelList
    local label = TextPrefab.Create(UI, "Modifiers.MoveLimit.Label", list, "", "Center", Overlays.LABEL_SIZE)
    local function UpdateLabel()
        local color = modifier.RemainingMoves > 10 and Color.WHITE or Color.LARIAN.RED -- Show remaining moves below a certain threshold in red.
        label:SetText(TSK.Label_MovesLeft:Format({
            FormatArgs = {modifier.RemainingMoves},
            Color = color,
        }))
    end

    -- Update label immediately upon starting the game.
    UpdateLabel()

    -- Update the label after successful moves.
    UI.Board.Events.SwapPerformed:Subscribe(function (_)
        UpdateLabel()
    end, {Priority = -1}) -- Not strictly necessary as the modifier should've been applied prior to this.
end

function Overlays._Initialize()
    if Overlays._Initialized then return end

    local labelList = UI.Background:AddChild("ModifiersLabelList", "GenericUI_Element_VerticalList")
    labelList:SetSizeOverride(V(Overlays.LABEL_SIZE[1], 200))
    labelList:SetPositionRelativeToParent("Top", 0, 200)
    Overlays.LabelList = labelList

    Overlays._Initialized = true
end

---Removes elements from the overlay from previous.
function Overlays._Cleanup()
    if not Overlays._Initialized then return end
    Overlays.LabelList:Clear()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the game UI starting a new game to setup the overlay.
UI.Events.GameStarted:Subscribe(function (_)
    Overlays.Setup()
end)