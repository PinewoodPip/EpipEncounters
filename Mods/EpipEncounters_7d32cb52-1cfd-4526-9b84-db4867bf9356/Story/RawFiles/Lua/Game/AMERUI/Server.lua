
local AMERUI = Game.AMERUI

function AMERUI.UpdateState(char, instance, interface, page)

    AMERUI.characterStates[char] = {
        Instance = instance,
        Interface = interface,
        Page = page,
    }

    Game.Net.Broadcast("EPIPENCOUNTERS_AMERUI_StateChanged", {Character = char, Interface = interface, Page = page})
end

function AMERUI.ClearState(char)
    Game.Net.Broadcast("EPIPENCOUNTERS_AMERUI_StateChanged", {Character = char})

    AMERUI.characterStates[char] = nil
end

function AMERUI.GetCharOfInstance(instance)
    return Osi.DB_AMER_UI_UsersInUI:Get(instance, nil, nil)[1][3]
end

function AMERUI.GetCurrentPage(instance)
    return Osi.DB_AMER_UI_CurrentPage:Get(instance, nil, nil, nil)[1][3]
end

Ext.Osiris.RegisterListener("PROC_AMER_UI_Page_PageBecame", 3, "after", function(instance, interface, page)
    
    local char = AMERUI.GetCharOfInstance(instance)
    
    AMERUI.UpdateState(char, instance, interface, page)
end)

Ext.Osiris.RegisterListener("PROC_AMER_UI_ActiveCharChanging", 5, "after", function(map, instance, interface, oldChar, newChar)
    AMERUI.ClearState(oldChar)
    AMERUI.UpdateState(newChar, instance, interface, AMERUI.GetCurrentPage(instance))
end)

Ext.Osiris.RegisterListener("PROC_AMER_UI_ExitUI", 3, "after", function(instance, char, ui)
    AMERUI.ClearState(char)
end)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Element interactions.
Ext.Osiris.RegisterListener("CharacterItemEvent", 3, "after", function(char, item, event)
    -- Element wheels.
    if event == AMERUI.ITEM_EVENTS.ELEMENTWHEEL_SCROLL_DOWN then
        AMERUI:FireGlobalEvent("ElementWheelScrolled", item, -1)
    elseif event == AMERUI.ITEM_EVENTS.ELEMENTWHEEL_SCROLL_UP then
        AMERUI:FireGlobalEvent("ElementWheelScrolled", item, 1)
    end
end)