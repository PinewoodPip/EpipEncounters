
---------------------------------------------
-- General data related to UI.
-- UI-specific enums, etc. are located in the respective UIs's tables instead.
---------------------------------------------

Client.UI.Data = {
    Patterns = {},
    StringTemplates = {},
}
local Data = Client.UI.Data

---------------------------------------------
-- STATS
---------------------------------------------

-- IDs used to request stat tooltips for UIs.
-- TODO are these off?
Data.ENGINE_STATS = {
    STRENGTH = 0,
    FINESSE = 1,
    VITALITY = 12,
    INTELLIGENCE = 2,
    CONSTITUTION = 3,
    MEMORY = 4,
    WITS = 5,
    DAMAGE = 6,
    PHYSICAL_ARMOR = 7,
    MAGIC_ARMOR = 8,
    CRITICAL_CHANCE = 9,
    ACCURACY = 10,
    DODGING = 11,
    ACTION_POINTS = 13,
    SOURCE_POINTS = 14,
    REPUTATION = 15,
    KARMA = 16,
    SIGHT = 17,
    HEARING = 18,
    VISION_ANGLE = 19,
    MOVEMENT = 20,
    INITIATIVE = 21,
    BLOCK = 22,
    PIERCING_RESISTANCE = 23,
    PHYSICAL_RESISTANCE = 24,
    CORROSIVE_RESISTANCE = 25,
    MAGIC_RESISTANCE = 26,
    TENEBRIUM_RESISTANCE = 27,
    FIRE_RESISTANCE = 28,
    WATER_RESISTANCE = 29,
    EARTH_RESISTANCE = 30,
    AIR_RESISTANCE = 31,
    POISON_RESISTANCE = 32,
    CUSTOM_RESISTANCE = 33, -- No description whatsoever.
    WILLPOWER = 34,
    BODYBUILDING = 35,
    EXPERIENCE = 36,
    NEXT_LEVEL = 37,
    MAX_AP = 38,
    START_AP = 39,
    AP_RECOVERY = 40,
    MAX_WEIGHT = 41,
    MIN_DAMAGE = 42,
    MAX_DAMAGE = 43,
    LIFESTEAL = 44,
    GAIN = 45,
}

---------------------------------------------
-- MISC
---------------------------------------------

-- IDs of vanilla UIs.
Data.UITypes = {
    mods = 49,
    panelSelect_c = 83,
    actionProgression = 0,
    bottomBar_c = 59,
    characterCreation = 3,
    connectionMenu = 33,
    characterCreation_c = 4,
    characterSheet = 119,
    chatLog = 6,
    combatLog = 7,
    optionsSettings = 45,
    containerInventory = 37,
    contextMenu = 11,
    craftPanel_c = 84,
    dummyOverhead = 15,
    enemyHealthBar = 42,
    equipmentPanel_c = 64,
    examine = 104,
    examine_c = 67,
    fullScreenHUD = 100,
    gameMenu = 19,
    hotBar = 40,
    saving = 99,
    journal = 22,
    loadingScreen = 23,
    minimap = 30,
    mainMenu = 27,
    mods = 32,
    mouseIcon = 31,
    msgBox = 29,
    msgBox_c = 75,
    notification = 36,
    overhead = 5,
    partyInventory = 116,
    partyInventory_c = 142,
    partyManagement_c = 82,
    playerInfo = 38,
    reward_c = 137,
    skills = 41,
    statsPanel_c = 63,
    statusConsole = 117,
    textDisplay = 43,
    tooltip = 44,
    trade = 46,
    trade_c = 73,
    tutorialBox = 55,
    uiCraft = 102,
    uiFade = 16,
    worldTooltip = 48,
    giftBagsMenu = 146,
    giftBagContent = 147,
    optionsInput = 13,
    playerInfo_controller = 61,
}