
-- Important lessons learnt:
-- You cannot have mouse listeners on shapes, need to use sprites
-- Depth 0 elements have 0 width/height

---@class VanityUI : UI
local Vanity = {
    Position = {0, 0},

    visible = true,
    openCategories = {},
    TABS = {},
    currentSlot = "Helmet",
    currentTab = nil,
    currentItemTemplateOverride = nil,
    oldContentHeight = 0,
    oldScrollY = 0,
    racialCategories = {},

    ---@type table<string,VanityTemplate>
    TEMPLATES = {},
    CATEGORIES = {
        Favorites = {
            Name = "Favorites",
            Tags = {},
        },
        Classed = {
            Name = "Classed",
            Tags = {
                Battlemage = true,
                Enchanter = true,
                Inquisitor = true,
                Ranger = true,
                Rogue = true,
                Shadowblade = true,
                Wayfarer = true,
                Witch = true,
            },
        },
        Platemail = {
            Name = "Platemail",
            Tags = {Platemail = true,}
        },
        Scalemail = {
            Name = "Scalemail",
            Tags = {Scalemail = true,}
        },
        Leather = {
            Name = "Leather",
            Tags = {Leather = true,}
        },
        Mage = {
            Name = "Mage",
            Tags = {Mage = true,}
        },
        Common = {
            Name = "Common",
            Slots = ARMOR_SLOTS,
            Tags = {Common = true, Tool = true, Starter = true,}
        },

        -- WEAPONS
        OneHandedSwords = {
            Name = "One-Handed Swords",
            Slots = {Weapon = true}, -- Slot restriction.
            Tags = {Sword = true, ["1H"] = true},
            RequireAllTags = true,
        },
        TwoHandedSwords = {
            Name = "Two-Handed Swords",
            Slots = {Weapon = true},
            Tags = {Sword = true, ["2H"] = true},
            RequireAllTags = true,
        },
        OneHandedAxes = {
            Name = "One-Handed Axes",
            Slots = {Weapon = true}, -- Slot restriction.
            Tags = {Axe = true, ["1H"] = true},
            RequireAllTags = true,
        },
        TwoHandedAxes = {
            Name = "Two-Handed Axes",
            Slots = {Weapon = true},
            Tags = {Axe = true, ["2H"] = true},
            RequireAllTags = true,
        },
        OneHandedMaces = {
            Name = "One-Handed Maces",
            Slots = {Weapon = true}, -- Slot restriction.
            Tags = {Mace = true, ["1H"] = true},
            RequireAllTags = true,
        },
        TwoHandedMaces = {
            Name = "Two-Handed Maces",
            Slots = {Weapon = true},
            Tags = {Mace = true, ["2H"] = true},
            RequireAllTags = true,
        },
        Staves = {
            Name = "Staves",
            Slots = {Weapon = true},
            Tags = {Staff = true},
        },
        Spears = {
            Name = "Spears",
            Slots = {Weapon = true},
            Tags = {Spear = true},
        },
        Bows = {
            Name = "Bows",
            Slots = {Weapon = true},
            Tags = {Bow = true},
        },
        Crossbows = {
            Name = "Crossbows",
            Slots = {Weapon = true},
            Tags = {Crossbow = true},
        },
        Daggers = {
            Name = "Daggers",
            Slots = {Weapon = true},
            Tags = {Dagger = true},
        },
        Wands = {
            Name = "Wands",
            Slots = {Weapon = true},
            Tags = {Wand = true},
        },
        Shields = {
            Name = "Shields",
            Slots = {Weapon = true},
            Tags = {Shield = true},
        },
        
        Other = {
            Name = "Other",
            Tags = {
                REF = true,
                Unique = true,
                Other = true, -- Fallback tag for items with 0 tags
            },
        },
    },

    CATEGORY_ORDER = {
        "Favorites",
        "Classed",
        "Platemail",
        "Scalemail",
        "Leather",
        "Mage",
        "Common",

        "OneHandedSwords",
        "TwoHandedSwords",
        "OneHandedAxes",
        "TwoHandedAxes",
        "OneHandedMaces",
        "TwoHandedMaces",
        "Staves",
        "Spears",
        "Bows",
        "Crossbows",
        "Daggers",
        "Wands",
        "Shields",

        "Other",
    },

    -- Tags given to templates automatically through
    -- a word match from their name.
    -- Templates may end up in multiple categories
    -- if they match multiple of these.
    -- Mapping is pattern -> Tag.
    TEMPLATE_NAME_TAGS = {
        -- Elves = "Elven",
        -- Elf = "Elven",
        -- Humans = "Human",
        -- Dwarves = "Dwarven",
        -- Dwarf = "Dwarven",
        -- Lizard = "Lizard",
        -- Lizards = "Lizard",
        Chainmail = "Chainmail",
        Leather = "Leather",
        Mage = "Mage",
        Robe = "Mage",
        Platemail = "Platemail",
        Scalemail = "Scalemail",
        StarterArmor = "Starter",

        -- CHARACTER CREATION
        Ranger = "Ranger",
        Rogue = "Rogue",
        Battlemage = "Battlemage",
        Shadowblade = "Shadowblade",
        Enchanter = "Enchanter",
        Inquisitor = "Inquisitor",
        Wayfarer = "Wayfarer",
        Witch = "Witch",

        Common = "Common",
        Civilian = "Common",
        Broom = "Common",
        Bucket = "Common", -- lol
        Tool = "Common",
        FUR = "Common",
        TOOL = "Common",
        Unique = "Unique",
        REF = "Reference",

        -- Weapons
        Sword = "Sword",
        Axe = "Axe",
        Mace = "Mace",
        Shield = "Shield",
        Dagger = "Dagger",
        Staff = "Staff",
        Spear = "Spear",
        Pitchfork = "Spear", -- lol
        Pickaxe = "Mace",
        Bow = "Bow",
        Crossbow = "Crossbow",
        Wand = "Wand",
        ["2H"] = "2H",
        ["1H"] = "1H",
    },

    -- The race/gender combo each visual slot in the root lsx corresponds to.
    SLOT_TO_RACE_GENDER = {
        {Race = "Human", Gender = "Male", LifeType = "Living"},
        {Race = "Human", Gender = "Female", LifeType = "Living"},
        {Race = "Dwarf", Gender = "Male", LifeType = "Living"},
        {Race = "Dwarf", Gender = "Female", LifeType = "Living"},
        {Race = "Elf", Gender = "Male", LifeType = "Living"},
        {Race = "Elf", Gender = "Female", LifeType = "Living"},
        {Race = "Lizard", Gender = "Male", LifeType = "Living"},
        {Race = "Lizard", Gender = "Female", LifeType = "Living"},

        {Race = "?", Gender = "?", LifeType = "?"},
        
        {Race = "Undead_Human", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Human", Gender = "Female", LifeType = "Undead"},
        {Race = "Undead_Dwarf", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Dwarf", Gender = "Female", LifeType = "Undead"},
        {Race = "Undead_Elf", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Elf", Gender = "Female", LifeType = "Undead"},
        {Race = "Undead_Lizard", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Lizard", Gender = "Female", LifeType = "Undead"},
    },

    SLOT_TO_DB_INDEX = {
        Helmet = 1,
        Breast = 2,
        Gloves = 3,
        Leggings = 4,
        Boots = 5,
        Weapon = 6,
        Shield = 7,
    },

    -- Patterns to replace within root template names
    -- to create a display name.
    ROOT_NAME_REPLACEMENTS = {
        ["EQ_Armor"] = "",
        ["EQ_"] = "",
        ["Elves"] = "Elven",
        ["WPN_"] = "",
        ["TOOL_"] = "",
        ["FUR_"] = "",
        ["Tool_"] = "",
        ["Clothing_"] = "",
        ["Maj_"] = "",
        ["ARM_UNIQUE_ARX"] = "", -- Fuck this one, screws the pascalcase pattern

        -- Actual keywords
        ["Upperbody"] = "Chest",
        ["UpperBody"] = "Chest",
        ["LowerBody"] = "Leggings",
        ["Lowerbody"] = "Leggings",
    },

    PERSISTENT_OUTFIT_TAG = "PIP_VANITY_PERSISTENT_OUTFIT",
    PERSISTENT_WEAPONRY_TAG = "PIP_VANITY_PERSISTENT_WEAPONRY",

    ARMOR_SLOTS = {
        Helmet = true,
        Breast = true,
        Gloves = true,
        Leggings = true,
        Boots = true,
    },

    WEAPON_SLOTS = {
        Weapon = true,
        Shield = true,
    },

    ENTRY_WIDTH = 250,
    HEADER_ENTRY_WIDTH = 240,
    ID = "PIP_Vanity",
    INPUT_DEVICE = "KeyboardMouse",
    PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/Vanity.swf",
    CURRENT_SAVE_VERSION = 4,
    SAVE_FILENAME = "EPIP_VanityOutfits.json",

    Events = {
        ---@type VanityUI_Event_EntryClicked
        EntryClicked = {},
        ---@type VanityUI_Event_EntryRemoved
        EntryRemoved = {},
        ---@type VanityUI_Event_SaveDataLoaded
        SaveDataLoaded = {},
        ---@type VanityUI_Event_ButtonPressed
        ButtonPressed = {},
        ---@type VanityUI_Event_EntryFavoriteToggled
        EntryFavoriteToggled = {},
        ---@type VanityUI_Event_TabButtonPressed
        TabButtonPressed = {},
        ---@type VanityUI_Event_SliderHandleReleased
        SliderHandleReleased = {},
        ---@type VanityUI_Event_CopyPressed
        CopyPressed = {},
        ---@type VanityUI_Event_PastePressed
        PastePressed = {},
        ---@type VanityUI_Event_InputChanged
        InputChanged = {},
        ---@type VanityUI_Event_CheckboxPressed
        CheckboxPressed = {},
        AppearanceReapplied = {Legacy = false}, ---@type Event<VanityUI_Event_AppearanceRefreshed>
    },
    Hooks = {
        ---@type VanityUI_Hook_GetEntryLabel
        GetEntryLabel = {},
        ---@type VanityUI_Hook_GetLabelColor
        GetLabelColor = {},
        ---@type VanityUI_Hook_GetSaveData
        GetSaveData = {},
    },
}
Epip.InitializeUI(nil, "Vanity", Vanity)

---------------------------------------------
-- EVENTS / HOOKS
---------------------------------------------

---@class VanityUI_Event_AppearanceRefreshed

---@class VanityUI_Event_EntryClicked : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string)

---@class VanityUI_Event_EntryRemoved : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string)

---@class VanityUI_Event_EntryFavoriteToggled : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string, active:boolean))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string, active:boolean)

