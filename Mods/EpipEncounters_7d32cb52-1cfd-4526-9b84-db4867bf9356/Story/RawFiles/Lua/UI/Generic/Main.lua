
---@class GenericUI : Feature
Client.UI.Generic = {
    SWF_PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/generic.swf",
    DEFAULT_LAYER = 15,
    _Element = {},
    ELEMENTS = {}, ---@type table<GenericUI_ElementType, GenericUI_Element>
    PREFABS = {},
    INSTANCES = {} ---@type table<integer, GenericUI_Instance>
}
local Generic = Client.UI.Generic ---@class GenericUI
Epip.InitializeLibrary("Generic", Generic)
Generic:Debug()

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

-- Note that these are bound to each UI! They are not "global" events - you can't listen for an event happening across all instances.

---@class GenericUI_Event_Button_Pressed : Event
---@field RegisterListener fun(self, listener:fun(stringID:string))
---@field Fire fun(self, stringID:string)

---@class GenericUI_Event_StateButton_StateChanged : Event
---@field RegisterListener fun(self, listener:fun(stringID:string, active:boolean))
---@field Fire fun(self, stringID:string, active:boolean)

---------------------------------------------
-- INSTANCE
---------------------------------------------

---@class GenericUI_Instance : UI
local _Instance = {
    ID = "UNKNOWN",
    CurrentTooltipElement = nil, -- Current element's ID and UI whose tooltip is being displayed.
    Elements = {},
    USE_LEGACY_EVENTS = false,

    Events = {
    },
}
Inherit(_Instance, Client.UI._BaseUITable)

---@class GenericUI_Event_ViewportChanged
---@field Width integer
---@field Height integer

---@param id string
---@return GenericUI_Element?
function _Instance:GetElementByID(id)
    return self.Elements[id]
end

---@param id string
---@return FlashMovieClip?
function _Instance:GetMovieClipByID(id)
    return self:GetRoot().elements[id]
end

---@overload fun(self, id:string, elementType:"Empty", parentID:string|GenericUI_Element?):GenericUI_Element_Empty
---@overload fun(self, id:string, elementType:"TiledBackground", parentID:string|GenericUI_Element?):GenericUI_Element_TiledBackground
---@overload fun(self, id:string, elementType:"Text", parentID:string|GenericUI_Element?):GenericUI_Element_Text
---@overload fun(self, id:string, elementType:"IggyIcon", parentID:string|GenericUI_Element?):GenericUI_Element_IggyIcon
---@overload fun(self, id:string, elementType:"Button", parentID:string|GenericUI_Element?):GenericUI_Element_Button
---@overload fun(self, id:string, elementType:"VerticalList", parentID:string|GenericUI_Element?):GenericUI_Element_VerticalList
---@overload fun(self, id:string, elementType:"HorizontalList", parentID:string|GenericUI_Element?):GenericUI_Element_HorizontalList
---@overload fun(self, id:string, elementType:"ScrollList", parentID:string|GenericUI_Element?):GenericUI_Element_ScrollList
---@overload fun(self, id:string, elementType:"StateButton", parentID:string|GenericUI_Element?):GenericUI_Element_StateButton
---@overload fun(self, id:string, elementType:"Divider", parentID:string|GenericUI_Element?):GenericUI_Element_Divider
---@overload fun(self, id:string, elementType:"Slot", parentID:string|GenericUI_Element?):GenericUI_Element_Slot
---@overload fun(self, id:string, elementType:"ComboBox", parentID:string|GenericUI_Element?):GenericUI_Element_ComboBox
---@param elementType GenericUI_ElementType
---@param parentID string|GenericUI_Element? Defaults to root of the MainTimeline.
---@return GenericUI_Element? Nil in case of failure (ex. invalid type).
function _Instance:CreateElement(id, elementType, parentID)
    local element = nil ---@type GenericUI_Element
    local elementTable = Generic.ELEMENTS[elementType]
    local root = self:GetRoot()
    if type(parentID) == "table" then parentID = parentID.ID end

    if not elementTable then
        _Instance:LogError("Tried to instantiate an element of unknown type: " .. elementType)
        return nil
    end

    -- Create element in flash
    root.AddElement(id, elementType, parentID or "")

    element = {
        UI = self,
        ID = id,
        Type = elementType,
        ParentID = parentID or "",
    }
    Inherit(element, elementTable)

    -- Map ID to lua element
    self.Elements[id] = element

    element:_RegisterEvents()
    element:_OnCreation()

    return element
