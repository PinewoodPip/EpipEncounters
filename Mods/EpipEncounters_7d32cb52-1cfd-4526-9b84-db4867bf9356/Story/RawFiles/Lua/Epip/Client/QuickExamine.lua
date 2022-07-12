
Epip.Features.QuickExamine = {
    WIDTH = 400,
    DIVIDER_WIDTH = 370,
    HEIGHT = 600,
}
local QuickExamine = Epip.Features.QuickExamine
Epip.AddFeature("QuickExamine", "QuickExamine", QuickExamine)

local Generic = Client.UI.Generic

QuickExamine.UI = Generic.Create("PIP_QuickExamine")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---------------------------------------------
-- SETUP
---------------------------------------------

local function Setup()
    local ui = QuickExamine.UI
    local uiObject = ui:GetUI()

    ---@type GenericUI_Element_TiledBackground
    local panel = ui:CreateElement("Panel", "TiledBackground")

    panel:SetSize(QuickExamine.WIDTH, QuickExamine.HEIGHT)
    panel:SetAlpha(0.5)
    panel:SetAsDraggableArea()
    
    uiObject.SysPanelSize = {QuickExamine.WIDTH, QuickExamine.HEIGHT}
    uiObject.Left = QuickExamine.WIDTH

    ---@type GenericUI_Element_ScrollList
    local container = panel:AddChild("Container", "ScrollList")

    container:SetFrame(QuickExamine.WIDTH, QuickExamine.HEIGHT)

    ---@type GenericUI_Element_VerticalList
    local list = container:AddChild("List", "VerticalList")

    ui:GetUI():Show()

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "center")

    local x, y = ui:GetPosition()
    uiObject:SetPosition(x, y + 100)

    -- Text and divider
    local header = list:AddChild("Header", "Text") ---@type GenericUI_Element_Text
    header:SetText(Text.Format("Quick Examine", {
        Color = "ffffff",
        Size = 15,
    }))
    header:SetSize(QuickExamine.WIDTH, 20)

    local charName = list:AddChild("CharName", "Text")
    charName:SetText(Text.Format("Character Name", {
        Color = "ffffff",
        Size = 21,
    }))
    charName:SetSize(QuickExamine.WIDTH, 30)

    local div = list:AddChild("MainDiv", "Divider")
    div:SetSize(QuickExamine.DIVIDER_WIDTH, 20)
    -- div:SetCenterInLists(true)

    list:RepositionElements()

    local content = list:AddChild("Content", "VerticalList")
    QuickExamine.ContentContainer = content
end

function QuickExamine:__Setup()
    Client.Timer.Start("", 1.4, function()
        Setup()
    end)
end