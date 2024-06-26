
---------------------------------------------
-- Toggles the minimap and hotbar UIs
-- while the client is Meditating.
---------------------------------------------

local MinimapToggle = Epip.GetFeature("Feature_MinimapToggle")
local BottomBarC = Client.UI.Controller.BottomBar
local StatusConsole = Client.UI.StatusConsole
local Hotbar = Client.UI.Hotbar
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
    Settings = {},
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

---Updates the visibility of the affected UIs.
function IM.Update()
    local enabled = IM:ReturnFromHooks("GetState", false)
    local uisVisible = not enabled

    -- Bottom bar can still be shown if attempting to use it.
    -- This update thus needs to run regardless of whether the Immersive Meditation state changed. 
    if Client.IsUsingController() then
        BottomBarC:GetRoot().visible = uisVisible or BottomBarC.IsActive()
    end

    if enabled == IM.currentState then return nil end

    IM.currentState = enabled

    -- Update UI visibility
    MinimapToggle.RequestState("ImmersiveMeditation", uisVisible)
    if not Client.IsUsingController() then
        Hotbar.ToggleVisibility(uisVisible, "PIP_ImmersiveMeditation")
        StatusConsole.Toggle(uisVisible, "PIP_ImmersiveMeditation")
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

-- Update state when client toggles meditation, the hotbar refreshes or the game is unpaused. The hotbar listener is needed for unpause.
Ascension:RegisterListener("ClientToggledMeditating", IM.Update)
Hotbar:RegisterListener("Refreshed", IM.Update)
BottomBarC:RegisterInvokeListener("updateSlots", IM.Update)
BottomBarC.Events.ActiveStateToggled:Subscribe(function (_)
    Timer.Start(0.1, function (_)
        IM.Update()
    end)
end)
Utilities.Hooks.RegisterListener("GameState", "GameUnpaused", IM.Update)
