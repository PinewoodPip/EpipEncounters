
---------------------------------------------
-- Hooks and scripting for the EE-fied EnemyHealthBar.
-- Displays B/H, resistances and misc info.
-- Is also used as an utility to fetch the "last hovered character"
-- The B/H display is considered a core feature of the UI, not an "Epip Feature".
-- As such it cannot be disabled.
---------------------------------------------

local Bar = {
    latestCharacter = nil,
    latestItem = nil,

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
        ["Public/Game/GUI/enemyHealthBar.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/enemyHealthBarTween.swf"
    },
}
Epip.InitializeUI(Client.UI.Data.UITypes.enemyHealthBar, "EnemyHealthBar", Bar)

function Bar.GetCharacter()
    local pointer = Ext.UI.GetPickingState()
    local char = nil

    if pointer.HoverCharacter then
        char = pointer.HoverCharacter
    elseif pointer.HoverCharacter2 then
        char = pointer.HoverCharacter2 -- Dead characters.
    end

    if char then
        char = Ext.GetCharacter(char) 
    end

    return char
end

function Bar.GetItem()
    local pointer = Ext.UI.GetPickingState()
    local item = nil

    if pointer.HoverItem then
        item = Ext.GetItem(pointer.HoverItem)
    end

    return item
end

function Bar.SetBottomText(text)
    local element = Bar:GetRoot().hp_mc.textHolder_mc.label_txt

    element.htmlText = text
end

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

function Bar.UpdateBottomText()
    local root = Bar:GetRoot()
    local char = Bar:GetCharacter()
    local item = Bar:GetItem()

    local text = Bar:ReturnFromHooks("GetBottomText", Bar.cachedVanillaBottomText or Bar.GetBottomText(), char, item)
    Bar.SetBottomText(text)

    root.hp_mc.statusHolder_mc.y = Bar:ReturnFromHooks("GetStatusHolderY", Bar.STATUS_HOLDER_Y, char, item)
end

function Bar.UpdateStacks()
    local char = Bar.GetCharacter()

    -- Hide stacks if we're not hovering over a character.
    if not char then
        Bar.SetStack("Battered", 0)
        Bar.SetStack("Harried", 0)
    else
        local battered,batteredDuration = Game.Character.GetStacks(char, "B")
        local harried,harriedDuration = Game.Character.GetStacks(char, "H")

        Bar.SetStack("Battered", battered, batteredDuration)
        Bar.SetStack("Harried", harried, harriedDuration)
    end

    Bar.UpdateBottomText()
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
    local char = Bar.GetCharacter()
    local item = Bar.GetItem()
    local root = Bar:GetRoot()

    -- Old boss frame toggle. Was flawed because it did not account for chars that were made into a boss with Osiris / instance override. We now rely on the engine info.
    -- local isBoss = char ~= nil and char.RootTemplate.CombatTemplate.IsBoss
    local isBoss = root.hp_mc.frame_mc.currentFrame == 2
    local isItem = item ~= nil and char == nil -- char takes priority, though I don't think you can have your cursor on both to begin with?

    root.hp_mc.itemBg_mc.visible = isItem
    root.hp_mc.bossBg_mc.visible = isBoss
    root.hp_mc.frame_mc.visible = not isBoss and not isItem

    -- hide B/H background for items
    root.hp_mc.b_0_mc.visible = not isItem
    root.hp_mc.h_0_mc.visible = not isItem
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
    Bar.UpdateBottomText()
end)

-- Set opacity for stack backgrounds based on if the amount if enough to inflict a T3.
Bar:RegisterHook("GetStackOpacity", function(opacity, stack, amount)
    local threshold = Game.Character.GetStacksNeededToInflictTier3(Client.GetCharacter())

    if amount >= threshold then
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
        local modifierActive = Client.Input.IsHoldingModifierKey()

        if modifierActive then -- Show alternate info.
            local level = char.Stats.Level
            local sp = char.Stats.MPStart
            local maxSp = char.Stats.MaxMpOverride
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
end

Ext.Events.SessionLoaded:Subscribe(function()
    local root = Bar:GetRoot()

    Ext.RegisterUITypeCall(Bar.UITypeID, "pipEnemyHealthBarHook", function(ui, method, ...)
        local char = Bar.GetCharacter()
        local item = Bar.GetItem()

        if char then
            Bar.latestCharacter = Bar.GetCharacter()
        end

        if item then
            Bar.latestItem = Bar.GetItem()
        end

        Bar.UpdateStacks()
        Bar.UpdateFrame()

        Bar:FireEvent("updated", char, item)
    end)

    Ext.RegisterUITypeCall(Bar.UITypeID, "pipEnemyHealthBarTextSet", function(ui, method, param1, param2, param3)
        -- Bar.SetHeader(topStr:upper())

        -- Utilities.Hooks.FireEvent("PIP_enemyHealthBar", "engineTextSet", topStr, bottomStr, bool1)
        Bar.cachedVanillaBottomText = param2
        Bar.UpdateBottomText()
    end, "After")

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