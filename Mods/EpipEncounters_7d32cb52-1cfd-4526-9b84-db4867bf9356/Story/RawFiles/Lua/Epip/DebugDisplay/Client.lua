
local Generic = Client.UI.Generic

---@class Feature_DebugDisplay
local DebugDisplay = Epip.GetFeature("EpipEncounters", "DebugDisplay")

---------------------------------------------
-- METHODS
---------------------------------------------

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
    tickCounter:SetSize(500, 30)

    Ext.Events.Tick:Subscribe(function (ev)
        DebugDisplay.SetClientTicks(#DebugDisplay.ticks)
    end)

    
    local serverTickCounter = container:AddChild("ServerTickCounter", "GenericUI_Element_Text")
    serverTickCounter:SetType(0)
    serverTickCounter:SetSize(500, 30)

    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {200, 300}
    uiObject.Left = 200

    ui:SetPosition("topright", "topright", nil, 0.1)

    DebugDisplay.UI = ui
    DebugDisplay.ClientTickCounter = tickCounter
    DebugDisplay.ServerTickCounter = serverTickCounter
end