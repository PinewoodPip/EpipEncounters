
local Generic = Client.UI.Generic
local Spinner = Generic.GetPrefab("GenericUI_Prefab_Spinner")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local LabelledDropdown = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")
local LabelledCheckbox = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")
local LabelledTextField = Generic.GetPrefab("GenericUI_Prefab_LabelledTextField")

---@class Feature_StatsEditor
local StatsEditor = Epip.GetFeature("EpipEncounters", "StatsEditor")
StatsEditor.UI = nil ---@type GenericUI_Instance
StatsEditor.UI_SIZE = {1000, 1000}
StatsEditor.UI_CONTENT_SIZE = {800, 750}
StatsEditor.FORM_ELEMENT_WIDTH = 800
StatsEditor.FORM_ELEMENT_HEIGHT = 50
StatsEditor.SupportedFields = { -- TODO
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

-- Render Integers and Qualifiers.
StatsEditor.Events.RenderProperty:Subscribe(function (ev)
    if ev.PropertyType == "Integer" or ev.PropertyType == "Qualifier" then
        local spinner = Spinner.Create(StatsEditor.UI, ev.PropertyName, ev.Container, ev.PropertyName, -math.maxinteger, math.maxinteger, 1) -- TODO step
        local value

        if ev.PropertyValue == "None" then
            value = -1
        else
            value = tonumber(ev.PropertyValue)
        end

        spinner:SetValue(value)
        spinner:SetSize(StatsEditor.FORM_ELEMENT_WIDTH, StatsEditor.FORM_ELEMENT_HEIGHT)

        if ev.PropertyType == "Qualifier" then
            spinner:SetBounds(-1, 10, 1)
        end
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
        dropdown:SetSize(StatsEditor.FORM_ELEMENT_WIDTH, StatsEditor.FORM_ELEMENT_HEIGHT)
    end
end)

-- Render Yes/No properties.
StatsEditor.Events.RenderProperty:Subscribe(function (ev)
    if ev.PropertyType == "YesNo" then
        local checkbox = LabelledCheckbox.Create(StatsEditor.UI, ev.PropertyName, ev.Container, ev.PropertyName)

        checkbox:SetState(ev.PropertyValue == "Yes")

        checkbox:SetSize(StatsEditor.FORM_ELEMENT_WIDTH, StatsEditor.FORM_ELEMENT_HEIGHT)
    end
end)

-- Render text fields.
StatsEditor.Events.RenderProperty:Subscribe(function (ev)
    if ev.PropertyType == "String" then
        local text = LabelledTextField.Create(StatsEditor.UI, ev.PropertyName, ev.Container, ev.PropertyName)

        text:SetText(ev.PropertyValue)

        text:SetSize(StatsEditor.FORM_ELEMENT_WIDTH, StatsEditor.FORM_ELEMENT_HEIGHT)
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

    local container = frame:AddChild("Container", "GenericUI_Element_ScrollList")
    container:SetSize(table.unpack(StatsEditor.UI_CONTENT_SIZE))
    container:SetPositionRelativeToParent("TopLeft", 0, 50) -- Position below label
    container:SetMouseWheenEnabled(true)

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
    StatsEditor.Setup("SkillData", "Projectile_Fireball")
end