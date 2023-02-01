
---------------------------------------------
-- Hooks and scripting for the EE-fied EnemyHealthBar.
-- Displays B/H, resistances and misc info.
-- Is also used as an utility to fetch the "last hovered character"
-- The B/H display is considered a core feature of the UI, not an "Epip Feature".
-- As such it cannot be disabled.
---------------------------------------------

local BH = EpicEncounters.BatteredHarried
local V = Vector.Create

---@class EnemyHealthBarUI : UI
local Bar = {
    latestCharacter = nil,
    latestItem = nil,

    _FRAME_FLASH_SHAPES = {
        ITEM = "itemBg_mc",
        BOSS = "bossBg_mc",
        REGULAR = "frame_mc",
        VANILLA_BOSS = "vanillaBg_mc",
    },

    -- These are not the 'official' colors,
    -- they're lightly modified for readability.
    RESISTANCE_COLORS = {
        Fire = "f77c27",
        Water = "27aff6",
        Earth = "aa7840",
        Air = "8f83cb",
        Poison = "5bd42b",
        Physical = "acacac",
        Piercing = "c23c3c",
        Shadow = "5b34ca",
    },

    RESISTANCES_DISPLAYED = {
        "Fire", "Water", "Earth", "Air", "Poison", "Physical", "Piercing",
    },

    BLINK_IN_DURATION = 0.2,
    BLINK_OUT_DURATION = 1.0,
    BLINK_OUT_ALPHA = 0.5, -- Alpha to which the blinkout animation fades (blinkin is 1.0)
    STATUS_HOLDER_Y = 123,

    MAX_STACKS = 10,

    RESISTANCE_STRING = "<font color='#%s'>%s%%</font>", -- Params: Color, value.
    ALTERNATE_STATUS_OPACITY = 0.1, -- Opacity for Status Holder when shift is being held.

    POSITIONING = {
        BOSS_FRAME = V(-238.5, -43.75),
        ITEM_FRAME = V(-198, -10),
        VANILLA_FRAME = V(-219, -43.75),
        BOTTOM_TEXT_Y = 57,
        BH_BACKGROUND_SCALE = 0.48,
        BH_BACKGROUND = V(125, 77.75),
        BH_SCALE = 0.6,
        BH_NUMBERS = V(121, 74),
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/enemyHealthBar.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/enemyHealthBar.swf"
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    
    Events = {
        Updated = {}, ---@type Event<EnemyHealthBarUI_Event_Updated>
    },
    Hooks = {
        GetBottomLabel = {}, ---@type Event<EnemyHealthBarUI_Hook_GetBottomLabel>
        GetStatusHolderPosition = {}, ---@type Event<EnemyHealthBarUI_Hook_GetStatusHolderPosition>
        GetStatusHolderOpacity = {}, ---@type Event<EnemyHealthBarUI_Hook_GetStatusHolderOpacity>
        GetStackOpacity = {}, ---@type Event<EnemyHealthBar_Hook_GetStackOpacity>
        GetHeader = {}, ---@type Event<EnemyHealthBarUI_Hook_GetHeader>
    },
}
Epip.InitializeUI(Client.UI.Data.UITypes.enemyHealthBar, "EnemyHealthBar", Bar)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class EnemyHealthBarUI_Event_Updated
---@field Character EclCharacter?
---@field Item EclItem?

---@class EnemyHealthBarUI_Hook_GetHeader
---@field Header string Hookable.
---@field Character EclCharacter?
---@field Item EclItem?

---@class EnemyHealthBarUI_Hook_GetBottomLabel
---@field Labels string[] Hookable.
---@field Character EclCharacter?
---@field Item EclItem?

---@class EnemyHealthBarUI_Hook_GetStatusHolderPosition
---@field PositionY number Hookable.

---@class EnemyHealthBarUI_Hook_GetStatusHolderOpacity
---@field Opacity number Hookable.

---@class EnemyHealthBar_Hook_GetStackOpacity
---@field Stack string
---@field Opacity number Hookable.
---@field Amount integer

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the character being shown on the bar.
---@return EclCharacter?
function Bar.GetCharacter()
    return Pointer.GetCurrentCharacter(nil, true)
end

---Returns the item being shown on the bar.
---@return EclItem?
function Bar.GetItem()
    local hasChar = Bar.GetCharacter() ~= nil
    local item = nil

    if not hasChar then -- Characters take priority.
        item = Pointer.GetCurrentItem()
    end

    return item
end

---Sets the label below the frame.
---@param text string
function Bar.SetBottomText(text)
    local element = Bar:GetRoot().hp_mc.textHolder_mc.label_txt

    element.htmlText = text
end

---Returns the label below the frame.
---@return string
function Bar.GetBottomText()
    local element = Bar:GetRoot().hp_mc.textHolder_mc.label_txt

    return element.htmlText
end

function Bar.SetHeader(text)
    local root = Bar:GetRoot()

    root.hp_mc.nameHolder_mc.text_txt.htmlText = text
end

---------------------------------------------
-- INTERNAL METHODS
---------------------------------------------

---Updates all the new features of the UI.
function Bar._Update()
    Bar._UpdateFrame()
    Bar._UpdateStacks()
    Bar._UpdateTexts()
    Bar._UpdateStatusHolder()
end

---Updates the position and opacity of the status bar.
function Bar._UpdateStatusHolder()
    local root = Bar:GetRoot()
    local statusHolder = root.hp_mc.statusHolder_mc

    -- Update position
    statusHolder.y = Bar.Hooks.GetStatusHolderPosition:Throw({
        PositionY = Bar.STATUS_HOLDER_Y,
    }).PositionY

    -- Update opacity
    statusHolder.alpha = Bar.Hooks.GetStatusHolderOpacity:Throw({
        Opacity = 1,
    }).Opacity
end

---Updates the label below the frame.
---@param originalHeader string? Defaults to entity display name.
---@return string, string --Header, bottom label.
function Bar._UpdateTexts(originalHeader)
    local char = Bar:GetCharacter()
    local item = Bar:GetItem()
    local header, footer
    if not originalHeader then
        if char then
            originalHeader = char.DisplayName
        elseif item then
            originalHeader = item.DisplayName
        end
    end
    
    header = Bar.Hooks.GetHeader:Throw({
        Header = originalHeader,
        Character = char,
        Item = item,
    }).Header
    local labels = Bar.Hooks.GetBottomLabel:Throw({
        Labels = {Bar._cachedVanillaBottomText or Bar.GetBottomText()},
        Character = char,
        Item = item,
    }).Labels
    footer = Text.Join(labels, "\n")

    Bar.SetBottomText(footer)

    return header, footer
end

---Updates the BH stack displays.
function Bar._UpdateStacks()
    local isEE = EpicEncounters.IsEnabled()
    local char = Bar.GetCharacter()
    local showStacks = char and isEE

    -- Hide stacks if we're not hovering over a character.
    if not showStacks then
        Bar._SetStack("Battered", 0)
        Bar._SetStack("Harried", 0)
    else
        local battered,batteredDuration = BH.GetStacks(char, "B")
        local harried,harriedDuration = BH.GetStacks(char, "H")

        Bar._SetStack("Battered", battered, batteredDuration)
        Bar._SetStack("Harried", harried, harriedDuration)
    end
end

---Sets the amount of BH displayed.
---@param stack string
---@param amount integer
---@param duration number? Inapplicable to backgrounds.
function Bar._SetStack(stack, amount, duration)
    local root = Bar:GetRoot()
    local shorthand = "b"
    if stack == "Harried" then
        shorthand = "h"
    end
    local background = root.hp_mc[shorthand .. "_0_mc"]

    -- Show the right numeral element, hide others
    for i=1,Bar.MAX_STACKS,1 do
        local element = root.hp_mc[shorthand .. "_" .. i .. "_mc"]

        element.visible = i == amount
    end

    -- Background opacity
    background.alpha = Bar.Hooks.GetStackOpacity:Throw({
        Stack = stack,
        Amount = amount,
        Opacity = 1,
    }).Opacity

    -- Duration. Blink if >0 and < 1 turn.
    if duration and duration <= 6.0 and duration > 0 then
        root.hp_mc.startStackTween(stack);
    elseif (stack == "Battered" and root.hp_mc.bTweenRunning) or (stack == "Harried" and root.hp_mc.hTweenRunning) then
        root.hp_mc.stopStackTween(stack);
    end
end

---Updates the frame of the UI.
function Bar._UpdateFrame()
    local isEE = EpicEncounters.IsEnabled()
    local char = Bar.GetCharacter()
    local item = Bar.GetItem()
    local root = Bar:GetRoot()
    local hpHolder = root.hp_mc
    local currentFrameName ---@type string

    -- Hide all frames first
    for _,shape in pairs(Bar._FRAME_FLASH_SHAPES) do
        hpHolder[shape].visible = false
    end

    -- Old boss frame toggle. Was flawed because it did not account for chars that were made into a boss with Osiris / instance override. We now rely on the engine info.
    -- local isBoss = char ~= nil and char.RootTemplate.CombatTemplate.IsBoss
    local isBoss = root.hp_mc.frame_mc.currentFrame == 2
    local isItem = item ~= nil and char == nil -- char takes priority, though I don't think you can have your cursor on both to begin with?

    if isEE then
        if isBoss then
            currentFrameName = Bar._FRAME_FLASH_SHAPES.BOSS
        elseif isItem then
            currentFrameName = Bar._FRAME_FLASH_SHAPES.ITEM
        else
            currentFrameName = Bar._FRAME_FLASH_SHAPES.REGULAR
        end
    else
        if isBoss then
            currentFrameName = Bar._FRAME_FLASH_SHAPES.VANILLA_BOSS
        else -- Regular enemies use item frame (which also doesn't have BH indicators)
            currentFrameName = Bar._FRAME_FLASH_SHAPES.ITEM
        end
    end

    hpHolder[currentFrameName].visible = true

    -- Hide B/H background for items, or outside EE
    hpHolder.b_0_mc.visible = not isItem or not isEE
    hpHolder.h_0_mc.visible = not isItem or not isEE
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update the UI when shift is toggled.
Client.Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "lshift" then
        Bar._Update()
    end
end)

-- Set opacity for stack backgrounds based on if the amount if enough to inflict a T3.
Bar.Hooks.GetStackOpacity:Subscribe(function (ev)
    local threshold = BH.GetStacksNeededToInflictTier3(Client.GetCharacter())
    local amount = ev.Amount
    local opacity

    if not EpicEncounters.IsEnabled() then
        opacity = 0
    elseif amount >= threshold then
        opacity = 1
    elseif amount == 0 then
        opacity = 0.5
    else
        opacity = 0.75
    end

    ev.Opacity = opacity
end)

-- Set bottom text.
Bar.Hooks.GetBottomLabel:Subscribe(function (ev)
    -- Show resistances for chars, or alternative info if shift is being held.
    local char, item = ev.Character, ev.Item
    local text = ""

    if char then
        local modifierActive = Client.Input.IsShiftPressed()

        if modifierActive then -- Show alternate info.
            local level = char.Stats.Level
            local sp, maxSp = Character.GetSourcePoints(char)
            local ap = char.Stats.CurrentAP
            local init = char.Stats.Initiative

            if maxSp == -1 then
                maxSp = 3
            end

            text = string.format("Level %s  %s AP  %s/%s SP  %s INIT", level, ap, sp, maxSp, init)
        else -- Show resistances.

            text = ""

            for _,resistanceId in ipairs(Bar.RESISTANCES_DISPLAYED) do
                local amount = char.Stats[resistanceId .. "Resistance"]
                local display = string.format(Bar.RESISTANCE_STRING, Bar.RESISTANCE_COLORS[resistanceId], amount)

                text = text .. "  " .. display
            end
        end
    elseif item and item.Stats then -- Show item level.
        text = string.format("Level %s", item.Stats.Level)
    end

    -- Make text smaller.
    text = string.format("<font size='14.5'>%s</font>", text)

    table.insert(ev.Labels, text)
end)

-- Listen for texts being set.
Bar:RegisterInvokeListener("setText", function (ev, header, footer, useLongTextField)
    Bar._cachedVanillaBottomText = footer
    local t1, t2 = Bar._UpdateTexts(header)

    ev:PreventAction()
    ev.UI:GetRoot().setText(t1, t2, useLongTextField)
end, "Before")

-- Listen for statuses being updated.
-- This is where we update all the new functionality of the UI.
Bar:RegisterInvokeListener("updateStatuses", function (_, _) -- Param 1 decides whether to add new statuses if the element doesn't exist
    local char = Bar.GetCharacter()
    local item = Bar.GetItem()

    if char then
        Bar.latestCharacter = Bar.GetCharacter().Handle
        Bar.latestItem = nil
    elseif item then
        Bar.latestItem = Bar.GetItem().Handle
        Bar.latestCharacter = nil
    end

    Bar._Update()

    Bar.Events.Updated:Throw({
        Character = char,
        Item = item,
    })
end, "After")

-- Move status holder downwards based on bottom text height.
Bar.Hooks.GetStatusHolderPosition:Subscribe(function (ev)
    local element = Bar:GetRoot().hp_mc.textHolder_mc.label_txt
    local offset = -22.62

    offset = offset + element.height

    ev.PositionY = ev.PositionY + offset
end)

-- Fade out status holder if shift is held.
Bar.Hooks.GetStatusHolderOpacity:Subscribe(function (ev)
    ev.Opacity = Client.Input.IsShiftPressed() and Bar.ALTERNATE_STATUS_OPACITY or ev.Opacity
end)

-- Display level by character name and hide it from the footer.
Bar.Hooks.GetHeader:Subscribe(function (ev)
    local char, item = ev.Character, ev.Item
    local level = (char and Character.GetLevel(char)) or (item and Item.GetLevel(item))

    if level then
        ev.Header = string.format("%s - Lvl %s", ev.Header, level)
    end
end)
Bar.Hooks.GetBottomLabel:Subscribe(function (ev)
    table.remove(ev.Labels, 1)
end, {Priority = -9999999})

---------------------------------------------
-- SETUP
---------------------------------------------

---Positions the new elements of the UI.
function Bar._PositionElements()
    local root = Bar:GetRoot()

    for i=0,Bar.MAX_STACKS,1 do -- need to start at 0 here to also reposition the base icon
        local battered = root.hp_mc["b_" .. i .. "_mc"]
        local harried = root.hp_mc["h_" .. i .. "_mc"]

        battered.scaleX, battered.scaleY = Bar.POSITIONING.BH_SCALE, Bar.POSITIONING.BH_SCALE
        battered.x = -Bar.POSITIONING.BH_NUMBERS[1] - battered.width * 0.935 -- wtf?
        battered.y = Bar.POSITIONING.BH_NUMBERS[2]

        harried.scaleX, harried.scaleY = Bar.POSITIONING.BH_SCALE, Bar.POSITIONING.BH_SCALE
        harried.x, harried.y = Bar.POSITIONING.BH_NUMBERS:unpack()
    end

    -- Positioning the base icons
    local battered = root.hp_mc["b_0_mc"]
    local harried = root.hp_mc["h_0_mc"]

    harried.scaleX, harried.scaleY = Bar.POSITIONING.BH_BACKGROUND_SCALE, Bar.POSITIONING.BH_BACKGROUND_SCALE
    harried.x, harried.y = Bar.POSITIONING.BH_BACKGROUND:unpack()

    battered.scaleX, battered.scaleY = Bar.POSITIONING.BH_BACKGROUND_SCALE, Bar.POSITIONING.BH_BACKGROUND_SCALE
    battered.x = -Bar.POSITIONING.BH_BACKGROUND[1] - battered.width * 0.9 -- wtf?
    battered.y = Bar.POSITIONING.BH_BACKGROUND[2]

    -- Bottom text
    root.hp_mc.textHolder_mc.label_txt.y = Bar.POSITIONING.BOTTOM_TEXT_Y
    root.hp_mc.textHolder_mc.label_txt.wordWrap = false

    -- Frames
    local bossFrame = root.hp_mc.bossBg_mc
    bossFrame.x, bossFrame.y = Bar.POSITIONING.BOSS_FRAME:unpack()

    local itemFrame = root.hp_mc.itemBg_mc
    itemFrame.x, itemFrame.y = Bar.POSITIONING.ITEM_FRAME:unpack()

    local vanillaBossFrame = root.hp_mc.vanillaBg_mc
    vanillaBossFrame.x, vanillaBossFrame.y = Bar.POSITIONING.VANILLA_FRAME:unpack()
end

-- Position elements once the UI is loaded.
Ext.Events.SessionLoaded:Subscribe(function()
    local root = Bar:GetRoot()

    Bar._PositionElements()

    -- Set blinking animation vars
    root.hp_mc.BHFlashAlpha = Bar.BLINK_OUT_ALPHA
    root.hp_mc.BHFlashInDuration = Bar.BLINK_IN_DURATION
    root.hp_mc.BHFlashOutDuration = Bar.BLINK_OUT_DURATION
end)