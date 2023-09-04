
-- Scripting for a new, custom context-menu UI. This does not hook the original UI, as it is limited in functionality.

-- TODO
-- Make it block clicks to world while active (overlay API - separate element)
-- option to not close menu upon button click

-- Scrollbars
-- Icon button element
-- +/- button element (shift click would add/remove 10 at a time)
-- Shift-click to not close on button press
-- Cleanup!!! especially elementdata storing
-- support submenus in getList()

-- fix clicking to close
-- recenter amount text upon change

---@class ContextMenuUI : UI
---@field _LatestHoveredCharacterHandle CharacterHandle
---@field _LatestHoveredItemHandle ItemHandle
local ContextMenu = {
    VANILLA_ACTIONS = {
        SIT = 2,
        LOOT_CHARACTER = 3,
        PICK_UP = 4,
        ATTACK = 6,
        TALK = 11,
        CHAIN = 13,
        UNCHAIN = 14,
        PICKPOCKET = 15,
        SEND_TO_CHARACTER = 18,
        DROP = 20,
        EXAMINE = 22,
    },

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    state = {
        subMenus = {},
        menu = {
            id = "main",
            entries = {},
        },
    },
    elements = {},
    menuHandlers = {},
    position = {},
    selectedElements = {},
    elementsCount = 0,
    vanillaContextData = nil,

    ARRAY_ENTRY_TEMPLATES = {
        BUTTON = {
            "Index",
            "ActionID",
            "PlayClickSound",
            "Unused1",
            "Label",
            "Disabled",
            "Legal",
        },
    },

    MAX_HEIGHT = 500,

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/contextMenu.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/contextMenu.swf",
    },
}
Epip.InitializeUI(Ext.UI.TypeID.contextMenu.Object, "ContextMenu", ContextMenu)

---@type table<integer, true>
ContextMenu.ITEM_ACTIONS = {
    [ContextMenu.VANILLA_ACTIONS.SEND_TO_CHARACTER] = true,
    [ContextMenu.VANILLA_ACTIONS.DROP] = true,
    [ContextMenu.VANILLA_ACTIONS.PICK_UP] = true,
    [ContextMenu.VANILLA_ACTIONS.SIT] = true,
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class ContextMenuUI_ArrayEntry_Button
---@field Index integer 0-based. Used by the engine instead of the action ID.
---@field ActionID integer
---@field PlayClickSound boolean
---@field Unused1 ""
---@field Label string
---@field Disabled boolean
---@field Legal boolean

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the character associated with the currently open context menu.
---@param force boolean?
---@return EclCharacter?
function ContextMenu.GetCurrentCharacter(force)
    local char = nil
    if ContextMenu.IsOpen() or force then
        char = Character.Get(ContextMenu._LatestHoveredCharacterHandle)
    end
    return char
end

---Register a listener for a UI Call raw event.
---@override Necessary to distinguish between the 2 instances.
---@param method string ExternalInterface call name.
---@param handler fun(ev:EclLuaUICallEvent)
---@param uiInstance "Vanilla"|"Custom"
---@param when? "Before"|"After"
function ContextMenu:RegisterCallListener(method, handler, uiInstance, when)
    Client.UI._BaseUITable.RegisterCallListener(self, method, function (ev)
        if ev.UI:GetTypeId() < 1000 and uiInstance == "Vanilla" then
            handler(ev)
        elseif uiInstance == "Custom" then
            handler(ev)
        end
    end, when)
end

---Register a listener for a UI Invoke raw event.
---@override Necessary to distinguish between the 2 instances.
---@param method string ExternalInterface call name.
---@param handler fun(ev:EclLuaUICallEvent)
---@param uiInstance "Vanilla"|"Custom"
---@param when? "Before"|"After"
function ContextMenu:RegisterInvokeListener(method, handler, uiInstance, when)
    Client.UI._BaseUITable.RegisterInvokeListener(self, method, function (ev)
        if ev.UI:GetTypeId() < 1000 and uiInstance == "Vanilla" then
            handler(ev)
        elseif uiInstance == "Custom" then
            handler(ev)
        end
    end, when)
end

function ContextMenu.SetPosition(ui, x, y)
    ui = ui or ContextMenu.GetActiveUI()
    -- TODO pushback near edges
    x = x or ContextMenu.position.x
    y = y or ContextMenu.position.y

    local root = ui:GetRoot()

    root.contextMenusList.y = 0

    ContextMenu.position = {x = x, y = y}

    for i=0,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]

        menu.x = x + (i * 265)
        menu.y = y

        -- TEMP!!!
        -- TODO pushback (keepInScreen)
        -- if i == 0 then
        --     menu.x = 0
        --     menu.y = 0
        -- end

        -- local bottom = menu.y + menu.height
        -- local stageHeight = ContextMenu.Root.stage.fullScreenHeight

        -- Ext.Print(bottom, stageHeight)
        -- if bottom > stageHeight then
        --     menu.y = menu.y - (menu.y + menu.height - stageHeight)
        -- end
    end
