
local OptionsInput = Client.UI.OptionsInput
local Vanity = Client.UI.Vanity

---@class Feature_Housing : Feature
local Housing = Epip.Features.Housing

Housing.movingFurnitureHandle = nil ---@type EntityHandle

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the furniture currently being moved.
---@return EclItem
function Housing.GetMovingFurniture()
    local obj

    if Housing.movingFurnitureHandle then
        obj = Item.Get(Housing.movingFurnitureHandle)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return obj
end

---@return boolean
function Housing.IsMovingFurniture()
    return Housing.movingFurnitureHandle ~= nil
end

---Begins moving a furniture.
---@param obj EclItem
function Housing.StartMovingFurniture(obj)
    Housing:DebugLog("Moving furniture: ", obj.DisplayName)

    Housing.movingFurnitureHandle = obj.Handle

    GameState.Events.RunningTick:Subscribe(function (_)
        local pos = Ext.UI.GetPickingState(1).WalkablePosition
        -- local pos = Ext.UI.GetPickingState(1).PlaceablePosition

        if pos then
            local item = Housing.GetMovingFurniture()

            item.Translate = pos
        end
    end, {StringID = "Housing_MoveFurniture"})

    -- Cannot prevent mouse events unfortunately.
    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.EDIT_CHARACTER, true, "Housing")
    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.CONTEXT_MENU, true, "Housing")
end

function Housing.PlaceMovingFurniture()
    local obj = Housing.GetMovingFurniture()

    Net.PostToServer("EPIPENCOUNTERS_Housing_PlaceMovingFurniture", {
        ObjNetID = obj.NetID,
        Position = obj.Translate,
    })

    Housing.movingFurnitureHandle = nil
    GameState.Events.RunningTick:Unsubscribe("Housing_MoveFurniture")

    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.EDIT_CHARACTER, false, "Housing")
    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.CONTEXT_MENU, false, "Housing")
end

---@param furniture GUID|Feature_Housing_Furniture
---@param position Vector3D
function Housing.SpawnFurniture(furniture, position)
    if type(furniture) == "string" then furniture = Housing.GetFurniture(furniture) end

    Net.PostToServer("EPIPENCOUNTERS_Housing_SpawnFurniture", {
        Position = position,
        FurnitureGUID = furniture.TemplateGUID,
    })
end

---------------------------------------------
-- VANITY TAB
---------------------------------------------

local Tab = Vanity.CreateTab({
    Name = "Furniture",
    ID = "PIP_Furniture",
    Icon = Client.UI.Hotbar.ACTION_ICONS.BAG,
})

function Tab:Render()
    Vanity.RenderText("Header", "Spawn furniture out of thin air!")

    local furniture = Housing.GetFurnitureTable()
    local categories = {}
    for objType,furnitures in pairs(furniture) do
        local newTable = {
            Type = Housing.GetfurnitureTypeName(objType),
            Furnitures = {},
        }
        table.insert(categories, newTable)

        for _,data in pairs(furnitures) do
            table.insert(newTable.Furnitures, data)
        end

        table.sort(newTable.Furnitures, function (a, b)
            return a.Name < b.Name
        end)
    end
    table.sort(categories, function (a, b)
        return a.Type < b.Type
    end)

    for _,category in ipairs(categories) do
        local isOpen = Vanity.IsCategoryOpen(category.Type)
        Vanity.RenderEntry(category.Type, category.Type, true, isOpen, false, false)

        if isOpen then
            for _,data in ipairs(category.Furnitures) do
                Vanity.RenderEntry(data.TemplateGUID, data.Name, false, false, false, false)
            end
        end
    end
end

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Housing.SpawnFurniture(id, Client.GetCharacter().Translate)
end)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Moving furniture.
OptionsInput.Events.ActionExecuted:RegisterListener(function (action, binding)
    if action == "EpipEncounters_Housing_MoveFurniture" then
        local pointer = Ext.UI.GetPickingState(1)
        local handle = pointer.HoverItem -- PlaceableEntity not supported.
        
        if handle then
            local obj = Item.Get(handle)

            if obj then
                Housing.StartMovingFurniture(obj)
            end
        end
    end
end)

-- Place down moving furniture.
Client.Input.Events.MouseButtonPressed:Subscribe(function (e)
    if Housing.IsMovingFurniture() and (e.InputID == "left2" or e.InputID == "right2") then
        Housing.PlaceMovingFurniture()
    end
end)