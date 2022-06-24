
---------------------------------------------
-- Hooks for the CharacterCreation UI, also used by the respec mirror.
-- Note that this UI only exists when it is being used. As such, the table
-- does not have a UI or Root property. You can use GetUI() and GetRoot() instead.
---------------------------------------------

CharacterCreation = {
    -- If your mod adds more presets, you should add them here,
    -- in the order they appear in Character Creation.
    -- This is used to pull up preset descriptions,
    -- as from the UI we can only get the index of the preset.
    PRESET_ORDER = {
        "Witch",
        "Battlemage",
        "Cleric",
        "Conjurer",
        "Enchanter",
        "Fighter",
        "Inquisitor",
        "Knight",
        "Metamorph",
        "Ranger",
        "Rogue",
        "Shadowblade",
        "Wizard",
        "Wayfarer",
    },

    -- If you wish to add descriptions to a preset, add them to this table,
    -- forllowing the example format.
    PRESET_DESCRIPTIONS = {
        -- Witch = {
        --     Name = "Witch",
        --     Description = "Trained in the summoning arts, a Conjurer calls forth aid to the battlefield with versatile totems as well as a powerful Fire Slug, and can reliably apply Dazzled III to befuddle their enemies.",
        --     Tooltip = "Test",
        -- },
        -- Conjurer = {
        --     Name = "Conjurer",
        --     Description = "Trained in the summoning arts, a Conjurer calls forth aid to the battlefield with versatile totems as well as a powerful Fire Slug, and can reliably apply Dazzled III to befuddle their enemies.",
        --     Tooltip = "Test",
        -- },
        -- Wizard = {
        --     Name = "Wizard",
        --     Description = "As a master of combat magic, a Wizard torments foes with heavy elemental damage and lasting afflictions, but lacks Tiered Effects to help their allies.",
        --     Tooltip = "Wizard",
        -- },
    },

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    UITypeID = Client.UI.Data.UITypes.characterCreation,
    SELECTOR_CONTENT_IDS = {
        ORIGIN = 0,
        PRESET = 1,
    },

    initialized = false,
    nextTooltipIsPresetTooltip = false,
}
Client.UI.CharacterCreation = CharacterCreation
setmetatable(CharacterCreation, {__index = Client.UI._BaseUITable})

---------------------------------------------
-- METHODS
---------------------------------------------

-- Returns true if the Character Creation UI currently exists.
function CharacterCreation.IsInCharacterCreation()
    return CharacterCreation:Exists()
end

-- Convert a 0-based index to the preset string ID, as defined in PRESET_ORDER.
function CharacterCreation.IndexToPreset(index)
    return CharacterCreation.PRESET_ORDER[index]
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

-- Sets the description for the current preset.
-- Pass nil to description to keep current.
function CharacterCreation.SetPresetDescription(description, visible, tooltip)
    local presetText = CharacterCreation:GetRoot(CharacterCreation).CCPanel_mc.pip_presetDescNew

    if description ~= nil then
        presetText.text.htmlText = string.format("<font face='Averia Serif' size='20'>%s</font>", description)

        presetText.tooltipString = tooltip or presetText.tooltipString
    end

    if visible ~= nil then
        presetText.visible = visible
    end
end

function CharacterCreation.HasAnyPresetDescriptionDefined()
    for i,data in pairs(CharacterCreation.PRESET_DESCRIPTIONS) do
        return true
    end
    return false
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

function HandleCharacterCreationUpdate(uiObj, panelIndex, description)
    local root = uiObj:GetRoot()
    local presetText = root.CCPanel_mc.pip_presetDescNew.text

    -- Ext.Print(presetText.defaultTextFormat.font)
    -- Ext.Print(root.CCPanel_mc.origins_mc.originSelector_mc.visualContentList.content_array[0].text_txt.defaultTextFormat.font)
    

    -- Selector ID 0 has the origin description as the first element in visualContentList - the contents below the selector
    -- local originDesc = root.CCPanel_mc.origins_mc.originSelector_mc.visualContentList.content_array[0].text_txt.htmlText

    local presetYOffset = -40

    root.CCPanel_mc.origins_mc.presetSelectorBorder_mc.visible = true
    root.CCPanel_mc.origins_mc.presetSelectorBorder_mc.y = 504 + presetYOffset
    root.CCPanel_mc.origins_mc.presetSelector_mc.title_txt.mouseEnabled = false

    root.CCPanel_mc.origins_mc.presetSelector_mc.y = 470 + presetYOffset
    root.CCPanel_mc.origins_mc.presetSelector_mc.title_txt.htmlText = ""
    
    presetText.height = 200 -- 150 default
    presetText.width = 350 -- 300 default
    presetText.x = 45 -- -150 default
    presetText.y = 575

    local class = root.CCPanel_mc.pip_presetDescNew
    presetText.multiLine = true
    presetText.wordWrap = true
    presetText.autoSize = "left"
    presetText.italic = true
    presetText.mouseEnabled = true
end

