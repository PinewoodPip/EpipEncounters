
local Generic = Client.UI.Generic

---Base class for container / list prefabs.
---@class GenericUI_I_Container : GenericUI_Prefab, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty
local Container = {}
Generic:RegisterClass("GenericUI_I_Container", Container, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI_I_Container", Container)

---------------------------------------------
-- METHODS
---------------------------------------------

---Called when a child element is added to the container.
---@abstract
---@param element GenericUI_Element
---@diagnostic disable-next-line: unused-local
function Container:OnElementAdded(element) end

---Positions the elements of the container.
---@abstract
function Container:PositionElements() end

---@override
function Container:GetRootElement()
    return self.Root
end

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@return GenericUI_I_Container
function Container:__CreateRoot(ui, id, parent)
    local instance = self:_Create(ui, id) ---@type GenericUI_I_Container

    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance.Root = root

    -- Listen for child elements being added.
    root.Events.ChildAdded:Subscribe(function (ev)
        instance:OnElementAdded(ev.Child)
    end)

    return instance
end

---Returns the list of children that can be positioned.
---@return GenericUI_Element[]
function Container:__GetPositionableChildren()
    return self:GetChildren() -- TODO consider visible?
end