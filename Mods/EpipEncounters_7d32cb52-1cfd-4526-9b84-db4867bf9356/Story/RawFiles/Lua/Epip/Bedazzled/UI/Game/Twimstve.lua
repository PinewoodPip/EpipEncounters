
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local TwimstveGameMode = Bedazzled:GetClass("Features.Bedazzled.GameModes.Twimstve")
local Textures = Epip.GetFeature("Feature_GenericUITextures")
local BaseUI = Bedazzled.GameUI
local V = Vector.Create

---@class Features.Bedazzled.UI.Game.Twimstve
local UI = {}
UI.SOUNDS = {
    ROTATE = "UI_Game_Dialog_Open",
    CANT_ROTATE = "UI_Game_ActionUnavailable",
}
-- In units per second.
UI.SWIRL_ROTATION_SPEED = {
    NORMAL = 30,
    SWAPPING = 200, -- Speed used while gems are being swapped.
}
UI.RotatorAnchor = nil ---@type Vector2

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI for a new game.
function UI.Setup()
    UI._Initialize()
    UI.Game = BaseUI.Board ---@type Features.Bedazzled.GameModes.Twimstve
    local game = UI.Game

    game.Events.GameOver:Subscribe(function (_)
        UI._OnGameOver()
    end)

    UI.ClearSelection()
end

---Clears the anchor and hides the rotator.
function UI.ClearSelection()
    UI.RotatorAnchor = nil
    UI.Rotator:SetVisible(false)
end

---Sets the selection and shows the rotator, if the position is valid.
---@param pos Vector2 Top-left grid coordinate of the rotator.
function UI.SetSelection(pos)
    local rotator = UI.Rotator
    local gem = UI.Game:GetGemAt(pos:unpack())
    if gem and BaseUI.IsInteractable() and gem:IsIdle() and UI.Game:IsAnchorValid(pos) then
        local element = BaseUI.GetGemElement(gem)
        local visualPositionX, visualPositionY = element:GetGridPosition()
        UI.RotatorAnchor = pos

        visualPositionX = visualPositionX - BaseUI.CELL_SIZE[1]/2
        visualPositionY = visualPositionY - BaseUI.CELL_SIZE[2]/2

        rotator:SetPosition(visualPositionX, visualPositionY)
        rotator:SetVisible(true)
    else
        UI.ClearSelection()
    end
end

---Returns whether the user has a valid selected anchor for the rotator.
---@return boolean
function UI.HasSelection()
    return UI.RotatorAnchor ~= nil
end

---Hides the related elements.
function UI.Cleanup()
    if not UI._Initialized then return end

    UI.ClearSelection()

    UI.Game = nil
end

---Returns whether the overlay should be active.
---@return boolean
function UI.IsActive()
    return UI.Game ~= nil
end

---Perform cleanup routines on a game over.
function UI._OnGameOver()
    -- Clear gem selection
    UI.ClearSelection()
end

---Creates the static overlay elements and subscribes to listeners of the base UI.
function UI._Initialize()
    if UI._Initialized then return end
    local gemContainer = BaseUI.GemContainer

    -- Gem selectors
    local selectorSize = Vector.ScalarProduct(BaseUI.CELL_SIZE, 2)
    local rotator = gemContainer:AddChild("Twimstve.Rotator", "GenericUI_Element_IggyIcon")
    rotator:SetIcon("Item_Rare", selectorSize:unpack())
    rotator:SetVisible(false)
    rotator:SetMouseEnabled(false)
    rotator:SetMouseChildren(false)
    local swirlAnchor = rotator:AddChild("Twimstve.Rotator.Swirl.Anchor", "GenericUI_Element_Empty")
    swirlAnchor:SetPositionRelativeToParent("Center")
    local swirl = swirlAnchor:AddChild("Twimstve.Rotator.Swirl.Texture", "GenericUI_Element_Texture")
    swirl:SetTexture(Textures.TEXTURES.MISC.SWIRLING_STAR, selectorSize)
    swirl:SetPosition(-selectorSize[1]/2, -selectorSize[2]/2)
    GameState.Events.Tick:Subscribe(function (ev)
        local rotation = swirlAnchor:GetMovieClip().rotation
        local rotationSpeed = UI.Game:IsInteracting() and UI.SWIRL_ROTATION_SPEED.SWAPPING or UI.SWIRL_ROTATION_SPEED.NORMAL
        swirlAnchor:SetRotation(rotation + (ev.DeltaTime / 1000) * rotationSpeed)
    end, {EnabledFunctor = function() return BaseUI:IsVisible() and UI.IsActive() end})
    UI.Rotator = rotator

    -- Hide rotator when mouse exits the grid
    BaseUI.GridClickbox.Events.MouseOut:Subscribe(function (_)
        UI.ClearSelection()
    end, {EnabledFunctor = function () return UI.IsActive() end})

    -- Event listeners for the base UI should be registered here
    -- as the UI is "static" and never re-created.
    BaseUI.Events.GemClicked:Subscribe(function (ev)
        UI._OnGemClickboxClicked(ev.Position)
    end, {EnabledFunctor = function () return UI.IsActive() end})
    BaseUI.Events.ClickBoxHovered:Subscribe(function (ev)
        UI._UpdateSelection(ev.Clickbox, ev.GridPosition)
    end, {EnabledFunctor = function () return UI.IsActive() end})

    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Updates the selection based on hovered position.
---@param element GenericUI_Element
---@param gridPos Vector2
function UI._UpdateSelection(element, gridPos)
    local mc = element:GetMovieClip()
    local x, y = mc.mouseX, mc.mouseY
    local cellSize = BaseUI.CELL_SIZE
    local newPos = Vector.Clone(gridPos)

    -- Offset the selection based on the quadrant of the cell being hovered
    if x < cellSize[1] / 2 and y < cellSize[2] / 2 then -- Top-left
        newPos = V(gridPos[1] - 1, gridPos[2] + 1)
    elseif x > cellSize[1] / 2 and y < cellSize[2] / 2 then -- Top-right
        newPos = V(gridPos[1], gridPos[2] + 1)
    elseif x < cellSize[1] / 2 and y > cellSize[2] / 2 then -- Bottom-left
        newPos = V(gridPos[1] - 1, gridPos[2])
    end

    UI.SetSelection(newPos)
end

---Handle clickboxes being clicked.
---@param pos Vector2
function UI._OnGemClickboxClicked(pos)
    local gem = UI.Game:GetGemAt(pos:unpack())
    local element = BaseUI.GetGemElement(gem)

    if gem and element and gem:IsIdle() and UI.HasSelection() then
        UI.Game:Rotate(UI.RotatorAnchor, "Clockwise") -- TODO
    end
end

-- Set up or hide the overlay when a new game starts. 
BaseUI.Events.GameStarted:Subscribe(function (_)
    local game = BaseUI.Board
    if game.GameMode == TwimstveGameMode:GetClassName() then
        UI.Setup()
    else
        UI.Cleanup()
    end
end)
