
---------------------------------------------
-- Displays a warning when using common problematic mods.
---------------------------------------------

local MessageBox = Client.UI.MessageBox
local Mods = Mod.GUIDS

---@type Feature
local Warnings = {
    _messageQueue = {},

    MSG_BOX_ID = "Epip_IncompatibleModWarning",

    INCOMPATIBLE_MODS = {
        [Mods.EE_CORE] = {
            -- I don't have the mental energy to get the GUIDs of all the Odin mods atm. This is the only one I had on hand
            Mods.ODIN_SUMMONING_SCALING,
            Mods.CONFLUX,
            Mods.CRAFTING_OVERHAUL,
            Mods.BETTER_CLOUDS,
            Mods.IMPROVED_GWYDIAN_RINCE,
            Mods.CITIZENS_OF_DIVINITY,
            Mods.POLYMORPH_RECRUITING_FIX,
            Mods.INITIATIVE_TURN_ORDER,
            Mods.WILDFIRE,
            Mods.RELICS_OF_RIVELLON_FIX,
            Mods.UNLEASHED,
            Mods.GREED,
            Mods.LET_THERE_BE_TOOLTIPS,
            Mods.ANIMATIONS_PLUS,
            Mods.MAJORA_FASHION_SINS,
        },
        [Mods.EPIP_ENCOUNTERS] = {
            Mods.IMPROVED_HOTBAR,
            -- Mods.LEADERLIB, -- Appears to work as of late v1066
            Mods.MULTIHOTBARS,
            Mods.CUSTOM_DAMAGE_TYPES,
        },
    },
    TranslatedStrings = {
        MessageBoxBody = {
           Handle = "h9f6cbb29ge1f5g4b74g9e19ge7a83138bbf5",
           Text = "Mod '%s' is incompatible with '%s' and it is not recommended to use them together.",
           ContextDescription = "Message box body",
        },
    }
}
Epip.RegisterFeature("IncompatibleModsWarning", Warnings)

---------------------------------------------
-- METHODS
---------------------------------------------

---Shows the next queued incompatibility message.
function Warnings._ShowNextWarningInQueue()
    local msg = Warnings._messageQueue[1]

    if msg then
        table.remove(Warnings._messageQueue, 1)

        MessageBox.Open({
            ID = Warnings.MSG_BOX_ID,
            Header = Text.CommonStrings.Warning:GetString(),
            Message = msg,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create a queue of incompatibility warnings upon loading in.
GameState.Events.GameReady:Subscribe(function (_)
    for baseModGuid,list in pairs(Warnings.INCOMPATIBLE_MODS) do
        if Mod.IsLoaded(baseModGuid) then
            for _,incompatibleModGUID in pairs(list) do
                if Mod.IsLoaded(incompatibleModGUID) then
                    local mod = Ext.Mod.GetModInfo(incompatibleModGUID)
                    local baseMod = Ext.Mod.GetModInfo(baseModGuid)
                    local message = string.format(Warnings.TranslatedStrings.MessageBoxBody:GetString(), mod.Name, baseMod.Name)

                    table.insert(Warnings._messageQueue, message)
                end
            end
        end
    end

    -- Do not display warnings in developer mode.
    if not Epip.IsDeveloperMode() then
        Warnings._ShowNextWarningInQueue()
    end
end)

-- Show the next waning queued upon one being dismissed.
MessageBox.RegisterMessageListener(Warnings.MSG_BOX_ID, MessageBox.Events.ButtonPressed, function ()
    Timer.StartTickTimer(3, function (_)
        Warnings._ShowNextWarningInQueue()
    end)
end)