---@class VanityUI_Event_SliderHandleReleased : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string, value:number))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string, value:number)

---@class VanityUI_Event_SaveDataLoaded : Event
---@field RegisterListener fun(self, listener:fun(data:table))
---@field Fire fun(self, data:table)

---@class VanityUI_Event_TabButtonPressed : Event
---@field RegisterListener fun(self, listener:fun(id:string))
---@field Fire fun(self, id:string)

---@class VanityUI_Event_CopyPressed : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string, text:string))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string, text:string)

---@class VanityUI_Event_CheckboxPressed : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string, state:boolean))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string, state:boolean)

---@class VanityUI_Event_PastePressed : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string)

---@class VanityUI_Event_InputChanged : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string, text:string))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string, text:string)

---@class VanityUI_Event_ButtonPressed : Event
---@field RegisterListener fun(self, listener:fun(tab:CharacterSheetCustomTab, id:string))
---@field Fire fun(self, tab:CharacterSheetCustomTab, id:string)

---@class VanityUI_Hook_GetSaveData : Hook
---@field RegisterHook fun(self, handler:fun(data:table))
---@field Return fun(self, data:table)

---@class VanityUI_Hook_GetEntryLabel : Hook
---@field RegisterHook fun(self, handler:fun(text:string, tab:CharacterSheetCustomTab, entryID:string))
---@field Return fun(self, text:string, tab:CharacterSheetCustomTab, entryID:string)

