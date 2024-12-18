
local Inventory = Client.UI.PartyInventory

---@class Feature_AutoUnlockPartyInventory
local AutoUnlock = Epip.GetFeature("Feature_AutoUnlockPartyInventory")
AutoUnlock.SETTING_ID = "Inventory_AutoUnlockInventory"

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function AutoUnlock:IsEnabled()
    return Settings.GetSettingValue("Epip_Inventory", AutoUnlock.SETTING_ID) and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for inventory lock being toggled - we synchronize this manually, as the engine seems to struggle at this.
-- The extra "scripted" parameter is just coming from lua. The UI is not modified.
Inventory:RegisterCallListener("lockInventory", function (ev, flashCharacterHandle, state, isScripted)
    if not isScripted then -- Needs to be done even for clients with the setting disabled.
        AutoUnlock:DebugLog("Synching lock/unlock request")

        Net.PostToServer("EPIPENCOUNTERS_ToggleInventoryLock", {
            NetID = Character.Get(flashCharacterHandle, true).NetID,
            State = state,
        })

        ev:PreventAction()
    end
end)

-- Listen for being notified of other characters wanting to have their inventory unlocked.
Net.RegisterListener("EPIPENCOUNTERS_ToggleInventoryLock", function (payload)
    local char = Character.Get(payload.NetID)

    AutoUnlock:DebugLog("Received request to unlock inventory of " .. char.DisplayName)

    Inventory:ExternalInterfaceCall("lockInventory", Ext.UI.HandleToDouble(char.Handle), payload.State, true) -- We add an extra parameter to distinguish scripted calls.
end)

-- Request inventory to be opened when the game is ready.
GameState.Events.ClientReady:Subscribe(function (_)
    if AutoUnlock:IsEnabled() then
        Timer.Start(2, function (_) -- Possibly unnecessary?
            AutoUnlock:DebugLog("Requesting unlock")

            local characters = Client.UI.PlayerInfo.GetCharacters(true)
            for _,char in ipairs(characters) do
                AutoUnlock:DebugLog("Unlocking inventory of " .. char.DisplayName)

                Net.PostToServer("EPIPENCOUNTERS_ToggleInventoryLock", {NetID = char.NetID, State = false})
            end
        end)
    end
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse})