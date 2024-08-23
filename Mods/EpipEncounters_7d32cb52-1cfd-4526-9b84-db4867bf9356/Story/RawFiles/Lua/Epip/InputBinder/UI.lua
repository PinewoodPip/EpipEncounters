
---------------------------------------------
-- Default UI for the InputBinder feature.
-- Supports setting and clearing the binding, and visualizes the selected key combination.
---------------------------------------------

local InputBinder = Epip.GetFeature("Features.InputBinder")
local Input = Client.Input
local Generic = Client.UI.Generic
local Button = Generic.GetPrefab("GenericUI_Prefab_Button")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local CommonStrings = Text.CommonStrings
local V = Vector.Create

local UI = Generic.Create("Features.InputBinder.UI", 999)
UI._Initialized = false
UI._CurrentBinding = nil ---@type InputLib_Action_KeyCombination?

UI.PANEL_SIZE = V(600, 200)
UI.HEADER_SIZE = V(UI.PANEL_SIZE[1], 50)
UI.BINDING_LABEL_SIZE = V(UI.PANEL_SIZE[1], 75)

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
        local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
        local bg = root:AddChild("BG", "GenericUI_Element_TiledBackground")
        bg:SetBackground("Black", UI.PANEL_SIZE:unpack())

        -- Set up header and binding label
        local header = TextPrefab.Create(UI, "Header", root, "", "Center", UI.HEADER_SIZE)
        header:SetPositionRelativeToParent("Top", 0, 40)

        local bindingLabel = TextPrefab.Create(UI, "BindingLabel", root, "", "Center", UI.BINDING_LABEL_SIZE)
        bindingLabel:SetPositionRelativeToParent("Center", 0, 20)

        -- Set up buttons
        local buttonList = bg:AddChild("ButtonList", "GenericUI_Element_HorizontalList")

        local acceptButton = Button.Create(UI, "AcceptButton", buttonList, Button.STYLES.Blue)
        acceptButton:SetLabel(CommonStrings.Accept)
        acceptButton.Events.Pressed:Subscribe(function (_)
            InputBinder.CompleteRequest(UI._CurrentBinding)
            UI:Hide()
        end)

        local clearButton = Button.Create(UI, "ClearButton", buttonList, Button.STYLES.SmallRed)
        clearButton:SetLabel(CommonStrings.Clear)
        clearButton.Events.Pressed:Subscribe(function (_)
            InputBinder.CompleteRequest(nil)
            UI:Hide()
        end)

        local cancelButton = Button.Create(UI, "CancelButton", buttonList, Button.STYLES.SmallRed)
        cancelButton:SetLabel(CommonStrings.Cancel)
        cancelButton.Events.Pressed:Subscribe(function (_)
            InputBinder.CancelRequest()
            UI:Hide()
        end)

        buttonList:RepositionElements()
        buttonList:SetPositionRelativeToParent("Bottom", 0, -40)

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
    UI.Header:SetText(Text.Format(InputBinder.TranslatedStrings.Header:Format({Size = 21, Color = Color.WHITE}), {
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
    label = Text.Format(label, {Color = Color.WHITE})

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

    -- Allow left2 to be used in a button chord.
    if Input.IsKeyPressed("left2") and dummyBinding.Keys[1] then
        table.insert(dummyBinding.Keys, "left2")
    end

    table.simpleSort(dummyBinding.Keys)

    return dummyBinding
end
GameState.Events.ClientReady:Subscribe(function (_)
    Input.Events.KeyPressed:Subscribe(function (ev)
        if UI:IsVisible() and InputBinder.GetCurrentRequest() then -- IsVisible() returns true in main menu as well on first session load for some reason - TODO investigate
            local dummyBinding = GetPressedKeys()
            if Input.IsMouseInput(ev.InputID) and (not Input.ACTION_WHITELISTED_MOUSE_INPUTS[ev.InputID] and not ev.InputID == "left2") then return end
            if #dummyBinding.Keys == 0 then return end
            local mapping = Input.StringifyBinding(dummyBinding)
            if mapping == UI._CurrentBinding then return end -- Prevents action spam from pressing excepted keys (ex. mouse) while holding others

            InputBinder:DebugLog("Mapping pressed: ", mapping)

            UI._CurrentBinding = dummyBinding
            UI._UpdateBindingLabel()
        end
    end)
end)