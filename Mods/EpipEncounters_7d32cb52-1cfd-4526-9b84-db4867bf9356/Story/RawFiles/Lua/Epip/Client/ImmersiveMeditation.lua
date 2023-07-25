
---------------------------------------------
-- Toggles the minimap and hotbar UIs
-- while the client is Meditating.
---------------------------------------------

local MinimapToggle = Epip.GetFeature("Feature_MinimapToggle")
local Ascension = Game.Ascension

---@type Feature
local IM = {
    currentState = false,

    TranslatedStrings = {
        ImmersiveMeditation_Name = {
            Handle = "ha970de96geaf5g483eg9996gac184c8fe843",
            Text = "Immersive Meditation",
            ContextDescription = "Immersive meditation setting name",
        },
        ImmersiveMeditation_Description = {
            Handle = "h8f6b67aaga9fag4c62gbd92g0f4d43fd8855",
            Text = "Hides the Hotbar and Minimap while within the Ascension and Greatforge UIs.",
            ContextDescription = "Immersive meditation setting tooltip",
        },
    },
}
Epip.RegisterFeature("ImmersiveMeditation", IM)

---------------------------------------------
-- SETTINGS
---------------------------------------------

IM:RegisterSetting("Enabled", 
{
    Type = "Boolean",
    NameHandle = IM.TranslatedStrings.ImmersiveMeditation_Name,
    DescriptionHandle = IM.TranslatedStrings.ImmersiveMeditation_Description,
    RequiredMods = {Mod.GUIDS.EE_CORE},
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function IM:IsEnabled()
    return IM:GetSettingValue(IM.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

function IM.Update()
    if Client.IsUsingController() then return nil end
    local state = IM:ReturnFromHooks("GetState", false)

    if state == IM.currentState then return nil end

    IM.currentState = state

    if state then
        Client.UI.Hotbar.ToggleVisibility(false, "PIP_ImmersiveMeditation")
        Client.UI.StatusConsole.Toggle(false, "PIP_ImmersiveMeditation")
        
        MinimapToggle.RequestState("ImmersiveMeditation", false)
    else
        Client.UI.Hotbar.ToggleVisibility(true, "PIP_ImmersiveMeditation")
        Client.UI.StatusConsole.Toggle(true, "PIP_ImmersiveMeditation")

        MinimapToggle.RequestState("ImmersiveMeditation", true)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Enable when we're in Ascension. Never enable immersive meditation if the option is off.
IM:RegisterHook("GetState", function(enabled)
    if not enabled and Game.AMERUI.ClientIsInUI() and IM:IsEnabled() then
        enabled = true
    end

    return enabled
end)

-- Update state when client toggles meditation, the hotbar refreshes or the game is unpaused. The hotbar listener is needed for unpause
Ascension:RegisterListener("ClientToggledMeditating", function(_)
    IM.Update()
end)

Client.UI.Hotbar:RegisterListener("Refreshed", function()
    IM.Update()
end)

-- No timer necessary!
Utilities.Hooks.RegisterListener("GameState", "GameUnpaused", function()
    IM.Update()
end)