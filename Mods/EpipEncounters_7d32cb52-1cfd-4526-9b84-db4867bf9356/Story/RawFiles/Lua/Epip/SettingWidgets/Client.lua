
---------------------------------------------
-- Contains utility methods to render settings via
-- Generic prefabs that mimic Larian's form UIs.
---------------------------------------------

local Generic = Client.UI.Generic
local LabelledDropdownPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")
local LabelledCheckboxPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")
local LabelledTextField = Generic.GetPrefab("GenericUI_Prefab_LabelledTextField")
local V = Vector.Create

---@class Features.SettingWidgets : Feature
local Widgets = {
    DEFAULT_SIZE = V(400, 50), -- Default size used if no override is specified.
    TEXTFIELD_DELAY = 0.6, -- Delay in seconds between text edits and the respective String setting being updated.

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

---@alias Features.SettingWidgets.SupportedSettingType SettingsLib_Setting_Choice|SettingsLib_Setting_Boolean|SettingsLib_Setting_String

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.SettingWidgets.Hooks.RenderSetting -- TODO make this a hook instead
---@field UI GenericUI_Instance
---@field Parent GenericUI_ParentIdentifier?
---@field Setting Features.SettingWidgets.SupportedSettingType
---@field Size Vector2 If not set by caller, defaults to `DEFAULT_SIZE`.
---@field ValueChangedCallback fun(value:any)? Callback for when the setting's value changes **through the widget**.
---@field Instance GenericUI_Prefab? Hookable. Defaults to `nil`.

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
---@return GenericUI_Prefab
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

    return field
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
        Widgets._RenderCheckboxFromSetting(ev)
    elseif setting.Type == "Choice" then
        Widgets._RenderComboBoxFromSetting(ev)
    elseif setting.Type == "String" then
        Widgets._RenderTextFieldFromSetting(ev)
    end
end, {StringID = "DefaultImplementation"})