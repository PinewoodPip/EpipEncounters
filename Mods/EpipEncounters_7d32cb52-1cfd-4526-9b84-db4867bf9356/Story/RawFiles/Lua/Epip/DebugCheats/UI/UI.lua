
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local FormHorizontalList = Generic.GetPrefab("GenericUI_Prefab_FormHorizontalList")
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")
local V = Vector.Create

---@type Feature
local DebugCheatsUI = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    _UIInitialized = false,
    _CurrentContext = nil, ---@type Feature_DebugCheats_Context?
    _CurrentEntityHandle = nil, ---@type ComponentHandle?
    _CurrentPosition = nil, ---@type Vector3?

    TranslatedStrings = {
        Header = {
           Handle = "h5b9e7fc0g6bbcg4781gb9aag95c9189ad110",
           Text = "Debug Cheats",
           ContextDescription = "UI header",
        },
    },

    Events = {
        RenderAction = {}, ---@type Event<Feature_DebugCheatsUI_Event_RenderAction>
    }
}
Epip.RegisterFeature("DebugCheatsUI", DebugCheatsUI)

local UI = Generic.Create("Epip_DebugCheats")
DebugCheatsUI.UI = UI

local BG_WIDTH = 600
local BG_HEIGHT = 800
local TEXT_HEIGHT = 50
UI.SIZE = V(BG_WIDTH, BG_HEIGHT)
UI.LIST_SIZE = V(BG_WIDTH, BG_HEIGHT)
UI.BG_ALPHA = 0.3
UI.HEADER_SIZE = V(BG_WIDTH, 40)
UI.DRAGGABLE_AREA_SIZE = V(BG_WIDTH, 50)
UI.DRAGGABLE_AREA_ALPHA = 0.5
UI.FORM_ELEMENT_SIZE = V(BG_WIDTH, TEXT_HEIGHT)
UI.FORM_TEXTFIELD_SIZE = V(100, TEXT_HEIGHT)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_DebugCheatsUI_Event_RenderAction
---@field Action Feature_DebugCheats_Action

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI.
---@param context Feature_DebugCheats_Context
---@param entityHandle ComponentHandle?
function UI.Setup(context, entityHandle)
    UI._Initialize()

    DebugCheatsUI._CurrentContext = context
    DebugCheatsUI._CurrentEntityHandle = entityHandle
    DebugCheatsUI._CurrentPosition = Pointer.GetWorldPosition()

    DebugCheatsUI:DebugLog("Opening UI with context", context)

    local actions = DebugCheats.GetActions(context)
    UI._RenderActions(actions)

    UI._UpdateContextLabel()

    UI:Show()
end

---Updates the label for the current context.
function UI._UpdateContextLabel()
    local element = UI.ContextLabel

    element:SetText(DebugCheatsUI._CurrentContext or "None?")
end

---Renders actions onto the UI.
---@param actions Feature_DebugCheats_Action[]
function UI._RenderActions(actions)
    for _,action in ipairs(actions) do
        DebugCheatsUI:DebugLog("Rendering action", action:GetID(), action:GetClassName())

        DebugCheatsUI.Events.RenderAction:Throw({
            Action = action,
        })
    end
end

---Creates the elements of the UI.
function UI._Initialize()
    if not DebugCheatsUI._UIInitialized then
        local bg = UI:CreateElement("Root", "GenericUI_Element_TiledBackground")
        bg:SetBackground("Black", UI.SIZE:unpack())
        bg:SetAlpha(UI.BG_ALPHA)

        local contentList = bg:AddChild("ContentList", "GenericUI_Element_VerticalList")

        local draggableArea = bg:AddChild("DraggableArea", "GenericUI_Element_TiledBackground")
        draggableArea:SetBackground("Black", UI.DRAGGABLE_AREA_SIZE:unpack())
        draggableArea:SetAlpha(UI.DRAGGABLE_AREA_ALPHA)
        draggableArea:SetAsDraggableArea()

        local _ = TextPrefab.Create(UI, "Header", contentList, DebugCheatsUI.TranslatedStrings.Header:GetString(), "Center", UI.HEADER_SIZE)
        local contextText = TextPrefab.Create(UI, "ContextLabel", contentList, "", "Center", UI.HEADER_SIZE)
        UI.ContextLabel = contextText

        local actionList = contentList:AddChild("ActionList", "GenericUI_Element_ScrollList")
        actionList:SetFrame(UI.LIST_SIZE:unpack())
        UI.ActionList = actionList

        DebugCheatsUI._UIInitialized = true
    end

    -- Cleanup previous elements
    UI.ActionList:Clear()
