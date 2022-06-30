
---@meta OptionsSettingsUI, ContextClient

---@class OptionsSettingsUI
---@field Options table<string, OptionsSettingsOptionSet>
---@field OptionValues table<string, table>
---@field PendingValueChanges table<string, table>
---@field TABS table<string, number>
---@field SAVE_FILENAME string
---@field currentTab number
---@field currentElements table<number, OptionsSettingsOption>
---@field currentCustomTabs table<number, string> Binds a side button's numerical ID to the mod it's for.

---@type OptionsSettingsUI
local OptionsSettings = {
    Options = {},
    OptionValues = {},
    PendingValueChanges = {},

    TABS = {
        GRAPHICS = 1,
        AUDIO = 2,
        GAMEPLAY = 3
    },
    SAVE_FILENAME = "epip_modsettings.json",
    STARTING_NUM_ID = 1337,

    currentTab = 0,
    currentElements = {},
    nextNumID = 1337,
    currentCustomTabs = {},
}
Client.UI.OptionsSettings = OptionsSettings
Epip.InitializeUI(Client.UI.Data.UITypes.optionsSettings, "OptionsSettings", OptionsSettings)
OptionsSettings:Debug()

-- Strange, Type does not seem to work.
function OptionsSettings:GetUI()
    return Ext.UI.GetByPath("Public/Game/GUI/optionsSettings.swf")
end

---@alias OptionsSettingsOptionType "Checkbox" | "Dropdown" | "Slider" | "Button" | "Header" | "Selector"

---@class OptionsSettingsOption
---@field Type string TODO alias
---@field Mod string
---@field ID string
---@field Label string
---@field Tooltip string
---@field ServerOnly boolean If true, the setting will only be visible for the host, and will be synchronized to the server context.
---@field SaveOnServer boolean If true, the setting will not be saved to the file.
---@field DefaultValue any Should be boolean for Checkbox, number for other vanilla elements. Buttons have no value. For Dropdown, use 1-based index.

---@class OptionsSettingsCheckbox : OptionsSettingsOption
---@field FilteredBool boolean TODO

---@class OptionsSettingsDropdown : OptionsSettingsOption
---@field Options string[]

---@class OptionsSettingsSlider : OptionsSettingsOption
---@field MinAmount number
---@field MaxAmount number
---@field Interval number
---@field HideNumbers boolean

---@class OptionsSettingsButton : OptionsSettingsOption
---@field SoundOnUp string

---@class OptionsSettingsHeader
---@field Label string

---@class OptionsSettingsTabHeader
---@field Label string

---@class OptionsSettingsSelectorOption
---@field Label string
---@field SubSettings string[]

---@class OptionsSettingsSelector : OptionsSettingsOption
---@field Options OptionsSettingsSelectorOption[]

---@class OptionsSettingsOptionSet
---@field Mod string
---@field TabHeader string
---@field SideButtonLabel string
---@field ServerOnly boolean If true, this section will only be visible to the host.
---@field Options OptionsSettingsOption[]

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when a custom option's value is set, either from loading or applying changes through the menu/SetOptionValue.
---@class OptionsSettingsUI_OptionSet : Event
---@field data OptionsSettingsOption
---@field value any

---Fired before a mod's options settings tab is rendered.
---@class OptionsSettingsUI_CustomTabRenderStarted : Event
---@field modID string
---@field data OptionsSettingsOptionSet

---Fired when an option element needs to be rendered in the UI.
---@class OptionsSettingsUI_ElementRenderRequest : Event
---@field type string
---@field data OptionsSettingsOption
---@field numID number The numeric ID this element should use.

---Fired when a settings tab is rendered. Values > 3 are custom tabs; their info should be queried from OptionsSettings.currentCustomTabs
---@class OptionsSettingsUI_TabRendered : Event
---@field tab number

---Fired when a custom checkbox is clicked while enabled.
---@class OptionsSettingsUI_CheckboxClicked : Event
---@field element OptionsSettingsOption
---@field active boolean

---Fired when a custom button is clicked while enabled.
---@class OptionsSettingsUI_ButtonClicked : Event
---@field element OptionsSettingsOption

---Fired when a custom slider's value is changed by the user.
---@class OptionsSettingsUI_SliderChanged : Event
---@field element OptionsSettingsOption
---@field value number

