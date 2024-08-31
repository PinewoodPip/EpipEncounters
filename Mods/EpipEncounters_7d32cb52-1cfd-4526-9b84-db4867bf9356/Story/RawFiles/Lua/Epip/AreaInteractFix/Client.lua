
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
    local uiObj = AreaInteract:GetUI()
    local inventoryUIObj = ContainerInventory:GetUI()
    uiObj.Layer = 16
    -- Make sure the inventory UI goes on top, as it stays open
    -- alongside AreaInteract.
    if inventoryUIObj.Layer < 16 then
        inventoryUIObj.Layer = 17
    end
end, {EnabledFunctor = Client.IsUsingController})