---@class VanityUI_Hook_GetLabelColor : Hook
---@field RegisterHook fun(self, handler:fun(color:string, label:string, tab:CharacterSheetCustomTab, entryID:string))
---@field Return fun(self, color:string, label:string, tab:CharacterSheetCustomTab, entryID:string)

for id,data in pairs(Vanity.CATEGORIES) do
    data.ID = id
end

---@class VanityCategoryQuery
---@field Data VanityCategory
---@field Templates VanityTemplate[]

---@class VanityOutfit
---@field Name string
---@field Race Race
---@field Gender Gender
---@field Templates table<string,string>
---@field Dyes table<string,string>

---@type CharacterSheetUI
local CharacterSheet = Client.UI.CharacterSheet

---------------------------------------------
-- METHODS
---------------------------------------------

function Vanity:GetUI()
    return Ext.UI.GetByName(self.ID)
end

function Vanity:GetRoot()
    return self:GetUI():GetRoot()
end

function Vanity.Toggle(state)
    if state ~= nil then
        Vanity.visible = state
    else
        Vanity.visible = not Vanity.visible
    end
end

function Vanity:IsVisible()
    return self.visible
end

function Vanity.GetMenu()
    return Vanity:GetRoot().menu_mc
end

function Vanity.SetHeader(text)
    -- text = "<font color='#ffffff' size='20'><b>" .. text .. "</b></font>"

    local menu = Vanity.GetMenu()
    menu.setHeader(text)
    -- header.htmlText = text
end

Net.RegisterListener("EPIPENCOUNTERS_Vanity_SetTemplateOverride", function(payload)
    Vanity.currentItemTemplateOverride = payload.TemplateOverride
    Vanity.Refresh()
end)

function Vanity.Refresh()
    if Vanity.visible then
        Vanity.Setup(Vanity.currentTab)
    end
end

---@param slot StatsItemSlot|EclItem
function Vanity.SetSlot(slot)
    if type(slot) ~= "string" then slot = Item.GetEquippedSlot(slot) or Item.GetItemSlot(slot) end

    Vanity.currentSlot = slot
    Vanity.Refresh()
end

function Vanity.GetCurrentItem()
    return Ext.GetItem(Client.GetCharacter():GetItemBySlot(Vanity.currentSlot))
end

---Refreshes the appearance of visuals on the active char by toggling their helmet preference (for character sheet) and applying a polymorph status (for world model). Credits to Luxen for the discovery!
---@param useAltStatus boolean
function Vanity.RefreshAppearance(useAltStatus)
    local char = Client.GetCharacter()

    Net.PostToServer("EPIPENCOUNTERS_Vanity_RefreshAppearance", {
        CharacterNetID = char.NetID,
        UseAltStatus = useAltStatus
    })

    Timer.Start(0.4, function(_)
        Vanity.Events.AppearanceReapplied:Throw({})
    end)
end

---------------------------------------------
-- INTERNAL METHODS
---------------------------------------------

function Vanity.SaveData(path)
    local save = {
        Version = Vanity.CURRENT_SAVE_VERSION,
    }
    path = path or Vanity.SAVE_FILENAME

    save = Vanity.Hooks.GetSaveData:Return(save)

    IO.SaveFile(path, save)
end

function Vanity.LoadData(path)
    path = path or Vanity.SAVE_FILENAME
    local save = IO.LoadFile(path)

    Vanity.Events.SaveDataLoaded:Fire(save)
end

function Vanity.Cleanup()
    local root = Vanity:GetRoot()
    local scrollbar = root.menu_mc.list.m_scrollbar_mc

    Vanity.oldContentHeight = Vanity:GetRoot().menu_mc.list.containerContent_mc.height
    Vanity.oldScrollY = scrollbar.m_scrolledY

    root.menu_mc.clearEntries()

    Vanity.currentTab = nil

    Vanity.Toggle(false)

    -- Tab buttons
    local tabs = root.menu_mc.tabButtons_mc;

    tabs.clearButtons();

    Vanity.currentTab = nil
    Vanity.TogglePointsWarning(true)
end

function Vanity.IsCategoryOpen(categoryID)
    return Vanity:ReturnFromHooks("IsCategoryOpen", Vanity.openCategories[categoryID], categoryID)
end

