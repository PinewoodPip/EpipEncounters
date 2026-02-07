
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

local ParseFlashArray = Client.Flash.ParseArray
local CommonStrings = Text.CommonStrings

---@class ContextMenuUI : UI
---@field _LatestHoveredCharacterHandle CharacterHandle
---@field _LatestHoveredItemHandle ItemHandle
local ContextMenu = {
    VANILLA_ACTIONS = {
        USE = 2, -- May have other names such as "Sit" based on an item's peace use actions
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
        ADD_TO_WARES = 50,
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

    _MaxSize = nil, ---@type Vector2? Maximum flash size of the current context menu. Removing submenus will not shrink it.

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

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        EntryPressed = {}, ---@type Event<UI.ContextMenu.Events.EntryPressed>
    }
}
Epip.InitializeUI(Ext.UI.TypeID.contextMenu.Object, "ContextMenu", ContextMenu)

---@type table<integer, true>
ContextMenu.ITEM_ACTIONS = {
    [ContextMenu.VANILLA_ACTIONS.SEND_TO_CHARACTER] = true,
    [ContextMenu.VANILLA_ACTIONS.DROP] = true,
    [ContextMenu.VANILLA_ACTIONS.PICK_UP] = true,
    [ContextMenu.VANILLA_ACTIONS.USE] = true,
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

---@class UI.ContextMenu.Menu
---@field id string
---@field menu UI.ContextMenu.SubMenu

---@class UI.ContextMenu.SubMenu
---@field id string
---@field entries UI.ContextMenu.Entry[]

---@class UI.ContextMenu.Entry
---@field type UI.ContextMenu.Entry.Type
---@field selectable boolean
---@field id string
---@field menu string
---@field closeOnButtonPress boolean?
---@field greyedOut boolean?
---@field legal boolean?
---@field text string
---@field icon string?
---@field requireShiftClick boolean?
---@field faded boolean?
---@field eventIDOverride string? If set, this event ID will be used instead of the entry ID when firing events. Useful for making variations of one action, with different params
---@field netMsg string?
---@field params table?
---@field subMenu string?

---@class UI.ContextMenu.Entry.Button : UI.ContextMenu.Entry
---@field type "button"

---@class UI.ContextMenu.Entry.Checkbox : UI.ContextMenu.Entry
---@field type "checkbox"
---@field checked boolean?

---@class UI.ContextMenu.Entry.Header : UI.ContextMenu.Entry
---@field type "header"

---@class UI.ContextMenu.Entry.Stat : UI.ContextMenu.Entry
---@field type "stat"
---@field min number
---@field max number
---@field step number

---@class UI.ContextMenu.Entry.SubMenu : UI.ContextMenu.Entry
---@field type "subMenu"

---@class UI.ContextMenu.Entry.Removable : UI.ContextMenu.Entry
---@field type "removable"

---@alias UI.ContextMenu.Instance UIObject
---@alias UI.ContextMenu.Entry.Type "subMenu"|"button"|"checkbox"|"header"|"stat"|"removable"

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class UI.ContextMenu.Events.EntryPressed
---@field ID string|integer Will be integer for vanilla entries.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the character associated with the currently open context menu.
---@param force boolean?
---@return EclCharacter?
function ContextMenu.GetCurrentCharacter(force)
    local charHandle = ContextMenu._LatestHoveredCharacterHandle
    local char = nil
    if charHandle and (ContextMenu.IsOpen() or force) then
        char = Character.Get(charHandle)
    end
    return char
end

---Register a listener for a UI Call raw event.
---@override Necessary to distinguish between the 2 instances.
---@param method string ExternalInterface call name.
---@param handler fun(ev:EclLuaUICallEvent)
---@param uiInstance ("Vanilla"|"Custom")? If `nil`, will be registered for both.
---@param when? "Before"|"After"
function ContextMenu:RegisterCallListener(method, handler, uiInstance, when)
    if uiInstance ~= nil then
        Client.UI._BaseUITable.RegisterCallListener(self, method, function (ev)
            if ev.UI:GetTypeId() < 1000 and uiInstance == "Vanilla" then
                handler(ev)
            elseif uiInstance == "Custom" then
                handler(ev)
            end
        end, when)
    else -- Register listener for both UIs
        ContextMenu:RegisterCallListener(method, handler, "Vanilla", when)
        ContextMenu:RegisterCallListener(method, handler, "Custom", when)
    end
end

---Register a listener for a UI Invoke raw event.
---@override Necessary to distinguish between the 2 instances.
---@param method string ExternalInterface call name.
---@param handler fun(ev:EclLuaUICallEvent)
---@param uiInstance ("Vanilla"|"Custom")? If `nil`, will be registered for both.
---@param when? "Before"|"After"
function ContextMenu:RegisterInvokeListener(method, handler, uiInstance, when)
    if uiInstance ~= nil then
        Client.UI._BaseUITable.RegisterInvokeListener(self, method, function (ev)
            if ev.UI:GetTypeId() < 1000 and uiInstance == "Vanilla" then
                handler(ev)
            elseif uiInstance == "Custom" then
                handler(ev)
            end
        end, when)
    else -- Register listener for both UIs
        ContextMenu:RegisterInvokeListener(method, handler, "Vanilla", when)
        ContextMenu:RegisterInvokeListener(method, handler, "Custom", when)
    end
end

---Sets the position of a context menu.
---@param ui UIObject? Defaults to active context menu.
---@param x number? Defaults to current X.
---@param y number? Defaults to current Y.
function ContextMenu.SetPosition(ui, x, y)
    ui = ui or ContextMenu.GetActiveUI()
    x = x or ContextMenu.position.x
    y = y or ContextMenu.position.y
    local uiPos = Vector.Create(x, y)

    local root = ui:GetRoot()

    root.contextMenusList.y = 0

    ContextMenu.position = {x = x, y = y}

    local width, height = 0, 0 -- Size of the menu area (including submenus).
    for i=0,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]

        menu.x = (i * 265)
        menu.y = 0

        width = width + menu.width

        if menu.visible then
            height = math.clamp(menu.height, height, root.MAX_HEIGHT + 10) -- MAX_HEIGHT doesn't consider height of start/end pieces
        end
    end

    -- Use max size of the context menu to avoid jitter when submenus are removed/readded
    local currentMaxSize = ContextMenu._MaxSize
    local uiScale = ui:GetUIScaleMultiplier()
    ContextMenu._MaxSize = currentMaxSize and Vector.Create(math.max(currentMaxSize[1], width), math.max(currentMaxSize[2], height)) or Vector.Create(width, height)
    width, height = ContextMenu._MaxSize[1], ContextMenu._MaxSize[2]

    -- Push all menus to the left if they were to overflow through the right edge of the screen.
    local viewport = Client.GetViewportSize()
    local rightEdgeX = width * uiScale + uiPos[1]
    local pushLeft = rightEdgeX - viewport[1]
    if pushLeft > 0 and x >= 0 then
        uiPos[1] = uiPos[1] - pushLeft
    end

    -- Push all menus upwards if they were to overflow through the bottom edge of the screen.
    local bottomY = height * uiScale + uiPos[2]
    local pushUp = bottomY - viewport[2]
    if pushUp > 0 then
        uiPos[2] = uiPos[2] - pushUp
    end

    -- Only mess with position for the custom instance.
    ContextMenu.UI:SetPosition(math.floor(uiPos[1]), math.floor(uiPos[2]))
