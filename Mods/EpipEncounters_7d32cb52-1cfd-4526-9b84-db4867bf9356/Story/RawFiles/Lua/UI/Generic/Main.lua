
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

---@alias GenericUI_ParentIdentifier string|GenericUI_Element

---------------------------------------------
-- METHODS
---------------------------------------------

---@param id string
---@param layer integer? Defaults to `DEFAULT_LAYER`.
---@return GenericUI_Instance
function Generic.Create(id, layer)
    ---@type GenericUI_Instance
    local ui = {
        ID = id,
        Name = id,
        Elements = {},
        Events = {
            -- TODO fix code duplication (IggyEventCaptured is also in the IDE annotation version)
            IggyEventUpCaptured = {Legacy = false}, ---@type Event<GenericUI.Instance.Events.IggyEventCaptured>
            IggyEventDownCaptured = {Legacy = false}, ---@type Event<GenericUI.Instance.Events.IggyEventCaptured>
        },
        Hooks = {},
    }
    local uiOBject = Ext.UI.Create(id, Generic.SWF_PATH, layer or Generic.DEFAULT_LAYER)
    Epip.InitializeUI(uiOBject:GetTypeId(), id, ui)
    ui = Generic:GetClass("GenericUI_Instance").Create(ui)

    Generic.INSTANCES[uiOBject:GetTypeId()] = ui

    -- Basic element events
    Generic._ForwardUICall(ui, "elementMouseUp", "MouseUp")
    Generic._ForwardUICall(ui, "elementMouseDown", "MouseDown")
    ui:RegisterCallListener("elementMouseOver", Generic._OnElementMouseOver)
    ui:RegisterCallListener("elementMouseOut", Generic._OnElementMouseOut)
    Generic._ForwardUICall(ui, "elementRightClick", "RightClick")
    ui:RegisterCallListener("elementMouseMove", function (_, elementID, localX, localY, stageX, stageY)
        local element = ui:GetElementByID(elementID)
        element.Events.MouseMove:Throw({
            LocalPos = Vector.Create(localX, localY),
            StagePos = Vector.Create(stageX, stageY),
        })
    end)
    Generic._ForwardUICall(ui, "elementTweenCompleted", "TweenCompleted", {"EventID"})

    ui:RegisterCallListener("ShowElementTooltip", Generic._OnElementShowTooltip)

    -- Text
    Generic._ForwardUICall(ui, "Text_Changed", "Changed", {"Text"})
    Generic._ForwardUICall(ui, "Text_Focused", "Focused")
    Generic._ForwardUICall(ui, "Text_Unfocused", "Unfocused")

    -- Button
    Generic._ForwardUICall(ui, "Button_Pressed", "Pressed")

    -- StateButton
    Generic._ForwardUICall(ui, "StateButton_StateChanged", "StateChanged", {"Active"})

    -- Slot
    Generic._ForwardUICall(ui, "Slot_DragStarted", "DragStarted")
    Generic._ForwardUICall(ui, "Slot_Clicked", "Clicked")

    -- ComboBox
    ui:RegisterCallListener("ComboBox_ItemSelected", Generic._OnComboBoxItemSelected)

    -- Slider
    Generic._ForwardUICall(ui, "Slider_HandleReleased", "HandleReleased", {"Value"})
    Generic._ForwardUICall(ui, "Slider_HandleMoved", "HandleMoved", {"Value"})

    -- IggyEvent forwarding
    ui:RegisterCallListener("IggyEventCaptured", Generic._OnIggyEventCaptured)

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

---@private
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
---@param id string|integer String ID of the UI or its TypeID.
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
function Generic._ForwardUICall(ui, call, eventName, fields)
    fields = fields or {}
    ui:RegisterCallListener(call, function(_, id, ...)
        local element = ui:GetElementByID(id)
        if not element then return end -- TODO Does this ever happen? If so, investigate

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

---Handles a MouseOver event.
---@param ev EclLuaUICallEvent
---@param id string Element ID.
function Generic._OnElementMouseOver(ev, id)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return end
    Generic:DebugLog("CALL onElementMouseOver: ", id)

    element.Events.MouseOver:Throw({})

    if element and element.Tooltip then
        element:GetMovieClip().ShowTooltip()
    end
end

---Handles a ShowTooltip event.
---@param ev EclLuaUICallEvent
---@param id string
---@param x number
---@param y number
---@param width number
---@param height number
---@param _ unknown
---@param align unknown
function Generic._OnElementShowTooltip(ev, id, x, y, width, height, _, align)
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

---Handles a Game.Tooltip event invoked from a Generic element.
---@param char EclCharacter
---@param skill string
---@param tooltip any
function Generic._OnTooltip(char, skill, tooltip)
    if Generic.CurrentTooltipElement then
        local element = Generic.CurrentTooltipElement.UI:GetElementByID(Generic.CurrentTooltipElement.ID)

        if element.Tooltip.Type == "Formatted" then
            tooltip.Data = table.deepCopy(element.Tooltip.Data) or {}
        end
    end
end
Game.Tooltip.RegisterListener("Skill", nil, Generic._OnTooltip)

-- Listen for tooltips being ready to position
Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui)
    if Generic.CurrentTooltipElement then
        local pos = Generic.CurrentTooltipElement.Position

        ui:SetPosition(math.floor(pos.X), math.floor(pos.Y))
    end
end, "After")

---Handles a MouseOut event.
---@param ev EclLuaUICallEvent
---@param id string
function Generic._OnElementMouseOut(ev, id)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id)
    if not element then return nil end
    Generic:DebugLog("CALL onElementMouseOut: ", id)

    element.Events.MouseOut:Throw({})

    -- Hide tooltip
    if element and element.Tooltip and Generic.CurrentTooltipElement and Generic.CurrentTooltipElement.ID == id then -- TODO ui check
        Client.UI.Hotbar:HideTooltip()
        Generic.CurrentTooltipElement.UI:ExternalInterfaceCall("hideTooltip")
        Generic.CurrentTooltipElement = nil
    end
end

---Handles ComboBox items being selected.
---@param ev EclLuaUICallEvent
---@param id string
---@param index integer
---@param optionID string
function Generic._OnComboBoxItemSelected(ev, id, index, optionID)
    local element = Generic.GetInstance(ev.UI:GetTypeId()):GetElementByID(id) ---@cast element GenericUI_Element_ComboBox
    if not element then return nil end
    Generic:DebugLog("CALL ComboBox_ItemSelected: ", id)

    element.Events.OptionSelected:Throw({
        Index = index + 1,
        ---@diagnostic disable-next-line: invisible
        Option = element._Options[index + 1]
    })
end

---Handles IggyEvents being captured.
---@param ev EclLuaUICallEvent
---@param _ integer Event index, from the events array. Arbitrary, not very relevant.
---@param eventID string
---@param timing "Up"|"Down"
function Generic._OnIggyEventCaptured(ev, _, eventID, timing)
    local instance = Generic.GetInstance(ev.UI:GetTypeId())
    Generic:DebugLog("CALL IggyEventCaptured: ", eventID)

    local event = timing == "Up" and instance.Events.IggyEventUpCaptured or instance.Events.IggyEventDownCaptured
    event:Throw({
        EventID = eventID:gsub("^IE ", ""),
        Timing = timing,
    })
end