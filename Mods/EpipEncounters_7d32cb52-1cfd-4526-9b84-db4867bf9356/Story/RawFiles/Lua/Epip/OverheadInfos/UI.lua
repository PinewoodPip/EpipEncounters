
local BatteredHarried = EpicEncounters.BatteredHarried
local ObjectPool = DataStructures.Get("ObjectPool")
local Generic = Client.UI.Generic
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local _IsEpicEncounters = EpicEncounters.IsEnabled()
local V = Vector.Create

---@class Features.OverheadInfos
local BHOverheads = Epip.GetFeature("Features.OverheadInfos")

---@class Features.OverheadInfos.UIFactory : Class
local UIFactory = {
    _InstancePool = ObjectPool.Create(), ---@type ObjectPool<Features.OverheadInfos.UIFactory.Instance>
}
BHOverheads:RegisterClass("Features.OverheadInfos.UIFactory", UIFactory)

UIFactory.UI_SIZE = V(100, 50)
UIFactory.UI_ALPHA = 0
UIFactory.CHARACTER_POS_Y_OFFSET = 0.5
UIFactory.UI_OFFSET = V(0, -40)
UIFactory.ICON_SIZE = V(40, 40)
UIFactory.FADED_ICON_ALPHA = 0.75 -- Alpha for when stack requirement for T3 is not met
UIFactory.HEALTHBAR_SCALE = 0.5
UIFactory.BARS_X_OFFSET = 25
UIFactory.BAR_HEIGHT = 15
UIFactory.VITALITY_BAR_WIDTH = 350
UIFactory.ARMOR_BAR_WIDTH = 170

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.OverheadInfos.UIFactory.Instance : GenericUI_Instance
---@field Root GenericUI_Element_Empty
---@field BatteredIcon GenericUI_Element_IggyIcon
---@field HarriedIcon GenericUI_Element_IggyIcon
---@field CharacterHandle ComponentHandle? `nil` if the UI has no character set.
---@field VitalityBar GenericUI_Element_Color
---@field PhysicalArmorBar GenericUI_Element_Color
---@field MagicArmorBar GenericUI_Element_Color

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an overlay for a character.
---@param char EclCharacter
---@return Features.OverheadInfos.UIFactory.Instance
function UIFactory.Create(char)
    local instance = UIFactory._GetAvailableInstance() or UIFactory._Create()

    BHOverheads:DebugLog("Assigning a UI to", char.DisplayName)
    UIFactory._SetCharacter(instance, char)

    return instance
end

