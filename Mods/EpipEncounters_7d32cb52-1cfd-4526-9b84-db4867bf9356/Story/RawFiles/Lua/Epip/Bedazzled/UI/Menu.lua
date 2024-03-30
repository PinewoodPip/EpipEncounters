
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local Button = Generic.GetPrefab("GenericUI_Prefab_Button")
local CloseButton = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local ValueLabelPrefab = Generic.GetPrefab("GenericUI.Prefabs.ValueLabel")
local SlicedTexture = Generic.GetPrefab("GenericUI.Prefabs.SlicedTexture")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local CommonStrings = Text.CommonStrings
local V = Vector.Create
local GameModes = {
    Classic = Bedazzled:GetClass("Features.Bedazzled.GameModes.Classic"),
    Twimstve = Bedazzled:GetClass("Features.Bedazzled.GameModes.Twimstve"),
}

---@class Features.Bedazzled.UI.Menu : GenericUI_Instance
local UI = Generic.Create("Features.Bedazzled.UI.Menu")
UI.EXPERIENCE_BAR_EMPTY_COLOR = Color.Create(Color.LARIAN.DARK_GRAY)
UI.EXPERIENCE_BAR_FILLED_COLOR = Color.Create(Bedazzled.LOGO_COLOR)
UI.EXPERIENCE_BAR_SIZE = V(350, 35)

---@type table<string, Features.Bedazzled.Board.Modifier>
UI._RegisteredModifiers = {}
UI._StatisticLabels = {} ---@type table<string, GenericUI.Prefabs.ValueLabel> Maps namespaced setting ID to prefab instance.

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
    }),
    Label_NoHighScores = Bedazzled:RegisterTranslatedString({
        Handle = "h828b925fg74e3g4ef5g83ecgc3577fd1e8df",
        Text = "No scores yet!",
        ContextDescription = [[Label for highscores panel, when there are not scores yet]],
    }),
    Label_Score = Bedazzled:RegisterTranslatedString({
        Handle = "h0d904d22g8e9ag4450gaf2dg8236ba3b865a",
        Text = "%d. %s pts",
        ContextDescription = [[Label for a score entry. Params are ranking and score. "pts" at the end is abbreviation for "points"]],
    }),
    Setting_GameMode_Name = Bedazzled:RegisterTranslatedString({
        Handle = "hc514c6a1g4fccg4d58g8d43g95ab5885182a",
        Text = "Game Mode",
        ContextDescription = "Setting name",
    }),
    Setting_GameMode_Description = Bedazzled:RegisterTranslatedString({
        Handle = "h79eeb20cg10b4g4b59ga41dg4e94623fd506",
        Text = "Determines the base rules of the game and default modifier settings.<br><br>- Classic: swap adjacent gems to create matches. The original experience.<br>- Twimst've: rotate groups of 2x2 gems to create matches. The washing machine experience.",
        ContextDescription = "Tooltip for game mode setting",
    }),
    Setting_RaidMechanics_Intensity_Name = Bedazzled:RegisterTranslatedString({
        Handle = "hde82ec74g19fcg4737g90b8g4b2ab8dd10ad",
        Text = "Raid Level",
        ContextDescription = [[Setting name for "Raid Mechanics" modifier intensity]],
    }),
    Setting_RaidMechanics_Intensity_Description = Bedazzled:RegisterTranslatedString({
        Handle = "hb54abc37gfadeg4ac4gbeccgaf652d4bf6e3",
        Text = "Enables MMO-style raid mechanics.<br>If >0, gems with MMO enrage timers will periodically appear with increasing frequency; if left unmatched, they will bring a fair and balanced instant game over.<br>Higher levels increase spawn frequency.",
        ContextDescription = [[Tooltip for "Raid Level" setting]],
    }),
    Setting_CementMixer_Intensity_Choice_Low = Bedazzled:RegisterTranslatedString({
        Handle = "hd2814793gdb4ag4ab1gb8b5g8bf25a06d5bb",
        Text = "Mild Load",
        ContextDescription = [[Choice for "Cement Mixing" modifier setting; "Load" is used as in "workload"]],
    }),
    Setting_CementMixer_Intensity_Choice_Medium = Bedazzled:RegisterTranslatedString({
        Handle = "h4b8d86eegf633g43cagb13ag375c003b00f2",
        Text = "Considerable Load",
        ContextDescription = [[Choice for "Cement Mixing" modifer setting; "Load" is used as in "workload"]],
    }),
    Setting_CementMixer_Intensity_Choice_High = Bedazzled:RegisterTranslatedString({
        Handle = "h37022247gea5fg479dg81dag3e5f5532f915",
        Text = "Huge Load",
        ContextDescription = [[Choice for "Cement Mixing" modifer setting; "Load" is used as in "workload"]],
    }),
}

