
local Notification = Client.UI.Notification
local MsgBox = Client.UI.MessageBox
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Input = Client.Input
local V = Vector.Create

local UI = Generic.Create("Feature_Bedazzled")
UI:Hide()

UI._Initialized = false
UI.Board = nil ---@type Feature_Bedazzled_Board?
UI.Gems = {} ---@type table<GUID, GenericUI_Prefab_Bedazzled_Gem>
UI.GemSelection = nil ---@type Feature_Bedazzled_UI_GemSelection

UI.CELL_BACKGROUND = "Item_Epic"
UI.CELL_SIZE = V(64, 64)
UI.BACKGROUND_SIZE = V(900, 1080)
UI.MOUSE_SWIPE_DISTANCE_THRESHOLD = 30
UI.CELL_BACKGROUND_COLOR = Color.Create(150, 131, 93)
UI.MINIMUM_SCORE_DIGITS = 9
UI.SCORE_FLYOVER_DURATION = 1
UI.SCORE_FLYOVER_Y_OFFSET = -40
UI.SCORE_FLYOVER_TRAVEL_DISTANCE = -50
UI.HoveredGridPosition = nil ---@type Vector2?

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

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Bedazzled_UI_GemSelection
---@field Position Vector2
---@field InitialMousePosition Vector2
---@field CanSwipe boolean

---------------------------------------------
-- GEM PREFAB
---------------------------------------------

