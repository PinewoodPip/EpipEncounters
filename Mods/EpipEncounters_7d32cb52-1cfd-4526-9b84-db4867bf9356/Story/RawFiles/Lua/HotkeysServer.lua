
hotkeyCooldowns = {}

function SetHotkeyOnCooldown(id, seconds)
    hotkeyCooldowns[id] = {time = Ext.Utils.MonotonicTime(), cooldown = seconds}
end

function GetTimeSpan(tick1, tick2) -- get time elapsed between 2 MonotonicTimes, in seconds
    local ticks = tick1 - tick2
    return ticks / 1000
end

function IsHotkeyReady(id)
    if not hotkeyCooldowns[id] then return true end

    return GetTimeSpan(Ext.Utils.MonotonicTime(), hotkeyCooldowns[id].time) > hotkeyCooldowns[id].cooldown
end

Net.RegisterListener("EPIPENCOUNTERS_Hotkey_Meditate", function(payload)
    local char = Ext.GetCharacter(payload.NetID).MyGuid

    if IsHotkeyReady("PIP_Meditate") then
        Osi.PROC_PIP_Hotkey_Meditate(char)
        SetHotkeyOnCooldown("PIP_Meditate", 3)
    end
end)

-- Source infuse
Net.RegisterListener("EPIPENCOUNTERS_Hotkey_SourceInfuse", function(payload)
    local char = Ext.GetCharacter(payload.NetID).MyGuid

    if IsHotkeyReady("PIP_SourceInfuse") then
        Osi.PROC_PIP_Hotkey_Infuse(char)
        SetHotkeyOnCooldown("PIP_SourceInfuse", 1)
    end
end)

-- Toggle party link
Net.RegisterListener("EPIPENCOUNTERS_Hotkey_TogglePartyLink", function(payload)
    local char = Ext.GetCharacter(payload.NetID).MyGuid

    if IsHotkeyReady("PIP_TogglePartyLink") then
        Osi.PROC_PIP_Hotkey_TogglePartyLink(char)
        SetHotkeyOnCooldown("PIP_TogglePartyLink", 1)
    end
end)

-- Bedroll rest (requires a bedroll, yes; but just one per party)
Net.RegisterListener("EPIPENCOUNTERS_Hotkey_UserRest", function(payload)
    local char = Ext.GetCharacter(payload.NetID).MyGuid

    if IsHotkeyReady("PIP_UserRest") then
        Osi.PROC_PIP_Hotkey_UserRest(char)
        SetHotkeyOnCooldown("PIP_UserRest", 1)
    end
end)

-- Portable Respec Mirror (requires a mirror, yes; but just one per party)
Net.RegisterListener("EPIPENCOUNTERS_Hotkey_Respec", function(payload)
    local char = Ext.GetCharacter(payload.NetID).MyGuid

    if IsHotkeyReady("PIP_Respec") then
        Osi.PROC_PIP_Hotkey_Respec(char)
        SetHotkeyOnCooldown("PIP_Respec", 2)
    end
end)