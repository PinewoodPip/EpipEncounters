
---------------------------------------------
-- Implements the ability to customize container item icons.
---------------------------------------------

---@class Features.ContainerCustomization : Feature
local Customization = {
    NETMSG_SET_ICON = "Features.ContainerCustomization.SetIcon",
    ICON_TAG_TEMPLATE = "Features.ContainerCustomization.Icon.%s",
    ICON_TAG_PATTERN = "Features%.ContainerCustomization%.Icon%.(.+)",

    TranslatedStrings = {
        Label_SetIcon = {
            Handle = "hbaa52d27g137eg4101gb6a8gcba7fc222552",
            Text = "Set icon...",
            ContextDescription = [[Context menu option]],
        },
        Label_ResetIcon = {
            Handle = "h01593888g2003g4c04g8a69g1b02ea6ae107",
            Text = "Reset icon",
            ContextDescription = [[Context menu option]],
        },
    }
}
Epip.RegisterFeature("Features.ContainerCustomization", Customization)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.ContainerCustomization.SetIcon : NetLib_Message_Item
---@field Icon icon? `nil` if the icon override is being removed.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the icon override for an item, if any.
---@param item Item
---@return icon? -- `nil` if the icon of the item has not been customized.
function Customization.GetIconOverride(item)
    for _,tag in ipairs(item:GetTags()) do
        local icon = tag:match(Customization.ICON_TAG_PATTERN)
        if icon then
            return icon
        end
    end
    return nil
end
