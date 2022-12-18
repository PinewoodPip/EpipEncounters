
local OptionsInput = Client.UI.OptionsInput
local Vanity = Client.UI.Vanity

---@class Feature_Housing : Feature
local Housing = Epip.Features.Housing

Housing.selectedFurniture = nil ---@type Feature_Housing_SelectedFurniture
Housing.furnitureYAxisStep = 0.5
Housing.FURNITURE_ROTATION_STEP = 0.1

local _MovementTask = {}

function _MovementTask:Enter()
    print("entering...")
    if not self:HasValidTarget() then return false end
    
    local pointer = Ext.UI.GetPickingState(1)
        local handle = pointer.HoverItem or pointer.PlaceableEntity
        
        if handle then
            local obj = Ext.Entity.GetGameObject(handle)

            if obj then
                Housing.SelectFurniture(obj, handle)
                self.Running = true
                print("entered!")
                return true
            end
        end

    return false
end

function _MovementTask:SetCursor()
    local cc = Ext.UI.GetCursorControl()

    if self.Running then
        cc.MouseCursor = "CursorItemMove"

        cc.RequestedFlags = 0x30
        SetCursorText(Text.Format("Left-click to place.<br>Ctrl+Mouse Wheel to lower/raise", {
            Color = Color.LARIAN.GREEN,
        }))
    elseif self.Previewing then
        cc.MouseCursor = "CursorItemMove"
    else
        cc.MouseCursor = "CursorSystem"
    end
end

function _MovementTask:Update()
    print("updating")
    self:SetCursor()

    return self._RequestStop
end

function _MovementTask:CanEnter() -- Necessary for preview to be entered. Called when the priority is highest
    -- print("canenter")
    return self:HasValidTarget() and Client.Input.IsAltPressed()
end

function _MovementTask:CanExit()
    Ext.Print("CanExit")
    return not Client.Input.IsAltPressed()
end

function _MovementTask:CanExit2()
    Ext.Print("CanExit2")
    return not Client.Input.IsAltPressed()
end

function _MovementTask:ExitPreview()
    Ext.Print("ExitPreview")
    self.Previewing = false
end

function _MovementTask:Exit()
    self.Running = false
    Housing.PlaceMovingFurniture()
end

function _MovementTask:GetPriority(previousPriority)
    -- print(self)
    if previousPriority < 9999 and self:HasValidTarget() then
        -- print("high prio")
        return 9999
    end

    return 0
end

function _MovementTask:GetDescription()
    return "asdasd"
end

function _MovementTask:GetExecutePriority(previousPriority)
    return self:GetPriority(previousPriority)
end

function _MovementTask:Start() -- When left clicked
    print("start")
    self._RequestStop = false
end

function _MovementTask:Stop() -- When cancelled by right-click
    print("stop")
    self._RequestStop = false
    Housing.PlaceMovingFurniture()
end

function _MovementTask:HasValidTargetPos()
    return (Ext.UI.GetPickingHelper().WalkableAiFlags & 1) == 0
end

function _MovementTask:HasValidTarget()
    local pointer = Ext.UI.GetPickingState(1)
    local handle = pointer.HoverItem or pointer.PlaceableEntity
    
    if handle then
        local obj = Ext.Entity.GetGameObject(handle)

        if obj then
            return true
        end
    end

    return false
end

function _MovementTask:UpdatePreview()
    -- print("updating preview")
end

_MovementTask.GetError = function (self)
    if self.Running and not _MovementTask:HasValidTargetPos() then
       return 4
    else
       return 0
    end
 end

function _MovementTask:EnterPreview() -- Called when the task has high enough priority
    Ext.Print("EnterPreview")
    self.Previewing = true
end

function _MovementTask:HandleInputEvent(ev, state)
    local evDesc = Ext.Input.GetInputManager().InputDefinitions[ev.EventId]
    if evDesc.EventName == "Action1" and ev.OldValue.State == "Pressed" and Client.Input.IsAltPressed() and not _MovementTask.Running and self.Previewing and self:HasValidTarget() then
        state.RequestRun = true
        print(Text.Dump(state))
    elseif _MovementTask.Running and evDesc.EventName == "Action1" and ev.OldValue.State == "Pressed" then
        -- Housing.PlaceMovingFurniture()
        -- _MovementTask:Exit()
    end
end

