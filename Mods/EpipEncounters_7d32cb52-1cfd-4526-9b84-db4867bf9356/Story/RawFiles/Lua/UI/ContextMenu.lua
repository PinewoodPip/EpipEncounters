
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

local ContextMenu = {
    Root = nil,
    UI = nil,
    VanillaUI = nil,

    VANILLA_ACTIONS = {
        LOOT_CHARACTER = 3,
        ATTACK = 6,
        TALK = 11,
        CHAIN = 13,
        UNCHAIN = 14,
        PICKPOCKET = 15,
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
    character = nil,
    item = nil,
    vanillaContextData = nil,

    MAX_HEIGHT = 500,

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/contextMenu.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/contextMenu.swf",
    },
}
Client.UI.ContextMenu = ContextMenu
Epip.InitializeUI(Client.UI.Data.UITypes.contextMenu, "ContextMenu", ContextMenu)

function ContextMenu.SetPosition(ui, x, y)
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

function ContextMenu.Open()
    local root = ContextMenu.Root

    ContextMenu.SetPosition(ContextMenu.UI, ContextMenu.position.x, ContextMenu.position.y)

    root.open()
    ContextMenu.UI:Show()

    ContextMenu.Root.windowsMenu_mc.updateDone()

    -- TODO!
    -- if tryPushBack and ContextMenu.GetActiveUI():GetRoot().isCustomInstance then

    -- end
end

function ContextMenu.Close(ui)
    local root = ui:GetRoot()
    root.close()

    ContextMenu.Cleanup(ui)
end

function ContextMenu.IsOpen()
    return #ContextMenu.GetActiveUI():GetRoot().contextMenusList.content_array > 0
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
    ContextMenu.character = nil
    ContextMenu.item = nil
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
        ui = ContextMenu.VanillaUI
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
    return ContextMenu.character or ContextMenu.item
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

-- Handling redirected vanilla context menus
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

    local pressable = (not elementData.requireShiftClick) or Client.Input.IsHoldingModifierKey()

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
            local msg = {NetID = ContextMenu.GetCurrentEntity().NetID, ClientCharacterNetID = Client.GetCharacter().NetID}

            -- If the element is a checkbox, also send new state
            if elementData.type == "checkbox" then
                msg.State = not elementData.checked
            end

            Game.Net.PostToServer(elementData.netMsg, msg)
        end

        if elementData.closeOnButtonPress then
            ContextMenu.Close(ui)
        end
    end
end

Utilities.Hooks.RegisterListener("ContextMenu", "contextMenuOpened", function(ui, elements)
    -- Close our instance - we don't support using both at once
    local item = ContextMenu.item
    ContextMenu.Close(ContextMenu.UI)
    ContextMenu.item = item
    ContextMenu.position = {x = 0, y = 0}

    ContextMenu.elementsCount = #elements

    -- Ext.Dump(elements)

    -- Scan elements to check if we're examining a character
    -- If this context menu is from an item, the UICall listener will have already caught it - characters take priority though.
    for i,data in pairs(elements) do
        local action = data[2]

        -- TODO apparently the open option is the same for both corpses and items... how to distinguish without checking string?

        -- TODO reverse logic - assume it's a char until we find an option that proves it's an item. Since the issue are items; right-clicking them from inventory does not pull up the health bar so we cannot rely on it to know that an item was context'd

        if action == ContextMenu.VANILLA_ACTIONS.TALK or action == ContextMenu.VANILLA_ACTIONS.LOOT_CHARACTER or action == ContextMenu.VANILLA_ACTIONS.CHAIN or action == ContextMenu.VANILLA_ACTIONS.PICKPOCKET or action == ContextMenu.VANILLA_ACTIONS.UNCHAIN then
            -- TODO some better solution

            if not item then
                ContextMenu.character = Client.UI.EnemyHealthBar.latestCharacter
            end
            -- ContextMenu.item = nil -- TODO should we allow both at once?
            break
        end
    end

    if ContextMenu.character then
        Utilities.Hooks.FireEvent("PIP_ContextMenu", "VanillaMenu_Character", ContextMenu.character)
    elseif ContextMenu.item then
        Utilities.Hooks.FireEvent("PIP_ContextMenu", "VanillaMenu_Item", ContextMenu.item)
    end

    ContextMenu.SetPosition(ContextMenu.VanillaUI)
    ContextMenu.VanillaUI:GetRoot().windowsMenu_mc.updateDone(true)
end)

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
    if Client.Input.IsHoldingModifierKey() then
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
        ContextMenu.character = Ext.GetCharacter(entityHandle)
        ContextMenu.item = Ext.GetItem(entityHandle)
    else
        ContextMenu.character = Client.GetCharacter()
    end
    
    -- Always use our instance for user-made context menus
    ContextMenu.RequestMenu(x, y, id, ContextMenu.UI, ...)
