
local ContextMenu = Client.UI.ContextMenu
local PartyInventory = Client.UI.PartyInventory
local ContainerInventory = Client.UI.ContainerInventory
local Hotbar = Client.UI.Hotbar
local IconPicker = Epip.GetFeature("Feature_IconPicker")

---@class Features.ContainerCustomization
local Customization = Epip.GetFeature("Features.ContainerCustomization")
local TSK = Customization.TranslatedStrings

-- UIs to refresh when an item's icon is changed.
Customization.UIS_TO_REFRESH = {
    PartyInventory,
    ContainerInventory,
}

Customization._CurrentItemHandle = nil ---@type ItemHandle

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests to override an item's icon.
---@param item EclItem
---@param icon icon? `nil` will clear an existing override.
function Customization.RequestSetIcon(item, icon)
    Net.PostToServer(Customization.NETMSG_SET_ICON, {
        ItemNetID = item.NetID,
        Icon = icon,
    })
end

---Refreshes UIs to update displayed icons.
function Customization.RefreshUIs()
    for _,ui in ipairs(Customization.UIS_TO_REFRESH) do
        if ui:IsVisible() then
            ui:Show()
        end
    end
    Hotbar.Refresh() -- Special case; Epip's hotbar does not listen for being shown/hidden
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add context menu option to customize container icons.
-- Set icon overrides for items upon loading in.
-- Necessary as the `Icon` field is client-only and not persisted.
GameState.Events.GameReady:Subscribe(function (_)
    Customization:DebugLog("Restoring icon overrides...")

    -- Set icon overrides for items in player character inventories.
    local chars = Client.UI.PlayerInfo.GetCharacters()
    for _,char in ipairs(chars) do
        local items = char:GetInventoryItems()
        for _,itemGUID in ipairs(items) do
            local item = Item.Get(itemGUID)
            local icon = Customization.GetIconOverride(item)
            if icon then
                Customization:DebugLog("Found icon override for", item.DisplayName)
                item.Icon = icon
            end
        end
    end
end)

-- Add context menu options to customize container icons & backgrounds.
ContextMenu.RegisterVanillaMenuHandler("Item", function (item)
    if Item.IsContainer(item) and Item.IsInInventory(item) then
        ContextMenu.AddElement({{
            id = "Features.ContainerCustomization.SetIcon",
            type = "button",
            text = TSK.Label_SetIcon:GetString(),
        }})

        -- Add option to clear icon override
        local iconOverride = Customization.GetIconOverride(item)
        if iconOverride then
            ContextMenu.AddElement({{
                id = "Features.ContainerCustomization.ClearIcon",
                type = "button",
                text = TSK.Label_ResetIcon:GetString(),
            }})
        end
    end
end)
ContextMenu.RegisterElementListener("Features.ContainerCustomization.SetIcon", "buttonPressed", function (_, _)
    local item = ContextMenu.GetCurrentEntity()
    if not Entity.IsItem(item) then Customization:__LogWarning("Set icon requested but context menu entity is not an item?") return end
    ---@cast item EclItem

    -- Open icon picker
    Customization._CurrentItemHandle = item.Handle
    IconPicker:SetSettingValue(IconPicker.Settings.IconType, "Containers") -- Default to showing container icons
    IconPicker.Open("Features.ContainerCustomization")
end)
ContextMenu.RegisterElementListener("Features.ContainerCustomization.ClearIcon", "buttonPressed", function (_, _)
    local item = ContextMenu.GetCurrentEntity()
    if not Entity.IsItem(item) then Customization:__LogWarning("Clear icon requested but context menu entity is not an item?") return end
    ---@cast item EclItem

    Customization.RequestSetIcon(item, nil)
end)
IconPicker.Events.IconPicked:Subscribe(function (ev)
    if ev.RequestID ~= "Features.ContainerCustomization" then return end
    local item = Item.Get(Customization._CurrentItemHandle)
    Customization.RequestSetIcon(item, ev.Icon)
end)

-- Handle requests to set item icons.
Net.RegisterListener(Customization.NETMSG_SET_ICON, function (ev)
    local item = ev:GetItem()
    item.Icon = ev.Icon or ""
    Customization.RefreshUIs()
end)