end

---Adds a single entry to a menu.
---@param entry UI.ContextMenu.Entry
---@param menu string? -- Defaults to "main"
function ContextMenu.AddElement(entry, menu)
    local ui = ContextMenu.GetActiveUI()
    menu = menu or "main"

    ContextMenu.AddElements(ui, {
        id = menu,
        entries = entry,
    })
end

---Gets the next free numeric id for a new element.
---@return integer
function ContextMenu.GetNextElementNumID()
    -- elementsCount is intended to track how many indexes are being used up by vanilla context menu entries.
    return ContextMenu.elementsCount + #ContextMenu.state.menu.entries
end

---Returns the active context menu UI instance.
---@return UI.ContextMenu.Instance
function ContextMenu:GetUI()
    return ContextMenu.GetActiveUI()
end

---Returns the root flash object of the current context menu UI.
---@return FlashObject
function ContextMenu:GetRoot()
    return ContextMenu:GetUI():GetRoot()
end

---Returns a all submenu flash elements for the given UI instance.
---@param ui UI.ContextMenu.Instance
---@return table<string, FlashMovieClip>
function ContextMenu.GetSubMenus(ui)
    local root = ui:GetRoot()
    local menus = {}
    for i=1,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]

        menus[menu.list_string_id] = menu
    end
    return menus
