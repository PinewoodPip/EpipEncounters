
---------------------------------------------
-- Cycles overlay colors to create a rainbow effect.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")
local OVERLAY_COLOR_INDEXES = Color.OVERLAY_COLOR_INDEXES
local C = Color.CreateFromRGB

---@type Feature
local RainbowOverlays = {
    _Enabled = false,
    _CurrentTime = 0,

    -- Source: https://www.krishnamani.in/color-codes-for-rainbow-vibgyor-colours/
    ---@type RGBColor[]
    COLORS = {
        C(148, 0, 211),
        C(75, 0, 130),
        C(0, 0, 255),
        C(0, 255, 0),
        C(255, 255, 0),
        C(255, 127, 0),
        C(255, 0 , 0),
    },
    CYCLE_TIME = 3.5, -- In seconds.
    OVERLAYS = Set.Create({ -- Overlay colors affected.
        OVERLAY_COLOR_INDEXES.SELECTOR_DOTS,
        OVERLAY_COLOR_INDEXES.SELECTOR_OUTER_CIRCLE,
        OVERLAY_COLOR_INDEXES.SELECTOR_INNER_CROSS,

        OVERLAY_COLOR_INDEXES.TACTICAL_HIGHLIGHTS_ACTIVE_CHARACTER,
        OVERLAY_COLOR_INDEXES.TACTICAL_HIGHLIGHTS_CONTROLLED_ALLY,

        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_SPECIAL,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_AEROTHEURGE,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_GEOMANCER,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_PYROKINETIC,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_NECROMANCER,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_POLYMORPH,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_HUNTSMAN,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_SCOUNDREL,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_SOURCERY,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_SUMMONING,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_WARFARE,
        OVERLAY_COLOR_INDEXES.SKILL_PREPARE_HYDROSOPHIST,
    }),
    TICK_EVENT_ID = "Feature_RainbowOverlays",
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Starts the rainbow color sequence.
function RainbowOverlays.Start()
    GameState.Events.Tick:Unsubscribe(RainbowOverlays.TICK_EVENT_ID)
    GameState.Events.Tick:Subscribe(function (ev)
        RainbowOverlays._Update(ev.DeltaTime / 1000)
    end, {StringID = RainbowOverlays.TICK_EVENT_ID})
end

---Updates the overlay colors.
---@param dt number Deltatime, in seconds.
function RainbowOverlays._Update(dt)
    local overlayColors = Ext.Utils.GetGlobalSwitches().OverlayColors
    local colorStages = #RainbowOverlays.COLORS
    local stageTime = RainbowOverlays.CYCLE_TIME / colorStages
    local currentStage ---@type integer
    local currentStageTime ---@type number

    RainbowOverlays._CurrentTime = RainbowOverlays._CurrentTime + dt

    currentStage = (math.floor(RainbowOverlays._CurrentTime / stageTime) + 1) % colorStages
    if currentStage == 0 then 
        currentStage = colorStages
    end
    currentStageTime = RainbowOverlays._CurrentTime % stageTime

    for index in RainbowOverlays.OVERLAYS:Iterator() do
        local currentColor = RainbowOverlays.COLORS[currentStage]
        local nextColor = RainbowOverlays.COLORS[currentStage + 1]
        if not nextColor then -- Wrap around
            nextColor = RainbowOverlays.COLORS[1]
        end
        local interpolatedColor = Color.Lerp(currentColor, nextColor, currentStageTime / stageTime)
        local r, g, b = interpolatedColor:ToFloats()

        overlayColors[index] = {
            r,
            g,
            b,
            1.0,
        }
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Enable the feature through a console command.
Ext.RegisterConsoleCommand("rainbowoverlays", function (_, _)
    RainbowOverlays.Start()
end)
