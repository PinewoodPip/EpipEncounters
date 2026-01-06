
---@class Features.ContainerCustomization
local Customization = Epip.GetFeature("Features.ContainerCustomization")

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets a custom icon for an item.
---@param item EsvItem
---@param icon icon?
function Customization.SetIcon(item, icon)
    Customization.ClearIcon(item) -- Clear existing icon override first
    local iconTag = string.format(Customization.ICON_TAG_TEMPLATE, icon)
    Osi.SetTag(item.MyGuid, iconTag)

    Net.Broadcast(Customization.NETMSG_SET_ICON, {
        ItemNetID = item.NetID,
        Icon = icon,
    })
end

---Clears a custom icon for an item.
---@param item EsvItem
function Customization.ClearIcon(item)
    local iconOverride = Customization.GetIconOverride(item)
    if not iconOverride then return end
    local iconTag = string.format(Customization.ICON_TAG_TEMPLATE, iconOverride)
    Osi.ClearTag(item.MyGuid, iconTag)

    Net.Broadcast(Customization.NETMSG_SET_ICON, {
        ItemNetID = item.NetID,
        Icon = nil,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to set item icons.
Net.RegisterListener(Customization.NETMSG_SET_ICON, function (ev)
    local item = ev:GetItem()
    if ev.Icon then
        Customization.SetIcon(item, ev.Icon)
    else
        Customization.ClearIcon(item)
    end
end)