
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
local Generic = Client.UI.Generic
local Set = DataStructures.Get("DataStructures_Set")
local CheckboxPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")
local DropdownPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")
local SliderPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledSlider")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local SetPrefab = Generic.GetPrefab("GenericUI_Prefab_FormSet")
local SelectorPrefab = Generic.GetPrefab("GenericUI_Prefab_Selector")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local V = Vector.Create

---@class Feature_SettingsMenuOverlay : Feature
local Overlay = {
    -- Setting types supported by the previous implementation of the UI.
    ORIGINAL_SETTING_TYPES = Set.Create({
        "Boolean",
        "ClampedNumber",
        "Choice"
    }),

    _ALWAYS_USE = true, -- If `false`, the overlay will only be used if a tab contains elements that the original UI does not support.

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        RenderEntry = {}, ---@type Event<Feature_SettingsMenuOverlay_Event_RenderEntry>
    },
    Hooks = {
        CanRenderEntry = {}, ---@type Event<Feature_SettingsMenuOverlay_Hook_CanRenderEntry>
    }
}
Epip.RegisterFeature("SettingsMenuOverlay", Overlay)
local UI = Generic.Create("PIP_SettingsMenuOverlay")
UI._Initialized = false
UI.LIST_SIZE = V(950, 770)
UI.FORM_ELEMENT_SIZE = V(800, 60)
UI.DEFAULT_LABEL_SIZE = V(800, 999) -- Labels are afterwards resized to text height.

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_SettingsMenuOverlay_Event_RenderEntry
---@field Entry Feature_SettingsMenu_Entry
---@field Parent string|GenericUI_Element

---@class Feature_SettingsMenuOverlay_Hook_CanRenderEntry
---@field Entry Feature_SettingsMenu_Entry
---@field CanRender boolean Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI to render a list of entries.
---@param entries Feature_SettingsMenu_Entry[]
function Overlay.Setup(entries)
    Overlay._Initialize()

    -- Resize and reposition the overlay to match the regular menu
    local settingsUIObject = SettingsMenu:GetUI():GetUI()
    local uiObject = UI:GetUI()
    uiObject:Resize(settingsUIObject.FlashMovieSize[1], settingsUIObject.FlashMovieSize[2], settingsUIObject:GetUIScaleMultiplier())
    uiObject.SysPanelSize = settingsUIObject.SysPanelSize
    UI:SetPositionRelativeToViewport("center", "center", "screen")

    local list = UI.List
    list:Clear()

    for _,entry in ipairs(entries) do
        UI.RenderEntry(entry)
    end

    UI.List:RepositionElements()
    UI:GetUI().Layer = SettingsMenu:GetUI():GetUI().Layer + 1
    SettingsMenu:GetUI():SetFlag("OF_PlayerModal1", false)
    UI:Show()

    GameState.Events.RunningTick:Subscribe(function (_)
        if not SettingsMenu:GetUI():IsVisible() then

            Overlay.Close()
            GameState.Events.RunningTick:Unsubscribe("SettingsMenuOverlay")
        end
    end, {StringID = "SettingsMenuOverlay"})
end

---Closes the overlay.
function Overlay.Close()
    SettingsMenu:GetUI():SetFlag("OF_PlayerModal1", true)
    Client.Tooltip.HideTooltip()
    UI:Hide()
end

---Renders an entry.
---@param entry Feature_SettingsMenu_Entry
---@param parent GenericUI_ParentIdentifier? Defaults to the main list.
function UI.RenderEntry(entry, parent)
    local canRender = Overlay.Hooks.CanRenderEntry:Throw({
        Entry = entry,
        CanRender = true,
    }).CanRender

    if canRender then
        Overlay.Events.RenderEntry:Throw({
            Entry = entry,
            Parent = parent or UI.List,
        })
    end
end

---Repositions elements within the main list.
function UI._RepositionEntries()
    UI.List:RepositionElements()
end

---Creates the core elements of the UI, if not already initialized.
function Overlay._Initialize()
    if not UI._Initialized then
        local root = UI:CreateElement("UIRoot", "GenericUI_Element_Empty")
        root:SetPosition(665, 145) -- Needs to be done in UI space.
        -- root:SetColor(Color.Create(120, 0, 0))
        -- root:SetSize(UI.LIST_SIZE:unpack())

        local list = root:AddChild("ScrollList", "GenericUI_Element_ScrollList")
        list:SetFrame(UI.LIST_SIZE:unpack())
        list:SetScrollbarSpacing(-30)
        list:SetMouseWheelEnabled(true)
        list:SetRepositionAfterAdding(false)
        UI.List = list

        UI._Initialized = true
    end
end

