
---@type Feature
local EmoteCommands = {
    EMOTES = {
        angry = "emotion_angry",
        talk = "emotion_normal",
        sad = "emotion_sad",
        thankful = "emotion_thankful",
        drink = "use_drink",
        craft = "use_craft",
        dig = "use_dig",
        cower = "cower",
        inspect = "use_inspect",
        activate = "use_activate",
        loot = "use_loot",
        eat = "use_eat",
        move = "use_move",
        hit = "hit",
        dodge = "dodge",
        fall = "knockdown_fall",
        barf = "barf", -- lol ?
        sneak = "sneak",
        drunk = "stilldrunk",
        crippled = "stillcrippled",
        chilled = "stillchilled",
        diseased = "stilldiseased",
        blind = "stillblind",
        electrified = "stillelectrified",
        mental = "stillmental"
    },
}
Epip.RegisterFeature("EmoteCommands", EmoteCommands)

local Commands = Epip.GetFeature("Feature_ChatCommands")

-- TODO use hook
---@return string
function EmoteCommands.GetHelpText()
    local msg = ""

    for emote,animation in pairs(EmoteCommands.EMOTES) do
        msg = msg .. Text.Format("%s : %s", {
            FormatArgs = {emote, animation},
        }) .. "<br>"
    end

    return msg
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local EmoteHandler = nil
if Ext.IsClient() then
    EmoteHandler = function (args, _)
        local emote = args[1]
        local animation = EmoteCommands.EMOTES[emote]

        if not animation then
            Client.UI.ChatLog.AddMessage(nil, "Invalid emote. Use /help emote for a list of emotes.")
        end
    end
else
    EmoteHandler = function (args, char)
        local emote = args[1]
        local animation = EmoteCommands.EMOTES[emote]

        if animation then
            Osiris.PlayAnimation(char, animation)
        end
    end
end

Commands.RegisterCommand({Name = "emote", Description = "Perform an emote. Use /help emote for a list of emotes.", Help = EmoteCommands.GetHelpText()}, EmoteHandler)