---@param tab CharacterSheetCustomTab
function Vanity.Setup(tab, ...)
    Vanity.Cleanup()

    CharacterSheet:GetUI():Show()

    Vanity.currentTab = tab
    Vanity.SetHeader(tab.Name)
    tab:Render()

    -- tab buttons
    for _,registeredTab in ipairs(Vanity.TABS) do
        Vanity.AddTabButton(registeredTab.ID, registeredTab.Name, registeredTab.Icon, registeredTab.ID == tab.ID)
    end

    Vanity.GetMenu().list.positionElements()

    -- Deselect character sheet tabs
    local sheetRoot = Client.UI.CharacterSheet:GetRoot()
    local list = sheetRoot.stats_mc.tabsList

    for i=0,#list.content_array-1,1 do
        local button = list.content_array[i]

        button.setActive(false)
    end

    list = Vanity.GetMenu().list
    for i=0,#list.content_array-1,1 do
        local element = list.content_array[i]

        -- if element.CENTER_IN_LIST then
        --     local width = element.width
        --     if element.widthOverride then
        --         width = element.widthOverride
        --     end
        --     element.x = list.m_sideSpacing + (298/2) - (width/2) - 20
        -- end
        if element.SIDE_OFFSET then
            element.x = element.x + element.SIDE_OFFSET
        end
    end

    -- Try to restore scroll position
    local scrollbar = Vanity:GetRoot().menu_mc.list.m_scrollbar_mc
    if Vanity.oldContentHeight > 0 then
        local contentHeight = Vanity:GetRoot().menu_mc.list.containerContent_mc.height

        Vanity:DebugLog("Scrolling to " .. Vanity.oldScrollY)
        Vanity:DebugLog("Heights: " .. Vanity.oldContentHeight .. " " .. contentHeight)

        local delta = Vanity.oldContentHeight / contentHeight
        local mult = 1

        mult = mult * delta

        if delta < 0 then
            -- Kamil maybe we should figure out where these magic numbers come from...
            -- must be related to bounds of content
            Vanity.oldScrollY = Vanity.oldScrollY * 1.07
        end

        scrollbar.scrollTo(Vanity.oldScrollY * mult)
    end

    Vanity.Toggle(CharacterSheet:GetRoot().visible)
end