end

---Returns the element data of an entry.
---@param id string
---@return UI.ContextMenu.Entry?
function ContextMenu.GetElementData(id)
    return ContextMenu.elements[id]
end

---Adds a submenu to the context menu.
---@param data table
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

---Sets up a new context menu.
---@param data UI.ContextMenu.Menu
function ContextMenu.Setup(data)
    local root = ContextMenu.Root

    for i=0,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]
        
        menu.list.clearElements()
    end

    ContextMenu.elements = {}
    ContextMenu.selectedElements = {}

    ContextMenu:DebugLog("Setting up new menu")

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

    root.open()
    ContextMenu.UI:Show()

    ContextMenu.Root.windowsMenu_mc.updateDone()

    ContextMenu.SetPosition(ContextMenu.UI, position[1], position[2])
end

---Closes the UI.
---@param ui UI.ContextMenu.Instance? Defaults to current instance.
function ContextMenu.Close(ui)
    ui = ui or ContextMenu.GetActiveUI()
    local root = ui:GetRoot()
    root.close()
    ContextMenu.Cleanup(ui)
end

---Returns whether a context menu is currently open.
---@return boolean
function ContextMenu.IsOpen()
    return ContextMenu.GetActiveUI().OF_Visible
end

---Updates the latest hovered character handle.
local function UpdateLatestHoveredCharacter()
    local char = Pointer.GetCurrentCharacter(nil, true) -- Living characters are prioritized.
    -- Do not update the char if a context menu is already open.
    if char and not ContextMenu.IsOpen() then
        ContextMenu._LatestHoveredCharacterHandle = char.Handle
        ContextMenu._LatestHoveredItemHandle = nil
    end
end

---Updates the latest hovered item handle.
local function UpdateLatestHoveredItem()
    local item = Pointer.GetCurrentItem()
    if item and not ContextMenu.IsOpen() then
        ContextMenu._LatestHoveredItemHandle = item.Handle
        ContextMenu._LatestHoveredCharacterHandle = nil
    end
end

---Cleans up the context menu state.
---@param ui UI.ContextMenu.Instance
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

    ContextMenu._MaxSize = nil
end

---Registers a listener for an element event.
---@param elementID string
---@param type string
---@param callback function TODO
function ContextMenu.RegisterElementListener(elementID, type, callback)
    Utilities.Hooks.RegisterListener("PIP_ContextMenu", type .. "_" .. elementID, callback)
end

---Registers a handler for a context menu.
---@param id string
---@param callback function TODO
function ContextMenu.RegisterMenuHandler(id, callback)
    ContextMenu.menuHandlers[id] = callback
end

---Registers a handler for vanilla context menu events.
---@param type string
---@param callback function TODO
function ContextMenu.RegisterVanillaMenuHandler(type, callback)
    Utilities.Hooks.RegisterListener("PIP_ContextMenu", "VanillaMenu_" .. type, callback)
end

---Registers a hook for stat display.
---@param elementID string
---@param handler function TODO
function ContextMenu.RegisterStatDisplayHook(elementID, handler)
    Utilities.Hooks.RegisterHook("PIP_ContextMenu", "statDisplay_" .. elementID, handler)
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

