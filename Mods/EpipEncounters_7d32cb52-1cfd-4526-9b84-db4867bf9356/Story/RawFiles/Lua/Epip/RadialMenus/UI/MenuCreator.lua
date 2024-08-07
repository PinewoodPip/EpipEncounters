
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local Input = Client.Input
local CommonStrings = Text.CommonStrings
local V = Vector.Create

local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local RadialMenuUI = RadialMenus.UI
local TSK = RadialMenus.TranslatedStrings

local UI = Generic.Create("Features.RadialMenus.UI.MenuCreator", 8) ---@class Features.RadialMenus.UI.MenuCreator : GenericUI_Instance -- Layer 9 is KBM skillbook UI.
RadialMenus.MenuCreatorUI = UI
UI.CONTENT_SIZE = V(670, 500)
UI.HEADER_SIZE = V(400, 50)
UI.SETTING_SIZE = V(650, 50)
UI.SLOT_SETTING_SIZE = V(UI.SETTING_SIZE[1], 70) -- Size for settings that render as hotbar slots.
---@type table<Features.Features.RadialMenus.UI.MenuCreator.Mode, TextLib_TranslatedString>
UI.MODE_HEADERS = {
    ["CreateMenu"] = TSK.Label_CreateNewMenu,
    ["EditMenu"] = TSK.Label_EditMenu,
    ["EditSlot"] = TSK.Label_EditSlot,
}
UI._CurrentMode = nil ---@type Features.Features.RadialMenus.UI.MenuCreator.Mode?
UI._MenuBeingEdited = nil ---@type Features.RadialMenus.Menu?
UI._SlotBeingEdited = nil ---@type Features.RadialMenus.Slot?
UI._SlotIndex = nil ---@type integer? Index of the slot being edited within the custom menu.

---@alias Features.Features.RadialMenus.UI.MenuCreator.Mode "CreateMenu"|"EditMenu"|"EditSlot"

---@class Features.RadialMenus.UI.MenuCreator.Hooks
UI.Hooks = UI.Hooks
UI.Hooks.CreateMenu = UI:AddSubscribableHook("CreateMenu") ---@type Hook<Features.RadialMenus.UI.MenuCreator.Hooks.CreateMenu>
UI.Hooks.UpdateSlot = UI:AddSubscribableHook("UpdateSlot") ---@type Hook<{Slot:Features.RadialMenus.Slot}> Thrown when editing a custom slot has finished. `Slot` is hookable.

---@class Features.RadialMenus.UI.MenuCreator.Events : GenericUI.Instance.Events
UI.Events = UI.Events
UI.Events.RenderMenuSettings = UI:AddSubscribableEvent("RenderMenuSettings") ---@type Event<Features.RadialMenus.UI.MenuCreator.Events.RenderMenuSettings>
UI.Events.RenderSlotSettings = UI:AddSubscribableEvent("RenderSlotSettings") ---@type Event<Features.RadialMenus.UI.MenuCreator.Events.RenderSlotSettings>
UI.Events.UpdateMenu = UI:AddSubscribableEvent("UpdateMenu") ---@type Event<{Menu:Features.RadialMenus.Menu}> Thrown when editing a menu has finished.

