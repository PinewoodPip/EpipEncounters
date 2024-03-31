
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
local Generic = Client.UI.Generic
local MsgBox = Client.UI.MessageBox
local Set = DataStructures.Get("DataStructures_Set")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local SetPrefab = Generic.GetPrefab("GenericUI_Prefab_FormSet")
local SelectorPrefab = Generic.GetPrefab("GenericUI_Prefab_Selector")
local CloseButton = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local CommonStrings = Text.CommonStrings
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
UI.PANELS_Y = 37
-- Different from the vibgyor rainbow for contrast reasons.
UI._RAINBOW_COLORS = {
    "DB5ED3",
    "B956E3",
    "5171BD",
    Color.VIBGYOR_RAINBOW[4],
    Color.VIBGYOR_RAINBOW[5],
    Color.VIBGYOR_RAINBOW[6],
    "DE3E3E",
}
UI._RAINBOW_TEXT_CYCLE_TIME = 3.5 -- In seconds.

---------------------------------------------
-- STYLES
---------------------------------------------

---@type GenericUI_Prefab_Button_Style
UI.LARGE_BUTTON_STYLE = table.shallowCopy(ButtonPrefab:GetStyle("LargeRed"))
UI.LARGE_BUTTON_STYLE.Sound = "UI_Gen_Accept" -- UI_Gen_Apply maps to the same sound.

---@type GenericUI_Prefab_Button_Style
UI.TAB_BUTTON_STYLE_INACTIVE = table.shallowCopy(ButtonPrefab:GetStyle("TransparentLargeDark"))
UI.TAB_BUTTON_STYLE_INACTIVE.Sound = "UI_Gen_BigButton_Click"

