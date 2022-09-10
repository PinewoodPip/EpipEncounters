
local Generic = Client.UI.Generic
local SpinnerPrefab = Generic.GetPrefab("GenericUI_Prefab_Spinner")

ExampleUI = Generic.Create("PIP_ExampleUI")

local background = ExampleUI:CreateElement("Background", "GenericUI_Element_TiledBackground")
background:SetBackground("RedPrompt", 400, 400) -- 400x400 panel size

local closeButton = background:AddChild("CloseButton", "GenericUI_Element_Button")
closeButton:SetType("Close")
closeButton:SetPositionRelativeToParent("TopRight", -20, 20)

-- Events can be registered from the elements, with basic ones like MouseOver, MouseUp also being available
closeButton.Events.Pressed:Subscribe(function (_) -- Close the UI when the button is pressed
    ExampleUI:Hide()
end)

local header = background:AddChild("Header", "GenericUI_Element_Text")
header:SetText(Text.Format("My UI", {Color = Color.BLACK}))
header:SetSize(400, 50)
header:SetPositionRelativeToParent("Top", 0, 60) -- Sets the header's position to the top of panel, with a 60px offset from the top

local contentList = background:AddChild("ContentList", "GenericUI_Element_VerticalList")
contentList:SetElementSpacing(10)

local dropdown = contentList:AddChild("Dropdown", "GenericUI_Element_ComboBox")
dropdown:SetOptions({
    {ID = "Option1", Label = "Option 1"},
    {ID = "Option2", Label = "Option 2"},
    {ID = "Option3", Label = "Option 3"},
})
dropdown:SelectOption("Option2")

-- Prefabs can be created to work with groups of elements in an abstracted and reusable manner, simulating custom sprites
-- The Spinner prefab implements a spinner form element using Text + Button elements
local spinner = SpinnerPrefab.Create(ExampleUI, "MySpinner", contentList, "My Label", 0, 10, 1) -- Min value 0, max value 10, step 1
spinner:SetSize(270, 30)
spinner:SetValue(3)
spinner.Events.ValueChanged:Subscribe(function (ev) -- With custom, contextual events, too
    print("Spinner value changed", ev.Value)
end)

contentList:SetPositionRelativeToParent("Center")

local acceptButton = background:AddChild("AcceptButton", "GenericUI_Element_Button")
acceptButton:SetText(Text.Format("Accept", {Size = 17}), 5)
acceptButton:SetPositionRelativeToParent("Bottom", 0, -50)
dropdown.Events.OptionSelected:Subscribe(function (ev)
    print("Dropdown option selected", ev.Option.ID)

    acceptButton:SetEnabled(ev.Option.ID == "Option2")
end)

-- Direct access to UIObject and MovieClip is available
print(ExampleUI:GetUI())
print(acceptButton:GetMovieClip())

-- Elements can be referenced by their ID even if not explicitly exposed by original modder, and modified at any time
print(ExampleUI:GetElementByID("AcceptButton"))

Ext.Events.SessionLoaded:Subscribe(function (_)
    ExampleUI:Show()
end)