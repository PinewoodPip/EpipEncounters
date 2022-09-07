
local Inventory = Client.UI.PartyInventory

---@class Feature_AutoUnlockPartyInventory
local AutoUnlock = Epip.GetFeature("Feature_AutoUnlockPartyInventory")
AutoUnlock.SETTING_ID = "Inventory_AutoUnlockInventory"

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function AutoUnlock:IsEnabled()
    return Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", AutoUnlock.SETTING_ID) and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for being notified of other characters wanting to have their inventory unlocked.
Net.RegisterListener("EPIPENCOUNTERS_AutoUnlockInventory", function (payload)
    local char = Character.Get(payload.NetID)

    AutoUnlock:DebugLog("Received request to unlock inventory of " .. char.DisplayName)

    -- Need to show the inventory momentarily to avoid a mysterious rare crash that results from v56 inventory sync fixes.
    Inventory:Show()

    Inventory:ExternalInterfaceCall("lockInventory", Ext.UI.HandleToDouble(char.Handle), false)

    Inventory:Hide()
end)

-- Request inventory to be opened when the game is ready.
GameState.Events.GameReady:Subscribe(function (_)
    if AutoUnlock:IsEnabled() then
        AutoUnlock:DebugLog("Requesting unlock")

        local characters = Client.UI.PlayerInfo.GetCharacters(true)
        for _,char in ipairs(characters) do
            AutoUnlock:DebugLog("Unlocking inventory of " .. char.DisplayName)

            Net.PostToServer("EPIPENCOUNTERS_AutoUnlockInventory", {NetID = char.NetID})
        end
    end
end)