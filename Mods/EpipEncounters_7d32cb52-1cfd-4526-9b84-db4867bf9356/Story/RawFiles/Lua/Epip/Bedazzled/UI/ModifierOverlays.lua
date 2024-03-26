
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Notification = Client.UI.Notification
local UI = Bedazzled.GameUI
local V = Vector.Create

local Overlays = {
    LABEL_SIZE = V(UI.BACKGROUND_SIZE[1] * 0.8, 30),
    ENRAGE_GEM_SPAWN_SOUND = "UI_Lobby_AssignMember",
    SOUNDS = {
        EPIPE_CONSUMED_AMBIENCE = "UI_Game_PerceptionReveal_Puzzle",
        EPIPE_CONSUMED_IMPACT = "UI_Lobby_AssignMember",
    },
}

local TSK = {
    Label_MovesLeft = Bedazzled:RegisterTranslatedString("h9692b408ge89fg4f6cgb5d6gc0554e9fdd0c", {
        Text = "%d Moves Left",
        ContextDescription = "Label for move limit; first parameter is amount of moves left",
    }),
    Label_GemEnraged_1 = Bedazzled:RegisterTranslatedString({
        Handle = "hdc4fb40cgce17g4d19g836bga575f703a664",
        Text = "A gem has enraged!",
        ContextDescription = [[Shown when a gem becomes enraged from the "Raid Mechanics" modifier]],
    }),
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Bedazzled.UI.Game.ModifierOverlays.Gem : GenericUI_Prefab_Bedazzled_Gem
---@field Gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
---@field EnrageTimer GenericUI_Prefab_Text

---------------------------------------------
-- METHODS
---------------------------------------------

---Initializes the overlays based on the current board.
function Overlays.Setup()
    local board = UI.Board
    local modifiersSet = board:GetModifiers()

    -- Cleanup should be run first due to the _Initialized check.
    Overlays._Cleanup()
    Overlays._Initialize()

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

    -- Raid Mechanics gem overlays
    local raidMechanicsMod = modifiersSet["Features.Bedazzled.Board.Modifiers.RaidMechanics"]
    if raidMechanicsMod then
        ---@cast raidMechanicsMod Features.Bedazzled.Board.Modifiers.RaidMechanics
        Overlays._SetupRaidMechanics(moveLimitMod)
    end

    local cementMixerMod = modifiersSet["Features.Bedazzled.Board.Modifiers.CementMixer"]
    if cementMixerMod then
        ---@cast cementMixerMod Features.Bedazzled.Board.Modifiers.CementMixer
        Overlays._SetupCementMixer(cementMixerMod)
    end
end

---Sets up the time limit label.
---@param modifier Features.Bedazzled.Board.Modifiers.TimeLimit
function Overlays._SetupTimeLimitDisplay(modifier)
    local list = Overlays.LabelList
    local label = TextPrefab.Create(UI, "Modifiers.TimeLimit.Label", list, "", "Center", Overlays.LABEL_SIZE)

    -- Update the label when the board updates.
    UI.Board.Events.Updated:Subscribe(function (_)
        local color = modifier.RemainingTime >= 60 and Color.WHITE or Color.LARIAN.RED -- Show time left below a minute in red.

        label:SetText(Text.Format(Text.FormatTime(modifier.RemainingTime), {
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
    UI.Board.Events.MovePerformed:Subscribe(function (_)
        UpdateLabel()
    end, {Priority = -1}) -- Not strictly necessary as the modifier should've been applied prior to this.
end

---Sets up gem timer displays for the RaidMechanics modifier.
---@param modifier Features.Bedazzled.Board.Modifiers.RaidMechanics
---@diagnostic disable-next-line: unused-local
function Overlays._SetupRaidMechanics(modifier)
    local board = UI.Board

    -- All event subscribers should run after enrage timers are rolled.
    -- Setup timers for new gems. Must be done even if they don't roll as enraged,
    -- as the property may be passed onto swapped gems.
    board.Events.GemAdded:Subscribe(function (ev)
        local gem = ev.Gem ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
        local element = UI.GetGemElement(gem) ---@cast element Features.Bedazzled.UI.Game.ModifierOverlays.Gem
        local label = TextPrefab.Create(UI, "Modifier.RaidMechanics.EnrageTimer." .. Text.GenerateGUID(), element.Icon, "1", "Center", V(50, 32))
        label:SetSize(50, label:GetTextSize()[2]) -- Auto-size text based on placeholder.
        label:SetPositionRelativeToParent("Center")
        label:SetStroke(Color.Create(0, 0, 0):ToDecimal(), 2, 1, 15, 15)
        element.EnrageTimer = label

        Overlays._UpdateEnrageTimer(gem, element)

        -- Show notification for new enraged gems.
        if gem.EnrageTimer then
            Notification.ShowWarning(TSK.Label_GemEnraged_1:GetString(), nil, Overlays.ENRAGE_GEM_SPAWN_SOUND)
        end
    end, {Priority = -1})

    -- Update enrage timers after every move.
    board.Events.MovePerformed:Subscribe(function (_)
        for _,gem in ipairs(board:GetGems()) do
            ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
            if gem.EnrageTimer then
                Overlays._UpdateEnrageTimer(gem, UI.GetGemElement(gem))
            end
        end
    end, {Priority = -1})

    -- Update timers when gems have their data changed.
    board.Events.GemDataApplied:Subscribe(function (ev)
        Overlays._UpdateEnrageTimer(ev.Gem, UI.GetGemElement(ev.Gem))
    end)
end

---Sets up sounds for the CementMixer modifier.
---@param mod Features.Bedazzled.Board.Modifiers.CementMixer
---@diagnostic disable-next-line: unused-local
function Overlays._SetupCementMixer(mod)
    local board = UI.Board

    -- Play gratifying sounds when an Epipe is consumed.
    board.Events.MatchExecuted:Subscribe(function (ev)
        for _,gem in ipairs(ev.Match:GetAllGems()) do
            if gem.Type == "Epipe" then
                -- This is so epic that it has an "impact" sound AND a long ambience jingle.
                UI:PlaySound(Overlays.SOUNDS.EPIPE_CONSUMED_AMBIENCE)
                UI:PlaySound(Overlays.SOUNDS.EPIPE_CONSUMED_IMPACT)
            end
        end
    end)
end

---Updates the enrage timer display for a gem.
---@param gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
---@param element Features.Bedazzled.UI.Game.ModifierOverlays.Gem
function Overlays._UpdateEnrageTimer(gem, element)
    local label = element.EnrageTimer
    label:SetVisible(gem.EnrageTimer ~= nil)
    if gem.EnrageTimer then
        label:SetText(Text.Format("%s", {
            FormatArgs = {element.Gem.EnrageTimer},
            Color = Color.LARIAN.RED,
        }))
    end
end

function Overlays._Initialize()
    if Overlays._Initialized then return end

    local labelList = UI.Background:AddChild("ModifiersLabelList", "GenericUI_Element_VerticalList")
    labelList:SetSizeOverride(V(Overlays.LABEL_SIZE[1], 200))
    labelList:SetPositionRelativeToParent("Top", 0, 200)
    UI.Background:SetChildIndex(labelList, 2)
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