end

-- Adds a single entry to a menu, "main" by default.
function ContextMenu.AddElement(entry, menu)
    local ui = ContextMenu.GetActiveUI()
    menu = menu or "main"

    ContextMenu.AddElements(ui, {
        id = menu,
        entries = entry,
    })
end

-- Get a numeric id for the next element.
function ContextMenu.GetNextElementNumID()
    -- elementsCount is intended to track how many indexes are being used up by vanilla context menu entries.
    return ContextMenu.elementsCount + #ContextMenu.state.menu.entries
end

function ContextMenu:GetUI()
    return ContextMenu.GetActiveUI()
end

function ContextMenu:GetRoot()
    return ContextMenu:GetUI():GetRoot()
end

function ContextMenu.GetSubMenus(ui)
    local root = ui:GetRoot()
    local menus = {}
    for i=1,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]

        menus[menu.list_string_id] = menu
    end
    return menus
end

function ContextMenu.GetElementData(id)
    return ContextMenu.elements[id]
end

function ContextMenu.AddSubMenu(data)

    local ui = ContextMenu.GetActiveUI()

    local root = ui:GetRoot()

    Ext.Print("Adding new submenu: " .. data.menu.id)

    root.spawnContextMenu(data.menu.id)

    ContextMenu.AddElements(ui, data.menu)

    local subMenu = ContextMenu.GetSubMenus(ui)[data.menu.id]
    subMenu.updateDone() -- only need to update our new menu, doing it for all means re-playing the opening animation
    subMenu.visible = true

    ContextMenu.SetPosition(ui, ContextMenu.position.x, ContextMenu.position.y)
end

function ContextMenu.Setup(data)
    local root = ContextMenu.Root

    for i=0,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]
        
        menu.list.clearElements()
    end

    ContextMenu.elements = {}
    ContextMenu.selectedElements = {}

    Utilities.Log("ContextMenu", "Setting up new menu")

    ContextMenu.state = {
        subMenus = {},
        menu = {
            id = "main",
            entries = {}
        }
    }

    -- add entries
    data.id = "main" -- first menu is always main
    ContextMenu.AddElements(ContextMenu.UI, data.menu)
end

---@param position Vector2?
function ContextMenu.Open(position)
    local root = ContextMenu.Root
    if type(position) ~= "table" then
        position = Vector.Create(ContextMenu.position.x, ContextMenu.position.y)
    end

    ContextMenu.SetPosition(ContextMenu.UI, position[1], position[2])

    root.open()
    ContextMenu.UI:Show()

    ContextMenu.Root.windowsMenu_mc.updateDone()

    -- TODO!
    -- if tryPushBack and ContextMenu.GetActiveUI():GetRoot().isCustomInstance then

    -- end
end

function ContextMenu.Close(ui)
    ui = ui or ContextMenu.GetActiveUI()

    local root = ui:GetRoot()
    root.close()

    ContextMenu.Cleanup(ui)
end

function ContextMenu.IsOpen()
    return ContextMenu.GetActiveUI().OF_Visible
end

local function UpdateLatestHoveredCharacter()
    -- Living characters are prioritized.
    local char = Pointer.GetCurrentCharacter(nil, true)

    -- Do not update the char is a context menu is already open.
    if char and not ContextMenu.IsOpen() then
        ContextMenu._LatestHoveredCharacterHandle = char.Handle
        ContextMenu._LatestHoveredItemHandle = nil
    end
end
local function UpdateLatestHoveredItem()
    local item = Pointer.GetCurrentItem()

    if item and not ContextMenu.IsOpen() then
        ContextMenu._LatestHoveredItemHandle = item.Handle
        ContextMenu._LatestHoveredCharacterHandle = nil
    end
