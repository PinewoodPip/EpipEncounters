
---@class Feature_Vanity_Transmog : Feature
local Transmog = {
    NET_MSG_ICON_REMOVED = "Feature_Vanity_Transmog_NetMessage_IconOverrideRemoved",
    NET_MSG_SET_ICON = "Feature_Vanity_Transmog_NetMsg_SetIcon",
    NET_MSG_REVERT_APPEARANCE = "Features.Vanity.Transmog.NetMsgs.RevertAppearance",

    KEEP_APPEARANCE_TAG_PREFIX = "PIP_Vanity_Transmog_KeepAppearance_",
    INVISIBLE_TAG = "PIP_VANITY_INVISIBLE",
    KEEP_ICON_TAG = "PIP_VANITY_TRANSMOG_ICON_%s",
    KEEP_ICON_PATTERN = "^PIP_VANITY_TRANSMOG_ICON_(.+)$",
    TRANSMOGGED_TAG = "PIP_VANITY_TRANSMOG_TEMPLATE_%s",
    TRANSMOGGED_TAG_PATTERN = "^PIP_VANITY_TRANSMOG_TEMPLATE_(.+)$",

    favoritedTemplates = {},
    activeCharacterTemplates = {},

    TranslatedStrings = {
        VanityTabName = {
            Handle = "h4528e43cga37bg40cdg9c6eg6b6144813c87",
            Text = "Transmog",
            ContextDescription = [[Vanity tab name]],
        },
    },

    Events = {},
    Hooks = {},
}
Epip.RegisterFeature("Vanity_Transmog", Transmog)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_Vanity_Transmog_NetMessage_IconOverrideRemoved : NetLib_Message_Item

---@class EPIPENCOUNTERS_Vanity_Transmog_ToggleVisibility : NetLib_Message_State, NetLib_Message_Item, NetLib_Message_Character

---@class Feature_Vanity_Transmog_NetMsg_SetIcon : NetLib_Message_Item, NetLib_Message_Character
---@field Icon icon

---@class Features.Vanity.Transmog.NetMsgs.RevertAppearance : NetLib_Message_Character, NetLib_Message_Item

---------------------------------------------
-- METHODS
---------------------------------------------

---@param item Item
---@return string?
function Transmog.GetIconOverride(item)
    return Entity.GetParameterTagValue(item, Transmog.KEEP_ICON_PATTERN)
end

---Returns the template an item has been transmogged into, if any.
---@param item Item
---@return GUID?
function Transmog.GetTransmoggedTemplate(item)
    return Entity.GetParameterTagValue(item, Transmog.TRANSMOGGED_TAG_PATTERN)
end