function Vanity.AddTabButton(id, tooltipText, icon, isActive)
    local tabs = Vanity:GetRoot().menu_mc.tabButtons_mc

    tabs.addButton(id)

    local buttons = tabs.list.content_array
    local button = buttons[#buttons - 1]

    button.setActive(isActive)

    button.iggyIcon.x = 23
    button.iggyIcon.y = 7
    button.tooltip = tooltipText

    Vanity:GetUI():SetCustomIcon("pip_tabButton_" .. id, icon, 32, 32)
end

function Vanity.RenderItemDropdown()
    local itemSlot = Vanity.currentSlot
    local dropdownIndex = 1

    local slotOptions = {}

    for i,v in ipairs(Data.Game.SLOTS_WITH_VISUALS) do
        table.insert(slotOptions, v)
        if v == itemSlot then
            dropdownIndex = i
        end
    end

    Vanity.RenderDropdown("TransmogItemSlot", slotOptions, dropdownIndex)
end

---@return boolean
function Vanity.IsOpen()
    return Vanity.visible
end

function Vanity.GetMenu()
    return Vanity:GetRoot().menu_mc
end

local function setupButton(button)
    button.CENTER_IN_LIST = true

    button.heightOverride = 40
end

function Vanity.RenderButtonPair(id1, text1, enabled1, id2, text2, enabled2)
    local menu = Vanity.GetMenu()
    local list = menu.list.content_array

    menu.addDualButtons(id1, text1, enabled1, id2, text2, enabled2)
    
    local buttonList = list[#list - 1]
    buttonList.EL_SPACING = -2
    buttonList.CENTER_IN_LIST = true
    buttonList.scaleX = 0.9 -- TODO
    buttonList.positionElements()
end

function Vanity.RenderButton(id, text, enabled)
    local menu = Vanity.GetMenu()
    enabled = enabled or true -- TODO

    menu.addButton(id, text, enabled)

    local list = menu.list.content_array
    local button = list[#list-1]
    setupButton(button)
end

function Vanity.RenderSlider(id, value, min, max, step, label, tooltip)
    local menu = Vanity.GetMenu()
    label = label or ""

    menu.addSlider(id, min, max, value, step, label, tooltip)

    local list = menu.list.content_array
    local button = list[#list-1]

    button.sideOffset = -360
    button.scaleX = 0.75
    button.scaleY = 0.75
    button.formHL_mc.alpha = 0
    button.slider_mc.m_handle_mc.stop()
    button.slider_mc.m_bg_mc.stop()

    button.heightOverride = 32
end

function Vanity.GetLastElement()
    local list = Vanity.GetMenu().list.content_array
    local element = list[#list-1]

    return element
end

function Vanity.RenderCheckbox(id, text, active, enabled)
    local menu = Vanity.GetMenu()

    if enabled == nil then
        enabled = true
    end

    menu.addCheckbox(id, text, active, enabled)

    local list = menu.list.content_array
    local checkbox = list[#list-1]
    -- checkbox.scaleX = 0.3
    checkbox.label_txt.width = 230
    checkbox.enable = true
    checkbox.heightOverride = 50
end

function Vanity.RenderText(id, text)
    local menu = Vanity.GetMenu()

    menu.addText(id, text)

    local list = menu.list.content_array
    local button = list[#list-1]

    -- button.heightOverride = 30
    button.text_txt.autoSize = "left"
    button.text_txt.wordWrap = true
    -- button.text_txt.align = "left"
    -- button.CENTER_IN_LIST = true
    button.text_txt.htmlText = "<font color='000000'>" .. button.text_txt.htmlText .. "</font>"
    button.text_txt.width = 298 - 10
    -- button.widthOverride = 400
end

function Vanity.SetupColorIcon(element)
    element.icon_mc.scaleX = 0.8
    element.icon_mc.scaleY = element.icon_mc.scaleX
    element.icon_mc.x = 3
    element.icon_mc.y = 3

end

function Vanity.RenderLabelledColor(id, color, label, showInputField)
    local menu = Vanity.GetMenu()
    if showInputField == nil then showInputField = false end
    
    menu.addLabelledColor(id, color, label, showInputField)

    local list = menu.list.content_array
    local element = list[#list-1]
    local input = element.inputField_mc

    element.text_mc.text_txt.autoSize = "left"
    -- element.text_mc.text_txt.width = element.text_mc.text_txt.width - 80
    Vanity.SetupColorIcon(element.color_mc)
    element.text_mc.x = 31
    element.text_mc.y = 13
    element.color_mc.y = 11
    element.text_mc.mouseEnabled = false
    element.heightOverride = element.height + 3

    input.copy_mc.x = 210
    input.paste_mc.x = input.copy_mc.x + 32
    input.paste_mc.visible = true

    input.input_txt.width = 90
    input.input_txt.x = input.copy_mc.x - input.input_txt.width
    input.bg_mc.width = input.input_txt.width
    input.bg_mc.height = input.input_txt.height
    input.bg_mc.x = input.input_txt.x
    input.bg_mc.y = input.input_txt.y

    input.input_txt.maxChars = 7
    input.input_txt.restrict = "a-fA-F0-9#"
end

function Vanity.SetColorLabel(id, color, label, input, forceUpdate)
    local menu = Vanity.GetMenu()

    menu.setColorLabel(id, color, label, input, forceUpdate)
end

function Vanity.RenderDropdown(id, options, selectedIndex)
    local menu = Vanity.GetMenu()
    selectedIndex = selectedIndex or 1

    menu.addCombo(id)

    for _,optionName in ipairs(options) do
        menu.addComboOption(id, optionName)
    end

    local list = menu.list.content_array
    local combo = list[#list-1]

    combo.selectedIndex = selectedIndex - 1
    combo.heightOverride = 50
end

function Vanity.GetTemplateInSlot(char, slot)
    local item = char:GetItemBySlot(slot)
    local template = ""

    if item then
        template = Ext.GetItem(item).RootTemplate.Id
    end

    return template
end

function Vanity.RenderEntry(id, text, canCollapse, active, canFavorite, favorited, iggyIcon, canRemove, colors)
    local menu = Vanity.GetMenu()
    canFavorite = canFavorite or false
    favorited = favorited or false
    if canRemove == nil then canRemove = false end

    text = Text.Format(text, {
        Color = Vanity.Hooks.GetLabelColor:Return("453b2b", text, Vanity.currentTab, id),
    })
    text = Vanity.Hooks.GetEntryLabel:Return(text, Vanity.currentTab, id)

    menu.addEntry(id, text, canCollapse, active, canFavorite, favorited)

    local list = menu.list.content_array
    local element = list[#list-1]
    element.heightOverride = element.hit_mc.height
    element.hl_mc.visible = false

    local minusBtn = element.minusBtn_mc
    minusBtn.x = 250
    minusBtn.y = 3
    element.setMinusButtonVisible(canRemove)

    if colors then
        element.setColorsVisible(true)

        local colorList = element.colorList
        colorList.y = 2
        colorList.x = 190
        colorList.scaleX = 0.7
        colorList.scaleY = 0.7
        colorList.mouseChildren = false
        colorList.mouseEnabled = false

        Vanity.SetupColorIcon(colorList.content_array[0])
        Vanity.SetupColorIcon(colorList.content_array[1])
        Vanity.SetupColorIcon(colorList.content_array[2])
        
        element.setColor(0, colors[1]:ToDecimal())
        element.setColor(1, colors[2]:ToDecimal())
        element.setColor(2, colors[3]:ToDecimal())

        if canRemove then
            element.minusBtn_mc.x = colorList.x + colorList.width - element.minusBtn_mc.width
            colorList.x = colorList.x - 5 - element.minusBtn_mc.width
        end
    else
        element.setColorsVisible(false)
    end

    if canCollapse then
        element.hl_mc.width = Vanity.HEADER_ENTRY_WIDTH
        element.heightOverride = element.border_mc.height + 2

        element.collapse_mc.y = 13
        element.collapse_mc.x = 9

        element.hl_mc.x = 10
        element.hl_mc.y = 9
        element.text_txt.x = 25
        element.text_txt.y = 7.5

        element.border_mc.width = element.border_mc.width - 20
        element.border_mc.x = -20

        if active then
            element.collapse_mc.x = 25
        end
    else
        element.hl_mc.width = Vanity.ENTRY_WIDTH
        element.text_txt.autoSize = "left"
        element.text_txt.width = 250
    end

    if canFavorite then
        element.favoriteButton_mc.x = 240
    end

    element.text_txt.width = element.hl_mc.width

    element.hit_mc.alpha = 0
    element.hit_mc.width = element.hl_mc.width
    element.hit_mc.height = element.hl_mc.height
    element.hit_mc.x = element.hl_mc.x
    element.hit_mc.y = element.hl_mc.y
    element.hit_mc.mouseEnabled = true

    if iggyIcon then
        element.addIggyIcon(iggyIcon, 0x00ffff)
        Vanity:GetUI():SetCustomIcon(iggyIcon, iggyIcon, 24, 24)

        element.text_txt.x = element.text_txt.x + 24

        -- TODO
        -- element.addDyeIcon(0x753e3e)
        -- element.dyeIcon.width = 24
        -- element.dyeIcon.height = 24
    end
end

function Vanity.SetPosition(x, y)
    local ui = Vanity:GetUI()

    Vanity:GetUI():SetPosition(x, y)

    Vanity.Position = {x, y}
end

-- Auto-generate some tags from template name.
Vanity:RegisterHook("GenerateTemplateTags", function(tags, template, data)
    template = Ext.Template.GetTemplate(template)

    -- Only auto-tag templates from Shared
    if data.Mod == "Shared" then
        local tagCount = 0
        for pattern,tag in pairs(Vanity.TEMPLATE_NAME_TAGS) do
            if string.match(template.Name, pattern) then
                tags[tag] = true
                tagCount = tagCount + 1
            end
        end
    
        -- Fallback tag for items with 0 tags
        if tagCount == 0 and data.Mod == "Shared" then
            Vanity:DebugLog("Template with no thematic tags generated: " .. template.Name .. " " .. template.Id)
            -- Ext.Dump(data) -- TODO filter out

            tags = {Other = true}
        end
    end

    -- Add race/gender tags for all mods
    for i,visual in ipairs(data.Visuals) do
        if visual ~= "" then
            tags[Vanity.SLOT_TO_RACE_GENDER[i].Race] = true
            tags[Vanity.SLOT_TO_RACE_GENDER[i].Gender] = true
        end
    end

    if data.Mod then
        tags[data.Mod] = true
    end

    return tags
end)

-- Remove underscores and replace some common words to create
-- somewhat readable and coherent names for the context menus.
Vanity:RegisterHook("GenerateTemplateName", function(name, template, data)
    
    -- Miscellaneous prefix removals
    for pattern,replacement in pairs(Vanity.ROOT_NAME_REPLACEMENTS) do
        name = name:gsub(pattern, replacement)
    end

    -- Remove underscores
    name = name:gsub("_", " ")

    -- Remove trailing whitespaces
    name = name:gsub("^ *", "") -- front
    name = name:gsub(" *$", "") -- end

    -- "Armor" prefix
    name = name:gsub("^Armor ", "")

    -- PascalCase handling!!! insane
    name = name:gsub("(%l)(%u%a*)", "%1 %2")
    -- Failed attempts!!! hilarious
    -- name = name:gsub(" ?(%u%l+)(%u%l+) ?", "%1 %2")
    -- name = name:gsub(" ?(a*)(%ua*) ?", "%1 %2")
    -- name = name:gsub("( ?)(%u%l+)(%u%l+)( ?)", "%1%2%3%4")

    -- Add a star at the end of items that do not hide any slots - 
    -- these tend to not work unless used in a specific slot.
    if data.Slot == "None" then
        name = name .. "*"
    end

    return name
end)

--- Load template data from a file.
---@param file string Relative to data dir.
function Vanity.LoadTemplateData(file)
    local data = Ext.IO.LoadFile(file, "data")
    data = Ext.Json.Parse(data)

    for guid,info in pairs(data) do
        -- Only load templates from mods that are loaded
        if info.Mod == "Shared" or Mod.IsLoaded(info.Mod) then
            Vanity.TEMPLATES[guid] = info
            Vanity.TEMPLATES[guid].GUID = guid
            Vanity.TEMPLATES[guid].Tags = Vanity:ReturnFromHooks("GenerateTemplateTags", {}, guid, info)
            Vanity.TEMPLATES[guid].Name = Vanity:ReturnFromHooks("GenerateTemplateName", Vanity.TEMPLATES[guid].RootName, guid, info)
    
            -- Create a category for each non-Shared mod
            if info.Mod ~= "Shared" and not Vanity.CATEGORIES[info.Mod] then
                Vanity.CATEGORIES[info.Mod] = {
                    Name = Ext.Mod.GetModInfo(info.Mod).Name,
                    Mod = info.Mod,
                    Tags = {[info.Mod] = true},
                    ID = info.Mod,
                }
    
                table.insert(Vanity.CATEGORY_ORDER, info.Mod)
            end
        end
    end
end

function Vanity.SnapToCharacterSheet()
    local cSheetPosition = CharacterSheet:GetUI():GetPosition()
    local x = cSheetPosition[1] + 1
    local y = cSheetPosition[2] + (217 * (Ext.UI.GetViewportSize()[2]/1080))
    y = math.floor(y)

    Vanity.SetPosition(x, y)
end

---@param data CharacterSheetCustomTab
---@return CharacterSheetCustomTab
function Vanity.CreateTab(data)
    local tab = Vanity._Tab.Create(data)

    table.insert(Vanity.TABS, tab)

    return tab
end

function Vanity.IsTemplateEquipped(templateGUID)
    local isEquipped = false

    -- Check template override
    if Vanity.currentItemTemplateOverride then
        isEquipped = Vanity.currentItemTemplateOverride == templateGUID
    else -- Otherwise check real template
        isEquipped = Vanity.GetCurrentItem().RootTemplate.Id == templateGUID
    end

    return isEquipped
end

function hex(val, minLength)
    minLength = minLength or 0
    local valStr = string.format("%x", val)

    
    while string.len(valStr) < minLength do
        valStr = "0" .. valStr
    end

    return valStr:upper()
end

function Vanity.TogglePointsWarning(state)
    local alpha = 0
    if state then alpha = 1 end

    local root = CharacterSheet:GetRoot()
    local list = root.stats_mc.pointsWarn

    -- Hide stat blips in the character sheet for all tabs covered up by custom ones.
    for i=1,math.min(#Vanity.TABS, 4),1 do
        local element = list[i - 1]

        -- TODO there are more tabs (ex. the GM ones, with different indexes), can they have blips?
        if element then
            element.alpha = alpha
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Block character sheet tooltips while the UI is open. Temporary fix for a new(?) strange issue where the sheet receives hover events.
---@param ev EclLuaUICallEvent
local function PreventTooltip(ev)
    if Vanity.IsOpen() then
        ev:PreventAction()
    end
end
Client.UI.CharacterSheet:RegisterCallListener("showStatTooltip", PreventTooltip)
Client.UI.CharacterSheet:RegisterCallListener("showAbilityTooltip", PreventTooltip)
Client.UI.CharacterSheet:RegisterCallListener("showTalentTooltip", PreventTooltip)

Net.RegisterListener("EPIPENCOUNTERS_Vanity_RefreshSheetAppearance", function(_)
    local sheet = Client.UI.CharacterSheet
    local char = Client.GetCharacter()
    local hasHelm = char.PlayerData.HelmetOptionState
    if hasHelm then hasHelm = 0 else hasHelm = 1 end

    sheet:ExternalInterfaceCall("setHelmetOption", hasHelm)
    if hasHelm == 0 then hasHelm = 1 else hasHelm = 0 end
    sheet:ExternalInterfaceCall("setHelmetOption", hasHelm)
end)

Vanity:RegisterCallListener("copyFromElement", function(ev, id)
    local element = ev.UI:GetRoot().focusedElement

    Vanity:DebugLog("Copying text", element.input_txt.htmlText, "from", id)

    Vanity.Events.CopyPressed:Fire(Vanity.currentTab, id, element.input_txt.htmlText)
end)

Vanity:RegisterCallListener("pasteIntoElement", function(ev, id)
    local element = ev.UI:GetRoot().focusedElement

    Vanity:DebugLog("Pasting into ", id)

    Vanity.Events.PastePressed:Fire(Vanity.currentTab, id)
end)

Vanity:RegisterCallListener("pipMinusPressed", function(ev, id)
    Vanity.Events.EntryRemoved:Fire(Vanity.currentTab, id)
end)

Vanity:RegisterCallListener("copyPressed", function(ev, id, text)
    Vanity.Events.CopyPressed:Fire(Vanity.currentTab, id, text)
end)

Vanity:RegisterCallListener("checkBoxID", function(ev, id, state)
    Vanity.Events.CheckboxPressed:Fire(Vanity.currentTab, id, state == 1)
end)

Vanity:RegisterCallListener("pastePressed", function(ev, id)
    Vanity.Events.PastePressed:Fire(Vanity.currentTab, id)
end)

Vanity:RegisterCallListener("acceptInput", function(ev, id, text)
    Vanity.Events.InputChanged:Fire(Vanity.currentTab, id, text)
end)

-- Hide level up blips while the UI is open.
GameState.Events.RunningTick:Subscribe(function (e)
    if not Client.IsUsingController() then
        if Vanity.visible and CharacterSheet:Exists() then
            Vanity.TogglePointsWarning(false)
        else
            Vanity.TogglePointsWarning(true)
        end
    end
end)

-- Save data on pause.
Utilities.Hooks.RegisterListener("GameState", "GamePaused", function()
    Vanity.SaveData()
end)

Vanity:RegisterCallListener("sliderHandleUp", function(ev, id, value)
    Vanity.Events.SliderHandleReleased:Fire(Vanity.currentTab, id, value)
end)

-- Close the UI when the selected item is unequipped and we're in the transmog menu.
Server.RegisterOsirisListener("ItemUnEquipped", 2, function(item, char)
    if Vanity:IsVisible() and Vanity.currentTab and Ext.Entity.GetItem(item) == Vanity.GetCurrentItem() then
        Timer.Start("PIP_VanityRefresh", 0.15, Vanity.Refresh)
    end
end)

-- Refresh the UI when the character is switched.
Utilities.Hooks.RegisterListener("Client", "ActiveCharacterChanged", function()
    Vanity.Refresh()
end)

-- Close when the character sheet tab is changed.
Client.UI.CharacterSheet.Events.TabChanged:Subscribe(function (_)
    Vanity.Toggle(false)
end)

Vanity:RegisterCallListener("entryClicked", function(ev, id, isCategory)
    Vanity:DebugLog("Entry clicked: " .. id)

    Vanity:GetUI():ExternalInterfaceCall("PlaySound", "UI_Game_CharacterSheet_Attribute_Select_Click")

    if isCategory then -- TODO event
        Vanity.openCategories[id] = not Vanity.openCategories[id]
        Vanity.Refresh()
    else
        Vanity.Events.EntryClicked:Fire(Vanity.currentTab, id)
    end
end)

Vanity.Events.TabButtonPressed:RegisterListener(function (id)
    Vanity:PlaySound("UI_Generic_Click")

    local tab = nil
    for _,registeredTab in ipairs(Vanity.TABS) do
        if registeredTab.ID == id then
            tab = registeredTab
            break
        end
    end

    if tab then
        Vanity.Setup(tab)

        -- TODO rework into a Once listener
        Timer.Start("", 0.1, function()
            CharacterSheet:HideTooltip()
        end)
    end
end)

Vanity:RegisterListener("ComboElementSelected", function(id, index, oldIndex)
    if id == "TransmogItemSlot" then
        Vanity.SetSlot(Data.Game.SLOTS_WITH_VISUALS[index])
    end
end)

Client.UI.ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    if Item.IsDyeable(item) and Item.IsEquipped(Client.GetCharacter(), item) then
        local selectable = (not Client.IsInCombat()) and (not Game.Character.IsDead(Client.GetCharacter()))
        Client.UI.ContextMenu.AddElement({
            {id = "epip_OpenVanity", type = "button", text = "Vanity...", selectable = selectable, faded = not selectable},
        })
    end
end)

Vanity:RegisterCallListener("pipTabButtonPressed", function(ev, id)
    Vanity.Events.TabButtonPressed:Fire(id)
end)

Vanity:RegisterCallListener("pipListButtonClicked", function(ev, id)
    Vanity.Events.ButtonPressed:Fire(Vanity.currentTab, id)
end)

local function OnComboSelected(ui, method, id, index, oldIndex)
    Vanity:FireEvent("ComboElementSelected", id, index + 1, oldIndex + 1)
end

local function OnTick()
    local root = Vanity:GetRoot()

    local isVisible = CharacterSheet:IsVisible() and not Client.IsInCombat()

    -- Close UI when the sheet is closed - TODO event
    if Vanity:IsVisible() and not isVisible then
        Vanity.Cleanup()
    end

    root.visible = isVisible and Vanity.visible

    Vanity.SnapToCharacterSheet()
end

Vanity:RegisterCallListener("pipEntryFavoriteClicked", function(ev, id, active)
    Vanity:DebugLog("Toggling favorite " .. tostring(active))
    Vanity.Events.EntryFavoriteToggled:Fire(Vanity.currentTab, id, active)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Load Shared data.
Ext.Events.SessionLoaded:Subscribe(function()
    Vanity.LoadTemplateData("Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/RawFiles/Lua/Epip/ContextMenus/Vanity/Data/Templates_Shared.json")
end)

function Vanity.Init()
    Ext.UI.Create(Vanity.ID, Vanity.PATH, 100)

    local ui = Vanity:GetUI()
    local root = Vanity:GetRoot()
    local characterSheetUI = Client.UI.CharacterSheet:GetUI()

    ui.Layer = characterSheetUI.Layer + 1

    -- Initial position
    Vanity.SnapToCharacterSheet()

    Ext.RegisterUICall(ui, "entryClicked", OnEntryClicked)
    Ext.RegisterUICall(ui, "pipComboElementSelected", OnComboSelected)

    Ext.Events.Tick:Subscribe(OnTick)

    root.resultPanel_mc.visible = false

    -- ui:Show()

    -- Position BG
    local bg = root.menu_mc.bg_mc
    bg.x = 25
    bg.y = 40
    bg.height = bg.height + 40

    -- Position menu
    local menu = root.menu_mc
    menu.y = 50
    -- menu.outfitsButton_mc.widthOverride = 100
    -- menu.transmogButton_mc.widthOverride = 100

    -- menu.outfitsButton_mc.text_mc.text_txt.htmlText = "<font size='17'>Outfits</font>"
    -- menu.outfitsButton_mc.text_mc.x = 84
    -- menu.outfitsButton_mc.text_mc.y = 8
    -- menu.transmogButton_mc.text_mc.text_txt.htmlText = "<font size='17'>Transmog</font>"
    -- menu.transmogButton_mc.text_mc.x = 73
    -- menu.transmogButton_mc.text_mc.y = 8

    -- menu.transmogButton_mc.textY = 8
    -- menu.outfitsButton_mc.textY = 8

    menu.frame_mc.y = 2

    -- Heaader
    local header = menu.header_txt
    header.width = menu.frame_mc.width
    header.x = 5
    header.y = 6

    local buttons = menu.buttonList
    -- buttons.EL_SPACING = 40
    -- buttons.x = 50
    -- buttons.y = 70
    -- buttons.positionElements()
    buttons.visible = false

    -- Position list
    local list = menu.list
    list.x = 40
    list.y = 90 -- 150
    list.SB_SPACING = -294 -- Scrollbar spacing
    list.SIDE_SPACING = 10
    list.m_scrollbar_mc.m_hideWhenDisabled = false
    list.setFrame(294, menu.bg_mc.height - list.y + 40)
    list.m_scrollbar_mc.setLength(menu.bg_mc.height - list.y + 14)
    list.m_scrollbar_mc.y = -12
    list.m_scrollbar_mc.x = -34
    list.mouseWheelWhenOverEnabled = true

    local tabs = menu.tabButtons_mc
    tabs.x = 2
    tabs.y = -43
    tabs.list.EL_SPACING = -9

    -- Fix for character sheet buttons not re-lighting up when you close the Vanity UI by going back to the real opened tab.
    Ext.RegisterUICall(CharacterSheet:GetUI(), "selectedTab", function(ui, method, newTab)
        local buttons = ui:GetRoot().stats_mc.tabsList

        for i=0,#buttons.content_array-1,1 do
            local button = buttons.content_array[i]

            if button.id == newTab then
                button.setActive(true)
            end
        end
    end, "After")
end

function Vanity:__Setup()
    Vanity.Init()
    Vanity.LoadData()
end