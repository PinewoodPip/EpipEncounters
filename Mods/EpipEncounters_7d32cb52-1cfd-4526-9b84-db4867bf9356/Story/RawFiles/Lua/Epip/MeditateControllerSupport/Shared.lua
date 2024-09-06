
---@class Features.MeditateControllerSupport : Feature
local Support = {
    NETMSG_INTERACT = "Features.MeditateControllerSupport.NetMsg.InteractWithElement",
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

---@class Features.MeditateControllerSupport.NetMsg.ExitUI : NetLib_Message_Character
