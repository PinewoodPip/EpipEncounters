
local BatteredHarried = EpicEncounters.BatteredHarried
local Generic = Client.UI.Generic
local V = Vector.Create

---@class Feature_BHOverheads
local BHOverheads = Epip.GetFeature("Feature_BHOverheads")

---@class Feature_BHOverheads_UIFactory : Class
local UIFactory = {}
BHOverheads:RegisterClass("Feature_BHOverheads_UIFactory", UIFactory)

UIFactory.UI_SIZE = V(100, 50)
UIFactory.UI_ALPHA = 0
UIFactory.CHARACTER_POS_OFFSET = V(0, 1.5, 0)
UIFactory.UI_OFFSET = V(-40, -40)
UIFactory.ICON_SIZE = V(40, 40)
UIFactory.FADED_ICON_ALPHA = 0.75 -- Alpha for when stack requirement for T3 is not met

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an overlay for a character.
---@param char EclCharacter
---@return GenericUI_Instance
function UIFactory.Create(char)
    local instanceID = "Epip_Feature_BHOverheads_" .. char.MyGuid .. "_" .. Text.GenerateGUID()
    local instance = Generic.Create(instanceID)
    instance._BHOverlayCharacterHandle = char.Handle
    instance:TogglePlayerInput(false)

    local bg = instance:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Black", UIFactory.UI_SIZE:unpack())
    bg:SetAlpha(UIFactory.UI_ALPHA)

    local iconList = bg:AddChild("IconList", "GenericUI_Element_HorizontalList")
    local batteredIconElement = iconList:AddChild("Battered", "GenericUI_Element_IggyIcon")
    local harriedIconElement = iconList:AddChild("Harried", "GenericUI_Element_IggyIcon")

    GameState.Events.RunningTick:Subscribe(function (_)
        local uiObject = instance:GetUI()
        local clientChar = Client.GetCharacter()
        local uiChar = Character.Get(instance._BHOverlayCharacterHandle)
        local pos = Vector.Create(uiChar.WorldPos)
        pos = pos + UIFactory.CHARACTER_POS_OFFSET

        local uiPos = Client.WorldPositionToScreen(pos) + UIFactory.UI_OFFSET
        uiObject:SetPosition(math.floor(uiPos[1]), math.floor(uiPos[2]))

        -- Update BH icons
        local battered = BatteredHarried.GetStacks(uiChar, "Battered")
        local harried = BatteredHarried.GetStacks(uiChar, "Harried")
        local batteredIcon = BatteredHarried.GetIcon("Battered", battered)
        local harriedIcon = BatteredHarried.GetIcon("Harried", harried)

        batteredIconElement:SetIcon(batteredIcon, UIFactory.ICON_SIZE:unpack())
        harriedIconElement:SetIcon(harriedIcon, UIFactory.ICON_SIZE:unpack())

        -- Fade out icons if the stack count is not enough for applying T3
        local stacksNeededForTier3 = BatteredHarried.GetStacksNeededToInflictTier3(clientChar)
        batteredIconElement:SetAlpha(battered >= stacksNeededForTier3 and 1 or UIFactory.FADED_ICON_ALPHA)
        harriedIconElement:SetAlpha(harried >= stacksNeededForTier3 and 1 or UIFactory.FADED_ICON_ALPHA)
    end, {StringID = instanceID})

    return instance
end

---Unitializes and destroys a BH overhead UI.
---@param ui GenericUI_Instance
function UIFactory.Destroy(ui)
    GameState.Events.RunningTick:Unsubscribe(ui:GetID())
    ui:Destroy()
end