
local Generic = Client.UI.Generic
local SpinnerPrefab = Generic.GetPrefab("GenericUI_Prefab_Spinner")

-- Creates the UI
local ExampleUI = Generic.Create("PIP_ExampleUI")

-- Adds a background element
local background = ExampleUI:CreateElement("MyBackground", "GenericUI_Element_TiledBackground")
background:SetBackground("RedPrompt", 400, 400) -- 400x400 panel size

background.Events.MouseOver:Subscribe(function (_)
    print("Mouse entered background")
end)

-- Adds a button
local closeButton = background:AddChild("CloseButton", "GenericUI_Element_Button")
closeButton:SetType("Close") -- Sets the appearance
closeButton:SetPositionRelativeToParent("TopRight", -20, 20) -- Puts the button in the top right corner of the parent element (Background) with a 20px offset on both axes

-- Events can be registered from the elements, with basic ones like MouseOver, MouseUp also being available in addition to the high-level ones implemented by each element type. Pressed is akin to MouseUp, but only fires if the button is not disabled.
closeButton.Events.Pressed:Subscribe(function (_)
    -- Close the UI when the button is pressed
    ExampleUI:Hide()
end)

-- Adds some text
local header = background:AddChild("MyHeader", "GenericUI_Element_Text")
header:SetText(Text.Format("My UI", {Color = Color.BLACK}))
header:SetSize(400, 50)
header:SetPositionRelativeToParent("Top", 0, 60) -- Sets the header's position to the top center of the panel, with a 60px offset from the top

-- VerticalList is the equivalent of Larian's listDisplay; HorizontalList and Grid are also available
local contentList = background:AddChild("ContentList", "GenericUI_Element_VerticalList")
contentList:SetElementSpacing(10)

-- Adding children to a list-like element automatically positions them, similar to listDisplay.addElement()
local dropdown = contentList:AddChild("Dropdown", "GenericUI_Element_ComboBox")
dropdown:SetOptions({
    {ID = "Option1", Label = "Option 1"},
    {ID = "Option2", Label = "Option 2"},
    {ID = "Option3", Label = "Option 3"},
})
dropdown:SelectOption("Option2")

-- Prefabs can be created to work with groups of elements in an abstracted and reusable manner, simulating custom sprites
-- The Spinner prefab implements a spinner form control using Text + Button elements
local spinner = SpinnerPrefab.Create(ExampleUI, "MySpinner", contentList, Text.Format("My Spinner", {Color = Color.BLACK}), 0, 10, 1) -- Min value 0, max value 10, step 1; parented to contentList
spinner:SetSize(270, 30)
spinner:SetValue(3)
spinner.Events.ValueChanged:Subscribe(function (ev) -- Prefabs can implement their own contextual events
    print("Spinner value changed", ev.Value)
end)

contentList:SetPositionRelativeToParent("Center")

local acceptButton = background:AddChild("AcceptButton", "GenericUI_Element_Button")
acceptButton:SetText(Text.Format("Accept", {Size = 17}), 5)
acceptButton:SetPositionRelativeToParent("Bottom", 0, -50)

-- Enable the accept button when a specific dropdown option is chosen
dropdown.Events.OptionSelected:Subscribe(function (ev)
    print("Dropdown option selected", ev.Option.ID)

    acceptButton:SetEnabled(ev.Option.ID == "Option2")
end)

-- Other modders can access your UI and elements by their string ID
local myUI = Generic.GetInstance("PIP_ExampleUI")
local myAcceptButton = myUI:GetElementByID("AcceptButton")

-- Direct access to UIObject and MovieClip is available
print(ExampleUI:GetUI())
print(acceptButton:GetMovieClip())

-- GenericUI instances inherit from the same class as built-in UIs in Epip
print(ExampleUI:IsFlagged("OF_PlayerInput1"))

Ext.Events.SessionLoaded:Subscribe(function (_)
    ExampleUI:Show()
end)