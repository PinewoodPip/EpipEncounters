
local Settings = Settings
local OptionsSettings = Client.UI.OptionsSettings

---@class Feature_SettingsMenu : Feature
local Menu = {
    UI_ID = "EPIP_SettingsMenu",
    UI = nil, ---@type UI

    Tabs = {}, ---@type table<string, Feature_SettingsMenu_Tab>
    TabRegistrationOrder = {}, ---@type string[]
    currentTabID = nil,
    currentElements = {}, ---@type table<Feature_SettingsMenu_ElementID, Feature_SettingsMenu_Entry>
    nextElementNumID = 1, ---@type Feature_SettingsMenu_ElementID
    tabButtonToTabID = {}, ---@type table<integer, string>

    _initializedUI = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        RenderSetting = {}, ---@type Event<Feature_SettingsMenu_Event_RenderSetting>
    },
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
---@field Elements Feature_SettingsMenu_Entry[]

---@class Feature_SettingsMenu_Entry
---@field Type "Setting"|"Label"

---@class Feature_SettingsMenu_Entry_Label : Feature_SettingsMenu_Entry
---@field Label string

---@class Feature_SettingsMenu_Entry_Setting : Feature_SettingsMenu_Entry
---@field Module string
---@field ID string

---@class Feature_SettingsMenu_Setting : SettingsLib_Setting
---@field Visible boolean? Defaults to true.
---@field DeveloperOnly boolean? Defaults to false.

---@class Feature_SettingsMenu_Setting_Slider : Feature_SettingsMenu_Setting, SettingsLib_Setting_ClampedNumber
---@field Step number
---@field HideNumbers boolean? Defaults to false.

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_SettingsMenu_Event_RenderSetting
---@field Setting Feature_SettingsMenu_Setting
---@field ElementID Feature_SettingsMenu_ElementID

---------------------------------------------
-- METHODS
---------------------------------------------

---@param data Feature_SettingsMenu_Tab
function Menu.RegisterModule(data)
    Menu.Tabs[data.ID] = data
    table.insert(Menu.TabRegistrationOrder, data.ID)
end

---@param id string
---@return Feature_SettingsMenu_Tab
function Menu.GetTab(id)
    return Menu.Tabs[id]
end

function Menu.RenderTabButtons()
    local UI = Menu.GetUI()
    local root = UI:GetRoot()

    root.mainMenu_mc.menuBtnList.clearElements()

    for i,id in ipairs(Menu.TabRegistrationOrder) do
        local tab = Menu.GetTab(id)

        Menu.tabButtonToTabID[i] = id
        
        root.mainMenu_mc.addOptionButton(tab.ButtonLabel, "EPIP_TabClicked", i, false)
    end
end

function Menu._Setup()
    local UI = Menu.GetUI()
    local root = UI:GetRoot()
    local mainMenu = root.mainMenu_mc

    -- Render tab buttons
    Menu.RenderTabButtons()

    -- Render tab contents
    if Menu.currentTabID then
        Menu.RenderSettings(Menu.GetTab(Menu.currentTabID))
    end
end

---@param tab Feature_SettingsMenu_Tab
function Menu.RenderSettings(tab)
    local UI = Menu.GetUI()
    local root = UI:GetRoot()
    Menu.nextElementNumID = 1
    root.removeItems()

    Menu:DebugLog("Rendering tab", tab.ID)

    -- TODO render event

    for _,entry in ipairs(tab.Elements) do
        -- TODO extract methods for these, add events
        if entry.Type == "Setting" then
            entry = entry ---@type Feature_SettingsMenu_Entry_Setting
            local setting = Settings.GetSetting(entry.Module, entry.ID) ---@type Feature_SettingsMenu_Setting
            local canRender = setting.Visible or setting.Visible == nil

            canRender = canRender and (not setting.DeveloperOnly or Epip.IsDeveloperMode())

            if canRender then
                Menu.RenderSetting(setting)
            end
        elseif entry.Type == "Label" then
            local numID = Menu.nextElementNumID
            Menu.nextElementNumID = Menu.nextElementNumID + 1

            Menu._RenderLabel(entry, numID)
        end
    end

    Menu.currentTabID = tab.ID

    -- TODO fire tabrendered
