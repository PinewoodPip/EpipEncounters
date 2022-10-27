
---@class Feature_Vanity_Transmog : Feature
local Transmog = {
    favoritedTemplates = {},
    activeCharacterTemplates = {},
    KEEP_APPEARANCE_TAG_PREFIX = "PIP_Vanity_Transmog_KeepAppearance_",
    INVISIBLE_TAG = "PIP_VANITY_INVISIBLE",
    KEEP_ICON_TAG = "PIP_VANITY_TRANSMOG_ICON_%s",
    KEEP_ICON_PATTERN = "^PIP_VANITY_TRANSMOG_ICON_(.+)$",
    TRANSMOGGED_TAG = "PIP_VANITY_TRANSMOG_TEMPLATE_%s",
    TRANSMOGGED_TAG_PATTERN = "^PIP_VANITY_TRANSMOG_TEMPLATE_(.+)$",

    Events = {},
    Hooks = {},
}
Epip.RegisterFeature("Vanity_Transmog", Transmog)

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