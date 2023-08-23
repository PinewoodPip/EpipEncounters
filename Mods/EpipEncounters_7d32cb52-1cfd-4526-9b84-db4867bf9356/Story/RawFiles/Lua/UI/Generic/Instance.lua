
---@class GenericUI
local Generic = Client.UI.Generic

---Represents a Generic UI instance. Allows interfacing with the UI from lua.
---@class GenericUI_Instance : UI
---@field private ID string
local _Instance = {
    ID = "UNKNOWN",
    CurrentTooltipElement = nil, -- Current element's ID and UI whose tooltip is being displayed.
    Elements = {},

    TRACE_LEVELS = {
        INFO = 0,
        WARNING = 1,
        ERROR = 2,
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        IggyEventCaptured = {}, ---@type Event<GenericUI.Instance.Events.IggyEventCaptured>
    },
}
Generic:RegisterClass("GenericUI_Instance", _Instance, {})
Inherit(_Instance, Client.UI._BaseUITable)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI_Event_ViewportChanged
---@field Width integer
---@field Height integer

---@class GenericUI.Instance.Events.IggyEventCaptured
---@field EventID string Without "IE " prefix.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an instance out of a UI table.
---@param ui UI Must be an initialized instance of the UI class.
function _Instance.Create(ui)
    local instance = _Instance:__Create(ui) ---@cast instance GenericUI_Instance
    return instance
end

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

---Sets whether an iggy event should be captured.
---@param eventID string Unprefixed name; ex. "UICancel"
---@param capture boolean All events are uncaptured by default.
function _Instance:SetIggyEventCapture(eventID, capture)
    local root = self:GetRoot()
    root.SetIggyEventCapture("IE " .. eventID, capture)
end

---@param element GenericUI_Element
function _Instance:DestroyElement(element)
    local root = self:GetRoot()
    local parent = element:GetParent()

    if parent then
        ---@diagnostic disable-next-line: invisible
        parent:_UnregisterChild(element)
    end

    root.DestroyElement(element.ID)
    self.Elements[element.ID] = nil
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
        _Instance:Error("CreateElement", "Tried to instantiate an element of unknown type: " .. elementType)
    end
    -- TODO fix lists first
    -- if self:GetElementByID(id) ~= nil then
    --     _Instance:Error("CreateElement", "Attemped to create an element with an ID already in use:", id)
    -- end

    -- Create element in flash
    root.AddElement(id, elementType, parentID or "")

    element = {
        UI = self,
        ID = id,
        Type = elementType,
        ParentID = parentID or "",
        _Children = {},
    }
    Inherit(element, elementTable)

    -- Map ID to lua element
    self.Elements[id] = element

    ---@diagnostic disable: invisible
    if parentID then
        local parentElement = self:GetElementByID(parentID)
        parentElement:_RegisterChild(element)
    end

    element:_RegisterEvents()
    element:_OnCreation()
    ---@diagnostic enable: invisible

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