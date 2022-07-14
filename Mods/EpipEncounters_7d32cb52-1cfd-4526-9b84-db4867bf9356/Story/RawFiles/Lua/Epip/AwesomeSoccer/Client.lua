
---------------------------------------------
-- A recreation of Awesome Soccer as a Client.UI.Generic UI.
---------------------------------------------
local G = Client.UI.Generic
local T = Client.UI.Generic.CreateTexture

local Soccer = {
    UI = nil,
    Stats = {
        Wins = 0,
        Games = 0,
        LP = 0,
        WinningStreak = false,
        Streak = 0,
    },

    DEFAULT_HEADER = "Click the ball to start playing!",
    BALL_SCALE_EXPANDED = 1.06,
    BALL_SCALE = 1,
    LEGENDARY_STREAK_THRESHOLD = 6, -- Illegal to change outside of testing!
    SAVE_VERSION = 0,
    SAVE_FILENAME = "PIP_AwesomeSoccer.json",
}
Epip.AddFeature("AwesomeSoccer", "AwesomeSoccer", Soccer)

function Soccer.SaveStats()
    local save = {
        Version = Soccer.SAVE_VERSION,
        Stats = Soccer.Stats,
    }

    Ext.IO.SaveFile(Soccer.SAVE_FILENAME, Ext.Json.Stringify(save))
end

function Soccer.LoadStats()
    local save = Ext.IO.LoadFile(Soccer.SAVE_FILENAME)
    if save then
        save = Ext.Json.Parse(save)

        Soccer.Stats = save.Stats

        Soccer:FireEvent("StatsLoaded")
    end
end

function Soccer.Close()
    G.CloseInterface(Soccer.UI)
    Soccer.SaveStats()
end

---------------------------------------------
-- GAME LOGIC
---------------------------------------------

function Soccer.AddLP(amount)
    amount = amount or 1

    Soccer.Stats.LP = Soccer.Stats.LP + 1

    Soccer:FireEvent("LPChanged", amount, Soccer.Stats.LP)
end

function Soccer.RollResult()
    local won = math.random(0, 99) < 50

    if won then
        Soccer.Stats.Wins = Soccer.Stats.Wins + 1
    end

    -- Increment win/lose streak, or reset it
    if won ~= Soccer.Stats.WinningStreak then
        Soccer.Stats.WinningStreak = won
        Soccer.Stats.Streak = 1
    else
        Soccer.Stats.Streak = Soccer.Stats.Streak + 1
    end

    Soccer.Stats.Games = Soccer.Stats.Games + 1

    -- Award LP.
    if Soccer.Stats.Streak >= Soccer.LEGENDARY_STREAK_THRESHOLD then
        Soccer.AddLP()
    end

    Soccer:FireEvent("GamePlayed", won)

    return won
end

---------------------------------------------
-- UI LOGIC
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_OpenSoccer", function(cmd, payload)
    Soccer.Open()
end)

function Soccer.Open()
    G.OpenInterface(Soccer.UI)
end

-- Reset texts upon opening.
-- Soccer:RegisterListener("InterfaceOpened", function()
--     local resultText = Soccer.UI.container.header
--     local streakText = Soccer.UI.container.streak
-- end)

Soccer:RegisterListener("GamePlayed", function(won)
    local resultText = Soccer.UI.container.header
    local streakText = Soccer.UI.container.streak

    if won then
        resultText.SetText("You win!")
    else
        resultText.SetText("You lose!")
    end

    local str = "Winning Streak: "
    if not won then
        str = "Losing Streak: "
    end

    str = str .. Soccer.Stats.Streak

    if Soccer.Stats.Streak >= Soccer.LEGENDARY_STREAK_THRESHOLD then
        str = str .. "<br><font color='#8a2da6'>LEGENDARY STREAK!</font>"
    end

    streakText.SetText(str)
end)

