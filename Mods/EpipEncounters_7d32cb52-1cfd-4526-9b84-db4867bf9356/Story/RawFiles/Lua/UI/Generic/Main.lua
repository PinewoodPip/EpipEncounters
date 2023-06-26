
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

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_HotbarSlot"|"GenericUI_Prefab_Spinner"|"GenericUI_Prefab_Text"|"GenericUI_Prefab_LabelledDropdown"|"GenericUI_Prefab_LabelledCheckbox"|"GenericUI_Prefab_LabelledTextField"|"GenericUI_Prefab_FormHorizontalList"|"GenericUI_Prefab_LabelledIcon"|"GenericUI_Prefab_Status"|"GenericUI_Prefab_TooltipPanel"|"GenericUI_Prefab_FormElementBackground"|"GenericUI_Prefab_LabelledSlider"|"GenericUI_Prefab_FormSet"|"GenericUI_Prefab_FormElement"|"GenericUI_Prefab_FormSetEntry"|"GenericUI_Prefab_Selector"|"GenericUI_Prefab_DraggingArea"

---@alias GenericUI_ParentIdentifier string|GenericUI_Element

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
---@field private ID string
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

---Returns the string identifier of the UI.
---@return string
function _Instance:GetID()
    return self.ID
end

---@param id string
---@return GenericUI_Element?
function _Instance:GetElementByID(id)
    return self.Elements[id]
end

---@param element GenericUI_Element
function _Instance:DestroyElement(element)
    local root = self:GetRoot()

    root.DestroyElement(element.ID)
end

---@param id string
---@return FlashMovieClip?
function _Instance:GetMovieClipByID(id)
    return self:GetRoot().elements[id]
end

---Destroys the UI.
function _Instance:Destroy()
    local ui = self:GetUI()
    local id = self.ID
    local typeID = ui:GetTypeId()

    -- Destroy UIObject
    Ext.UI.Destroy(id)

    -- Make the table unusable
    table.destroy(self, "Attempted to interface with a destroyed UI (" .. id .. ")")

    -- Remove the UI from the manager
    Generic.INSTANCES[typeID] = nil
end

---@generic T
---@param id string
---@param elementType `T`|GenericUI_ElementType
---@param parentID string|GenericUI_Element? Defaults to root of the MainTimeline.
---@return `T`
function _Instance:CreateElement(id, elementType, parentID)
    elementType = elementType:gsub("GenericUI_Element_", "")
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
Generic:RegisterClass("GenericUI_Prefab", Prefab)
Generic._Prefab = Prefab

---@protected
---@param ui GenericUI_Instance
---@param id string
---@return GenericUI_Prefab
function Prefab:_Create(ui, id, ...)
    local obj = {UI = ui, ID = id}
    Inherit(obj, self)

    obj:_SetupEvents()
    obj:_Setup(...)

    return obj
end

---@generic T
---@param id string Automatically prefixed.
---@param elementType `T`|GenericUI_ElementType
---@param parent (GenericUI_Element|string)?
---@return T
function Prefab:CreateElement(id, elementType, parent)
    return self.UI:CreateElement(self:PrefixID(id), elementType, parent)
end

function Prefab:_Setup() end

function Prefab:PrefixID(id)
    return self.ID .. "_" .. id
end

---@deprecated
function Prefab:GetMainElement()
    return self.UI:GetElementByID(self:PrefixID("Container"))
end

function Prefab:_SetupEvents()
    local eventTemplates = self.Events
    local hookTemplates = self.Hooks
    
    self.Events = {}
    self.Hooks = {}
    for id,_ in pairs(eventTemplates or {}) do
        self.Events[id] = SubscribableEvent:New(id)
    end
    for id,_ in pairs(hookTemplates or {}) do
        self.Hooks[id] = SubscribableEvent:New(id)
    end
end

