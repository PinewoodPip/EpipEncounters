
---------------------------------------------
-- Miscellaneous options related to player infos,
-- and cheat menu for developer mode, all available from a context menu.
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo

local cheatMenu = Debug.CheatsContextMenu

if not Ext.Debug.IsDeveloperMode() then cheatMenu = nil end

-- Show status toggle context menu, as well as debugging cheats.
Client.UI.ContextMenu.RegisterMenuHandler("playerInfoPlayerPortrait", function()

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = {
                {id = "playerInfo_Header", type = "header", text = "—— Player Status ——"},

                -- openCharInventory no longer works in engine, it seems.
                -- {id = "playerInfo_OpenInventory", type = "button", text = "Open Inventory"},
                {id = "playerInfo_ToggleStatuses", type = "checkbox", text = "Show Statuses", checked = PlayerInfo.GetStatusesVisibility()},
                {id = "playerInfo_ToggleSummons", type = "checkbox", text = "Show Summons", checked = PlayerInfo.GetSummonsVisibility()},

                cheatMenu,
            }
        }
    })

    Client.UI.ContextMenu.Open()
end)

-- Same as above, but for summons - toggling statuses/hiding summons makes no sense for them
Client.UI.ContextMenu.RegisterMenuHandler("playerInfoSummonPortrait", function()

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = {
                {id = "playerInfo_Header", type = "header", text = "—— Player Status ——"},

                cheatMenu,
            }
        }
    })

    Client.UI.ContextMenu.Open()
end)

Client.UI.ContextMenu.RegisterElementListener("playerInfo_ToggleStatuses", "buttonPressed", function()
    PlayerInfo.ToggleStatuses()
end)

Client.UI.ContextMenu.RegisterElementListener("playerInfo_ToggleSummons", "buttonPressed", function()
    PlayerInfo.ToggleSummons()
end)