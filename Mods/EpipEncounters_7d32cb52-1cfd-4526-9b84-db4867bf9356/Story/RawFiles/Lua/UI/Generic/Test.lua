
local Generic = Client.UI.Generic
local G = Generic

---@type GenericUI_Instance
local Test = Generic.Create("PIP_Test")

---------------------------------------------
-- METHODS
---------------------------------------------

function Test.SetupTests()
    local ui = Test:GetUI()
    local root = ui:GetRoot()
    ui:Show()

    print(Test.ID, Test.GetMovieClipByID)
    print(root.Root.stringID)

    ---@type GenericUI_Element_TiledBackground
    local bg = Test:CreateElement("tiledbgTest", "TiledBackground", "")

    ---@type GenericUI_Element_Text
    local text = Test:CreateElement("textTest", "Text", "tiledbgTest")

    bg:SetBackground(Generic.ELEMENTS.TiledBackground.BACKGROUND_TYPES.BLACK, 400, 400)
    text:SetText("Testing!")
    text:GetMovieClip().SetType(0)
    text:SetSize(360/2, 200)
    bg:GetMovieClip().background_mc.alpha = 0.2

    bg:SetAsDraggableArea()

    ---@type GenericUI_Element_IggyIcon
    local icon = Test:CreateElement("iggyTest", "IggyIcon", "tiledbgTest")
    icon:SetIcon("AMER_UNI_Spear_D", 64, 64)

    ---@type GenericUI_Element_Button
    local button = Test:CreateElement("buttonTest", "Button", "tiledbgTest")
    button:SetType(G.ELEMENTS.Button.TYPES.BROWN)

    ---@type GenericUI_Element_Text
    local epicEnemiesText = Test:CreateElement("EpicEnemiesText", "Text", "tiledbgTest")

    -- epicEnemiesText:GetMovieClip().align = "left"
    epicEnemiesText:SetText("Testing!")
    epicEnemiesText:GetMovieClip().SetType(1)
    -- epicEnemiesText:GetMovieClip().SetType(0)
    epicEnemiesText:SetPosition(0, 20)
    -- epicEnemiesText:SetSize(100, 100)
    -- epicEnemiesText:GetMovieClip().text_txt.width = 100
    -- epicEnemiesText:GetMovieClip().text_txt.height = 100
    epicEnemiesText:SetSize(400, 200)
    print(epicEnemiesText:GetMovieClip()._txt_Center.width)
    print(epicEnemiesText:GetMovieClip()._txt_Left.width)
    -- epicEnemiesText:GetMovieClip().text_txt.width = 100
    -- epicEnemiesText:GetMovieClip().SetType(1)
    -- epicEnemiesText:SetStroke(0, 2, 1, 1, 2)

    button:SetText("Button!")

    button:GetMovieClip().visible = false
    icon:SetPosition(5, 150)

    ---@type GenericUI_Element_VerticalList
    local list = Test:CreateElement("list", "VerticalList", "tiledbgTest")
    Test:CreateElement("button_1", "Button", list)
    local button1 = Test:CreateElement("button_2", "Button", list)
    button1:SetText(Text.Format("Test", {
        Color = "ffffff",
    }))
    -- button1:GetMovieClip().text_txt.align = "center"

    print(button1:GetMovieClip().text_mc.text_txt.visible)
    button1:GetMovieClip().text_mc.text_txt.y = 100
    button1:GetMovieClip().bg_mc.visible = false

    list:GetMovieClip().visible = false

    -- root.tiledbgTest.textTest.SetText("Asd")
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function(_)
    Client.Timer.Start("", 1.4, function()
        Test.SetupTests()
    end)
end)