---@class Feature_Housing_SelectedFurniture
---@field Handle EntityHandle
---@field EntityType "Item"|"Scenery"
---@field PositionOffset Vector3D
---@field OriginalPosition Vector3D
local _SelectedFurniture = {}

---@return EclItem|EclScenery
function _SelectedFurniture:GetEntity()
    return Ext.Entity.GetGameObject(self.Handle)
end

---@param pos Vector3D
---@param addOffset boolean? Defaults to true.
function _SelectedFurniture:SetPosition(pos, addOffset)
    pos = table.deepCopy(pos)
    local obj = self:GetEntity()
    
    if addOffset then
        for i,v in ipairs(pos) do
            pos[i] = v + self.PositionOffset[i]
        end
    end

    if self.EntityType == "Item" then
        obj.Translate = pos
    else
        -- Objects do not automatically snap to walkable grid, since many of them are walkable themselves and cause the object to infinitely rise.
        local y = self.OriginalPosition[2]

        pos[2] = y
        if addOffset then
            pos[2] = pos[2] + self.PositionOffset[2]
        end

        obj.Translate = pos
    end
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the furniture currently being moved.
---@return Feature_Housing_SelectedFurniture
function Housing.GetSelectedFurniture()
    local obj

    if Housing.selectedFurniture then
        obj = Housing.selectedFurniture
    end

    return obj
end

---@return boolean
function Housing.IsMovingFurniture()
    return Housing.selectedFurniture ~= nil
end

---Begins moving a furniture.
---@param obj EclItem|EclScenery
---@param handle? EntityHandle Necessary for scenery due to technical limitations.
function Housing.SelectFurniture(obj, handle)
    Housing:DebugLog("Moving furniture: ", obj)

    ---@type Feature_Housing_SelectedFurniture
    local selectedObj = {
        Handle = handle or obj.Handle,
        EntityType = "Scenery",
        PositionOffset = {0, 0, 0},
        OriginalPosition = obj.Translate,
    }
    Inherit(selectedObj, _SelectedFurniture)

    if GetExtType(obj) == "ecl::Item" then
        selectedObj.EntityType = "Item"
    end

    Housing.selectedFurniture = selectedObj

    GameState.Events.RunningTick:Subscribe(function (_)
        local pos = Ext.UI.GetPickingState(1).WalkablePosition
        -- local pos = Ext.UI.GetPickingState(1).PlaceablePosition

        if pos then
            Housing.selectedFurniture:SetPosition(pos, true)
        end
    end, {StringID = "Housing_MoveFurniture"})

    -- Cannot prevent mouse events unfortunately.
    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.EDIT_CHARACTER, true, "Housing")
    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.CONTEXT_MENU, true, "Housing")

    Client.UI.Input.SetMouseWheelBlocked(true)

    -- Ext.UI.RegisterCharacterTask(Client.GetCharacter(), _MovementTask)
    -- _MovementTask.RequestRun = true
end

function Housing.PlaceMovingFurniture()
    local obj = Housing.GetSelectedFurniture():GetEntity()

    -- Sync item positions to server
    if Housing.GetSelectedFurniture().EntityType == "Item" then
        Net.PostToServer("EPIPENCOUNTERS_Housing_PlaceMovingFurniture", {
            ObjNetID = obj.NetID,
            Position = obj.Translate,
        })
    end

    Housing.selectedFurniture = nil
    GameState.Events.RunningTick:Unsubscribe("Housing_MoveFurniture")

    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.EDIT_CHARACTER, false, "Housing")
    -- Client.UI.Input.ToggleEventCapture(Client.Input.FLASH_EVENTS.CONTEXT_MENU, false, "Housing")
    Client.UI.Input.SetMouseWheelBlocked(false)
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

