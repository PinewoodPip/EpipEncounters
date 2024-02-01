
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local Button = Generic.GetPrefab("GenericUI_Prefab_Button")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local CommonStrings = Text.CommonStrings
local V = Vector.Create

---@class Features.Bedazzled.UI.Menu : GenericUI_Instance
local UI = Generic.Create("Features.Bedazzled.UI.Menu")

---@type table<string, Features.Bedazzled.Board.Modifier>
UI._RegisteredModifiers = {}

local TSK = {
    Label_Bedazzle = Bedazzled:RegisterTranslatedString({
        Handle = "h4f32f5d3g1149g4401gadc5g056b31b49f87",
        Text = "Bedazzle",
        ContextDescription = "Context menu option for opening Bedazzled minigame",
    }),
    Label_HighScores = Bedazzled:RegisterTranslatedString({
        Handle = "he49de766g758eg4360g8000g0a8e5eb1885a",
        Text = "High-Scores",
        ContextDescription = "Label for highscores panel",
    })
}

UI.Events.RenderSettings = SubscribableEvent:New("RenderSettings") ---@type Event<Empty>
UI.Hooks.GetModifierConfiguration = SubscribableEvent:New("GetModifierConfiguration") ---@type Hook<{Modifier:Features.Bedazzled.Board.Modifier, Config:Features.Bedazzled.Board.Modifier.Configuration?}>

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function UI:Show()
    self:_Initialize()

    -- Update the highscores panel; necessary for when player returns from a game with a new score set.
    UI.UpdateHighScoresPanel()

    self:SetPositionRelativeToViewport("center", "center")
    Client.UI._BaseUITable.Show(self)
end

---Registers a game modifier.
---@param mod Features.Bedazzled.Board.Modifier
function UI.RegisterModifier(mod)
    UI._RegisteredModifiers[mod:GetClassName()] = mod
end

-- TODO remove code duplication
function UI.CreateText(id, parent, label, align, size)
    local text = TextPrefab.Create(UI, id, parent, label, align, size)
    text:SetStroke(Color.Create(0, 0, 0):ToDecimal(), 2, 1, 15, 15)

    return text
end

---Starts a game with the current settings.
function UI.StartGame()
    -- Fetch modifiers to use for the new game
    local modifiers = {} ---@type Features.Bedazzled.Board.Modifier[]
    for className,config in pairs(UI.GetModifierConfigs()) do
        table.insert(modifiers, Bedazzled:GetClass(className):Create(config))
    end

    -- Start the game and hide the menu
    local board = Bedazzled.CreateGame("Classic", modifiers)
    Bedazzled.GameUI.Setup(board)
    UI:Hide()
end

---Updates the highscores panel.
---**Should only be called while the UI is visible.**
function UI.UpdateHighScoresPanel()
    local gamemodeLabel = UI.GameModeLabel
    local gamemodeDescription = Text.Format(UI._GetCurrentGameDescription(), {
        Color = Color.BLACK,
        Size = 15,
    })
    gamemodeLabel:SetText(gamemodeDescription)

    -- Gather game mode information and scores
    local gamemode = UI._GetCurrentGameMode()
    local mods = UI.GetModifierConfigs()
    local scores = Bedazzled.GetHighScores(gamemode, mods)
    local list = UI.HighScoresList
    list:Clear()
    for i,score in ipairs(scores) do -- Render scores
        local label = Text.Format("%d. %s", {
            FormatArgs = {
                i,
                Text.AddPadding(tostring(score.Score), 50, " ", "front")
            },
            Color = Color.BLACK,
        })
        local text = TextPrefab.Create(UI, "HighScores_" .. tostring(i), list, label, "Left", V(300, 32))
        text:SetMouseEnabled(true) -- Required for tooltips.

        -- Show date of the score as tooltip
        local date = Client.UI.Time.GetDateFromString(score.Date)
        local dateLabel = Text.Format("%s/%s/%s @ %s:%s", {
            FormatArgs = {
                date.Day,
                date.Month,
                date.Year,
                Text.AddPadding(tostring(date.Hour), 2, "0"),
                Text.AddPadding(tostring(date.Minute), 2, "0"),
            },
        })
        text:SetTooltip("Simple", dateLabel)
    end