---Fired when a custom dropdown's option is changed by the user.
---@class OptionsSettingsUI_DropdownChanged : Event
---@field element OptionsSettingsOption
---@field optionIndex number 1-based index.

---Fired when a custom setting's value change is applied from the menu (through the "Apply changes" button).
---@class OptionsSettingsUI_ChangeApplied : Event
---@field option OptionsSettingsOption
---@field value any

---Hook to manipulate if an element should be interactable in the UI. Can be used, for example, to make a setting require another to be toggled on first.
---@class OptionsSettingsUI_IsElementEnabled : Hook
---@field enabled boolean Defaults to true.
---@field data OptionsSettingsOption

---Hook to manipulate a custom option's value. Can be used, for example, to disable a setting based on another's value.
---@class OptionsSettingsUI_GetOptionValue : Hook
---@field value any Defaults to the stored value.
---@field data OptionsSettingsOption

---Fired while `baseUpdate_Array` is being parsed in Flash. Hook to manipulate the parsed array.
---@class OptionsSettingsUI_BaseUpdate : Hook
---@field elements table[] TODO document fields

---Hook to manipulate the label of tab buttons for mods.
---@class OptionsSettingsUI_GetSideButtonLabel : Hook
---@field label string Defaults to OptionsSettingsOption.SideButtonLabel or OptionsSettingsOption.Mod

---Hook to manipulate the header of mod setting menus.
---@class OptionsSettingsUI_GetTabHeader : Hook
---@field label string Defaults to OptionsSettingsOption.TabHeader or OptionsSettingsOption.Mod

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a mod for use with the options menu.
---@param mod string
---@param data OptionsSettingsOptionSet
function OptionsSettings.RegisterMod(mod, data)
    data.Mod = mod
    data.Options = data.Options or {}

    OptionsSettings.Options[mod] = data

    OptionsSettings.RegisterOptions(mod, data.Options)
end

---Adds options to a mod's option menu.
---@param mod string
---@param data OptionsSettingsOption[]
function OptionsSettings.RegisterOptions(mod, data)
    for i,option in pairs(data) do
        OptionsSettings.RegisterOption(mod, option)
    end
end

---Adds an option to a mod's options menu.
---@param mod string
---@param data OptionsSettingsOption
function OptionsSettings.RegisterOption(mod, data)
    data.Mod = mod

    local modData = OptionsSettings.Options[mod]

    if not modData then
        modData = {
            Mod = mod,
            Options = {},
        }
        OptionsSettings.Options[mod] = modData
    end

    if not OptionsSettings.OptionValues[data.ID] then
        OptionsSettings.OptionValues[data.ID] = data.DefaultValue
    end

    table.insert(modData.Options, data) -- TODO infinite loop?
end

---Returns whether a custom option's element is interactable. Hookable.
---@param id string
---@return boolean
function OptionsSettings.IsElementEnabled(id)
    local data = OptionsSettings.GetOptionData(id)

    local enabled = OptionsSettings:ReturnFromHooks("IsElementEnabled", true, data)

    return enabled
end

---Set the state of an option in the UI. Does not change the stored value of custom options.
---@param id string|number
---@param state any
---@param elementType OptionsSettingsOptionType? Needs to be provided for vanilla options. TODO get automatically
function OptionsSettings.SetElementState(id, state, elementType)
    local numID = OptionsSettings.GetElementNumID(id)
    local data = OptionsSettings.GetOptionData(id)
    local root = OptionsSettings:GetRoot()

    if data then
        elementType = data.Type
    end

    OptionsSettings:DebugLog("Setting element " .. id .. " to " .. tostring(state))

    if type(id) == "number" then
        numID = id
    end

    if elementType == "Dropdown" then
        root.mainMenu_mc.selectMenuDropDownEntry(numID, state - 1) -- Converting from 1-based to 0-based index
    elseif elementType == "Checkbox" then
        local checkboxState = 0

        if state then
            checkboxState = 1
        end

        root.mainMenu_mc.setMenuCheckbox(numID, OptionsSettings.IsElementEnabled(id), checkboxState)
    elseif elementType == "Selector" then
        print("numid", numID)
        root.mainMenu_mc.setSelector(numID, state - 1, true)
    end
end