-- Interacting with furniture.
OptionsInput.Events.ActionExecuted:RegisterListener(function (action, binding)
    if action == "EpipEncounters_Housing_MoveFurniture" then
        local pointer = Ext.UI.GetPickingState(1)
        local handle = pointer.HoverItem or pointer.PlaceableEntity
        -- local handle = pointer.HoverItem
        
        if Housing.IsMovingFurniture() then
            Housing.PlaceMovingFurniture()
        elseif handle then
            local obj = Ext.Entity.GetGameObject(handle)

            if obj then
                Housing.SelectFurniture(obj, handle)
            end
        end
    elseif Housing.IsMovingFurniture() then
        local obj = Housing.GetSelectedFurniture()
        local entity = obj:GetEntity()

        if action == "EpipEncounters_Housing_RaiseFurniture" or action == "EpipEncounters_Housing_LowerFurniture" then -- Raise/lower furniture.
            local offset = Housing.furnitureYAxisStep
            if action == "EpipEncounters_Housing_LowerFurniture" then
                offset = -offset
            end

            obj.PositionOffset = {obj.PositionOffset[1], obj.PositionOffset[2] + offset, obj.PositionOffset[3]}
        elseif action == "EpipEncounters_Housing_RotateFurniture_Plus" or action == "EpipEncounters_Housing_RotateFurniture_Minus" then
            -- TODO
            local rotation = entity.Rotation
            local offset = Housing.FURNITURE_ROTATION_STEP
            if action == "EpipEncounters_Housing_RotateFurniture_Minus" then
                offset = -offset
            end

            local angles = Ext.Math.ExtractEulerAngles(rotation)
            local rotationMatrix = Ext.Math.BuildRotation3({1, 0, 0}, 10)
            rotation = Ext.Math.BuildFromEulerAngles3(angles)
            
            entity.Rotation = Ext.Math.Rotate(rotation, 90, {1, 0, 0})

            -- _D(rotation)
        end
    end
end)

-- Place down moving furniture.
Client.Input.Events.MouseButtonPressed:Subscribe(function (e)
    if Housing.IsMovingFurniture() and (e.InputID == "left2" or e.InputID == "right2") then
        -- Housing.PlaceMovingFurniture()
        _MovementTask._RequestStop = true
    end
end)

-- userAction.HandleInputEvent = function (self, ev, state)
--     local evDesc = Ext.Input.GetInputManager().InputDefinitions[ev.EventId]
--     if evDesc.EventName == "Action1" and ev.OldValue.State == "Pressed" and ev.NewValue.State == "Released" then
--        if not self.Running and self.Previewing and self:HasValidTarget() then
--           Ext.Print("RequestRun")
--           state.RequestRun = true
--        end
       
--        if self.Running and self:HasValidTargetPos() then
--           Ext.PrintWarning("HIT!!!!!")
--           local pos = Ext.UI.GetPickingHelper().WalkablePos.Position
--           Ext.PrintWarning("Move " .. tostring(self.Target) .. " to " .. pos[1] .. "," .. pos[2] .. "," .. pos[3])
--        end
--     end
--  end

function ClearCursorText()
    local cc = Ext.UI.GetCursorControl()
    if cc.HasTextDisplay then
       local ui = Ext.UI.GetByHandle(cc.TextDisplayUIHandle)
       if ui.Text ~= "" then
          ui:GetRoot().removeText()
          ui.Text = ""
       end
       cc.HasTextDisplay = false
    end
end
 
function SetCursorText(text)
    local cc = Ext.UI.GetCursorControl()
    local ui = Ext.UI.GetByHandle(cc.TextDisplayUIHandle)
    local pos = Ext.UI.GetMouseFlashPos(ui)
    if ui.Text ~= text then
       ui:GetRoot().addText(text, pos[1], pos[2])
       ui.Text = text
    elseif (ui.WorldScreenPositionX ~= pos[1] or ui.WorldScreenPositionY ~= pos[2]) then
       ui:GetRoot().moveText(pos[1], pos[2])
    end
    cc.HasTextDisplay = true
 end
 
-- local userAction = {
--     Running = false,
--     Previewing = false,
--     Target = nil
-- }

-- userAction.HandleInputEvent = function (self, ev, state)
--    if evDesc.EventName == "Action1" and ev.OldValue.State == "Pressed" and ev.NewValue.State == "Released" then
--       if not self.Running and self.Previewing and self:HasValidTarget() then
--          Ext.Print("RequestRun")
--          state.RequestRun = true
--       end
      
--       if self.Running and self:HasValidTargetPos() then
--          Ext.PrintWarning("HIT!!!!!")
--          local pos = Ext.UI.GetPickingHelper().WalkablePos.Position
--          Ext.PrintWarning("Move " .. tostring(self.Target) .. " to " .. pos[1] .. "," .. pos[2] .. "," .. pos[3])
--       end
--    end
-- end

Ext.Events.SessionLoaded:Subscribe(function (e)
    Ext.UI.RegisterCharacterTask(Client.GetCharacter(), _MovementTask)
end)