
------------------------------------
-- This script spams the console with UI calls/invokes, optionally filtered per UI and call.
-- Copy-pasted from Focus, credits to them.
-- Only active when a dropdown is set within the mod settings, visible only in developer mode.
------------------------------------

local SpamCalls = {
    ['updateStatuses'] = true,
    ['addTooltip'] = true,
    ['update'] = true,
    ['removeLabel'] = true,
    ['updateSlotData'] = true,
    ['setBar1Progress'] = true,
    ['setInputDevice'] = true,
    ['setAllSlotsEnabled'] = true,
    ['updateBtnInfos'] = true,
}

local sniffAll = false
local UITypeToID = Client.UI.Data.UITypes
local uis = {
    -- [UITypeToID.overhead] = true,
    -- [UITypeToID.hotBar] = true,
    -- [UITypeToID.characterCreation] = true,
    [UITypeToID.worldTooltip] = true,
}

local function SniffInvoke(event)
    local call = event.Function
    local ui = event.UI

    if SpamCalls[call] then return end
    if not uis[ui:GetTypeId()] and not sniffAll then return nil end

    Ext.Print("Engine.UIInvoke", ui:GetTypeId(), call, table.unpack(event.Args))
end

local function SniffCall(event)
    local call = event.Function
    local ui = event.UI

    if SpamCalls[call] then return end
    if not uis[ui:GetTypeId()] and not sniffAll then return nil end

    Ext.Print("Engine.UICall", ui:GetTypeId(), call, table.unpack(event.Args))
end

Ext.Events.SessionLoaded:Subscribe(function()
    local dropdownValue = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "DEBUG_SniffUICalls")

    sniffAll = dropdownValue == 3

    if dropdownValue and dropdownValue > 1 then
        Utilities.Log("Debug", "Sniffing UI calls/invokes!")

        Ext.Events.UIInvoke:Subscribe(SniffInvoke)
        Ext.Events.UICall:Subscribe(SniffCall)
    end
end)
