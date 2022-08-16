
local Generic = Client.UI.Generic
local Spinner = Generic.GetPrefab("GenericUI_Prefab_Spinner")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local LabelledDropdown = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")

---@class Feature_StatsEditor
local StatsEditor = Epip.GetFeature("EpipEncounters", "StatsEditor")
StatsEditor.UI = nil ---@type GenericUI_Instance
StatsEditor.UI_SIZE = {1000, 1000}
StatsEditor.UI_CONTENT_SIZE = {800, 900}
StatsEditor.SupportedFields = {
    SkillData = {

    },
}
StatsEditor.Events.RenderProperty = StatsEditor:AddSubscribableEvent("RenderProperty") ---@type SubscribableEvent<Feature_StatsEditor_Event_RenderProperty>

StatsEditor:Debug()

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_StatsEditor_Event_RenderProperty
---@field StatID string
---@field StatType StatsObjectType
---@field PropertyName string
---@field PropertyType StatEntry_FieldType
---@field Container GenericUI_Element_VerticalList
---@field StatsObject unknown TODO type
---@field PropertyValue any

---------------------------------------------
-- METHODS
---------------------------------------------

---@param statType StatsObjectType
---@param statID string
function StatsEditor.Setup(statType, statID)
    local modifierList = Stats.ModifierLists[statType]
    local container = StatsEditor.UI.Container
    local stat = Stats.Get(statType, statID)

    if not modifierList then
        StatsEditor:LogError("Unsupported modifier list: " .. statType)
        return nil
    end

    container:Clear()

    for propertyName,propertyType in pairs(modifierList) do
        StatsEditor.Events.RenderProperty:Throw({
            StatID = statID,
            StatType = statType,
            PropertyName = propertyName,
            PropertyType = propertyType,
            Container = container,
            StatsObject = stat,
            PropertyValue = stat[propertyName],
        })
    end

    StatsEditor.UI.Header:SetText(Text.Format("%s (%s)", {
        FormatArgs = {
            statID,
            statType,
        },
        Size = 23,
        Color = Color.BLACK,
    }))

    StatsEditor.UI:Show()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---------------------------------------------
-- RENDERING FIELDS
---------------------------------------------

-- Render Integers.
StatsEditor.Events.RenderProperty:Subscribe(function (ev)
    if ev.PropertyType == "Integer" then
        local spinner = Spinner.Create(StatsEditor.UI, ev.PropertyName, ev.Container, ev.PropertyName, -math.maxinteger, math.maxinteger, 1) -- TODO step

        spinner:SetValue(ev.PropertyValue)
    end
end)

-- Render enums.
StatsEditor.Events.RenderProperty:Subscribe(function (ev)
    local enum = Stats.Enums[Stats.ModifierLists[ev.StatType][ev.PropertyName]]

    if enum then
        local options = {}

        for i=0,#enum,1 do
            table.insert(options, {ID = enum[i], Label = enum[i]})
        end

        local dropdown = LabelledDropdown.Create(StatsEditor.UI, ev.PropertyName, ev.Container, ev.PropertyName, options)
        dropdown:SelectOption(ev.PropertyValue)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function StatsEditor:__Setup()
    local ui = Generic.Create("PIP_StatsEditor")
    StatsEditor.UI = ui

    local bg = ui:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Note", table.unpack(StatsEditor.UI_SIZE))

    local frame = bg:AddChild("Content", "GenericUI_Element_Empty")
    frame:SetPositionRelativeToParent("TopLeft", 110, 100)

    local container = frame:AddChild("Container", "GenericUI_Element_VerticalList")
    container:SetSize(table.unpack(StatsEditor.UI_CONTENT_SIZE))
    container:SetPositionRelativeToParent("TopLeft", 0, 50) -- Position below label

    local header = TextPrefab.Create(ui, "Header", frame, "", 1, StatsEditor.UI_CONTENT_SIZE)
    header:GetMainElement():SetStroke(Color.CreateFromHex(Color.WHITE), 1, 0.5, 1, 2)
    header:GetMainElement():SetMouseEnabled(false)

    StatsEditor.UI.Header = header
    StatsEditor.UI.Container = container

    ui:GetUI().SysPanelSize = {StatsEditor.UI_SIZE[1], StatsEditor.UI_SIZE[2] + 150}
    ui:SetPosition("center", "center", nil, 2)

    ui:Hide()
end

function StatsEditor:__Test()
    -- StatsEditor.Setup("SkillData", "Projectile_Fireball")
end