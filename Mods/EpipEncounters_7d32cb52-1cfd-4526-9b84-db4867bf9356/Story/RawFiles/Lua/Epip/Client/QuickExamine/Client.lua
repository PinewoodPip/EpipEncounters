
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class Feature_QuickExamine : Feature
local QuickExamine = {
    entityNetID = nil,
    lockCharacter = false,

    _Widgets = {}, ---@type Feature_QuickExamine_Widget[]

    UI = nil, ---@type Feature_QuickExamine_UI
    WIDTH = 400,
    CONTAINER_PADDING = 5,
    SCROLLBAR_WIDTH = 18,
    ContentContainer = nil, ---@type GenericUI_Element_VerticalList
    CharacterNameElement = nil, ---@type GenericUI_Element_Text
    ALPHA = 0.8,
    HEIGHT = 600,

    SAVE_FILENAME = "EpipEncounters_QuickExamine.json",
    SAVE_VERSION = 1,
    INPUT_DEVICE = "KeyboardMouse",

    Settings = {
        AllowDead = {
            ID = "AllowDead",
            Type = "Boolean",
            Name = "Enable Corpses",
            Description = "Allows examining dead characters.",
            DefaultValue = false,
        },
    },

    USE_LEGACY_HOOKS = false,

    Events = {
        EntityChanged = {}, ---@type QuickExamine_Event_EntityChanged
    },
    Hooks = {
        IsEligible = {}, ---@type Event<Feature_QuickExamine_Hook_IsEligible>
    }
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
    Setting = nil, ---@type SettingsLib_Setting_Boolean If defined, the widget will not render if the setting is not enabled.
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

---@param id string
---@param parentElement string|GenericUI_Element
---@param label string
---@return GenericUI_Prefab_Text
function _Widget:CreateHeader(id, parentElement, label)
    return TextPrefab.Create(QuickExamine.UI, id, parentElement, label, "Center", Vector.Create(QuickExamine.GetContainerWidth(), 30))
end

---@param id string
---@param parentElement string|GenericUI_Element
---@return GenericUI_Element_Divider
function _Widget:CreateDivider(id, parentElement)
    if type(parentElement) == "string" then
        parentElement = QuickExamine.UI:GetElementByID(parentElement)
    end
    local div = parentElement:AddChild(id, "GenericUI_Element_Divider")
    div:SetSize(QuickExamine.GetContainerWidth())

    return div
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class QuickExamine_Event_EntityChanged : Event
---@field RegisterListener fun(self, listener:fun(entity:Entity))
---@field Fire fun(self, entity:Entity)

---@class Feature_QuickExamine_Hook_IsEligible
---@field Entity Entity
---@field Eligible boolean Hookable. Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param name string
---@param data Feature_QuickExamine_Widget?
---@return Feature_QuickExamine_Widget
function QuickExamine.RegisterWidget(name, data)
    ---@type Feature_QuickExamine_Widget
    local widget = data or {}
    widget.Name = name
    Inherit(widget, _Widget)

    table.insert(QuickExamine._Widgets, widget)

    local setting = widget.Setting
    if setting then
        setting.ModTable = setting.ModTable or QuickExamine:GetSettingsModuleID()
        setting.ID = setting.ID or ("Widget_" .. name)
        Settings.RegisterSetting(widget.Setting)
    end

    return widget
end

---@param widget Feature_QuickExamine_Widget
---@param entity Entity
---@return boolean
function QuickExamine.CanRenderWidget(widget, entity)
    local isEnabled = true

    if widget.Setting then
        isEnabled = Settings.GetSettingValue(widget.Setting)
    end

    return isEnabled and widget:CanRender(entity)
end

---@return GenericUI_Element_VerticalList
function QuickExamine.GetContainer()
    return QuickExamine.ContentContainer
end

function QuickExamine.GetContainerWidth()
    return QuickExamine.WIDTH - QuickExamine.CONTAINER_PADDING * 2 - QuickExamine.SCROLLBAR_WIDTH
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
---@return boolean
function QuickExamine.IsEligible(entity)
    local hook = QuickExamine.Hooks.IsEligible:Throw({
        Entity = entity,
        Eligible = true,
    })

    return hook.Eligible
end

---@param entity Entity
function QuickExamine.SetEntity(entity)
    if entity and QuickExamine.IsEligible(entity) then
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
    elseif not entity then -- Only hide the UI is entity passed is nil.
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

-- Disallow dead characters if the setting is disabled.
QuickExamine.Hooks.IsEligible:Subscribe(function (ev)
    if Entity.IsCharacter(ev.Entity) then
        local char = ev.Entity

        if QuickExamine:GetSettingValue(QuickExamine.Settings.AllowDead) == false and Character.IsDead(char) then
            ev.Eligible = false
        end
    end
end)

-- Render widgets whenever the entity changes.
QuickExamine.Events.EntityChanged:RegisterListener(function (entity)
    for _,widget in ipairs(QuickExamine._Widgets) do
        if QuickExamine.CanRenderWidget(widget, entity) then
            local success, msg = pcall(widget.Render, widget, entity)
            
            if not success then
                QuickExamine:LogError("Error while rendering widget: " .. msg)
            end
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
    div:SetSize(QuickExamine.GetContainerWidth())
    div:SetCenterInLists(true)
    div:GetMovieClip().heightOverride = div:GetMovieClip().height / 2

    -- Draggable area
    local dragArea = panel:AddChild("DragArea", "GenericUI_Element_TiledBackground")
    dragArea:SetBackground("Black", QuickExamine.WIDTH, 75)
    dragArea:SetAlpha(0.2)
    dragArea:SetAsDraggableArea()

    local content = list:AddChild("Content", "GenericUI_Element_ScrollList")
    content:SetMouseWheelEnabled(true)
    content:SetFrame(QuickExamine.GetContainerWidth(), 510)
    content:Move(QuickExamine.CONTAINER_PADDING, 0)
    content:SetScrollbarSpacing(-QuickExamine.CONTAINER_PADDING * 2)
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