end

-- Parses updateButtons() from vanilla context menu to keep track of vanilla context menu elements.
local function OnContextMenuUpdateButtons(ui, method, param3)
    local root = ui:GetRoot()
    local data = {{}}
    local entryIndex = 1

    for i=0,#root.buttonArr-1,1 do
        local element = root.buttonArr[i]

        if (i) % 7 == 0 and i > 0 then
            entryIndex = entryIndex + 1
            table.insert(data, {})
        end

        table.insert(data[entryIndex], element)
    end

    ContextMenu.vanillaContextData = data
end

-- Fetches item from vanilla context menu calls.
local function OnContextMenu(ui, method, param3, handle)
    local item = Ext.GetItem(Ext.UI.DoubleToHandle(handle)) -- inventory uses this param

    if item == nil then
        item = Ext.GetItem(Ext.UI.DoubleToHandle(param3)) -- but other UIs use this one instead
    end

    ContextMenu.item = item
end

Ext.Events.SessionLoaded:Subscribe(function()

    -- Setup our custom instance
    if Epip.IS_IMPROVED_HOTBAR then
        ContextMenu.UI = Ext.UI.Create("pip_contextMenu", "Public/ImprovedHotbar_53cdc613-9d32-4b1d-adaa-fd97c4cef22c/GUI/contextMenu.swf", 300)
    else
        ContextMenu.UI = Ext.UI.Create("pip_contextMenu", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/contextMenu.swf", 300)
    end
    
    ContextMenu.Root = ContextMenu.UI:GetRoot()
    ContextMenu.Root.isCustomInstance = true
    ContextMenu.Root.MAX_HEIGHT = ContextMenu.MAX_HEIGHT
    ContextMenu.Close(ContextMenu.UI)

    Ext.RegisterUICall(ContextMenu.UI, "buttonPressed", OnButtonPressed)
    Ext.RegisterUICall(ContextMenu.UI, "buttonSelected", OnButtonSelected)
    Ext.RegisterUICall(ContextMenu.UI, "pipStatButtonUp", OnStatButtonPressed)

    -- Setup vanilla context menu
    if not Epip.IS_IMPROVED_HOTBAR then
        ContextMenu.VanillaUI = Ext.UI.GetByType(Client.UI.Data.UITypes.contextMenu)
        ContextMenu.VanillaUI:GetRoot().contextMenusList.content_array[0].list_string_id = "main"
        ContextMenu.VanillaUI:GetRoot().MAX_HEIGHT = ContextMenu.MAX_HEIGHT
    end

    -- Vanilla UI calls
    Ext.RegisterUINameCall("openContextMenu", OnContextMenu)

    if not Epip.IS_IMPROVED_HOTBAR then
        Ext.RegisterUIInvokeListener(ContextMenu.VanillaUI, "updateButtons", OnContextMenuUpdateButtons, "Before")
        Ext.RegisterUICall(ContextMenu.VanillaUI, "buttonPressed", OnButtonPressed)
        Ext.RegisterUICall(ContextMenu.VanillaUI, "buttonSelected", OnButtonSelected)
        Ext.RegisterUICall(ContextMenu.VanillaUI, "pipStatButtonUp", OnStatButtonPressed)
        Ext.RegisterUICall(ContextMenu.VanillaUI, "pipContextMenuClosed", function(ui)
            ContextMenu.Cleanup(ui)
        end)
        Ext.RegisterUICall(ContextMenu.VanillaUI, "pipVanillaContextMenuOpened", function(ui, method)
            Utilities.Hooks.FireEvent("ContextMenu", "contextMenuOpened", ui, ContextMenu.vanillaContextData)
        end, "After")
    else -- We still need to listen for closing
        Ext.Events.Tick:Subscribe(function()
            local ui = ContextMenu.GetActiveUI()

            -- if ui then
            --     ContextMenu.Cleanup(ui)
            -- end
        end)
    end
    
    -- Global call to begin creating a custom context menu
    Ext.RegisterUINameCall("pipRequestContextMenu", OnRequestContextMenu)
end)