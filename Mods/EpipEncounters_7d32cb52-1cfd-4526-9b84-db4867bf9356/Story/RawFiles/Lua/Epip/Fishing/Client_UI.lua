local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local V = Vector.Create

---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")
local UI = Generic.Create("Feature_Fishing")
Fishing.UI = UI
UI:Hide()

UI.Elements = {} -- Holds references to various important elements of the UI.

UI._GameState = nil ---@type Feature_Fishing_GameState
UI._GameObjects = {} ---@type Feature_Fishing_GameObject[]
UI._GameObjectClass = nil ---@type Feature_Fishing_GameObject
UI._GameObjectClasses = {} ---@type table<string, Feature_Fishing_GameObject>
UI._GameObjectStateClass = nil ---@type Feature_Fishing_GameObject_State

UI.USE_LEGACY_HOOKS = false
UI.Hooks.GetProgressDrain = UI:AddSubscribableHook("GetProgressDrain") ---@type Event<Feature_Fishing_UI_Hook_GetProgressDrain>

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
UI.TUTORIAL_PROGRESS_DRAIN_MULTIPLIER = 0.5

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_Fishing_UI_Hook_GetProgressDrain
---@field Drain integer Hookable.
---@field GameState Feature_Fishing_GameState
---@field Character EclCharacter
---@field Fish Feature_Fishing_Fish

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

    UI.CreateGameObject("Feature_Fishing_GameObject_Bobber", "Bobber", UI.BLOBBER_SIZE)
    local fish = UI.CreateGameObject("Feature_Fishing_GameObject_Fish", "Fish", UI.FISH_SIZE)

    -- TODO move elsewhere
    fish:GetState().Position = 300

    UI.SnapToCursor()
    UI.UpdateProgressBar()
    UI.UpdateFishIcon()
    UI.UpdateTutorialText()
    UI:Show()

    GameState.Events.RunningTick:Subscribe(UI._OnTick, nil, "Feature_Fishing_UI_Tick")
end

---@return Feature_Fishing_GameState
function UI.GetGameState()
    return UI._GameState
end

---@return EclCharacter?
function UI.GetCharacter()
    local state = UI.GetGameState()
    local char = state and Character.Get(state.CharacterHandle) ---@type EclCharacter

    return char
end

function UI.GetProgressDrain()
    local drain = UI.PROGRESS_DRAIN
    local char = UI.GetCharacter()
    local state = UI.GetGameState()
    local hook = UI.Hooks.GetProgressDrain:Throw({
        GameState = state,
        Character = char,
        Drain = drain,
        Fish = state.CurrentFish,
    })

    return hook.Drain
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

function UI.UpdateTutorialText()
    local element = UI.Elements.TutorialText

    element:SetVisible(Fishing.GetTotalFishCaught() <= 0)
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

---@param className string
---@param class Feature_Fishing_GameObject
function UI.RegisterGameObject(className, class)
    UI._GameObjectClasses[className] = class
end

---@generic T
---@param className `T`
---@param elementID string
---@param size Vector2D
---@return T
function UI.CreateGameObject(className, elementID, size)
    local class = UI._GameObjectClasses[className]
    local gameObject = class:Create(elementID, size, UI._GameObjectStateClass.Create())

    table.insert(UI._GameObjects, gameObject)

    return gameObject
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
    UI.AddProgress(-UI.GetProgressDrain() * ev.DeltaTime / 1000)

    -- Exit the minigame if the client goes into dialogue.
    if Client.IsInDialogue() then
        UI.Cleanup("Cancelled")
    else
        UI.UpdateGameObjects(ev.DeltaTime)
    end
end

-- If the user is catching fish for the first time, slow down the drain
-- so as to let give them more time to get used to the controls.
UI.Hooks.GetProgressDrain:Subscribe(function (ev)
    if Fishing.GetTotalFishCaught() <= 0 then
        ev.Drain = ev.Drain * UI.TUTORIAL_PROGRESS_DRAIN_MULTIPLIER
    end
end)

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

    local tutorialText = TextPrefab.Create(UI, "TutorialText", panel, Text.Format(Fishing.TSK["MinigameTutorialHint"], {Color = Color.WHITE}), "Left", V(300, 200))
    tutorialText:SetStroke(Color.Create(Color.BLACK), 1, 1, 15, 1)
    tutorialText:SetPosition(UI.SIZE[1] + 10, 0)
    UI.Elements.TutorialText = tutorialText

    UI:Hide()
end