end

---@return number, number
function _Instance:GetMousePosition()
    local stage = self:GetRoot().stage
    local uiX, uiY = self:GetPosition()
    local x = stage.mouseX + uiX
    local y = stage.mouseY + uiY

    return x, y
end

---------------------------------------------
-- PREFAB
---------------------------------------------

---@class GenericUI_Prefab
local Prefab = {
    ID = "None",
    UI = nil, ---@type GenericUI_Instance
    Events = {},
}
Generic._Prefab = Prefab

function Prefab:_Setup()
    self:_SetupEvents()
end

function Prefab:PrefixID(id)
    return self.ID .. "_" .. id
end

function Prefab:GetMainElement()
    return self.UI:GetElementByID(self:PrefixID("Container"))
end

function Prefab:_SetupEvents()
    local _Templates = self.Events
    
    self.Events = {}

    for id,_ in pairs(_Templates) do
        self.Events[id] = SubscribableEvent:New(id)
    end
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ev UIEvent
---@param elementID string
---@param eventName string
---@param eventObj table?
function Generic.OnElementUICall(ev, elementID, eventName, eventObj)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(elementID)
    if not element then return nil end
    Generic:DebugLog("CALL " .. eventName, elementID)

    element.Events[eventName]:Throw(eventObj)
end

---@param id string
---@return GenericUI_Instance
function Client.UI.Generic.Create(id)
    ---@type GenericUI_Instance
    local ui = {
        ID = id,
        Name = id,
        Elements = {},
        Events = {
            ---@type GenericUI_Event_Button_Pressed
            Button_Pressed = {},
            ---@type GenericUI_Event_StateButton_StateChanged
            StateButton_StateChanged = {},
            ---@type SubscribableEvent<GenericUI_Event_ViewportChanged>
            ViewportChanged = {Legacy = false},
        },
        TRACE_LEVELS = {
            INFO = 0,
            WARNING = 1,
            ERROR = 2,
        },
    }
    local uiOBject = Ext.UI.Create(id, Generic.SWF_PATH, Generic.DEFAULT_LAYER)
    Epip.InitializeUI(uiOBject:GetTypeId(), id, ui)
    Inherit(ui, _Instance)

    Generic.INSTANCES[uiOBject:GetTypeId()] = ui

    ui:RegisterCallListener("elementMouseUp", Generic.OnElementMouseUp)
    ui:RegisterCallListener("elementMouseDown", Generic.OnElementMouseDown)
    ui:RegisterCallListener("elementMouseOver", Generic.OnElementMouseOver)
    ui:RegisterCallListener("elementMouseOut", Generic.OnElementMouseOut)
    ui:RegisterCallListener("elementRightClick", function(ev, stringID)
        Generic.OnElementUICall(ev, stringID, "RightClick")
    end)
    ui:RegisterCallListener("ShowElementTooltip", Generic.OnElementShowTooltip)
    -- ui:RegisterCallListener("viewportChanged", Generic.OnViewportChanged)

    -- Text
    Generic.ForwardUICall(ui, "Text_Changed", "Changed", {"Text"})

    -- Button
    ui:RegisterCallListener("Button_Pressed", Generic.OnButtonPressed)

    -- StateButton
    ui:RegisterCallListener("StateButton_StateChanged", Generic.OnStateButtonStateChanged)

    -- Slot
    ui:RegisterCallListener("Slot_DragStarted", Generic.OnSlotDragStarted)
    ui:RegisterCallListener("Slot_Clicked", Generic.OnSlotClicked)

    -- ComboBox
    ui:RegisterCallListener("ComboBox_ItemSelected", Generic.OnComboBoxItemSelected)

    -- Slider
    Generic.ForwardUICall(ui, "Slider_HandleReleased", "HandleReleased", {"Value"})

    -- Logging
    ui:RegisterCallListener("GenericLog", function(ev, elementID, elementType, msg, msgType)
        msg = string.format("TRACE %s (%s): %s", elementID, elementType, msg)

        if msgType == ui.TRACE_LEVELS.WARNING then
            ui:LogWarning(msg)
        elseif msgType == ui.TRACE_LEVELS.ERROR then
            ui:LogError(msg)
        else
            ui:Log(msg)
        end
    end)
    
    return ui
