
local Chat = Epip.Features.ChatCommands
Chat.UI = Client.UI.ChatLog

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for slash commands.
Chat.UI.Hooks.CanSendMessage:RegisterHook(function (canSend, text, char)
    local command = string.match(text, "^/(.*)$")

    if command then
        local args = Text.Split(command, " ")
        command = args[1]

        table.remove(args, 1)

        local commandData = Chat.COMMANDS[command]

        if commandData then
            Chat.Events.CommandSent:Fire(command, args, Client.GetCharacter())
        else
            Chat.UI.AddMessage(nil, "Invalid command! Use /help for a list of commands.")
        end
        

        canSend = false
    end

    return canSend
end)

-- Forward commands to server.
Chat.Events.CommandSent:RegisterListener(function (command, args, char)
    Net.PostToServer("EPIPENCOUNTERS_EpipChat_CommandSent", {
        CharacterNetID = char.NetID,
        Command = command,
        Args = args,
    })
end)

Chat.UI.Events.MessageSent:RegisterListener(function (text, clientChar)
    local root = Client.UI.ChatLog:GetRoot()

    -- TODO finish
    -- root.log_mc.input_txt.selectable = true
    -- -- root.log_mc.setInputFocus(false)
    -- root.log_mc.onFocusLost()
    -- root.stage.focus = 0
    -- print(root.stage.focus)
end)

---------------------------------------------
-- EPIP COMMANDS
---------------------------------------------

-- Commands handler on server.
Chat.RegisterCommand({Name = "rp", Description = "Say a message over your character's head.",})

-- Lmao this doesnt seem to work
-- Chat.RegisterCommand({Name = "clear", Description = "Clear the chat log for the current tab.",}, function (args, char)
--     Chat.UI.ClearTab(nil)
-- end)

local function ListCommandHelp(command, useHelp)
    local desc = command.Description

    if useHelp then
        desc = command.Help or desc
    end

    local commandHelpText = Text.Format("/%s : %s", {
        FormatArgs = {command.Name, desc}
    })

    Chat.UI.AddMessage(nil, commandHelpText)
end

-- Built-in help command.
Chat.RegisterCommand({Name = "help", Description = "Show a list of commands.",}, function (args, char)

    -- List all commands
    if #args == 0 then
        Chat.UI.AddMessage(nil, "---------------------")
        Chat.UI.AddMessage(nil, "Chat Commands:")

        for id,command in pairs(Chat.COMMANDS) do
            if id ~= "help" then
                ListCommandHelp(command)
            end
        end
    else -- Get help with a specific command
        local command = Chat.COMMANDS[args[1]]

        if command then
            Chat.UI.AddMessage(nil, "Help for /" .. command.Name .. ":")
            ListCommandHelp(command, true)
        else
            Chat.UI.AddMessage(nil, "Invalid command. Use /help for a list of commands.")
        end
    end
end)