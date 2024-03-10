
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local TwimstveGameMode = Bedazzled:GetClass("Features.Bedazzled.GameModes.Twimstve")
local Textures = Epip.GetFeature("Feature_GenericUITextures")
local BaseUI = Bedazzled.GameUI

---@class Features.Bedazzled.UI.Game.Twimstve
local UI = {}
UI.SOUNDS = {
    ROTATE = "UI_Game_Dialog_Open",
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

---Sets the selection and shows the rotator.
---@param pos Vector2 Top-left grid coordinate of the rotator.
function UI.SetSelection(pos)
    local rotator = UI.Rotator
    local element = BaseUI.GetGemElement(UI.Game:GetGemAt(pos:unpack())) -- TODO nil checks
    local visualPositionX, visualPositionY = element:GetGridPosition()
    UI.RotatorAnchor = pos

    visualPositionX = visualPositionX - BaseUI.CELL_SIZE[1]/2
    visualPositionY = visualPositionY - BaseUI.CELL_SIZE[2]/2

    rotator:SetPosition(visualPositionX, visualPositionY)
    rotator:SetVisible(true)
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
    end, {EnabledFunctor = function () return BaseUI:IsVisible() end})
    UI.Rotator = rotator

    -- Hide rotator when mouse exits the grid
    BaseUI.GridClickbox.Events.MouseOut:Subscribe(function (_)
        UI.ClearSelection()
    end)

    -- Event listeners for the base UI should be registered here
    -- as the UI is "static" and never re-created.
    BaseUI.Events.GemClicked:Subscribe(function (ev)
        UI._OnGemClickboxClicked(ev.Position)
    end)
    BaseUI.Events.GemHovered:Subscribe(function (ev)
        UI._OnGemClickboxHovered(ev.Position)
    end)

    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Handle clickboxes being hovered over.
---@param pos Vector2
function UI._OnGemClickboxHovered(pos)
    local x, y = pos:unpack()
    local gem = UI.Game:GetGemAt(x, y)
    local element = BaseUI.GetGemElement(gem)

    -- TODO snap within bounds when hovering over last row/column
    if gem and element and BaseUI.IsInteractable() and gem:IsIdle() and UI.Game:IsAnchorValid(pos) then
        UI.SetSelection(pos)
    else
        UI.ClearSelection()
    end
end

---Handle clickboxes being clicked.
---@param pos Vector2
function UI._OnGemClickboxClicked(pos)
    local gem = UI.Game:GetGemAt(pos:unpack())
    local element = BaseUI.GetGemElement(gem)

    if gem and element and gem:IsIdle() and UI.HasSelection() and UI.Game:CanRotateAt(UI.RotatorAnchor) then
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
