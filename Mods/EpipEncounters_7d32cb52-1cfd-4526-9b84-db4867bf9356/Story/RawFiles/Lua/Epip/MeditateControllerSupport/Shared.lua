
---@class Features.MeditateControllerSupport : Feature
local Support = {
    DEFAULT_PAGE = "Page_MainHub",

    NETMSG_INTERACT = "Features.MeditateControllerSupport.NetMsg.InteractWithElement",
    NETMSG_SCROLL_WHEEL = "Features.MeditateControllerSupport.NetMsg.ScrollWheel",
    NETMSG_INTERACT_WHEEL = "Features.MeditateControllerSupport.NetMsg.InteractWithWheel",
    NETMSG_BACK = "Features.MeditateControllerSupport.NetMsg.Back",
    NETMSG_EXIT = "Features.MeditateControllerSupport.NetMsg.ExitUI",
    TranslatedStrings = {

    },
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
}
Epip.RegisterFeature("Features.MeditateControllerSupport", Support)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.MeditateControllerSupport.NetMsg.InteractWithElement : NetLib_Message_Character
---@field CollectionID string
---@field PageID string For sanity/sync checks.
---@field ElementID string
---@field EventID string StoryUse action data is unmapped; thus we cannot fetch the event ID automatically.

---@class Features.MeditateControllerSupport.NetMsg.Back : NetLib_Message_Character

---@class Features.MeditateControllerSupport.NetMsg.ExitUI : NetLib_Message_Character

---@class Features.MeditateControllerSupport.NetMsg.ScrollWheel : NetLib_Message_Character
---@field PageID string For sanity/sync checks.
---@field WheelID string
---@field Direction "Previous"|"Next"

---@class Features.MeditateControllerSupport.NetMsg.InteractWithWheel : NetLib_Message_Character
---@field PageID string For sanity/sync checks.
---@field WheelID string
---@field EventID string