---Set an element to be enabled/disabled (interactable or not). TODO other types
---@param id string|number
---@param enabled boolean
---@param elementType OptionsSettingsOptionType
function OptionsSettings.SetElementEnabled(id, enabled, elementType)
    local numID = OptionsSettings.GetElementNumID(id)
    local root = OptionsSettings:GetRoot()

    if elementType == "Dropdown" then
        root.mainMenu_mc.setMenuDropDownEnabled(numID, enabled)
    elseif elementType == "Checkbox" then
        local element = OptionsSettings.GetOptionElement(numID)

        root.mainMenu_mc.setMenuCheckbox(numID, enabled, element.stateID)
    end
end

---Get the numerical id of a custom option element in the UI.
---@param id string
---@return number
function OptionsSettings.GetElementNumID(id)
    if type(id) == "string" then
        for i,v in pairs(OptionsSettings.currentElements) do
            if v.ID == id then
                return i
            end
        end
    elseif type(id) == "number" then
        return id
    end
end

---Get the data for an option.
---@param id string
---@return OptionsSettingsOption
function OptionsSettings.GetOptionData(id)
    for modID,modData in pairs(OptionsSettings.Options) do
        for i,optionData in ipairs(modData.Options) do
            if optionData.ID == id then
                return optionData
            end
        end
    end
end

---Get the value of a custom option.
---@param mod string
---@param id string
---@return any Type varies based on element type. Boolean for checkboxes, number for other vanilla elements.
function OptionsSettings.GetOptionValue(mod, id)
    local data = OptionsSettings.GetOptionData(id)
    local value = OptionsSettings.OptionValues[id]
    
    value = OptionsSettings:ReturnFromHooks("GetOptionValue", value, data)

    -- Dev settings always use default values if developer mode isnt on
    -- TODO

    return value
end

---Set a custom option's value. Immediately synchronized to server, if need be.
---@param mod string
---@param option string
---@param value any
---@param synch? boolean Whether to synch the value to the server. Defaults to true.
function OptionsSettings.SetOptionValue(mod, option, value, synch)
    OptionsSettings.OptionValues[option] = value

    if synch or synch == nil then
        OptionsSettings.SynchToServer(option, value)
    end

    -- If the UI is open, update the element.
    if OptionsSettings:GetUI() ~= nil then
        OptionsSettings.SetElementState(option, value)
    end

    if OptionsMenu.initialized then
        OptionsSettings:FireEvent("OptionSet", OptionsSettings.GetOptionData(option), value)
    end
end

---------------------------------------------
-- RENDERING METHODS
---------------------------------------------

---Render a slider.
---@param data OptionsSettingsSlider
---@param numID number
function OptionsSettings.RenderSlider(data, numID)
    local root = OptionsSettings:GetRoot()
    local value = OptionsSettings.GetOptionValue(data.Mod, data.ID)

    root.mainMenu_mc.addMenuSlider(numID, data.Label, value, data.MinAmount, data.MaxAmount, data.Interval, data.HideNumbers, data.Tooltip)
end

---Render a button.
---@param data OptionsSettingsButton
---@param numID number
function OptionsSettings.RenderButton(data, numID)
    local root = OptionsSettings:GetRoot()
    local enabled = OptionsSettings.IsElementEnabled(data.ID)

    root.mainMenu_mc.addMenuButton(numID, data.Label, data.SoundOnUp or "", enabled, data.Tooltip)
end

---Render a header.
---@param data OptionsSettingsHeader
---@param numID number
function OptionsSettings.RenderHeader(data, numID)
    OptionsSettings:GetRoot().mainMenu_mc.addMenuLabel(data.Label)
end

---Render a checkbox option.
---@param data OptionsSettingsCheckbox
---@param numID number
function OptionsSettings.RenderCheckbox(data, numID)
    local value = OptionsSettings.GetOptionValue(data.Mod, data.ID)
    local enabled = OptionsSettings.IsElementEnabled(data.ID)
    local stateId = 0

    if value then
        stateId = 1
    end

    OptionsSettings:GetRoot().mainMenu_mc.addMenuCheckbox(numID, data.Label, enabled, stateId, 0, data.Tooltip) -- TODO filteredBool
end

