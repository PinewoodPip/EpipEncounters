
---------------------------------------------
-- Contains utility methods to render settings via
-- Generic prefabs that mimic Larian's form UIs.
---------------------------------------------

local Generic = Client.UI.Generic
local ContextMenu = Client.UI.ContextMenu
local LabelledDropdownPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")
local LabelledCheckboxPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")
local LabelledTextField = Generic.GetPrefab("GenericUI_Prefab_LabelledTextField")
local LabelledSlider = Generic.GetPrefab("GenericUI_Prefab_LabelledSlider")
local Spinner = Generic.GetPrefab("GenericUI_Prefab_Spinner")
local FormTextHolder = Generic.GetPrefab("GenericUI.Prefabs.FormTextHolder")
local FormSlot = Generic.GetPrefab("GenericUI.Prefab.Form.Slot")
local FormColor = Generic.GetPrefab("GenericUI.Prefab.Form.Color")
local SkillPicker = Epip.GetFeature("Features.SkillPicker")
local InputBinder = Epip.GetFeature("Features.InputBinder")
local ColorPicker = Epip.GetFeature("Features.ColorPicker")
local V = Vector.Create

---@class Features.SettingWidgets : Feature
local Widgets = {
    DEFAULT_SIZE = V(400, 50), -- Default size used if no override is specified.
    TEXTFIELD_DELAY = 0.6, -- Delay in seconds between text edits and the respective String setting being updated.
    MAX_INPUT_BINDINGS = 2, -- Not a hard limit; the Input library supports infinite bindings per action, however displaying that in an elegant manner is difficult!

    CONTEXT_MENU_ENTRIES = {
        RESET = "Features.SettingWidgets.Reset",
    },

    _TOOLTIP_ID_PATTERN = "^SettingWidgets%.(.+)%.(.+)$", -- Module ID can have periods.

    _CurrentSkillPickerSetting = nil, ---@type Features.SettingWidgets.Hooks.RenderSetting?
    _CurrentColorPickerSetting = nil, ---@type Features.SettingWidgets.Hooks.RenderSetting?

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        SettingUpdated = {}, ---@type Event<Features.SettingWidgets.Events.SettingUpdated>
    },
    Hooks = {
        RenderSetting = {}, ---@type Hook<Features.SettingWidgets.Hooks.RenderSetting>
    },
}
Epip.RegisterFeature("SettingWidgets", Widgets)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.SettingWidgets.SupportedSettingType SettingsLib_Setting_Choice|SettingsLib_Setting_Boolean|SettingsLib_Setting_String|SettingsLib.Settings.InputBinding|SettingsLib_Setting_ClampedNumber|SettingsLib.Setting.Color

---@alias Features.SettingWidgets.PreferredRepresentation.ClampedNumber "Slider"|"Spinner"
---@alias Features.SettingWidgets.ValueFormatting "Default"|"Time"

---@class Features.SettingWidgets.Setting.Slider : Feature_SettingsMenu_Setting_Slider
---@field PreferredRepresentation Features.SettingWidgets.PreferredRepresentation.ClampedNumber
---@field ValueFormatting Features.SettingWidgets.ValueFormatting

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Thrown when a rendered setting has been interacted with.
---@class Features.SettingWidgets.Events.SettingUpdated
---@field Request Features.SettingWidgets.Hooks.RenderSetting
---@field Value any Hookable. Defaults to setting value.

---@class Features.SettingWidgets.Hooks.RenderSetting
---@field UI GenericUI_Instance
---@field Parent GenericUI_ParentIdentifier?
---@field Setting Features.SettingWidgets.SupportedSettingType
---@field Size Vector2 If not set by caller, defaults to `DEFAULT_SIZE`.
---@field ValueChangedCallback fun(value:any)? Callback for when the setting's value changes **through the widget**.
---@field Instance (GenericUI_Prefab|GenericUI_I_Elementable)? Hookable. Defaults to `nil`.
---@field UpdateSettingValue boolean
---@field DefaultShownValue any?

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
---@param updateSettingValue boolean? If `true`, interactions with the element will automatically apply changes to the setting. Defaults to `true`.
---@param defaultShownValue any? If set, the element will be set to display this value regardless of the setting's actual value. Setting a `nil` value is unsupported.
---@return GenericUI_Prefab|GenericUI_I_Elementable
function Widgets.RenderSetting(ui, parent, setting, size, callback, updateSettingValue, defaultShownValue)
    updateSettingValue = updateSettingValue == nil and true or updateSettingValue
    return Widgets.Hooks.RenderSetting:Throw({
        UI = ui,
        Parent = parent,
        Setting = setting,
        Size = size or Widgets.DEFAULT_SIZE,
        ValueChangedCallback = callback,
        Instance = nil,
        UpdateSettingValue = updateSettingValue,
        DefaultShownValue = defaultShownValue,
    }).Instance
