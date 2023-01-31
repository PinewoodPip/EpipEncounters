
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
        BOSS_FRAME = {X = -238.5, Y = -43.75},
        ITEM_FRAME = {X = -198, Y = -10},
        VANILLA_FRAME = V(-219, -43.75),
        BOTTOM_TEXT = {Y = 57},
        BH_BACKGROUND = {
            SCALE = 0.48,
            X = 125,
            Y = 77.75,
        },
        NUMERALS = {
            SCALE = 0.6,
            X = 121,
            Y = 74,
        },
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/enemyHealthBar.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/enemyHealthBar.swf"
    },
}
Epip.InitializeUI(Client.UI.Data.UITypes.enemyHealthBar, "EnemyHealthBar", Bar)

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
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

---Updates the label below the frame.
---@return string
function Bar._UpdateBottomText()
    local root = Bar:GetRoot()
    local char = Bar:GetCharacter()
    local item = Bar:GetItem()

    local text = Bar:ReturnFromHooks("GetBottomText", Bar.cachedVanillaBottomText or Bar.GetBottomText(), char, item)
    Bar.SetBottomText(text)

    root.hp_mc.statusHolder_mc.y = Bar:ReturnFromHooks("GetStatusHolderY", Bar.STATUS_HOLDER_Y, char, item)

    return text
end

function Bar.UpdateStacks()
    local isEE = EpicEncounters.IsEnabled()
    local char = Bar.GetCharacter()
    local showStacks = char and isEE

    -- Hide stacks if we're not hovering over a character.
    if not showStacks then
        Bar.SetStack("Battered", 0)
        Bar.SetStack("Harried", 0)
    else
        local battered,batteredDuration = BH.GetStacks(char, "B")
        local harried,harriedDuration = BH.GetStacks(char, "H")

        Bar.SetStack("Battered", battered, batteredDuration)
        Bar.SetStack("Harried", harried, harriedDuration)
    end

    Bar._UpdateBottomText()
end

function Bar.SetStack(stack, amount, duration)
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
    background.alpha = Bar:ReturnFromHooks("GetStackOpacity", 1, stack, amount) or 1

    -- Duration. Blink if >0 and < 1 turn.
    if duration and duration <= 6.0 and duration > 0 then
        root.hp_mc.startStackTween(stack);
    elseif (stack == "Battered" and root.hp_mc.bTweenRunning) or (stack == "Harried" and root.hp_mc.hTweenRunning) then
        root.hp_mc.stopStackTween(stack);
    end
end

function Bar.UpdateFrame()
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

-- Change opacity of Status Holder when shift is being pressed.
Utilities.Hooks.RegisterListener("Input", "SneakConesToggled", function(pressed)
    local root = Bar:GetRoot()
    local statusHolder = root.hp_mc.statusHolder_mc

    if pressed then
        statusHolder.alpha = Bar.ALTERNATE_STATUS_OPACITY
    else
        statusHolder.alpha = 1
    end
end)

-- Update bottom text when shift is pressed.
Utilities.Hooks.RegisterListener("Input", "SneakConesToggled", function(pressed)
    Bar._UpdateBottomText()
end)

-- Set opacity for stack backgrounds based on if the amount if enough to inflict a T3.
Bar:RegisterHook("GetStackOpacity", function(opacity, stack, amount)
    local threshold = BH.GetStacksNeededToInflictTier3(Client.GetCharacter())

    if not EpicEncounters.IsEnabled() then
        opacity = 0
    elseif amount >= threshold then
        opacity = 1
    elseif amount == 0 then
        opacity = 0.5
    else
        opacity = 0.75
    end

    return opacity
end)

