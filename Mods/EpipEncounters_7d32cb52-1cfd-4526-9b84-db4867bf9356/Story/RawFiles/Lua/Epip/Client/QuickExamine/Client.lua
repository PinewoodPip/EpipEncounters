
local Generic = Client.UI.Generic

---@class Feature_QuickExamine : Feature
local QuickExamine = {
    entityNetID = nil,
    lockCharacter = false,

    _Widgets = {}, ---@type Feature_QuickExamine_Widget[]

    UI = nil, ---@type Feature_QuickExamine_UI
    WIDTH = 400,
    SCROLLBAR_WIDTH = 10,
    ContentContainer = nil, ---@type GenericUI_Element_VerticalList
    CharacterNameElement = nil, ---@type GenericUI_Element_Text
    DIVIDER_WIDTH = 350,
    ALPHA = 0.8,
    HEIGHT = 600,

    SAVE_FILENAME = "EpipEncounters_QuickExamine.json",
    SAVE_VERSION = 1,
    INPUT_DEVICE = "KeyboardMouse",

    Events = {
        EntityChanged = {}, ---@type QuickExamine_Event_EntityChanged
    },
}
Epip.RegisterFeature("QuickExamine", QuickExamine)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Feature_QuickExamine_Entity EclCharacter|EclItem

---@class Feature_QuickExamine_UI : GenericUI_Instance

---@class Feature_QuickExamine_Widget
---@field Name string
local _Widget = {
    
}

---@param entity Feature_QuickExamine_Entity
---@return GenericUI_Element
---@diagnostic disable
function _Widget:Render(entity)
    QuickExamine:Error("Widget:Construct", "Not implemented for ", self.Name)
end

---@param entity Feature_QuickExamine_Entity
---@return boolean
function _Widget:CanRender(entity)
    return true
end
---@diagnostic enable

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class QuickExamine_Event_EntityChanged : Event
---@field RegisterListener fun(self, listener:fun(entity:Entity))
---@field Fire fun(self, entity:Entity)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param name string
---@return Feature_QuickExamine_Widget
function QuickExamine.RegisterWidget(name)
    ---@type Feature_QuickExamine_Widget
    local widget = {
        Name = name,
    }
    Inherit(widget, _Widget)

    table.insert(QuickExamine._Widgets, widget)

    return widget
end

---@return GenericUI_Element_VerticalList
function QuickExamine.GetContainer()
    return QuickExamine.ContentContainer
end

function QuickExamine.GetContainerWidth()
    return QuickExamine.GetContainer():GetMovieClip().width - 60
end

---@param path Path?
function QuickExamine.LoadData(path)
    path = path or QuickExamine.SAVE_FILENAME
    local save = IO.LoadFile(path)

    if save then
        QuickExamine.lockCharacter = save.Lock
    end
end

---@param path Path?
function QuickExamine.SaveData(path)
    path = path or QuickExamine.SAVE_FILENAME

    IO.SaveFile(path, {
        Version = QuickExamine.SAVE_VERSION,
        Lock = QuickExamine.lockCharacter,
    })
end

---@return boolean
function QuickExamine.IsLocked()
    return QuickExamine.lockCharacter
end

---@param entity Entity
function QuickExamine.SetEntity(entity)
    if entity then
        if entity.NetID ~= QuickExamine.entityNetID then
            QuickExamine.entityNetID = entity.NetID

            QuickExamine.GetContainer():Clear()

            -- Filler to compensate for the top div having a short height for the culling effect.
            QuickExamine.GetContainer():AddChild("Filler", "GenericUI_Element_Empty"):GetMovieClip().heightOverride = 10

            QuickExamine.CharacterNameElement:SetText(Text.Format(entity.DisplayName, {
                Color = "ffffff",
                Size = 21,
            }))
            QuickExamine.CharacterNameElement:SetSize(QuickExamine.WIDTH, 50)

            QuickExamine.Events.EntityChanged:Fire(entity)

            QuickExamine.UI.Container:RepositionElements()

            QuickExamine.UI:GetUI():Show()
        end
    else
        QuickExamine.entityNetID = nil

        QuickExamine.UI:GetUI():Hide()
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function(action, _)
    if action == "EpipEncounters_QuickExamine" then
        local char = Pointer.GetCurrentCharacter(nil, true)

        QuickExamine.SetEntity(char)
    end
