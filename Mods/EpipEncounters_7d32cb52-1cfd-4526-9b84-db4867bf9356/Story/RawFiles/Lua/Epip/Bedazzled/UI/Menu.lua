
local Notification = Client.UI.Notification
local MsgBox = Client.UI.MessageBox
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local DraggingAreaPrefab = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local Button = Generic.GetPrefab("GenericUI_Prefab_Button")
local CommonStrings = Text.CommonStrings
local Input = Client.Input
local V = Vector.Create

local UI = Generic.Create("Features.Bedazzled.UI.Menu")
local TSK = {
    Label_Bedazzle = Bedazzled:RegisterTranslatedString("h4f32f5d3g1149g4401gadc5g056b31b49f87", {
        Text = "Bedazzle",
        ContextDescription = "Context menu option for opening Bedazzled minigame",
    })
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function UI:Show()
    self:_Initialize()
    self:SetPositionRelativeToViewport("center", "center")
    Client.UI._BaseUITable.Show(self)
end

-- TODO remove code duplication
function UI.CreateText(id, parent, label, align, size)
    local text = TextPrefab.Create(UI, id, parent, label, align, size)
    text:SetStroke(Color.Create(0, 0, 0):ToDecimal(), 2, 1, 15, 15)

    return text
end

function UI:_Initialize()
    if self._Initialized then return end

    local uiObject = self:GetUI()

    local panel = self:CreateElement("BG", "GenericUI_Element_Texture")
    panel:SetTexture(Textures.PANELS.CLIPBOARD)

    self.BACKGROUND_SIZE = panel:GetSize()
    self.FRAME_SIZE = V(self.BACKGROUND_SIZE[1] - 20, 500) -- Size of the settings list frame.
    uiObject.SysPanelSize = self.BACKGROUND_SIZE

    local headerLabel = UI.CreateText("TitleHeader", panel, Text.Format(Bedazzled.TranslatedStrings.GameTitle:GetString(), {Size = 42, Color = "7E72D6", FontType = Text.FONTS.ITALIC}), "Center", V(self.BACKGROUND_SIZE[1], 50))
    headerLabel:SetPositionRelativeToParent("Top", 0, 60)

    local startButton = Button.Create(UI, "StartButton", panel, Button:GetStyle("GreenMedium"))
    startButton:SetLabel(CommonStrings.Start)
    startButton:SetPositionRelativeToParent("Bottom", 0, -44)

    -- Start a new game when the start button is pressed.
    startButton.Events.Pressed:Subscribe(function (_)
        Bedazzled.GameUI.Setup()
        UI:Hide()
    end)

    self._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add Bedazzled option to gem and rune context menus.
local function IsRuneCraftingMaterial(item) -- TODO move
    local RUNE_MATERIAL_STATS = {
        LOOT_Bloodstone_A = "Bloodstone",
        TOOL_Pouch_Dust_Bone_A = "Bone",
        LOOT_Clay_A = "Clay",
        LOOT_Emerald_A = "Emerald",
        LOOT_Granite_A = "Granite",
        LOOT_OreBar_A_Iron_A = "Iron",
        LOOT_Jade_A = "Jade",
        LOOT_Lapis_A = "Lapis",
        LOOT_Malachite_A = "Malachite",
        LOOT_Obsidian_A = "Obsidian",
        LOOT_Onyx_A = "Onyx",
        LOOT_Ruby_A = "Ruby",
        LOOT_Sapphire_A = "Sapphire",
        LOOT_OreBar_A_Silver_A = "Silver",
        LOOT_OreBar_A_Steel_A = "Steel",
        LOOT_Tigerseye_A = "TigersEye",
        LOOT_Topaz_A = "Topaz",
    }

    return RUNE_MATERIAL_STATS[item.StatsId] ~= nil
end
Client.UI.ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    local showOption = IsRuneCraftingMaterial(item)
    if not showOption then -- Also show the entry for runes.
        local stat = Stats.Get("StatsLib_StatsEntry_Object", item.StatsId)
        if stat.RuneLevel > 0 then
            showOption = true
        end
    end
    if showOption then
        Client.UI.ContextMenu.AddElement({
            {id = "epip_Feature_Bedazzled", type = "button", text = TSK.Label_Bedazzle:GetString()},
        })
    end
end)

-- Start the game when the context menu option is selected.
Client.UI.ContextMenu.RegisterElementListener("epip_Feature_Bedazzled", "buttonPressed", function(_, _)
    UI:Show()
end)

