
local BatteredHarried = EpicEncounters.BatteredHarried
local ObjectPool = DataStructures.Get("ObjectPool")
local Generic = Client.UI.Generic
local V = Vector.Create

---@class Feature_BHOverheads
local BHOverheads = Epip.GetFeature("Feature_BHOverheads")

---@class Feature_BHOverheads_UIFactory : Class
local UIFactory = {
    _InstancePool = ObjectPool.Create(), ---@type ObjectPool<Features.BHOverheads.UIFactory.Instance>
}
BHOverheads:RegisterClass("Feature_BHOverheads_UIFactory", UIFactory)

UIFactory.UI_SIZE = V(100, 50)
UIFactory.UI_ALPHA = 0
UIFactory.CHARACTER_POS_OFFSET = V(0, 1.5, 0)
UIFactory.UI_OFFSET = V(-40, -40)
UIFactory.ICON_SIZE = V(40, 40)
UIFactory.FADED_ICON_ALPHA = 0.75 -- Alpha for when stack requirement for T3 is not met

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.BHOverheads.UIFactory.Instance : GenericUI_Instance
---@field BatteredIcon GenericUI_Element_IggyIcon
---@field HarriedIcon GenericUI_Element_IggyIcon
---@field CharacterHandle ComponentHandle? `nil` if the UI has no character set.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an overlay for a character.
---@param char EclCharacter
---@return Features.BHOverheads.UIFactory.Instance
function UIFactory.Create(char)
    local instance = UIFactory._GetAvailableInstance() or UIFactory._Create()

    BHOverheads:DebugLog("Assigning a UI to", char.DisplayName)
    UIFactory._SetCharacter(instance, char)

    return instance
end

---Disposes of a BH overhead UI.
---@param ui Features.BHOverheads.UIFactory.Instance
function UIFactory.Dispose(ui)
    local instanceID = ui:GetID()

    -- Stop the update loop and hide the UI
    GameState.Events.RunningTick:Unsubscribe(instanceID)
    ui:Hide()

    UIFactory._InstancePool:Dispose(ui)
end

---------------------------------------------
-- PRIVATE METHODS
---------------------------------------------

---Creates a new instance of the UI.
---@return Features.BHOverheads.UIFactory.Instance
function UIFactory._Create()
    local instanceID = "Epip_Feature_BHOverheads_" .. Text.GenerateGUID()
    local instance = Generic.Create(instanceID) ---@cast instance Features.BHOverheads.UIFactory.Instance
    instance:TogglePlayerInput(false)

    local bg = instance:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Black", UIFactory.UI_SIZE:unpack())
    bg:SetAlpha(UIFactory.UI_ALPHA)

    local iconList = bg:AddChild("IconList", "GenericUI_Element_HorizontalList")
    local batteredIconElement = iconList:AddChild("Battered", "GenericUI_Element_IggyIcon")
    local harriedIconElement = iconList:AddChild("Harried", "GenericUI_Element_IggyIcon")

    instance.BatteredIcon = batteredIconElement
    instance.HarriedIcon = harriedIconElement

    return instance
end

---Sets the character bound to an instance.
---@param instance Features.BHOverheads.UIFactory.Instance
---@param char EclCharacter
function UIFactory._SetCharacter(instance, char)
    instance.CharacterHandle = char.Handle

    -- Start the update loop.
    GameState.Events.RunningTick:Subscribe(function (_)
        local uiObject = instance:GetUI()
        local clientChar = Client.GetCharacter()
        local uiChar = Character.Get(instance.CharacterHandle)
        local pos = Vector.Create(uiChar.WorldPos)
        pos = pos + UIFactory.CHARACTER_POS_OFFSET

        local uiPos = Client.WorldPositionToScreen(pos) + UIFactory.UI_OFFSET
        uiObject:SetPosition(math.floor(uiPos[1]), math.floor(uiPos[2]))

        -- Update BH icons
        local battered = BatteredHarried.GetStacks(uiChar, "Battered")
        local harried = BatteredHarried.GetStacks(uiChar, "Harried")
        local batteredIcon = BatteredHarried.GetIcon("Battered", battered)
        local harriedIcon = BatteredHarried.GetIcon("Harried", harried)
        local batteredIconElement = instance.BatteredIcon
        local harriedIconElement = instance.HarriedIcon

        batteredIconElement:SetIcon(batteredIcon, UIFactory.ICON_SIZE:unpack())
        harriedIconElement:SetIcon(harriedIcon, UIFactory.ICON_SIZE:unpack())

        -- Fade out icons if the stack count is not enough for applying T3
        local stacksNeededForTier3 = BatteredHarried.GetStacksNeededToInflictTier3(clientChar)
        batteredIconElement:SetAlpha(battered >= stacksNeededForTier3 and 1 or UIFactory.FADED_ICON_ALPHA)
        harriedIconElement:SetAlpha(harried >= stacksNeededForTier3 and 1 or UIFactory.FADED_ICON_ALPHA)
    end, {StringID = instance:GetID()})
end

---Returns an available instance from the pool, if any.
---@return Features.BHOverheads.UIFactory.Instance?
function UIFactory._GetAvailableInstance()
    return UIFactory._InstancePool:Get()
end