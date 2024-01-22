
---------------------------------------------
-- Contains utility methods to render settings via
-- Generic prefabs that mimic Larian's form UIs.
---------------------------------------------

local Generic = Client.UI.Generic
local LabelledDropdownPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")
local LabelledCheckboxPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")
local LabelledTextField = Generic.GetPrefab("GenericUI_Prefab_LabelledTextField")
local LabelledSlider = Generic.GetPrefab("GenericUI_Prefab_LabelledSlider")
local FormTextHolder = Generic.GetPrefab("GenericUI.Prefabs.FormTextHolder")
local InputBinder = Epip.GetFeature("Features.InputBinder")
local V = Vector.Create

---@class Features.SettingWidgets : Feature
local Widgets = {
    DEFAULT_SIZE = V(400, 50), -- Default size used if no override is specified.
    TEXTFIELD_DELAY = 0.6, -- Delay in seconds between text edits and the respective String setting being updated.
    MAX_INPUT_BINDINGS = 2, -- Not a hard limit; the Input library supports infinite bindings per action, however displaying that in an elegant manner is difficult!

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        RenderSetting = {}, ---@type Event<Features.SettingWidgets.Hooks.RenderSetting>
    },
}
Epip.RegisterFeature("SettingWidgets", Widgets)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.SettingWidgets.SupportedSettingType SettingsLib_Setting_Choice|SettingsLib_Setting_Boolean|SettingsLib_Setting_String|SettingsLib.Settings.InputBinding|SettingsLib_Setting_ClampedNumber

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.SettingWidgets.Hooks.RenderSetting -- TODO make this a hook instead
---@field UI GenericUI_Instance
---@field Parent GenericUI_ParentIdentifier?
---@field Setting Features.SettingWidgets.SupportedSettingType
---@field Size Vector2 If not set by caller, defaults to `DEFAULT_SIZE`.
---@field ValueChangedCallback fun(value:any)? Callback for when the setting's value changes **through the widget**.
---@field Instance (GenericUI_Prefab|GenericUI_I_Elementable)? Hookable. Defaults to `nil`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Renders a setting widget.
---@see Features.SettingWidgets.Hooks.RenderSetting
---@param ui GenericUI_Instance
---@param parent GenericUI_ParentIdentifier?
---@param setting Features.SettingWidgets.SupportedSettingType
---@param size Vector2?
---@param callback fun(value:any)?
---@return GenericUI_Prefab|GenericUI_I_Elementable
function Widgets.RenderSetting(ui, parent, setting, size, callback)
    return Widgets.Hooks.RenderSetting:Throw({
        UI = ui,
        Parent = parent,
        Setting = setting,
        Size = size,
        ValueChangedCallback = callback,
        Instance = nil,
    }).Instance
end

---------------------------------------------
-- PRIVATE METHODS
---------------------------------------------

---Renders a checkbox from a Boolean setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI_Prefab_LabelledCheckbox
function Widgets._RenderCheckboxFromSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib_Setting_Boolean
    local ui, parent, size = request.UI, request.Parent, request.Size

    local checkbox = LabelledCheckboxPrefab.Create(ui, Widgets._GetPrefixedID(setting:GetID()), parent, setting:GetName())

    checkbox:SetSize(size:unpack())
    checkbox:SetState(setting:GetValue())

    -- Set setting value and run callback.
    checkbox.Events.StateChanged:Subscribe(function (ev)
        Widgets._SetSettingValue(setting, ev.Active, request)
    end)

    checkbox:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    return checkbox
end

---Renders a combobox from a Choice setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI_Prefab_LabelledDropdown
function Widgets._RenderComboBoxFromSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib_Setting_Choice
    local ui, parent, size = request.UI, request.Parent, request.Size

    -- Generate combobox options from setting choices.
    local options = {}
    for _,choice in ipairs(setting.Choices) do
        table.insert(options, {
            ID = choice.ID,
            Label = choice:GetName(),
        })
    end

    local dropdown = LabelledDropdownPrefab.Create(ui, Widgets._GetPrefixedID(setting:GetID()), parent, setting:GetName(), options)
    dropdown:SetSize(size:unpack())
    dropdown:SelectOption(setting:GetValue())

    -- Set setting value and run callback.
    dropdown.Events.OptionSelected:Subscribe(function (ev)
        Widgets._SetSettingValue(setting, ev.Option.ID, request)
    end)

    dropdown:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    return dropdown
end

---Renders an editable text field tostring a String setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI_Prefab_LabelledTextField
function Widgets._RenderTextFieldFromSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib_Setting_String
    local timerID = Widgets._GetPrefixedID("Timer_" .. setting:GetID())
    local ui, parent, size = request.UI, request.Parent, request.Size

    local field = LabelledTextField.Create(ui, Widgets._GetPrefixedID(setting:GetID()), parent, setting:GetName())
    field:SetText(setting:GetValue())
    field:SetSize(size:unpack())

    -- Set setting value and run callback
    -- This uses a delay to reduce lag from needless updates.
    field.Events.TextEdited:Subscribe(function (ev)
        local existingTimer = Timer.GetTimer(timerID)
        if existingTimer then
            existingTimer:Cancel()
        end

        Timer.Start(timerID, Widgets.TEXTFIELD_DELAY, function (_)
            Widgets._SetSettingValue(setting, ev.Text, request)
        end)
    end)

    field:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    return field
