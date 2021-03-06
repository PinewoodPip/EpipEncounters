
---@class QuickExamine : Feature
Epip.Features.QuickExamine = {
    entityNetID = nil,
    lockCharacter = false,

    UI = nil, ---@type GenericUI_Instance
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
---@class QuickExamine
local QuickExamine = Epip.Features.QuickExamine
Epip.AddFeature("QuickExamine", "QuickExamine", QuickExamine)

local Generic = Client.UI.Generic

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class QuickExamine_Event_EntityChanged : Event
---@field RegisterListener fun(self, listener:fun(entity:Entity))
---@field Fire fun(self, entity:Entity)

---------------------------------------------
-- METHODS
---------------------------------------------

---@return GenericUI_Element_VerticalList
function Epip.Features.QuickExamine.GetContainer()
    return QuickExamine.ContentContainer
end

function QuickExamine.GetContainerWidth()
    return QuickExamine.GetContainer():GetMovieClip().width - 60
end

---@param path Path?
function QuickExamine.LoadData(path)
    path = path or QuickExamine.SAVE_FILENAME
    local save = Utilities.LoadJson(path)

    if save then
        QuickExamine.lockCharacter = save.Lock
    end
end

---@param path Path?
function QuickExamine.SaveData(path)
    path = path or QuickExamine.SAVE_FILENAME

    Utilities.SaveJson(path, {
        Version = QuickExamine.SAVE_VERSION,
        Lock = QuickExamine.lockCharacter,
    })
end

---@return boolean
function Epip.Features.QuickExamine.IsLocked()
    return QuickExamine.lockCharacter
end

---@param entity Entity
function Epip.Features.QuickExamine.SetEntity(entity)
    if entity then
        if entity.NetID ~= QuickExamine.entityNetID then
            QuickExamine.entityNetID = entity.NetID

            QuickExamine.GetContainer():Clear()

            -- Filler to compensate for the top div having a short height for the culling effect.
            QuickExamine.GetContainer():AddChild("Filler", "Empty"):GetMovieClip().heightOverride = 10

            QuickExamine.CharacterNameElement:SetText(Text.Format(entity.DisplayName, {
                Color = "ffffff",
                Size = 21,
            }))
            QuickExamine.CharacterNameElement:SetSize(QuickExamine.WIDTH, 50)

            QuickExamine.Events.EntityChanged:Fire(entity)

            QuickExamine.UI:GetElementByID("Container"):RepositionElements()

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
        local char = Client.GetPointerCharacter()

        QuickExamine.SetEntity(char)
    end
end)

Client.UI.EnemyHealthBar:RegisterListener("updated", function(char, _)
    if char and QuickExamine.UI:IsVisible() and not QuickExamine.IsLocked() then
        QuickExamine.SetEntity(char) -- TODO support items
    end
end)

