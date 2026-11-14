
---------------------------------------------
-- Adds a setting to require the player to hold down the "End turn" keybind to end their turn.
---------------------------------------------

local Input = Client.Input
local Generic = Client.UI.Generic
local StatusConsole = Client.UI.StatusConsole
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local V = Vector.Create

---@type Feature
local HoldToEndTurn = {
    PROGRESS_BAR_FAKE_PROGRESS = 0.15, -- Fraction of the hold progress bar that will be shown as filled from the start. Used for better UX for when the player taps the button shortly, to better indicate it needs to be held.

    _TimeHeld = 0, -- In seconds.

    TranslatedStrings = {
        Setting_HoldDuration_Name = {
            Handle = "h70a24743g4647g4003g9addgc24bf8703a55",
            Text = [["End turn" hold duration]],
            ContextDescription = [[Setting name]],
        },
        Setting_HoldDuration_Description = {
            Handle = "hfea3ab31g5b1cg4508ga289g6433090aee2e",
            Text = [[Duration in seconds that the "End turn" keybind must be held for to end the turn. Set to 0 to disable.]],
            ContextDescription = [[Setting name for "End turn hold duration"]],
        },
    },

    Settings = {},
}
Epip.RegisterFeature("Features.HoldToEndTurn", HoldToEndTurn)
local TSK = HoldToEndTurn.TranslatedStrings

---@class Features.HoldToEndTurn.Overlay : GenericUI_Instance
local Overlay = Generic.Create("Features.HoldToEndTurn.Overlay")
Overlay.PROGRESS_BAR_WIDTH = 190

---------------------------------------------
-- SETTINGS
---------------------------------------------

local HoldDurationSetting = HoldToEndTurn:RegisterSetting("HoldDuration", {
    Type = "ClampedNumber",
    Name = TSK.Setting_HoldDuration_Name,
    Description = TSK.Setting_HoldDuration_Description,
    Min = 0,
    Max = 1,
    Step = 0.1,
    HideNumbers = false,
    DefaultValue = 0,
})

---------------------------------------------
-- OVERLAY
---------------------------------------------

---Repositions and shows the overlay.
function Overlay.Setup()
    -- Rescale and reposition UI
    -- Needs to be done each time as the user might've changed resized the window
    local uiObj = Overlay:GetUI()
    local statusConsoleUIObj = StatusConsole:GetUI()
    uiObj.MovieLayout = 3
    uiObj.SysPanelSize = {200, 200} -- Needed for SetPositionRelativeToViewport()
    uiObj.Layer = statusConsoleUIObj.Layer + 1
    uiObj:Resize(statusConsoleUIObj.FlashMovieSize[1], statusConsoleUIObj.FlashMovieSize[2], statusConsoleUIObj:GetUIScaleMultiplier())
    Overlay:SetPositionRelativeToViewport("bottom", "bottom", "screen")

    Overlay._Initialize()
end

---Updates the progress bar.
---@param timeHeld number In seconds.
function Overlay.Update(timeHeld)
    local progress = timeHeld / HoldDurationSetting:GetValue()
    local PROGRESS_BAR_FAKE_PROGRESS = HoldToEndTurn.PROGRESS_BAR_FAKE_PROGRESS
    local PROGRESS_BAR_WIDTH = Overlay.PROGRESS_BAR_WIDTH
    Overlay.ProgressBar:SetScrollRect(V(0, 0), V(progress * PROGRESS_BAR_WIDTH * (1 - PROGRESS_BAR_FAKE_PROGRESS) + PROGRESS_BAR_WIDTH * PROGRESS_BAR_FAKE_PROGRESS, 250))
    if StatusConsole:IsVisible() and timeHeld > 0 then
        Overlay:TryShow()
    else
        Overlay:TryHide()
    end
end

---Creates the UI's static elements.
function Overlay._Initialize()
    if Overlay._Initialized then return end

    local root = Overlay:CreateElement("Root", "GenericUI_Element_Empty")

    local progressBar = root:AddChild("ProgressBar", "GenericUI_Element_Texture")
    progressBar:SetTexture(Textures.FRAMES.COLORED_NOTIFICATION.DARK_RED, V(Overlay.PROGRESS_BAR_WIDTH, 36))
    progressBar:SetPosition(377, 82)
    Overlay.ProgressBar = progressBar

    Overlay._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
-------------------------------------------

-- Prevent ending turn through the vanilla keybind unless it is held down.
local _CachedBinding = nil ---@type InputLib_InputEventBinding?
local _CurrentListenerID = nil ---@type string?
local _TimeHeld = 0 -- In seconds.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if not _CachedBinding then
        _CachedBinding = Input.GetBinding(260, "Key") -- TODO refresh when keybinds are changed
    end
    if ev.InputID == _CachedBinding.InputID and Input.HasInputEventModifiersPressed(_CachedBinding) then
        if Client.IsActiveCombatant() then
            if ev.State == "Pressed" then
                _TimeHeld = 0

                Overlay.Setup()

                _CurrentListenerID = Text.GenerateGUID()
                GameState.Events.RunningTick:Subscribe(function (tickEv)
                    _TimeHeld = _TimeHeld + tickEv.DeltaTime / 1000
                    Overlay.Update(_TimeHeld)
                    if _TimeHeld >= HoldDurationSetting:GetValue() then
                        Client.UI.StatusConsole:ExternalInterfaceCall("EndButtonPressed")
                        Overlay:Hide()
                        GameState.Events.RunningTick:Unsubscribe(_CurrentListenerID)
                    end
                end, {StringID = _CurrentListenerID})
            elseif _CurrentListenerID then -- Clear listener on release
                Overlay:Hide()
                GameState.Events.RunningTick:Unsubscribe(_CurrentListenerID)
            end
            ev:Prevent()
        end
    end
end, {EnabledFunctor = function ()
    return HoldDurationSetting:GetValue() > 0
end})
