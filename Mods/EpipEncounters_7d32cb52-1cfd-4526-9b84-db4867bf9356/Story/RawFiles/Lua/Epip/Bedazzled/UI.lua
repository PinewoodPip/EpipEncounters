
local Notification = Client.UI.Notification
local MsgBox = Client.UI.MessageBox
local Bedazzled = Epip.GetFeature("Feature_Bedazzled") ---@class Feature_Bedazzled
local Generic = Client.UI.Generic
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local DraggingAreaPrefab = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local SlicedTexture = Generic.GetPrefab("GenericUI.Prefabs.SlicedTexture")
local DiscordRichPresence = Epip.GetFeature("Features.DiscordRichPresence")
local Input = Client.Input
local V = Vector.Create

---@class Features.Bedazzled.UI.Game : GenericUI_Instance
local UI = Generic.Create("Feature_Bedazzled")
Bedazzled.GameUI = UI

UI._Initialized = false
UI._LastHoveredGemClickbox = nil ---@type Vector2?
UI.Board = nil ---@type Features.Bedazzled.GameMode? TODO rename
UI.Gems = {} ---@type table<GUID, GenericUI_Prefab_Bedazzled_Gem>

UI.CELL_BACKGROUND = "Item_Epic"
UI.CELL_SIZE = V(64, 64)
UI.BACKGROUND_SIZE = V(900, 1080)
UI.CELL_BACKGROUND_COLOR = Color.Create(150, 131, 93)
UI.MINIMUM_SCORE_DIGITS = 9
UI.SCORE_FLYOVER_DURATION = 1
UI.SCORE_FLYOVER_Y_OFFSET = -40
UI.SCORE_FLYOVER_TRAVEL_DISTANCE = -50
UI.FORFEIT_DELAY = 2 -- Delay in seconds before the UI closes after a forfeit.
UI.PLAY_AREA_FRAME_BORDER_SIZE = V(20, 20) -- Size of the border around the gem area.

UI.SOUNDS = {
    CLICK = "UI_Game_Skillbar_Unlock",
    LONG_MATCH = "UI_Game_Persuasion_Success",
    MATCH = "UI_MainMenu_CharacterCreation_Plus", -- previously UI_Game_Reward_DropReward
    EXPLOSION = "Items_Objects_UNI_Teleport_Pyramid_Teleport",
    INVALID_MATCH = "UI_Game_ActionUnavailable",
    GAME_OVER = "UI_Game_GameOver",
    SWIPE = "UI_Game_Dialog_Open",
    HYPERCUBE_DETONATION = "UI_Game_XPgain",
}
---Sounds to play when a fusion results in a modifier.
---@type table<Feature_Bedazzled_GemModifier_ID, string>
UI.FUSION_MODIFIER_SOUNDS = {
    Rune = "Items_Inventory_Consumeables_Magic",
    LargeRune = "UI_Game_Party_Merge",
    GiantRune = "UI_Game_Persuasion_Success",
}

---Sounds to play when a fusion results in a gem type transformation.
---@type table<Feature_Bedazzled_GemDescriptor_ID, string>
UI.FUSION_TRANSFORM_SOUNDS = {
    Protean = "UI_Game_Persuasion_Success",
}

