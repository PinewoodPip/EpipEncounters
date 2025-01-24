
---------------------------------------------
-- Fixes typos in somekeyword overhead status messages.
-- Since this joke is so english-specific, localization is unviable to support.
---------------------------------------------

local Overhead = Client.UI.Overhead

---@type Feature
local TextFixes = {
    ---Fixed spellings of "Prosperity".
    ---@type string[]
    PROSPERITY_SPELLINGS = {
        "Property",
        "Profanity",
        "Protensity",
        "Propietary",
        "Profession",
        "Propane",
        "Propserity",
        "Preposterous",
        "Portability",
        "Proppity",
    },
    ---Fixed spellings of "Violent".
    ---@type string[]
    VIOLENT_SPELLINGS = {
        "Visionary",
        "Visual",
        "Virtual",
        "Volatile",
        "Vile",
        "Vending",
        "Vivid",
        "Villainous",
        "Vertical",
        "Vaping",
    },
    ---Fixed spellings of "Strike".
    ---@type string[]
    STRIKE_SPELLINGS = {
        "Studios",
        "Strokes",
        "Streaks",
        "Steaks",
        "Sticks",
        "Stakes",
        "Strides",
        "Strangers",
        "Struggles",
        "Stations",
        "Styles",
        "Steamers",
        "Staplers",
    },

    PROSPERITY_MESSAGE = [[<font color="cc7a00">Prosperity</font>]],
    VIOLENT_STRIKES_MESSAGE = [[<font color="c80000">Violent Strikes</font>]],
}
Epip.RegisterFeature("Features.AprilFools.OverheadTextFixes", TextFixes)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Randomize overhead texts for the affected keywords.
Overhead.Hooks.RequestOverheads:Subscribe(function (ev)
    for _,request in ipairs(ev.Overheads) do
        if request.Label == TextFixes.PROSPERITY_MESSAGE then
            local replacement = TextFixes.PROSPERITY_SPELLINGS[math.random(1, #TextFixes.PROSPERITY_SPELLINGS)]
            request.Label = request.Label:gsub("Prosperity", replacement)
        elseif request.Label == TextFixes.VIOLENT_STRIKES_MESSAGE then
            -- For Violent Strike, each word is randomized.
            local violentReplacement = TextFixes.VIOLENT_SPELLINGS[math.random(1, #TextFixes.VIOLENT_SPELLINGS)]
            local strikeReplacement = TextFixes.STRIKE_SPELLINGS[math.random(1, #TextFixes.STRIKE_SPELLINGS)]
            request.Label = request.Label:gsub("Violent", violentReplacement)
            request.Label = request.Label:gsub("Strikes", strikeReplacement)
        end
    end
end, {EnabledFunctor = Epip.IsAprilFools})
