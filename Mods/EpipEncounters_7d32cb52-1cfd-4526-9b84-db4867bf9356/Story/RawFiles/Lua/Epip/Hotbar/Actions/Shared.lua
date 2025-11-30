
---------------------------------------------
-- Hotbar actions implemented by Epip.
-- Supports forwarding action events to the server as well as cooldowns.
---------------------------------------------

local CommonStrings = Text.CommonStrings

---@class Feature_HotbarActions : Feature
local Actions = {
    -- Cooldowns for hotkeys. Stores the last time the hotkey was ran at and the requested cooldown.
    -- Mainly used to prevent some Ascension features from breaking if they are accessed multiple times in a quick succession.
    _ActionCooldowns = {}, ---@type table<string, {Time: integer, Cooldown: number}>>
    _ActionsByID = {}, ---@type table<string, Feature_HotbarActions_Action>

    NET_MSG_ACTION_USED = "Feature_HotbarActions_NetMsg_ActionUsed",
    NET_MSG_USERREST_NOBEDROLL = "Features.HotbarActions.NetMsg.NoBedroll", -- Empty message.

    TELEPORTER_PYRAMID_GUIDS = {
        ["fd45268f-5953-47c4-ba2f-255a05e2ce0e"] = true,
        ["34810bdd-1185-468b-a5af-3298d0a861cf"] = true,
        ["74f7068e-d388-4ffe-9e68-89406a6049d1"] = true,
        ["e90a55e7-973e-4c77-b4b3-65f87808791c"] = true,
    },
    PYRAMID_DISABLED_TAG = "PYRAMID_DISABLED",

    ---@type Feature_HotbarActions_Action[]
    ACTIONS = {},

    TranslatedStrings = {
        HotbarAction_UserRest = {
           Handle = "ha314a4bag7349g4ec0g9e7eg122821cef234",
           Text = "Bedroll Rest",
           ContextDescription = "Hotbar action name",
        },
        HotbarAction_UserRest_NoBedroll = {
           Handle = "hac06b15egc508g40b1gb729gf0951d875d5f",
           Text = "We do not have a bedroll to rest on!",
           ContextDescription = "Error message for bedroll rest",
        },
        HotbarAction_UsePyramid_Name = {
           Handle = "h4ac91ab1gcde9g4cd5gb8a3gc19b15f3dd4b",
           Text = "Pyramids",
           ContextDescription = "Hotbar action name",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        ActionUsed = {}, ---@type Event<Feature_HotbarActions_Event_ActionUsed>
    },
    Hooks = {},
}
Epip.RegisterFeature("HotbarActions", Actions)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when an action is successfully used. On the server, this only fires for actions with NetMessageChannel set.
---@class Feature_HotbarActions_Event_ActionUsed
---@field Character Character
---@field Action Feature_HotbarActions_Action

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_HotbarActions_NetMsg_ActionUsed : NetLib_Message_Character
---@field ActionID string

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_HotbarActions_Action : HotbarAction
---@field DefaultIndex integer? 1-based.
---@field RequiresEE boolean?
---@field Cooldown number?

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns an action by ID.
---@param id string
---@return Feature_HotbarActions_Action
function Actions.GetAction(id)
    return Actions._ActionsByID[id]
end

---Registers an action.
---@param action Feature_HotbarActions_Action
function Actions.RegisterAction(action)
    Actions.ACTIONS[action.ID] = action
    -- Update string ID -> action map
    Actions._ActionsByID[action.ID] = action

    -- Register the action into the Hotbar API
    if Ext.IsClient() then
        local Hotbar = Client.UI.Hotbar

        if not action.RequiresEE or EpicEncounters.IsEnabled() then
            Hotbar.RegisterAction(action.ID, action)

            -- Place the action at a default index
            if action.DefaultIndex then
                Hotbar.SetHotkeyAction(action.DefaultIndex, action.ID)
            end

            -- Wrap the execute event
            Hotbar.RegisterActionListener(action.ID, "ActionUsed", function (char, _)
                Actions.TryExecuteAction(char, action)
            end)
        end
    end
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register default actions
local actions = {
    {
        ID = "EPIP_UserRest",
        NameHandle = Actions.TranslatedStrings.HotbarAction_UserRest.Handle,
        Icon = "hotbar_icon_laureate",
        DefaultIndex = 9,
    },
    {
        ID = "EE_Meditate",
        NameHandle = CommonStrings.Meditate.Handle,
        Icon = "hotbar_icon_nongachatransmute",
        DefaultIndex = 11,
        RequiresEE = true,
        Cooldown = 3,
    },
    {
        ID = "EE_SourceInfuse",
        NameHandle = CommonStrings.SourceInfuse.Handle,
        Icon = "hotbar_icon_sp",
        DefaultIndex = 12,
        RequiresEE = true,
        Cooldown = 1,
    },
    {
        ID = "EPIP_UsePyramid",
        NameHandle = Actions.TranslatedStrings.HotbarAction_UsePyramid_Name.Handle,
        Icon = "hotbar_icon_bag",
        Cooldown = 1,
    },
}

for _,action in ipairs(actions) do
    Actions.RegisterAction(action)
end
