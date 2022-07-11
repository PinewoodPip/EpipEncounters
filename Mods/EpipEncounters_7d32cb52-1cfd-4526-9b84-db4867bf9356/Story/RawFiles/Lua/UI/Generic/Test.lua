
local Generic = Client.UI.Generic
local G = Generic

---@type GenericUI_Instance
local Test = Generic.Create("PIP_Test")

---------------------------------------------
-- METHODS
---------------------------------------------

function Test.TestButtons()
    ---@type GenericUI_Element_VerticalList
    local list = Test:CreateElement("btnList", "VerticalList", Test.Container)
    list:SetPosition(0, 40)

    for id,index in pairs(Generic.ELEMENTS.Button.TYPES) do
        local button = list:AddChild(id, "Button") ---@type GenericUI_Element_Button

        button:SetType(index)
        button:SetText(Text.Format(id, {Color = "ffffff", Size = 15}))
    end
end

function Test.SetupTests()
    local ui = Test:GetUI()
    local root = ui:GetRoot()
    ui:Show()

    print(Test.ID, Test.GetMovieClipByID)
    print(root.Root.stringID)

    ---@type GenericUI_Element_TiledBackground
    local bg = Test:CreateElement("tiledbgTest", "TiledBackground", "")
    Test.Container = bg

    ---@type GenericUI_Element_Text
    local text = Test:CreateElement("textTest", "Text", "tiledbgTest")

    bg:SetBackground(Generic.ELEMENTS.TiledBackground.BACKGROUND_TYPES.BLACK, 400, 400)
    text:SetText(Text.Format("Generic Test", {Color = "ffffff"}))
    text:GetMovieClip().SetType(1)
    text:SetSize(400, 200)
    bg:GetMovieClip().background_mc.alpha = 0.2

    bg:SetAsDraggableArea()

    Test.TestButtons()

    
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function(_)
    Client.Timer.Start("", 1.4, function()
        Test.SetupTests()
    end)
end)
