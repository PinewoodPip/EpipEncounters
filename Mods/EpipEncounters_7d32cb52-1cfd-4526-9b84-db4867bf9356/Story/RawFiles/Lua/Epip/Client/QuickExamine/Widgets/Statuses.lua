
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local StatusPrefab = Generic.GetPrefab("GenericUI_Prefab_Status")

---@class Feature_QuickExamine_Widget_Statuses : Feature
local Statuses = {}
Epip.RegisterFeature("QuickExamine_Widget_Statuses", Statuses)

---------------------------------------------
-- WIDGET
---------------------------------------------

local Widget = QuickExamine.RegisterWidget("Statuses", {
    Setting = {
        ID = "Widget_Statuses",
        Type = "Boolean",
        Name = "Show Statuses",
        Description = "Shows the active, visible statuses of characters.",
        DefaultValue = true,
    },
})

function Widget:CanRender(entity)
    return Statuses:IsEnabled() and Entity.IsCharacter(entity)
end

function Widget:Render(entity)
    local char = entity ---@type EclCharacter
    local container = QuickExamine.GetContainer()

    local grid = container:AddChild("Statuses_Grid", "GenericUI_Element_Grid")
    grid:SetGridSize(QuickExamine.GetContainerWidth() // StatusPrefab.SIZE[1] - 1, -1)
    grid:SetCenterInLists(true)

    local statuses = char:GetStatusObjects() ---@type EclStatus[]
    for i,status in ipairs(statuses) do
        if Stats.IsStatusVisible(status) then
            local _ = StatusPrefab.Create(QuickExamine.UI, status.StatusId .. "_" .. tostring(i), grid, char, status)
        end
    end
    grid:RepositionElements()
end