end

---Executes an action.
---@param action Feature_DebugCheats_Action
---@param contextData Feature_DebugCheats_Action_Context Fields related to the basic context (Character, Item) will be automatically filled out.
function DebugCheatsUI._ExecuteAction(action, contextData)
    local currentContext = DebugCheatsUI._CurrentContext

    contextData.Position = DebugCheatsUI._CurrentPosition

    if currentContext == "Character" then
        local char = Character.Get(DebugCheatsUI._CurrentEntityHandle)
        contextData.TargetCharacter = char
        contextData.Position = Vector.Create(char.WorldPos)
    elseif currentContext == "Item" then
        local item = Character.Get(DebugCheatsUI._CurrentEntityHandle)
        contextData.TargetItem = item
        contextData.Position = Vector.Create(item.WorldPos)
    end

    DebugCheats.ExecuteAction(action:GetID(), contextData)
end

---------------------------------------------
-- BUILT-IN ACTION RENDERING
---------------------------------------------

---Renders a Character action.
---@param action Feature_DebugCheats_Action
function DebugCheatsUI._RenderButton(action)
    local list = UI.ActionList
    local button = list:AddChild(action:GetID(), "GenericUI_Element_Button")
    button:SetType("Brown")
    button:SetText(action:GetName())

    button:SetTooltip("Simple", action:GetDescription())

    button.Events.Pressed:Subscribe(function (_)
        DebugCheatsUI._ExecuteAction(action, {})
    end)
end

---Renders a text field with a spinner.
---@param action Feature_DebugCheats_Action_ParametrizedCharacter
function DebugCheatsUI._RenderQuantifiedTextField(action)
    local element = FormHorizontalList.Create(UI, action:GetID(), UI.ActionList, action:GetName(), UI.FORM_ELEMENT_SIZE, UI.FORM_TEXTFIELD_SIZE)

    local textField = TextPrefab.Create(UI, action:GetID() .. "_TextField", element.List, "", "Left", UI.FORM_TEXTFIELD_SIZE)
    textField:SetEditable(true)

    local button = element:AddChild("Button", "GenericUI_Element_Button")
    button:SetType("Brown")
    button:SetText("Run")
    
    button.Events.Pressed:Subscribe(function (_)
        DebugCheatsUI._ExecuteAction(action, {
            Amount = 1, -- TODO
            String = textField:GetText()
        })
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for keybinds to open the UI.
Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function (action, _)
    if action == "EpipEncounters_DebugCheats_OpenUI" then
        ---@type Feature_DebugCheats_Context
        local context = "Ground"
        local entityHandle = nil
        local pointerChar = Pointer.GetCurrentCharacter(nil, true)
        local pointerItem = Pointer.GetCurrentItem()

        if pointerChar then
            context = "Character"
            entityHandle = pointerChar.Handle
        elseif pointerItem then
            context = "Item"
            entityHandle = pointerItem.Handle
        end

        UI.Setup(context, entityHandle)
    end
end)

-- Render built-in action types.
DebugCheatsUI.Events.RenderAction:Subscribe(function (ev)
    local actionType = ev.Action:GetClassName() ---@cast actionType Feature_DebugCheats_ActionType
    local action = ev.Action

    if actionType == "Feature_DebugCheats_Action_Character" then
        DebugCheatsUI._RenderButton(action)
    elseif actionType == "Feature_DebugCheats_Action_Item" then
        DebugCheatsUI._RenderButton(action)
    elseif actionType == "Feature_DebugCheats_Action_Position" then
        DebugCheatsUI._RenderButton(action)
    elseif actionType == "Feature_DebugCheats_Action_ParametrizedCharacter" then
        DebugCheatsUI._RenderQuantifiedTextField(action)
    else
        DebugCheatsUI:DebugLog("No built-in rendering for action type", actionType)
    end
end)