QuickExamine.Events.EntityChanged:RegisterListener(function (entity)
    local container = QuickExamine.GetContainer()
    local artifacts = Artifact.GetEquippedPowers(entity)

    local header = container:AddChild("QuickExamine_Artifacts_Header", "Text")
    header:SetText(Text.Format("Artifact Powers", {Color = "ffffff", Size = 19}))
    header:SetSize(QuickExamine.GetContainerWidth(), 30)

    if #artifacts > 0 then
        local artifactContainer = container:AddChild("QuickExamine_Artifacts", "HorizontalList")
        artifactContainer:SetSize(QuickExamine.GetContainerWidth(), 35)
        artifactContainer:SetCenterInLists(true)

        for _,artifact in ipairs(artifacts) do
            local template = Ext.Template.GetTemplate(string.match(artifact.ItemTemplate, Data.Patterns.GUID)) ---@type ItemTemplate

            local icon = artifactContainer:AddChild(artifact.ID .. "icon", "IggyIcon")
            icon:SetIcon(template.Icon, 32, 32)
            icon.Tooltip = {
                Type = "Formatted",
                Data = artifact:GetPowerTooltip(),
            }
        end
    end

    local div = container:AddChild("QuickExamine_Divider", "Divider")
    div:SetSize(QuickExamine.DIVIDER_WIDTH, 20)
    div:SetCenterInLists(true)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

local function Setup()
    local ui = QuickExamine.UI
    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {QuickExamine.WIDTH + QuickExamine.SCROLLBAR_WIDTH, QuickExamine.HEIGHT}
    uiObject.Left = QuickExamine.WIDTH

    QuickExamine.LoadData()

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "right")

    -- Push the UI down a bit from the center, so it's below the minimap at 1080p
    local x, y = ui:GetPosition()
    uiObject:SetPosition(x, y + 100)

    -- Build elements
    local panel = ui:CreateElement("Panel", "TiledBackground")
    panel:SetSize(QuickExamine.WIDTH, QuickExamine.HEIGHT)
    panel:SetAlpha(QuickExamine.ALPHA)

    local container = panel:AddChild("Container", "VerticalList")
    container:SetSize(QuickExamine.WIDTH, -1)
    container:SetCenterInLists(true)

    local list = container:AddChild("List", "VerticalList")
    list:SetSize(QuickExamine.WIDTH, -1)
    list:SetSideSpacing(-20)

    local header = list:AddChild("Header", "Text")
    header:SetText(Text.Format("Quick Examine", {
        Color = "ffffff",
        Size = 15,
    }))
    header:SetSize(QuickExamine.WIDTH, 20)
    header:SetAsDraggableArea()

    local charName = list:AddChild("CharName", "Text")
    charName:SetText(Text.Format("Character Name", {
        Color = "ffffff",
        Size = 21,
    }))
    charName:SetSize(QuickExamine.WIDTH, 30)
    charName:SetAsDraggableArea()
    QuickExamine.CharacterNameElement = charName

    local div = list:AddChild("MainDiv", "Divider")
    div:SetAsDraggableArea()
    div:SetSize(QuickExamine.DIVIDER_WIDTH, 20)
    div:SetCenterInLists(true)
    div:GetMovieClip().heightOverride = div:GetMovieClip().height / 2

    local content = list:AddChild("Content", "ScrollList")
    content:SetMouseWheenEnabled(true)
    content:SetFrame(QuickExamine.WIDTH - 30, 510)
    content:SetScrollbarSpacing(20)
    content:SetSideSpacing(26)
    QuickExamine.ContentContainer = content
    
    local closeButton = panel:AddChild("Close", "Button")
    closeButton:SetType(Generic.ELEMENTS.Button.TYPES.CLOSE)
    closeButton:SetPosition(QuickExamine.WIDTH - closeButton:GetMovieClip().width, 0)
    closeButton:RegisterListener(Generic.ELEMENTS.Button.EVENT_TYPES.PRESSED, function()
        ui:GetUI():Hide()
    end)

    local lockButton = panel:AddChild("Lock", "StateButton")
    lockButton:SetType(Generic.ELEMENTS.StateButton.TYPES.LOCK)
    lockButton:SetActive(QuickExamine.IsLocked())
    lockButton:SetPosition(400 - 23 - 25, 2)
    lockButton:RegisterListener(Generic.ELEMENTS.StateButton.EVENT_TYPES.STATE_CHANGED, function(state)
        QuickExamine.lockCharacter = state
        QuickExamine.SaveData()
    end)
    lockButton.Tooltip = "Lock Character"

    uiObject.Layer = Client.UI.PlayerInfo:GetUI().Layer

    uiObject:Hide()
end

function QuickExamine:__Setup()
    QuickExamine.UI = Generic.Create("PIP_QuickExamine")

    -- Delayed setup to catch errors
    if Epip.IsDeveloperMode(true) then
        Client.Timer.Start("", 1.4, function()
            Setup()
        end)
    else
        Setup()
    end
end