end

---Renders a list of bindings from an InputBinding setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI.Prefabs.FormTextHolder
function Widgets._RenderInputBindingSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib.Settings.InputBinding
    local ui, parent, size = request.UI, request.Parent, request.Size

    local form = FormTextHolder.Create(ui, Widgets._GetPrefixedID(setting:GetID()), parent, setting:GetName(), size)
    local action = setting.TargetActionID

    if action then
        local function UpdateFields()
            local bindings = Client.Input.GetActionBindings(action)
            local bindingNames = {} ---@type string[]
            for i,binding in ipairs(bindings) do
                bindingNames[i] = Client.Input.StringifyBinding(binding)
            end
            for i=#bindingNames+1,Widgets.MAX_INPUT_BINDINGS,1 do -- Add extra empty fields, until reaching max
                bindingNames[i] = ""
            end

            form:SetFields(bindingNames)
        end

        UpdateFields()

        -- Request binding when clicked, and listen for the request being completed/cancelled to update the view
        form.Events.FieldClicked:Subscribe(function (ev)
            InputBinder.Events.RequestCompleted:Subscribe(function (_)
                UpdateFields()

                InputBinder.Events.RequestCompleted:Unsubscribe("Features.SettingWidgets") -- Unsubscribe to prevent leaks
                InputBinder.Events.RequestCancelled:Unsubscribe("Features.SettingWidgets")
            end, {StringID = "Features.SettingWidgets"})
            InputBinder.Events.RequestCancelled:Subscribe(function (_)
                InputBinder.Events.RequestCompleted:Unsubscribe("Features.SettingWidgets") -- Unsubscribe to prevent leaks
                InputBinder.Events.RequestCancelled:Unsubscribe("Features.SettingWidgets")
            end, {StringID = "Features.SettingWidgets"})

            -- Should be ordered after event registration in case the request is resolved synchronously
            InputBinder.RequestBinding(Client.Input.GetAction(action), ev.Index)
        end)

        form:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))
    else
        Widgets:LogWarning("Using InputBinding settings without a target action is not supported!")
    end

    return form
end

---Renders a slider for a ClampedNumber setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI_Prefab_LabelledSlider
function Widgets._RenderClampedNumberSetting(request)
    local setting = request.Setting ---@cast setting Feature_SettingsMenu_Setting_Slider
    local ui, parent, size = request.UI, request.Parent, request.Size
    local instance = LabelledSlider.Create(ui, Widgets._GetPrefixedID(setting:GetID()), parent, size, setting:GetName(), setting.Min, setting.Max, setting.Step or 0.1) -- Default to 0.1 step for settings that use the base class.

    -- Handle the slider being interacted with.
    ---@param ev GenericUI_Element_Slider_Event_HandleMoved|GenericUI_Element_Slider_Event_HandleReleased
    local function OnValueChanged(ev)
        Widgets._SetSettingValue(setting, ev.Value, request)
    end
    instance.Events.HandleMoved:Subscribe(OnValueChanged)
    instance.Events.HandleReleased:Subscribe(OnValueChanged)

    return instance
end

---Sets the value of a setting and runs the ValueChanged callback.
---@param setting Features.SettingWidgets.SupportedSettingType
---@param value any
---@param request any
function Widgets._SetSettingValue(setting, value, request)
    Settings.SetValue(setting.ModTable, setting:GetID(), value)
    Settings.Save(setting.ModTable)

    if request.ValueChangedCallback then
        request.ValueChangedCallback(value)
    end
end

---Generates a tooltip for a setting.
---@param setting SettingsLib_Setting
---@return TooltipLib_CustomFormattedTooltip?
function Widgets._GetSettingTooltip(setting)
    local description = setting:GetDescription()
    if description == "" then return nil end -- Do not create a tooltip for settings with no description.

    ---@type TooltipLib_CustomFormattedTooltip
    local tooltip = {
        Elements = {
            {
                Type = "ItemName",
                Label = setting:GetName(),
            },
            {
                Type = "ItemDescription",
                Label = description,
            },
            {
                Type = "ItemRarity",
                Label = "", -- Necessary to properly clean up the previous tooltip.
            },
        },
    }
    return tooltip
end

---Returns a prefixed ID, for use with elements.
---@param id string
---@return string
function Widgets._GetPrefixedID(id)
    return "Feature_SettingWidgets_Setting_" .. id
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Default implementation of RenderSetting event.
Widgets.Hooks.RenderSetting:Subscribe(function (ev)
    local setting = ev.Setting
    if setting.Type == "Boolean" then
        ev.Instance = Widgets._RenderCheckboxFromSetting(ev)
    elseif setting.Type == "Choice" then
        ev.Instance = Widgets._RenderComboBoxFromSetting(ev)
    elseif setting.Type == "String" then
        ev.Instance = Widgets._RenderTextFieldFromSetting(ev)
    elseif setting.Type == "InputBinding" then
        ev.Instance = Widgets._RenderInputBindingSetting(ev)
    elseif setting.Type == "ClampedNumber" then
        ev.Instance = Widgets._RenderClampedNumberSetting(ev)
    end
end, {StringID = "DefaultImplementation"})