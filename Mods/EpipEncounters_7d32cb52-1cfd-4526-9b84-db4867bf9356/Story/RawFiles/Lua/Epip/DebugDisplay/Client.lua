
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class Feature_DebugDisplay
local DebugDisplay = Epip.GetFeature("EpipEncounters", "DebugDisplay")
DebugDisplay.TrackedModVersions = {
    {GUID = Mod.GUIDS.EPIP_ENCOUNTERS, Name = "Epip"},
    {GUID = Mod.GUIDS.EE_CORE, Name = "Core"},
    {GUID = Mod.GUIDS.EE_ORIGINS, Name = "Origins"},
    {GUID = Mod.GUIDS.EE_DERPY, Name = "Derpy's"},
}
DebugDisplay.BG_SIZE = Vector.Create(200, 200)
DebugDisplay.PING_INTERVAL = 0.8
DebugDisplay.pingTime = Ext.Utils.MonotonicTime()

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EPIPENCOUNTERS_DebugDisplay_Ping
---@field ClientTime integer
---@field NetID NetId

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
---@return boolean
function DebugDisplay:IsEnabled()
    return Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "Developer_DebugDisplay") and Epip.IsDeveloperMode() and _Feature.IsEnabled(self)
end

---@param active boolean
function DebugDisplay.Toggle(active)
    if active and DebugDisplay:IsEnabled() then
        DebugDisplay.UI:Show()
    else
        DebugDisplay.UI:Hide()
    end
end

function DebugDisplay.UpdateModVersions()
    local element = DebugDisplay.ModVersionText

    local text = ""
    for i,data in ipairs(DebugDisplay.TrackedModVersions) do
        local mod = Ext.Mod.GetMod(data.GUID)

        if mod then
            local modVer = DebugDisplay.GetModVersionDisplay(mod)

            text = text .. Text.Format("%s: %s", {FormatArgs = {data.Name, modVer}})

            if i ~= #DebugDisplay.TrackedModVersions then
                text = text .. "\n"
            end
        end
    end

    element:SetText(text)
end

---@param mod Module
---@return string
function DebugDisplay.GetModVersionDisplay(mod)
    local major, minor, revision, build = Mod.GetStoryVersion(mod.Info.ModuleUUID)
    local display = ""

    if major > 9 or minor > 9 or revision > 9 or build > 9 then
        display = Text.Format("v%s.%s.%s.%s", {FormatArgs = {major, minor, revision, build}})
    else
        display = Text.Format("v%s%s%s%s", {FormatArgs = {major, minor, revision, build}})
    end

    return display
end

---@param ticks integer
function DebugDisplay.SetServerTicks(ticks)
    local element = DebugDisplay.ServerTickCounter
    local switches = Ext.Utils.GetGlobalSwitches()
    local frameCap = switches.ServerFrameCap

    element:SetText(Text.Format("Server TPS: %s/%s", {FormatArgs = {ticks, frameCap}, Color = Color.WHITE}))
end

---@param ticks integer
function DebugDisplay.SetClientTicks(ticks)
    local element = DebugDisplay.ClientTickCounter
    local gfxSettings = Ext.Utils.GetGraphicSettings()
    local frameCapEnabled = gfxSettings.FrameCapEnabled
    local suffix = ""
    if frameCapEnabled then
        suffix = "/" .. tostring(gfxSettings.FrameCapFPS)
    end
    if gfxSettings.VSync then
        suffix = " (VSync)"
    end

    element:SetText(Text.Format("Client FPS: %s%s", {FormatArgs = {ticks, suffix}, Color = Color.WHITE}))
end

function DebugDisplay.SendPingRequest()
    if GameState.IsInSession() then
        DebugDisplay.pingTime = Ext.Utils.MonotonicTime()
    
        Net.PostToServer("EPIPENCOUNTERS_DebugDisplay_Ping", {ClientTime = Ext.Utils.MonotonicTime(), NetID = Client.GetCharacter().NetID})
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for pings being sent back.
Net.RegisterListener("EPIPENCOUNTERS_DebugDisplay_Ping", function (payload)
    local now = Ext.Utils.MonotonicTime()
    local timeElapsed = now - payload.ClientTime

    DebugDisplay.PingLabel:SetText(Text.Format("Ping: %sms", {FormatArgs = {timeElapsed}, Color = Color.WHITE}))
end)

Ext.Events.Tick:Subscribe(function (ev)
    DebugDisplay.AddTick()
end)

Net.RegisterListener("EPIPENCOUNTERS_DebugDisplay_ServerTicks", function (payload)
    local ticks = payload.Ticks

    DebugDisplay.SetServerTicks(ticks)
end)

Client.UI.OptionsSettings:RegisterListener("OptionSet", function(data, value)
    if data.ID == "Developer_DebugDisplay" then
        DebugDisplay.Toggle(value)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function DebugDisplay:__Setup()
    local textSize = Vector.Create(DebugDisplay.BG_SIZE[1], 25)
    local ui = Generic.Create("PIP_DebugDisplay")
    local bg = ui:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Black", DebugDisplay.BG_SIZE:unpack())
    bg:SetAlpha(0.4)

    local dragArea = bg:AddChild("DragArea", "GenericUI_Element_TiledBackground") -- This is a bit ridiculous - even if children are not mouse enabled, they still extend the mouse range of the background, so we need to use a "hit_mc" instead of making BG the dragging area.
    dragArea:SetBackground("Black", DebugDisplay.BG_SIZE:unpack())
    dragArea:SetAlpha(0)
    dragArea:SetAsDraggableArea()

    local container = bg:AddChild("Container", "GenericUI_Element_VerticalList")
    container:SetMouseEnabled(false) -- So the container does not block dragging (though its children already do not...)

    local tickCounter = TextPrefab.Create(ui, "TickCounter", container, "", "Left", textSize)

    Ext.Events.Tick:Subscribe(function (ev)
        DebugDisplay.SetClientTicks(#DebugDisplay.ticks)
    end)

    local serverTickCounter = TextPrefab.Create(ui, "ServerTickCounter", container, "", "Left", textSize)
    local pingCounter = TextPrefab.Create(ui, "PingLabel", container, "", "Left", textSize)
    local extVersionText = TextPrefab.Create(ui, "ExtVersionLabel", container, Text.Format("Ext: v%s", {FormatArgs = {Ext.Utils.Version()}}), "Left", textSize)

    local modVersionText = TextPrefab.Create(ui, "ModVersionLabel", container, "", "Left", Vector.Create(DebugDisplay.BG_SIZE[1], 200))

    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {200, 300}
    uiObject.Left = 200

    GameState.Events.GameReady:Subscribe(function (ev)
        ui:SetPosition("topright", "topright", nil, 0.1)
    end, {Once = true})

    DebugDisplay.UI = ui
    DebugDisplay.ClientTickCounter = tickCounter
    DebugDisplay.ServerTickCounter = serverTickCounter
    DebugDisplay.ModVersionText = modVersionText
    DebugDisplay.ExtVersionText = extVersionText
    DebugDisplay.PingLabel = pingCounter

    DebugDisplay.UpdateModVersions()

    DebugDisplay.Toggle(Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "Developer_DebugDisplay"))

    Timer.Start(DebugDisplay.PING_INTERVAL, function (ev)
        if DebugDisplay:IsEnabled() then
            DebugDisplay.SendPingRequest()
        end
    end):SetRepeatCount(-1)
end