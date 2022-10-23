
local AF = {
    cinematicCombatOption = false, -- Cached value
    ID = "PIP_AprilFoolsOverlay",
    INPUT_DEVICE = "KeyboardMouse",
}
Epip.InitializeUI(nil, "AprilFoolsOverlay", AF)

function AF.PositionElements(width, height)
    local root = AF:GetRoot()
    local text = root.licenseActivation_txt
    local bg1 = root.cinematicOverlayTop_mc
    local bg2 = root.cinematicOverlayBottom_mc

    text.height = 100
    text.width = 360
    -- TODO fix
    -- text.htmlText = "Unlicensed Copy<br>Go to settings to activate your Epip Encounters license."
    text.htmlText = ""
    -- text.visible = Epip.IsAprilFools()
    text.visible = false
    text.x = 1500

    bg1.width = bg1.width * 2
    bg2.width = bg2.width * 2
end

function AF.ToggleCinematicMode(enabled)
    local root = AF:GetRoot()
    local bg1 = root.cinematicOverlayTop_mc
    local bg2 = root.cinematicOverlayBottom_mc

    bg1.visible = enabled
    bg2.visible = enabled

    if enabled then
        Client.UI.Minimap:Toggle(false, false)
    else
        Client.UI.Minimap:ToggleFromSettings()
    end

    Client.UI.PlayerInfo:GetRoot().visible = not enabled
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- April fools license registration button
Client.UI.OptionsSettings:RegisterListener("CustomTabRenderStarted", function(modID, data)
    if modID == "EpipEncounters" and Epip.IsAprilFools() then
        Client.UI.OptionsSettings.RenderOption({
            ID = "AprilFoolsLicenseRegistration",
            Type = "Button",
            Label = "Activate License",
            Tooltip = "Active your Epip Encounters license key.",
            SoundOnUp = "UI_Gen_Back",
        })
    end
end)

-- ...and it's "functionality"
Client.UI.OptionsSettings:RegisterListener("ButtonClicked", function(element)
    if element.ID == "AprilFoolsLicenseRegistration" then
        Client.UI.MessageBox.Open({
            ID = "AprilFoolsLicenseRegistration",
            Header = "",
            Message = "TPW_PIP_GEN_NET_Character_CharacterGetCharacterNetIDForCharacterPlayerCharacter() failed to return, please let Piperanth know about this (your game should be fine)",
            Buttons = {
                {Text = "Y'ACCEPT", ID = 0},
            },
        })
    end
end)

Client:RegisterListener("ViewportChanged", function(width, height)
    if AF:IsEnabled() and AF:GetUI() ~= nil then
        AF:GetUI():ExternalInterfaceCall("setMcSize", width * 2, height * 2)
        -- AF:GetUI():ExternalInterfaceCall("setPosition", "topRight", "screen", "bottomRight")
        AF.PositionElements(width, height)
    end
end)

-- On Tick
local function UpdateCinematicMode()
    local cinematicMode = Client.IsInCombat() and not Client.IsActiveCombatant() and AF.cinematicCombatOption
    AF.ToggleCinematicMode(cinematicMode)
end

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting.ModTable == "EpipEncounters" and ev.Setting.ID == "CinematicCombat" then
        AF.cinematicCombatOption = ev.Value
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function AF:__Setup()
-- Ext.Events.SessionLoaded:Subscribe(function()
    AF.cinematicCombatOption = Settings.GetSettingValue("EpipEncounters", "CinematicCombat")

    if not Epip.IsAprilFools() and not AF.cinematicCombatOption then AF:Disable() return nil end

    local ui = Ext.UI.Create(AF.ID, "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/aprilfools_overlay.swf", 100)

    ui.Layer = Ext.UI.GetByPath("Public/Game/GUI/gameMenu.swf").Layer - 1

    AF:TogglePlayerInput(false)

    local viewport = Ext.UI.GetViewportSize()
    ui:ExternalInterfaceCall("setMcSize", viewport[1] * 2, viewport[2] * 2)
    AF.PositionElements(viewport[1], viewport[2])
    AF.ToggleCinematicMode(false)

    Ext.Events.Tick:Subscribe(function()
        UpdateCinematicMode()
    end)
-- end)
end