end

function ContextMenu.Cleanup(ui)
    ContextMenu.state = {
        subMenus = {},
        menu = {
            id = "main",
            entries = {},
        },
    }
    ContextMenu.selectedElements = {}
    UpdateLatestHoveredCharacter()
    UpdateLatestHoveredItem()
    ContextMenu.itemHandle = nil
    ContextMenu.elementsCount = 0

    local root = ui:GetRoot()

    -- only call Hide() and position on our custom instance
    -- merely hiding it does not stop mouse events?
    if root.isCustomInstance then
        ui:Hide()
        ContextMenu.SetPosition(ui, -999, -999)
        root.contextMenusList.height = 0
    end   
end

function ContextMenu.RegisterElementListener(elementID, type, callback)
    Utilities.Hooks.RegisterListener("PIP_ContextMenu", type .. "_" .. elementID, callback)
end

-- TODO support multiple??? or fire event?
function ContextMenu.RegisterMenuHandler(id, callback)
    ContextMenu.menuHandlers[id] = callback
end

function ContextMenu.RegisterVanillaMenuHandler(type, callback)
    Utilities.Hooks.RegisterListener("PIP_ContextMenu", "VanillaMenu_" .. type, callback)
end

function ContextMenu.RegisterStatDisplayHook(elementID, handler)
    Utilities.Hooks.RegisterHook("PIP_ContextMenu", "statDisplay_" .. elementID, handler)
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------
function ContextMenu.AddElements(ui, menuData)
    ui = ui or ContextMenu.GetActiveUI()
    local menuID = menuData.id
    for i,data in pairs(menuData.entries) do
        local type = data.type

        data.menu = menuID
        if data.closeOnButtonPress == nil then
            data.closeOnButtonPress = not (data.type == "stat" or data.type == "subMenu") -- stat and submenu elements do not close on press by default
        end

        -- elements are selectable by default
        if data.selectable == nil then
            data.selectable = true
        end

        -- TODO make this use hooks! to allow for custom-defined elements!
        if type == "button" then
            ContextMenu.AddButton(ui, menuID, data.id, data.text, data.greyedOut, data.legal, data)
        elseif type == "checkbox" then
            ContextMenu.AddCheckbox(ui, menuID, data.id, data.text, data.checked, data.greyedOut, data.legal, data)
        elseif type == "header" then
            ContextMenu.AddHeader(ui, menuID, data.id, data.text, data)
        elseif type == "subMenu" then
            ContextMenu.AddSubMenuElement(ui, menuID, data.id, data.text, data.subMenu, data)
        elseif type == "stat" then
            ContextMenu.AddStatEntry(ui, menuID, data)
        elseif type == "removable" then
            ContextMenu.AddRemovableEntry(ui, menuID, data)
        end

        ContextMenu.SetupIcon(ui, menuID, data)

        ContextMenu.elements[data.id] = data
    end
end

function ContextMenu.GetText(elementData)
    -- grey out text
    local text = elementData.text

    if elementData.requireShiftClick then
        text = text .. " (Shift+Click)"
    end

    if elementData.faded then
        text = "<font color='#59564f'>" .. text .. "</font>"
    end

    return text
end

-- Get the currently-used Context Menu UI instance, defaulting to the custom one if neither is being used.
function ContextMenu.GetActiveUI()
    local ui = ContextMenu.UI

    if not ContextMenu.Root.visible then
        ui = Ext.UI.GetByType(Ext.UI.TypeID.contextMenu.Object) or Ext.UI.GetByType(Ext.UI.TypeID.contextMenu.Default)
    end

    return ui
end

function ContextMenu.SetupIcon(ui, menuID, data)
    local element = ContextMenu.GetLastElement(ui, menuID)

    if data.icon then
        local iconName = "pip_contextmenu_" .. data.id
        element.iggy_icon.name = "iggy_" .. iconName
        element.iggy_icon.visible = true
        element.iggy_icon.y = 5
        element.iggy_icon.x = -7
        ui:SetCustomIcon(iconName, data.icon, 20, 20)
    end
end

