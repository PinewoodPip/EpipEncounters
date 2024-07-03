
local Generic = Client.UI.Generic

---Container wrapper that implements its own pooling system, supporting Prefabs as items (children).
---Items need not be homogenous.
---@class GenericUI.Prefabs.PooledContainer : GenericUI_Prefab, GenericUI_I_Elementable
---@field Container GenericUI.Container
---@field _NewItemFunctor GenericUI.Prefabs.PooledContainer.NewItemFunctor
---@field _Items GenericUI_I_Elementable[]
---@field _CurrentItemsAmount integer
local Container = {}
Generic:RegisterClass("GenericUI.Prefabs.PooledContainer", Container, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.PooledContainer", Container)

-- TODO make a proper interface
---@alias GenericUI.Container GenericUI_Element_VerticalList|GenericUI_Element_HorizontalList|GenericUI_Element_Grid|GenericUI_Element_ScrollList

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.PooledContainer"

---@alias GenericUI.Prefabs.PooledContainer.NewItemFunctor fun(index:integer):GenericUI_I_Elementable

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a PooledContainer for an existing container element.
---@param container GenericUI.Container
---@param newItemFunctor GenericUI.Prefabs.PooledContainer.NewItemFunctor Elements created are expected to be children of the container.
---@return GenericUI.Prefabs.PooledContainer
function Container.Create(container, newItemFunctor)
    local instance = Container:__Create() ---@cast instance GenericUI.Prefabs.PooledContainer
    instance.Container = container
    instance._Items = {}
    instance._CurrentItemsAmount = 0
    instance._NewItemFunctor = newItemFunctor
    return instance
end

---Returns an item by index.
---A new item will be created if necessary.
---@param index integer Must be <= (Current items + 1)
---@return GenericUI_I_Elementable
function Container:GetItem(index)
    local item = self._Items[index]
    if not item then
        if index > (self._CurrentItemsAmount + 1) then
            Container:__Error("GetItem", "Requesting items out of order; current amount is", self._CurrentItemsAmount, ", requesting item at index", index)
        end
        item = self:__CreateItem()
        self:_RegisterItem(item)
    end
    self._CurrentItemsAmount = index -- Safe due to the order check above.
    item:SetVisible(true)
    return item
end

---Repositions items of the container and hides unused items.
function Container:RepositionElements()
    for i=self._CurrentItemsAmount+1,#self._Items,1 do -- Hide unused items
        local item = self._Items[i]
        if item:IsVisible() then
            item:SetVisible(false)
        else -- Exit after finding the first invisible element; performance gain is very, very minimal.
            break
        end
    end
    self.Container:RepositionElements()
end

---Sets all used items as invisible and resets the counter of used items.
function Container:Clear()
    for i=1,self._CurrentItemsAmount,1 do
        local item = self._Items[i]
        item:SetVisible(false)
    end
    self._CurrentItemsAmount = 0
end

---Creates a new item via the functor and registers it as a child item.
---@see GenericUI.Prefabs.PooledContainer._RegisterItem
---@return GenericUI_I_Elementable
function Container:__CreateItem()
    local item = self._NewItemFunctor(#self._Items + 1)
    self:_RegisterItem(item)
    return item
end

---Tracks an item as a child of the container.
---This is separate from the usual Element children tracking,
---as it supports tracking prefab instances as well.
---@param item GenericUI_I_Elementable
function Container:_RegisterItem(item)
    table.insert(self._Items, item)
end

---@override
function Container:GetRootElement()
    return self.Container
end