end

---Returns the setting being displayed in a custom tooltip, if any.
---@param tooltip TooltipLib_TooltipSourceData
---@return SettingsLib_Setting?
function Widgets.GetTooltipSetting(tooltip)
    local tooltipID = tooltip.CustomTooltipID
    if not tooltipID then return nil end
    local module, id = tooltipID:match(Widgets._TOOLTIP_ID_PATTERN)
    local setting = nil ---@type SettingsLib_Setting?
    if module then
        setting = Settings.GetSetting(module, id)
    end
    return setting
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

    local checkbox = LabelledCheckboxPrefab.Create(ui, Widgets._GetPrefixedID(setting), parent, setting:GetName())

    checkbox:SetSize(size:unpack())
    checkbox:SetState(Widgets._GetDefaultShownValue(request))

    -- Set setting value and run callback.
    checkbox.Events.StateChanged:Subscribe(function (ev)
        Widgets._SetSettingValue(setting, ev.Active, request)
    end)

    checkbox:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    -- Update the checkbox when the setting is changed.
    Widgets._RegisterValueChangedListener(checkbox, request, function (ev)
        checkbox:SetState(ev.Value)
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

    local dropdown = LabelledDropdownPrefab.Create(ui, Widgets._GetPrefixedID(setting), parent, setting:GetName(), options)
    dropdown:SetSize(size:unpack())
    dropdown:SelectOption(Widgets._GetDefaultShownValue(request))

    -- Set setting value and run callback.
    dropdown.Events.OptionSelected:Subscribe(function (ev)
        Widgets._SetSettingValue(setting, ev.Option.ID, request)
    end)

    dropdown:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    -- Hide the tooltip when the dropdown is interacted with,
    -- so it doesn't obscure the options.
    dropdown.ComboBox.Events.MouseUp:Subscribe(function (_)
        Client.Tooltip.HideTooltip()
    end)

    -- Update the combobox when the setting is changed.
    Widgets._RegisterValueChangedListener(dropdown, request, function (ev)
        dropdown:SelectOption(ev.Value)
    end)

    return dropdown
end

---Renders an editable text field tostring a String setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI_Prefab_LabelledTextField
function Widgets._RenderTextFieldFromSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib_Setting_String
    local timerID = Widgets._GetPrefixedID(setting) .. ".Timer"
    local ui, parent, size = request.UI, request.Parent, request.Size

    local field = LabelledTextField.Create(ui, Widgets._GetPrefixedID(setting), parent, setting:GetName())
    field:SetText(Widgets._GetDefaultShownValue(request))
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

    -- Update the text when the setting is changed.
    Widgets._RegisterValueChangedListener(field, request, function (ev)
        local textField = field.Text
        if not textField:IsFocused() then -- Do not do this if the user is typing, as it is redundant and will reset the caret.
            field:SetText(ev.Value)
        end
    end)

    return field
end

---Renders a list of bindings from an InputBinding setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI.Prefabs.FormTextHolder
function Widgets._RenderInputBindingSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib.Settings.InputBinding
    local ui, parent, size = request.UI, request.Parent, request.Size

    local form = FormTextHolder.Create(ui, Widgets._GetPrefixedID(setting), parent, setting:GetName(), size)
    local action = setting.TargetActionID

    if action then
        local function UpdateFields()
            local bindings = Client.Input.GetActionBindings(action)
            local bindingNames = {} ---@type string[]
            for i,binding in ipairs(bindings) do
                bindingNames[i] = Client.Input.StringifyBinding(binding)
            end
            for i=#bindingNames+1,Widgets.MAX_INPUT_BINDINGS,1 do -- Add extra empty fields, until reaching max
                bindingNames[i] = Text.CommonStrings.Unbound:Format({Color = Color.LARIAN.DARK_GRAY})
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

        -- Update the fields when the setting is changed.
        Widgets._RegisterValueChangedListener(form, request, function (_)
            UpdateFields()
        end)
    else
        Widgets:LogWarning("Using InputBinding settings without a target action is not supported!")
    end

    if request.DefaultShownValue ~= nil then
        Widgets:__LogWarning("_RenderInputBindingSetting", "DefaultShownValue is not supported for InputBinding settings")
    end

    return form
end

---Renders a slider for a ClampedNumber setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI_Prefab_LabelledSlider
function Widgets._RenderClampedNumberSetting(request)
    local setting = request.Setting ---@cast setting Features.SettingWidgets.Setting.Slider
    local ui, parent, size = request.UI, request.Parent, request.Size

    local instance
    local preferredRepresentation = setting.PreferredRepresentation or "Slider"
    local settingID = Widgets._GetPrefixedID(setting)
    local step = setting.Step or 0.1 -- Default to 0.1 step for settings that use the base class.
    if preferredRepresentation == "Slider" then
        instance = LabelledSlider.Create(ui, settingID, parent, size, setting:GetName(), setting.Min, setting.Max, step)

        -- Handle the slider being interacted with.
        ---@param ev GenericUI_Element_Slider_Event_HandleMoved|GenericUI_Element_Slider_Event_HandleReleased
        local function OnValueChanged(ev)
            Widgets._SetSettingValue(setting, ev.Value, request)
        end
        instance.Events.HandleMoved:Subscribe(OnValueChanged)
        instance.Events.HandleReleased:Subscribe(OnValueChanged)
    elseif preferredRepresentation == "Spinner" then
        instance = Spinner.Create(ui, settingID, parent, setting:GetName(), setting.Min, setting.Max, step, size, Spinner.STYLES.DOS1Large)

        instance.Events.ValueChanged:Subscribe(function (ev)
            Widgets._SetSettingValue(setting, ev.Value, request)
        end)

        -- Format values per setting preference.
        -- "Default" needs no special consideration.
        if setting.ValueFormatting == "Time" then
            -- Format as MM:SS.
            instance.Hooks.GetValueLabel:Subscribe(function (ev)
                ev.Label = Text.FormatTime(ev.Value)
            end)
        end
    end

    instance:SetValue(Widgets._GetDefaultShownValue(request))

    -- Update the slider when the setting is changed.
    Widgets._RegisterValueChangedListener(instance, request, function (ev)
        instance:SetValue(ev.Value)
    end)

    -- Setup tooltips on hover
    instance:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    return instance
end


---Renders a slider for a ClampedNumber setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI.Prefab.Form.Slot
function Widgets._RenderSlotSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib.Setting.Skill
    local ui, parent, size = request.UI, request.Parent, request.Size

    local instance
    local settingID = Widgets._GetPrefixedID(setting)
    instance = FormSlot.Create(ui, settingID, parent, setting:GetName(), size)
    local slot = instance.Slot
    slot:SetCanDrag(false)
    slot:SetCanDrop(true)
    slot:SetUsable(false)
    slot:SetValidObjectTypes({
        ["Skill"] = true,
        ["Action"] = true,
    })

    -- Handle the element being interacted with
    instance.Events.ObjectDraggedIn:Subscribe(function (ev)
        if ev.Object.Type == "Skill" then
            Widgets._SetSettingValue(setting, ev.Object.StatsID, request)
        end
    end)

    -- Open the skill picker when the slot is clicked
    instance.Events.Clicked:Subscribe(function (_)
        Widgets._CurrentSkillPickerSetting = request
        SkillPicker.Request("SettingWidget")
    end)

    -- Set the slot to display the setting's skill
    instance.Slot:SetSkill(Widgets._GetDefaultShownValue(request))

    -- Update the slot when the setting is changed
    Widgets._RegisterValueChangedListener(instance, request, function (ev)
        instance.Slot:SetSkill(ev.Value)
    end)

    -- Setup tooltips on hover
    instance:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    return instance
end

---Renders a picker for a Color setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return GenericUI.Prefab.Form.Color
function Widgets._RenderColorSetting(request)
    local setting = request.Setting ---@cast setting SettingsLib.Setting.Color
    local ui, parent, size = request.UI, request.Parent, request.Size

    local instance
    local settingID = Widgets._GetPrefixedID(setting)
    instance = FormColor.Create(ui, settingID, parent, setting:GetName(), size)
    instance:SetColor(Widgets._GetDefaultShownValue(request)) -- Display the current color.

    -- Open the Color Picker when the color is clicked.
    instance.Events.ColorClicked:Subscribe(function (_)
        Widgets._CurrentColorPickerSetting = request
        ColorPicker.Request("SettingWidget", setting:GetValue())
    end)

    -- Update the color when the setting is changed
    Widgets._RegisterValueChangedListener(instance, request, function (ev)
        instance:SetColor(ev.Value)
    end)

    -- Setup tooltips on hover
    instance:SetTooltip("Custom", Widgets._GetSettingTooltip(setting))

    return instance
end

---Registers a callback for a setting value changing.
---@param instance GenericUI_I_Elementable
---@param request Features.SettingWidgets.Hooks.RenderSetting The request's callback will also be invoked.
---@param callback fun(ev:Features.SettingWidgets.Events.SettingUpdated) Callback intended to update the widget instance.
function Widgets._RegisterValueChangedListener(instance, request, callback)
    local subscriberID = "Features.SettingWidgets." .. Text.GenerateGUID()
    Widgets.Events.SettingUpdated:Subscribe(function (ev)
        if instance:IsDestroyed() then -- Remove the listener once the instance has been destroyed.
            Widgets.Events.SettingUpdated:Unsubscribe(subscriberID)
        elseif ev.Request.Setting == request.Setting then
            callback(ev)
            if request.ValueChangedCallback then
                request.ValueChangedCallback(ev.Value) -- Also invoke the callback from the request.
            end
        end
    end, {StringID = subscriberID})
end

---Attempts to the value of a setting.
---@param setting Features.SettingWidgets.SupportedSettingType
---@param value any
---@param request Features.SettingWidgets.Hooks.RenderSetting
function Widgets._SetSettingValue(setting, value, request)
    if request.UpdateSettingValue then
        Settings.SetValue(setting.ModTable, setting:GetID(), value)
        Settings.Save(setting.ModTable)
    end
    Widgets.Events.SettingUpdated:Throw({
        Request = request,
        Value = value,
    })
end

---Generates a tooltip for a setting.
---@param setting SettingsLib_Setting
---@return TooltipLib_CustomFormattedTooltip?
function Widgets._GetSettingTooltip(setting)
    local description = setting:GetDescription()
    if description == "" then return nil end -- Do not create a tooltip for settings with no description.

    ---@type TooltipLib_CustomFormattedTooltip
    local tooltip = {
        ID = string.format("SettingWidgets.%s.%s", setting.ModTable, setting.ID),
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

---Opens the context menu for a setting.
---@param request Features.SettingWidgets.Hooks.RenderSetting
function Widgets._SetupSettingContextMenu(request)
    ContextMenu.Setup({
        menu = {
            id = "main",
            entries = {
                {id = Widgets.CONTEXT_MENU_ENTRIES.RESET, type = "button", text = Text.CommonStrings.ResetToDefault:GetString(), params = {Request = request}},
            }
        }
    })

    ContextMenu.Open(V(Client.GetMousePosition()))
end

---Returns the default value to display for a widget.
---@param request Features.SettingWidgets.Hooks.RenderSetting
---@return any
function Widgets._GetDefaultShownValue(request)
    if request.DefaultShownValue ~= nil then
        return request.DefaultShownValue
    else
        return request.Setting:GetValue()
    end
end

---Returns a prefixed ID, for use with elements.
---@param setting Features.SettingWidgets.SupportedSettingType
---@return string
function Widgets._GetPrefixedID(setting)
    return "Features.SettingWidgets.RenderedSetting." .. setting.ModTable .. "." .. setting.ID
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
    elseif setting.Type == "Skill" then
        ev.Instance = Widgets._RenderSlotSetting(ev)
    elseif setting.Type == "Color" then
        ev.Instance = Widgets._RenderColorSetting(ev)
    end

    -- Add listeners for opening the context menu.
    -- TODO extract to a separate listener so this works on other implementations of RenderSetting as well?
    if ev.Instance then
        local root = ev.Instance:GetRootElement()
        root.Events.RightClick:Subscribe(function (_)
            Widgets._SetupSettingContextMenu(ev)
        end)
    end
end, {StringID = "DefaultImplementation"})

-- Listen for requests to reset setting values from the context menu.
ContextMenu.RegisterElementListener(Widgets.CONTEXT_MENU_ENTRIES.RESET, "buttonPressed", function(_, params)
    local request = params.Request ---@type Features.SettingWidgets.Hooks.RenderSetting
    local setting = request.Setting

    -- Widgets will be updated using their regular SettingsLib listeners; no need to track requests here.
    Widgets._SetSettingValue(setting, setting:GetDefaultValue(), request)
end)

-- Handle skill settings being set from the picker.
SkillPicker.Events.RequestCompleted:Subscribe(function (ev)
    if ev.RequestID == "SettingWidget" then
        local request = Widgets._CurrentSkillPickerSetting
        Widgets._SetSettingValue(request.Setting, ev.Skill, request)
    end
end)

-- Handle color settings being set from the picker.
ColorPicker.Events.ColorPicked:Subscribe(function (ev)
    if ev.RequestID == "SettingWidget" then
        local request = Widgets._CurrentColorPickerSetting
        Widgets._SetSettingValue(request.Setting, ev.Color, request)
    end
end)
