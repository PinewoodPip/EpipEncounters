
local Generic = Client.UI.Generic

---@class Feature_DebugDisplay
local DebugDisplay = Epip.GetFeature("EpipEncounters", "DebugDisplay")
DebugDisplay.TrackedModVersions = {
    {GUID = Mod.GUIDS.EPIP_ENCOUNTERS, Name = "Epip"},
    {GUID = Mod.GUIDS.EE_CORE, Name = "Core"},
    {GUID = Mod.GUIDS.EE_ORIGINS, Name = "Origins"},
    {GUID = Mod.GUIDS.EE_DERPY, Name = "Derpy's"},
}

---------------------------------------------
-- METHODS
---------------------------------------------

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

    element:SetText(Text.Format("Server TPS: %s/%s", {FormatArgs = {ticks, frameCap}, Color = Color.COLORS.WHITE}))
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

    element:SetText(Text.Format("Client FPS: %s%s", {FormatArgs = {ticks, suffix}, Color = Color.COLORS.WHITE}))
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Ext.Events.Tick:Subscribe(function (ev)
    DebugDisplay.AddTick()
end)

Net.RegisterListener("EPIPENCOUNTERS_DebugDisplay_ServerTicks", function (_, payload)
    local ticks = payload.Ticks

    DebugDisplay.SetServerTicks(ticks)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function DebugDisplay:__Setup()
    local ui = Generic.Create("PIP_DebugDisplay")
    local bg = ui:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground(1, 200, 200)
    bg:SetAlpha(0.4)
    bg:SetAsDraggableArea()

    local container = bg:AddChild("Container", "GenericUI_Element_VerticalList")
    local tickCounter = container:AddChild("TickCounter", "GenericUI_Element_Text")
    tickCounter:SetType(0)
    tickCounter:SetSize(500, 25)

    Ext.Events.Tick:Subscribe(function (ev)
        DebugDisplay.SetClientTicks(#DebugDisplay.ticks)
    end)

    
    local serverTickCounter = container:AddChild("ServerTickCounter", "GenericUI_Element_Text")
    serverTickCounter:SetType(0)
    serverTickCounter:SetSize(500, 25)

    local modVersionText = container:AddChild("ModVersionLabel", "GenericUI_Element_Text")
    modVersionText:SetType(0)
    modVersionText:SetSize(500, 100)

    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {200, 300}
    uiObject.Left = 200

    ui:SetPosition("topright", "topright", nil, 0.1)

    DebugDisplay.UI = ui
    DebugDisplay.ClientTickCounter = tickCounter
    DebugDisplay.ServerTickCounter = serverTickCounter
    DebugDisplay.ModVersionText = modVersionText

    DebugDisplay.UpdateModVersions()
end