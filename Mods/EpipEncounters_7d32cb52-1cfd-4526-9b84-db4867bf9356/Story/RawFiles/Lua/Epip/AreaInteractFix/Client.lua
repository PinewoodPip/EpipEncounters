
---------------------------------------------
-- Fixes interacting with items from the AreaInteract UI
-- directly (not via context menu) not working when custom UIs exist.
---------------------------------------------

local AreaInteract = Client.UI.Controller.AreaInteract
local ContainerInventory = Client.UI.ContainerInventory

---@type Feature
local Fix = {}
Epip.RegisterFeature("Features.AreaInteractFix", Fix)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Adjust the layer of the UI to fix the issue.
-- This technically only needs to be done once at runtime.
-- Presumably the issue comes from custom UIs defaulting to layers above the UI's default of 10.
GameState.Events.GameReady:Subscribe(function (_)
    local areaInteractUIObj = AreaInteract:GetUI()
    local inventoryUIObj = ContainerInventory:GetUI()
    local contextMenuUIObj = Ext.UI.GetByType(Ext.UI.TypeID.contextMenu_c.Object)
    areaInteractUIObj.Layer = 16 -- 1 layer higher than the default for custom UIs, which appears to be what triggers this issue.
    -- Make sure the inventory and context menu UIs go on top,
    -- as they stay open alongside AreaInteract.
    if inventoryUIObj.Layer < areaInteractUIObj.Layer then
        inventoryUIObj.Layer = areaInteractUIObj.Layer + 1
    end
    if contextMenuUIObj.Layer < inventoryUIObj.Layer then
        contextMenuUIObj.Layer = inventoryUIObj.Layer + 1
    end
end, {EnabledFunctor = Client.IsUsingController})

-- Adjust layer of UIs intended to go above the container inventory
Ext.Events.UIObjectCreated:Subscribe(function (ev)
    if ev.UI:GetTypeId() == Ext.UI.TypeID.book then
        ev.UI.Layer = ContainerInventory:GetUI().Layer + 1
    end
end)
Ext.Events.UIObjectCreated:Subscribe(function (ev)
    if ev.UI:GetTypeId() == Ext.UI.TypeID.sortBy_c then
        ev.UI.Layer = ContainerInventory:GetUI().Layer + 1
    end
end)