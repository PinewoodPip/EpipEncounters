
local Generic = Client.UI.Generic
local SaveLoad = Client.UI.SaveLoad

---@type Feature
local SaveLoadOverlay = {
    UI = nil, ---@type GenericUI_Instance
}
Epip.AddFeature("SaveLoadOverlay", "SaveLoadOverlay", SaveLoadOverlay)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

SaveLoad.Events.GetContent:Subscribe(function (e)
    if SaveLoadOverlay:IsEnabled() then
        local ui = SaveLoadOverlay.UI

        ui:GetUI():Show()
        ui:GetUI().Layer = SaveLoad:GetUI().Layer + 1
        SaveLoad:SetFlag("OF_PlayerModal1", false)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local function SetupUI()
    local ui = SaveLoadOverlay.UI

    local panel = ui:CreateElement("Panel", "TiledBackground")
    panel:SetAlpha(0)

    local sorting = panel:AddChild("Sorting", "StateButton")
    local text = panel:AddChild("SortingLabel", "Text")
    text:SetText(Text.Format("Sorting", {Color = Color.COLORS.WHITE}))
    text:SetType(0)
    text:SetPosition(60, 7)
    text:SetMouseEnabled(false)
    text:SetSize(100, 60)

    panel:SetPosition(480, 960)

    ui:GetUI():Hide()
end

function SaveLoadOverlay:__Setup()
    if Client.IsUsingController() then
        SaveLoadOverlay:Disable()
    else
        SaveLoadOverlay.UI = Generic.Create("PIP_SaveLoadOverlay")
        SetupUI()
    end
end