---Renders a Set setting.
---@param setting Feature_SettingsMenu_Setting_Set
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI_Prefab_FormSet
function UI._RenderSet(setting, parent)
    local element = SetPrefab.Create(UI, setting:GetNamespacedID(), parent, setting:GetName(), UI.FORM_ELEMENT_SIZE)

    -- Listen for add/remove events and update the setting.
    -- This is a little bit flawed as it does not set the changes as pending. TODO
    element.Events.EntryAdded:Subscribe(function (ev)
        local set = setting:GetValue() ---@type DataStructures_Set
        set:Add(ev.Value)
        element:RenderFromSetting(setting)
        UI._RepositionEntries()
        Settings.Save(setting.ModTable)
    end)
    element.Events.EntryRemoved:Subscribe(function (ev)
        local set = setting:GetValue() ---@type DataStructures_Set
        set:Remove(ev.Value)
        element:RenderFromSetting(setting)
        UI._RepositionEntries()
        Settings.Save(setting.ModTable)
    end)

    -- Show skill tooltips.
    if setting.ElementsAreSkills then
        element.Events.EntryElementCreated:Subscribe(function (ev)
            local entry = ev.Element
            entry:SetTooltip("Skill", entry:GetLabel())
        end)
    end

    element:RenderFromSetting(setting)

    return element
end

---Renders a Choice setting.
---@param setting SettingsLib_Setting_Choice
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI_Prefab_LabelledDropdown
function UI._RenderChoice(setting, parent)
    -- Generate combobox options from setting choices.
    local options = {}
    for _,choice in ipairs(setting.Choices) do
        table.insert(options, {
            ID = choice.ID,
            Label = choice:GetName(),
        })
    end

    local dropdown = DropdownPrefab.Create(UI, setting:GetNamespacedID(), parent, setting:GetName(), options)
    dropdown:SetSize(UI.FORM_ELEMENT_SIZE:unpack())
    dropdown:SelectOption(setting:GetValue())

    dropdown.Events.OptionSelected:Subscribe(function (ev)
        SettingsMenu.SetPendingChange(setting, ev.Option.ID)
    end)

    return dropdown
end

---Renders a Boolean setting.
---@param setting SettingsLib_Setting_Boolean
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI_Prefab_LabelledCheckbox
function UI._RenderCheckbox(setting, parent)
    local element = CheckboxPrefab.Create(UI, setting:GetNamespacedID(), parent, setting:GetName())

    element:SetState(setting:GetValue() == true)
    element:SetSize(UI.FORM_ELEMENT_SIZE:unpack())

    element.Events.StateChanged:Subscribe(function (ev)
        SettingsMenu.SetPendingChange(setting, ev.Active)
    end)

    return element
end

---Renders a ClampedNumber setting.
---@param setting Feature_SettingsMenu_Setting_Slider
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI_Prefab_LabelledSlider
function UI._RenderClampedNumber(setting, parent)
    local element = SliderPrefab.Create(UI, setting:GetNamespacedID(), parent, UI.FORM_ELEMENT_SIZE, setting:GetName(), setting.Min, setting.Max, setting.Step or 1)

    element:SetValue(setting:GetValue())

    element.Events.HandleReleased:Subscribe(function (ev)
        SettingsMenu.SetPendingChange(setting, ev.Value)
    end)

    return element
end

---Renders a InputBinding setting.
---@param setting SettingsLib.Settings.InputBinding
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI.Prefabs.FormTextHolder
function UI._RenderInputBinding(setting, parent)
    local instance = SettingWidgets.RenderSetting(UI, parent, setting, UI.FORM_ELEMENT_SIZE, function (value)
        SettingsMenu.SetPendingChange(setting, value)
    end)
    ---@cast instance GenericUI.Prefabs.FormTextHolder
    return instance
end

---Renders a Text setting.
---@param setting SettingsLib.Settings.InputBinding
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI_Prefab_LabelledTextField
function UI._RenderStringSetting(setting, parent)
    local instance = SettingWidgets.RenderSetting(UI, parent, setting, UI.FORM_ELEMENT_SIZE, function (value)
        SettingsMenu.SetPendingChange(setting, value)
    end)
    ---@cast instance GenericUI_Prefab_LabelledTextField
    return instance
end

---Renders a label entry.
---@param data Feature_SettingsMenuOverlay_Event_RenderEntry
---@return GenericUI_Prefab_Text
function UI._RenderLabel(data)
    local entry = data.Entry ---@cast entry Feature_SettingsMenu_Entry_Label
    local element = TextPrefab.Create(UI, Text.GenerateGUID(), data.Parent, entry.Label, "Center", UI.DEFAULT_LABEL_SIZE)
    element:SetSize(UI.DEFAULT_LABEL_SIZE[1], element:GetTextSize()[2]) -- Resize to text height.

    return element
end

---Renders a button entry.
---@param data Feature_SettingsMenuOverlay_Event_RenderEntry
---@return GenericUI_Element_Button
function UI._RenderButton(data)
    local entry = data.Entry ---@type Feature_SettingsMenu_Entry_Button
    local element = UI:CreateElement(entry.ID, "GenericUI_Element_Button", data.Parent)

    element:SetType("RedBig")
    element:SetCenterInLists(true)
    element:SetText(entry.Label, 15)
    element:SetTooltip("Simple", entry.Tooltip)

    element.Events.Pressed:Subscribe(function (_)
        SettingsMenu.Events.ButtonPressed:Throw({
            Tab = SettingsMenu.GetTab(SettingsMenu.currentTabID),
            ButtonID = entry.ID
        })
    end)

    return element
