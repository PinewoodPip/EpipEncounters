
---@class GenericUI
local Generic = Client.UI.Generic

---Base interface class for prefabs.
---@class GenericUI_Prefab : Class
---@field UI GenericUI_Instance
local Prefab = {
    ID = "None",
    Events = {}, -- Will be initialized into events.
    Hooks = {}, -- Will be initialized into events.
}
Generic:RegisterClass("GenericUI_Prefab", Prefab)
Generic._Prefab = Prefab

---Call to initialize the prefab class.
---Cast to your prefab type afterwards.
---@protected
---@param ui GenericUI_Instance
---@param id string
---@return GenericUI_Prefab
function Prefab:_Create(ui, id, ...)
    local obj = {UI = ui, ID = id}
    obj = self:__Create(obj) ---@cast obj GenericUI_Prefab

    obj:_SetupEvents()
    obj:_Setup(...)

    return obj
end

---Creates an element belonging to the prefab.
---@generic T
---@param id string Automatically prefixed.
---@param elementType `T`|GenericUI_ElementType
---@param parent (GenericUI_Element|string)?
---@return T
function Prefab:CreateElement(id, elementType, parent)
    return self.UI:CreateElement(self:PrefixID(id), elementType, parent)
end

---Returns the prefix to use for elements created as part of the prefab.
function Prefab:PrefixID(id)
    return self.ID .. "_" .. id
end

---@see GenericUI_I_Elementable
---@deprecated
function Prefab:GetMainElement()
    return self.UI:GetElementByID(self:PrefixID("Container"))
end

---Destroys the prefab instance.
---@abstract
function Prefab:Destroy()
    Generic:Error("Prefab:Destroy", "Not implemented for this prefab")
end

---Called after `_Create()`.
---@virtual
---@deprecated
---@protected
---@param ... any
function Prefab:_Setup(...) end

---Initializes the events and hooks of the prefab.
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