
local Settings = Settings
local OptionsSettings = Client.UI.OptionsSettings

---@class Feature_SettingsMenu : Feature
local Menu = {
    UI_ID = "EPIP_SettingsMenu",
    TAB_BUTTON_ID = 1337,
    UI = nil, ---@type UI

    Tabs = {}, ---@type table<string, Feature_SettingsMenu_Tab>
    TabRegistrationOrder = {}, ---@type string[]
    currentTabID = nil,
    currentElements = {}, ---@type table<Feature_SettingsMenu_ElementID, Feature_SettingsMenu_Entry>
    nextElementNumID = 1, ---@type Feature_SettingsMenu_ElementID
    tabButtonToTabID = {}, ---@type table<integer, string>
    pendingChanges = {}, ---@type table<string, any>
    categoryStateIndexes = {},

    _initializedUI = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        RenderSetting = {}, ---@type Event<Feature_SettingsMenu_Event_RenderSetting>
        ChangesApplied = {}, ---@type Event<Feature_SettingsMenu_Event_ChangesApplied>
        ButtonPressed = {}, ---@type Event<Feature_SettingsMenu_Event_ButtonPressed>
    },
    Hooks = {
        GetTabEntries = {}, ---@type Event<Feature_SettingsMenu_Hook_GetTabEntries>
        CanRenderTabButton = {}, ---@type Event<Feature_SettingsMenu_Hook_CanRenderTabButton>
    }
}
Epip.RegisterFeature("SettingsMenu", Menu)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Feature_SettingsMenu_ElementID integer

---@class Feature_SettingsMenu_Tab
---@field ID string
---@field ButtonLabel string
---@field HeaderLabel string
---@field HostOnly boolean? Defaults to false.
---@field DeveloperOnly boolean? Defaults to false.
---@field Entries Feature_SettingsMenu_Entry[]

---@class Feature_SettingsMenu_Entry
---@field Type "Setting"|"Label"|"Button"|"Category"

---@class Feature_SettingsMenu_Entry_Label : Feature_SettingsMenu_Entry
---@field Label string

---@class Feature_SettingsMenu_Entry_Setting : Feature_SettingsMenu_Entry
---@field Module string
---@field ID string

---@class Feature_SettingsMenu_Entry_Button : Feature_SettingsMenu_Entry_Label
---@field ID string
---@field Tooltip string
---@field SoundOnUp string

---@class Feature_SettingsMenu_Entry_Category_Option
---@field ID any Defaults to index.
---@field Label string
---@field SubEntries Feature_SettingsMenu_Entry[]

---@class Feature_SettingsMenu_Entry_Category : Feature_SettingsMenu_Entry
---@field Label string
---@field ID string
---@field Options Feature_SettingsMenu_Entry_Category_Option[]

---@class Feature_SettingsMenu_Setting : SettingsLib_Setting
---@field Visible boolean? Defaults to true.
---@field DeveloperOnly boolean? Defaults to false.

---@class Feature_SettingsMenu_Setting_Set : SettingsLib_Setting_Set
---@field ElementsAreSkills boolean? If `true`, elements will show skill tooltips.

---@class Feature_SettingsMenu_Setting_Slider : Feature_SettingsMenu_Setting, SettingsLib_Setting_ClampedNumber
---@field Step number
---@field HideNumbers boolean? Defaults to false.

---@class Feature_SettingsMenu_Setting_ComboBox : Feature_SettingsMenu_Setting, SettingsLib_Setting_Choice

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_SettingsMenu_Event_RenderSetting
---@field Setting Feature_SettingsMenu_Setting
---@field ElementID Feature_SettingsMenu_ElementID

---@class Feature_SettingsMenu_Event_ChangesApplied
---@field Changes table<string, table<string, any>> Changes made. First index is module, second index is setting ID.

---@class Feature_SettingsMenu_Event_ButtonPressed
---@field Tab Feature_SettingsMenu_Tab
---@field ButtonID string

---@class Feature_SettingsMenu_Hook_GetTabEntries
---@field Tab Feature_SettingsMenu_Tab
---@field Entries Feature_SettingsMenu_Entry[] Hookable.

