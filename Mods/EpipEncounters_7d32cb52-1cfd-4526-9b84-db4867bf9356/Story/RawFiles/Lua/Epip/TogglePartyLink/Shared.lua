
local HotbarActions = Epip.GetFeature("Feature_HotbarActions")

---@class Features.PartyLinking : Feature
local PartyLinking = {
    HOTBAR_ACTION_ID = "EPIP_TogglePartyLink",
    TranslatedStrings = {
        HotbarAction_TogglePartyLink = {
           Handle = "hd15285dag87d6g450cg8f17gd663d87a474e",
           Text = "Chain/Unchain",
           ContextDescription = "Hotbar action name",
        },
    },
}
Epip.RegisterFeature("Features.PartyLinking", PartyLinking)

-- Register Hotbar action
HotbarActions.RegisterAction({
    ID = PartyLinking.HOTBAR_ACTION_ID,
    Name = PartyLinking.TranslatedStrings.HotbarAction_TogglePartyLink:GetString(),
    Icon = "hotbar_icon_infinity",
    DefaultIndex = 10,
    Cooldown = 1,
})
