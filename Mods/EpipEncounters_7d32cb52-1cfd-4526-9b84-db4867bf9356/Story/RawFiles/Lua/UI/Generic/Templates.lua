
---------------------------------------------
-- Template elements for Client.UI.Generic.
-- Pre-built elements that you can reference for faster UI development.
-- Buttons, backgrounds and such.
---------------------------------------------

local Generic = Client.UI.Generic
Generic.TEMPLATES = {
    BUTTONS = {},
    BACKGROUNDS = {},
}
local Templates = Generic.TEMPLATES

---------------------------------------------
-- BUTTONS
---------------------------------------------

Templates.BUTTONS.GREEN = {
    Type = "Button",
    ButtonTextY = 2,
    ClickBoxWidth = 153,
    ClickBoxHeight = 30,
    Textures = {
        Idle = Generic.CreateTexture("ui_button_green_idle", 256),
        Highlighted = Generic.CreateTexture("ui_button_green_hightlighted", 256), -- Nice typo Pip
        Pressed = Generic.CreateTexture("ui_button_green_pressed", 256),
    },
}

Templates.BUTTONS.RED = {
    Type = "Button",
    ButtonTextY = 2,
    ClickBoxWidth = 153,
    ClickBoxHeight = 30,
    Textures = {
        Idle = Generic.CreateTexture("ui_button_red_idle", 256),
        Highlighted = Generic.CreateTexture("ui_button_red_highlighted", 256),
        Pressed = Generic.CreateTexture("ui_button_red_pressed", 256),
    },
}

-- Stat buttons
Templates.BUTTONS.STAT_MINUS = {
    Type = "Button",
    ButtonText = "",
    ClickBoxWidth = 20,
    ClickBoxHeight = 20,
    Textures = {
        Idle = Generic.CreateTexture("ui_button_stat_minus_idle", 32),
        Highlighted = Generic.CreateTexture("ui_button_stat_minus_highlighted", 32),
        Pressed = Generic.CreateTexture("ui_button_stat_minus_pressed", 32),
    },
}

Templates.BUTTONS.STAT_PLUS = {
    Type = "Button",
    ButtonText = "",
    ClickBoxWidth = 20,
    ClickBoxHeight = 20,
    Textures = {
        Idle = Generic.CreateTexture("ui_button_stat_plus_idle", 32),
        Highlighted = Generic.CreateTexture("ui_button_stat_plus_highlighted", 32),
        Pressed = Generic.CreateTexture("ui_button_stat_plus_pressed", 32),
    },
}

Templates.BUTTONS.CLOSE = {
    Type = "Button",
    ButtonText = "",
    -- width = 23,
    -- height = 23, -- TODO make iggy icon its own thing!!!
    ClickBoxWidth = 23,
    ClickBoxHeight = 23,
    Textures = {
        Idle = Generic.CreateTexture("ui_button_close_idle", 32),
        Highlighted = Generic.CreateTexture("ui_button_close_highlighted", 32),
        Pressed = Generic.CreateTexture("ui_button_close_pressed", 32),
    },
}

Templates.BUTTONS.AWESOME_SOCCERBALL = {
    Type = "Button",
    ButtonText = "",
    ClickBoxWidth = 512,
    ClickBoxHeight = 512,
    Textures = {
        Idle = Generic.CreateTexture("pip_ui_awesomesoccer_ball", 512),
        Highlighted = Generic.CreateTexture("pip_ui_awesomesoccer_ball", 512),
        Pressed = Generic.CreateTexture("pip_ui_awesomesoccer_ball", 512),
    },
}

---------------------------------------------
-- BACKGROUNDS
---------------------------------------------

-- Textures
Templates.BACKGROUNDS.TEXTURES = {
    EXAMINE = {
        TOP = Generic.CreateTexture("examine_panel_top", 512),
        BOTTOM = Generic.CreateTexture("examine_panel_bottom", 512),
    }
}

-- Panels, for use with AddSlicedBackground
Templates.BACKGROUNDS.TALL = {
    Grid = {
        {Templates.BACKGROUNDS.TEXTURES.EXAMINE.TOP},
        {Templates.BACKGROUNDS.TEXTURES.EXAMINE.BOTTOM},
    },
    Offset = {y = 100, x = -10},
    SliceSize = 512,
}

-- Checkbox
-- TODO! make it check!!!