---Adds multiple elements to a menu.
---@param ui UI.ContextMenu.Instance?
---@param menuData UI.ContextMenu.SubMenu
function ContextMenu.AddElements(ui, menuData)
    ui = ui or ContextMenu.GetActiveUI()
    local menuID = menuData.id
    for _,data in pairs(menuData.entries) do
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
            ContextMenu.AddButton(ui, menuID, data.id, data.greyedOut, data.legal, data)
        elseif type == "checkbox" then
            ---@cast data UI.ContextMenu.Entry.Checkbox
            ContextMenu.AddCheckbox(ui, menuID, data.id, data.checked, data.greyedOut, data.legal, data)
        elseif type == "header" then
            ---@cast data UI.ContextMenu.Entry.Header
            ContextMenu.AddHeader(ui, menuID, data.id, data)
        elseif type == "subMenu" then
            ---@cast data UI.ContextMenu.Entry.SubMenu
            ContextMenu.AddSubMenuElement(ui, menuID, data.id, data)
        elseif type == "stat" then
            ---@cast data UI.ContextMenu.Entry.Stat
            ContextMenu.AddStatEntry(ui, menuID, data)
        elseif type == "removable" then
            ---@cast data UI.ContextMenu.Entry.Removable
            ContextMenu.AddRemovableEntry(ui, menuID, data)
        end

        ContextMenu.SetupIcon(ui, menuID, data)

        ContextMenu.elements[data.id] = data
    end
end

---Returns the formatted label for an entry,
---including suffixes for control hints (ex. "Shift+Click")
---@param elementData UI.ContextMenu.Entry
---@return string
function ContextMenu.GetText(elementData)
    local text = elementData.text

    -- Add shift+click hint
    if elementData.requireShiftClick then
        text = text .. string.format(" (%s)", CommonStrings.ShiftClick:GetString())
    end

    -- Grey out text
    if elementData.faded then
        text = "<font color='#59564f'>" .. text .. "</font>"
    end

    return text
end

---Get the currently-used Context Menu UI instance, defaulting to the custom one if neither is being used.
---@return UI.ContextMenu.Instance
function ContextMenu.GetActiveUI()
    local ui = ContextMenu.UI
    if not ContextMenu.Root or not ContextMenu.Root.visible then
        ui = Ext.UI.GetByType(Ext.UI.TypeID.contextMenu.Object) or Ext.UI.GetByType(Ext.UI.TypeID.contextMenu.Default)
    end
    return ui
end

---Sets up the icon for a context menu element.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@param data UI.ContextMenu.Entry
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

---Requests a context menu to be opened.
---@param x number? Defaults to current position.
---@param y number? Defaults to current position.
---@param id string
---@param ui UI.ContextMenu.Instance?
---@param requestingElementData UI.ContextMenu.Entry?
---@vararg any
function ContextMenu.RequestMenu(x, y, id, ui, requestingElementData, ...)
    if not ui then ui = ContextMenu.UI end
    ContextMenu._MaxSize = nil
    ContextMenu.SetPosition(ui, x, y)

    -- Track submenus
    if id ~= "main" then
        ContextMenu.state.subMenus[id] = {subMenus = {}}
    end
    if ContextMenu.menuHandlers[id] then
        ContextMenu.menuHandlers[id](ContextMenu.GetCurrentEntity(), requestingElementData, ...)
    else
        ContextMenu:__LogWarning("Context menu " .. id .. " has no handler. Setup context menus with ContextMenu.RegisterMenuHandler(id, callback)")
    end

    -- Hook to perform stuff after the normal handling.
    Utilities.Hooks.FireEvent("PIP_ContextMenu", "contextMenuRequested", id)
end

---Adds a button to the menu.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@param elementID string
---@param greyedOut boolean
---@param legal boolean
---@param data UI.ContextMenu.Entry
function ContextMenu.AddButton(ui, menuID, elementID, greyedOut, legal, data)
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

---Returns the menu element for the given menu ID.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@return FlashMovieClip?
function ContextMenu.GetMenuElement(ui, menuID)
    local root = ui:GetRoot()
    for i=0,#root.contextMenusList.content_array-1,1 do
        local menu = root.contextMenusList.content_array[i]

        if menu.list_string_id == menuID then
            return menu
        end
    end
