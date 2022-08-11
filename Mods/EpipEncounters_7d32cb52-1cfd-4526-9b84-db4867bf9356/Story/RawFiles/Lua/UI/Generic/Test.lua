
local Generic = Client.UI.Generic
local G = Generic

---@type GenericUI_Instance
local Test = Generic.Create("PIP_Test")
Test:Debug()

---------------------------------------------
-- METHODS
---------------------------------------------

function Test.TestButtons()
    ---@type GenericUI_Element_VerticalList
    local list = Test:CreateElement("btnList", "VerticalList", Test.Container)
    list:SetPosition(0, 40)
    local header = list:AddChild("header", "GenericUI_Element_Text")
    header:SetText(Text.Format("Buttons and StateButtons", {Color = "ffffff"}))
    header:SetSize(400, 40)

    local _B = Generic.ELEMENTS.Button
    local _SB = Generic.ELEMENTS.StateButton

    for _,id in pairs(_B.TYPES) do
        local button = list:AddChild(id, "Button") ---@type GenericUI_Element_Button

        button:SetType(id)
        button:SetText(Text.Format(id, {Color = "ffffff", Size = 15}))
        button.Events.Pressed:Subscribe(function (_)
            button:SetEnabled(false)
        end)
        button:SetCenterInLists(true)
    end

    list:SetSize(300, -1)

    local div = list:AddChild("div", "GenericUI_Element_Divider")
    div:SetType(2)
    div:SetSize(400)

    for id,index in pairs(_SB.TYPES) do
        local button = list:AddChild(id, "GenericUI_Element_StateButton")

        button:SetType(index)
        -- button:SetText(Text.Format(id, {Color = "ffffff", Size = 15}))
        button.Events.StateChanged:Subscribe(function (ev)
            print("state changed", ev.Active)
        end)
    end

    -- Slider
    local slider = list:AddChild("Slider", "Slider") ---@type GenericUI_Element_Slider
    slider.Events.HandleReleased:Subscribe(function (ev)
        print(ev.Value)
    end)
end

function Test.TestSlot()
    local list = Test:CreateElement("btnList", "VerticalList", Test.Container)
    local slot = list:AddChild("testSlot", "Slot") ---@type GenericUI_Element_Slot
    slot = slot:GetMovieClip()

    -- slot:SetIcon("Skill_Warrior_PhoenixDive", 50, 50)
    -- slot:SetSourceBorder(true)
    -- slot:SetCooldown(0)
    -- slot:SetLabel("12")

    ---@type GenericUI_Prefab_HotbarSlot
    local s1 = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot").Create(Test, "s1", list)
end

function Test.TestComboBox()
    local list = Test:CreateElement("btnList", "VerticalList", Test.Container)
    local combo = list:AddChild("Combo", "ComboBox")

    combo:SetOptions({
        {ID = "test1", Label = "Test 1"},
        {ID = "test2", Label = "Test 2"},
        {ID = "test3", Label = "Test 3"},
    })

    combo:SelectOption("test2")

    combo.Events.OptionSelected:Subscribe(function (e)
        print(e.Index)
    end)

    combo:SetOpenUpwards(true)
end

function Test.TestPositioning()
    local parent = Test.BG:AddChild("BGPositionTest", "TiledBackground")
    parent:SetBackground(1, 600, 600)
    parent:SetPosition(400, 20)

    local positions = {
        "Center",
        "TopLeft",
        "TopRight",
        "Top",
        "Left",
        "Right",
        "Bottom",
        "BottomLeft",
        "BottomRight",
    }

    for _,position in ipairs(positions) do
        local btn = parent:AddChild("PositionTest_" .. position, "Button")
        btn:SetPositionRelativeToParent(position, 0, 0)
    end
end

function Test.SetupTests()
    local ui = Test:GetUI()
    local root = ui:GetRoot()
    ui:Show()

    ---@type GenericUI_Element_TiledBackground
    local bg = Test:CreateElement("tiledbgTest", "TiledBackground", "")
    local container = bg:AddChild("container", "VerticalList")
    Test.Container = container
    Test.BG = bg

    ---@type GenericUI_Element_Text
    local text = Test:CreateElement("textTest", "Text", "tiledbgTest")
    text:SetMouseEnabled(false)

    bg:SetBackground(Generic.ELEMENTS.TiledBackground.BACKGROUND_TYPES.BOX, 400, 400)
    text:SetText(Text.Format("Generic Test", {Color = "ffffff"}))
    text:GetMovieClip().SetType(1)
    text:SetSize(400, 200)
    bg:GetMovieClip().background_mc.alpha = 0.8

    -- bg:SetAsDraggableArea()

    -- TESTS
    Test.TestButtons()
    Test.TestSlot()
    Test.TestComboBox()
    Test.TestPositioning()

    container:RepositionElements()
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function(_)
    if Test:IsDebug() then
        Timer.Start("", 1.6, function()
            Test.SetupTests()
        end)
    end
end)