function Prefab:Destroy()
    Generic:Error("Prefab:Destroy", "Not implemented for this prefab")
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ev EclLuaUICallEvent
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
function Generic.Create(id)
    ---@type GenericUI_Instance
    local ui = {
        ID = id,
        Name = id,
        Elements = {},
        Events = {
            -- TODO remove
            ---@type GenericUI_Event_Button_Pressed
            Button_Pressed = {},
            ---@type GenericUI_Event_StateButton_StateChanged
            StateButton_StateChanged = {},
            ---@type Event<GenericUI_Event_ViewportChanged>
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

    -- Basic element events
    Generic.ForwardUICall(ui, "elementMouseUp", "MouseUp")
    Generic.ForwardUICall(ui, "elementMouseDown", "MouseDown")
    ui:RegisterCallListener("elementMouseOver", Generic.OnElementMouseOver)
    ui:RegisterCallListener("elementMouseOut", Generic.OnElementMouseOut)
    Generic.ForwardUICall(ui, "elementRightClick", "RightClick")
    Generic.ForwardUICall(ui, "elementTweenCompleted", "TweenCompleted", {"EventID"})
    
    ui:RegisterCallListener("ShowElementTooltip", Generic.OnElementShowTooltip)
    -- ui:RegisterCallListener("viewportChanged", Generic.OnViewportChanged)

    -- Text
    Generic.ForwardUICall(ui, "Text_Changed", "Changed", {"Text"})

    -- Button
    Generic.ForwardUICall(ui, "Button_Pressed", "Pressed")

    -- StateButton
    Generic.ForwardUICall(ui, "StateButton_StateChanged", "StateChanged", {"Active"})

    -- Slot
    Generic.ForwardUICall(ui, "Slot_DragStarted", "DragStarted")
    Generic.ForwardUICall(ui, "Slot_Clicked", "Clicked")

    -- ComboBox
    ui:RegisterCallListener("ComboBox_ItemSelected", Generic.OnComboBoxItemSelected)

    -- Slider
    Generic.ForwardUICall(ui, "Slider_HandleReleased", "HandleReleased", {"Value"})
    Generic.ForwardUICall(ui, "Slider_HandleMoved", "HandleMoved", {"Value"})

    -- Logging
    ui:RegisterCallListener("GenericLog", function(_, elementID, elementType, msg, msgType)
        msg = string.format("TRACE %s (%s): %s", elementID, elementType, msg)

        if msgType == ui.TRACE_LEVELS.WARNING then
            ui:LogWarning(msg)
        elseif msgType == ui.TRACE_LEVELS.ERROR then
            ui:LogError(msg)
        else
            ui:Log(msg)
        end
    end)

    if ui:Exists() then
        ui:Hide()
    end
    
    return ui
end

---@generic T
---@param className `T`|GenericUI_PrefabClass
---@return T
function Generic.GetPrefab(className)
    return Generic.PREFABS[className]
end

---@param tbl1 table
---@param tbl2 table
function Generic.Inherit(tbl1, tbl2)
    if not tbl1.Events then tbl1.Events = {} end
    if tbl2.Events then
        for name,_ in pairs(tbl2.Events) do
            tbl1.Events[name] = {}
        end
    end
    Inherit(tbl1, tbl2)
end

---@param elementType string
---@param elementTable GenericUI_Element
function Generic.RegisterElementType(elementType, elementTable)
    Generic.ELEMENTS[elementType] = elementTable
end

---@param call string
---@vararg LuaFlashCompatibleType
---@return fun(self:GenericUI_Element, ...):any?
function Generic.ExposeFunction(call)
    local fun = function(obj, ...)
        local mc = obj:GetMovieClip()

        local success, result = pcall(mc[call], ...)

        if not success then
            Generic:LogError("Error while calling exposed " .. call .. "() function on " .. obj.ID .. ": " .. result)
        end

        return result
    end

    return fun
end

---Returns the instance of a Generic UI by its identifier.
---@param id string|integer
---@return GenericUI_Instance
function Generic.GetInstance(id)
    local instance

    if type(id) == "string" then
        for _,inst in pairs(Generic.INSTANCES) do
            if inst:GetID() == id then
                instance = inst
                break
            end
        end
    elseif type(id) == "number" then
        instance = Generic.INSTANCES[id]
    else
        Generic:Error("GetInstance", "Wrong parameter type", type(id))
    end

    return instance
end

---Registers a prefab.
---@param id string
---@param prefab table
function Generic.RegisterPrefab(id, prefab)
    -- Only set metatable if the prefab has not manually inherited from something else
    if getmetatable(prefab) == nil then
        Inherit(prefab, Generic._Prefab)
    end

    Generic.PREFABS[id] = prefab
end

---@param ui GenericUI_Instance
---@param call string
---@param eventName string
---@param fields string[]?
function Generic.ForwardUICall(ui, call, eventName, fields)
    fields = fields or {}
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
            tooltip.Data = table.deepCopy(element.Tooltip.Data) or {}
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
        ---@diagnostic disable-next-line: invisible
        Option = element._Options[index + 1]
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