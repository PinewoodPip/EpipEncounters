
local ConnectionMenu = {
    STATE_IDS = {
        ANYBODY = 0,
        FRIENDS_ONLY = 1,
        INVITE_ONLY = 2,
        LOCAL = 3,
    },
    CHECKBOX_IDS = {
        LAN = 0,
        DIRECT_CONNECT = 1,
    },
}
Epip.InitializeUI(Client.UI.Data.UITypes.connectionMenu, "ConnectionMenu", ConnectionMenu)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- TODO
Client:RegisterListener("DeterminedAsHost", function()
    -- Client.UI.GameMenu:GetUI():ExternalInterfaceCall("buttonPressed", Client.UI.GameMenu.BUTTON_IDS.CONNECTIVITY)

    -- Timer.Start("_ConnectivityMenuLANToggle", 0.3, function()
    --     ConnectionMenu:GetUI():ExternalInterfaceCall("checkBoxID", ConnectionMenu.CHECKBOX_IDS.LAN, 1)
    --     ConnectionMenu:GetUI():ExternalInterfaceCall("cancelPressed")
    --     Client.UI.GameMenu.GetUI():ExternalInterfaceCall("buttonPressed", Client.UI.GameMenu.BUTTON_IDS.RESUME)
    -- end)
end)