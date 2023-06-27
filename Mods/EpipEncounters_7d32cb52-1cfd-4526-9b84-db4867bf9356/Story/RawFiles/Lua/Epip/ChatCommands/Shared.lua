
---@class Feature_ChatCommands : Feature
local Commands = {
    COMMANDS = {},
    Events = {
        ---@type EpipChat_Event_CommandSent
        CommandSent = {},
    },
}
Epip.RegisterFeature("ChatCommands", Commands)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class ChatCommand
---@field Name string
---@field Description string
---@field Help? string Help text for /help {command}. Defaults to description.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when the client sends a command.
---@class EpipChat_Event_CommandSent : Event
---@field RegisterListener fun(self, listener:fun(command:string, args:string[], char:Character))
---@field Fire fun(self, command:string, args:string[], char:Character)

---------------------------------------------
-- METHODS
---------------------------------------------

---Register a command, optionally with an initial handler.
---@param command ChatCommand
---@param handler? fun(args:string[], char:Character)
function Commands.RegisterCommand(command, handler)
    Commands.COMMANDS[command.Name] = command

    if handler then
        Commands.RegisterCommandListener(command.Name, handler)
    end
end

---@param command string
---@param handler fun(args:string[], char:Character)
function Commands.RegisterCommandListener(command, handler)
    Commands:RegisterListener("CommandSent_" .. command, handler)
end

---Execute a command.
function Commands.Execute(char, command, args)
    Commands.Events.CommandSent:Fire(command, args, char)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward command events to specific listeners.
Commands.Events.CommandSent:RegisterListener(function (command, args, char)
    Commands:FireEvent("CommandSent_" .. command, args, char)
end)