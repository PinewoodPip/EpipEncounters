
---@class Features.DiscordRichPresence : Feature
local DRP = {
    TSKHANDLES = {
        LONE_ADVENTURER = "hdb0e989eg9f4ag4e6ag82f3g17ff0daccfe8",
        IN_PARTY = "hf94ae99dgfd1cg468ega464ge96f45467b32",
        IN_MAIN_MENU = "h68d245e2g47bag4db5g8ecag7ddfabed5120",
        IN_LOBBY = "h90cfc933g2c6bg4992g9b78g50e786e512e0",
        IN_ARENA = "h47d162d0gf917g458bgb102g8e5cfc5eb92c",
        IN_GAME_MASTER = "hb9eee13bg7e18g4385g9149gead90c9263f3",
    },
    MODES = {
        VANILLA = "Vanilla",
        OVERHAUL = "Overhaul",
        CUSTOM = "Custom",
    },

    _OriginalLabels = {}, ---@type table<TranslatedStringHandle, string> TODO
    _OriginalLevelNames = {}, ---@type table<string, string> Maps string key to text.

    TranslatedStrings = {
        Label_RichPresence = {
            Handle = "hd1eed9f3g8a0bg4098g9369g0ba5549b947f",
            Text = "Discord Rich Presence",
            ContextDescription = "'Discord' refers to the app",
        },
        Label_PartyLevel = {
            Handle = "h20643acfg8b9fg46ccg8039g253dd6e02788",
            Text = "%s - Lvl %d",
            ContextDescription = "Rich Presence message. Params are region name and  character level.",
        },
        Setting_Mode_Name = {
            Handle = "hdb9a40e2g4713g40e0g8885gd6e1b75512c3",
            Text = "Discord Rich Presence",
            ContextDescription = "Setting name",
        },
        Setting_Mode_Description = {
            Handle = "h08dbc3efgf409g4a96g9d3bge907e2638a9a",
            Text = "Controls your Discord Rich Presence.<br><br>- Vanilla: unmodified; shows current map name and multiplayer status.<br>- Overhaul: displays the major overhaul being used (ex. \"Epic Encounters 2\") and party level.<br>- Custom: allows you to freely set both lines using the text boxes below.",
            ContextDescription = "Setting tooltip",
        },
        Setting_CustomLine1_Name = {
            Handle = "hed5f3515g0bcdg4e22ga774gb2221e6b308f",
            Text = "Custom Line 1",
            ContextDescription = "Setting name",
        },
        Setting_CustomLine2_Name = {
            Handle = "h37705f99g9f5cg4f74g9751g3302acb7c87b",
            Text = "Custom Line 2",
            ContextDescription = "Setting name",
        },
        Setting_CustomLine_Description = {
            Handle = "h3a4e8fc6ga604g45f6gbff7g549e349fbe7d",
            Text = "Rich Presence message to be used if the Rich Presence setting is set to \"Custom\".",
            ContextDescription = "Setting tooltip",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetPresence = {}, ---@type Hook<Features.DiscordRichPresence.Hooks.GetPresence> Client-only.
    },
}
Epip.RegisterFeature("Features.DiscordRichPresence", DRP)
