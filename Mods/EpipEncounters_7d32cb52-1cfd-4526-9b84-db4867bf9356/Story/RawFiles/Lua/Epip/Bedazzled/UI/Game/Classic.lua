
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local ClassicGameMode = Bedazzled:GetClass("Features.Bedazzled.GameModes.Classic")
local Input = Client.Input
local V = Vector.Create
local BaseUI = Bedazzled.GameUI

---@class Features.Bedazzled.UI.Game.Classic
local UI = {}
UI.MOUSE_SWIPE_DISTANCE_THRESHOLD = 30
UI.SOUNDS = {
    SWIPE = "UI_Game_Dialog_Open",
}
UI.GemSelection = nil ---@type Feature_Bedazzled_UI_GemSelection

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI for a new game.
function UI.Setup()
    UI._Initialize()
    UI.Game = BaseUI.Board ---@type Features.Bedazzled.GameModes.Classic
    local game = UI.Game

    game.Events.GameOver:Subscribe(function (_)
        UI._OnGameOver()
    end)

    UI.ClearSelection()
    UI.SecondarySelector:SetVisible(false)
end

---Selects a gem.
---@param gem Feature_Bedazzled_Board_Gem
function UI.SelectGem(gem)
    local element = BaseUI.GetGemElement(gem)
    local selector = UI.Selector
    local visualPositionX, visualPositionY = element:GetGridPosition()

    if BaseUI.IsInteractable() then
        visualPositionX = visualPositionX - BaseUI.CELL_SIZE[1]/2
        visualPositionY = visualPositionY - BaseUI.CELL_SIZE[2]/2

        selector:SetPosition(visualPositionX, visualPositionY)
        selector:SetVisible(true)

        UI.GemSelection = {
            Position = V(UI.Game:GetGemGridCoordinates(gem)),
            InitialMousePosition = V(Client.GetMousePosition()),
            CanSwipe = true,
        }
    end
end

---Returns whether mouse swipes are possible in the current state.
---Mouse swipes require a gem selection.
---@return boolean
function UI.CanMouseSwipe()
    local canSwipe = UI.GemSelection and UI.GemSelection.CanSwipe or false

    canSwipe = canSwipe and BaseUI.IsInteractable()

    return canSwipe
end

---Returns the gem currently selected by the cursor.
---@return Feature_Bedazzled_Board_Gem?
function UI.GetSelectedGem()
    local game = UI.Game
    local gem = nil
    if game and UI.HasGemSelection() then
        gem = game:GetGemAt(UI.GetSelectedPosition():unpack())
    end
    return gem
end

---@return boolean
function UI.HasGemSelection()
    return UI.GemSelection ~= nil
end

---@return Vector2?
function UI.GetSelectedPosition()
    return UI.GemSelection and UI.GemSelection.Position or nil
end

function UI.ClearSelection()
    local selector = UI.Selector

    UI.GemSelection = nil
    selector:SetVisible(false)
end

---@param pos1 Vector2
---@param pos2 Vector2
function UI.RequestSwap(pos1, pos2)
    UI.Game:Swap(pos1, pos2)

    UI.ClearSelection()
end

---Hides the related elements.
function UI.Cleanup()
    if not UI._Initialized then return end

    UI.ClearSelection()
    UI.SecondarySelector:SetVisible(false)

    UI.Game = nil
end

---Creates the static overlay elements and subscribes to listeners of the base UI.
function UI._Initialize()
    if UI._Initialized then return end
    local gemContainer = BaseUI.GemContainer

    -- Gem selectors
    local secondarySelector = gemContainer:AddChild("SecondarySelector", "GenericUI_Element_IggyIcon")
    secondarySelector:SetIcon("Item_Rare", BaseUI.CELL_SIZE:unpack())
    secondarySelector:SetVisible(false)
    secondarySelector:SetMouseEnabled(false)
    UI.SecondarySelector = secondarySelector

    local selector = gemContainer:AddChild("Selector", "GenericUI_Element_IggyIcon")
    selector:SetIcon("Item_Divine", BaseUI.CELL_SIZE:unpack())
    selector:SetVisible(false)
    selector:SetMouseEnabled(false)
    UI.Selector = selector

    -- Hide secondary selector when mouse exits the grid
    BaseUI.GridClickbox.Events.MouseOut:Subscribe(function (_)
        UI.SecondarySelector:SetVisible(false)
    end)

    -- Event listeners for the base UI should be registered here
    -- as the UI is "static" and never re-created.
    BaseUI.Events.GemClicked:Subscribe(function (ev)
        UI._OnGemClickboxClicked(ev.Position:unpack())
    end)
    BaseUI.Events.GemHovered:Subscribe(function (ev)
        UI._OnGemClickboxHovered(ev.Position:unpack())
    end)

    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Handle clickboxes being hovered over.
---@param x integer
---@param y integer
function UI._OnGemClickboxHovered(x, y)
    local gem = UI.Game:GetGemAt(x, y)
    local element = BaseUI.GetGemElement(gem)
    local selector = UI.SecondarySelector

    if gem and element and BaseUI.IsInteractable() and gem:IsIdle() then
        local visualPositionX, visualPositionY = element:GetGridPosition()

        visualPositionX = visualPositionX - BaseUI.CELL_SIZE[1]/2
        visualPositionY = visualPositionY - BaseUI.CELL_SIZE[2]/2

        selector:SetPosition(visualPositionX, visualPositionY)
        selector:SetVisible(true)
    else
        selector:SetVisible(false)
    end

    UI.HoveredGridPosition = (gem and element) and V(x, y) or nil
end

---Handle clickboxes being clicked.
---@param x integer
---@param y integer
function UI._OnGemClickboxClicked(x, y)
    local newSelection = V(x, y)
    local gem = UI.Game:GetGemAt(x, y)
    local element = BaseUI.GetGemElement(gem)

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

---Perform cleanup routines on a game over.
function UI._OnGameOver()
    -- Clear gem selection
    UI.ClearSelection()
    UI.SecondarySelector:SetVisible(false)
end

-- Stop listening for swipes if left click is released.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "left2" and ev.State == "Released" then
        if UI.HasGemSelection() then
            -- Also play a click sound. This is here so it doesn't play while swiping.
            BaseUI:PlaySound(BaseUI.SOUNDS.CLICK)

            UI.GemSelection.CanSwipe = false
        end
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

            BaseUI:PlaySound(UI.SOUNDS.SWIPE)
        end
    end
end)

-- Set up or hide the overlay when a new game starts. 
BaseUI.Events.GameStarted:Subscribe(function (_)
    local game = BaseUI.Board
    if game.GameMode == ClassicGameMode:GetClassName() then
        UI.Setup()
    else
        UI.Cleanup()
    end
end)

-- Cheat: right-click cycles gem types.
Input.Events.KeyPressed:Subscribe(function (ev)
    if Bedazzled:IsDebug() and ev.InputID == "right2" and BaseUI.Board then
        local pos = UI.HoveredGridPosition
        local board = BaseUI.Board

        if pos then
            local descriptors = Bedazzled.GetGemDescriptors() ---@type table<string, Feature_Bedazzled_Gem>
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
    if Bedazzled:IsDebug() and BaseUI.Board and UI.HoveredGridPosition then
        local pos = UI.HoveredGridPosition
        local board = BaseUI.Board
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
