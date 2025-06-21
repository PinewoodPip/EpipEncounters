
---------------------------------------------
-- Miscellaneous options related to player infos,
-- and cheat menu for developer mode, all available from a context menu.
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo
local cheatMenu = Debug.CheatsContextMenu

---@type Feature
local PlayerInfoContextMenu = {
    TranslatedStrings = {
        Label_Header = {
            Handle = "he60622c5g07adg4b95g9df4g673e55c5d33a",
            Text = "—— Player Status ——",
            ContextDescription = [[Header shown in context menu when right-clicking a player portrait.]],
        },
        Label_ShowStatuses = {
            Handle = "h58d447e9gf7e7g4299gbae7gbc1c9e70adda",
            Text = "Show Statuses",
            ContextDescription = [[Option in context menu]],
        },
        Label_ShowSummons = {
            Handle = "hd8528c79g1e8ag48f3g8241g38332e78cc95",
            Text = "Show Summons",
            ContextDescription = [[Option in context menu]],
        },
    }
}
Epip.RegisterFeature("PlayerInfoContextMenu", PlayerInfoContextMenu)
local TSK = PlayerInfoContextMenu.TranslatedStrings

if not Epip.IsDeveloperMode() then cheatMenu = nil end

-- Show status toggle context menu, as well as debugging cheats.
local lastCharHandle = nil ---@type CharacterHandle?
Ext.Events.UICall:Subscribe(function (ev) -- Very hasty workaround for not having the character handle
    if ev.Function == "pipRequestContextMenu" then
        if ev.Args[1] == "playerInfoPlayerPortrait" then
            lastCharHandle = Ext.UI.DoubleToHandle(ev.Args[4])
        end
    end
end, {Priority = 99999})
Client.UI.ContextMenu.RegisterMenuHandler("playerInfoPlayerPortrait", function()
    local data = {
        {id = "playerInfo_Header", type = "header", text = TSK.Label_Header:GetString()},

        -- openCharInventory no longer works in engine, it seems.
        -- {id = "playerInfo_OpenInventory", type = "button", text = "Open Inventory"},
        {id = "playerInfo_ToggleStatuses", type = "checkbox", text = TSK.Label_ShowStatuses:GetString(), checked = PlayerInfo.GetStatusesVisibility()},
        {id = "playerInfo_ToggleSummons", type = "checkbox", text = TSK.Label_ShowSummons:GetString(), checked = PlayerInfo.GetSummonsVisibility()},

        cheatMenu,
    }
    -- Run hook
    data = PlayerInfo.Hooks.GetContextMenuEntries:Throw({
        Entries = data,
        IsSummon = false,
        Character = lastCharHandle and Character.Get(lastCharHandle) or nil,
    }).Entries

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = data,
        }
    })

    Client.UI.ContextMenu.Open()
end)

-- Same as above, but for summons - toggling statuses/hiding summons makes no sense for them
Client.UI.ContextMenu.RegisterMenuHandler("playerInfoSummonPortrait", function()
    local data = {
        {id = "playerInfo_Header", type = "header", text = TSK.Label_Header:GetString()},

        cheatMenu,
    }
    -- Run hook
    data = PlayerInfo.Hooks.GetContextMenuEntries:Throw({
        Entries = data,
        IsSummon = true,
    }).Entries

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = data,
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