function onOptionSelect(uiObj, methodName, contentID, optionID, scrollingRightBool)
    -- Ext.Print(contentID) -- 0 is origins selector, 1 is preset selector
    -- Ext.Print(optionID)
    
    if contentID == CharacterCreation.SELECTOR_CONTENT_IDS.PRESET then
        Utilities.Hooks.FireEvent("UI_CharacterCreation", "PresetWasChanged", optionID)

        local preset = CharacterCreation.IndexToPreset(optionID)
        local data = CharacterCreation.PRESET_DESCRIPTIONS[preset]

        if data then
            CharacterCreation.SetPresetDescription(data.Description, true, data.Tooltip)
        else
            CharacterCreation.SetPresetDescription("", false, "")
        end
    elseif contentID == CharacterCreation.SELECTOR_CONTENT_IDS.ORIGIN then
        Utilities.Hooks.FireEvent("UI_CharacterCreation", "OriginWasChanged", optionID)
    end
end

-- TODO this is a mess man, clean it up
function onUpdateSkills(uiObj, methodName, param3)
    HandleCharacterCreationUpdate(uiObj, true)
end

function onSetDetailsBefore(uiObj, methodName, param3)
    HandleCharacterCreationUpdate(uiObj, false)
end

function onSetDetailsAfter(uiObj, methodName, param3)
    HandleCharacterCreationUpdate(uiObj, false)
end

function onSetPanel(uiObj, methodName, param3, num1, num2)
    HandleCharacterCreationUpdate(uiObj, param3)

    CharacterCreation.SetPresetDescription(nil, param3 == 0)
end

function onUpdateContent(uiObj, methodName, param3, flashArray1)
    if not CharacterCreation.initialized then

        -- Show a hint on setup, as we currently cannot retrieve the
        -- randomly-chosen preset. TODO
        if CharacterCreation.HasAnyPresetDescriptionDefined() then
            CharacterCreation.SetPresetDescription("Choose a preset to see a description of it here.", true)
        end

        CharacterCreation.initialized = true
    end
    
    HandleCharacterCreationUpdate(uiObj)
end

local function OnCreationDone(ui, method)
    Utilities.Hooks.FireEvent("CharacterCreation", "CreationFinished")
    Utilities.Hooks.FireEvent("CharacterCreation", "CreationExited")
end

local function OnCreationCancel(ui, method)
    Utilities.Hooks.FireEvent("CharacterCreation", "CreationCancelled")
    Utilities.Hooks.FireEvent("CharacterCreation", "CreationExited")
end

local function OnPresetTooltipRequest(ui, method, string, x, y, width, height, align)
    -- ui:ExternalInterfaceCall("showTooltip", string, x, y, width, height, align)

    local char = Client.GetCharacter()
    local handle = Ext.UI.HandleToDouble(char.Handle)
    local stat = Client.UI.Data.ENGINE_STATS.KARMA

    CharacterCreation.nextTooltipIsPresetTooltip = true
    ui:ExternalInterfaceCall("showStatTooltip", handle, stat, x, y, width, height, "left");
    CharacterCreation.nextTooltipIsPresetTooltip = false
end

local function OnStatTooltip(char, stat, tooltip)
    if not CharacterCreation.nextTooltipIsPresetTooltip then return nil end
    -- Ext.Dump(tooltip.Data)

    -- tooltip.Data = {
    --     {
    --         Type = "StatName",
    --         Label = "Conjurer",
    --     },
    --     {
    --         Type = "SkillDescription",
    --         Label = "<font size='19'>Trained in the summoning arts, a Conjurer calls forth aid to the battlefield with versatile totems as well as a powerful Fire Slug, and can reliably apply Dazzled III to befuddle their enemies.<br><br><font color='797980'>Dazzled III</font> requires 7 Harried:<br>Target has reduced accuracy, dodge, and is Blinded, reducing their vision to 3m.</font><br> ",
    --     },
    --     {
    --         Type = "StatsPointValue",
    --         Label = "Insert upside here",
    --     },
    --     {
    --         Type = "StatsTalentsMalus",
    --         Label = "Insert downside here",
    --     },
    -- }
end

---------------------------------------------
-- SETUP
---------------------------------------------
Ext.Events.SessionLoading:Subscribe(function()
    local id = CharacterCreation.UITypeID

    Ext.RegisterUITypeCall(id, "creationDone", OnCreationDone, "After")
    Ext.RegisterUITypeCall(id, "mainMenu", OnCreationCancel, "After")
    Ext.RegisterUITypeCall(id, "selectOption", onOptionSelect, "After")
    Ext.RegisterUITypeCall(id, "pipShowPresetTooltip", OnPresetTooltipRequest, "After")

    Ext.RegisterUITypeInvokeListener(id, "updateContent", onUpdateContent, "After")
    Ext.RegisterUITypeInvokeListener(id, "updateSkills", onUpdateSkills, "After")
    Ext.RegisterUITypeInvokeListener(id, "setDetails", onSetDetailsAfter, "After")
    Ext.RegisterUITypeInvokeListener(id, "setDetails", onSetDetailsBefore, "Before")
    Ext.RegisterUITypeInvokeListener(id, "setPanel", onSetPanel, "After")

    Game.Tooltip.RegisterListener("Stat", nil, OnStatTooltip)
end)