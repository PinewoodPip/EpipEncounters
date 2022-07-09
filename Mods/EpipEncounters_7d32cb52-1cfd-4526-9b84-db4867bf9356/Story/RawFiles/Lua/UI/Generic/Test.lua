
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
    epicEnemiesText:GetMovieClip().text_txt.autoSize = "center"
    epicEnemiesText:GetMovieClip().text_txt.align = "center"
    epicEnemiesText:SetText(Text.Format("Epic Enemies Perks<br>- This one<br>- That one<br>- Impetus", {
        Color = "ffffff",
        -- FontType = Text.FONTS.ITALIC,
    }))
    epicEnemiesText:GetMovieClip().text_txt.width = 500
    -- epicEnemiesText:SetPosition(5, 20)

    print(epicEnemiesText:GetMovieClip().text_txt.x)
    epicEnemiesText:SetStroke(0, 2, 1, 1, 2)

    -- epicEnemiesText:GetMovieClip().text_txt.x = 0

    button:SetText("Button!")

    button:GetMovieClip().visible = false
    icon:SetPosition(5, 150)

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