function ContextMenu.RequestMenu(x, y, id, ui, requestingElementData, ...)
    if not ui then ui = ContextMenu.UI end
    ContextMenu.SetPosition(ui, x, y)

    -- track submenus
    if id ~= "main" then
        ContextMenu.state.subMenus[id] = {subMenus = {}}
    end
    if ContextMenu.menuHandlers[id] then
        ContextMenu.menuHandlers[id](ContextMenu.GetCurrentEntity(), requestingElementData, ...)
    else
        Utilities.LogWarning("ContextMenu", "Context menu " .. id .. " has no handler. Setup context menus with ContextMenu.RegisterMenuHandler(id, callback)")
    end

    -- hook to perform stuff after the normal handling.
    Utilities.Hooks.FireEvent("PIP_ContextMenu", "contextMenuRequested", id)
end

function ContextMenu.AddButton(ui, menuID, elementID, text, greyedOut, legal, data)
    local root = ui:GetRoot()
    local elementData = data
    
    table.insert(ContextMenu.state.menu.entries, elementData)

    local numID = ContextMenu.GetNextElementNumID()
    root.addButton(menuID, numID, elementID, true, ContextMenu.GetText(data), greyedOut or false, legal or true)

    local element = ContextMenu.GetLastElement(ui, menuID)

    if not elementData.selectable then -- TODO add a distinction between unselectable and disabled?
        element.selectable = false
        element.disabled = true
    end
end

function ContextMenu.GetMenuElement(ui, menuID)
    local root = ui:GetRoot()
    for i=0,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]

        if menu.list_string_id == menuID then
            return menu
        end
    end
end

