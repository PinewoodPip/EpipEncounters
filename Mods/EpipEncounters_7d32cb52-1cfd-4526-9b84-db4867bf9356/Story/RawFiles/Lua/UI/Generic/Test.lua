
local Generic = Client.UI.Generic

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

    bg:SetBackground(Generic.ELEMENTS.TiledBackground.BACKGROUND_TYPES.BOX, 100, 100)
    text:SetText("Testing!")

    bg:SetAsDraggableArea()

    ---@type GenericUI_Element_IggyIcon
    local icon = Test:CreateElement("iggyTest", "IggyIcon", "tiledbgTest")
    icon:SetIcon("Skill_Warrior_DeflectiveBarrier", 64, 64)

    -- root.tiledbgTest.textTest.SetText("Asd")
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function(_)
    Client.Timer.Start("", 2, function()
        Test.SetupTests()
    end)
end)
