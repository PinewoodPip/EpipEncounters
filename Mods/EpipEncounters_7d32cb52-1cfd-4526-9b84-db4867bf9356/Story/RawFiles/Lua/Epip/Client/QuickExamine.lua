
Epip.Features.QuickExamine = {
    EntityNetID = nil,
    UI = nil, ---@type GenericUI_Instance
    WIDTH = 400,
    SCROLLBAR_WIDTH = 10,
    ContentContainer = nil, ---@type GenericUI_Element_VerticalList
    CharacterNameElement = nil, ---@type GenericUI_Element_Text
    DIVIDER_WIDTH = 370,
    ALPHA = 0.8,
    HEIGHT = 600,

    Events = {
        EntityChanged = {}, ---@type QuickExamine_Event_EntityChanged
    },
}
local QuickExamine = Epip.Features.QuickExamine
Epip.AddFeature("QuickExamine", "QuickExamine", QuickExamine)

local Generic = Client.UI.Generic

QuickExamine.UI = Generic.Create("PIP_QuickExamine")

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

---@param entity Entity
function Epip.Features.QuickExamine.SetEntity(entity)
    if entity then
        QuickExamine.EntityNetID = entity.NetID

        QuickExamine.GetContainer():Clear()

        QuickExamine.CharacterNameElement:SetText(Text.Format(entity.DisplayName, {
            Color = "ffffff",
            Size = 21,
        }))
        QuickExamine.CharacterNameElement:SetSize(QuickExamine.WIDTH, 50)

        QuickExamine.Events.EntityChanged:Fire(entity)

        QuickExamine.UI:GetElementByID("Container"):RepositionElements()

        QuickExamine.UI:GetUI():Show()
    else
        QuickExamine.EntityNetID = nil

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

---------------------------------------------
-- SETUP
---------------------------------------------

local function Setup()
    local ui = QuickExamine.UI
    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {QuickExamine.WIDTH + QuickExamine.SCROLLBAR_WIDTH, QuickExamine.HEIGHT}
    uiObject.Left = QuickExamine.WIDTH

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "right")

    -- Push the UI down a bit from the center, so it's below the minimap at 1080p
    local x, y = ui:GetPosition()
    uiObject:SetPosition(x, y + 100)

    -- Build elements

    local panel = ui:CreateElement("Panel", "TiledBackground")
    panel:SetSize(QuickExamine.WIDTH, QuickExamine.HEIGHT)
    panel:SetAlpha(QuickExamine.ALPHA)

    local container = panel:AddChild("Container", "VerticalList")

    local list = container:AddChild("List", "VerticalList")
    list:SetSize(QuickExamine.WIDTH, -1) -- TODO remove, TODO investigate stack overflow

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

    local content = list:AddChild("Content", "ScrollList")
    content:SetMouseWheenEnabled(true)
    content:SetFrame(QuickExamine.WIDTH, 510)
    content:SetScrollbarSpacing(-30)
    content:SetSideSpacing(5)
    QuickExamine.ContentContainer = content

    
    local closeButton = panel:AddChild("Close", "Button")
    closeButton:SetType(Generic.ELEMENTS.Button.TYPES.CLOSE)
    -- closeButton:SetPosition(QuickExamine.WIDTH - closeButton:GetMovieClip().width, 0)
    closeButton:SetPosition(400 - 23, 0) -- TODO fix
    closeButton:RegisterListener(Generic.ELEMENTS.Button.EVENT_TYPES.PRESSED, function()
        ui:GetUI():Hide()
    end)

    uiObject.Layer = Client.UI.PlayerInfo:GetUI().Layer

    uiObject:Hide()
end

function QuickExamine:__Setup()
    Client.Timer.Start("", 1.4, function()
        Setup()
    end)
end