end

---Registers a prefab.
---@param id string
---@param prefab table
function Generic.RegisterPrefab(id, prefab)
    Generic.PREFABS[id] = prefab
end

---@param tbl1 table
---@param tbl2 table
function Generic.Inherit(tbl1, tbl2)
    if tbl2.Events then
        for name,_ in pairs(tbl2.Events) do
            tbl1.Events[name] = {}
        end
    end
    Inherit(tbl1, tbl2)
end

---@param elementType string
---@param elementTable GenericUI_Element
function Client.UI.Generic.RegisterElementType(elementType, elementTable)
    Generic.ELEMENTS[elementType] = elementTable
end

---@param call string
---@vararg LuaFlashCompatibleType
---@return fun(self:GenericUI_Element, ...):any?
function Client.UI.Generic.ExposeFunction(call)
    local fun = function(obj, ...)
        local mc = obj:GetMovieClip()

        local success, error, result = pcall(mc[call], ...)

        if not success then
            Generic:LogError("Error while calling exposed " .. call .. "() function on " .. obj.ID .. ": " .. error)
        end

        return result
    end

    return fun
end

---@param id integer
---@return GenericUI_Instance
function Client.UI.Generic.GetInstance(id)
    return Generic.INSTANCES[id]
end

function Client.UI.Generic.RegisterPrefab(id, prefab)
    Generic.PREFABS[id] = prefab
end

---@param ui GenericUI_Instance
---@param call string
---@param eventName string
---@param fields string[]
function Generic.ForwardUICall(ui, call, eventName, fields)
    ui:RegisterCallListener(call, function(ev, id, ...)
        local element = ui:GetElementByID(id)
        if not element then return nil end
    
        local event = {}
        local params = {...}

        for i,param in ipairs(params) do
            event[fields[i]] = param
        end

        element.Events[eventName]:Throw(event)
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Generic.OnElementMouseUp = function(ev, id)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL onElementMouseUp: ", id)

    element.Events.MouseUp:Throw({})
end

Generic.OnElementMouseDown = function(ev, id)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL onElementMouseDown: ", id)

    element.Events.MouseDown:Throw({})
end

Generic.OnElementMouseOver = function(ev, id)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL onElementMouseOver: ", id)

    element.Events.MouseOver:Throw({})

    if element and element.Tooltip then
        element:GetMovieClip().ShowTooltip()
    end
end

Generic.OnElementShowTooltip = function(ev, id, x, y, width, height, _, align)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())
    local mouseX, mouseY = ui:GetMousePosition()
    local element = ui:GetElementByID(id)
    -- local element = ui:GetElementByID(id)

    if Ext.UI.GetViewportSize()[1] - mouseX < 100 then
        mouseX = mouseX - 250
    end

    local offset = {0, 0}
    if type(element.Tooltip) == "table" and element.Tooltip.Spacing then
        offset = element.Tooltip.Spacing
    end

    Generic.CurrentTooltipElement = {
        UI = ui,
        ID = id,
        Position = {
            X = mouseX + offset[1],
            Y = mouseY + offset[2],
        },
    }

    if type(element.Tooltip) == "string" then
        ui:ExternalInterfaceCall("showTooltip", element.Tooltip, mouseX, mouseY, width, height, "left") -- TODO custom align
    else
        if element.Tooltip.Type == "Formatted" then
            -- TODO workaround for Character Creation context
            Client.UI.Hotbar:ExternalInterfaceCall("showSkillTooltip", Client.UI.Hotbar:GetRoot().hotbar_mc.characterHandle, "Teleportation_FreeFall", mouseX, mouseY, width, height)
        elseif element.Tooltip.Type == "Skill" then
            Client.UI.Hotbar:ExternalInterfaceCall("showSkillTooltip", Client.UI.Hotbar:GetRoot().hotbar_mc.characterHandle, element.Tooltip.SkillID, mouseX, mouseY, width, height)
        end
    end
