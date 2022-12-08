local Generic = Client.UI.Generic
local V = Vector.Create

---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")
local UI = Generic.Create("Feature_Fishing")
Fishing.UI = UI
UI:Hide()

UI.Elements = {} -- Holds references to various important elements of the UI.

UI._GameState = nil ---@type Feature_Fishing_GameState
UI._GameObjects = {} ---@type Feature_Fishing_GameObject[]

---------------------------------------------
-- CONSTANTS
---------------------------------------------

UI.SIZE = V(50, 500)
UI.BLOBBER_AREA_SIZE = V(40, 490)
UI.BLOBBER_SIZE = V(40, 70)
UI.FISH_SIZE = V(32, 32)
UI.FISH_ICON_SIZE = V(32, 32)
UI.BOBBER_COLOR = Color.CreateFromHex(Color.LARIAN.GREEN)
UI.GRAVITY = 250
UI.PLAYER_STRENGTH = 550 -- Used to be 400
UI.MAX_VELOCITY = 220
UI.MAX_ACCELERATION = 150
UI.CLICK_ACCELERATION_BOOST = 60 -- TODO add cooldown
UI.PROGRESS_PER_SECOND = 0.15
UI.PROGRESS_BAR_WIDTH = 5
UI.STARTING_PROGRESS = 0.45
UI.PROGRESS_DRAIN = 0.1

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Fishing_GameState
local _GameState = {
    Progress = 0,
    CurrentFish = nil, ---@type Feature_Fishing_Fish
    CharacterHandle = nil, ---@type ComponentHandle
}

---@param char EclCharacter
---@param fish Feature_Fishing_Fish
---@return Feature_Fishing_GameState
function _GameState.Create(char, fish)
    local tbl = {
        Progress = UI.STARTING_PROGRESS,
        CurrentFish = fish,
        CharacterHandle = char.Handle,
    }
    Inherit(tbl, _GameState)

    return tbl
end

---@class Feature_Fishing_GameObject_State
local _State = {
    Acceleration = 0,
    Velocity = 0,
    Position = 0,
}

---@return Feature_Fishing_GameObject_State
function _State.Create()
    ---@type Feature_Fishing_GameObject_State
    local tbl = {
        Acceleration = 0,
        Position = 0,
    }
    Inherit(tbl, _State)

    return tbl
end

---@class Feature_Fishing_GameObject
---@field State Feature_Fishing_GameObject_State
---@field Size Vector2D
---@field ElementID string
---@field Type string
local _GameObject = {}

function _GameObject:Create(elementID, size, state)
    ---@type Feature_Fishing_GameObject
    local tbl = {
        State = state,
        ElementID = elementID,
        Size = size,
    }
    Inherit(tbl, self)

    return tbl
end

function _GameObject:GetUpperBound()
    return self.State.Position + self.Size[2]
end

---@diagnostic disable: unused-local
---@param deltaTime number In milliseconds.
function _GameObject:Update(deltaTime) error("Not implemented") end -- TODO use template method pattern
---@diagnostic enable: unused-local

---@param otherObject Feature_Fishing_GameObject
---@return boolean
function _GameObject:IsCollidingWith(otherObject)
    local myState = self:GetState()
    local otherState = otherObject:GetState()

    return myState.Position < (otherObject:GetUpperBound()) and self:GetUpperBound() >= otherState.Position
end

---@diagnostic disable: unused-local
---@param otherObject Feature_Fishing_GameObject
---@param deltaTime number In milliseconds.
function _GameObject:OnCollideWith(otherObject, deltaTime) end
---@diagnostic enable: unused-local

---@return Feature_Fishing_GameObject_State
function _GameObject:GetState()
    return self.State
end

---@return GenericUI_Element
function _GameObject:GetElement()
    return UI:GetElementByID(self.ElementID)
end

function _GameObject:UpdatePosition()
    local element = self:GetElement()

    element:SetPositionRelativeToParent("Bottom", 0, -self.State.Position)
end

---------------------------------------------
-- BOBBER CLASS
---------------------------------------------

---@class Feature_Fishing_GameObject_Bobber : Feature_Fishing_GameObject
local _Bobber = {
    Type = "Bobber",
}
Inherit(_Bobber, _GameObject)

---@param deltaTime number In milliseconds.
function _Bobber:Update(deltaTime)
    local state = self.State
    local seconds = deltaTime / 1000
    local acceleration = state.Acceleration
    local applyGravity = not Client.Input.IsKeyPressed("left2") -- TODO turn into a hook

    if applyGravity then
        acceleration = acceleration - UI.GRAVITY * seconds
    else
        acceleration = acceleration + UI.PLAYER_STRENGTH * seconds
    end

    state.Acceleration = math.clamp(acceleration, -UI.MAX_ACCELERATION, UI.MAX_ACCELERATION)
    state.Velocity = state.Velocity + acceleration * seconds
    state.Velocity = math.clamp(state.Velocity, -UI.MAX_VELOCITY, UI.MAX_VELOCITY)

    state.Position = math.clamp(state.Position + state.Velocity * seconds, 0, UI.GetBobberUpperBound())

    if state.Position <= 0 or state.Position >= UI.GetBobberUpperBound() then -- TODO use gameobject method
        state.Velocity = 0
        state.Acceleration = 0
    end
