
---@class Features.TradeContainers : Feature
local TradeContainers = {
    NETMSG_OPEN_CONTAINER = "Features.TradeContainers.NetMsg.OpenContainer",
    NETMSG_SEND_TO_CHARACTER = "Features.TradeContainers.NetMsg.SendToCharacter",
    NETMSG_SEND_TO_CHARACTER_COMPLETED = "Features.TradeContainers.NetMsg.SendToCharacterCompleted",

    TranslatedStrings = {
        Tooltip_Hint = {
            Handle = "hd2aaa37dg2eccg4480g90d5gab593d074c2f",
            Text = "Right-click to open.",
            ContextDescription = [[Tooltip hint for containers]],
        },
    },
}
Epip.RegisterFeature("Features.TradeContainers", TradeContainers)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.TradeContainers.NetMsg.OpenContainer : NetLib_Message_Character, NetLib_Message_Item
---@class Features.TradeContainers.NetMsg.SendToCharacter : NetLib_Message_Character, NetLib_Message_Item
---@class Features.TradeContainers.NetMsg.SendToCharacterCompleted : NetLib_Message_Item
