
---------------------------------------------
-- Allows loading additional scripts defined in a json within the Osiris Data directory.
-- Intended usage is to quickly run test/debug scripts without including them in any mod directory.
---------------------------------------------

---@class Features.PersonalScripts : Feature
local PersonalScripts = {
    DEFINITION_PATH = "Epip/CustomScripts.json",
    FOLDER_PATH = "Epip/CustomScripts",
    SAVE_PROTOCOL = 1,

    _ScriptConfigs = {}, ---@type Features.PersonalScripts.Script[]

    TranslatedStrings = {
        FeatureName = {
            Handle = "hbc86d8eag822bg4699g9046gc47787f8565d",
            Text = "Custom Scripts",
            ContextDescription = [[Feature name; appears in settings menu]],
        },
        Label_Explanation = {
            Handle = "he4b6fda6gfaddg43a7gb3ecg20e01e95238e",
            Text = "Custom Scripts allow you to load additional Lua scripts without needing to include them in a mod pak.<br>They can be useful to quickly extend & modify Epip's behaviour, create quick tests and cheats, or small new features.",
            ContextDescription = [[Hint in the settings menu tab]],
        },
        Label_Details = {
            Handle = "hb4f59492g1fdag4824gae84g0eb3c3d4527c",
            Text = [[Put Lua scripts in the %s folder (relative to your savegames folder) and use the "Add Script" button to register and configure them. Custom Scripts load after Epip's, in top-to-bottom order, and are not synchronized between peers.<br>Use the checkboxes to toggle scripts, and the arrow buttons to set load order. A Lua reset or a save & reload is required to reload scripts.]],
            ContextDescription = [[Hint in the settings menu tab. Param is a folder path.]],
        },
        Label_AddScript = {
            Handle = "h4617b458g594dg4024gb37eg8062631ebee9",
            Text = "Add Script",
            ContextDescription = [[Button in settings menu]],
        },
        MsgBox_AddScript_Body = {
            Handle = "hc9cf6a7age288g4bd7gbfbag75c71c1969ae",
            Text = "Enter the script's relative path with no extension.",
            ContextDescription = [[Message box for the "Add script" button]],
        },
        MsgBox_AddScript_Button_Shared = {
            Handle = "he0716b9bga6f2g4e49g8891g21780216c118",
            Text = "Add shared script",
            ContextDescription = [[Button in "Add script" message box]],
        },
        MsgBox_AddScript_Button_Client = {
            Handle = "h02aa046bgd8f6g4627g9637gd4d69407abad",
            Text = "Add client script",
            ContextDescription = [[Button in "Add script" message box; "client" refers to a game client/application (computer networking terminology)]],
        },
        MsgBox_AddScript_Button_Server = {
            Handle = "h4c185a0bg8cdcg4b2ega962g78420c14debc",
            Text = "Add server script",
            ContextDescription = [[Button in "Add script" message box; "server" refers to a multiplayer game server (computer networking terminology)]],
        },
        MsgBox_InvalidPath_Body = {
            Handle = "h192d069eg0a8eg4a88g92cdg31d84fc06104",
            Text = "There is no script at %s. Ensure you have placed the script in the correct folder.",
            ContextDescription = [[Message box when adding a script with a wrong path. Param is the path the user previously entered.]],
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        ScriptRegistered = {Context = "Client"}, ---@type Event<{Config:Features.PersonalScripts.Script}> Only thrown for scripts registered at runtime; not thrown for scripts registered from loading the saved config.
    },
}
Epip.RegisterFeature("PersonalScripts", PersonalScripts)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.PersonalScripts.ScriptList
---@field Scripts Features.PersonalScripts.Script[]
---@field Protocol integer?

---@class Features.PersonalScripts.Script
---@field Context ScriptContext
---@field Path path Relative to the root directory.
---@field PathRoot InputOutputLib_UserFileContext
---@field ModTable string Mod table to use as the environment.
---@field Enabled boolean

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns all detected personal scripts.
---@return Features.PersonalScripts.Script[] -- In load order.
function PersonalScripts.GetAllScripts()
    return PersonalScripts._ScriptConfigs
end

---Returns the configuration for a script.
---@param path path
---@return Features.PersonalScripts.Script
function PersonalScripts.GetScript(path)
    local script = nil
    for _,scriptEntry in ipairs(PersonalScripts.GetAllScripts()) do
        if scriptEntry.Path == path then
            script = scriptEntry
        end
    end
    return script
end

---Registers a config for a new script.
---Will throw `ScriptRegistered`.
---@param config Features.PersonalScripts.Script
function PersonalScripts.RegisterScript(config)
    table.insert(PersonalScripts._ScriptConfigs, config)
    PersonalScripts.SaveConfig()
    PersonalScripts.Events.ScriptRegistered:Throw({
        Config = config,
    })
end

---Saves the configuration and load order of all scripts.
---@param configPath path? Defaults to `DEFINITION_PATH`.
function PersonalScripts.SaveConfig(configPath)
    configPath = configPath or PersonalScripts.DEFINITION_PATH
    ---@type Features.PersonalScripts.ScriptList
    local config = {
        Scripts = {},
        Protocol = PersonalScripts.SAVE_PROTOCOL,
    }
    for i,script in ipairs(PersonalScripts.GetAllScripts()) do
        config.Scripts[i] = script
    end
    IO.SaveFile(configPath, config)
end

---Returns whether a script can be loaded.
---@param script Features.PersonalScripts.Script
---@return boolean
function PersonalScripts.CanLoad(script)
    local canLoad = script.Context == "Shared"
    if not canLoad then
        canLoad = (Ext.IsClient() and script.Context == "Client") or (Ext.IsServer() and script.Context == "Server")
    end
    canLoad = canLoad and script.Enabled
    return canLoad
end

---Registers script entries from all available sources.
---@param configPath path? Defaults to `DEFINITION_PATH`. File must follow the `Features.PersonalScripts.ScriptList` structure.
---@return Features.PersonalScripts.Script[] -- In load order.
function PersonalScripts._LoadConfigs(configPath)
    configPath = configPath or PersonalScripts.DEFINITION_PATH
    local entries = {} ---@type Features.PersonalScripts.Script[]

    -- Load scripts from config .json.
    local configList = IO.LoadFile(configPath) ---@type Features.PersonalScripts.ScriptList
    for _,scriptDef in ipairs(configList and configList.Scripts or {}) do
        table.insert(entries, scriptDef)
        scriptDef.Enabled = scriptDef.Enabled == nil and true or scriptDef.Enabled -- Older jsons did not have this field.
    end

    PersonalScripts._ScriptConfigs = entries

    return entries
end

---Loads scripts from a definition file.
function PersonalScripts._LoadScripts()
    for _,script in ipairs(PersonalScripts.GetAllScripts()) do
        if PersonalScripts.CanLoad(script) then
            local path = script.PathRoot == "user" and PersonalScripts.FOLDER_PATH .. "/" .. script.Path or script.Path -- Scripts from the Osiris Data folder must be in the designated PersonalScripts folder.
            local code = IO.LoadFile(path, script.PathRoot, true)
            if code then
                local env = script.ModTable and Mods[script.ModTable] or nil
                local chunk = load(code, path, "t", env)
                local success, err = pcall(chunk)
                if not success then
                    PersonalScripts:__LogError("Failed to load script", path, ":\n", err)
                else
                    PersonalScripts:__Log(Ext.IsServer() and "Server" or "Client", "Loaded script", path) -- Intentionally not a debug log, so the user can easily tell the scripts have loaded.
                end
            else
                PersonalScripts:__LogError("Script doesn't exist", path)
            end
        end
    end
end

---Returns the folder path relative to the game save directory.
---This will include the `/Osiris Data/` prefix; it's not usable for IO.
---@return string
function PersonalScripts._GetPrefixedFolderPath()
    return "/Osiris Data/" .. PersonalScripts.FOLDER_PATH
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Load personal scripts.
PersonalScripts._LoadConfigs()
PersonalScripts._LoadScripts()