-- Show "welcome back" message.
Soccer:RegisterListener("StatsLoaded", function()
    if Soccer.Stats.Games > 0 then
        Soccer.UI.container.header.SetText("Welcome back!")
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Soccer.CreateUI()
    Soccer.UI = G.CreateInterface("AwesomeSoccer")
    local ui = Soccer.UI

    local bg = G.AddSlicedBackground(Soccer.UI, "background_panel", G.TEMPLATES.BACKGROUNDS.TALL)
    Soccer.UI.MakeDraggable()

    local container = G.AddElement(ui, "container", {
        Type = "Base",
        -- width = 430, -- TODO NOTE: changing this also causes the children to inherit the delta!!!! bad!!! dont allow changing it on parent element.
        -- height = 500,
        ClickBoxWidth = 430,
        ClickBoxHeight = 500,
        y = 130,
        -- DebugHitMC = true,
    })
    G.CenterElement(container, bg, true)

    local logo = G.AddElement(container, "logo", {
        y = -80,
        Type = "IggyIcon",
        Scale = 0.8,
        Texture = T("pip_ui_awesomesoccer_logo", 512),
    })
    G.CenterElement(logo, container, true)

    local ball = G.AddElement(container, "ball", G.TEMPLATES.BUTTONS.AWESOME_SOCCERBALL)
    G.CenterElement(ball, container, true, true)

    local header = G.AddElement(container, "header", {
        Type = "Text",
        y = 60,
        Text = Soccer.DEFAULT_HEADER,
        FontSize = 23,
        mouseEnabled = false,
        mouseChildren = false,
    })
    header.text_txt.width = 500 -- TODO fix, autosize somehow
    header.text_txt.height = 100
    G.CenterElement(header, container, true)

    -- Streak counter
    local streak = G.AddElement(container, "streak", {
        Type = "Text",
        Text = "",
        FontSize = 23,
        Center = {H = container},
        Anchor = {Bottom = container, OffsetY = -55}
    })
    streak.text_txt.width = 300 -- TODO fix, autosize somehow
    streak.text_txt.height = 100
    G.CenterElement(streak, container, true)

    -- CLOSE BUTTON
    local closeButton = G.AddElement(container, "close", {
        Type = "Button",
        ButtonText = "",
        ClickBoxWidth = 23,
        ClickBoxHeight = 23,
        Scale = 1.5,
        Textures = {
            Idle = T("ui_button_close_idle", 32),
            Highlighted = T("ui_button_close_highlighted", 32),
            Pressed = T("ui_button_close_pressed", 32),
        },
        Anchor = {
            Top = container,
            Right = container,
            OffsetY = -70,
            OffsetX = 20,
        },
    })
    G.RegisterElementListener(closeButton, "ButtonClicked", function()
        Soccer.Close()
    end)

    -- BALL
    G.RegisterElementListener(ball, "MouseOver", function()
        G.ScaleElement(ball, Soccer.BALL_SCALE_EXPANDED, true)
    end)

    G.RegisterElementListener(ball, "MouseOut", function()
        G.ScaleElement(ball, Soccer.BALL_SCALE, true)
    end)

    G.RegisterElementListener(ball, "MouseDown", function()
        G.ScaleElement(ball, Soccer.BALL_SCALE, true)
    end)

    G.RegisterElementListener(ball, "MouseUp", function()
        G.ScaleElement(ball, Soccer.BALL_SCALE_EXPANDED, true)
    end)

    G.RegisterElementListener(ball, "ButtonClicked", function()
        Soccer.RollResult()
    end)

    return ui
end

function Soccer.Setup()
    local ui = Soccer.CreateUI()

    G.CloseInterface(ui)

    Soccer.LoadStats()
end

Ext.Events.SessionLoaded:Subscribe(function()
    Soccer.Setup()

    -- Open the menu on reset while debugging.
    -- With enough delay to see any console errors.
    if Soccer.IS_DEBUG then
        Client.Timer.Start("PIP_Soccer_DebugOpen", 2, function()
            Soccer.Open()        
        end)
    end
end)