---@type GenericUI_Prefab_Button_Style
UI.TAB_BUTTON_STYLE_ACTIVE = table.shallowCopy(ButtonPrefab:GetStyle("LargeRedWithArrows"))
UI.TAB_BUTTON_STYLE_ACTIVE.Sound = "UI_Gen_BigButton_Click"

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
---@param tab Feature_SettingsMenu_Tab
---@param entries Feature_SettingsMenu_Entry[]
function Overlay.Setup(tab, entries)
    Overlay._Initialize()

    -- Resize and reposition the overlay to match the regular menu
    local settingsUIObject = SettingsMenu:GetUI():GetUI()
    local uiObject = UI:GetUI()
    uiObject:Resize(settingsUIObject.FlashMovieSize[1], settingsUIObject.FlashMovieSize[2], settingsUIObject:GetUIScaleMultiplier())
    uiObject.SysPanelSize = settingsUIObject.SysPanelSize
    UI:SetPositionRelativeToViewport("center", "center", "screen")

    local list = UI.List
    list:Clear()

    -- Render tab buttons
    local tabButtonsList = UI.TabButtonsList
    tabButtonsList:Clear()
    for i,id in ipairs(SettingsMenu.TabRegistrationOrder) do
        local registeredTab = SettingsMenu.GetTab(id)
        if SettingsMenu.CanRenderTabButton(registeredTab) then
            local button = ButtonPrefab.Create(UI, "TabButton." .. registeredTab.ID, tabButtonsList, UI.TAB_BUTTON_STYLE_INACTIVE)
            button:SetActiveStyle(UI.TAB_BUTTON_STYLE_ACTIVE)
            button:SetActivated(SettingsMenu.IsTabOpen(id))
            button:SetLabel(registeredTab.ButtonLabel)

            -- Switch the tab when the button is pressed.
            button.Events.Pressed:Subscribe(function (_)
                SettingsMenu.SetActiveTab(id)
            end)

            SettingsMenu.tabButtonToTabID[i] = id -- TODO remove
        end
    end

    for _,entry in ipairs(entries) do
        UI.RenderEntry(entry)
    end

    UI.TabHeader:SetText(Text.Format(tab.HeaderLabel:upper(), {Size = 22, FontType = Text.FONTS.BOLD}))

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
        local root = UI:CreateElement("Root", "GenericUI_Element_Empty")

        local leftPanel = root:AddChild("LeftPanel", "GenericUI_Element_Texture")
        leftPanel:SetTexture(Textures.PANELS.SETTINGS_LEFT)
        leftPanel:SetPosition(291, UI.PANELS_Y)
        UI.LeftPanel = leftPanel

        local tabButtonsList = leftPanel:AddChild("TabButtonsList", "GenericUI_Element_ScrollList")
        tabButtonsList:SetFrame(360, 900)
        tabButtonsList:SetMouseWheelEnabled(true)
        tabButtonsList:SetScrollbarSpacing(-371)
        tabButtonsList:SetPosition(0, 120)
        UI.TabButtonsList = tabButtonsList

        -- Hide the scrollbar background
        local tabButtonstListScrollBg = tabButtonsList:GetMovieClip().list.m_scrollbar_mc.m_bg_mc
        if tabButtonstListScrollBg then
            tabButtonstListScrollBg.visible = false
        end

        local rightPanel = root:AddChild("RightPanel", "GenericUI_Element_Texture")
        rightPanel:SetTexture(Textures.PANELS.SETTINGS_RIGHT)
        rightPanel:SetPosition(641, UI.PANELS_Y)
        UI.RightPanel = rightPanel

        local tabButtonsHeader = TextPrefab.Create(UI, "TabButtonsHeader", leftPanel, SettingsMenu.TranslatedStrings.MenuButton:Format({Size = 22, FontType = Text.FONTS.BOLD, Casing = "Uppercase"}), "Center", V(200, 50))
        tabButtonsHeader:SetPositionRelativeToParent("Top", 0, 40)

        local tabHeader = TextPrefab.Create(UI, "TabHeader", rightPanel, "", "Center", V(200, 50))
        tabHeader:SetPositionRelativeToParent("Top", 0, 40)
        UI.TabHeader = tabHeader

        -- Create buttons at the bottom of the right panel
        local bottomButtonsList = rightPanel:AddChild("BottomButtonsList", "GenericUI_Element_HorizontalList")
        bottomButtonsList:SetElementSpacing(10)

        local acceptButton = ButtonPrefab.Create(UI, "AcceptButton", bottomButtonsList, UI.LARGE_BUTTON_STYLE)
        acceptButton:SetLabel(CommonStrings.Accept:Format({Casing = "Uppercase"}))
        acceptButton.Events.Pressed:Subscribe(function (_)
            if SettingsMenu.HasPendingChanges() then
                Overlay._ShowPendingChangesPrompt()
            else
                SettingsMenu.Close()
            end
        end)

        local applyButton = ButtonPrefab.Create(UI, "ApplyButton", bottomButtonsList, UI.LARGE_BUTTON_STYLE)
        applyButton:SetLabel(CommonStrings.Apply:Format({Casing = "Uppercase"}))
        applyButton.Events.Pressed:Subscribe(function (_)
            SettingsMenu.ApplyPendingChanges()
        end)

        bottomButtonsList:SetPositionRelativeToParent("Bottom", 0, -44)

        local closeButton = CloseButton.Create(UI, "CloseButton", rightPanel)
        closeButton:SetPositionRelativeToParent("TopRight", -20, 22)
        closeButton.Events.Pressed:Subscribe(function (_)
            -- Show the pending changes prompt if there are any
            if SettingsMenu.HasPendingChanges() then
                Overlay._ShowPendingChangesPrompt()
            else -- Otherwise close the UI
                SettingsMenu.Close()
            end
        end)
        -- Prevent the close button from hiding the UI if there are pending changes
        closeButton.Hooks.CanClose:Subscribe(function (ev)
            ev.CanClose = not SettingsMenu.HasPendingChanges()
        end)

        local settingsRoot = root:AddChild("SettingsRoot", "GenericUI_Element_Empty")
        settingsRoot:SetPosition(665, 145) -- Needs to be done in UI space.
        -- root:SetColor(Color.Create(120, 0, 0))
        -- root:SetSize(UI.LIST_SIZE:unpack())

        local list = settingsRoot:AddChild("ScrollList", "GenericUI_Element_ScrollList")
        list:SetFrame(UI.LIST_SIZE:unpack())
        list:SetScrollbarSpacing(-30)
        list:SetMouseWheelEnabled(true)
        list:SetRepositionAfterAdding(false)
        UI.List = list

        UI._SetupBuildLabel()

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
---@return GenericUI_I_Elementable
function UI._RenderChoice(setting, parent)
    local element = SettingWidgets.RenderSetting(UI, parent, setting, UI.FORM_ELEMENT_SIZE, function (value)
        SettingsMenu.SetPendingChange(setting, value)
    end, false)

    return element
end