-- Set bottom text.
Bar:RegisterHook("GetBottomText", function(text, char, item)

    -- Show resistances for chars, or alternative info if shift is being held.
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

            for i,resistanceId in ipairs(Bar.RESISTANCES_DISPLAYED) do
                local amount = char.Stats[resistanceId .. "Resistance"]
                local display = string.format(Bar.RESISTANCE_STRING, Bar.RESISTANCE_COLORS[resistanceId], amount)

                text = text .. "  " .. display
            end
        end
    elseif item and item.Stats then -- Show item level.
        text = string.format("Level %s", item.Stats.Level)
    end

    -- Make text smaller.
    return string.format("<font size='14.5'>%s</font>", text)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Bar.PositionElements()
    local root = Bar:GetRoot()

    for i=0,Bar.MAX_STACKS,1 do -- need to start at 0 here to also reposition the base icon
        local battered = root.hp_mc["b_" .. i .. "_mc"]
        local harried = root.hp_mc["h_" .. i .. "_mc"]

        battered.scaleX = Bar.POSITIONING.NUMERALS.SCALE
        battered.scaleY = Bar.POSITIONING.NUMERALS.SCALE
        battered.x = -Bar.POSITIONING.NUMERALS.X - battered.width * 0.935 -- wtf?
        battered.y = Bar.POSITIONING.NUMERALS.Y

        harried.scaleX = Bar.POSITIONING.NUMERALS.SCALE
        harried.scaleY = Bar.POSITIONING.NUMERALS.SCALE
        harried.x = Bar.POSITIONING.NUMERALS.X
        harried.y = Bar.POSITIONING.NUMERALS.Y
    end

    -- Positioning the base icons
    local battered = root.hp_mc["b_0_mc"]
    local harried = root.hp_mc["h_0_mc"]

    harried.scaleX = Bar.POSITIONING.BH_BACKGROUND.SCALE
    harried.scaleY = Bar.POSITIONING.BH_BACKGROUND.SCALE
    harried.x = Bar.POSITIONING.BH_BACKGROUND.X
    harried.y = Bar.POSITIONING.BH_BACKGROUND.Y

    battered.scaleX = Bar.POSITIONING.BH_BACKGROUND.SCALE
    battered.scaleY = Bar.POSITIONING.BH_BACKGROUND.SCALE
    battered.x = -Bar.POSITIONING.BH_BACKGROUND.X - battered.width * 0.9 -- wtf?
    battered.y = Bar.POSITIONING.BH_BACKGROUND.Y

    -- Bottom text
    root.hp_mc.textHolder_mc.label_txt.y = Bar.POSITIONING.BOTTOM_TEXT.Y
    root.hp_mc.textHolder_mc.label_txt.wordWrap = false

    -- Frames
    local bossFrame = root.hp_mc.bossBg_mc
    bossFrame.x = Bar.POSITIONING.BOSS_FRAME.X
    bossFrame.y = Bar.POSITIONING.BOSS_FRAME.Y

    local itemFrame = root.hp_mc.itemBg_mc
    itemFrame.x = Bar.POSITIONING.ITEM_FRAME.X
    itemFrame.y = Bar.POSITIONING.ITEM_FRAME.Y

    local vanillaBossFrame = root.hp_mc.vanillaBg_mc
    vanillaBossFrame.x, vanillaBossFrame.y = Bar.POSITIONING.VANILLA_FRAME:unpack()
end

-- Listen for texts being set.
Bar:RegisterInvokeListener("setText", function (ev, header, footer, useLongTextField)
    Bar.cachedVanillaBottomText = footer

    ev:PreventAction()
    ev.UI:GetRoot().setText(header, Bar._UpdateBottomText(), useLongTextField)
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

    Bar.UpdateStacks()
    Bar.UpdateFrame()

    Bar:FireEvent("updated", char, item)
end, "After")

Ext.Events.SessionLoaded:Subscribe(function()
    local root = Bar:GetRoot()

    Bar.PositionElements()

    -- Set blinking animation vars
    root.hp_mc.BHFlashAlpha = Bar.BLINK_OUT_ALPHA
    root.hp_mc.BHFlashInDuration = Bar.BLINK_IN_DURATION
    root.hp_mc.BHFlashOutDuration = Bar.BLINK_OUT_DURATION
end)

-- Move status holder downwards based on bottom text height.
Bar:RegisterHook("GetStatusHolderY", function(y, char, item)
    local element = Bar:GetRoot().hp_mc.textHolder_mc.label_txt
    local offset = -22.62

    offset = offset + element.height

    return y + offset
end)