end

---Renders a category of settings.
---@param data Feature_SettingsMenuOverlay_Event_RenderEntry
---@return GenericUI_Prefab_Selector
function UI._RenderCategory(data)
    local entry = data.Entry ---@type Feature_SettingsMenu_Entry_Category
    local options = {}
    for i,option in ipairs(entry.Options) do
        options[i] = option.Label
    end

    local element = SelectorPrefab.Create(UI, entry.ID, UI.List, entry.Label, UI.FORM_ELEMENT_SIZE, options)

    -- Create sub-elements
    for i,option in ipairs(entry.Options) do
        local container = element:GetSubElementContainer(i)
        container:SetRepositionAfterAdding(false)

        for _,subEntry in ipairs(option.SubEntries) do
            UI.RenderEntry(subEntry, container)
        end

        container:RepositionElements()
    end

    -- When the option changes, we need to reposition the main list,
    -- as the new contents might clip into entries below the selector.
    element.Events.Updated:Subscribe(function (_)
        UI._RepositionEntries()
    end)

    return element
end

---Renders a setting entry.
---@param data Feature_SettingsMenuOverlay_Event_RenderEntry
---@return GenericUI_Prefab_FormElement
function UI._RenderSetting(data)
    local entry = data.Entry ---@type Feature_SettingsMenu_Entry_Setting
    local parent = data.Parent
    local setting = Settings.GetSetting(entry.Module, entry.ID) ---@type Feature_SettingsMenu_Setting
    local settingType = setting.Type
    local element ---@type GenericUI_Prefab_FormElement

    if settingType == "Set" then
        element = UI._RenderSet(setting, parent)
    elseif settingType == "Boolean" then
        element = UI._RenderCheckbox(setting, parent)
    elseif settingType == "Choice" then
        element = UI._RenderChoice(setting, parent)
    elseif settingType == "ClampedNumber" then
        element = UI._RenderClampedNumber(setting, parent)
    elseif settingType == "InputBinding" then
        element = UI._RenderInputBinding(setting, parent)
    elseif settingType == "String" then
        element = UI._RenderStringSetting(setting, parent)
    else
        Overlay:LogWarning("Unsupported setting type: " .. settingType)
    end

    if element then
        ---@type TooltipLib_SimpleTooltip
        local tooltip = {
            Label = setting:GetDescription(),
            TooltipStyle = "Simple",
            MouseStickMode = "BottomRight",
            UseDelay = true,
        }
        element:SetCenterInLists(true)
        element:SetTooltip("Simple", tooltip)
    end

    return element
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Prevent developer entries from rendering outside of developer mode.
Overlay.Hooks.CanRenderEntry:Subscribe(function (ev)
    local entry = ev.Entry
    if entry.Type == "Setting" then
        ---@cast entry Feature_SettingsMenu_Entry_Setting
        local setting = Settings.GetSetting(entry.Module, entry.ID) ---@cast setting Feature_SettingsMenu_Setting

        if (setting.DeveloperOnly and not Epip.IsDeveloperMode()) or setting.Visible == false then
            ev.CanRender = false
        end

        -- Don't render settings when their required mods are missing
        ev.CanRender = ev.CanRender and SettingsMenu.AreRequiredModsEnabled(setting)
    end
end)

-- Listen for entry render requests.
Overlay.Events.RenderEntry:Subscribe(function (ev)
    local entry = ev.Entry
    local entryType = entry.Type
    local element ---@type GenericUI_Element

    if entryType == "Setting" then
        UI._RenderSetting(ev) -- Centering and such is handled within the method, return is discarded
    elseif entryType == "Label" then
        element = UI._RenderLabel(ev)
    elseif entryType == "Button" then
        element = UI._RenderButton(ev)
    elseif entryType == "Category" then
        element = UI._RenderCategory(ev)
    else
        Overlay:LogWarning("Unsupported entry type: " .. entry.Type)
    end

    if element then
        element:SetCenterInLists(true)
    end
end)

-- Hijack the original render request event.
SettingsMenu.Hooks.GetTabEntries:Subscribe(function (ev)
    local hasCustomElements = false

    for _,entry in ipairs(ev.Entries) do
        if entry.Type == "Setting" then
            entry = entry ---@type Feature_SettingsMenu_Entry_Setting
            local setting = Settings.GetSetting(entry.Module, entry.ID) ---@type Feature_SettingsMenu_Setting

            if not Overlay.ORIGINAL_SETTING_TYPES:Contains(setting.Type) then
                hasCustomElements = true
                break
            end
        end
    end

    Overlay:DebugLog("Tab has custom entries:", hasCustomElements)
    if hasCustomElements or Overlay._ALWAYS_USE then
        Overlay.Setup(ev.Entries)
        ev.Entries = {}
    else
        Overlay.Close()
    end
end)