---Render a selector onto the UI.
---@param selector OptionsSettingsSelector
---@param numID number
function OptionsSettings.RenderSelector(selector, numID)
    local root = OptionsSettings:GetRoot()

    root.mainMenu_mc.addMenuSelector(numID, "")
    local element = Client.Flash.GetLastElement(root.mainMenu_mc.list.content_array)
    element.formHL_mc.alpha = 0
    element.selectorData_mc.alpha = 0
    element.title_txt.mouseEnabled = false
    element = element.selection_mc
    element.hit_mc.alpha = 0

    element.x = 180
    element.hit_mc.mouseEnabled = false -- TODO

    element.LB_mc.x = 0
    element.text_txt.x = 0
    element.text_txt.mouseEnabled = false
    element.RB_mc.x = 550

    for i,option in ipairs(selector.Options) do
        root.mainMenu_mc.addSelectorOption(numID, i - 1, option.Label)
    end
    
    OptionsSettings.SetElementState(selector.ID, OptionsSettings.GetOptionValue(selector.Mod, selector.ID))
end

---Render a dropdown option.
---@param data OptionsSettingsDropdown
---@param numID number
function OptionsSettings.RenderDropdown(data, numID)
    OptionsSettings:GetRoot().mainMenu_mc.addMenuDropDown(numID, data.Label, data.Tooltip)

    for i,option in ipairs(data.Options) do
        OptionsSettings.RenderDropdownEntry(numID, option)
    end

    OptionsSettings.SetElementEnabled(data.ID, OptionsSettings.IsElementEnabled(data.ID))
    OptionsSettings.SetElementState(data.ID, OptionsSettings.GetOptionValue(data.Mod, data.ID))
end

---Returns the MovieClip for an element.
---@param id string|number String or number ID of the element.
---@return FlashMovieClip
function OptionsSettings.GetOptionElement(id)
    local element = nil

    if type(id) == "string" then
        id = OptionsSettings.GetElementNumID(id)
    end

    if id then
        local root = OptionsSettings:GetRoot()
        local elements = root.mainMenu_mc.list.content_array

        for i=0,#elements-1,1 do
            if elements[i].id == id then
                element = elements[i]
                break
            end
        end
    end

    return element
end

---Add an entry to a dropdown element.
---@param id stirng|number
---@param option string Label.
function OptionsSettings.RenderDropdownEntry(id, option)
    if type(id) == "string" then
        id = OptionsSettings.GetElementNumID(id)
    end
    OptionsSettings:GetRoot().mainMenu_mc.addMenuDropDownEntry(id, option)
end

---Render an option directly.
---@param elementData OptionsSettingsOption
---@param numID? integer
---@return number Numeric ID.
function OptionsSettings.RenderOption(elementData, numID)
    numID = numID or OptionsSettings.nextNumID

    -- Server-only settings are only shown for host
    if not elementData.ServerOnly or Client.IsHost() then
        OptionsSettings.currentElements[numID] = elementData

        OptionsSettings:FireEvent("ElementRenderRequest", elementData.Type, elementData, numID)

        OptionsSettings.nextNumID = OptionsSettings.nextNumID + 1

        return numID
    end
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

function OptionsSettings.RenderOptions(tabID)
    local modID = OptionsSettings.currentCustomTabs[tabID]
    local modData = OptionsSettings.Options[modID]
    local root = OptionsSettings:GetRoot()
    root.removeItems()

    OptionsSettings.currentElements = {}

    OptionsSettings:FireEvent("CustomTabRenderStarted", modID, modData)

    for i,elementData in pairs(modData.Options) do
        OptionsSettings.RenderOption(elementData)

        if elementData.Type == "Selector" then
            for z,subSettingID in ipairs(elementData.Options[OptionsSettings.GetOptionValue(elementData.Mod, elementData.ID)].SubSettings) do
                local settingData = OptionsSettings.GetOptionData(subSettingID)

                local elementID = OptionsSettings.RenderOption(settingData)
    
                -- TODO finish
                -- OptionsSettings:DebugLog("Adding subsetting with id", elementID)
                -- OptionsSettings:Dump(settingData)
    
                -- if elementID then
                --     OptionsSettings.GetOptionElement(elementID).visible = false
                --     root.mainMenu_mc.addSelectorSubSetting(numID, i - 1, elementID)
                -- end
            end
        end
    end

    OptionsSettings.currentTab = tabID

    Ext.OnNextTick(function()
        OptionsSettings:FireEvent("TabRendered", OptionsSettings.currentTab)
    end)
end