end)

Client.UI.EnemyHealthBar:RegisterListener("updated", function(char, _)
    if char and QuickExamine.UI:IsVisible() and not QuickExamine.IsLocked() then
        QuickExamine.SetEntity(char) -- TODO support items
    end
end)

-- Render widgets whenever the entity changes.
QuickExamine.Events.EntityChanged:RegisterListener(function (entity)
    for _,widget in ipairs(QuickExamine._Widgets) do
        if widget:CanRender(entity) then
            widget:Render(entity)
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local function Setup()
    ---@class Feature_QuickExamine_UI
    local ui = QuickExamine.UI
    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {QuickExamine.WIDTH + QuickExamine.SCROLLBAR_WIDTH, QuickExamine.HEIGHT}
    uiObject.Left = QuickExamine.WIDTH - 2

    QuickExamine.LoadData()

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "right")

    -- Push the UI down a bit from the center, so it's below the minimap at 1080p
    local x, y = ui:GetPosition()
    uiObject:SetPosition(x, y + 100)

    -- Build elements
    local panel = ui:CreateElement("Panel", "GenericUI_Element_TiledBackground")
    panel:SetSize(QuickExamine.WIDTH, QuickExamine.HEIGHT)
    panel:SetAlpha(QuickExamine.ALPHA)

    local container = panel:AddChild("Container", "GenericUI_Element_VerticalList")
    container:SetSize(QuickExamine.WIDTH, -1)
    container:SetCenterInLists(true)
    ui.Container = container

    local list = container:AddChild("List", "GenericUI_Element_VerticalList")
    list:SetSize(QuickExamine.WIDTH, -1)
    list:SetSideSpacing(-20)

    local header = list:AddChild("Header", "GenericUI_Element_Text")
    header:SetText(Text.Format("Quick Examine", {
        Color = "ffffff",
        Size = 15,
    }))
    header:SetSize(QuickExamine.WIDTH, 20)

    local charName = list:AddChild("CharName", "GenericUI_Element_Text")
    charName:SetText(Text.Format("Character Name", {
        Color = "ffffff",
        Size = 21,
    }))
    charName:SetSize(QuickExamine.WIDTH, 30)
    QuickExamine.CharacterNameElement = charName

    local div = list:AddChild("MainDiv", "GenericUI_Element_Divider")
    div:SetSize(QuickExamine.DIVIDER_WIDTH)
    div:SetCenterInLists(true)
    div:GetMovieClip().heightOverride = div:GetMovieClip().height / 2

    -- Draggable area
    local dragArea = panel:AddChild("DragArea", "GenericUI_Element_TiledBackground")
    dragArea:SetBackground("Black", QuickExamine.WIDTH, 75)
    dragArea:SetAlpha(0.2)
    dragArea:SetAsDraggableArea()

    local content = list:AddChild("Content", "GenericUI_Element_ScrollList")
    content:SetMouseWheelEnabled(true)
    content:SetFrame(QuickExamine.WIDTH - 30, 510)
    content:SetScrollbarSpacing(20)
    content:SetSideSpacing(26)
    QuickExamine.ContentContainer = content
    
    local closeButton = panel:AddChild("Close", "GenericUI_Element_Button")
    closeButton:SetType("Close")
    closeButton:SetPosition(QuickExamine.WIDTH - closeButton:GetMovieClip().width, 0)
    closeButton.Events.Pressed:Subscribe(function (_)
        ui:GetUI():Hide()
    end)

    local lockButton = panel:AddChild("Lock", "GenericUI_Element_StateButton")
    lockButton:SetType(Generic.ELEMENTS.StateButton.TYPES.LOCK)
    lockButton:SetActive(QuickExamine.IsLocked())
    lockButton:SetPosition(400 - 23 - 25, 2)
    lockButton.Events.StateChanged:Subscribe(function (ev)
        QuickExamine.lockCharacter = ev.Active
        QuickExamine.SaveData()
    end)
    lockButton.Tooltip = "Lock Character"

    uiObject.Layer = Client.UI.PlayerInfo:GetUI().Layer

    uiObject:Hide()
end

function QuickExamine:__Setup()
    local startupDelay = 0.1 -- Required for setPosition to work.
    QuickExamine.UI = Generic.Create("PIP_QuickExamine")

    Timer.Start(startupDelay, function()
        Setup()
    end)
end