
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