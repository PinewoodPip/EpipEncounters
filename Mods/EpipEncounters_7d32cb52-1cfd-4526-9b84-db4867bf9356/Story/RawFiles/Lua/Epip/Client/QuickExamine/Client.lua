
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_QuickExamine : Feature
local QuickExamine = {
    entityNetID = nil,
    lockCharacter = false,

    _Widgets = {}, ---@type Feature_QuickExamine_Widget[]

    UI = nil, ---@type Feature_QuickExamine_UI
    CONTAINER_PADDING = 5,
    SCROLLBAR_WIDTH = 18,
    ContentContainer = nil, ---@type GenericUI_Element_VerticalList
    CharacterNameElement = nil, ---@type GenericUI_Element_Text

    SAVE_FILENAME = "EpipEncounters_QuickExamine.json",
    SAVE_VERSION = 1,
    INPUT_DEVICE = "KeyboardMouse",
    GRAPHICAL_SETTINGS = Set.Create({
        "Opacity",
        "Width",
        "Height",
    }),

    TranslatedStrings = {
        Name = {
           Handle = "h939f9996g8c0fg46dbg8d51g5816929f1387",
           Text = "Quick Examine",
           ContextDescription = "Name of the feature",
        },
        SavePosition = {
           Handle = "h6cc76e3fg8d5cg466egb96agb780b490d0d5",
           Text = "Save Default Position",
           ContextDescription = "Settings button to set default position",
        },
        SavePositionTooltip = {
           Handle = "h9e8f2aecg2b81g4f48ga9bbg43dd8f593686",
           Text = "Saves the UI's current position and restores it upon reloading. Use to set the default position of the UI.",
           ContextDescription = "Tooltip for button to set default position",
        },
        EnableCorpses_Name = {
           Handle = "h30052af9g5fbag4abcg9a0eg1ee45676a79c",
           Text = "Enable Corpses",
           ContextDescription = "Setting name",
        },
        EnableCorpses_Description = {
           Handle = "ha15ba540g2da4g4056g8174gcd25a3b1d343",
           Text = "Allows examining dead characters.",
           ContextDescription = "Setting tooltip",
        },
        Opacity_Name = {
           Handle = "h042a555bg1f1dg43efg97a8g0df8238a0eb5",
           Text = "Background Opacity",
           ContextDescription = "Setting name",
        },
        Opacity_Description = {
           Handle = "h3985c604gd7a2g4e68gb817g4d1311259a13",
           Text = "Controls the opacity of the background panel.<br><br>Default is 80%.",
           ContextDescription = "Setting tooltip",
        },
        Width_Name = {
           Handle = "h3a060f85gad6dg4e73g8526ga0606d366478",
           Text = "Width",
           ContextDescription = "Setting name",
        },
        Width_Description = {
           Handle = "h4f610121gdb42g4d2fg9a8ag61eeedb018cb",
           Text = "Controls the width of the user interface.<br><br>Default is 400.",
           ContextDescription = "Setting tooltip",
        },
        Height_Name = {
           Handle = "h693e7865g63d9g402bgba37g2f627a59d4c6",
           Text = "Height",
           ContextDescription = "Setting name",
        },
        Height_Description = {
           Handle = "hccad2bc4g7010g48e3gae5dg045ab5228de2",
           Text = "Controls the height of the user interface.<br><br>Default is 600.",
           ContextDescription = "Setting tooltip",
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
-- SETTINGS
---------------------------------------------

local TSKs = QuickExamine.TranslatedStrings

QuickExamine:RegisterSetting("AllowDead", {
    Type = "Boolean",
    Name = TSKs.EnableCorpses_Name,
    Description = TSKs.EnableCorpses_Description,
    DefaultValue = false,
})
QuickExamine:RegisterSetting("Opacity", {
    Type = "ClampedNumber",
    Name = TSKs.Opacity_Name,
    Description = TSKs.Opacity_Description,
    Min = 0,
    Max = 100,
    Step = 1,
    HideNumbers = false,
    DefaultValue = 80,
})
QuickExamine:RegisterSetting("Width", {
    Type = "ClampedNumber",
    Name = TSKs.Width_Name,
    Description = TSKs.Width_Description,
    Min = 300,
    Max = 800,
    Step = 1,
    HideNumbers = false,
    DefaultValue = 400,
})
QuickExamine:RegisterSetting("Height", {
    Type = "ClampedNumber",
    Name = TSKs.Height_Name,
    Description = TSKs.Height_Description,
    Min = 300,
    Max = 800,
    Step = 1,
    HideNumbers = false,
    DefaultValue = 600,
})
-- Hidden from the user, set through a button in the settings menu.
QuickExamine:RegisterSetting("Position", {
    Type = "Vector",
    Name = "Position",
    Arity = 2,
    Description = "Controls the position of the interface.",
    DefaultValue = Vector.Create(-1, -1),
})

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

---@return number
function QuickExamine.GetWidth()
    return QuickExamine:GetSettingValue(QuickExamine.Settings.Width)
end

---@return number
function QuickExamine.GetHeight()
    return QuickExamine:GetSettingValue(QuickExamine.Settings.Height)
end

---@return number
function QuickExamine.GetContainerWidth()
    return QuickExamine.GetWidth() - QuickExamine.CONTAINER_PADDING * 2 - QuickExamine.SCROLLBAR_WIDTH
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

---@return Feature_QuickExamine_Widget[]
function QuickExamine.GetWidgets()
    return QuickExamine._Widgets
end

function QuickExamine._UpdatePanelSize()
    local UI = QuickExamine.UI
    local uiObject = UI:GetUI()
    local width = QuickExamine.GetWidth()
    local height = QuickExamine.GetHeight()

    uiObject.SysPanelSize = {width + QuickExamine.SCROLLBAR_WIDTH, height}
    uiObject.Left = width - 2
end

function QuickExamine._RestorePosition()
    local savedPosition = QuickExamine:GetSettingValue(QuickExamine.Settings.Position) ---@type Vector2D
    local viewportSize = Ext.UI.GetViewportSize()

    -- Do not restore position if it would be placed off-screen (possible scenario if user's resolution changes)
    if savedPosition[1] >= 0 and savedPosition[2] >= 0 and savedPosition[1] < viewportSize[1] and savedPosition[2] < viewportSize[2] then
        QuickExamine:DebugLog("Restoring saved position", savedPosition:unpack())

        QuickExamine.UI:GetUI():SetPosition(savedPosition:unpack())
    end
end

---@param position Vector2D? Defaults to current position.
function QuickExamine._SetDefaultPosition(position)
    position = position or Vector.Create(QuickExamine.UI:GetUI():GetPosition())

    QuickExamine.Settings.Position:SetValue(position)
    QuickExamine:SaveSettings()
end

---@param setting SettingsLib_Setting
---@return boolean
function QuickExamine.IsWidgetSetting(setting)
    local isWidgetSetting = false

    for _,widget in ipairs(QuickExamine.GetWidgets()) do
        if widget.Setting and widget.Setting.ID == setting.ID and setting.ModTable == widget.Setting.ModTable then
            isWidgetSetting = true
            break
        end
    end

    return isWidgetSetting
end

---Sets the entity displayed on the UI and opens it, if it was closed.
---The entity must pass `IsEligible()` and be different from the current entity.
---@see Feature_QuickExamine.IsEligible
---@param entity Entity
---@param forceUpdate boolean? If `true`, the UI will be refreshed even if the entity passed is the same as current. Defaults to `false`.
function QuickExamine.SetEntity(entity, forceUpdate)
    if entity and QuickExamine.IsEligible(entity) then
        if entity.NetID ~= QuickExamine.entityNetID or forceUpdate or not QuickExamine.UI:IsVisible() then
            local width = QuickExamine.GetWidth()
            local height = QuickExamine.GetHeight()
            local UI = QuickExamine.UI

            QuickExamine.entityNetID = entity.NetID

            QuickExamine.GetContainer():Clear()

            UI.Container:SetSize(width, -1)
            UI.HeaderList:SetSize(width, -1)
            UI.HeaderText:SetSize(width, 20)
            UI.CharacterNameText:SetSize(width, 30)
            UI.DraggingArea:SetBackground("Black", width, 75)
            UI.CloseButton:SetPosition(width - UI.CloseButton:GetMovieClip().width, 0)

            -- Filler to compensate for the top div having a short height for the culling effect.
            QuickExamine.GetContainer():AddChild("Filler", "GenericUI_Element_Empty"):GetMovieClip().heightOverride = 10

            QuickExamine.CharacterNameElement:SetText(Text.Format(entity.DisplayName, {
                Color = "ffffff",
                Size = 21,
            }))
            QuickExamine.CharacterNameElement:SetSize(width, 50)

            UI.MainDivider:SetSize(QuickExamine.GetContainerWidth())

            UI.HeaderList:RepositionElements()

            UI.ContentContainer:SetFrame(QuickExamine.GetContainerWidth(), QuickExamine.GetHeight() - 99)
            UI.ContentContainer:SetScrollbarSpacing(-QuickExamine.CONTAINER_PADDING * 2)
            UI.LockButton:SetPosition(QuickExamine.GetWidth() - 48, 2)

            -- Set background alpha.
            local background = UI.Background
            background:SetAlpha(QuickExamine:GetSettingValue(QuickExamine.Settings.Opacity) / 100)
            background:SetSize(width, height)

            -- Set UIObject properties.
            QuickExamine._UpdatePanelSize()

            QuickExamine.Events.EntityChanged:Fire(entity)

            UI.Container:RepositionElements()

            UI:GetUI():Show()
        end
    elseif not entity then -- Only hide the UI is entity passed is nil.
        QuickExamine.entityNetID = nil

        QuickExamine.UI:GetUI():Hide()
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == "EpipEncounters_QuickExamine" then
        local char = Pointer.GetCurrentCharacter(nil, true)

        QuickExamine.SetEntity(char, true)
    end
end)

-- Update the entity when the health bar updates.
Client.UI.EnemyHealthBar.Events.Updated:Subscribe(function (ev)
    if ev.Character and QuickExamine.UI:IsVisible() and not QuickExamine.IsLocked() then
        QuickExamine.SetEntity(ev.Character) -- TODO support items
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

        QuickExamine.GetContainer():RepositionElements()
    end
end)

-- Refresh the UI when graphical settings are changed.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if QuickExamine.UI and (QuickExamine.GRAPHICAL_SETTINGS:Contains(ev.Setting.ID) or QuickExamine.IsWidgetSetting(ev.Setting)) then
        local width = QuickExamine.UI:GetUI().SysPanelSize[1]
        local newWidth
        local posX, posY

        QuickExamine.SetEntity(Character.Get(QuickExamine.entityNetID), true) -- TODO support items

        newWidth = QuickExamine.UI:GetUI().SysPanelSize[1]
        posX, posY = QuickExamine.UI:GetPosition()
        QuickExamine.UI:GetUI():SetPosition(posX - (newWidth - width), posY)
    end
end)

-- Listen for "Save default position" button being pressed in the settings menu.
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
SettingsMenu.Events.ButtonPressed:Subscribe(function (ev)
    if ev.ButtonID == "QuickExamine_SaveDefaultPosition" then
        QuickExamine._SetDefaultPosition()
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local function Setup()
    ---@class Feature_QuickExamine_UI
    local UI = QuickExamine.UI
    local uiObject = UI:GetUI()

    -- Load config.
    QuickExamine.LoadData()

    QuickExamine._UpdatePanelSize()

    UI:ExternalInterfaceCall("setPosition", "center", "screen", "right")

    -- Push the UI down a bit from the center, so it's below the minimap at 1080p
    local x, y = UI:GetPosition()
    uiObject:SetPosition(x, y + 100)

    -- Build elements
    local panel = UI:CreateElement("Panel", "GenericUI_Element_TiledBackground")
    UI.Background = panel

    local container = panel:AddChild("Container", "GenericUI_Element_VerticalList")
    container:SetCenterInLists(true)
    UI.Container = container

    local list = container:AddChild("List", "GenericUI_Element_VerticalList")
    UI.HeaderList = list

    local header = list:AddChild("Header", "GenericUI_Element_Text")
    header:SetText(Text.Format("Quick Examine", {
        Color = "ffffff",
        Size = 15,
    }))
    UI.HeaderText = header

    local charName = list:AddChild("CharName", "GenericUI_Element_Text")
    charName:SetText(Text.Format("Character Name", {
        Color = "ffffff",
        Size = 21,
    }))
    UI.CharacterNameText = charName
    QuickExamine.CharacterNameElement = charName

    local div = list:AddChild("MainDiv", "GenericUI_Element_Divider")
    div:SetCenterInLists(true)
    div:GetMovieClip().heightOverride = div:GetMovieClip().height / 2
    UI.MainDivider = div

    -- Draggable area
    local dragArea = panel:AddChild("DragArea", "GenericUI_Element_TiledBackground")
    dragArea:SetAlpha(0.2)
    dragArea:SetAsDraggableArea()
    UI.DraggingArea = dragArea

    local content = list:AddChild("Content", "GenericUI_Element_ScrollList")
    content:SetMouseWheelEnabled(true)
    content:Move(QuickExamine.CONTAINER_PADDING, 0)
    QuickExamine.ContentContainer = content
    UI.ContentContainer = content
    
    local closeButton = panel:AddChild("Close", "GenericUI_Element_Button")
    closeButton:SetType("Close")
    closeButton.Events.Pressed:Subscribe(function (_)
        UI:GetUI():Hide()
    end)
    UI.CloseButton = closeButton

    local lockButton = panel:AddChild("Lock", "GenericUI_Element_StateButton")
    lockButton:SetType("Lock")
    lockButton:SetActive(QuickExamine.IsLocked())
    lockButton.Events.StateChanged:Subscribe(function (ev)
        QuickExamine.lockCharacter = ev.Active
        QuickExamine.SaveData()
    end)
    lockButton.Tooltip = "Lock Character"
    UI.LockButton = lockButton

    uiObject.Layer = Client.UI.PlayerInfo:GetUI().Layer

    -- Needs a delay to not collide with the setposition UI
    Timer.StartTickTimer(3, function (_)
        QuickExamine._RestorePosition()
    end)

    uiObject:Hide()
end

function QuickExamine:__Setup()
    local startupDelay = 0.1 -- Required for setPosition to work.
    QuickExamine.UI = Generic.Create("PIP_QuickExamine")

    Timer.Start(startupDelay, function()
        Setup()
    end)
end