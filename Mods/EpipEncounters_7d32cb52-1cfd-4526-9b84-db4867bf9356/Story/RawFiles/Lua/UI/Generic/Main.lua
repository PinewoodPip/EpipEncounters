
Client.UI.Generic = {
    SWF_PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/generic.swf",
    DEFAULT_LAYER = 15,
    _Element = {},
    ELEMENTS = {}, ---@type table<GenericUI_ElementType, GenericUI_Element>
    INSTANCES = {} ---@type table<integer, GenericUI_Instance>
}
local Generic = Client.UI.Generic
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
}
Inherit(_Instance, Client.UI._BaseUITable)

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

---@overload fun(id:string, elementType:"Empty", parentID:string|GenericUI_Element?):GenericUI_Element_Empty
---@overload fun(id:string, elementType:"TiledBackground", parentID:string|GenericUI_Element?):GenericUI_Element_TiledBackground
---@overload fun(id:string, elementType:"Text", parentID:string|GenericUI_Element?):GenericUI_Element_Text
---@overload fun(id:string, elementType:"IggyIcon", parentID:string|GenericUI_Element?):GenericUI_Element_IggyIcon
---@overload fun(id:string, elementType:"Button", parentID:string|GenericUI_Element?):GenericUI_Element_Button
---@overload fun(id:string, elementType:"VerticalList", parentID:string|GenericUI_Element?):GenericUI_Element_VerticalList
---@overload fun(id:string, elementType:"HorizontalList", parentID:string|GenericUI_Element?):GenericUI_Element_HorizontalList
---@overload fun(id:string, elementType:"ScrollList", parentID:string|GenericUI_Element?):GenericUI_Element_ScrollList
---@overload fun(id:string, elementType:"StateButton", parentID:string|GenericUI_Element?):GenericUI_Element_StateButton
---@overload fun(id:string, elementType:"Divider", parentID:string|GenericUI_Element?):GenericUI_Element_Divider
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
-- METHODS
---------------------------------------------

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
    ui:RegisterCallListener("ShowElementTooltip", Generic.OnElementShowTooltip)

    -- Button
    ui:RegisterCallListener("Button_Pressed", Generic.OnButtonPressed)

    -- StateButton
    ui:RegisterCallListener("StateButton_StateChanged", Generic.OnStateButtonStateChanged)

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

---@param elementType string
---@param elementTable GenericUI_Element
function Client.UI.Generic.RegisterElementType(elementType, elementTable)
    Generic.ELEMENTS[elementType] = elementTable
end

---@param call string
---@vararg LuaFlashCompatibleType
---@return fun(self:GenericUI_Element, ...):any?
function Client.UI.Generic.ExposeFunction(call, ...)
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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Generic.OnElementMouseUp = function(ev, id)
    Generic:DebugLog("CALL onElementMouseUp: ", id)
end

Generic.OnElementMouseDown = function(ev, id)
    Generic:DebugLog("CALL onElementMouseDown: ", id)
end

Generic.OnElementMouseOver = function(ev, id)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())
    Generic:DebugLog("CALL onElementMouseOver: ", id)

    local element = ui:GetElementByID(id)

    if element and element.Tooltip then
        element:GetMovieClip().ShowTooltip()
    end
end

Generic.OnElementShowTooltip = function(ev, id, x, y, width, height, _, align)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())
    local mouseX, mouseY = ui:GetMousePosition()
    local element = ui:GetElementByID(id)
    -- local element = ui:GetElementByID(id)

    print(Ext.UI.GetViewportSize()[1], mouseX, Ext.UI.GetViewportSize()[1] - mouseX < 100)
    if Ext.UI.GetViewportSize()[1] - mouseX < 100 then
        mouseX = mouseX - 250
    end

    Generic.CurrentTooltipElement = {
        UI = ui,
        ID = id,
        Position = {
            X = mouseX,
            Y = mouseY,
        },
    }


    if type(element.Tooltip) == "string" then
        ui:ExternalInterfaceCall("showTooltip", element.Tooltip, mouseX, mouseY, width, height, "left") -- TODO custom align
    else
        -- TODO workaround for Character Creation context
        Client.UI.Hotbar:ExternalInterfaceCall("showSkillTooltip", Client.UI.Hotbar:GetRoot().hotbar_mc.characterHandle, "Teleportation_FreeFall", mouseX, mouseY, width, height)
    end

    -- ui:ExternalInterfaceCall("showTalentTooltip", 126, Ext.Utils.HandleToInteger(Client.GetCharacter().Handle), x, y, width, height, "none")
end

Generic.OnTooltip = function(char, skill, tooltip)
    if Generic.CurrentTooltipElement then
        tooltip.Data = Generic.CurrentTooltipElement.UI:GetElementByID(Generic.CurrentTooltipElement.ID).Tooltip or {}  
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
    local ui = Generic.GetInstance(ev.UI:GetTypeId())
    Generic:DebugLog("CALL onElementMouseOut: ", id)

    local element = ui:GetElementByID(id)

    if element and element.Tooltip and Generic.CurrentTooltipElement and Generic.CurrentTooltipElement.ID == id then -- TODO ui check
        Client.UI.Hotbar:ExternalInterfaceCall("hideTooltip")
        Generic.CurrentTooltipElement.UI:ExternalInterfaceCall("hideTooltip")
        Generic.CurrentTooltipElement = nil
    end
end

Generic.OnButtonPressed = function(ev, id)
    Generic:DebugLog("CALL Button_Pressed: ", id)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())

    ui.Events.Button_Pressed:Fire(id)
end

Generic.OnStateButtonStateChanged = function(ev, id, active)
    Generic:DebugLog("CALL StateButton_StateChanged: ", id, active)
    local ui = Generic.GetInstance(ev.UI:GetTypeId())

    ui.Events.StateButton_StateChanged:Fire(id, active)
end