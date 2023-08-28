
---@class Feature_Fishing
local Fishing = Epip.GetFeature("Feature_Fishing")

---@class Feature_Fishing_CharacterTask : UserspaceCharacterTaskCallbacks
local _Task = {
    _Previewing = false,
    CharacterHandle = nil, ---@type ComponentHandle

    ID = "Epip_Feature_Fishing",
    WATER_SEARCH_RADIUS = 0.3,
}
Fishing._CharacterTaskClass = _Task

---@param char EclCharacter
---@return Feature_Fishing_CharacterTask
function _Task.Create(char)
    local tbl = {CharacterHandle = char and char.Handle}
    Inherit(tbl, _Task)

    return tbl
end

function _Task:GetCharacter()
    return Client.GetCharacter() -- TODO
end

function _Task:Enter()
    return false
end

function _Task:Attached() end

-- Called once per tick while the task has priority.
function _Task:SetCursor()
    local cc = Ext.UI.GetCursorControl()

    if self._Previewing then
        cc.MouseCursor = "CursorWand_Ground"

        Client.Tooltip.ShowMouseTextTooltip(Fishing.TSK["CharacterTask_MouseTextTooltip"], Vector.Create(30, 20))
    end
end

function _Task:Update()
    self:SetCursor()

    return false
end

-- Necessary for preview to be entered. Called when the priority is highest.
function _Task:CanEnter()
    return self:HasValidTargetPos()
end

function _Task:CanExit()
    return true
end

function _Task:CanExit2()
    return true
end

-- Called when the task loses top priority or is cancelled.
function _Task:ExitPreview()
    self._Previewing = false

    Client.Tooltip.HideMouseTextTooltip()
end

function _Task:Exit() end

function _Task:MeetsRequirements()
    local char = self:GetCharacter()

    return self:HasValidTargetPos() and Fishing.HasFishingRodEquipped(char) and Character.IsUnsheathed(char) and Fishing.IsNearWater(char)
end

function _Task:GetPriority(previousPriority)
    if previousPriority < 9999 and self:MeetsRequirements() then
        return 9999
    end

    return -99
end

function _Task:GetDescription()
    return "Fish! For fish."
end

function _Task:GetExecutePriority(_)
    return 0
end

-- Called when left click is pressed, even if the task does not have top priority.
function _Task:Start()
    if self:MeetsRequirements() then
        Fishing.Start(self:GetCharacter())
    end
end

-- Called when right-click is pressed.
function _Task:Stop() end

function _Task:HasValidTargetPos() -- TODO make it require looking at the water
    local char = Character.Get(self.CharacterHandle)
    local region = Fishing.GetRegionAt(char.WorldPos)
    local isCursorByWater = Fishing.IsPositionNearWater(Pointer.GetWalkablePosition(), self.WATER_SEARCH_RADIUS)

    return region and (isCursorByWater or not region.RequiresWater)
end

function _Task:HasValidTarget()
    return false
end

function _Task:UpdatePreview() end

_Task.GetError = function (self)
    if not self:HasValidTargetPos() then
       return 4
    else
       return 0
    end
 end

function _Task:EnterPreview() -- Called when the task has high enough priority
    self._Previewing = true
end

function _Task:HandleInputEvent(ev, _)
    local evDesc = Ext.Input.GetInputManager().InputDefinitions[ev.EventId]

    -- Start fishing when Action1 is pressed.
    if evDesc.EventName == "Action1" and ev.OldValue.State == "Pressed" and Client.Input.IsAltPressed() and self._Previewing and self:HasValidTargetPos() then
        Fishing.Start(self:GetCharacter())
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Attach the task to active characters.
local attached = DataStructures.Get("DataStructures_Set").Create()
Client.Events.ActiveCharacterChanged:Subscribe(function (ev)
    local char = ev.NewCharacter
    if not attached:Contains(char.Handle) then
        Ext.Behavior.AttachCharacterTask(char, _Task.ID)
        attached:Add(char.Handle)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Behavior.RegisterCharacterTask(_Task.ID, _Task.Create)