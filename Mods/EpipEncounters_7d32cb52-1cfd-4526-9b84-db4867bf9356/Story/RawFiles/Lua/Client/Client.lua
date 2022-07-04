
---@meta Client, ContextClient

Client = {
    UI = {},
    Input = {}, -- See Input.lua

    ---------------------------------------------
    -- Internal variables - do not set
    ---------------------------------------------

    IS_HOST = false,
    GAME_STATES = {
        UNKNOWN = "Unknown",
        INIT = "Init",
        INIT_MENU = "InitMenu",
        INIT_NETWORK = "InitNetwork",
        INIT_CONNECTION = "InitConnection",
        IDLE = "Idle",
        LOAD_MENU = "LoadMenu",
        MENU = "Menu",
        EXIT = "Exit",
        SWAP_LEVEL = "SwapLevel",
        LOAD_LEVEL = "LoadLevel",
        LOAD_MODULE = "LoadModule",
        LOAD_SESSION = "LoadSession",
        LOAD_GM_CAMPAIGN = "LoadGMCampaign",
        UNLOAD_LEVEL = "UnloadLevel",
        UNLOAD_MODULE = "UnloadModule",
        UNLOAD_SESSION = "UnloadSession",
        PAUSED = "Paused",
        PREPARE_RUNNING = "PrepareRunning",
        RUNNING = "Running",
        DISCONNECT = "Disconnect",
        JOIN = "Join",
        SAVE = "Save",
        START_SAVING = "StartLoading",
        STOP_LOADING = "StopLoading",
        START_SERVER = "StartServer",
        MOVIE = "Movie",
        INSTALLATION = "Installation",
        GAME_MASTER_PAUSE = "GameMasterPause",
        MOD_RECEIVING = "ModReceiving",
        LOBBY = "Lobby",
        BUILD_STORY = "BuildStory",
        LOAD_LOCALIZATION = "LoadLoca", -- Name confirmed by Norbyte, though looks to be unused?
    },
}
Epip.InitializeLibrary("Client", Client)

---Get the Source Infusion level the client character is currently preparing.
---@meta EE
---@return number Infusion level
function Client.GetPreparedInfusionLevel()
    return Game.Character.GetPreparedInfusionLevel(Client.GetCharacter())
end

---Returns true if the client character is preparing a Source Infusion.
---@meta EE
---@return boolean
function Client.IsPreparingInfusion()
    return Game.Character.IsPreparingInfusion(Client.GetCharacter())
end

---Returns true if the client is the host of the current session.  
---Relies on GameMenu.
---@return boolean
function Client.IsHost()
    return Client.IS_HOST
end

---Returns the current date and time as a string.
---@return string
function Client.GetDateString()
    local ui = Client.UI.Vanity:GetUI()
    local date = ui:GetRoot().getDate()

    return date
end

---Returns the current date and time as an object. Relies on Client.UI.Time
---@param utc? boolean Whether to use UTC time. Defaults to false.
---@return DateTime
function Client.GetDate(utc)
    return Client.UI.Time.GetDate(utc)
end

---Returns true if the client character is currently in dialogue.
---@return boolean
function Client.IsInDialogue()
    return Ext.UI.GetByPath("Public/Game/GUI/dialog.swf") ~= nil
end

---Returns the currently-controlled character on the client.  
---Checks StatusConsole (or bottomBar for controllers), then CharacterCreation and Hotbar as a fallback.
---@return EclCharacter
function Client.GetCharacter()
    -- StatusConsole is the most reliable UI from my experience. CharacterSheet and Hotbar can fail/lag behind (and the former is not updated while closed!)
    local ui
    local handle
    local char = nil
    local isController = Client.IsUsingController()

    if isController then
        ui = Ext.UI.GetByPath("Public/Game/GUI/bottomBar_c.swf")
        handle = ui:GetRoot().characterHandle

        if handle then
            handle = Ext.UI.DoubleToHandle(handle)
        end
    else
        ui = Ext.UI.GetByType(Client.UI.Data.UITypes.statusConsole)
        handle = ui:GetPlayerHandle()
        -- If StatusConsole fails, we must be in CharacterCreation.
        if not handle then 
            ui = Ext.UI.GetByType(Client.UI.Data.UITypes.characterCreation)

            if ui then
                handle = ui:GetRoot().characterHandle -- GetPlayerHandle() does not work for this UI
            
                if handle then
                    handle = Ext.UI.DoubleToHandle(handle)
                else
                    -- Last resort attempt: try the hotbar UI
                    if Client.UI.Hotbar:GetUI() then
                        handle = Client.UI.Hotbar:GetUI():GetPlayerHandle()
                    end
                end
            end
        end
    end

    if handle then
        char = Ext.GetCharacter(handle)
    end
    
    return char
end

---Returns true if the game is in a gameplay state, or late into loading.
---@return string
function Client.IsInGameplayState()
    local state = Ext.Client.GetGameState()
    local STATES = Client.GAME_STATES

    return state == STATES.LOAD_SESSION or state == STATES.RUNNING or state == STATES.PREPARE_RUNNING
end

--- Copies text to the clipboard.  
---Some characters, like newlines, will be trimmed out as per the vanilla scripting on the swf.
---Relies on MessageBox.
---@param text string
function Client.CopyToClipboard(text)
    Client.UI.MessageBox.CopyToClipboard(text)
end

---Returns whether the client's char is currently playing its turn in a combat.
---Relies on StatusConsole.
---@return boolean
function Client.IsActiveCombatant()
    local sc = Client.UI.StatusConsole
    local root = sc:GetRoot()

    return root and root.fightButtons_mc.duoBtns_mc.visible
end

---Returns whether the client char is in combat.
---@return boolean
function Client.IsInCombat()
    local char = Client.GetCharacter()
    return char and Game.Character.IsInCombat(char)
end

---Returns whether the client is using a controller.
---@return boolean
function Client.IsUsingController()
    return Ext.UI.GetByPath("Public/Game/GUI/msgBox_c.swf") ~= nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the save/load buttons being added to the pause menu to
-- determine if this client is the host.
Utilities.Hooks.RegisterListener("GameMenu", "ButtonAdded", function(id, name, enabled)
    -- only the host has load/save buttons, so we know this client is hosting if these are present
    if id == Client.UI.GameMenu.BUTTON_IDS.LOAD then
        if not Client.IS_HOST then -- don't spam the message
            Client.IS_HOST = true
            Client:Log("Client is hosting.")
            Client:FireEvent("DeterminedAsHost")
        end
    end
end)

-- Forward saving events
Utilities.Hooks.RegisterListener("Saving", "SavingStarted", function()
    Client:FireEvent("SavingStarted")
end)

Utilities.Hooks.RegisterListener("Saving", "SavingFinished", function()
    Client:FireEvent("SavingFinished")
end)

-- Fire event on resizes
-- TODO does this fail if sheet hasnt been opened yet?
Ext.RegisterUITypeCall(119, "setPosition", function(ui, method, pos1, mode, pos2)
    local viewport = Ext.UI.GetViewportSize()
    
    Client:FireEvent("ViewportChanged", viewport[1], viewport[2])
end)