
---@class Feature_DebugCheats : Feature
local DebugCheats = {
    _Actions = {}, ---@type table<string, Feature_DebugCheats_Action>

    NET_MSG_ACTION_EXECUTED = "Feature_DebugCheats_Net_ActionExecuted",

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    TranslatedStrings = {
        SpawnItemTemplate_Name = {
           Handle = "hfd4d8ec8g76e3g4defg9647gc28159eb38e5",
           Text = "TODO",
           ContextDescription = "Spawn template action name",
        },
        SpawnItemTemplate_Description = {
           Handle = "h4e3b6a84g9de1g4723gb807ga808db3c9d70",
           Text = "TODO",
           ContextDescription = "Spawn item template action description",
        },
        CopyIdentifier_Name = {
           Handle = "hfa03d86cg9193g45efg966fg50e1f98ce39c",
           Text = "Copy GUID",
           ContextDescription = "Copy GUID action name",
        },
        CopyIdentifier_Description = {
           Handle = "ha8b96a59gace5g4aa5gba9cgc7567a58a8e8",
           Text = "TODO",
           ContextDescription = "Copy GUID action description",
        },
        CopyPosition_Name = {
           Handle = "hdba61afag2d17g4037g99b9g123d915c9b18",
           Text = "Copy Position",
           ContextDescription = "Copy position action name",
        },
        CopyPosition_Description = {
           Handle = "hac78ff60gededg498agbb7eg97795fcd40fc",
           Text = "Copies the cursor's world position to clipboard.",
           ContextDescription = "Copy position action description",
        },
        TeleportTo_Name = {
           Handle = "ha6bf3f4cg6de4g4ac8gb706g3f39de8376c3",
           Text = "Teleport to",
           ContextDescription = "Teleport action name",
        },
        TeleportTo_Description = {
           Handle = "h23e452c0g340fg4555g8034g753f003107bf",
           Text = "TODO",
           ContextDescription = "Teleport action description",
        },
    },

    Events = {
        ActionExecuted = {}, ---@type Event<Feature_DebugCheats_Event_ActionExecuted>
    },
    Hooks = {

    }
}
Epip.RegisterFeature("DebugCheats", DebugCheats)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_DebugCheats_Event_ActionExecuted
---@field Action Feature_DebugCheats_Action
---@field Context Feature_DebugCheats_Action_ContextData

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_DebugCheats_Net_ActionExecuted
---@field ActionID string
---@field Context table Needs to be serializable.

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Feature_DebugCheats_Context "SourceCharacter"|"TargetCharacter"|"SourcePosition"|"TargetPosition"|"TargetItem"|"String"|"Amount"|"TargetGameObject"|"AffectParty"

---@class Feature_DebugCheats_Action_ContextData
---@field SourceCharacter Character?
---@field TargetCharacter Character?
---@field SourcePosition Vector3?
---@field TargetPosition Vector3?
---@field TargetItem Item?
---@field TargetGameObject (Character|Item)?
---@field String string?
---@field Amount integer?
---@field AffectParty boolean?

---------------------------------------------
-- METHODS
---------------------------------------------

---Executes an action.
---@param actionID string
---@param contextData Feature_DebugCheats_Action_ContextData
function DebugCheats.ExecuteAction(actionID, contextData)
    local action = DebugCheats.GetAction(actionID)
    ---@type Feature_DebugCheats_Net_ActionExecuted
    local netPayload = {
        ActionID = actionID,
        Context = DebugCheats._EncodeNetContext(contextData),
    }

    DebugCheats:DebugLog("Executing action", actionID)

    -- Execute locally
    DebugCheats._ThrowExecuteActionEvent(action, contextData)

    -- Forward to other context
    if Ext.IsClient() then
        Net.PostToServer(DebugCheats.NET_MSG_ACTION_EXECUTED, netPayload)
    else
        Net.Broadcast(DebugCheats.NET_MSG_ACTION_EXECUTED, netPayload)
    end
end

---Registers an action.
---@param id string
---@param data Feature_DebugCheats_Action
---@return Feature_DebugCheats_Action
function DebugCheats.RegisterAction(id, data)
    local class = DebugCheats:GetClass("Feature_DebugCheats_Action")
    data.ID = id
    local instance = class.Create(data)

    DebugCheats._Actions[id] = instance

    return instance
end

---Gets an action by its ID.
---@param id string
---@return Feature_DebugCheats_Action
function DebugCheats.GetAction(id)
    local action = DebugCheats._Actions[id]
    if not action then
        DebugCheats:Error("GetAction", "No action with ID", id)
    end

    return action
end

---Returns the actions that are valid for a context.
---@param context Feature_DebugCheats_Action_ContextData
---@return Feature_DebugCheats_Action[]
function DebugCheats.GetActions(context)
    local actions = {}

    for _,action in pairs(DebugCheats._Actions) do
        local isValid = true

        -- Exclude actions that require more context than the table offers
        for contextType in action.Contexts:Iterator() do
            if context[contextType] == nil then
                isValid = false
            end
        end

        if isValid then
            table.insert(actions, action)
        end
    end

    return actions
end

---Encodes a context to be sent over the net.
---@param context Feature_DebugCheats_Action_ContextData
---@return table
function DebugCheats._EncodeNetContext(context) -- TODO make this hookable
    local data = {}

    data.CharacterNetID = context.TargetCharacter and context.TargetCharacter.NetID
    data.SourceCharacterNetID = context.SourceCharacter and context.SourceCharacter.NetID
    data.ItemNetID = context.TargetItem
    data.TargetPosition = context.TargetPosition
    data.SourcePosition = context.SourcePosition
    data.TargetGameObjectNetID = context.TargetGameObject and context.TargetGameObject.NetID
    data.Amount = context.Amount
    data.String = context.String
    data.AffectParty = context.AffectParty

    return data
end

---Parses context data from a net message.
---@param data table
---@return Feature_DebugCheats_Action_ContextData
function DebugCheats._ParseNetContext(data) -- TODO make this hookable
    local context = {} ---@type Feature_DebugCheats_Action_ContextData

    if data.CharacterNetID then
        context.TargetCharacter = Character.Get(data.CharacterNetID)
    end
    if data.SourceCharacterNetID then
        context.SourceCharacter = Character.Get(data.SourceCharacterNetID)
    end
    if data.ItemNetID then
        context.TargetItem = Item.Get(data.ItemNetID)
    end
    if data.TargetPosition then
        context.TargetPosition = Vector.Create(data.TargetPosition)
    end
    if data.SourcePosition then
        context.SourcePosition = Vector.Create(data.SourcePosition)
    end
    if data.TargetGameObjectNetID then
        context.TargetGameObject = Ext.Entity.GetGameObject(data.TargetGameObjectNetID)
    end

    context.Amount = data.Amount
    context.String = data.String
    context.AffectParty = data.AffectParty

    return context
end

---Executes an action.
---@param action Feature_DebugCheats_Action
---@param contextData Feature_DebugCheats_Action_ContextData
function DebugCheats._ThrowExecuteActionEvent(action, contextData)
    DebugCheats.Events.ActionExecuted:Throw({
        Action = action,
        Context = contextData,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for actions being executed from the other context.
Net.RegisterListener(DebugCheats.NET_MSG_ACTION_EXECUTED, function (payload)
    local action = DebugCheats.GetAction(payload.ActionID)
    local context = DebugCheats._ParseNetContext(payload.Context)

    DebugCheats:DebugLog("Received action from other context", action:GetID())

    DebugCheats._ThrowExecuteActionEvent(action, context)
end)