---@param option OptionsSettingsOption
---@param value any
function OptionsSettings.SynchToServer(option, value)
    option = OptionsSettings.GetOptionData(option)

    if option and option.ServerOnly and Client.IsHost() then
        OptionsSettings:Log("Synching setting to server: " .. option.ID .. " value " .. tostring(value))
        Game.Net.PostToServer("EPIPENCOUNTERS_ServerOptionChanged", {Mod = option.Mod, Setting = option.ID, Value = value})
    end
end

-- Save settings
function OptionsSettings.SaveSettings()
    local json = {protocol = 1, mods = {}}

    for modID,modData in pairs(OptionsSettings.Options) do
        json.mods[modID] = {settings = {}}

        for i,setting in pairs(modData.Options) do
            if not setting.SaveOnServer then
                json.mods[modID].settings[setting.ID] = OptionsSettings.GetOptionValue(modID, setting.ID)
            end
        end
    end

    Utilities.SaveJson(OptionsSettings.SAVE_FILENAME, json)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- TODO move elsewhere as this is from a feature and not the core library.
Game.Net.RegisterListener("EPIPENCOUNTERS_ServerSettingSynch", function(cmd, payload)
    OptionsSettings.SetOptionValue(payload.Module, payload.Setting, payload.Value, false)
end)

-- Render the basic element types
OptionsSettings:RegisterListener("ElementRenderRequest", function(elementType, data, numID)
    if elementType == "Checkbox" then
        OptionsSettings.RenderCheckbox(data, numID) -- TODO automatically keep track of numID by default?
    elseif elementType == "Dropdown" then
        OptionsSettings.RenderDropdown(data, numID)
    elseif elementType == "Slider" then
        OptionsSettings.RenderSlider(data, numID)
    elseif elementType == "Button" then
        OptionsSettings.RenderButton(data, numID)
    elseif elementType == "Header" then
        OptionsSettings.RenderHeader(data, numID)
    elseif elementType == "Selector" then
        OptionsSettings.RenderSelector(data, numID)
    end
end)

-- Synch server-only settings once the client has been detected as the host
Client:RegisterListener("DeterminedAsHost", function()
    for modID,modData in pairs(OptionsSettings.Options) do
        for i,setting in ipairs(modData.Options) do
            if not setting.SaveOnServer then
                OptionsSettings.SynchToServer(setting.ID, OptionsSettings.GetOptionValue(modID, setting.ID))
            end
        end
    end
end)

local function onupdate(ui, method)
    local root = ui:GetRoot()

    -- first array element is the type of UI element
    -- 0: Checkbox
        -- Params: id:number, label:string, enabled:bool, stateId:number, filterBool:bool, tooltip:string
    -- 1: dropdown
        -- Params: id:number, label:string, tooltip:string
    -- 2: dropdown entry
        -- Params: dropdownId:number, optionLabel:string
    -- 3: selectMenuDropDownEntry - sets the selected index of a dropdown
        -- Params: dropdownId:number, index:number
    -- 4: slider
        -- Params: id:number, label:string, amount:number, minAmount:number, maxAmount:number, interval:number, hiddenNumbers:bool, tooltip:string
    -- 5: button
        -- Params: id:number, label:string, soundOnUp:string, enabled:bool, tooltip:string
    -- 6: section header
        -- Params: string
    -- 7: tab header (sets the title of the UI)
        -- Params: string
    -- 8: setMenuDropdownEnabled
        -- Params: id:number, enabled:bool
    -- 9: setMenuCheckbox
        -- Params: id:number, enabled:bool, state:bool

    local content = ParseFlashArray(root.update_Array, {
        {id = 0, name = "checkbox", paramsCount = 6},
        {id = 1, name = "dropdown", paramsCount = 3},
        {id = 2, name = "dropdownEntry", paramsCount = 2},
        {id = 3, name = "selectDropdownEntry", paramsCount = 2},
        {id = 4, name = "slider", paramsCount = 8},
        {id = 5, name = "button", paramsCount = 5},
        {id = 6, name = "sectionHeader", paramsCount = 1},
        {id = 7, name = "tabHeader", paramsCount = 1},
        {id = 8, name = "setDropdownEnabled", paramsCount = 2},
        {id = 9, name = "setCheckbox", paramsCount = 3},
    })

    -- if OptionsSettings.IS_DEBUG then
    --     Ext.Dump(content)
    -- end
end