---@class GenericUI_Prefab_Bedazzled_Gem : GenericUI_Prefab, GenericUI_Element
---@field Gem Feature_Bedazzled_Board_Gem
---@field Root GenericUI_Element_Empty
---@field Icon GenericUI_Element_IggyIcon
local GemPrefab = {
    RUNE_ICONS = {
        Bloodstone = "Item_LOOT_Rune_Bloodstone_Medium",
        Jade = "Item_LOOT_Rune_Jade_Medium",
        Sapphire = "Item_LOOT_Rune_Sapphire_Medium",
        Topaz = "Item_LOOT_Rune_Topaz_Medium",
        Onyx = "Item_LOOT_Rune_Onyx_Medium",
        Emerald = "Item_LOOT_Rune_Emerald_Medium",
        Lapis = "Item_LOOT_Rune_Lapis_Medium",
        TigersEye = "Item_LOOT_Rune_TigersEye_Medium",
    },
    LARGE_RUNE_ICONS = {
        Bloodstone = "Item_LOOT_Rune_Bloodstone_Large",
        Jade = "Item_LOOT_Rune_Jade_Large",
        Sapphire = "Item_LOOT_Rune_Sapphire_Large",
        Topaz = "Item_LOOT_Rune_Topaz_Large",
        Onyx = "Item_LOOT_Rune_Onyx_Large",
        Emerald = "Item_LOOT_Rune_Emerald_Large",
        Lapis = "Item_LOOT_Rune_Lapis_Large",
        TigersEye = "Item_LOOT_Rune_TigersEye_Large",
    },
    GIANT_RUNE_ICONS = {
        Bloodstone = "Item_LOOT_Rune_Bloodstone_Giant",
        Jade = "Item_LOOT_Rune_Jade_Giant",
        Sapphire = "Item_LOOT_Rune_Sapphire_Giant",
        Topaz = "Item_LOOT_Rune_Topaz_Giant",
        Onyx = "Item_LOOT_Rune_Onyx_Giant",
        Emerald = "Item_LOOT_Rune_Emerald_Giant",
        Lapis = "Item_LOOT_Rune_Lapis_Giant",
        TigersEye = "Item_LOOT_Rune_TigersEye_Giant",
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
    element.Root = root
    local icon = element:CreateElement("Icon", "GenericUI_Element_IggyIcon", root)
    element.Icon = icon

    -- Offset the icon so its anchor is at the center, for when we tween the scale of the root element.
    icon:SetPosition(-UI.CELL_SIZE[1] / 2, -UI.CELL_SIZE[2]/2)

    root:SetMouseEnabled(false)
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

    if gemState == "Feature_Bedazzled_Board_Gem_State_InvalidSwap" or gemState == "Feature_Bedazzled_Board_Gem_State_Swapping" then
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

    -- Create a new game if there was no board
    if not currentBoard then
        UI.Setup()
    else -- Otherwise resume playing
        currentBoard:SetPaused(false)
    end

    self:SetPositionRelativeToViewport("center", "center")

    Client.UI._BaseUITable.Show(self)
end

-- Sets up a new game.
function UI.Setup()
    local board = Bedazzled.CreateBoard("Classic")
    local oldBoard = UI.Board

    -- Unsubscribe from previous board
    if oldBoard then
        oldBoard.Events.Updated:Unsubscribe("BedazzledUI_Updated")
        oldBoard.Events.MatchExecuted:Unsubscribe("BedazzledUI_MatchExecuted")
        oldBoard.Events.InvalidSwapPerformed:Unsubscribe("BedazzledUI_InvalidSwapPerformed")
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
    board.Events.InvalidSwapPerformed:Subscribe(function (_)
        UI:PlaySound(UI.SOUNDS.INVALID_MATCH)
    end, {StringID = "BedazzledUI_InvalidSwapPerformed"})

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

    board.Events.GameOver:Subscribe(function (_)
        UI.OnGameOver()
    end, {StringID = "BedazzledUI_GameOver"})

    -- Update gem visuals immediately when a gem transforms.
    -- This is so the new visuals are reflected even when the board is paused (for cheats)
    board.Events.GemTransformed:Subscribe(function (ev)
        local element = UI.GetGemElement(ev.Gem)
        element:UpdateIcon()
    end, {StringID = "BedazzledUI_GemTransformed"})

    UI.ResetButton:SetVisible(false)
end

function UI:Hide()
    UI.Board:SetPaused(true)
    Client.UI._BaseUITable.Hide(self)
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
    end
end

---Shows the game over text.
function UI.OnGameOver()
    local text = UI.GameOverText

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

    -- Clear gem selection
    UI.ClearSelection()
    UI.SecondarySelector:SetVisible(false)

    -- Show new game button
    UI.ResetButton:SetVisible(true)
end

---@return boolean
function UI.HasGemSelection()
    return UI.GemSelection ~= nil
end

---@return Vector2?
function UI.GetSelectedPosition()
    return UI.GemSelection and UI.GemSelection.Position or nil
end

---Returns the gem currently selected by the cursor.
---@return Feature_Bedazzled_Board_Gem?
function UI.GetSelectedGem()
    local board = UI.GetBoard()
    local gem = nil

    if board and UI.HasGemSelection() then
        gem = board:GetGemAt(UI.GetSelectedPosition():unpack())
    end

    return gem
end

---Returns whether mouse swipes are possible in the current state.
---Mouse swipes require a gem selection.
---@return boolean
function UI.CanMouseSwipe()
    local canSwipe = UI.GemSelection and UI.GemSelection.CanSwipe or false

    canSwipe = canSwipe and UI.IsInteractable()

    return canSwipe
end

---Returns whether the UI is in an interactable game state.
---@return boolean?
function UI.IsInteractable()
    local board = UI.Board

    -- Interaction in pause is still possible in debug (for setting up crazy matches)
    return board and (not board:IsPaused() or Bedazzled:IsDebug()) and board:IsRunning()
end

function UI.ClearSelection()
    local selector = UI.Selector

    UI.GemSelection = nil
    selector:SetVisible(false)
end

---Selects a gem.
---@param gem Feature_Bedazzled_Board_Gem
function UI.SelectGem(gem)
    local element = UI.GetGemElement(gem)
    local selector = UI.Selector
    local visualPositionX, visualPositionY = element:GetGridPosition()

    if UI.IsInteractable() then
        visualPositionX = visualPositionX - UI.CELL_SIZE[1]/2
        visualPositionY = visualPositionY - UI.CELL_SIZE[2]/2
    
        selector:SetPosition(visualPositionX, visualPositionY)
        selector:SetVisible(true)
    
        UI.GemSelection = {
            Position = V(UI.Board:GetGemGridCoordinates(gem)),
            InitialMousePosition = V(Client.GetMousePosition()),
            CanSwipe = true,
        }
    end
end

---@param pos1 Vector2
---@param pos2 Vector2
function UI.RequestSwap(pos1, pos2)
    UI.Board:Swap(pos1, pos2)

    UI.ClearSelection()
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

function UI._FormatScoreNumber(score)
    local pointsLabel = Text.AddPadding(tostring(score), UI.MINIMUM_SCORE_DIGITS, "0")
    
    -- Add comma separators
    local newStr = ""
    for i=1,#pointsLabel,1 do
        local index = #pointsLabel + 1 - i
        newStr = pointsLabel:sub(index, index) .. newStr

        if i % 3 == 0 and i ~= #pointsLabel then
            newStr = "," .. newStr
        end
    end

    return newStr
end

---Updates the score displays.
function UI.UpdateScore()
    local highScore = Bedazzled.GetHighScore(UI.Board.GameMode)
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
        local draggableArea = bg:AddChild("DraggableArea", "GenericUI_Element_TiledBackground")
        draggableArea:SetBackground("Black", UI.BACKGROUND_SIZE:unpack())
        draggableArea:SetAlpha(0)
        draggableArea:SetAsDraggableArea()

        local gemContainer = bg:AddChild("GemContainer", "GenericUI_Element_Empty")
        local BOARD_WIDTH = board.Size[2] * UI.CELL_SIZE[1]
        UI.GemContainer = gemContainer
        gemContainer:SetPosition(UI.BACKGROUND_SIZE[1]/2 - BOARD_WIDTH/2, 200)

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
    
                clickbox.Events.MouseDown:Subscribe(function (_)
                    UI.OnGemClickboxClicked(j, board.Size[1] - i + 1)
                end)
                clickbox.Events.MouseOver:Subscribe(function (_)
                    UI.OnGemClickboxHovered(j, board.Size[1] - i + 1)
                end)
                clickbox.Events.MouseOut:Subscribe(function (_)
                    UI.OnGemClickboxMouseOut(j, board.Size[1] - i + 1)
                end)
            end
        end

        -- Hide secondary selector when mouse exits the grid
        clickboxGrid.Events.MouseOut:Subscribe(function (_)
            UI.SecondarySelector:SetVisible(false)
        end)

        -- Gem selector
        local secondarySelector = gemContainer:AddChild("SecondarySelector", "GenericUI_Element_IggyIcon")
        secondarySelector:SetIcon("Item_Rare", UI.CELL_SIZE:unpack())
        secondarySelector:SetVisible(false)
        secondarySelector:SetMouseEnabled(false)
        UI.SecondarySelector = secondarySelector

        local selector = gemContainer:AddChild("Selector", "GenericUI_Element_IggyIcon")
        selector:SetIcon("Item_Divine", UI.CELL_SIZE:unpack())
        selector:SetVisible(false)
        selector:SetMouseEnabled(false)
        UI.Selector = selector
        
        -- Game Over text
        local gameOverText = UI.CreateText("GameOverText", bg, Text.Format("%s\n%s", {
            FormatArgs = {
                {
                    Text = Bedazzled.TranslatedStrings.GameOver:GetString(),
                    Size = 45,
                    Color = Color.CreateFromHex(Color.LARIAN.RED):ToHex(),
                },
                {
                    Text = Bedazzled.TranslatedStrings.GameOverSubTitle:GetString(),
                    Size = 25,
                },
            }
        }), "Center", V(UI.BACKGROUND_SIZE[1], 150))
        gameOverText:SetPositionRelativeToParent("Center", 0, -150)
        UI.GameOverText = gameOverText

        -- Reset button
        local resetButton = bg:AddChild("ResetButton", "GenericUI_Element_Button")
        resetButton:SetType("RedBig")
        resetButton:SetText(Text.CommonStrings.NewGame:GetString(), 15)
        resetButton.Events.Pressed:Subscribe(function (_)
            UI._OnNewGamePressed()
        end)
        resetButton:SetPositionRelativeToParent("Center", 0, 220)
        resetButton:SetVisible(false)
        UI.ResetButton = resetButton
    else -- Cleanup previous elements
        for _,gem in pairs(UI.Gems) do
            gem:Destroy()
        end

        UI.Gems = {}
    end

    UI.GameOverText:SetVisible(false)
    UI.ClearSelection()

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
    local gem = UI.Board:GetGemAt(x, y)
    local element = UI.GetGemElement(gem)
    local selector = UI.SecondarySelector

    if gem and element and UI.IsInteractable() then
        local visualPositionX, visualPositionY = element:GetGridPosition()

        visualPositionX = visualPositionX - UI.CELL_SIZE[1]/2
        visualPositionY = visualPositionY - UI.CELL_SIZE[2]/2

        selector:SetPosition(visualPositionX, visualPositionY)
        selector:SetVisible(true)
    end

    UI.HoveredGridPosition = (gem and element) and V(x, y) or nil
end

---Handle mouse leaving clickboxes.
---@param x integer
---@param y integer
---@diagnostic disable-next-line: unused-local
function UI.OnGemClickboxMouseOut(x, y)
    UI.HoveredGridPosition = nil
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
    local newSelection = V(x, y)
    local gem = UI.Board:GetGemAt(x, y)
    local element = UI.GetGemElement(gem)

    if gem and element and gem:IsIdle() then
        if UI.HasGemSelection() and newSelection == UI.GetSelectedPosition() then -- Deselect position
            UI.ClearSelection()
        elseif UI.HasGemSelection() and gem:IsAdjacentTo(UI.GetSelectedGem()) then
            UI.RequestSwap(UI.GetSelectedPosition(), V(x, y))
        else -- Select gem or change selection
            UI.SelectGem(gem)
        end
    end
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

    UI.CreateScoreFlyover(ev.Match)
end

---Fired when the new game button is pressed.
function UI._OnNewGamePressed()
    local isInGame = UI.Board and UI.Board:IsRunning()

    if isInGame then
        MsgBox.Open({
            Header = Text.CommonStrings.NewGame:GetString(),
            Message = Bedazzled.TranslatedStrings.NewGamePrompt:GetString(),
            ID = "Feature_Bedazzled_NewGame",
            Buttons = {
                {ID = 1, Text = Text.CommonStrings.Confirm:GetString()},
                {ID = 2, Text = Text.CommonStrings.Cancel:GetString()},
            }
        })
    else
        UI.Setup()
    end
end
MsgBox.RegisterMessageListener("Feature_Bedazzled_NewGame", MsgBox.Events.ButtonPressed, function (buttonID)
    if buttonID == 1 then
        UI.Setup()
    end
end)

-- Listen for mouse swipe gestures.
Input.Events.MouseMoved:Subscribe(function (_)
    if UI.CanMouseSwipe() then
        local currentPos = V(Client.GetMousePosition())
        local difference = currentPos - UI.GemSelection.InitialMousePosition

        if Vector.GetLength(difference) >= UI.MOUSE_SWIPE_DISTANCE_THRESHOLD then
            -- Get the dominant axis
            local swipeDirection = V(1, 0)
            if difference[1] < 0 then
                swipeDirection = V(-1, 0)
            end

            if difference[2] > 0 and difference[2] > math.abs(difference[1]) then
                swipeDirection = V(0, -1)
            elseif difference[2] < 0 and math.abs(difference[2]) > math.abs(difference[1]) then
                swipeDirection = V(0, 1)
            end

            UI.RequestSwap(UI.GetSelectedPosition(), UI.GetSelectedPosition() + swipeDirection)

            UI:PlaySound(UI.SOUNDS.SWIPE)
        end
    end
end)

-- Stop listening for swipes if left click is released.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "left2" and ev.State == "Released" then
        if UI.HasGemSelection() then
            -- Also play a click sound. This is here so it doesn't play while swiping.
            UI:PlaySound(UI.SOUNDS.CLICK) 

            UI.GemSelection.CanSwipe = false
        end
    end
end)

-- Add Bedazzled option to gem context menus.
local function IsRuneCraftingMaterial(item) -- TODO move
    local RUNE_MATERIAL_STATS = {
        LOOT_Bloodstone_A = "Bloodstone",
        TOOL_Pouch_Dust_Bone_A = "Bone",
        LOOT_Clay_A = "Clay",
        LOOT_Emerald_A = "Emerald",
        LOOT_Granite_A = "Granite",
        LOOT_OreBar_A_Iron_A = "Iron",
        LOOT_Jade_A = "Jade",
        LOOT_Lapis_A = "Lapis",
        LOOT_Malachite_A = "Malachite",
        LOOT_Obsidian_A = "Obsidian",
        LOOT_Onyx_A = "Onyx",
        LOOT_Ruby_A = "Ruby",
        LOOT_Sapphire_A = "Sapphire",
        LOOT_OreBar_A_Silver_A = "Silver",
        LOOT_OreBar_A_Steel_A = "Steel",
        LOOT_Tigerseye_A = "TigersEye",
        LOOT_Topaz_A = "Topaz",
    }

    return RUNE_MATERIAL_STATS[item.StatsId] ~= nil
end
Client.UI.ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    if IsRuneCraftingMaterial(item) then
        Client.UI.ContextMenu.AddElement({
            {id = "epip_Feature_Bedazzled", type = "button", text = "Bedazzle"},
        })
    end
end)