end

---Returns the configs for the current chosen modifiers.
---@return Features.Bedazzled.ModifierSet
function UI.GetModifierConfigs()
    local configs = {} ---@type Features.Bedazzled.ModifierSet
    for _,mod in pairs(UI._RegisteredModifiers) do
        local config = UI.Hooks.GetModifierConfiguration:Throw({
            Modifier = mod,
            Config = nil,
        }).Config
        if config and mod.IsConfigurationValid(config) then
            configs[mod:GetClassName()] = config
        end
    end
    return configs
end

function UI:_Initialize()
    if self._Initialized then return end

    local uiObject = self:GetUI()

    local panelList = self:CreateElement("PanelList", "GenericUI_Element_HorizontalList")
    panelList:SetElementSpacing(-50)
    UI.PanelList = panelList

    local panel = panelList:AddChild("BG", "GenericUI_Element_Texture")
    panel:SetTexture(Textures.PANELS.CLIPBOARD_LARGE)
    UI.MainPanel = panel

    self.BACKGROUND_SIZE = panel:GetSize()
    self.FRAME_SIZE = V(self.BACKGROUND_SIZE[1] - 200, 500) -- Size of the settings list frame.
    self.SETTING_SIZE = V(self.FRAME_SIZE[1], 70)

    local headerLabel = UI.CreateText("TitleHeader", panel, Text.Format(Bedazzled.TranslatedStrings.GameTitle:GetString(), {Size = 42, Color = "7E72D6", FontType = Text.FONTS.ITALIC}), "Center", V(self.BACKGROUND_SIZE[1], 50))
    headerLabel:SetPositionRelativeToParent("Top", 0, 60)

    local settingsList = panel:AddChild("SettingsList", "GenericUI_Element_ScrollList")
    settingsList:SetFrame(self.FRAME_SIZE:unpack())
    settingsList:SetMouseWheelEnabled(true)
    UI.SettingsList = settingsList

    -- Render settings - TODO redo this on every Show()?
    UI.Events.RenderSettings:Throw()
    settingsList:SetPositionRelativeToParent("Top", 0, 200)

    local startButton = Button.Create(UI, "StartButton", panel, Button:GetStyle("GreenMedium"))
    startButton:SetLabel(CommonStrings.Start)
    startButton:SetPositionRelativeToParent("Bottom", 0, -44)

    -- Start a new game when the start button is pressed.
    startButton.Events.Pressed:Subscribe(function (_)
        UI.StartGame()
    end)

    UI._SetupHighScores()

    panelList:RepositionElements()
    uiObject.SysPanelSize = panelList:GetSize()

    self._Initialized = true
end

---Sets up the highscores panel.
function UI._SetupHighScores()
    local panel = UI.PanelList:AddChild("HighScoresPanel", "GenericUI_Element_Texture")
    panel:SetTexture(Textures.PANELS.LIST)
    panel:SetCenterInLists(true)

    local highscoresHeader = UI.CreateText("HighScoresHeader", panel, TSK.Label_HighScores:Format({Size = 23}), "Center", V(400, 50))
    highscoresHeader:SetPositionRelativeToParent("Top", 0, 100)

    local gamemodeLabel = TextPrefab.Create(UI, "HighScoresGamemodeSubtitle", panel, "", "Center", V(400, 50))
    gamemodeLabel:SetPositionRelativeToParent("Top", 0, 155)
    UI.GameModeLabel = gamemodeLabel

    local scoresList = panel:AddChild("HighScoresList", "GenericUI_Element_ScrollList")
    scoresList:SetFrame(300, 400)
    scoresList:SetElementSpacing(0)
    scoresList:SetPositionRelativeToParent("Top", 30, 215)
    UI.HighScoresList = scoresList
end

