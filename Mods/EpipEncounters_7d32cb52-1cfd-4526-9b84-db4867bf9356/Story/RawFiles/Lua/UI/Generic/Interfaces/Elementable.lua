
---------------------------------------------
-- Interface for prefabs that allow calling methods from the Element class, operating upon their root element.
---------------------------------------------

local Generic = Client.UI.Generic

---@class GenericUI_I_Elementable : Class, GenericUI_Element
local Elementable = {}
Generic:RegisterClass("GenericUI_I_Elementable", Elementable)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the root element of the prefab.
---Any GenericUI_Element methods that are not implemented explicitly in the prefab
---will instead defer to the GenericUI_Element implementation,
---being called upon this root element.
---@abstract
---@return GenericUI_Element
function Elementable:GetRootElement()
    ---@diagnostic disable-next-line: missing-return
    Generic:Error("Elementable:GetRootElement", "Not implemented for", self:GetClassName())
end

---Returns whether the root element of the prefab has been destroyed.
---@return boolean
function Elementable:IsDestroyed()
    return table.isdestroyed(self:GetRootElement())
end

---Index function will defer to Element **methods**.
function Elementable.__index(_, key)
    local elementTable = Generic._Element
    if type(elementTable[key]) == "function" then -- Only return functions.
        return function(elementable, ...)
            elementable = elementable ---@type GenericUI_I_Elementable
            -- Call the Element method on the root element
            return elementTable[key](elementable:GetRootElement(), ...)
        end
    end
end
