
---@class Features.MeditateControllerSupport : Feature
local Support = {
    DEFAULT_PAGE = "Page_MainHub",

    NETMSG_INTERACT = "Features.MeditateControllerSupport.NetMsg.InteractWithElement",
    NETMSG_SCROLL_WHEEL = "Features.MeditateControllerSupport.NetMsg.ScrollWheel",
    NETMSG_INTERACT_WHEEL = "Features.MeditateControllerSupport.NetMsg.InteractWithWheel",
    NETMSG_SEND_NODE_DATA = "Features.MeditateControllerSupport.NetMsg.SendNodeData",
    NETMSG_SET_ASPECT = "Features.MeditateControllerSupport.NetMsg.SetAspect",
    NETMSG_SET_ASPECT_NODE = "Features.MeditateControllerSupport.NetMsg.SetAspectNode",
    NETMSG_BACK = "Features.MeditateControllerSupport.NetMsg.Back",
    NETMSG_DESELECT = "Features.MeditateControllerSupport.NetMsg.DeselectElement",
    NETMSG_EXIT = "Features.MeditateControllerSupport.NetMsg.ExitUI",
    TranslatedStrings = {
        Label_PreviousNode = {
            Handle = "h3d2488adg92abg4983gbaf6gccce651f920f",
            Text = "Previous Node",
            ContextDescription = [[Input label]],
        },
        Label_NextNode = {
            Handle = "h3c15e2c8gadbag4bd8g9888g232a459755e1",
            Text = "Next Node",
            ContextDescription = [[Input label]],
        },
    },
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
}
Epip.RegisterFeature("Features.MeditateControllerSupport", Support)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.MeditateControllerSupport.Page.AspectGraph : Features.MeditateControllerSupport.Page

---@class Features.MeditateControllerSupport.Page.AspectGraph.Node : Features.MeditateControllerSupport.Page.Graph.Node
---@field Subnodes integer

---@class Features.MeditateControllerSupport.AspectGraph
---@field AspectID string
---@field StartingNode string
---@field Nodes table<string, Features.MeditateControllerSupport.Page.AspectGraph.Node>
---@field NodeOrder string[]

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.MeditateControllerSupport.NetMsg.InteractWithElement : NetLib_Message_Character
---@field CollectionID string
---@field PageID string For sanity/sync checks.
---@field ElementID string
---@field EventID string StoryUse action data is unmapped; thus we cannot fetch the event ID automatically.

---@class Features.MeditateControllerSupport.NetMsg.Back : NetLib_Message_Character

---@class Features.MeditateControllerSupport.NetMsg.DeselectElement : NetLib_Message_Character

---@class Features.MeditateControllerSupport.NetMsg.ExitUI : NetLib_Message_Character

---@class Features.MeditateControllerSupport.NetMsg.ScrollWheel : NetLib_Message_Character
---@field PageID string For sanity/sync checks.
---@field WheelID string
---@field Direction "Previous"|"Next"

---@class Features.MeditateControllerSupport.NetMsg.InteractWithWheel : NetLib_Message_Character
---@field PageID string For sanity/sync checks.
---@field WheelID string
---@field EventID string

---@class Features.MeditateControllerSupport.NetMsg.SetAspect
---@field AspectID string

---@class Features.MeditateControllerSupport.NetMsg.SetAspectNode
---@field NodeID string? `nil` if a node was deselected.

---@class Features.MeditateControllerSupport.NetMsg.SendNodeData
---@field Aspects table<string, Features.MeditateControllerSupport.AspectGraph>