
local Set = DataStructures.Get("DataStructures_Set")

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
    },

    Events = {
        ActionExecuted = {}, ---@type Event<Feature_DebugCheats_Event_ActionExecuted>
    },
    Hooks = {
        IsActionValidInContext = {}, ---@type Event<Feature_DebugCheats_Hook_IsActionValidInContext>
    }
}
Epip.RegisterFeature("DebugCheats", DebugCheats)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_DebugCheats_Event_ActionExecuted
---@field Action Feature_DebugCheats_Action
---@field Context Feature_DebugCheats_Action_Context

---@class Feature_DebugCheats_Hook_IsActionValidInContext
---@field Action Feature_DebugCheats_Action
---@field Context Feature_DebugCheats_Context
---@field IsValid boolean Hookable. Defaults to `false`.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_DebugCheats_Net_ActionExecuted
---@field ActionID string
---@field Context table Needs to be serializable.

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Feature_DebugCheats_Context "Character"|"Item"|"Ground"

---@class Feature_DebugCheats_Action_Context

---@alias Feature_DebugCheats_ActionType "Feature_DebugCheats_Action_Character"|"Feature_DebugCheats_Action_Item"|"Feature_DebugCheats_Action_Position"|"Feature_DebugCheats_Action_Quantified"|"Feature_DebugCheats_Action_QuantifiedCharacter"|"Feature_DebugCheats_Action_String"|"Feature_DebugCheats_Action_ParametrizedCharacter"

---------------------------------------------
-- METHODS
---------------------------------------------

---Executes an action.
---@param actionID string
---@param contextData Feature_DebugCheats_Action_Context
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
---@generic T
---@param id string
---@param actionType `T`|Feature_DebugCheats_ActionType
---@param data table
---@return Feature_DebugCheats_Action|`T` --Will call default constructor with only ID passed.
function DebugCheats.RegisterAction(id, actionType, data)
    local class = DebugCheats:GetClass(actionType)
    if not (class and class:ImplementsClass("Feature_DebugCheats_Action")) then
        DebugCheats:Error("RegisterAction", actionType, " does not implement Feature_DebugCheats_Action")
    end
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

---Returns the actions that are valid for a context type.
---@param context Feature_DebugCheats_Context
---@return Feature_DebugCheats_Action[]
function DebugCheats.GetActions(context)
    local actions = {}

    for _,action in pairs(DebugCheats._Actions) do
        local hook = DebugCheats.Hooks.IsActionValidInContext:Throw({
            Action = action,
            Context = context,
            IsValid = false,
        })

        if hook.IsValid then
            table.insert(actions, action)
        end
    end

    return actions
end

---Encodes a context to be sent over the net.
---@param context Feature_DebugCheats_Action_Context|Feature_DebugCheats_Action_Context_Character|Feature_DebugCheats_Action_Context_Quantified|Feature_DebugCheats_Action_Context_String|Feature_DebugCheats_Action_Context_Position|Feature_DebugCheats_Action_Context_Item
---@return table
function DebugCheats._EncodeNetContext(context) -- TODO make this hookable
    local data = {}

    data.CharacterNetID = context.TargetCharacter and context.TargetCharacter.NetID
    data.ItemNetID = context.TargetItem
    data.Position = context.Position
    data.Amount = context.Amount
    data.String = context.String

    return data
end

---Parses context data from a net message.
---@param data table
---@return Feature_DebugCheats_Action_Context
function DebugCheats._ParseNetContext(data) -- TODO make this hookable
    local context = {} ---@type Feature_DebugCheats_Action_Context

    if data.CharacterNetID then
        context.TargetCharacter = Character.Get(data.CharacterNetID)
    end
    if data.ItemNetID then
        context.TargetItem = Item.Get(data.ItemNetID)
    end
    if data.Position then
        context.Position = Vector.Create(data.Position)
    end

    context.Amount = data.Amount
    context.String = data.String

    return context
end

---Executes an action.
---@param action Feature_DebugCheats_Action
---@param contextData Feature_DebugCheats_Action_Context
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

-- Default implementation for IsActionValidInContext.
---@type table<Feature_DebugCheats_Context, DataStructures_Set<string>>
local CONTEXT_CLASSES = {
    ["Character"] = Set.Create({
        "Feature_DebugCheats_Action_Character",
        "Feature_DebugCheats_Action_ParametrizedCharacter",
    }),
    ["Item"] = Set.Create({
        "Feature_DebugCheats_Action_Item",
    }),
    ["Ground"] = Set.Create({
        "Feature_DebugCheats_Action_Position",
    }),
}
DebugCheats.Hooks.IsActionValidInContext:Subscribe(function (ev)
    local context = ev.Context

    if CONTEXT_CLASSES[context]:Contains(ev.Action:GetClassName()) then
        ev.IsValid = true
    end
end)