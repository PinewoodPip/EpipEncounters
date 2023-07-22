
---------------------------------------------
-- Default UI for the InputBinder feature.
-- Supports setting and clearing the binding, and visualizes the selected key combination.
---------------------------------------------

local InputBinder = Epip.GetFeature("Features.InputBinder")
local Input = Client.Input
local Generic = Client.UI.Generic
local Button = Generic.GetPrefab("GenericUI_Prefab_Button")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local GenericUITextures = Epip.GetFeature("Feature_GenericUITextures")
local Textures = GenericUITextures.TEXTURES
local CommonStrings = Text.CommonStrings
local V = Vector.Create

local UI = Generic.Create("Features.InputBinder.UI", 999)
UI._Initialized = false
UI._CurrentBinding = nil ---@type InputLib_Action_KeyCombination?

UI.HEADER_SIZE = V(300, 50)
UI.BINDING_LABEL_SIZE = V(300, 75)

---------------------------------------------
-- METHODS
---------------------------------------------

---Opens the UI.
function UI.Open()
    UI._Initialize()
    UI:Show()
end

---Initializes the elements of the UI.
function UI._Initialize()
    if not UI._Initialized then
        local bg = UI:CreateElement("BG", "GenericUI_Element_Texture")
        bg:SetTexture(Textures.PANELS.ITEM_ALERT)

        -- Set up header and binding label
        local header = TextPrefab.Create(UI, "Header", bg, InputBinder.TranslatedStrings.Header:GetString(), "Center", UI.HEADER_SIZE)
        header:SetPositionRelativeToParent("Top", 0, 17)

        local bindingLabel = TextPrefab.Create(UI, "BindingLabel", bg, "", "Center", UI.BINDING_LABEL_SIZE)
        bindingLabel:SetPositionRelativeToParent("Center", 0, 20)

        -- Set up buttons
        local buttonList = bg:AddChild("ButtonList", "GenericUI_Element_HorizontalList")

        local acceptButton = Button.Create(UI, "AcceptButton", buttonList, Button:GetStyle("Blue"))
        acceptButton:SetLabel(CommonStrings.Accept:GetString())
        acceptButton.Events.Pressed:Subscribe(function (_)
            InputBinder.CompleteRequest(UI._CurrentBinding)
            UI:Hide()
        end)

        local clearButton = Button.Create(UI, "ClearButton", buttonList, Button:GetStyle("SmallRed"))
        clearButton:SetLabel(CommonStrings.Clear:GetString())
        clearButton.Events.Pressed:Subscribe(function (_)
            InputBinder.CompleteRequest(nil)
            UI:Hide()
        end)

        local cancelButton = Button.Create(UI, "CancelButton", buttonList, Button:GetStyle("SmallRed"))
        cancelButton:SetLabel(CommonStrings.Cancel:GetString())
        cancelButton.Events.Pressed:Subscribe(function (_)
            InputBinder.CancelRequest()
            UI:Hide()
        end)

        buttonList:RepositionElements()
        buttonList:SetPositionRelativeToParent("Bottom", 0, -90)

        UI.Background = bg
        UI.Header = header
        UI.BindingLabel = bindingLabel

        UI:SetPanelSize(bg:GetRawSize())
        UI:SetPositionRelativeToViewport("center", "center")

        UI._Initialized = false
    end

    local action = InputBinder.GetCurrentRequest()
    if not action then
        InputBinder:Error("UI._Initialized", "Called out of context (no request)")
    end

    -- Update header
    UI.Header:SetText(Text.Format(InputBinder.TranslatedStrings.Header:GetString(), {
        FormatArgs = {
            action:GetName(),
        },
        Size = 16,
    }))

    UI._CurrentBinding = nil
    UI._UpdateBindingLabel()
end

---Updates the binding label.
function UI._UpdateBindingLabel()
    local element = UI.BindingLabel
    local label
    if UI._CurrentBinding then
        label = Input.StringifyBinding(UI._CurrentBinding)
    else
        label = InputBinder.TranslatedStrings.Hint:GetString()
    end

    element:SetText(label)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to bind actions.
InputBinder.Events.BindingRequested:Subscribe(function (ev)
    UI.Open()
    ev:StopPropagation()
end, {StringID = "DefaultImplementation"})

-- Listen for key combinations being pressed while the UI is visible.
local function GetPressedKeys()
    local dummyBinding = {Keys = {}}

    for key,_ in pairs(Input.pressedKeys) do
        if (not Input.IsMouseInput(key) and not Input.IsTouchInput(key) or Input.ACTION_WHITELISTED_MOUSE_INPUTS[key]) then
            table.insert(dummyBinding.Keys, key)
        end
    end

    table.simpleSort(dummyBinding.Keys)

    return dummyBinding
end
Input.Events.KeyPressed:Subscribe(function (ev)
    if UI:IsVisible() then
        if Input.IsMouseInput(ev.InputID) and not Input.ACTION_WHITELISTED_MOUSE_INPUTS[ev.InputID] then return end
        local dummyBinding = GetPressedKeys()
        if #dummyBinding.Keys == 0 then return end
        local mapping = Input.StringifyBinding(dummyBinding)
        if mapping == UI._CurrentBinding then return end -- Prevents action spam from pressing excepted keys (ex. mouse) while holding others

        InputBinder:DebugLog("Mapping pressed: ", mapping)

        UI._CurrentBinding = dummyBinding
        UI._UpdateBindingLabel()
    end
end)