local function onbasearray(ui, method)
    local root = ui:GetRoot()

    local array = root.baseUpdate_Array
    local i = 0
    local elements = {}
    while i < #array do
        local elementType = array[i]
        local element

        if elementType == 0 then
            element = {
                Type = "TabButton",
                ID = array[i + 1],
                Label = array[i + 2],
                Active = array[i + 3],
                Callback = "switchMenu",
            }
            i = i + 3

            if element.Active then
                OptionsSettings.currentTab = element.ID
            end
        elseif elementType == 1 then
            element = {
                Type = "BottomButton",
                Index = array[i + 1],
                Label = array[i + 2],
            }
            i = i + 3
        elseif elementType == 2 then
            element = {
                Type = "TitleText",
                Label = array[i + 1],
            }
            i = i + 2
        else
            element = {
                Type = "None",
            }
            i = i + 1
        end

        table.insert(elements, element)
    end

    elements = OptionsSettings:ReturnFromHooks("BaseUpdate", elements)

    OptionsSettings.EncodeBaseUpdate(ui, elements)

    Ext.OnNextTick(function()
        OptionsSettings:FireEvent("TabRendered", OptionsSettings.currentTab)
    end)
end

function OptionsSettings.EncodeBaseUpdate(ui, elements)
    local newArray = {}
    for i,element in ipairs(elements) do
        if element.Type == "TabButton" then

            -- Special handling, since the normal update uses a constant
            table.insert(newArray, 0)
            table.insert(newArray, element.ID)
            table.insert(newArray, element.Label)
            table.insert(newArray, element.Active)
            table.insert(newArray, element.Callback)
        elseif element.Type == "BottomButton" then
            table.insert(newArray, 1)
            table.insert(newArray, element.Index)
            table.insert(newArray, element.Label)
        elseif element.Type == "TitleText" then
            table.insert(newArray, 2)
            table.insert(newArray, element.Label)
        else
            table.insert(newArray, 9)
        end
    end

    Game.Tooltip.TableToFlash(ui, "baseUpdate_Array", newArray)
end

-- Insert mod tabs
OptionsSettings:RegisterHook("BaseUpdate", function(elements)
    OptionsSettings.currentCustomTabs = {}

    local numID = 10
    for modID,modData in pairs(OptionsSettings.Options) do

        if not modData.ServerOnly or Client.IsHost() then
            table.insert(elements, {
                Type = "TabButton",
                ID = numID,
                Label = OptionsSettings:ReturnFromHooks("GetSideButtonLabel", modData.SideButtonLabel or modID, modData),
                Active = false,
                Callback = "PipCustomTabClick",
            })
            OptionsSettings.currentCustomTabs[numID] = modID
            numID = numID + 1
        end
    end
end)

Ext.RegisterUINameCall("PipCustomTabClick", function(ui, method, id)
    local tab = OptionsSettings.currentCustomTabs[id]
    local root = ui:GetRoot()
    local overview = ui:GetRoot().mainMenu_mc
    local buttons = overview.menuBtnList.content_array
    local modID = OptionsSettings.currentCustomTabs[id]

    -- Deselect other
    for i=0,#buttons-1,1 do
        local button = buttons[i]
        local isCurrent = button.buttonID == id

        button.bg_mc.visible = not isCurrent
        button.activeBG_mc.visible = isCurrent
        button.m_Disabled = isCurrent
    end

    -- Enter new tab
    -- TODO prompt on discard changes
    root.removeItems()

    OptionsSettings.RenderOptions(id)

    -- Set header
    root.mainMenu_mc.setTitle(OptionsSettings:ReturnFromHooks("GetTabHeader", OptionsSettings.Options[modID].TabHeader or modID, OptionsSettings.Options[modID]))
end)

local function OnCheckbox(ui, method, id, stateId)
    OptionsSettings:DebugLog("Checkbox clicked: " .. id)
    local element = OptionsSettings.currentElements[id]

    if element then
        OptionsSettings:FireEvent("CheckboxClicked", element, stateId == 1)
    end
end

local function OnButton(ui, method, id)
    OptionsSettings:DebugLog("Button clicked: " .. id)
    local element = OptionsSettings.currentElements[id]

    if element then
        OptionsSettings:FireEvent("ButtonClicked", element)
    end
end

local function OnSliderChange(ui, method, id, value)
    OptionsSettings:DebugLog("Slider changed: " .. id)
    local element = OptionsSettings.currentElements[id]

    if element then
        OptionsSettings:FireEvent("SliderChanged", element, value)
    end