end

---@param otherObject Feature_Fishing_GameObject
---@param deltaTime number In milliseconds.
function _Bobber:OnCollideWith(otherObject, deltaTime)
    if otherObject.Type == "Fish" then
        -- Add progress. The drain must be offset.
        UI.AddProgress((UI.PROGRESS_DRAIN + UI.PROGRESS_PER_SECOND) * deltaTime / 1000)
    end
end

---------------------------------------------
-- FISH CLASS
---------------------------------------------

---@class Feature_Fishing_GameObject_Fish : Feature_Fishing_GameObject
local _Fish = {
    Type = "Fish",
    Timer = 0,
    CYCLE_TIME = 2,
    FishState = "Floating",
    ACCELERATION = 40,
    MAX_ACCELERATION = 30,
    MAX_VELOCITY = 70,
}
Inherit(_Fish, _GameObject)

function _Fish:Update(deltaTime)
    local state = self.State
    local seconds = deltaTime / 1000
    local acceleration = state.Acceleration

    -- Switch states
    self.Timer = self.Timer + seconds
    if self.Timer > self.CYCLE_TIME then
        self.FishState = self.FishState == "Floating" and "Sinking" or "Floating"
        self.Timer = 0
        state.Velocity = 0
        state.Acceleration = 0
    end

    if self.FishState == "Floating" then
        acceleration = acceleration - self.ACCELERATION * seconds
    else
        acceleration = acceleration + self.ACCELERATION * seconds
    end

    -- TODO extract method for this; it's common functionality, most classes will not override it
    state.Acceleration = math.clamp(acceleration, -self.MAX_ACCELERATION, self.MAX_ACCELERATION)
    state.Velocity = state.Velocity + acceleration * seconds
    state.Velocity = math.clamp(state.Velocity, -self.MAX_VELOCITY, self.MAX_VELOCITY)

    state.Position = math.clamp(state.Position + state.Velocity * seconds, 0, UI.GetBobberUpperBound()) -- TODO adjust

    if state.Position <= 0 or state.Position >= UI.GetBobberUpperBound() then -- TODO use gameobject method
        state.Velocity = 0
        state.Acceleration = 0
    end
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@return GenericUI_Instance
function Fishing.GetUI()
    return Fishing.UI
end

---@param ev Feature_Fishing_Event_CharacterStartedFishing
function UI.Start(ev)
    if UI._GameState then
        UI:Error("Start", "Instance already in use")
    end

    UI._GameState = _GameState.Create(ev.Character, ev.Fish)

    local bobber = _Bobber:Create("Bobber", UI.BLOBBER_SIZE, _State.Create())
    local fish = _Fish:Create("Fish", UI.FISH_SIZE, _State.Create())

    -- TODO move elsewhere
    fish:GetState().Position = 300

    UI.AddGameObject(bobber)
    UI.AddGameObject(fish)

    UI.SnapToCursor()
    UI.UpdateProgressBar()
    UI.UpdateFishIcon()
    UI:Show()

    GameState.Events.RunningTick:Subscribe(UI._OnTick, nil, "Feature_Fishing_UI_Tick")
end

---@return Feature_Fishing_GameState
function UI.GetGameState()
    return UI._GameState
end

function UI.AddProgress(progress)
    local state = UI.GetGameState()

    state.Progress = math.clamp(state.Progress + progress, 0, 1)

    UI.UpdateProgressBar()
    
    if state.Progress >= 1 then
        UI.Cleanup("Success")
    elseif state.Progress <= 0 then
        UI.Cleanup("Failure")
    end
end

---@param reason Feature_Fishing_MinigameExitReason
function UI.Cleanup(reason)
    local state = UI.GetGameState()

    UI._GameState = nil
    UI._GameObjects = {}

    GameState.Events.RunningTick:Unsubscribe("Feature_Fishing_UI_Tick")

    UI:Hide()
    
    Fishing.Stop(Character.Get(state.CharacterHandle), state.CurrentFish, reason)
end

---@return Feature_Fishing_GameObject[]
function UI.GetGameObjects()
    return UI._GameObjects
end