end

Generic.OnTooltip = function(char, skill, tooltip)
    if Generic.CurrentTooltipElement then
        local element = Generic.CurrentTooltipElement.UI:GetElementByID(Generic.CurrentTooltipElement.ID)

        if element.Tooltip.Type == "Formatted" then
            tooltip.Data = element.Tooltip.Data or {}
        end
    end
end
Game.Tooltip.RegisterListener("Skill", nil, Generic.OnTooltip)

Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui)
    if Generic.CurrentTooltipElement then
        local pos = Generic.CurrentTooltipElement.Position

        ui:SetPosition(math.floor(pos.X), math.floor(pos.Y))
    end
end, "After")

Generic.OnElementMouseOut = function(ev, id)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL onElementMouseOut: ", id)

    element.Events.MouseOut:Throw({})

    if element and element.Tooltip and Generic.CurrentTooltipElement and Generic.CurrentTooltipElement.ID == id then -- TODO ui check
        Client.UI.Hotbar:HideTooltip()
        Generic.CurrentTooltipElement.UI:ExternalInterfaceCall("hideTooltip")
        Generic.CurrentTooltipElement = nil
    end
end

Generic.OnButtonPressed = function(ev, id)
    ---@type GenericUI_Element_Button
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    Generic:DebugLog("CALL Button_Pressed: ", id)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())

    ui.Events.Button_Pressed:Fire(id)
    element.Events.Pressed:Throw({})
end

Generic.OnStateButtonStateChanged = function(ev, id, active)
    Generic:DebugLog("CALL StateButton_StateChanged: ", id, active)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())

    ui.Events.StateButton_StateChanged:Fire(id, active)
end

Generic.OnSlotDragStarted = function(ev, id)
    ---@type GenericUI_Element_Slot
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL Slot_DragStarted: ", id)

    element.Events.DragStarted:Throw({})
end

Generic.OnSlotClicked = function(ev, id)
    ---@type GenericUI_Element_Slot
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL Slot_Clicked: ", id)

    element.Events.Clicked:Throw({})
end

Generic.OnComboBoxItemSelected = function(ev, id, index, optionID)
    ---@type GenericUI_Element_ComboBox
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL ComboBox_ItemSelected: ", id)

    element.Events.OptionSelected:Throw({
        Index = index + 1,
        Option = {ID = optionID,}, -- TODO label
    })
end

-- Generic.OnViewportChanged = function(ui)
--     local viewport = Ext.UI.GetViewportSize()

--     ui.Events.ViewportChanged:Throw({
--         Width = viewport[1],
--         Height = viewport[2],
--     })
-- end

-- Listen for viewport changes
local oldViewport = {0, 0}
Ext.Events.Tick:Subscribe(function (e)
    local viewport = Ext.UI.GetViewportSize()
    local width, height = viewport[1], viewport[2]

    if oldViewport[1] ~= width or oldViewport[2] ~= height then
        for _,ui in pairs(Generic.INSTANCES) do
            ui.Events.ViewportChanged:Throw({
                Width = width,
                Height = height,
            })
        end

        oldViewport = viewport
    end
end)