UI.Events = {
    GemClicked = SubscribableEvent:New("GemClicked"), ---@type Event<Features.Bedazzled.UI.Game.Events.GemClicked>
    GemHovered = SubscribableEvent:New("GemHovered"), ---@type Event<Features.Bedazzled.UI.Game.Events.GemHovered>
    GameStarted = SubscribableEvent:New("GameStarted"), ---@type Event<Empty>
    NewGameRequested = SubscribableEvent:New("NewGameRequested"), ---@type Event<Empty>
    ClickBoxHovered = SubscribableEvent:New("ClickboxHovered"), ---@type Event<Features.Bedazzled.UI.Game.Events.ClickboxHovered>
    GameForfeited = SubscribableEvent:New("GameForfeited"), ---@type Event<Empty>
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Bedazzled_UI_GemSelection
---@field Position Vector2
---@field InitialMousePosition Vector2
---@field CanSwipe boolean

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.Bedazzled.UI.Game.Events.GemClicked
---@field Position Vector2

---@class Features.Bedazzled.UI.Game.Events.GemHovered
---@field Position Vector2

---@class Features.Bedazzled.UI.Game.Events.ClickboxHovered
---@field GridPosition Vector2
---@field Clickbox GenericUI_Element

---------------------------------------------
-- GEM PREFAB
---------------------------------------------

---@class GenericUI_Prefab_Bedazzled_Gem : GenericUI_Prefab, GenericUI_Element
---@field Gem Feature_Bedazzled_Board_Gem
---@field Root GenericUI_Element_Empty
---@field Icon GenericUI_Element_IggyIcon
local GemPrefab = {
    RUNE_ICONS = {
        Bloodstone = "ELRIC_LOOT_Rune_Bloodstone_Medium_Shadowed",
        Jade = "ELRIC_LOOT_Rune_Jade_Medium_Shadowed",
        Sapphire = "ELRIC_LOOT_Rune_Sapphire_Medium_Shadowed",
        Topaz = "ELRIC_LOOT_Rune_Topaz_Medium_Shadowed",
        Onyx = "ELRIC_LOOT_Rune_Onyx_Medium_Shadowed",
        Emerald = "ELRIC_LOOT_Rune_Emerald_Medium_Shadowed",
        Lapis = "ELRIC_LOOT_Rune_Lapis_Medium_Shadowed",
        TigersEye = "ELRIC_LOOT_Rune_TigersEye_Medium_Shadowed",
    },
    LARGE_RUNE_ICONS = {
        Bloodstone = "ELRIC_LOOT_Rune_Bloodstone_Large_Shadowed",
        Jade = "ELRIC_LOOT_Rune_Jade_Large_Shadowed",
        Sapphire = "ELRIC_LOOT_Rune_Sapphire_Large_Shadowed",
        Topaz = "ELRIC_LOOT_Rune_Topaz_Large_Shadowed",
        Onyx = "ELRIC_LOOT_Rune_Onyx_Large_Shadowed",
        Emerald = "ELRIC_LOOT_Rune_Emerald_Large_Shadowed",
        Lapis = "ELRIC_LOOT_Rune_Lapis_Large_Shadowed",
        TigersEye = "ELRIC_LOOT_Rune_TigersEye_Large_Shadowed",
    },
    GIANT_RUNE_ICONS = {
        Bloodstone = "ELRIC_LOOT_Rune_Bloodstone_Giant_Shadowed",
        Jade = "ELRIC_LOOT_Rune_Jade_Giant_Shadowed",
        Sapphire = "ELRIC_LOOT_Rune_Sapphire_Giant_Shadowed",
        Topaz = "ELRIC_LOOT_Rune_Topaz_Giant_Shadowed",
        Onyx = "ELRIC_LOOT_Rune_Onyx_Giant_Shadowed",
        Emerald = "ELRIC_LOOT_Rune_Emerald_Giant_Shadowed",
        Lapis = "ELRIC_LOOT_Rune_Lapis_Giant_Shadowed",
        TigersEye = "ELRIC_LOOT_Rune_TigersEye_Giant_Shadowed",
    },
    MODIFIER_PRIORITY_LIST = { -- Priorities for icons based on modifiers, from most important to least.
        "GiantRune",
        "LargeRune",
        "Rune",
    },
}
Generic.RegisterPrefab("GenericUI_Prefab_Bedazzled_Gem", GemPrefab)

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param gem Feature_Bedazzled_Board_Gem
---@return GenericUI_Prefab_Bedazzled_Gem
function GemPrefab.Create(ui, id, parent, gem)
    ---@diagnostic disable-next-line: invisible
    local element = GemPrefab:_Create(ui, id) ---@type GenericUI_Prefab_Bedazzled_Gem

    element.Gem = gem

    local root = element:CreateElement("Container", "GenericUI_Element_Empty", parent)
    root:SetMouseMoveEventEnabled(true)
    element.Root = root
    local icon = element:CreateElement("Icon", "GenericUI_Element_IggyIcon", root)
    element.Icon = icon

    -- Offset the icon so its anchor is at the center, for when we tween the scale of the root element.
    icon:SetPosition(-UI.CELL_SIZE[1] / 2, -UI.CELL_SIZE[2]/2)

    root:SetMouseEnabled(false) -- Must disable mouse on root as well else it will consume clicks due to its children, even if those are mouse disabled as well.
    root:SetMouseChildren(false)

    element:UpdateIcon()

    return element
end

---@param tween GenericUI_ElementTween
function GemPrefab:Tween(tween)
    self.Root:Tween(tween)
end

function GemPrefab:Update()
    local gem = self.Gem
    local root = self.Root
    local x, y = UI.GamePositionToUIPosition(self.Gem.X, gem:GetPosition())
    local gemState = gem.State.ClassName

    -- TODO extract method/hook
    if gemState == "Feature_Bedazzled_Board_Gem_State_InvalidSwap" or gemState == "Feature_Bedazzled_Board_Gem_State_Swapping" or gemState == "Features.Bedazzled.Board.Gem.State.MoveFrom" then
        -- Handled by tween
    else
        root:SetPosition(x, y)
    end

    self:UpdateIcon()
end

---Gets the icon for a modified gem.
---@param gemType string
---@param modifier string
---@return icon
function GemPrefab.GetIconForModifier(gemType, modifier)
    local icon

    if modifier == "Rune" then
        icon = GemPrefab.RUNE_ICONS[gemType]
    elseif modifier == "LargeRune" then
        icon = GemPrefab.LARGE_RUNE_ICONS[gemType]
    elseif modifier == "GiantRune" then
        icon = GemPrefab.GIANT_RUNE_ICONS[gemType]
    end

    return icon or "unknown"
end

function GemPrefab:UpdateIcon()
    local iconElement = self.Icon
    local gem = self.Gem
    local icon

    for _,mod in ipairs(GemPrefab.MODIFIER_PRIORITY_LIST) do
        if gem:HasModifier(mod) then
            icon = self.GetIconForModifier(gem.Type, mod)
            break
        end
    end
    
    if not icon then
        icon = gem:GetIcon()
    end

    iconElement:SetIcon(icon, UI.CELL_SIZE:unpack())
end

---Returns the gem's position on the UI grid, in pixels.
function GemPrefab:GetGridPosition()
    local gem = self.Gem
    local x, y = gem.X, gem.Y

    return UI.GamePositionToUIPosition(x, y)
end

function GemPrefab:Destroy()
    self.Root:Destroy()
    self.Root, self.Icon = nil, nil
end

---------------------------------------------
-- METHODS
---------------------------------------------

function UI:Show()
    local currentBoard = UI.Board

    -- A board must be set to show the UI.
    if not currentBoard then
        UI:__Error("Show", "A board must be set before showing the UI; use Setup()")
    else -- Otherwise resume playing
        currentBoard:SetPaused(false)
    end

    self:SetPositionRelativeToViewport("center", "center")

    Client.UI._BaseUITable.Show(self)
end

---Sets up a new game.
---@param board Features.Bedazzled.GameMode
function UI.Setup(board)
    local oldBoard = UI.Board

    -- Unsubscribe from previous board
    if oldBoard then
        oldBoard.Events.Updated:Unsubscribe("BedazzledUI_Updated")
        oldBoard.Events.MatchExecuted:Unsubscribe("BedazzledUI_MatchExecuted")
        oldBoard.Events.InvalidMovePerformed:Unsubscribe("BedazzledUI_InvalidMovePerformed")
        oldBoard.Events.GemAdded:Unsubscribe("BedazzledUI_GemAdded")
        oldBoard.Events.GameOver:Unsubscribe("BedazzledUI_GameOver")
        oldBoard.Events.GemTransformed:Unsubscribe("BedazzledUI_GemTransformed")
    end

    UI.Board = board

    UI._Initialize(board)

    -- Update UI when the board updates.
    board.Events.Updated:Subscribe(function (ev)
        UI.Update(ev.DeltaTime)
    end, {StringID = "BedazzledUI_Updated"})

    -- Create text flyovers for scoring matches.
    board.Events.MatchExecuted:Subscribe(function (ev)
        UI.OnMatchExecuted(ev)
    end, {StringID = "BedazzledUI_MatchExecuted"})

    -- Play sound for invalid swaps.
    board.Events.InvalidMovePerformed:Subscribe(function (_)
        UI:PlaySound(UI.SOUNDS.INVALID_MATCH)
    end, {StringID = "BedazzledUI_InvalidMovePerformed"})

    board.Events.GemAdded:Subscribe(function (ev)
        local gem = ev.Gem
        local guid = Text.GenerateGUID()
        local element = GemPrefab.Create(UI, guid, UI.GemContainer, gem)

        -- Forward state change events.
        gem.Events.StateChanged:Subscribe(function (stateChangeEv)
            UI.OnGemStateChanged(gem, stateChangeEv.NewState, stateChangeEv.OldState)
        end)

        UI.Gems[guid] = element
    end, {StringID = "BedazzledUI_GemAdded"})

    board.Events.GameOver:Subscribe(function (ev)
        UI.OnGameOver(ev)
    end, {StringID = "BedazzledUI_GameOver"})

    -- Update gem visuals immediately when a gem transforms.
    -- This is so the new visuals are reflected even when the board is paused (for cheats)
    board.Events.GemTransformed:Subscribe(function (ev)
        local element = UI.GetGemElement(ev.Gem)
        element:UpdateIcon()
    end, {StringID = "BedazzledUI_GemTransformed"})

    -- Update reset button label
    UI.ResetButton:SetLabel(Bedazzled.TranslatedStrings.Label_GiveUp)
    UI.ResetButton:SetVisible(true) -- Might've been hidden from a previous forfeit.

    UI.Events.GameStarted:Throw()

    UI:Show()
end

function UI:Hide()
    UI.Board:SetPaused(true)
    Client.UI._BaseUITable.Hide(self)
end

---Returns whether the current game has ended.
---@return boolean -- Also `true` if no game has been started yet.
function UI.IsGameEnded()
    return UI.Board == nil or not UI.Board:IsRunning()
end

---@param gem Feature_Bedazzled_Board_Gem
---@param newState Feature_Bedazzled_Board_Gem_StateClassName
---@param oldState Feature_Bedazzled_Board_Gem_State
function UI.OnGemStateChanged(gem, newState, oldState)
    local element = UI.GetGemElement(gem)
    local state

    if oldState.ClassName == "Feature_Bedazzled_Board_Gem_State_Swapping" then
        element:UpdateIcon()
    end

    -- Play sound for hypercubes being consumed
    -- The sound effect for this has a long delay, which is why we play it on swap.
    if newState == "Feature_Bedazzled_Board_Gem_State_Swapping" and gem.Type == "Protean" then
        Timer.Start(0.2, function (_)
            UI:PlaySound(UI.SOUNDS.HYPERCUBE_DETONATION)
        end)
    end

    if newState == "Feature_Bedazzled_Board_Gem_State_Swapping" then
        state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Swapping
        local otherGem = state.OtherGem
        local otherElement = UI.GetGemElement(otherGem)

        element.Gem, otherElement.Gem = otherElement.Gem, element.Gem

        local element1x, element1y = UI.GamePositionToUIPosition(element.Gem:GetBoardPosition())
        local element2x, element2y = UI.GamePositionToUIPosition(otherElement.Gem:GetBoardPosition())

        -- Tween both gems to make it look like they're swapping places
        -- In the game logic, this actually happens instantly.
        -- Match-checks are delayed until the Swapping state ends.
        otherElement:Tween({
            EventID = "Bedazzled_Swap1",
            FinalValues = {
                x = element2x,
                y = element2y,
            },
            StartingValues = {
                x = element1x,
                y = element1y,
            },
            Function = "Cubic",
            Ease = "EaseOut",
            Duration = state.Duration,
        })
        element:Tween({
            EventID = "Bedazzled_Swap1",
            FinalValues = {
                x = element1x,
                y = element1y,
            },
            StartingValues = {
                x = element2x,
                y = element2y,
            },
            Function = "Cubic",
            Ease = "EaseOut",
            Duration = state.Duration,
        })
    elseif newState == "Feature_Bedazzled_Board_Gem_State_Consuming" then
        state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Consuming

        element:Tween({
            EventID = "Bedazzled_Consume",
            FinalValues = {
                scaleX = 0,
                scaleY = 0,
            },
            StartingValues = {
                scaleX = 1.2,
                scaleY = 1.2,
            },
            Function = "Quadratic",
            Ease = "EaseInOut",
            Duration = state.Duration,
            OnComplete = function (_)
                element:Destroy()
                UI.Gems[element.ID] = nil
            end
        })
    elseif newState == "Feature_Bedazzled_Board_Gem_State_InvalidSwap" then -- Play invalid swap animation
        state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_InvalidSwap

        local otherGem = state.OtherGem
        local otherElement = UI.GetGemElement(otherGem)

        local element1x, element1y = UI.GamePositionToUIPosition(element.Gem:GetBoardPosition())
        local element2x, element2y = UI.GamePositionToUIPosition(otherElement.Gem:GetBoardPosition())

        element:Tween({
            EventID = "Bedazzled_InvalidSwap",
            FinalValues = {
                x = element2x,
                y = element2y,
            },
            StartingValues = {
                x = element1x,
                y = element1y,
            },
            Function = "Quadratic",
            Ease = "EaseInOut",
            Duration = state.Duration / 2,
            OnComplete = function (_) -- Animate back to initial position
                element:Tween({
                    EventID = "Bedazzled_InvalidSwap_Return",
                    FinalValues = {
                        x = element1x,
                        y = element1y,
                    },
                    StartingValues = {
                        x = element2x,
                        y = element2y,
                    },
                    Function = "Quadratic",
                    Ease = "EaseInOut",
                    Duration = state.Duration / 2,
                })
            end
        })
    elseif newState == "Feature_Bedazzled_Board_Gem_State_Fusing" then
        state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Fusing

        local targetGem = state.TargetGem
        local targetX, targetY = UI.GamePositionToUIPosition(targetGem:GetBoardPosition())

        element:Tween({
            EventID = "Bedazzled_Fusion",
            FinalValues = {
                x = targetX,
                y = targetY,
                scaleX = 0.7,
                scaleY = 0.7,
            },
            Function = "Cubic",
            Ease = "EaseOut",
            Duration = state.Duration,
            OnComplete = function (_)
                element:Destroy()
                UI.Gems[element.ID] = nil
            end
        })
    elseif newState == "Feature_Bedazzled_Board_Gem_State_Transforming" then
        state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Transforming

        element:Tween({
            EventID = "Bedazzled_Transforming_1",
            FinalValues = {
                scaleX = 1.2,
                scaleY = 1.2,
            },
            Function = "Cubic",
            Ease = "EaseOut",
            Duration = state.Duration / 2,
            OnComplete = function (_)
                element:Tween({
                    EventID = "Bedazzled_Transforming_2",
                    FinalValues = {
                        scaleX = 1,
                        scaleY = 1,
                    },
                    Function = "Cubic",
                    Ease = "EaseIn",
                    Duration = state.Duration / 2,
                })
            end
        })
    elseif newState == "Features.Bedazzled.Board.Gem.State.MoveFrom" then
        state = gem.State ---@type Features.Bedazzled.Board.Gem.State.MoveFrom
        local elementX, elementY = UI.GamePositionToUIPosition(element.Gem:GetBoardPosition())
        local oldX, oldY = UI.GamePositionToUIPosition(state.OriginalPosition:unpack())

        -- Tween the gem to make it look like it's moving.
        -- In the game logic, this actually happens instantly.
        -- Match-checks are delayed until the state ends.
        element:Tween({
            EventID = "Bedazzled_MoveFrom",
            FinalValues = {
                x = elementX,
                y = elementY,
            },
            StartingValues = {
                x = oldX,
                y = oldY,
            },
            Function = "Cubic",
            Ease = "EaseOut",
            Duration = state.Duration,
        })
    end
end

---Shows the game over text.
---@param ev Feature_Bedazzled_Board_Event_GameOver
function UI.OnGameOver(ev)
    local text = UI.GameOverText

    -- Update the game over text and fade it in 
    text:SetText(Text.Format("%s\n%s", {
        FormatArgs = {
            {
                Text = Bedazzled.TranslatedStrings.GameOver:GetString(),
                Size = 45,
                Color = Color.CreateFromHex(Color.LARIAN.RED):ToHex(),
            },
            {
                Text = ev.Reason,
                Size = 25,
            },
        }
    }))
    text:SetVisible(true)
    text:Tween({
        EventID = "FadeIn",
        Duration = 0.8,
        StartingValues = {
            alpha = 0,
        },
        FinalValues = {
            alpha = 1,
        },
        Function = "Cubic",
        Ease = "EaseOut",
    })

    -- Update reset button text
    UI.ResetButton:SetLabel(Text.CommonStrings.NewGame)
end

---Returns whether the UI is in an interactable game state.
---@return boolean?
function UI.IsInteractable()
    local board = UI.Board

    -- Interaction in pause is still possible in debug (for setting up crazy matches)
    return board and (not board:IsPaused() or Bedazzled:IsDebug()) and board:IsRunning() and board:IsInteractable()
end

---@param gem Feature_Bedazzled_Board_Gem
---@return GenericUI_Prefab_Bedazzled_Gem
function UI.GetGemElement(gem)
    local element

    for _,gemElement in pairs(UI.Gems) do
        if gemElement.Gem == gem then
            element = gemElement
        end
    end

    return element
end

---@return number, number --Width, height, in pixels.
function UI.GetBoardDimensions()
    return UI.Board.Size[2] * UI.CELL_SIZE[1], UI.Board.Size[1] * UI.CELL_SIZE[2]
end

function UI.CreateText(id, parent, label, align, size)
    local text = TextPrefab.Create(UI, id, parent, label, align, size)
    text:SetStroke(Color.Create(0, 0, 0):ToDecimal(), 2, 1, 15, 15)

    return text
end

---@param match Feature_Bedazzled_Match
function UI.CreateScoreFlyover(match)
    -- We need to calculate the UI position to spawn the text at
    -- we spawn it at the center top of the rect formed by all gems in the match

    local leftmostGem
    local rightmostGem
    local topmostGem
    if #match.Fusions == 0 then -- Use position of consumed gems if there are no fusions
        leftmostGem = match.Gems[1]
        rightmostGem = match.Gems[1]
        topmostGem = match.Gems[1]

        for _,gem in ipairs(match.Gems) do
            if gem.X < leftmostGem.X then
                leftmostGem = gem
            end
            if gem.X > rightmostGem.X then
                rightmostGem = gem
            end
            if gem:GetPosition() > topmostGem:GetPosition() then
                topmostGem = gem
            end
        end
    else -- Use first fusion
        local fusion = match.Fusions[1]

        leftmostGem, rightmostGem, topmostGem = fusion.TargetGem, fusion.TargetGem, fusion.TargetGem
    end

    local left = V(UI.GamePositionToUIPosition(leftmostGem:GetBoardPosition()))
    local right = V(UI.GamePositionToUIPosition(rightmostGem:GetBoardPosition()))
    local _, top = UI.GamePositionToUIPosition(topmostGem:GetBoardPosition())
    local positionX = left[1] + ((right[1] - left[1]) / 2) - UI.CELL_SIZE[1]/2
    local position = V(positionX, top + UI.SCORE_FLYOVER_Y_OFFSET)

    local text = UI.CreateText("MatchScoreFlyoverText", UI.GemContainer, tostring(match:GetScore()), "Center", UI.CELL_SIZE)
    text:SetPosition(position:unpack())
    text.Element:Tween({
        EventID = "FlyUp",
        Duration = UI.SCORE_FLYOVER_DURATION,
        Function = "Quadratic",
        Ease = "EaseInOut",
        FinalValues = {
            y = position[2] + UI.SCORE_FLYOVER_TRAVEL_DISTANCE,
            alpha = 0,
        },
        OnComplete = function (_)
            text.Element:Destroy()
        end
    })
end

---Formats a score number, adding commas between groups of 3 digits.
---@param score integer
---@param addPadding boolean? Defaults to `true`
---@return string
function UI._FormatScoreNumber(score, addPadding)
    local pointsLabel = addPadding ~= false and Text.AddPadding(tostring(score), UI.MINIMUM_SCORE_DIGITS, "0") or tostring(score)

    -- Add comma separators
    local newStr = ""
    for i=#pointsLabel,1,-1 do
        local index = #pointsLabel + 1 - i
        newStr = newStr .. pointsLabel:sub(index, index)

        if (i - 1) % 3 == 0 and i ~= 1 then
            newStr = newStr .. ","
        end
    end

    return newStr
end

---Updates the score displays.
function UI.UpdateScore()
    local highScore = Bedazzled.GetHighScore(UI.Board.GameMode, UI.Board:GetModifierConfigs())
    local highScorePoints = highScore and highScore.Score or 0
    local text = UI.ScoreText
    local pointsLabel = UI._FormatScoreNumber(UI.Board:GetScore())
    local highScorePointsLabel = UI._FormatScoreNumber(highScorePoints)

    text:SetText(Text.Format(Bedazzled.TranslatedStrings.Score:GetString(), {
        FormatArgs = {
            pointsLabel,
            highScorePointsLabel,
        }
    }))
end

---@param board Feature_Bedazzled_Board
function UI._Initialize(board)
    if not UI._Initialized then -- TODO support resizing the board
        local gemAreaSize = V(board.Size[1] * UI.CELL_SIZE[1], board.Size[2] * UI.CELL_SIZE[2])

        -- Set UI size
        local uiObject = UI:GetUI()
        uiObject.SysPanelSize = UI.BACKGROUND_SIZE

        -- UI background
        local bg = UI:CreateElement("Background", "GenericUI_Element_TiledBackground")
        UI.Background = bg
        bg:SetBackground("Note", UI.BACKGROUND_SIZE:unpack())

        -- Header and scoring
        local topContainer = bg:AddChild("TopContainer", "GenericUI_Element_VerticalList")
        topContainer:SetPositionRelativeToParent("TopLeft", 0, 80)

        UI.CreateText("TitleHeader", topContainer, Text.Format(Bedazzled.TranslatedStrings.GameTitle:GetString(), {Size = 42, Color = "7E72D6", FontType = Text.FONTS.ITALIC}), "Center", V(UI.BACKGROUND_SIZE[1], 50))

        local scoreText = UI.CreateText("ScoreText", topContainer, "", "Center", V(UI.BACKGROUND_SIZE[1], 100))
        UI.ScoreText = scoreText

        -- Draggable area
        DraggingAreaPrefab.Create(UI, "DraggableArea", bg, UI.BACKGROUND_SIZE)

        -- Gem area
        local gemContainer = bg:AddChild("GemContainer", "GenericUI_Element_Empty")
        local BOARD_WIDTH = board.Size[2] * UI.CELL_SIZE[1]
        UI.GemContainer = gemContainer
        gemContainer:SetPosition(UI.BACKGROUND_SIZE[1]/2 - BOARD_WIDTH/2, 300)

        -- Frame for gem area
        local gemAreaFrame = SlicedTexture.Create(UI, "GemAreaFrame", gemContainer, SlicedTexture:GetStyle("SimpleTooltip"), gemAreaSize + UI.PLAY_AREA_FRAME_BORDER_SIZE)
        gemAreaFrame:SetPosition(-UI.PLAY_AREA_FRAME_BORDER_SIZE[1] / 2, -UI.PLAY_AREA_FRAME_BORDER_SIZE[2] / 2)

        local closeButton = bg:AddChild("CloseButton", "GenericUI_Element_Button")
        closeButton:SetType("Close")
        closeButton:SetPositionRelativeToParent("TopRight", -50, 50)
        closeButton.Events.Pressed:Subscribe(function (_)
            UI:Hide()
        end)

        -- Create clickboxes for selecting gems
        local clickboxGrid = gemContainer:AddChild("ClickboxGrid", "GenericUI_Element_Grid")
        clickboxGrid:SetGridSize(board.Size:unpack())
        clickboxGrid:SetElementSpacing(0, 0)
        for i=1,board.Size[1],1 do
            for j=1,board.Size[2],1 do
                local clickbox = clickboxGrid:AddChild("Clickbox_" .. i .. "_" .. j, "GenericUI_Element_Color")
                clickbox:SetColor(UI.CELL_BACKGROUND_COLOR)
                clickbox:SetSize(UI.CELL_SIZE:unpack())
                clickbox:SetMouseMoveEventEnabled(true)

                clickbox.Events.MouseDown:Subscribe(function (_)
                    UI.OnGemClickboxClicked(j, board.Size[1] - i + 1)
                end)
                clickbox.Events.MouseOver:Subscribe(function (_)
                    UI.OnGemClickboxHovered(j, board.Size[1] - i + 1)
                end)
                clickbox.Events.MouseMove:Subscribe(function (_)
                    UI.Events.ClickBoxHovered:Throw({
                        Clickbox = clickbox,
                        GridPosition = V(j, board.Size[1] - i + 1),
                    })
                end)
            end
        end
        UI.GridClickbox = clickboxGrid

        -- Game Over text
        local gameOverText = UI.CreateText("GameOverText", bg, "", "Center", V(UI.BACKGROUND_SIZE[1], 150))
        gameOverText:SetPositionRelativeToParent("Center", 0, -50)
        UI.GameOverText = gameOverText

        -- Give up / new game button
        local resetButton = ButtonPrefab.Create(UI, "ForfeitButton", bg, ButtonPrefab:GetStyle("LargeRed"))
        resetButton:SetLabel(Bedazzled.TranslatedStrings.Label_GiveUp:GetString())
        resetButton.Events.Pressed:Subscribe(function (_)
            UI._OnResetPressed()
        end)
        resetButton:SetPositionRelativeToParent("Center", 0, 320)
        UI.ResetButton = resetButton
    else -- Cleanup previous elements
        for _,gem in pairs(UI.Gems) do
            gem:Destroy()
        end

        UI.Gems = {}
    end

    UI.GameOverText:SetVisible(false)

    UI._Initialized = true
end

---@param x number
---@param y number
---@return number, number
function UI.GamePositionToUIPosition(x, y)
    local board = UI.Board

    local UIboardHeight = UI.CELL_SIZE[2] * board.Size[1]
    local UIBoardWidth = UI.CELL_SIZE[1] * board.Size[2]
    local gameBoardHeight = Bedazzled.GEM_SIZE * board.Size[1]
    local gameBoardWidth = board.Size[2]

    local translatedPositionY = y / gameBoardHeight * UIboardHeight
    translatedPositionY = UIboardHeight - translatedPositionY - UI.CELL_SIZE[2]

    local translatedPositionX = (x - 1) / gameBoardWidth * UIBoardWidth

    translatedPositionX = translatedPositionX + UI.CELL_SIZE[1] / 2
    translatedPositionY = translatedPositionY + UI.CELL_SIZE[2] / 2

    return translatedPositionX, translatedPositionY
end

---@param dt number In seconds.
---@diagnostic disable-next-line: unused-local
function UI.Update(dt)
    for _,element in pairs(UI.Gems) do
        element:Update()
    end

    UI.UpdateScore()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Handle clickboxes being hovered over.
---@param x integer
---@param y integer
function UI.OnGemClickboxHovered(x, y)
    UI._LastHoveredGemClickbox = V(x, y)
    UI.Events.GemHovered:Throw({
        Position = UI._LastHoveredGemClickbox,
    })
end

---Returns the board being currently played.
---@return Feature_Bedazzled_Board?
function UI.GetBoard()
    return UI.Board
end

---Handle clickboxes being clicked.
---@param x integer
---@param y integer
function UI.OnGemClickboxClicked(x, y)
    UI.Events.GemClicked:Throw({
        Position = V(x, y),
    })
end

-- Listen for matches being executed.
---@param ev Feature_Bedazzled_Board_Event_MatchExecuted
function UI.OnMatchExecuted(ev)
    local reason = ev.Match.Reason

    -- Play extra sounds for special gem creation
    for _,fusion in ipairs(ev.Match.Fusions) do
        if fusion.TargetType then
            UI:PlaySound(UI.FUSION_TRANSFORM_SOUNDS[fusion.TargetType] or "")
        end
        if fusion.TargetModifier then
            UI:PlaySound(UI.FUSION_MODIFIER_SOUNDS[fusion.TargetModifier] or "")
        end
    end

    -- Play a different sound for explosions.
    if reason == ev.Match.REASONS.EXPLOSION then
        UI:PlaySound(UI.SOUNDS.EXPLOSION)
    else
        UI:PlaySound(UI.SOUNDS.MATCH)
    end

    -- Only create flyovers for matches that affect score.
    if ev.Match.Score ~= 0 then
        UI.CreateScoreFlyover(ev.Match)
    end
end

---Forwards event to request a new game.
function UI._RequestNewGame()
    UI.Events.NewGameRequested:Throw()
end

---Handle the forfeit or new game button being pressed.
function UI._OnResetPressed()
    local isInGame = UI.Board and UI.Board:IsRunning()
    if isInGame then
        MsgBox.Open({
            Header = Bedazzled.TranslatedStrings.Label_GiveUp:GetString(),
            Message = Bedazzled.TranslatedStrings.MsgBox_GiveUp_Body:GetString(),
            ID = "Features.Bedazzled.Forfeit",
            Buttons = {
                {ID = 1, Text = Text.CommonStrings.Confirm:GetString()},
                {ID = 2, Text = Text.CommonStrings.Cancel:GetString()},
            }
        })
    else
        UI._RequestNewGame()
    end
end
MsgBox.RegisterMessageListener("Features.Bedazzled.Forfeit", MsgBox.Events.ButtonPressed, function (buttonID)
    if buttonID == 1 then
        UI.ResetButton:SetVisible(false) -- Hide the reset button so it doesn't show an erroneous label during the game over.
        UI.Board:EndGame(Bedazzled.TranslatedStrings.GameOver_Reason_Forfeited)

        -- Hide the UI after a delay so the game over reason can be read.
        Timer.Start(UI.FORFEIT_DELAY, function (_)
            UI:Hide()
            UI.Events.GameForfeited:Throw()
        end)
    end
end)

-- Cheat: middle-click pauses board updates.
Input.Events.KeyPressed:Subscribe(function (ev)
    if Bedazzled:IsDebug() and UI.Board and ev.InputID == "middle" then
        local board = UI.Board
        local wasPaused = board:IsPaused()

        board:SetPaused(not wasPaused)

        Client.UI.Notification.ShowNotification(wasPaused and "Board unpaused" or "Board paused")
    end
end)

-- Listen for new high scores being set to show a notification.
Bedazzled.Events.NewHighScore:Subscribe(function (ev)
    local board = UI.Board
    local randomGem
    -- Use board logic for picking the random gem, if available.
    if board then
        randomGem = board:GetRandomGemDescriptor()
    else
        local _, gemDesc = next(Bedazzled.GetGemDescriptors())
        randomGem = gemDesc
    end
    local toastLabel = Text.Format(Bedazzled.TranslatedStrings.NewHighScore:GetString(), {
        FormatArgs = {
            ev.Score,
        }
    })

    Notification.ShowIconNotification(toastLabel, randomGem:GetIcon())
end)

-- Show a custom Discord Rich Presence if that feature is set to "overhaul mode"
DiscordRichPresence.Hooks.GetPresence:Subscribe(function (ev)
    local mode = DiscordRichPresence:GetSettingValue(DiscordRichPresence.Settings.Mode)
    if mode == DiscordRichPresence.MODES.OVERHAUL and UI:IsVisible() and UI.Board then
        local board = UI.Board
        ev.Line1 = Bedazzled.TranslatedStrings.GameTitle:GetString()
        ev.Line2 = Bedazzled.TranslatedStrings.DiscordRichPresence_Line2:Format({
            FormatArgs = {
                board:GetName(),
                UI._FormatScoreNumber(board.Score, false),
            },
        })
    end
end)

---------------------------------------------
-- COMMANDS
---------------------------------------------

-- Force a game over.
Ext.RegisterConsoleCommand("bedazzledgameover", function (_)
    if UI.Board and UI.Board:IsRunning() then
        UI.Board:EndGame("Forced game-over from commands.")
    end
end)