UI.Events.RenderSettings = SubscribableEvent:New("RenderSettings") ---@type Event<Empty>
UI.Hooks.GetModifierConfiguration = SubscribableEvent:New("GetModifierConfiguration") ---@type Hook<{Modifier:Features.Bedazzled.Board.Modifier, Config:Features.Bedazzled.Board.Modifier.Configuration?}>

---------------------------------------------
-- SETTINGS
---------------------------------------------

Bedazzled.Settings.GameMode = Bedazzled:RegisterSetting("GameMode", {
    Type = "Choice",
    Context = "Client",
    NameHandle = TSK.Setting_GameMode_Name,
    DescriptionHandle = TSK.Setting_GameMode_Description,
    DefaultValue = GameModes.Classic:GetClassName(),
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = GameModes.Classic:GetClassName(), Name = GameModes.Classic:GetName()},
        {ID = GameModes.Twimstve:GetClassName(), Name = GameModes.Twimstve:GetName()},
    },
})
Bedazzled.Settings.LevelUpMessageQueued = Bedazzled:RegisterSetting("LevelUpMessageQueued", {
    Type = "Boolean",
    Name = TSK.Setting_Experience_Name,
    Description = TSK.Setting_Experience_Description,
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function UI:Show()
    self:_Initialize()

    -- Update the highscores panel; necessary for when player returns from a game with a new score set.
    UI.UpdateHighScoresPanel()
    UI._UpdateStatistics()
    UI._UpdateExperienceWidget()

    -- Show a congratulatory message if the user has leveled up since the last time they accessed the menu.
    if Bedazzled:GetSettingValue(Bedazzled.Settings.LevelUpMessageQueued) == true then
        Client.UI.MessageBox.Open({
            Header = Bedazzled.TranslatedStrings.MsgBox_LevelUp_Title:GetString(),
            Message = Bedazzled.TranslatedStrings.MsgBox_LevelUp_Body:Format({
                FormatArgs = {
                    Text.Format(Bedazzled.GetLevelTitle(), {Color = Bedazzled.LOGO_COLOR}),
                },
            }),
        })
        Bedazzled:SetSettingValue(Bedazzled.Settings.LevelUpMessageQueued, false)
    end

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
    local gameClass = Bedazzled:GetClass(UI._GetCurrentGameMode()) ---@cast gameClass Features.Bedazzled.GameMode
    local game = Bedazzled.CreateGame(gameClass:Create(V(8, 8)), modifiers) -- TODO extract
    Bedazzled.GameUI.Setup(game)
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

    -- Render scores
    if scores[1] then
        for i,score in ipairs(scores) do
            local label = TSK.Label_Score:Format({
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
    else
        local label = TSK.Label_NoHighScores:Format({
            Color = Color.BLACK,
        })
        TextPrefab.Create(UI, "HighScores_Empty", list, label, "Center", V(270, 32))
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

---Creates the static elements of the UI.
function UI:_Initialize()
    if self._Initialized then return end

    local uiObject = self:GetUI()

    local panelList = self:CreateElement("PanelList", "GenericUI_Element_HorizontalList")
    panelList:SetElementSpacing(-50)
    UI.PanelList = panelList

    local panel = panelList:AddChild("BG", "GenericUI_Element_Texture")
    panel:SetTexture(Textures.PANELS.CLIPBOARD)
    UI.MainPanel = panel

    self.BACKGROUND_SIZE = panel:GetSize()
    self.FRAME_SIZE = V(self.BACKGROUND_SIZE[1] - 160, 700) -- Size of the settings list frame.
    self.SETTING_SIZE = V(self.FRAME_SIZE[1], 70)

    local headerLabel = UI.CreateText("TitleHeader", panel, Text.Format(Bedazzled.TranslatedStrings.GameTitle:GetString(), {Size = 42, Color = Bedazzled.LOGO_COLOR, FontType = Text.FONTS.ITALIC}), "Center", V(self.BACKGROUND_SIZE[1], 50))
    headerLabel:SetPositionRelativeToParent("Top", 0, 70)

    local settingsList = panel:AddChild("SettingsList", "GenericUI_Element_ScrollList")
    settingsList:SetFrame(self.FRAME_SIZE:unpack())
    settingsList:SetMouseWheelEnabled(true)
    settingsList:SetScrollbarSpacing(-10)
    UI.SettingsList = settingsList

    -- Render gamemode setting
    SettingWidgets.RenderSetting(UI, settingsList, Bedazzled.Settings.GameMode, self.SETTING_SIZE, function (_)
        UI.UpdateHighScoresPanel()
    end)

    -- Render modifier settings - TODO redo this on every Show()?
    UI.Events.RenderSettings:Throw()
    settingsList:SetPositionRelativeToParent("Top", 10, 160)

    local startButton = Button.Create(UI, "StartButton", panel, Button:GetStyle("GreenMedium"))
    startButton:SetLabel(TSK.Label_Bedazzle)
    startButton:SetPositionRelativeToParent("Bottom", 0, -44)

    -- Start a new game when the start button is pressed.
    startButton.Events.Pressed:Subscribe(function (_)
        UI.StartGame()
    end)

    local closeButton = CloseButton.Create(UI, "CloseButton", panel)
    closeButton:SetPositionRelativeToParent("TopLeft", 51, 45)

    -- Track level-ups to queue congratulatory messages the next time the menu is accessed.
    Bedazzled.Events.LeveledUp:Subscribe(function (_)
        Bedazzled:SetSettingValue(Bedazzled.Settings.LevelUpMessageQueued, true)
    end)

    UI._SetupHighScores()
    UI._SetupStatistics()
    UI._SetupExperienceBar()

    panelList:RepositionElements()
    uiObject.SysPanelSize = panelList:GetSize()

    self._Initialized = true
end

---Sets up the highscores panel.
function UI._SetupHighScores()
    local panel = UI.PanelList:AddChild("HighScoresPanel", "GenericUI_Element_Texture")
    panel:SetTexture(Textures.PANELS.LIST)
    panel:SetCenterInLists(true)
    UI.HighScoresPanel = panel

    local highscoresHeader = UI.CreateText("HighScoresHeader", panel, TSK.Label_HighScores:Format({Size = 23, Color = Bedazzled.LOGO_COLOR}), "Center", V(400, 50))
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

---Sets up the statistics panel.
function UI._SetupStatistics()
    local panel = UI.HighScoresPanel -- Statistics are shown in the same panel as high-scores.
    local statisticsHeader = UI.CreateText("StatisticsHeader", panel, CommonStrings.Statistics:Format({Size = 23, Color = Bedazzled.LOGO_COLOR}), "Center", V(400, 50))
    statisticsHeader:SetPositionRelativeToParent("Top", 0, 380)

    local statsList = panel:AddChild("StatsList", "GenericUI_Element_ScrollList")
    statsList:SetFrame(400 - 42, 270)
    statsList:SetPositionRelativeToParent("TopLeft", 70, 490)
    UI.StatsList = statsList

    -- Create labels
    for _,setting in ipairs(Bedazzled.STATISTIC_SETTINGS) do
        -- These "settings" are for persistence only and not user-modifiable, thus we do not use SettingWidgets.
        local label = ValueLabelPrefab.Create(UI, "Stats." .. setting:GetNamespacedID(), statsList, V(345, 30), Text.Format(setting:GetName(), {Color = Color.BLACK}), "")
        label:SetTooltip("Simple", setting:GetDescription())

        UI._StatisticLabels[setting:GetNamespacedID()] = label
    end
    statsList:RepositionElements()
end

---Creates the experience/level widget.
function UI._SetupExperienceBar()
    local panel = UI.HighScoresPanel
    local size = V(430, 80)
    local widgetPanel = panel:AddChild("LevelWidget.Panel", "GenericUI_Element_TiledBackground")
    widgetPanel:SetBackground("Black", size:unpack())
    widgetPanel:SetAlpha(0)
    local pos = V(UI.StatsList:GetPosition())
    widgetPanel:SetPosition(26, pos[2] - size[2]) -- Position before the stats list.

    -- Level title.
    local titleLabel = UI.CreateText("LevelLabel", widgetPanel, "Temp", "Center", V(size[1], 40))
    titleLabel:SetPositionRelativeToParent("Top", 0, 0)
    UI.LevelTitleLabel = titleLabel

    -- XP bar background.
    local emptyBar = widgetPanel:AddChild("LevelWidget.EmptyBar", "GenericUI_Element_Color")
    emptyBar:SetSize(UI.EXPERIENCE_BAR_SIZE:unpack())
    emptyBar:SetColor(UI.EXPERIENCE_BAR_EMPTY_COLOR)
    emptyBar:SetPositionRelativeToParent("Bottom", 0, -12)
    UI.ExperienceBarBackground = emptyBar

    -- XP bar fill.
    local filledBar = emptyBar:AddChild("LevelWidget.FilledBar", "GenericUI_Element_Color")
    filledBar:SetColor(UI.EXPERIENCE_BAR_FILLED_COLOR)
    UI.FilledExperienceBar = filledBar

    -- XP requirement label.
    local xpRequirementLabel = UI.CreateText("LevelWidget.ExperienceLabel", emptyBar, "Placeholder", "Center", UI.EXPERIENCE_BAR_SIZE)
    xpRequirementLabel:SetSize(UI.EXPERIENCE_BAR_SIZE[1], xpRequirementLabel:GetLineHeight(1))
    xpRequirementLabel:SetPositionRelativeToParent("Center")
    UI.ExperienceLabel = xpRequirementLabel
end

---Updates the level title and experience bar.
function UI._UpdateExperienceWidget()
    local level = Bedazzled.GetLevel()

    -- Update title
    local levelLabel = UI.LevelTitleLabel
    levelLabel:SetText(Bedazzled.TranslatedStrings.Label_Rank:Format({
        FormatArgs = {level, Bedazzled.GetLevelTitle()},
        Color = Bedazzled.LOGO_COLOR,
        Size = 21,
    }))

    -- Update XP bar fill
    local xp = Bedazzled:GetSettingValue(Bedazzled.Settings.Experience)
    local xpForCurrentLevel = Bedazzled.GetTotalExperienceRequirementForLevel(level)
    local xpForNextLevel = Bedazzled.GetTotalExperienceRequirementForLevel(level + 1)
    local currentLevelXp = (xp - xpForCurrentLevel)
    local nextLevelXp = (xpForNextLevel - xpForCurrentLevel)
    local xpFraction = currentLevelXp / nextLevelXp
    UI.FilledExperienceBar:SetSize(UI.EXPERIENCE_BAR_SIZE[1] * xpFraction, UI.EXPERIENCE_BAR_SIZE[2])

    -- Update XP bar label
    UI.ExperienceLabel:SetText(Text.Format("%d / %d %s", {
        FormatArgs = {currentLevelXp, nextLevelXp, Bedazzled.TranslatedStrings.Elo},
    }))
    UI.ExperienceBarBackground:SetTooltip("Simple", Bedazzled.TranslatedStrings.Label_TotalElo:Format(xp))
end

---Updates the statistic labels.
function UI._UpdateStatistics()
    for _,setting in ipairs(Bedazzled.STATISTIC_SETTINGS) do
        local label = UI._StatisticLabels[setting:GetNamespacedID()]
        if label then
            local value = setting:GetValue()
            local valueLabel
            -- Format time played.
            if setting == Bedazzled.Settings.PlayTime then
                valueLabel = Text.FormatTime(value)
            else
                valueLabel = tostring(value)
            end
            label.ValueLabel:SetText(Text.Format(valueLabel, {
                Color = Color.BLACK,
            }))
        else
            UI:__LogWarning("A statistic setting was added post-init? This is not supported and will not display correctly.")
        end
    end
end

---Returns a string description of the currently-chosen gamemode and modifiers.
function UI._GetCurrentGameDescription()
    local gamemode = UI._GetCurrentGameModeClass()
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
    local labels = {gamemode:GetName()} ---@type string[]
    for _,v in ipairs(modifierLabels) do
        table.insert(labels, v.Label)
    end
    return Text.Join(labels, ", ")
end

---Returns the currently-selected gamemode.
---@return Feature_Bedazzled_GameMode_ID
function UI._GetCurrentGameMode()
    return Bedazzled.Settings.GameMode:GetValue()
end

---Returns the class of the currently-selected gamemode.
---@return Features.Bedazzled.GameMode
function UI._GetCurrentGameModeClass()
    return Bedazzled:GetClass(UI._GetCurrentGameMode())
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
        if stat.RuneLevel and stat.RuneLevel > 0 then
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
    RaidMechanics = Bedazzled:GetClass("Features.Bedazzled.Board.Modifiers.RaidMechanics"),
    HyenaMode = Bedazzled:GetClass("Features.Bedazzled.Board.Modifiers.HyenaMode"),
    CementMixer = Bedazzled:GetClass("Features.Bedazzled.Board.Modifiers.CementMixer"),
}
local ModifierSettings = {
    TimeLimit_Time = Bedazzled:RegisterSetting("Modifiers.TimeLimit.Time", {
        Type = "ClampedNumber",
        Name = Modifiers.TimeLimit.Name,
        Description = Modifiers.TimeLimit.Description,
        Min = 0,
        Max = 60 * 60, -- 1 hour.
        Step = 60, -- 1 minute.
        HideNumbers = false,
        DefaultValue = 0,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
        ValueFormatting = "Time", ---@type Features.SettingWidgets.ValueFormatting
    }),
    MoveLimit_Moves = Bedazzled:RegisterSetting("Modifiers.MoveLimit.Moves", {
        Type = "ClampedNumber",
        Name = Modifiers.MoveLimit.Name,
        Description = Modifiers.MoveLimit.Description,
        Min = 0,
        Max = 1000,
        Step = 10,
        HideNumbers = false,
        DefaultValue = 0,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    RaidMechanics_Intensity = Bedazzled:RegisterSetting("Modifiers.RaidMechanics.Intensity", {
        Type = "ClampedNumber",
        Name = TSK.Setting_RaidMechanics_Intensity_Name,
        Description = TSK.Setting_RaidMechanics_Intensity_Description,
        Min = 0,
        Max = Modifiers.RaidMechanics.MAX_INTENSITY,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 0,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    HyenaMode = Bedazzled:RegisterSetting("Modifiers.HyenaMode", {
        Type = "Boolean",
        Name = Modifiers.HyenaMode.Name,
        Description = Modifiers.HyenaMode.Description,
        DefaultValue = false,
    }),
    CementMixer_Intensity = Bedazzled:RegisterSetting("Modifiers.CementMixer.Intensity", {
        Type = "Choice",
        Name = Modifiers.CementMixer.Name,
        Description = Modifiers.CementMixer.Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = 1, NameHandle = CommonStrings.Off.Handle},
            {ID = 2, NameHandle = TSK.Setting_CementMixer_Intensity_Choice_Low.Handle},
            {ID = 3, NameHandle = TSK.Setting_CementMixer_Intensity_Choice_Medium.Handle},
            {ID = 4, NameHandle = TSK.Setting_CementMixer_Intensity_Choice_High.Handle},
        },
    }),
}
-- In order of rendering.
local SettingsOrder = {
    ModifierSettings.TimeLimit_Time,
    ModifierSettings.MoveLimit_Moves,
    ModifierSettings.RaidMechanics_Intensity,
    ModifierSettings.HyenaMode,
    ModifierSettings.CementMixer_Intensity,
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
    elseif modClassName == Modifiers.RaidMechanics:GetClassName() then -- Raid Mechanics modifier
        local intensity = ModifierSettings.RaidMechanics_Intensity:GetValue()
        if intensity > 0 then
            ---@type Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
            ev.Config = {
                Intensity = intensity,
            }
        end
    elseif modClassName == Modifiers.HyenaMode:GetClassName() then
        local enabled = ModifierSettings.HyenaMode:GetValue() == true
        if enabled then
            -- Hyena mode takes no parameters.
            ev.Config = {}
        end
    elseif modClassName == Modifiers.CementMixer:GetClassName() then
        local intensity = ModifierSettings.CementMixer_Intensity:GetValue()
        if intensity > 1 then
            ---@type Features.Bedazzled.Board.Modifiers.CementMixer.Config
            ev.Config = {
                Intensity = intensity - 1, -- The Choice setting doesn't like numeric IDs that don't start from 1, so we offset them.
            }
        end
    end
end)
for _,mod in pairs(Modifiers) do
    UI.RegisterModifier(mod)
end

-- Show the menu or resume the current game when the context menu option is selected.
Client.UI.ContextMenu.RegisterElementListener("epip_Feature_Bedazzled", "buttonPressed", function(_, _)
    if Bedazzled.GameUI:GetBoard() ~= nil and not Bedazzled.GameUI.IsGameEnded() then
        Bedazzled.GameUI:Show()
    else
        -- If the user is playing for the first time,
        -- skip the menu and go directly into a default-configuration game (Classic).
        if Bedazzled.Settings.GamesPlayed:GetValue() == 0 then
            UI.StartGame()
        else
            UI:Show()
        end
    end
end)

-- Return to the menu when a game is forfeited.
Bedazzled.GameUI.Events.GameForfeited:Subscribe(function (_)
    UI:Show()
end)

-- Show the menu when a new game is requested.
Bedazzled.GameUI.Events.NewGameRequested:Subscribe(function (_)
    UI:Show()
    Bedazzled.GameUI:Hide()
end)