---Returns a string description of the currently-chosen gamemode and modifiers.
function UI._GetCurrentGameDescription()
    local gamemode = UI._GetCurrentGameMode()
    local modifierLabels = {} ---@type {ClassName:classname, Label:string}[]
    local mods = UI.GetModifierConfigs()
    for className,config in pairs(mods) do
        local class = Bedazzled:GetClass(className) ---@type Features.Bedazzled.Board.Modifier
        local description = class.StringifyConfiguration(config)
        table.insert(modifierLabels, {ClassName = className, Label = description})
    end

    -- Sort by class name
    table.sort(modifierLabels, function (a, b)
        return a.ClassName < b.ClassName
    end)

    -- Keep just the labels and concatenate them
    local labels = {gamemode} ---@type string[]
    for _,v in ipairs(modifierLabels) do
        table.insert(labels, v.Label)
    end
    return Text.Join(labels, ", ")
end

---Returns the currently-selected gamemode.
---@return Feature_Bedazzled_GameMode_ID
function UI._GetCurrentGameMode()
    return "Classic" -- TODO
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

-- Register modifiers and render/fetch their settings.
local Modifiers = {
    TimeLimit = Bedazzled:GetClass("Features.Bedazzled.Board.Modifiers.TimeLimit"),
    MoveLimit = Bedazzled:GetClass("Features.Bedazzled.Board.Modifiers.MoveLimit"),
}
local ModifierSettings = {
    TimeLimit_Time = Bedazzled:RegisterSetting("Modifiers.TimeLimit.Time", {
        Type = "ClampedNumber",
        Name = Modifiers.TimeLimit.Name,
        Description = Modifiers.TimeLimit.Description,
        Min = 0,
        Max = 60 * 30, -- 30 minutes.
        Step = 1,
        HideNumbers = false,
        DefaultValue = 0,
    }),
    MoveLimit_Moves = Bedazzled:RegisterSetting("Modifiers.MoveLimit.Moves", {
        Type = "ClampedNumber",
        Name = Modifiers.MoveLimit.Name,
        Description = Modifiers.MoveLimit.Description,
        Min = 0,
        Max = 100,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 0,
    }),
}
-- In order of rendering.
local SettingsOrder = {
    ModifierSettings.TimeLimit_Time,
    ModifierSettings.MoveLimit_Moves,
}
UI.Events.RenderSettings:Subscribe(function (_)
    for _,setting in ipairs(SettingsOrder) do
        SettingWidgets.RenderSetting(UI, UI.SettingsList, setting, UI.SETTING_SIZE, function (_)
            -- Update the highscores panel anytime modifiers are changed.
            UI.UpdateHighScoresPanel()
        end)
    end
end)
UI.Hooks.GetModifierConfiguration:Subscribe(function (ev)
    local mod = ev.Modifier
    local modClassName = mod:GetClassName()
    if modClassName == Modifiers.TimeLimit:GetClassName() then -- Time limit modifier
        local timeLimit = ModifierSettings.TimeLimit_Time:GetValue()
        if timeLimit > 0 then
            ---@type Features.Bedazzled.Board.Modifiers.TimeLimit.Config
            ev.Config = {
                TimeLimit = timeLimit,
            }
        end

    elseif modClassName == Modifiers.MoveLimit:GetClassName() then -- Move limit modifier
        local moveLimit = ModifierSettings.MoveLimit_Moves:GetValue()
        if moveLimit > 0 then
            ---@type Features.Bedazzled.Board.Modifiers.MoveLimit.Config
            ev.Config = {
                MoveLimit = moveLimit,
            }
        end
    end
end)
for _,mod in pairs(Modifiers) do
    UI.RegisterModifier(mod)
end

-- Start the game when the context menu option is selected.
Client.UI.ContextMenu.RegisterElementListener("epip_Feature_Bedazzled", "buttonPressed", function(_, _)
    UI:Show()
end)

-- Show the menu when a new game is requested.
Bedazzled.GameUI.Events.NewGameRequested:Subscribe(function (_)
    UI:Show()
    Bedazzled.GameUI:Hide()
end)