function UI.UpdateProgressBar()
    local state = UI.GetGameState()
    local element = UI:GetElementByID("ProgressBar") ---@type GenericUI_Element_Color
    local length = state.Progress * UI.SIZE[2]

    element:SetColor(Color.CreateFromHex(Color.LARIAN.YELLOW))
    element:SetSize(UI.PROGRESS_BAR_WIDTH, length)
    element:SetPosition(UI.SIZE[1], UI.SIZE[2] - length)
    -- element:SetPositionRelativeToParent("BottomRight", 5, -length) -- TODO investigate issue
end

function UI.UpdateFishIcon()
    local state = UI.GetGameState()

    UI.Elements.Fish:SetIcon(state.CurrentFish:GetIcon(), UI.FISH_ICON_SIZE:unpack())
end

function UI.SnapToCursor()
    local cursorX, cursorY = Client.GetMousePosition()
    local vp = Ext.UI.GetViewportSize()
    local x, y = cursorX, cursorY

    -- Prevent the UI from overflowing through the bottom of the screen
    local yOverflow = math.max(0, y + UI.SIZE[2] - vp[2])
    y = y - yOverflow

    UI:GetUI():SetPosition(x, y)
end

---@return number
function UI.GetBobberUpperBound()
    return UI.BLOBBER_AREA_SIZE[2] - UI.BLOBBER_SIZE[2]
end

function UI.AddGameObject(gameObject)
    table.insert(UI._GameObjects, gameObject)
end

---@param deltaTime number In milliseconds.
function UI.UpdateGameObjects(deltaTime)
    for _,gameObject in ipairs(UI._GameObjects) do
        gameObject:Update(deltaTime)
        gameObject:UpdatePosition()
    end

    -- Check for collisions
    for _,gameObject in ipairs(UI._GameObjects) do
        for _,otherObject in ipairs(UI._GameObjects) do
            if gameObject ~= otherObject and gameObject:IsCollidingWith(otherObject) then
                gameObject:OnCollideWith(otherObject, deltaTime)
            end
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Starting to click gives a boost to acceleration.
Client.Input.Events.MouseButtonPressed:Subscribe(function (ev)
    if ev.InputID == "left2" then
        for _,gameObject in ipairs(UI.GetGameObjects()) do
            if gameObject.Type == "Bobber" then
                local state = gameObject:GetState()
        
                state.Acceleration = state.Acceleration + UI.CLICK_ACCELERATION_BOOST
            end
        end
    end
end)

-- Cancel the minigame when the character is switched.
Client.Events.ActiveCharacterChanged:Subscribe(function (_)
    local state = UI.GetGameState()
    
    if state then
        UI.Cleanup("Cancelled")
    end
end)

-- Listen for requests to exit the minigame with escape.
Client.Input.Events.KeyStateChanged:Subscribe(function (ev)
    local state = UI.GetGameState()

    if state and ev.InputID == "escape" then
        UI.Cleanup("Cancelled")

        ev:Prevent()
    end
end)

---@param ev GameStateLib_Event_RunningTick
function UI._OnTick(ev)
    -- Drain progress.
    UI.AddProgress(-UI.PROGRESS_DRAIN * ev.DeltaTime / 1000)

    -- Exit the minigame if the client goes into dialogue.
    if Client.IsInDialogue() then
        UI.Cleanup("Cancelled")
    else
        UI.UpdateGameObjects(ev.DeltaTime)
    end
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Start the minigame when fishing starts.
-- Unsubscribe this listener to replace the minigame with a different implementation.
-- The minigame should call Fishing.Stop() when it exits for any reason.
Fishing.Events.CharacterStartedFishing:Subscribe(function (ev)
    UI.Start(ev)
end, {StringID = "DefaultImplementation"})

-- TODO remove once the start sequence is implemented.
Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function (action, _)
    if action == "EpipEncounters_Debug_Generic" then
        Fishing.Start(Client.GetCharacter())
    end
end)

function Fishing:__Setup()
    local panel = UI:CreateElement("Root", "GenericUI_Element_TiledBackground")
    panel:SetBackground("Black", UI.SIZE:unpack())
    panel:SetAlpha(0.5)

    local bobberArea = panel:AddChild("BobberArea", "GenericUI_Element_TiledBackground")
    bobberArea:SetBackground("Black", UI.BLOBBER_AREA_SIZE:unpack())
    bobberArea:SetPositionRelativeToParent("Center")

    local bobber = bobberArea:AddChild("Bobber", "GenericUI_Element_Color")
    bobber:SetSize(UI.BLOBBER_SIZE:unpack())
    bobber:SetColor(UI.BOBBER_COLOR)

    local fish = bobberArea:AddChild("Fish", "GenericUI_Element_IggyIcon")
    fish:SetIcon("Item_CON_Food_Fish_B", UI.FISH_ICON_SIZE:unpack())
    UI.Elements.Fish = fish

    local progressBar = panel:AddChild("ProgressBar", "GenericUI_Element_Color")
    progressBar:SetSize(0, 0)
    UI.Elements.ProgressBar = progressBar

    UI:Hide()
end