---Disposes of a BH overhead UI.
---@param ui Features.OverheadInfos.UIFactory.Instance
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
---@return Features.OverheadInfos.UIFactory.Instance
function UIFactory._Create()
    local instanceID = "Epip.Features.OverheadInfos." .. Text.GenerateGUID()
    local instance = Generic.Create(instanceID) ---@cast instance Features.OverheadInfos.UIFactory.Instance
    instance:TogglePlayerInput(false)

    local bg = instance:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Black", UIFactory.UI_SIZE:unpack())
    bg:SetAlpha(UIFactory.UI_ALPHA)

    local root = bg:AddChild("Root", "GenericUI_Element_Empty")
    instance.Root = root

    local BAR_HEIGHT = UIFactory.BAR_HEIGHT
    local BARS_X_OFFSET = UIFactory.BARS_X_OFFSET
    local ARMOR_BAR_WIDTH = UIFactory.ARMOR_BAR_WIDTH
    local HEALTHBAR_SCALE = UIFactory.HEALTHBAR_SCALE

    -- Health bar container
    local healthBarContainer = root:AddChild("HealthBarContainer", "GenericUI_Element_Empty")

    -- Black background behind the bars; also serves as a divider between the armor bars
    local healthBarBg = healthBarContainer:AddChild("Health.Background", "GenericUI_Element_Color")
    healthBarBg:SetSize(ARMOR_BAR_WIDTH * 2 + 15, BAR_HEIGHT * 2)
    healthBarBg:SetColor(Color.CreateFromHex("000000"))
    healthBarBg:Move(19, 15)

    -- Vitality bar
    local vitalityBar = healthBarContainer:AddChild("Health.VitalityBar", "GenericUI_Element_Color")
    vitalityBar:SetSize(UIFactory.VITALITY_BAR_WIDTH, BAR_HEIGHT)
    vitalityBar:SetColor(Color.CreateFromHex("DC313D"))
    vitalityBar:Move(BARS_X_OFFSET, 33)
    instance.VitalityBar = vitalityBar

    -- Physical armor bar
    local physArmorBar = healthBarContainer:AddChild("Health.PhysicalArmorBar", "GenericUI_Element_Color")
    physArmorBar:SetSize(ARMOR_BAR_WIDTH, BAR_HEIGHT)
    physArmorBar:SetColor(Color.CreateFromHex("C3C2C2"))
    physArmorBar:Move(BARS_X_OFFSET, 15)
    instance.PhysicalArmorBar = physArmorBar

    -- Magic armor bar
    local magicArmorBar = healthBarContainer:AddChild("Health.MagicArmorBar", "GenericUI_Element_Color")
    magicArmorBar:SetSize(ARMOR_BAR_WIDTH, BAR_HEIGHT)
    magicArmorBar:SetColor(Color.CreateFromHex("4FADE1"))
    magicArmorBar:Move(BARS_X_OFFSET + ARMOR_BAR_WIDTH + 10, 15)
    instance.MagicArmorBar = magicArmorBar

    local healthBarFrame = healthBarContainer:AddChild("Health.Frame", "GenericUI_Element_Texture")
    healthBarFrame:SetTexture(Textures.BARS.ENEMY_HEALTH_BAR.FRAMES.NORMAL)
    healthBarContainer:SetScale(V(HEALTHBAR_SCALE, HEALTHBAR_SCALE))

    -- Battered icon
    local BATTERED_ICON_OFFSET = -UIFactory.ICON_SIZE[1] / 2 - 3
    local batteredIconElement = root:AddChild("Battered", "GenericUI_Element_IggyIcon")
    batteredIconElement:SetPosition(healthBarContainer:GetPosition())
    batteredIconElement:Move(BATTERED_ICON_OFFSET, 0)
    batteredIconElement:SetVisible(_IsEpicEncounters) -- Always create the B/H element but hide them conditionally. This decision was for maintainability to avoid if-checks for whether the EE elements exist.

    local harriedIconElement = root:AddChild("Harried", "GenericUI_Element_IggyIcon")
    harriedIconElement:SetPosition(healthBarContainer:GetPosition())
    harriedIconElement:Move(healthBarContainer:GetWidth() + 3, 0)
    harriedIconElement:SetVisible(_IsEpicEncounters)

    instance.BatteredIcon = batteredIconElement
    instance.HarriedIcon = harriedIconElement

    -- Center health bar vertically
    healthBarContainer:Move(0, batteredIconElement:GetHeight() / 2 - healthBarContainer:GetHeight() / 2 + 6)

    harriedIconElement:Move(BATTERED_ICON_OFFSET, 0)
    root:Move(UIFactory.ICON_SIZE[1] * 0.5, 0)

    return instance
end

---Sets the character bound to an instance.
---@param instance Features.OverheadInfos.UIFactory.Instance
---@param char EclCharacter
function UIFactory._SetCharacter(instance, char)
    instance.CharacterHandle = char.Handle

    -- Start the update loop.
    GameState.Events.RunningTick:Subscribe(function (_)
        local uiObject = instance:GetUI()
        local clientChar = Client.GetCharacter()
        local uiChar = Character.Get(instance.CharacterHandle)
        local pos = Vector.Create(uiChar.WorldPos)
        pos = pos + V(0, uiChar.Height + UIFactory.CHARACTER_POS_Y_OFFSET, 0)

        local worldPos, depth = Client.WorldPositionToScreen(pos)
        local uiPos = worldPos + UIFactory.UI_OFFSET
        uiObject.RenderOrder = (-depth * 10) // 1 -- Sort overheads by proximity to the camera. Only refreshes when the UI is shown, not when moving the camera - TODO

        local uiWidth = instance.Root:GetWidth() * instance:GetScaleMultiplier()
        uiObject:SetPosition(math.floor(uiPos[1] - uiWidth / 2), math.floor(uiPos[2]))

        -- Update BH icons
        if _IsEpicEncounters then
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
        end

        -- Update healthbar
        local vitalityFraction = uiChar.Stats.CurrentVitality / uiChar.Stats.MaxVitality
        instance.VitalityBar:SetSize(vitalityFraction * UIFactory.VITALITY_BAR_WIDTH, UIFactory.BAR_HEIGHT)
        local physArmorFraction = uiChar.Stats.CurrentArmor / uiChar.Stats.MaxArmor
        instance.PhysicalArmorBar:SetSize(physArmorFraction * UIFactory.ARMOR_BAR_WIDTH, UIFactory.BAR_HEIGHT)
        local magicArmorFraction = uiChar.Stats.CurrentMagicArmor / uiChar.Stats.MaxMagicArmor
        instance.MagicArmorBar:SetSize(magicArmorFraction * UIFactory.ARMOR_BAR_WIDTH, UIFactory.BAR_HEIGHT)
    end, {StringID = instance:GetID()})
end

---Returns an available instance from the pool, if any.
---@return Features.OverheadInfos.UIFactory.Instance?
function UIFactory._GetAvailableInstance()
    return UIFactory._InstancePool:Get()
end