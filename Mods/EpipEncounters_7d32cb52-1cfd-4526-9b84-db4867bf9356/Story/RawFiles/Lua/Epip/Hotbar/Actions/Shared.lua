
---------------------------------------------
-- Hotbar actions implemented by Epip.
-- Supports forwarding action events to the server as well as cooldowns.
---------------------------------------------

---@class Feature_HotbarActions : Feature
local Actions = {
    -- Cooldowns for hotkeys. Stores the last time the hotkey was ran at and the requested cooldown.
    -- Mainly used to prevent some Ascension features from breaking if they are accessed multiple times in a quick succession.
    _ActionCooldowns = {}, ---@type table<string, {Time: integer, Cooldown: number}>>
    _ActionsByID = {}, ---@type table<string, Feature_HotbarActions_Action>

    NET_MSG_ACTION_USED = "Feature_HotbarActions_NetMsg_ActionUsed",

    -- TODO extract TSKs
    ---@type Feature_HotbarActions_Action[]
    ACTIONS = {
        {
            ID = "EPIP_Journal",
            Name = "Journal",
            Icon = "hotbar_icon_announcement",
        },
        {
            ID = "EPIP_UserRest",
            Name = "Bedroll Rest",
            Icon = "hotbar_icon_laureate",
            DefaultIndex = 9,
        },
        {
            ID = "EPIP_TogglePartyLink",
            Name = "Chain/Unchain",
            Icon = "hotbar_icon_infinity",
            DefaultIndex = 10,
            Cooldown = 1,
        },
        {
            ID = "EE_Meditate",
            Name = "Meditate",
            Icon = "hotbar_icon_nongachatransmute",
            DefaultIndex = 11,
            RequiresEE = true,
            Cooldown = 3,
        },
        {
            ID = "EE_SourceInfuse",
            Name = "Source Infuse",
            Icon = "hotbar_icon_sp",
            DefaultIndex = 12,
            RequiresEE = true,
            Cooldown = 1,
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

-- Generate string ID -> action map
for _,action in ipairs(Actions.ACTIONS) do
    Actions._ActionsByID[action.ID] = action
end

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