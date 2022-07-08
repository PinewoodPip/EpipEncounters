
Client.UI.Generic = {
    SWF_PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/generic.swf",
    DEFAULT_LAYER = 15,
    _Element = {},
}
local Generic = Client.UI.Generic

---------------------------------------------
-- INSTANCE
---------------------------------------------

---@class GenericUI_Instance : UI
---@field ID string
---@field Root GenericUI_Element
---@field Elements table<string, GenericUI_Element>

---@type GenericUI_Instance
local _Instance = {
    ID = "UNKNOWN",
    Elements = {},
}

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

---@param id string
---@param elementType GenericUI_ElementType
---@param parentID string? Defaults to root of the MainTimeline.
---@return GenericUI_Element?
function _Instance:CreateElement(id, elementType, parentID)
    local element = nil
    local root = self:GetRoot()

    root.AddElement(id, elementType, parentID or "")

    -- element = Client.Flash.GetLastElement(root.elements)
    -- TODO

    return element
end

---------------------------------------------
-- ELEMENT
---------------------------------------------

---@type GenericUI_Element
local _Element = Generic._Element

---@class GenericUI_Element
---@field UI GenericUI_Instance
---@field ID string
---@field Type string

---Get the movie clip of this element.
---@return FlashMovieClip
function _Element:GetMovieClip()
    return self.UI:GetMovieClipByID(self.ID)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param id string
---@return GenericUI_Instance
function Generic.Create(id)
    ---@type GenericUI_Instance
    local ui = {
        ID = id,
        Elements = {},
    }
    Inherit(ui, _Instance)
    local uiOBject = Ext.UI.Create(id, Generic.SWF_PATH, Generic.DEFAULT_LAYER)
    
    Epip.InitializeUI(uiOBject:GetTypeId(), id, ui)

    return ui
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------