end

local function OnDropdownChange(ui, method, id, optionIndex)
    OptionsSettings:DebugLog("Dropdown changed: " .. id)
    local element = OptionsSettings.currentElements[id]

    if element then
        OptionsSettings:FireEvent("DropdownChanged", element, optionIndex + 1)
    end
end

-- OptionsSettings:RegisterCallListener("selectOption", function(ev, id, optionIndex, toRight)
Ext.RegisterUINameCall("selectOption", function(ui, method, id, optionIndex, toRight)
    OptionsSettings:DebugLog("Selector changed: ", id)
    local element = OptionsSettings.currentElements[id]

    -- Selectors are immediately set, no need to confirm.
    if element then
        OptionsSettings:DebugLog("Re-rendering from selector change.")
        OptionsSettings.SetOptionValue(element.Mod, element.ID, optionIndex + 1, true)

        OptionsSettings.RenderOptions(OptionsSettings.currentTab)
    end
end)

OptionsSettings:RegisterListener("CheckboxClicked", function(element, stateId)
    OptionsSettings.PendingValueChanges[element.ID] = stateId
end)

OptionsSettings:RegisterListener("SliderChanged", function(element, value)
    OptionsSettings.PendingValueChanges[element.ID] = value
end)

OptionsSettings:RegisterListener("DropdownChanged", function(element, optionIndex)
    OptionsSettings.PendingValueChanges[element.ID] = optionIndex
end)

local function OnApplyOverrides(ui, method)
    for settingID,value in pairs(OptionsSettings.PendingValueChanges) do
        local setting = OptionsSettings.GetOptionData(settingID)

        OptionsSettings.SetOptionValue(setting.Mod, setting.ID, value)
        OptionsSettings:FireEvent("ChangeApplied", setting, value)
    end

    OptionsSettings.PendingValueChanges = {}

    OptionsSettings:Log("Changes applied.")

    OptionsSettings.SaveSettings()
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Load saved settings
Ext.Events.SessionLoading:Subscribe(function()
    local savedSettings = Utilities.LoadJson(OptionsSettings.SAVE_FILENAME)

    if savedSettings then
        OptionsSettings:DebugLog("Loading settings")

        -- Convert v1043 configs to new setting names
        if savedSettings.protocol == 0 then
            local oldSettings = {
                hotbarCombatLogLegacyBehaviour = "HotbarCombatLogButton",
                epip_CustomContextMenus = "CustomContextMenus",
            }
            local newSettings = {}

            for setting,value in pairs(savedSettings.mods.EpipEncounters.settings) do
                setting = oldSettings[setting] or setting

                setting = setting:sub(1, 1):upper() .. setting:sub(2)

                local data = OptionsSettings.GetOptionData(setting)

                if data and data.Type == "Dropdown" then
                    -- print(value, data.ID, value + 1)
                    -- value = value + 1
                elseif data and data.Type == "Checkbox" then
                    if value == 0 then
                        value = false
                    else
                        value = true
                    end
                end

                newSettings[setting] = value
            end

            savedSettings.mods.EpipEncounters.settings = newSettings

            savedSettings.protocol = 1

            OptionsSettings.SaveSettings()
        end

        if savedSettings.protocol > 0 then
            for modID,modData in pairs(savedSettings.mods) do

                if OptionsSettings.Options[modID] then
                    for setting, value in pairs(modData.settings) do
                        OptionsSettings.SetOptionValue(modID, setting, value)
                    end
                else
                    OptionsSettings:LogWarning("Mod has saved settings but is not loaded: " .. modID)
                end
            end
        end
    end
end)

Ext.Events.SessionLoaded:Subscribe(function()
    Ext.RegisterUINameInvokeListener("parseUpdateArray", onupdate)
    Ext.RegisterUINameInvokeListener("parseBaseUpdateArray", onbasearray)

    Ext.RegisterUINameCall("checkBoxID", OnCheckbox)
    Ext.RegisterUINameCall("menuSliderID", OnSliderChange)
    Ext.RegisterUINameCall("comboBoxID", OnDropdownChange)
    Ext.RegisterUINameCall("buttonPressed", OnButton)
    Ext.RegisterUINameCall("applyPressed", OnApplyOverrides)
end)