---Renders a Boolean setting.
---@param setting SettingsLib_Setting_Boolean
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI_I_Elementable
function UI._RenderCheckbox(setting, parent)
    local element = SettingWidgets.RenderSetting(UI, parent, setting, UI.FORM_ELEMENT_SIZE, function (value)
        SettingsMenu.SetPendingChange(setting, value)
    end, false)

    return element
end

---Renders a ClampedNumber setting.
---@param setting Feature_SettingsMenu_Setting_Slider
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI_I_Elementable
function UI._RenderClampedNumber(setting, parent)
    local element = SettingWidgets.RenderSetting(UI, parent, setting, UI.FORM_ELEMENT_SIZE, function (value)
        SettingsMenu.SetPendingChange(setting, value)
    end, false)

    return element
end

---Renders a InputBinding setting.
---@param setting SettingsLib.Settings.InputBinding
---@param parent GenericUI_ParentIdentifier?
---@return GenericUI.Prefabs.FormTextHolder
function UI._RenderInputBinding(setting, parent)
    local instance = SettingWidgets.RenderSetting(UI, parent, setting, UI.FORM_ELEMENT_SIZE, function (value)
        SettingsMenu.SetPendingChange(setting, value)
    end, false)
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
    end, false)
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

    local element = SelectorPrefab.Create(UI, entry.ID, data.Parent, entry.Label, UI.FORM_ELEMENT_SIZE, options)

    -- Create sub-elements
    for i,option in ipairs(entry.Options) do
        local container = element:GetSubElementContainer(i)
        container:SetRepositionAfterAdding(false)

        for _,subEntry in ipairs(option.SubEntries) do
            UI.RenderEntry(subEntry, container)
        end

        container:RepositionElements()
    end
    element:UpdateSelection() -- Necessary after adding elements to the category lists.

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

---Creates the build info label, showing the version and build date.
function UI._SetupBuildLabel()
    local buildInfo = IO.LoadFile("Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/buildmeta.json", "data")
    if buildInfo then
        local text = Text.Format("Epip v%s\n@ %s UTC+1", {
            FormatArgs = {Epip.VERSION, buildInfo.Date}
        })
        local buildLabel = TextPrefab.Create(UI, "BuildLabel", UI.LeftPanel, text, "Center", V(250, 100))
        buildLabel:SetPositionRelativeToParent("Bottom", 0, -10)

        -- Animate text color into a rainbow when it is Pip's birthday or April Fools.
        if Epip.IsPipBirthday() or Epip.IsAprilFools() then
            local currentTime = 0
            local colors = UI._RAINBOW_COLORS
            local colorStages = #colors
            local stageTime = UI._RAINBOW_TEXT_CYCLE_TIME / colorStages

            GameState.Events.Tick:Subscribe(function (ev)
                local currentStage = math.indexmodulo((math.floor(currentTime / stageTime) + 1), colorStages)
                local currentStageTime = currentTime % stageTime
                local currentColor = colors[currentStage]
                local nextColor = colors[math.indexmodulo(currentStage + 1, colorStages)]
                local interpolatedColor = Color.Lerp(Color.Create(currentColor), Color.Create(nextColor), currentStageTime / stageTime)

                currentTime = currentTime + ev.DeltaTime / 1000

                buildLabel:SetText(Text.Format(text, {
                    Color = interpolatedColor:ToHex(),
                }))
            end, {EnabledFunctor = function ()
                return UI:IsVisible()
            end})
        end
    end
end

---Shows a prompt requesting the user to confirm changes made to settings.
function Overlay._ShowPendingChangesPrompt()
    MsgBox.Open({
        Header = SettingsMenu.TranslatedStrings.MsgBox_ConfirmPendingChanges_Header:GetString(),
        Message = SettingsMenu.TranslatedStrings.MsgBox_ConfirmPendingChanges_Body:GetString(),
        ID = "Feature_SettingsMenu_UnsavedChanges",
        Buttons = {
            {ID = 1, Text = CommonStrings.Save:GetString()},
            {ID = 2, Text = CommonStrings.Exit:GetString()},
        }
    })
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
        Overlay.Setup(ev.Tab, ev.Entries)
        ev.Entries = {}
    else
        Overlay.Close()
    end
end)

-- Listen for the "Save pending changes?" prompt being confirmed.
MsgBox.RegisterMessageListener("Feature_SettingsMenu_UnsavedChanges", MsgBox.Events.ButtonPressed, function (buttonID, _)
    if buttonID == 1 then
        SettingsMenu.ApplyPendingChanges()
    end

    SettingsMenu.Close()
end)
