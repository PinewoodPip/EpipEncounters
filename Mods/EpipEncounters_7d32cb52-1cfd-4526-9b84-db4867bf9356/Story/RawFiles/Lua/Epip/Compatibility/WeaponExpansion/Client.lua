
---------------------------------------------
-- Compatbility considerations for Weapon Expansion.
-- Mainly changes related to the hotbar.
---------------------------------------------

local WEX = {
    Menu = nil,
    ModTable = "WeaponExpansion",
    REQUIRED_MODS = {
        [Mod.GUIDS.WEAPON_EXPANSION] = "LL's Weapon Expansion",
    }
}
local Hotbar = Client.UI.Hotbar
Epip.AddFeature("WeaponExpansionCompatibility", "WeaponExpansionCompatibility", WEX)

function WEX.RepositionButton()
    local button = WEX.Menu.ToggleButtonInstance:GetRoot()

    if true then -- TODO setting
        local hasSecondRow = Hotbar.HasSecondHotkeysRow()

        if hasSecondRow then
            button.y = -68
        else
            button.y = -0
        end
        button.visible = true
    else
        -- Hide original button next to hotbar
        button.visible = false
    end
end

Ext.Events.SessionLoading:Subscribe(function()
    if WEX:IsEnabled() then
        WEX.Menu = Mods[WEX.ModTable].MasteryMenu

        -- Add hotbar action
        Hotbar.RegisterAction("WeaponEX_OpenMasteryMenu", {
            Name = "Mastery",
            Icon = "hotbar_icon_weaponex",
        })

        -- Put it on the actions bar by default - second row, leftmost button
        Hotbar.SetHotkeyAction(7, "WeaponEX_OpenMasteryMenu")

        -- Make it open/close the menu
        Hotbar.RegisterActionListener("WeaponEX_OpenMasteryMenu", "ActionUsed", function(char, actionData)
            WEX.Menu.ToggleButtonInstance:ExternalInterfaceCall("toggleMasteryMenu")

        end)

        -- Highlight the action button while the menu is open
        Hotbar.RegisterActionHook("WeaponEX_OpenMasteryMenu", "IsActionHighlighted", function(isHighlighted, char, actionData, buttonIndex)
            if not isHighlighted then
                isHighlighted = WEX.Menu.Open
            end

            return isHighlighted
        end)

        Ext.RegisterUINameCall("repositionMasteryMenuToggleButton", function()
            WEX.RepositionButton()
        end, "After")

        Ext.RegisterUINameCall("toggleMasteryMenu", function(ui, method, ...)
            -- Move the UI a bit up, so its close button is accessible with 2 hotbar rows
            WEX.Menu.Instance:GetRoot().y = -68
        end, "After")
    end
end)

Ext.Events.SessionLoaded:Subscribe(function()
    if WEX:IsEnabled() then

        Hotbar:RegisterListener("Refreshed", function()
            WEX.RepositionButton()
        end)
        
        -- Remove original button next to hotbar
        -- WEX.Menu.ToggleButtonInstance:GetRoot().visible = false

        -- Move the menu a bit up, so the close button is accessible with 2 hotbar rows
        -- WEX.Menu.Instance:GetRoot().y = -68
    end
end)