---@class Feature_SettingsMenu_Hook_CanRenderTabButton
---@field Tab Feature_SettingsMenu_Tab
---@field Render boolean Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_SettingsMenu_Tab
---@param renderOrderIndex integer?
function Menu.RegisterTab(data, renderOrderIndex)
    Menu.Tabs[data.ID] = data
    
    table.insert(Menu.TabRegistrationOrder, renderOrderIndex or #Menu.TabRegistrationOrder + 1, data.ID)
end

---@param id string
---@return Feature_SettingsMenu_Tab
function Menu.GetTab(id)
    return Menu.Tabs[id]
end

---@param tab Feature_SettingsMenu_Tab
function Menu.CanRenderTabButton(tab)
    local render = true

    render = render and (not tab.HostOnly or Client.IsHost())
    render = render and (not tab.DeveloperOnly or Epip.IsDeveloperMode())

    return Menu.Hooks.CanRenderTabButton:Throw({Tab = tab, Render = render}).Render
end

---@return Feature_SettingsMenu_Tab?
function Menu.GetCurrentTab()
    return Menu.currentTabID and Menu.GetTab(Menu.currentTabID)
end

---@param tabID string
---@return boolean
function Menu.IsTabOpen(tabID)
    local currentTab = Menu.GetCurrentTab()

    return currentTab and currentTab.ID == tabID
end

function Menu.RenderTabButtons()
    local UI = Menu.GetUI()
    local root = UI:GetRoot()

    root.mainMenu_mc.menuBtnList.clearElements()

    for i,id in ipairs(Menu.TabRegistrationOrder) do
        local tab = Menu.GetTab(id)

        if Menu.CanRenderTabButton(tab) then
            Menu.tabButtonToTabID[i] = id
            
            root.mainMenu_mc.addOptionButton(tab.ButtonLabel, "EPIP_TabClicked", i, Menu.IsTabOpen(id))
        end
    end
end

---@param setting Feature_SettingsMenu_Setting
---@param value any
function Menu.SetPendingChange(setting, value)
    if not Menu.pendingChanges[setting.ModTable] then
        Menu.pendingChanges[setting.ModTable] = {}
    end

    Menu.pendingChanges[setting.ModTable][setting.ID] = value

    Menu:DebugLog("Pending change set:", setting.ModTable, setting.ID, value)
end

function Menu.ApplyPendingChanges()
    Menu:DebugLog("Applying pending changes")

    for moduleID,changes in pairs(Menu.pendingChanges) do
        for settingID,value in pairs(changes) do
            Menu:DebugLog("Set value of", settingID, "to", value)
            Settings.SetValue(moduleID, settingID, value)
        end

        Settings.Save(moduleID)
    end

    Menu.Events.ChangesApplied:Throw({
        Changes = Menu.pendingChanges,
    })

    Menu.pendingChanges = {}
end

function Menu._Setup()
    -- Render tab contents
    -- Defaults to first tab registered (if any!)
    if Menu.currentTabID or #Menu.TabRegistrationOrder > 0 then
        local tab = Menu.GetTab(Menu.currentTabID or Menu.TabRegistrationOrder[1])

        Menu.RenderSettings(tab)
    end

    -- Render tab buttons
    Menu.RenderTabButtons()
end

---@param tab Feature_SettingsMenu_Tab
function Menu.RenderSettings(tab)
    local UI = Menu.GetUI()
    local root = UI:GetRoot()
    Menu.nextElementNumID = 1
    Menu.currentElements = {}
    root.removeItems()

    Menu.currentTabID = tab.ID

    Menu:DebugLog("Rendering tab", tab.ID)

    local entries = Menu.Hooks.GetTabEntries:Throw({
        Tab = tab,
        Entries = table.deepCopy(tab.Entries),
    }).Entries
    for _,entry in ipairs(entries) do
        Menu.RenderEntry(entry)
    end

    root.mainMenu_mc.setTitle(tab.HeaderLabel or tab.ID)

    -- TODO fire tabrendered
end

---@param entry Feature_SettingsMenu_Entry
---@return Feature_SettingsMenu_ElementID
function Menu.RenderEntry(entry)
    local numID

    if entry.Type == "Setting" then
        entry = entry ---@type Feature_SettingsMenu_Entry_Setting
        local setting = Settings.GetSetting(entry.Module, entry.ID) ---@type Feature_SettingsMenu_Setting
        
        if setting then
            numID = Menu.RenderSetting(setting)
        else
            Menu:LogError("Tried to render setting that doesn't exist " .. entry.Module .. " " .. entry.ID)
        end
    elseif entry.Type == "Category" then
        entry = entry ---@type Feature_SettingsMenu_Entry_Category
        numID = Menu.nextElementNumID
        Menu.nextElementNumID = Menu.nextElementNumID + 1

        Menu._RenderCategory(entry, numID)
    elseif entry.Type == "Label" then
        numID = Menu.nextElementNumID
        Menu.nextElementNumID = Menu.nextElementNumID + 1

        Menu._RenderLabel(entry, numID)
    elseif entry.Type == "Button" then
        numID = Menu.nextElementNumID
        Menu.nextElementNumID = Menu.nextElementNumID + 1

        Menu._RenderButton(entry, numID)
    end

    if numID then
        Menu.currentElements[numID] = entry
    else
        Menu:DebugLog("Entry render not processed:")
        Menu:Dump(entry)
    end

    return numID
end

---@param setting Feature_SettingsMenu_Setting
---@return Feature_SettingsMenu_ElementID
function Menu.RenderSetting(setting)
    local numID = Menu.nextElementNumID
    Menu.nextElementNumID = Menu.nextElementNumID + 1

    Menu:DebugLog("Rendering setting", setting.ID)

    -- TODO register dynamic settings?

    -- Host-only settings are only shown for host
    -- TODO server settings
    if (setting.Context ~= "Host" and setting.Context ~= "Server") or Client.IsHost() then
        Menu.Events.RenderSetting:Throw({
            Setting = setting,
            ElementID = numID,
        })

        -- TODO selectors
    else
        numID = nil -- Don't associate the setting to the numID.
    end

    return numID
end

---@param elementID Feature_SettingsMenu_ElementID
---@param setting Feature_SettingsMenu_Setting
---@param state any
function Menu.SetSettingElementState(elementID, setting, state)
    local root = Menu.GetUI():GetRoot()

    -- TODO extract methods
    if setting.Type == "Choice" then
        root.mainMenu_mc.selectMenuDropDownEntry(elementID, state - 1) -- Converting from 1-based to 0-based index
    else
        Menu:LogError("Setting element state for settings of type " .. setting.Type .. " is not supported!")
    end
end

---@param elementID Feature_SettingsMenu_ElementID
---@param state any
---@param entry Feature_SettingsMenu_Entry
function Menu.SetElementState(elementID, state, entry)
    entry = entry or Menu.currentElements[elementID]
    local root = Menu.GetUI():GetRoot()

    if entry then
        local entryType = entry.Type

        if entryType == "Setting" then
            entry = entry ---@type Feature_SettingsMenu_Entry_Setting
            local setting = Settings.GetSetting(entry.Module, entry.ID)

            Menu.SetSettingElementState(elementID, setting, state)
        elseif entryType == "Category" then
            root.mainMenu_mc.setSelector(elementID, state - 1, true)
        else
            Menu:LogError("Setting element state for entries of type " .. entryType .. " is not supported!")
        end
    else
        Menu:LogError("Tried to set state of element that doesn't exist")
    end
end

---@return UI
function Menu.GetUI()
    local ui

    if not Menu._initializedUI then
        ui = {
            ID = Menu.UI_ID,
            PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/optionsSettings.swf", -- TODO expose
        }
        Ext.UI.Create(ui.ID, ui.PATH, 20)

        Epip.InitializeUI(nil, Menu.UI_ID, ui)

        Menu.UI = ui
        Menu._initializedUI = true
    end

    return Menu.UI
end

function Menu.Open()
    local ui = Menu.GetUI()

    ui:SetFlag("OF_PlayerModal1", true)
    ui:SetFlag("OF_PauseRequest", true)

    Menu._Setup()

    -- Needs a delay, else the engine cleans up the UI due to the real settings menu hiding.
    Ext.OnNextTick(function ()
        Client.UI.Fade.FadeIn(0)
    end)

    ui:Show()
end

function Menu.Close()
    local ui = Menu.GetUI()

    Menu.categoryStateIndexes = {}

    Client.UI.Fade.FadeOut()

    ui:Hide()
end

---@return boolean
function Menu.HasPendingChanges()
    return not table.isempty(Menu.pendingChanges)
end

---@param elementID Feature_SettingsMenu_ElementID
---@return Feature_SettingsMenu_Setting
function Menu.GetElementSetting(elementID)
    local entry = Menu.currentElements[elementID]
    local setting

    if entry and entry.Type == "Setting" then
        entry = entry ---@type Feature_SettingsMenu_Entry_Setting
        setting = Settings.GetSetting(entry.Module, entry.ID) ---@type Feature_SettingsMenu_Setting
    end

    return setting
end

---@param element Feature_SettingsMenu_Setting|Feature_SettingsMenu_ElementID|Feature_SettingsMenu_Entry
function Menu.IsElementEnabled(element)
    -- ID overload.
    if type(element) ~= "table" then
        element = Menu.GetElementSetting(element)
    end

    -- TODO

    return true
end

---@param tabID string
function Menu.SetActiveTab(tabID)
    Menu.currentTabID = tabID
    
    Menu:DebugLog("Switching tab to", tabID)

    -- Clear pending changes
    Menu.pendingChanges = {}

    if Menu.GetUI():IsVisible() then
        Menu._Setup()
    end
end

---@param data Feature_SettingsMenu_Entry_Label
---@param numID Feature_SettingsMenu_ElementID
function Menu._RenderLabel(data, numID)
    -- TODO figure out why raw strings do not work
    if not Text.Contains(data.Label, "<font") then data.Label = Text.Format(data.Label, {Size = 19}) end

    local root = Menu.GetUI():GetRoot()
    root.mainMenu_mc.addMenuMultilineLabel(numID, data.Label)
    local element = Client.Flash.GetLastElement(root.mainMenu_mc.list.content_array)

    element.text_txt.x = 160
    element.autoSize = "center"
    element.text_txt.height = element.text_txt.textHeight
end

---@param entry Feature_SettingsMenu_Entry_Category
---@param numID Feature_SettingsMenu_ElementID
function Menu._RenderCategory(entry, numID)
    Menu._RenderSelector(entry, numID)

    -- Render sub-entries
    local currentOption = entry.Options[Menu.categoryStateIndexes[entry.ID]]
    for _,subEntry in ipairs(currentOption.SubEntries) do
        Menu.RenderEntry(subEntry)
    end
end

---@param data Feature_SettingsMenu_Entry_Category
---@param numID Feature_SettingsMenu_ElementID
function Menu._RenderSelector(data, numID)
    local root = Menu.GetUI():GetRoot()

    root.mainMenu_mc.addMenuSelector(numID, data.Label)
    local element = Client.Flash.GetLastElement(root.mainMenu_mc.list.content_array)
    element.title_txt.y = element.title_txt.y + 20
    element.heightOverride = element.height + 40
    element.formHL_mc.alpha = 0
    element.selectorData_mc.alpha = 0
    element.title_txt.mouseEnabled = false
    element = element.selection_mc
    element.hit_mc.alpha = 0

    element.y = element.y + 50
    element.x = 180
    element.hit_mc.mouseEnabled = false -- TODO

    element.LB_mc.x = 0
    element.text_txt.x = 0
    element.text_txt.mouseEnabled = false
    element.RB_mc.x = 550

    for i,option in ipairs(data.Options) do
        option.ID = option.ID or i
        root.mainMenu_mc.addSelectorOption(numID, i - 1, option.Label)
    end

    Menu.categoryStateIndexes[data.ID] = Menu.categoryStateIndexes[data.ID] or 1
    
    Menu.SetElementState(numID, Menu.categoryStateIndexes[data.ID], data)
end

---@param data Feature_SettingsMenu_Entry_Button
---@param elementID Feature_SettingsMenu_ElementID
function Menu._RenderButton(data, elementID)
    local root = Menu.GetUI():GetRoot()
    local enabled = Menu.IsElementEnabled(data)

    root.mainMenu_mc.addMenuButton(elementID, data.Label, data.SoundOnUp or "", enabled, data.Tooltip)
end

---@param setting Feature_SettingsMenu_Setting
---@param elementID Feature_SettingsMenu_ElementID
function Menu._RenderCheckbox(setting, elementID)
    local value = Settings.GetSettingValue(setting)
    local enabled = Menu.IsElementEnabled(setting)
    local stateId = 0

    if value then
        stateId = 1
    end

    Menu.GetUI():GetRoot().mainMenu_mc.addMenuCheckbox(elementID, setting:GetName(), enabled, stateId, 0, setting:GetDescription()) -- TODO filteredBool
end

---@param setting Feature_SettingsMenu_Setting_Slider
---@param elementID Feature_SettingsMenu_ElementID
function Menu._RenderSlider(setting, elementID)
    local root = Menu.GetUI():GetRoot()
    local value = Settings.GetSettingValue(setting.ModTable, setting.ID)

    root.mainMenu_mc.addMenuSlider(elementID, setting:GetName(), value, setting.Min, setting.Max, setting.Step, setting.HideNumbers, setting:GetDescription())

    local element = Client.Flash.GetLastElement(root.mainMenu_mc.list.content_array)
    element.label_txt.autoSize = "center"
end

---@param setting Feature_SettingsMenu_Setting_ComboBox
---@param elementID Feature_SettingsMenu_ElementID
function Menu._RenderComboBox(setting, elementID)
    local root = Menu.GetUI():GetRoot()

    root.mainMenu_mc.addMenuDropDown(elementID, setting:GetName(), setting:GetDescription())

    for _,choice in ipairs(setting.Choices) do
        root.mainMenu_mc.addMenuDropDownEntry(elementID, choice:GetName())
    end

    -- TODO set enabled
    Menu.SetSettingElementState(elementID, setting, setting:GetChoiceIndex(setting:GetValue()))
end

function Menu._ShowPendingChangesPrompt()
    Client.UI.MessageBox.Open({
        Header = "Unsaved Changes",
        Message = "You have unsaved changes. Do you wish to apply them?",
        ID = "Feature_SettingsMenu_UnsavedChanges",
        Buttons = {
            {ID = 1, Text = "Save"},
            {ID = 2, Text = "Exit"},
        }
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local UI = Menu.GetUI()

-- Listen for tabs being switched.
UI:RegisterCallListener("EPIP_TabClicked", function (_, buttonID)
    Menu.SetActiveTab(Menu.tabButtonToTabID[buttonID])
end)

-- Listen for checkboxes changing state.
UI:RegisterCallListener("checkBoxID", function (_, elementID, stateID)
    local setting = Menu.GetElementSetting(elementID)

    Menu.SetPendingChange(setting, stateID == 1)
end)

-- Listen for combo boxes having their choice changed.
UI:RegisterCallListener("comboBoxID", function (_, elementID, optionIndex)
    local setting = Menu.GetElementSetting(elementID) ---@type Feature_SettingsMenu_Setting_ComboBox

    Menu.SetPendingChange(setting, setting.Choices[optionIndex + 1].ID)
end)

-- Listen for sliders being slid.
UI:RegisterCallListener("menuSliderID", function (_, elementID, value)
    local setting = Menu.GetElementSetting(elementID) ---@type Feature_SettingsMenu_Setting_Slider
    
    Menu.SetPendingChange(setting, value)
end)

-- Listen for button entries being pressed.
UI:RegisterCallListener("buttonPressed", function (_, elementID)
    local entry = Menu.currentElements[elementID] ---@type Feature_SettingsMenu_Entry_Button

    if entry and entry.ID then
        Menu.Events.ButtonPressed:Throw({
            Tab = Menu.GetTab(Menu.currentTabID),
            ButtonID = entry.ID,
        })
    else
        Menu:LogWarning("A button has been pressed which was not declared with any ID - it will not be usable in scripting.")
    end
end)

-- Listen for selectors being switched.
UI:RegisterCallListener("selectOption", function (_, elementID, optionIndex, _)
    -- TODO extract method
    local entry = Menu.currentElements[elementID] ---@type Feature_SettingsMenu_Entry_Category

    if entry and entry.Type == "Category" then
        Menu.categoryStateIndexes[entry.ID] = optionIndex + 1

        Menu.RenderSettings(Menu.GetTab(Menu.currentTabID))
    end
end)

-- Listen for apply being pressed.
UI:RegisterCallListener("applyPressed", function (_)
    Menu.ApplyPendingChanges()
end)

-- Render the built-in element types.
Menu.Events.RenderSetting:Subscribe(function (ev)
    local setting = ev.Setting
    local settingType = setting.Type

    if settingType == "Boolean" then
        Menu._RenderCheckbox(setting, ev.ElementID)
    elseif settingType == "ClampedNumber" then
        Menu._RenderSlider(setting, ev.ElementID)
    elseif settingType == "Choice" then
        Menu._RenderComboBox(setting, ev.ElementID)
    else
        Menu:LogWarning("Unknown setting type: " .. settingType .. " did Pip forgot to re-implement something? If this is a custom setting type, let them know to remove this warning call.")
    end
end)

-- Add a button to open Epip's settings menus to the vanilla UI.
OptionsSettings:RegisterInvokeListener("parseBaseUpdateArray", function(ev)
    -- Don't show the button in the main menu.
    if GameState.IsInSession() then
        local root = ev.UI:GetRoot()
    
        root.mainMenu_mc.addOptionButton("Epip Settings", "EPIP_OpenSettingsMenu", Menu.TAB_BUTTON_ID, false)
    end
end, "After")

-- Open the menu when the button is pressed from the vanilla UI.
OptionsSettings:RegisterCallListener("EPIP_OpenSettingsMenu", function (ev, buttonID)
    if buttonID == Menu.TAB_BUTTON_ID then
        Menu.Open()

        ev.UI:ExternalInterfaceCall("requestCloseUI")
    
        -- Close the game menu that appears as a result of closing the vanilla settings menu
        Ext.OnNextTick(function ()
            Client.UI.GameMenu:ExternalInterfaceCall("ButtonPressed", Client.UI.GameMenu.BUTTON_IDS.RESUME)
        end)
    end
end)

-- Close the menu with Esc.
Client.Input.Events.KeyReleased:Subscribe(function (ev)
    if Menu.GetUI():IsVisible() and ev.InputID == "escape" then
        Menu.Close()
    end
end)

-- Do not destroy the UI - instead hide it.
UI:RegisterCallListener("requestCloseUI", function (ev)
    if Menu.HasPendingChanges() then
        Menu._ShowPendingChangesPrompt()
    else
        Menu.Close()
    end

    ev:PreventAction()
end)

-- Listen for the accept button being pressed.
UI:RegisterCallListener("acceptPressed", function (_)
    if Menu.HasPendingChanges() then
        Menu._ShowPendingChangesPrompt()
    else
        Menu.Close()
    end
end)

Client.UI.MessageBox.RegisterMessageListener("Feature_SettingsMenu_UnsavedChanges", Client.UI.MessageBox.Events.ButtonPressed, function (buttonID, _)
    if buttonID == 1 then
        Menu.ApplyPendingChanges()
    end

    Menu.Close()
end)

-- Make developer settings return their default value if dev mode is off.
Settings.Hooks.GetSettingValue:Subscribe(function (ev)
    local setting = ev.Setting ---@type Feature_SettingsMenu_Setting

    if setting.DeveloperOnly and not Epip.IsDeveloperMode() then
        ev.Value = setting:GetDefaultValue()
    end
end)

-- Filter out settings that are developer-only or set to not be visible.
Menu.Hooks.GetTabEntries:Subscribe(function (ev)
    local filteredEntries = {}

    for _,entry in ipairs(ev.Entries) do
        if entry.Type == "Setting" then
            entry = entry ---@type Feature_SettingsMenu_Entry_Setting
            local setting = Settings.GetSetting(entry.Module, entry.ID) ---@type Feature_SettingsMenu_Setting
            
            if setting then
                local canRender = setting.Visible or setting.Visible == nil
    
                canRender = canRender and (not setting.DeveloperOnly or Epip.IsDeveloperMode())

                if canRender then
                    table.insert(filteredEntries, entry)
                end
            end
        else
            table.insert(filteredEntries, entry)
        end
    end

    ev.Entries = filteredEntries
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local root = UI:GetRoot()
local mainMenu = root.mainMenu_mc

mainMenu.toptitle_txt.htmlText = "EPIP SETTINGS"
mainMenu.ok_mc.text_txt.htmlText = "ACCEPT"
mainMenu.cancel_mc.text_txt.htmlText = "CANCEL"
mainMenu.apply_mc.text_txt.htmlText = "APPLY"

Menu.Close()