-- Start the game when the context menu option is selected.
Client.UI.ContextMenu.RegisterElementListener("epip_Feature_Bedazzled", "buttonPressed", function(_, _)
    UI:Show()
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

-- Cheat: right-click cycles gem types.
Input.Events.KeyPressed:Subscribe(function (ev)
    if Bedazzled:IsDebug() and ev.InputID == "right2" and UI.Board then
        local pos = UI.HoveredGridPosition
        local board = UI.Board

        if pos then
            local descriptors = table.deepCopy(Bedazzled.GetGemDescriptors()) ---@type table<string, Feature_Bedazzled_Gem>
            local list = {} ---@type Feature_Bedazzled_Gem[]
            for _,v in pairs(descriptors) do
                table.insert(list, v.Type)
            end
            table.sort(list)

            local currentGem = board:GetGemAt(pos:unpack())

            if currentGem then
                local currentIndex = table.reverseLookup(list, currentGem:GetDescriptor().Type)
                local newIndex = currentIndex + 1
                if newIndex == #list + 1 then newIndex = 1 end

                board:TransformGem(currentGem, list[newIndex])
            end
        end
    end
end)

-- Cheat: number keys add modifiers.
Input.Events.KeyPressed:Subscribe(function (ev)
    if Bedazzled:IsDebug() and UI.Board and UI.HoveredGridPosition then
        local pos = UI.HoveredGridPosition
        local board = UI.Board
        local gem = board:GetGemAt(pos:unpack())
        local modifier = nil

        if ev.InputID == "num1" then
            modifier = "Rune"
        elseif ev.InputID == "num2" then
            modifier = "LargeRune"
        elseif ev.InputID == "num3" then
            modifier = "GiantRune"
        end

        if gem and modifier then
            gem:AddModifier(modifier)
        end
    end
end)

-- Listen for new high scores being set to show a notification.
Bedazzled.Events.NewHighScore:Subscribe(function (ev)
    local randomGem = Bedazzled.GetRandomGemDescriptor()
    local toastLabel = Text.Format(Bedazzled.TranslatedStrings.NewHighScore:GetString(), {
        FormatArgs = {
            ev.Score,
        }
    })

    Notification.ShowIconNotification(toastLabel, randomGem:GetIcon())
end)

---------------------------------------------
-- COMMANDS
---------------------------------------------

-- Start the game from a console command.
Ext.RegisterConsoleCommand("bedazzled", function (_)
    UI.Setup()
end)

-- Force a game over.
Ext.RegisterConsoleCommand("bedazzledgameover", function (_)
    if UI.Board and UI.Board:IsRunning() then
        UI.Board:EndGame()
    end
end)