end

---@param setting Feature_SettingsMenu_Setting
function Menu.RenderSetting(setting)
    local numID = Menu.nextElementNumID
    Menu.nextElementNumID = Menu.nextElementNumID + 1

    Menu:DebugLog("Rendering setting", setting.ID)

    -- TODO register dynamic settings?

    -- Host-only settings are only shown for host
    -- TODO server settings
    if (setting.Context ~= "Host" and setting.Context ~= "Server") or Client.IsHost() then
        Menu.currentElements[numID] = {Module = setting.ModTable, ID = setting.ID}

        Menu.Events.RenderSetting:Throw({
            Setting = setting,
            ElementID = numID,
        })

        -- TODO selectors
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
        local uiObject = Ext.UI.Create(ui.ID, ui.PATH, 20)

        Epip.InitializeUI(nil, Menu.UI_ID, ui)

        Menu.UI = ui
        Menu._initializedUI = true
    end

    return Menu.UI
end

function Menu.Open()
    local ui = Menu.GetUI()

    -- ui:SetFlag("OF_PauseRequest", true)

    Menu._Setup()

    ui:Show()
end

function Menu.Close()
    local ui = Menu.GetUI()

    -- ui:SetFlag("OF_PauseRequest", false)

    ui:Hide()
end

---@param elementID Feature_SettingsMenu_ElementID
---@return Feature_SettingsMenu_Setting
function Menu.GetElementSetting(elementID)
    local entry = Menu.currentElements[elementID]
    local setting

    if entry then
        setting = Settings.GetSetting(entry.Module, entry.ID) ---@type Feature_SettingsMenu_Setting
    end

    return setting
end

---@param element Feature_SettingsMenu_Setting|Feature_SettingsMenu_ElementID
function Menu.IsElementEnabled(element)
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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local UI = Menu.GetUI()

UI:RegisterCallListener("EPIP_TabClicked", function (_, buttonID)
    Menu.SetActiveTab(Menu.tabButtonToTabID[buttonID])
end)

-- Render the built-in element types.
Menu.Events.RenderSetting:Subscribe(function (ev)
    local setting = ev.Setting
    local settingType = setting.Type

    if settingType == "Boolean" then
        Menu._RenderCheckbox(setting, ev.ElementID)
    elseif settingType == "ClampedNumber" then
        Menu._RenderSlider(setting, ev.ElementID)
    end
end)

-- Add a button to open Epip's settings menus to the vanilla UI.
OptionsSettings:RegisterInvokeListener("parseBaseUpdateArray", function(ev)
    local root = ev.UI:GetRoot()

    root.mainMenu_mc.addOptionButton("Mod Settings", "EPIP_OpenSettingsMenu", -1, false)
end, "After")

-- Open the menu when the button is pressed from the vanilla UI.
OptionsSettings:RegisterCallListener("EPIP_OpenSettingsMenu", function (ev)
    Menu.Open()

    ev.UI:ExternalInterfaceCall("requestCloseUI")

    Ext.OnNextTick(function ()
        Client.UI.GameMenu:ExternalInterfaceCall("ButtonPressed", Client.UI.GameMenu.BUTTON_IDS.RESUME)
    end)
end)

-- Close the menu with Esc.
Client.Input.Events.KeyReleased:Subscribe(function (ev)
    if Menu.GetUI():IsVisible() and ev.InputID == "escape" then
        Menu.Close()
    end
end)

-- Do not destroy the UI - instead hide it.
UI:RegisterCallListener("requestCloseUI", function (ev)
    Menu.Close()

    ev:PreventAction()
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local root = UI:GetRoot()
local mainMenu = root.mainMenu_mc

mainMenu.toptitle_txt.htmlText = "MOD SETTINGS"
mainMenu.ok_mc.text_txt.htmlText = "ACCEPT"
mainMenu.cancel_mc.text_txt.htmlText = "CANCEL"
mainMenu.apply_mc.text_txt.htmlText = "APPLY"

Menu.Close()