local MenuTypes = {
    Hotbar = RadialMenus:GetClass("Features.RadialMenus.Menu.Hotbar"),
    Custom = RadialMenus:GetClass("Features.RadialMenus.Menu.Custom"),
}
local Settings = {
    MenuName = RadialMenus:RegisterSetting("MenuCreator.MenuName", {
        Type = "String",
        Name = CommonStrings.Name, -- I don't feel this needs a description.
        DefaultValue = TSK.Label_NewMenu:GetString(),
    }),
    NewMenuType = RadialMenus:RegisterSetting("MenuCreator.NewMenuType", {
        Type = "Choice",
        Name = TSK.Setting_NewMenuType_Name,
        Description = TSK.Setting_NewMenuType_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = MenuTypes.Hotbar:GetClassName(), Name = Text.Resolve(MenuTypes.Hotbar:GetTypeName())},
            {ID = MenuTypes.Custom:GetClassName(), Name = Text.Resolve(MenuTypes.Custom:GetTypeName())},
        }
    }),
    HotbarStartIndex = RadialMenus:RegisterSetting("HotbarStartIndex", {
        Type = "ClampedNumber",
        Name = TSK.Setting_HotbarStartIndex_Name,
        Description = TSK.Setting_HotbarStartIndex_Description,
        Min = 1,
        Max = 145, -- TODO consider HotbarSlots min?
        Step = 1,
        HideNumbers = false,
        DefaultValue = 1,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    HotbarSlots = RadialMenus:RegisterSetting("HotbarSlots", {
        Type = "ClampedNumber",
        Name = CommonStrings.Slots,
        Description = TSK.Setting_HotbarSlots_Description,
        Min = 5, -- 1/2-slot radial menus break the fabric of reality, low amounts look bad with the curve graphics
        Max = 20,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 10,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    Skill = RadialMenus:RegisterSetting("MenuCreator.Skill", {
        Type = "Skill",
        Name = CommonStrings.Name, -- I don't feel this needs a description.
        DefaultValue = "",
    }),

    -- Slot settings
    SlotType = RadialMenus:RegisterSetting("MenuCreator.SlotType", {
        Type = "Choice",
        Name = TSK.Setting_SlotType_Name,
        Description = TSK.Setting_SlotType_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            -- TODO support items
            {ID = "Empty", Name = CommonStrings.Empty:GetString()},
            {ID = "Skill", Name = CommonStrings.Skill:GetString()},
            -- {ID = "Item", Name = CommonStrings.Item:GetString()},
            {ID = "InputAction", Name = CommonStrings.Keybind:GetString()},
        }
    }),
    ---@type SettingsLib_Setting_Choice
    InputAction = RadialMenus:RegisterSetting("MenuCreator.InputAction", {
        Type = "Choice",
        Name = CommonStrings.Keybind,
        Description = TSK.Setting_Keybind_Description,
        DefaultValue = "",
        Choices = {}, -- Generated when rendering the setting.
    }),
}

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.RadialMenus.UI.MenuCreator.Hooks.CreateMenu
---@field Menu Features.RadialMenus.Menu? Hookable. Defaults to `nil`.

---@class Features.RadialMenus.UI.MenuCreator.Events.RenderMenuSettings
---@field MenuType classname
---@field Container GenericUI_Element_VerticalList

---@class Features.RadialMenus.UI.MenuCreator.Events.RenderSlotSettings
---@field Slot Features.RadialMenus.Slot
---@field Container GenericUI_Element_VerticalList

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI to create a new menu.
function UI.SetupCreation()
    UI._CurrentMode = "CreateMenu"
    UI._MenuBeingEdited = nil
    UI._Setup()
end

---Sets up the UI to edit an existing menu.
---@param menu Features.RadialMenus.Menu
function UI.SetupEditMenu(menu)
    UI._CurrentMode = "EditMenu"
    UI._MenuBeingEdited = menu
    UI._Setup()
end

---Sets up the UI to edit a custom slot.
---@param menu Features.RadialMenus.Menu
---@param index integer
---@param slot Features.RadialMenus.Slot
function UI.SetupEditSlot(menu, index, slot)
    UI._CurrentMode = "EditSlot"
    UI._MenuBeingEdited = menu
    UI._SlotIndex = index
    UI._SlotBeingEdited = slot

    -- Set settings to the slot's current ones
    local slotType = slot.Type
    Settings.SlotType:SetValue(slotType)
    if slotType == "Skill" then
        -- TODO
    elseif slotType == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        Settings.InputAction:SetValue(slot.ActionID)
    elseif slotType == "Item" then
        -- TODO
    end

    UI._Setup()
end

function UI._Setup()
    local mode = UI._CurrentMode
    local isEditing = mode == "EditMenu" or mode == "EditSlot"
    UI._Initialize()

    -- Update static elements
    UI.CreateButton:SetLabel(isEditing and CommonStrings.Save or CommonStrings.Create)
    UI.Header:SetText(UI.MODE_HEADERS[UI._CurrentMode] or "Please update header TSK list")

    UI._RenderSettings()

    UI:SetPositionRelativeToViewport("center", "center")
    UI:Show()
end

---Creates a menu from the current setting values and closes the UI.
function UI._CreateMenu()
    local menu = UI.Hooks.CreateMenu:Throw({
        Menu = nil,
    }).Menu
    if menu then -- Add the menu and set it as the active one
        RadialMenus.AddMenu(menu)
        RadialMenuUI.SetCurrentMenu(menu)
    else
        UI:__LogWarning("_CreateMenu()", "No CreateMenu hooks responded")
    end
    UI:Hide()
end

---Applies the edits to the current menu.
function UI._SaveEdits()
    if UI._CurrentMode == "EditMenu" then
        UI.Events.UpdateMenu:Throw({
            Menu = UI._MenuBeingEdited,
        })
    elseif UI._CurrentMode == "EditSlot" then
        local slot = UI.Hooks.UpdateSlot:Throw({
            Slot = UI._SlotBeingEdited,
        }).Slot
        local menu = UI._MenuBeingEdited ---@cast menu Features.RadialMenus.Menu.Custom
        menu:SetSlot(UI._SlotIndex, slot)
    else
        UI:__Error("_SaveEdits", "Called in unsupported mode", UI._CurrentMode)
    end
    RadialMenuUI.Refresh()
    UI:Hide()
end

---Initializes the static elements of the UI.
function UI._Initialize()
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Texture")
    root:SetTexture(Textures.PANELS.CLIPBOARD_FEEDBACK)
    UI.Root = root

    -- Auxiliary rect to simplify positioning
    local contentArea = root:AddChild("Content", "GenericUI_Element_TiledBackground")
    contentArea:SetBackground("Black", UI.CONTENT_SIZE:unpack())
    contentArea:SetAlpha(0)
    contentArea:SetPositionRelativeToParent("TopLeft", 100, 100)

    local header = TextPrefab.Create(UI, "Header", contentArea, "", "Center", V(500, 50))
    header:SetPositionRelativeToParent("Top")
    UI.Header = header

    local contentList = contentArea:AddChild("ContentList", "GenericUI_Element_ScrollList")
    contentList:SetPositionRelativeToParent("TopLeft", 0, 50)
    contentList:SetFrame(UI.CONTENT_SIZE)
    UI.ContentList = contentList

    -- Setting lists
    local sharedSettingsList = contentList:AddChild("SharedSettingsList", "GenericUI_Element_VerticalList")
    UI.SharedSettingsList = sharedSettingsList
    UI._RenderSharedSettings()

    local menuSpecificSettingsList = contentList:AddChild("MenuSpecificSettingsList", "GenericUI_Element_VerticalList")
    UI.MenuSpecificSettingsList = menuSpecificSettingsList
    UI._RenderMenuTypeSettings()

    -- "Create" button
    local createButton = ButtonPrefab.Create(UI, "CreateButton", root, ButtonPrefab:GetStyle("DOS1Blue"))
    createButton:SetLabel(CommonStrings.Create)
    createButton:SetPositionRelativeToParent("Bottom", 0, -50)
    createButton.Events.Pressed:Subscribe(function (_)
        UI._Finish()
    end)
    UI.CreateButton = createButton

    -- Set panel size
    local uiObj = UI:GetUI()
    uiObj.SysPanelSize = {root:GetSize():unpack()}

    UI._Initialized = true
end

---Renders the settings for the current mode and object.
function UI._RenderSettings()
    local mode = UI._CurrentMode
    if mode == "EditSlot" then
        UI._RenderSlotSettings()
    elseif mode == "CreateMenu" or mode == "EditMenu" then
        UI._RenderSharedSettings()
        UI._RenderMenuTypeSettings()
    end
    UI._PositionLists()
end

---Renders the shared setting widgets.
function UI._RenderSharedSettings()
    local list = UI.SharedSettingsList
    list:Clear()

    SettingWidgets.RenderSetting(UI, list, Settings.MenuName, UI.SETTING_SIZE)

    -- Cannot edit the type of existing menus.
    if not UI._IsEditingMenu() then
        SettingWidgets.RenderSetting(UI, list, Settings.NewMenuType, UI.SETTING_SIZE, function (_)
            UI._RenderMenuTypeSettings()
            UI._PositionLists()
        end)
    end
end

---Renders settings specific to the selected menu type.
---@see Features.RadialMenus.UI.MenuCreator.Events.RenderMenuSettings
function UI._RenderMenuTypeSettings()
    local list = UI.MenuSpecificSettingsList
    list:Clear()
    UI.Events.RenderMenuSettings:Throw({
        MenuType = Settings.NewMenuType:GetValue(),
        Container = list,
    })
end

---Renders the settings for the slot being edited.
function UI._RenderSlotSettings()
    local sharedList = UI.SharedSettingsList
    sharedList:Clear()
    SettingWidgets.RenderSetting(UI, sharedList, Settings.SlotType, UI.SETTING_SIZE, function (_)
        -- Refresh settings when type is changed
        UI._RenderSpecificSlotSettings()
        UI._PositionLists()
    end)
    UI._RenderSpecificSlotSettings()
end

---Renders the settings specific to the current slot's type.
function UI._RenderSpecificSlotSettings()
    local specificList = UI.MenuSpecificSettingsList
    specificList:Clear()
    UI.Events.RenderSlotSettings:Throw({
        Slot = UI._SlotBeingEdited,
        Container = specificList,
    })
end

---Renders the dropdown for the input action picker.
---@param container GenericUI_Element_VerticalList
function UI._RenderInputActionDropdown(container)
    local actions = {} ---@type InputLib_Action[]
    local choices = {} ---@type SettingsLib_Setting_Choice_Entry[]
    for _,action in pairs(Input.GetActions()) do
        table.insert(actions, action)
    end
    table.sort(actions, function (a, b) -- Sort alphabetically
        return a:GetName() < b:GetName()
    end)
    for i,action in ipairs(actions) do
        choices[i] = {ID = action:GetID(), Name = action:GetName()}
    end
    Settings.InputAction:SetChoices(choices)
    SettingWidgets.RenderSetting(UI, container, Settings.InputAction, UI.SETTING_SIZE)

    -- Set the value of the setting if unitialized
    if Settings.InputAction:GetValue() == "" then
        Settings.InputAction:SetValue(choices[1].ID)
    end
end

---Confirms the creation or edits of the menu.
function UI._Finish()
    local mode = UI._CurrentMode
    if mode == "CreateMenu" then
        UI._CreateMenu()
    elseif mode == "EditMenu" or mode == "EditSlot" then
        UI._SaveEdits()
    else
        UI:__Error("_Finish", "Unsupported mode", mode)
    end
end

---Returns whether the UI is being used to edit an existing menu.
---@return boolean
function UI._IsEditingMenu()
    return UI._CurrentMode == "EditMenu"
end

---Returns whether the UI is being used to edit a custom slot.
---@return boolean
function UI._IsEditingSlot()
    return UI._CurrentMode == "EditSlot"
end

---Repositions all content lists.
function UI._PositionLists()
    UI.SharedSettingsList:RepositionElements()
    UI.MenuSpecificSettingsList:RepositionElements()
    UI.ContentList:RepositionElements()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show the creator UI when menu operations are requested.
RadialMenuUI.Events.NewMenuRequested:Subscribe(function (_)
    UI.SetupCreation()
end)
RadialMenuUI.Events.EditMenuRequested:Subscribe(function (ev)
    UI.SetupEditMenu(ev.Menu)
end)
RadialMenuUI.Events.EditSlotRequested:Subscribe(function (ev)
    UI.SetupEditSlot(ev.Menu, ev.Index, ev.Slot)
end)

-- Create menus when requested.
UI.Hooks.CreateMenu:Subscribe(function (ev)
    local menuClass = Settings.NewMenuType:GetValue()
    local menuName = Settings.MenuName:GetValue()
    if menuClass == MenuTypes.Hotbar:GetClassName() then -- Hotbar
        local startingIndex, slots = Settings.HotbarStartIndex:GetValue(), Settings.HotbarSlots:GetValue()
        ev.Menu = MenuTypes.Hotbar.Create(menuName, startingIndex, slots)
    elseif menuClass == MenuTypes.Custom:GetClassName() then -- Custom
        local slots = Settings.HotbarSlots:GetValue()
        ev.Menu = MenuTypes.Custom.Create(menuName, slots)
    end
end, {StringID = "DefaultImplementation"})

-- Apply menu edits.
UI.Events.UpdateMenu:Subscribe(function (ev)
    local menu = ev.Menu
    menu.Name = Settings.MenuName:GetValue()
    if menu:GetClassName() == MenuTypes.Hotbar:GetClassName() then
        ---@cast menu Features.RadialMenus.Menu.Hotbar
        menu.StartingIndex = Settings.HotbarStartIndex:GetValue()
        menu.SlotsAmount = Settings.HotbarSlots:GetValue()
    elseif menu:GetClassName() == MenuTypes.Custom:GetClassName() then
        ---@cast menu Features.RadialMenus.Menu.Custom
        menu:SetSlotsAmount(Settings.HotbarSlots:GetValue())
    end
end, {StringID = "DefaultImplementation"})

-- Apply slot edits.
UI.Hooks.UpdateSlot:Subscribe(function (ev)
    local newType = Settings.SlotType:GetValue() ---@type Features.RadialMenus.Slot.Type
    if newType == "Skill" then
        ev.Slot = RadialMenus.CreateSkillSlot(Settings.Skill:GetValue())
    elseif newType == "InputAction" then
        ev.Slot = RadialMenus.CreateInputActionSlot(Settings.InputAction:GetValue())
    elseif newType == "Item" then
        -- TODO!
    elseif newType == "Empty" then
        ev.Slot = table.shallowCopy(RadialMenus.EMPTY_SLOT)
    end
end, {StringID = "DefaultImplementation"})

-- Render menu-specific settings.
UI.Events.RenderMenuSettings:Subscribe(function (ev)
    local container = ev.Container
    if ev.MenuType == MenuTypes.Hotbar:GetClassName() then
        SettingWidgets.RenderSetting(UI, container, Settings.HotbarStartIndex, UI.SETTING_SIZE)
        SettingWidgets.RenderSetting(UI, container, Settings.HotbarSlots, UI.SETTING_SIZE)
    elseif ev.MenuType == MenuTypes.Custom:GetClassName() then
        SettingWidgets.RenderSetting(UI, container, Settings.HotbarSlots, UI.SETTING_SIZE) -- TODO rename
    end
end, {StringID = "DefaultImplementation"})

-- Render slot-specific settings.
UI.Events.RenderSlotSettings:Subscribe(function (ev)
    local container, slotType = ev.Container, Settings.SlotType:GetValue()
    if slotType == "Skill" then
        SettingWidgets.RenderSetting(UI, container, Settings.Skill, UI.SLOT_SETTING_SIZE)
    elseif slotType == "InputAction" then
        UI._RenderInputActionDropdown(container)
    end
end)
