
local Commands = Epip.GetFeature("Feature_ChatCommands")

---------------------------------------------
-- METHODS
---------------------------------------------



---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_EpipChat_CommandSent", function(payload)
    local char = Ext.GetCharacter(payload.CharacterNetID)
    local command = payload.Command
    local args = payload.Args

    Commands.Execute(char, command, args)
end)

---------------------------------------------
-- EPIP COMMANDS
---------------------------------------------

Commands.RegisterCommand({Name = "rp", Description = "Say a message over your character's head.",}, function (args, char)
    local msg = args[1]

    for i=2,#args,1 do
        msg = msg .. " " .. args[i]
    end

    if msg then
        Osiris.DisplayText(char, msg)
    end
end)