end

---Adds a checkbox to the menu.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@param elementID string
---@param checked boolean?
---@param greyedOut boolean?
---@param legal boolean?
---@param data UI.ContextMenu.Entry.Checkbox
function ContextMenu.AddCheckbox(ui, menuID, elementID, checked, greyedOut, legal, data)
    local root = ui:GetRoot()
    local elementData = data

    table.insert(ContextMenu.state.menu.entries, elementData)

    local elementNumID = ContextMenu.GetNextElementNumID()
    root.addCheckbox(menuID, elementNumID, elementID, true, ContextMenu.GetText(data), checked or false, greyedOut or false, legal or true)

    local contents = ContextMenu.GetMenuElement(ui, menuID).list.content_array
    local checkbox = contents[#contents-1]

    -- A frame-based approach is not working in the swf - not sure why.
    checkbox.checkbox_mc.x = 0
    checkbox.checkbox_checked_mc.x = 0
    checkbox.checkbox_mc.y = -2 -- Push these a bit up to compensate for arrow sticking out
    checkbox.checkbox_checked_mc.y = -2
    checkbox.text_txt.x = checkbox.text_txt.x + 20
end

---Centers text in a flash element.
---@param element FlashMovieClip
---@param offset number?
local function CenterText(element, offset)
    element.htmlText = '<p align="center">' .. element.htmlText .. '</p>'
    element.x = element.x + (offset or 0)
end

---Adds a header to the menu.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@param elementID string
---@param data UI.ContextMenu.Entry.Header
function ContextMenu.AddHeader(ui, menuID, elementID, data)
    ContextMenu.AddButton(ui, menuID, elementID, false, true, data)
    local element = ContextMenu.GetLastElement(ui, menuID)
    element.selectable = false
    element.disabled = true
    element.text_txt.align = "center"
    CenterText(element.text_txt, -5)
end

---Adds a stat entry to the menu.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@param data UI.ContextMenu.Entry.Stat
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

---Adds a removable entry to a menu.
---Removable elements function as a button, but also have a sub-button on their right.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@param data UI.ContextMenu.Entry.Removable
function ContextMenu.AddRemovableEntry(ui, menuID, data)
    ContextMenu.AddStatEntry(ui, menuID, data)
    local element = ContextMenu.GetLastElement(ui, menuID)
    element.amount_txt.visible = false
    element.plusBtn_mc.visible = false
end

---Adds a submenu entry to a menu.
---Submenu entries will open their submenu when selected.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@param elementID string
---@param data UI.ContextMenu.Entry.SubMenu
function ContextMenu.AddSubMenuElement(ui, menuID, elementID, data)
    -- Add it as a button first - no need for a specialized type in swf
    ContextMenu.AddButton(ui, menuID, elementID, false, true, data)

    -- Redefine the element as submenu-type
    local elementData = data
    elementData.type = "subMenu"
end

---Returns the last added element in a menu.
---@param ui UI.ContextMenu.Instance
---@param menuID string
---@return FlashMovieClip
function ContextMenu.GetLastElement(ui, menuID)
    local elements = ContextMenu.GetMenuElement(ui, menuID).list.content_array
    return elements[#elements-1]
end

---Returns either the character or item bound to the context menu, if any.
---@return (EclCharacter|EclItem)?
function ContextMenu.GetCurrentEntity()
    local entity
    if ContextMenu.itemHandle then
        entity = Item.Get(ContextMenu.itemHandle)
    else
        entity = ContextMenu.GetCurrentCharacter(true)
    end
    return entity
end

---Checks if an element has a submenu and hides it if so.
function ContextMenu.CheckRemoveSubMenu(ui, elementID)
    local elementData = ContextMenu.GetElementData(elementID)
    if elementData.subMenu then
        ContextMenu:DebugLog("Removing SubMenu: " .. elementData.subMenu)
        ContextMenu.RemoveSubMenu(ui, elementData.subMenu)
        ContextMenu.SetPosition(ui)
    end
end

---Hides a submenu.
---@param ui UI.ContextMenu.Instance
---@param menuID string
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

---Returns the event ID for an element, respecting eventIDOverride.
---@param elementData UI.ContextMenu.Entry
---@return string|integer
function ContextMenu.GetEventID(elementData)
    return elementData.eventIDOverride or elementData.id
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Handling redirected vanilla context menus - UNUSED?
Client.UI.ContextMenu.RegisterElementListener("vanilla_button", "buttonPressed", function(_, params)
    local ui = Ext.UI.GetByType(Ext.UI.TypeID.contextMenu.Object) or Ext.UI.GetByType(Ext.UI.TypeID.contextMenu.Default)
    ContextMenu:DebugLog("Handled vanilla button: " .. params.actionID)
    ui:ExternalInterfaceCall("buttonPressed", params.ID, params.actionID)
end)

---Handles button press events.
---@diagnostic disable: duplicate-doc-param
---@param ui UI.ContextMenu.Instance
---@param _ any
---@param _ any ID.
---@param elementID string
---@param _ any
---@param amountTxt string?
---@diagnostic enable: duplicate-doc-param
local function OnButtonPressed(ui, _, _, elementID, _, amountTxt)
    ContextMenu:DebugLog("Button pressed: " .. elementID)

    local elementData = ContextMenu.GetElementData(elementID)

    -- Vanilla buttons have simplified logic
    if not elementData then
        ContextMenu.Events.EntryPressed:Throw({
            ID = tonumber(elementID),
        })
        return
    end

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
        ContextMenu.Events.EntryPressed:Throw({
            ID = elementID,
        })

        -- Can specify a net msg to auto-post, eliminating the need to create handlers for simple commands
        if elementData.netMsg then
            local msg = {NetID = ContextMenu.GetCurrentEntity().NetID, ClientCharacterNetID = Client.GetCharacter().NetID, Params = elementData.params}

            -- If the element is a checkbox, also send new state
            if elementData.type == "checkbox" then
                ---@cast elementData UI.ContextMenu.Entry.Checkbox
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
ContextMenu:RegisterCallListener("pipVanillaContextMenuOpened", function (_)
    local vanillaElements = ContextMenu.vanillaContextData
    local itemHandle = ContextMenu.itemHandle or ContextMenu._LatestHoveredItemHandle
    local item = itemHandle and Item.Get(itemHandle) or nil

    -- Close our instance - we don't support using both at once
    ContextMenu.Close(ContextMenu.UI)

    -- Update bookkeeping
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

---Handles button selection (hover) events.
---@param ui UI.ContextMenu.Instance
---@param method string
---@param elementID string
---@diagnostic disable-next-line: unused-local
local function OnButtonSelected(ui, method, elementID)

    local elementData = ContextMenu.GetElementData(elementID)
    if not elementData then return nil end

    local previousSelectedID = ContextMenu.selectedElements[elementData.menu]

    -- No events for re-hovering
    if previousSelectedID == elementID then return nil end

    ContextMenu:DebugLog("Button selected: " .. elementID)

    ContextMenu.selectedElements[elementData.menu] = elementData.id

    if elementData and elementData.subMenu then
        ContextMenu.RequestMenu(nil, nil, elementData.subMenu, ui, elementData)
    end

    -- Remove submenus of previously selected element
    if previousSelectedID then
        ContextMenu.CheckRemoveSubMenu(ui, previousSelectedID)
    end

    Utilities.Hooks.FireEvent("PIP_ContextMenu", "buttonSelected" .. "_" .. elementID)
end

---Handles removable button press events.
---@param ui UI.ContextMenu.Instance
---@param _ any
---@param elementID string
local function OnRemovableButtonPressed(ui, _, elementID)
    ContextMenu:DebugLog("Removable button pressed: " .. elementID)

    local elementData = ContextMenu.GetElementData(elementID)
    local eventID = ContextMenu.GetEventID(elementData)

    Utilities.Hooks.FireEvent("PIP_ContextMenu", "removablePressed" .. "_" .. eventID, ContextMenu.GetCurrentEntity(), elementData.params)

    ContextMenu.Close(ui) -- TODO support removing elements in flash
end

---Handles stat button press events.
---@param ui UI.ContextMenu.Instance
---@param method string
---@param currentAmount number
---@param addition boolean
---@param elementID string
local function OnStatButtonPressed(ui, method, currentAmount, addition, elementID)
    local root = ui:GetRoot()
    ContextMenu:DebugLog("Stat button pressed: " .. elementID)

    local elementData = ContextMenu.GetElementData(elementID) ---@cast elementData UI.ContextMenu.Entry.Stat

    -- TODO cleanup
    if elementData.type == "removable" then
        OnRemovableButtonPressed(ui, method, elementID)
        return nil
    end

    elementID = ContextMenu.GetEventID(elementData)

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

---Handles context menu request events.
---@param ui UI.ContextMenu.Instance
---@param _ any
---@param id string
---@param x number
---@param y number
---@param entityHandle number?
---@vararg any
local function OnRequestContextMenu(ui, _, id, x, y, entityHandle, ...)
    -- The passed character handle, if any, becomes the associated character with this context menu. Otherwise, we default to client-controlled char.
    if entityHandle then
        entityHandle = Ext.UI.DoubleToHandle(entityHandle)

        if Character.Get(entityHandle) then
            ContextMenu._LatestHoveredCharacterHandle = entityHandle
        else
            ContextMenu.itemHandle = entityHandle
        end
    end

    -- Convert stage coordinates to global screen ones
    local pos = Vector.Create(x, y)
    pos = Client.GetUI(ui):FlashPositionToScreen(pos)

    -- Always use our instance for user-made context menus
    ContextMenu.RequestMenu(pos[1], pos[2], id, ContextMenu.UI, ...)
end

-- Parses updateButtons() from vanilla context menu to keep track of vanilla context menu elements.
ContextMenu:RegisterInvokeListener("updateButtons", function(ev)
    local root = ev.UI:GetRoot()
    local data = ParseFlashArray(root.buttonArr, ContextMenu.ARRAY_ENTRY_TEMPLATES.BUTTON) ---@type ContextMenuUI_ArrayEntry_Button[]

    ContextMenu.vanillaContextData = data
end, "Vanilla")

---Fetches item from vanilla context menu calls.
---@param ui UI.ContextMenu.Instance
---@param method string
---@param handle1 number
---@param handle2 number
---@diagnostic disable-next-line: unused-local
local function OnContextMenu(ui, method, handle1, handle2)
    -- PartyInventory uses handle1 param (with handle2 being the character handle),
    -- whereas other UIs use handle2 for the item instead.
    local parsedHandle1 = Ext.UI.DoubleToHandle(handle1)
    local parsedHandle2 = Ext.UI.DoubleToHandle(handle2)
    local itemHandle = nil ---@type ItemHandle?
    if Ext.Utils.GetHandleType(parsedHandle1) == "ClientItem" then
        itemHandle = parsedHandle1
    elseif Ext.Utils.GetHandleType(parsedHandle2) == "ClientItem" then
        itemHandle = parsedHandle2
    else
        itemHandle = nil -- Right-clicking empty slots in containerInventory causes this UICall to be sent with null handles.
    end
    if itemHandle then
        local item = Item.Get(itemHandle)
        ContextMenu.itemHandle = item.Handle
    end
end

Ext.Events.SessionLoaded:Subscribe(function()
    if Client.IsUsingController() then return end

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
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse})
Pointer.Events.HoverCharacter2Changed:Subscribe(function (_)
    UpdateLatestHoveredCharacter()
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse})

-- Listen for items being hovered in the world to track their handle.
Pointer.Events.HoverItemChanged:Subscribe(function (_)
    UpdateLatestHoveredItem()
end, {EnabledFunctor = Client.IsUsingKeyboardAndMouse})
