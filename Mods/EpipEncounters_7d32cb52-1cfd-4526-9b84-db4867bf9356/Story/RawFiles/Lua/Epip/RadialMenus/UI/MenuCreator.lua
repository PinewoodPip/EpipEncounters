
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local MsgBox = Client.UI.MessageBox
local Input = Client.Input
local CommonStrings = Text.CommonStrings
local V = Vector.Create

local RadialMenus = Epip.GetFeature("Features.RadialMenus") ---@class Features.RadialMenus
local RadialMenuUI = RadialMenus.UI
local TSK = RadialMenus.TranslatedStrings

local UI = Generic.Create("Features.RadialMenus.UI.MenuCreator", {Layer = 8, Visible = false}) ---@class Features.RadialMenus.UI.MenuCreator : GenericUI_Instance -- Layer 9 is KBM skillbook UI.
RadialMenus.MenuCreatorUI = UI
UI.CONTENT_SIZE = V(670, 500)
UI.HEADER_SIZE = V(400, 50)
UI.HEADER_FONT_SIZE = 23
UI.SETTING_SIZE = V(650, 50)
UI.SLOT_SETTING_SIZE = V(UI.SETTING_SIZE[1], 70) -- Size for settings that render as hotbar slots.
UI.MSGBOXID_DELETE_MENU = "Features.RadialMenus.UI.MenuCreator.DeleteMenu"
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
UI.Events.Initialized = UI:AddSubscribableEvent("Initialized") ---@type Event<Empty>
UI.Events.Opened = UI:AddSubscribableEvent("Opened") ---@type Event<Empty>
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
        Min = 4, -- 1/2-slot radial menus break the fabric of reality
        Max = 20,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 10,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    Skill = RadialMenus:RegisterSetting("MenuCreator.Skill", {
        Type = "Skill",
        Name = CommonStrings.Skill,
        Description = TSK.Setting_Skill_Description,
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
    local menuType = menu:GetClassName()
    UI._CurrentMode = "EditMenu"
    UI._MenuBeingEdited = menu

    -- Set settings to the menu's current ones
    Settings.MenuName:SetValue(menu.Name)
    Settings.NewMenuType:SetValue(menuType)
    if menuType == MenuTypes.Hotbar:GetClassName() then
        ---@cast menu Features.RadialMenus.Menu.Hotbar
        Settings.HotbarStartIndex:SetValue(menu.StartingIndex)
        Settings.HotbarSlots:SetValue(menu.SlotsAmount)
    elseif menuType == MenuTypes.Custom:GetClassName() then
        ---@cast menu Features.RadialMenus.Menu.Custom
        Settings.HotbarSlots:SetValue(#menu:GetSlots())
    else
        UI:__LogWarning("Editing unsupported menu type", menuType) -- TODO event
    end

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
        ---@cast slot Features.RadialMenus.Slot.Skill
        Settings.Skill:SetValue(slot.SkillID)
    elseif slotType == "InputAction" then
        ---@cast slot Features.RadialMenus.Slot.InputAction
        Settings.InputAction:SetValue(slot.ActionID)
    elseif slotType == "Item" then
        -- TODO
    else
        UI:__LogWarning("Editing unsupported slot type", slotType) -- TODO event
    end

    UI._Setup()
end

---Confirms the creation or edits of the menu.
function UI.Finish()
    local mode = UI._CurrentMode
    if mode == "CreateMenu" then
        UI._CreateMenu()
    elseif mode == "EditMenu" or mode == "EditSlot" then
        UI._SaveEdits()
    else
        UI:__Error("_Finish", "Unsupported mode", mode)
    end
end

---Prompts the user to delete the current menu.
function UI.RequestDeleteMenu()
    if UI._CurrentMode ~= "EditMenu" then UI:__Error("_DeleteMenu", "UI is not in menu edit mode") end
    MsgBox.Open({
        ID = UI.MSGBOXID_DELETE_MENU,
        Header = TSK.MsgBox_DeleteMenu_Title:GetString(),
        Message = TSK.MsgBox_DeleteMenu_Body:Format(UI._MenuBeingEdited.Name),
        Buttons = {
            {ID = 1, Text = CommonStrings.Delete:GetString()},
            {ID = 2, Text = CommonStrings.Cancel:GetString()},
        },
    })
end

---Returns whether the UI is being used to edit an existing menu.
---@return boolean
function UI.IsEditingMenu()
    return UI._CurrentMode == "EditMenu"
end

---Returns whether the UI is being used to edit a custom slot.
---@return boolean
function UI.IsEditingSlot()
    return UI._CurrentMode == "EditSlot"
end

function UI._Setup()
    local mode = UI._CurrentMode
    local isEditing = mode == "EditMenu" or mode == "EditSlot"
    UI._Initialize()

    -- Update static elements
    UI.CreateButton:SetLabel(isEditing and CommonStrings.Save or CommonStrings.Create)
    UI.Header:SetText(Text.Format(UI.MODE_HEADERS[UI._CurrentMode] or "Please update header TSK list", {Size = UI.HEADER_FONT_SIZE}))

    -- Only menus can be deleted; slots must be set to "empty", or removed by decrementing the amount of slots of the Custom menu.
    UI.DeleteButton:SetVisible(mode == "EditMenu")
    UI.ButtonsBar:RepositionElements()
    UI.ButtonsBar:SetPositionRelativeToParent("Bottom", 0, -60)

    UI._RenderSettings()

    Client.UI.Input.SetMouseWheelBlocked(false) -- Unblock mouse wheel so it's usable in dropdowns.

    if RadialMenuUI:IsVisible() and Client.IsUsingController() then -- Disable modal on main UI to gain control
        RadialMenuUI:GetUI().OF_PlayerModal1 = false
    end
    UI:SetPositionRelativeToViewport("center", "center")
    UI:Show()
    UI.Events.Opened:Throw()
end

---Creates a menu from the current setting values and closes the UI.
function UI._CreateMenu()
    local menu = UI.Hooks.CreateMenu:Throw({
        Menu = nil,
    }).Menu
    if menu then -- Add the menu and set it as the active one
        RadialMenus.AddMenu(menu)
        RadialMenus.SaveData()
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
    RadialMenus.SaveData()
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
    header:SetStroke(Color.Create(0, 0, 0):ToDecimal(), 2, 1, 15, 15)
    UI.Header = header

    local contentList = contentArea:AddChild("ContentList", "GenericUI_Element_ScrollList")
    contentList:SetPositionRelativeToParent("TopLeft", 0, 50)
    contentList:SetFrame(UI.CONTENT_SIZE)
    UI.ContentList = contentList

    -- Setting lists
    local sharedSettingsList = contentList:AddChild("SharedSettingsList", "GenericUI_Element_VerticalList")
    UI.SettingsList = sharedSettingsList
    UI._RenderMenuSettings()

    -- Create/save & delete buttons
    local buttonsBar = root:AddChild("BottomButtons", "GenericUI_Element_HorizontalList")
    UI.ButtonsBar = buttonsBar

    local createButton = ButtonPrefab.Create(UI, "CreateButton", buttonsBar, ButtonPrefab:GetStyle("DOS1Blue"))
    createButton:SetLabel(CommonStrings.Create)
    createButton.Events.Pressed:Subscribe(function (_)
        UI.Finish()
    end)
    UI.CreateButton = createButton

    local deleteButton = ButtonPrefab.Create(UI, "DeleteButton", buttonsBar, ButtonPrefab:GetStyle("RedDOS1"))
    deleteButton:SetLabel(CommonStrings.Delete)
    deleteButton.Events.Pressed:Subscribe(function (_)
        UI.RequestDeleteMenu()
    end)
    UI.DeleteButton = deleteButton

    -- Close button
    local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", root, ButtonPrefab:GetStyle("CloseStone"))
    closeButton:SetPositionRelativeToParent("TopRight", -47, 58)

    -- Set panel size
    local uiObj = UI:GetUI()
    uiObj.SysPanelSize = {root:GetSize():unpack()}

    UI._Initialized = true
    UI.Events.Initialized:Throw()
end

---Renders the settings for the current mode and object.
function UI._RenderSettings()
    local mode = UI._CurrentMode
    if mode == "EditSlot" then
        UI._RenderSlotSettings()
    elseif mode == "CreateMenu" or mode == "EditMenu" then
        UI._RenderMenuSettings()
    end
    UI._PositionLists()
end

---Renders the shared setting widgets.
---@see Features.RadialMenus.UI.MenuCreator.Events.RenderMenuSettings
function UI._RenderMenuSettings()
    local list = UI.SettingsList
    local preventCallbacks = true -- Awkward workaround for an unknown infinite update loop.
    list:Clear()

    SettingWidgets.RenderSetting(UI, list, Settings.MenuName, UI.SETTING_SIZE)

    -- Cannot edit the type of existing menus.
    if not UI.IsEditingMenu() then
        SettingWidgets.RenderSetting(UI, list, Settings.NewMenuType, UI.SETTING_SIZE, function (_)
            -- Refresh settings when menu type is changed.
            if not preventCallbacks then
                UI._RenderMenuSettings()
                UI._PositionLists()
            end
        end)
    end
    Timer.Start(0.2, function (_)
        preventCallbacks = false
    end)

    -- Render type-specific settings.
    UI.Events.RenderMenuSettings:Throw({
        MenuType = Settings.NewMenuType:GetValue(),
        Container = list,
    })
end

---Renders the settings for the slot being edited.
function UI._RenderSlotSettings()
    local list = UI.SettingsList
    local preventCallbacks = true -- Awkward workaround for an unknown infinite update loop.
    list:Clear()
    SettingWidgets.RenderSetting(UI, list, Settings.SlotType, UI.SETTING_SIZE, function (_)
        -- Refresh settings when type is changed.
        if not preventCallbacks then
            UI._RenderSlotSettings()
            UI._PositionLists()
        end
    end)
    Timer.Start(0.2, function (_)
        preventCallbacks = false
    end)

    -- Render type-specific settings.
    UI.Events.RenderSlotSettings:Throw({
        Slot = UI._SlotBeingEdited,
        Container = list,
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

---Deletes the current menu.
function UI._DeleteMenu()
    if UI._CurrentMode ~= "EditMenu" then UI:__Error("_DeleteMenu", "UI is not in menu edit mode") end
    RadialMenus.RemoveMenu(UI._MenuBeingEdited)
    UI:Hide()
    RadialMenuUI.Refresh()
    RadialMenus.SaveData()
end

---Repositions all content lists.
function UI._PositionLists()
    UI.SettingsList:RepositionElements()
    UI.ContentList:RepositionElements()
end

---@override
function UI:Hide()
    if RadialMenuUI:IsVisible() and Client.IsUsingController() then -- Re-enable modal on main UI to restore previous behaviour
        RadialMenuUI:GetUI().OF_PlayerModal1 = true
    end
    Client.UI._BaseUITable.Hide(self)
    Client.UI.Input.SetMouseWheelBlocked(RadialMenuUI:IsVisible()) -- Reblock mouse wheel if necessary.
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
        ev.Slot = RadialMenus.CreateEmptySlot()
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

-- Handle menu deletion requests.
MsgBox.RegisterMessageListener(UI.MSGBOXID_DELETE_MENU, MsgBox.Events.ButtonPressed, function (buttonID)
    if buttonID == 1 then
        UI._DeleteMenu()
    end
end)
