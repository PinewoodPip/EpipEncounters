
local AMERUI = Game.AMERUI

function AMERUI.ClientIsInSocketScreen()
    local state = AMERUI.GetState(Client.GetCharacter())

    return state ~= nil and state.Interface == AMERUI.INTERFACES.GREATFORGE.ID and state.Page == AMERUI.INTERFACES.GREATFORGE.PAGES.MAINHUB 
end

function AMERUI.GetState(char)
    if not char then char = Client.GetCharacter() end
    local state = AMERUI.characterStates[char.MyGuid]

    return state
end

function AMERUI.ClientIsInUI()
    -- local char = Utilities.GetPrefixedGUID(Client.GetCharacter())
    -- local state = AMERUI.characterStates[char]
    -- return state ~= nil
    return Client.GetCharacter():GetStatus(Game.Ascension.MEDITATING_STATUS)
end

Net.RegisterListener("EPIPENCOUNTERS_AMERUI_StateChanged", function(payload)
    local guid = payload.Character
    local char = Character.Get(guid)

    if not payload.Interface then
        AMERUI.characterStates[guid] = nil

        Utilities.Log("Client.AMERUI", "Exited UI: " .. guid)

        Utilities.Hooks.FireEvent("AMERUI", "CharacterExitedUI", payload)
    else
        AMERUI.characterStates[guid] = {
            Instance = payload.Instance,
            Interface = payload.Interface,
            Page = payload.Page,
        }

        Utilities.Log("Client.AMERUI", "Entered UI: " .. guid .. " UI " .. payload.Interface .. " Page " .. payload.Page)

        Utilities.Hooks.FireEvent("AMERUI", "CharacterEnteredUI", payload)
    end

    -- NOTE: BEHAVES WRONGLY WHEN CHANGING CHARS!!!! TODO FIX
    if char == Client.GetCharacter().MyGuid then
        if not payload.Interface then
            Utilities.Hooks.FireEvent("AMERUI", "ClientExitedUIs")
        else
            Utilities.Hooks.FireEvent("AMERUI", "ClientUIChanged", payload)
        end
    end
end)

-- Ext.Events.InputEvent:Subscribe(function(event)
--     Ext.Dump(event)
-- end)