function ContextMenu.AddCheckbox(ui, menuID, elementID, text, checked, greyedOut, legal, data)
    local root = ui:GetRoot()
    local elementData = data
    
    table.insert(ContextMenu.state.menu.entries, elementData)

    local elementNumID = ContextMenu.GetNextElementNumID()
    root.addCheckbox(menuID, elementNumID, elementID, true, ContextMenu.GetText(data), checked or false, greyedOut or false, legal or true)

    -- local contents = ContextMenu.Root.windowsMenu_mc.list.content_array
    -- local checkbox = contents[#contents-1]
    local contents = ContextMenu.GetMenuElement(ui, menuID).list.content_array
    local checkbox = contents[#contents-1]

    -- idk why, but a frame-based approach is not working in the swf
    checkbox.checkbox_mc.x = 0
    checkbox.checkbox_checked_mc.x = 0
    checkbox.checkbox_mc.y = -2 -- push these a bit up to compensate for arrow sticking out
    checkbox.checkbox_checked_mc.y = -2
    checkbox.text_txt.x = checkbox.text_txt.x + 20
end

function ContextMenu.AddHeader(ui, menuID, elementID, text, data)
    local root = ui:GetRoot()

    ContextMenu.AddButton(ui, menuID, elementID, text, false, true, data)

    local element = ContextMenu.GetLastElement(ui, menuID)
    element.selectable = false
    element.disabled = true
    element.text_txt.align = "center"
    CenterText(element.text_txt, -5)
end

function ContextMenu.AddStatEntry(ui, menuID, data)
    local root = ui:GetRoot()

    table.insert(ContextMenu.state.menu.entries, data)

    local elementNumID = ContextMenu.GetNextElementNumID()

    root.addStatEntry(menuID, elementNumID, data.id, false, ContextMenu.GetText(data), true, false, true)

    local contents = ContextMenu.GetMenuElement(ui, menuID).list.content_array
    local element = contents[#contents-1]

    element.btnParam1 = data.id

    element.plusBtn_mc.y = 5
    element.minusBtn_mc.y = 5

    if not data.selectable then -- TODO add a distinction between unselectable and disabled?
        element.selectable = false
        element.disabled = true
    end

    element.plusBtn_mc.x = 175
    element.minusBtn_mc.x = element.plusBtn_mc.x + 45

    element.amount_txt.autoSize = "center"
    element.amount_txt.htmlText = Text.RemoveTrailingZeros(Utilities.Hooks.ReturnFromHooks("PIP_ContextMenu", "statDisplay_" .. ContextMenu.GetEventID(data), data.min or 0, ContextMenu.GetCurrentEntity(), data.params))
    element.amount_txt.x = 205 - element.amount_txt.textWidth / 2
end

-- Removable elements function as a button, but also have a sub-button on their right.
function ContextMenu.AddRemovableEntry(ui, menuID, data)
    ContextMenu.AddStatEntry(ui, menuID, data)

    local element = ContextMenu.GetLastElement(ui, menuID)

    element.amount_txt.visible = false
    element.plusBtn_mc.visible = false
end

function ContextMenu.AddSubMenuElement(ui, menuID, elementID, text, subMenuID, data)
    local root = ui:GetRoot()

    -- add it as a button first - TODO specialized type in swf
    ContextMenu.AddButton(ui, menuID, elementID, ContextMenu.GetText(data), false, true, data)

    -- redefine the element as submenu-type
    local elementData = data
    elementData.type = "subMenu"
end

function ContextMenu.GetLastElement(ui, menuID)
    local elements = ContextMenu.GetMenuElement(ui, menuID).list.content_array
    return elements[#elements-1]
end

-- Returns either the character bound to the context menu, or the item
function ContextMenu.GetCurrentEntity()
    local entity

    if ContextMenu.itemHandle then
        entity = Item.Get(ContextMenu.itemHandle)
    else
        entity = ContextMenu.GetCurrentCharacter(true)
    end

    return entity
end

function ContextMenu.CheckRemoveSubMenu(ui, menu, elementID)
    local elementData = ContextMenu.GetElementData(elementID)

    if elementData.subMenu then
        Utilities.Log("ContextMenu", "Removing SubMenu: " .. elementData.subMenu)

        ContextMenu.RemoveSubMenu(ui, elementData.subMenu)

        ContextMenu.SetPosition(ui)
    end
end

function ContextMenu.RemoveSubMenu(ui, menuID)
    local root = ui:GetRoot()
    root.removeSubMenu(menuID)

    local elementData = ContextMenu.GetElementData(ContextMenu.selectedElements[menuID])

    -- remove submenus of this submenu as well.
    if elementData and elementData.subMenu then
        ContextMenu.RemoveSubMenu(ui, elementData.subMenu)
    end

    ContextMenu.selectedElements[menuID] = nil

    ContextMenu:FireEvent("SubMenuRemoved", menuID)
end

function ContextMenu.GetEventID(elementData)
    -- You can set an ID override for events, to have multiple elements fire the same event. Useful for making variations of one action, with different params
    if elementData.eventIDOverride then
        return elementData.eventIDOverride
    end

    return elementData.id
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Handling redirected vanilla context menus - UNUSED?
Client.UI.ContextMenu.RegisterElementListener("vanilla_button", "buttonPressed", function(character, params)
    local ui = Ext.UI.GetByType(Client.UI.Data.UITypes.contextMenu)
    local root = ui:GetRoot()

    Ext.Print("handled vanilla button: " .. params.actionID)

    ui:ExternalInterfaceCall("buttonPressed", params.ID, params.actionID)
end)

-- Handle param is unused by the game, always 0
local function OnButtonPressed(ui, method, id, elementID, handle, amountTxt)
    Utilities.Log("ContextMenu", "Button pressed: " .. elementID)

    local elementData = ContextMenu.GetElementData(elementID)

    -- Vanilla buttons give no events
    if not elementData then return nil end

    elementID = ContextMenu.GetEventID(elementData)

    local pressable = (not elementData.requireShiftClick) or Client.Input.IsShiftPressed()

    if pressable then
        -- Clone params
        local params = {}
        if elementData.params then
            params = {table.unpack(elementData.params)}

            -- TODO what's wrong?
            if #params == 0 then
                for i,v in pairs(elementData.params) do
                    params[i] = v
                end
            end
        end

        -- If this was a stat entry, also pass the updated amount text as a param
        if elementData.type == "stat" then
            params._statAmount = tonumber(amountTxt)
        end

        Utilities.Hooks.FireEvent("PIP_ContextMenu", "buttonPressed" .. "_" .. elementID, ContextMenu.GetCurrentEntity(), params)

        -- Can specify a net msg to auto-post, eliminating the need to create handlers for simple commands
        if elementData.netMsg then
            local msg = {NetID = ContextMenu.GetCurrentEntity().NetID, ClientCharacterNetID = Client.GetCharacter().NetID, Params = elementData.params}

            -- If the element is a checkbox, also send new state
            if elementData.type == "checkbox" then
                msg.State = not elementData.checked
            end

            Net.PostToServer(elementData.netMsg, msg)
        end

        if elementData.closeOnButtonPress then
            ContextMenu.Close(ui)
        end
    end
end

-- Listen for vanilla context menu being opened.
ContextMenu:RegisterCallListener("pipVanillaContextMenuOpened", function (ev)
    -- Close our instance - we don't support using both at once
    local vanillaElements = ContextMenu.vanillaContextData
    local item = Item.Get(ContextMenu.itemHandle) or (ContextMenu._LatestHoveredItemHandle and Item.Get(ContextMenu._LatestHoveredItemHandle))
    ContextMenu.Close(ContextMenu.UI)

    if item then
        ContextMenu.itemHandle = item.Handle
    end
    ContextMenu.position = {x = 0, y = 0}

    ContextMenu.elementsCount = #vanillaElements

    -- Log unmapped action IDs.
    if ContextMenu:IsDebug() then
        for _,data in pairs(vanillaElements) do
            if not table.reverseLookup(ContextMenu.VANILLA_ACTIONS, data.ActionID) then
                ContextMenu:LogWarning("Unmapped action:", data.ActionID, data.Index)
            end
        end
    end

    if item then
        ContextMenu._LatestHoveredCharacterHandle = nil
        Utilities.Hooks.FireEvent("PIP_ContextMenu", "VanillaMenu_Item", Item.Get(ContextMenu.itemHandle))
    else
        ContextMenu.itemHandle = nil
        ContextMenu._LatestHoveredItemHandle = nil
        Utilities.Hooks.FireEvent("PIP_ContextMenu", "VanillaMenu_Character", ContextMenu.GetCurrentCharacter(true))
    end

    ContextMenu.SetPosition(nil)
    ContextMenu.GetActiveUI():GetRoot().windowsMenu_mc.updateDone(true)
end, "Vanilla")

-- Fired when you hover over an entry
local function OnButtonSelected(ui, method, elementID)

    local elementData = ContextMenu.GetElementData(elementID)
    if not elementData then return nil end

    local previousSelectedID = ContextMenu.selectedElements[elementData.menu]

    -- No events for re-hovering
    if previousSelectedID == elementID then return nil end

    Utilities.Log("ContextMenu", "Button selected: " .. elementID)

    ContextMenu.selectedElements[elementData.menu] = elementData.id

    if elementData and elementData.subMenu then
        ContextMenu.RequestMenu(nil, nil, elementData.subMenu, ui, elementData)
    end

    -- Remove submenus of previously selected element
    if previousSelectedID then
        ContextMenu.CheckRemoveSubMenu(ui, elementData.menu, previousSelectedID)
    end

    Utilities.Hooks.FireEvent("PIP_ContextMenu", "buttonSelected" .. "_" .. elementID)
end

-- Separate event so it does not fire the quantity-related ones.
local function OnRemovableButtonPressed(ui, method, elementID)
    local root = ui:GetRoot()
    Utilities.Log("ContextMenu", "Removable button pressed: " .. elementID)

    local elementData = ContextMenu.GetElementData(elementID)
    local elementID = ContextMenu.GetEventID(elementData)

    Utilities.Hooks.FireEvent("PIP_ContextMenu", "removablePressed" .. "_" .. elementID, ContextMenu.GetCurrentEntity(), elementData.params)

    ContextMenu.Close(ui) -- TODO support removing elements in flash
end

local function OnStatButtonPressed(ui, method, currentAmount, addition, elementID)
    local root = ui:GetRoot()
    Utilities.Log("ContextMenu", "Stat button pressed: " .. elementID)

    local elementData = ContextMenu.GetElementData(elementID)

    -- TODO cleanup
    if elementData.type == "removable" then
        OnRemovableButtonPressed(ui, method, elementID)
        return nil
    end

    local elementID = ContextMenu.GetEventID(elementData)

    -- default step is 1
    local amount = elementData.step or 1
    if not addition then amount = -amount end

    -- shift-click does 10x
    if Client.Input.IsShiftPressed() then
        amount = amount * 10
    end

    -- Cap new amount if min/max are defined in element data
    local newAmount = tonumber(currentAmount) + amount
    if elementData.min then
        newAmount = math.max(elementData.min, newAmount)
    end
    if elementData.max then
        newAmount = math.min(elementData.max, newAmount)
    end

    local change = newAmount - currentAmount

    -- Events are not fired when there is no change.
    if change ~= 0 then
        Utilities.Hooks.FireEvent("PIP_ContextMenu", "statButtonPressed" .. "_" .. elementID, ContextMenu.GetCurrentEntity(), elementData.params, change)

        -- update visual
        root.setStatAmount(elementData.id,  Text.RemoveTrailingZeros(newAmount))
    end
end

local function OnRequestContextMenu(ui, method, id, x, y, entityHandle, ...)
    -- The passed character handle, if any, becomes the associated character with this context menu. Otherwise, we default to client-controlled char.
    if entityHandle then
        entityHandle = Ext.UI.DoubleToHandle(entityHandle)

        if Character.Get(entityHandle) then
            ContextMenu._LatestHoveredCharacterHandle = entityHandle
        else
            ContextMenu.itemHandle = entityHandle
        end
    end
    
    -- Always use our instance for user-made context menus
    ContextMenu.RequestMenu(x, y, id, ContextMenu.UI, ...)
end

-- Parses updateButtons() from vanilla context menu to keep track of vanilla context menu elements.
ContextMenu:RegisterInvokeListener("updateButtons", function(ev)
    local root = ev.UI:GetRoot()
    local data = Client.Flash.ParseArray(root.buttonArr, ContextMenu.ARRAY_ENTRY_TEMPLATES.BUTTON) ---@type ContextMenuUI_ArrayEntry_Button[]

    ContextMenu.vanillaContextData = data
end, "Vanilla")

-- Fetches item from vanilla context menu calls.
local function OnContextMenu(ui, method, param3, handle)
    local item = Ext.GetItem(Ext.UI.DoubleToHandle(handle)) -- inventory uses this param

    if item == nil then
        item = Ext.GetItem(Ext.UI.DoubleToHandle(param3)) -- but other UIs use this one instead
    end

    ContextMenu.itemHandle = item.Handle
end

Ext.Events.SessionLoaded:Subscribe(function()
    if Client.IsUsingController() then return nil end

    local vanillaUI = Ext.UI.GetByType(Ext.UI.TypeID.contextMenu.Object)
    
    -- Setup our custom instance
    ContextMenu.UI = Ext.UI.Create("pip_contextMenu", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/contextMenu.swf", 300)
    
    ContextMenu.Root = ContextMenu.UI:GetRoot()
    ContextMenu.Root.isCustomInstance = true
    ContextMenu.Root.MAX_HEIGHT = ContextMenu.MAX_HEIGHT
    ContextMenu.Close(ContextMenu.UI)

    Ext.RegisterUICall(ContextMenu.UI, "buttonPressed", OnButtonPressed)
    Ext.RegisterUICall(ContextMenu.UI, "buttonSelected", OnButtonSelected)
    Ext.RegisterUICall(ContextMenu.UI, "pipStatButtonUp", OnStatButtonPressed)
    Ext.RegisterUICall(ContextMenu.UI, "pipContextMenuClosed", function()
        ContextMenu.UI:Hide()
    end)

    -- Setup vanilla context menu
    vanillaUI:GetRoot().contextMenusList.content_array[0].list_string_id = "main"
    vanillaUI:GetRoot().MAX_HEIGHT = ContextMenu.MAX_HEIGHT

    -- Vanilla UI calls
    Ext.RegisterUINameCall("openContextMenu", OnContextMenu)

    Ext.RegisterUICall(vanillaUI, "buttonPressed", OnButtonPressed)
    Ext.RegisterUICall(vanillaUI, "buttonSelected", OnButtonSelected)
    Ext.RegisterUICall(vanillaUI, "pipStatButtonUp", OnStatButtonPressed)
    Ext.RegisterUICall(vanillaUI, "pipContextMenuClosed", function(ui)
        ContextMenu.Cleanup(ui)
    end)
    
    -- Global call to begin creating a custom context menu
    Ext.RegisterUINameCall("pipRequestContextMenu", OnRequestContextMenu)
end)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for characters being hovered to remember the latest hovered character.
Pointer.Events.HoverCharacterChanged:Subscribe(function (_)
    UpdateLatestHoveredCharacter()
end)
Pointer.Events.HoverCharacter2Changed:Subscribe(function (_)
    UpdateLatestHoveredCharacter()
end)

-- Listen for items being hovered in the world to track their handle.
Pointer.Events.HoverItemChanged:Subscribe(function (_)
    UpdateLatestHoveredItem()
end)