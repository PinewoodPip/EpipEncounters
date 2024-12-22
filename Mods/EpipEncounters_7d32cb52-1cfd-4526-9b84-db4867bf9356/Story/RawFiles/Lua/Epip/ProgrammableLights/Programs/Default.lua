
---------------------------------------------
-- Implements a simple cycling RGB pattern of christmas lights.
---------------------------------------------

local System = Epip.GetFeature("Features.ProgrammableLights")
local BaseProgramClass = System:GetClass("Features.ProgrammableLights.Program")
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenuOverlay")

---@type Features.ProgrammableLights.Program
local Program = {
    TIMER_ID = "Features.ProgrammableLights.Programs.Default",
    LIGHTS_SCALE = 0.8,
    PHASE_TIME = 1.6, -- Time between phase shifts, in seconds.
    BASE_OPACITY = 0.7, -- Starting opacity for "blink" tweens.
    FADEIN_TIME = 0.5, -- Duration of the opacity increase tween, in seconds.
    MAX_RANDOM_FADEIN_OFFSET = 0.65, -- Maximum random increase to the fade-in duration, in seconds.
    PIP_PURPLE_CHANCE = 0.2, -- Easter egg (easter eggs in Epip can be composites)
}
System:RegisterClass("Features.ProgrammableLights.Programs.Default", Program, {"Features.ProgrammableLights.Program"})

---@override
function Program:Initialize(root)
    local lightDesc = System.GetLight("Light1") -- I was going to make multiple lightbulb textures myself, but we run out of time budget

    -- Left side, from bottom to top
    local leftLight1 = self:CreateLight(root, lightDesc, {15, 915}, 90)
    local leftLight2 = self:CreateLight(root, lightDesc, {13, 738}, 260)
    local leftLight3 = self:CreateLight(root, lightDesc, {37, 629}, 280)
    local leftLight4 = self:CreateLight(root, lightDesc, {35, 490}, 270)
    local leftLight5 = self:CreateLight(root, lightDesc, {22, 318}, 320)
    local leftLight6 = self:CreateLight(root, lightDesc, {25, 177}, 290)

    -- Top side
    local topLight1 = self:CreateLight(root, lightDesc, {256, 47}, 20)
    local topLight2 = self:CreateLight(root, lightDesc, {454, 49}, 240)
    local topLight3 = self:CreateLight(root, lightDesc, {593, 35}, 340)
    local topLight4 = self:CreateLight(root, lightDesc, {779, 47}, 40)
    local topLight5 = self:CreateLight(root, lightDesc, {1104, 58}, 120)
    local topLight6 = self:CreateLight(root, lightDesc, {1304, 25}, 300)

    -- Right side, from top to bottom (classic Pip inconsistency lol)
    local rightLight1 = self:CreateLight(root, lightDesc, {1387, 160}, 60)
    local rightLight2 = self:CreateLight(root, lightDesc, {1360, 253}, 120)
    local rightLight3 = self:CreateLight(root, lightDesc, {1382, 422}, 95)
    local rightLight4 = self:CreateLight(root, lightDesc, {1346, 550}, 220)
    local rightLight5 = self:CreateLight(root, lightDesc, {1352, 765}, 65)
    local rightLight6 = self:CreateLight(root, lightDesc, {1325, 915}, 275)

    ---@type {Lights: Features.ProgrammableLights.UI.Prefabs.Light[], States: string[]}[]
    local groups = {
        {
            Lights = {leftLight1, topLight1, rightLight1},
            States = {"Red", "Green", "Blue", "Off", "Off", "Off"},
        },
        {
            Lights = {leftLight2, topLight2, rightLight2},
            States = {"Green", "Blue", "Off", "Off", "Off", "Red"},
        },
        {
            Lights = {leftLight3, topLight3, rightLight3},
            States = {"Blue", "Off", "Off", "Off", "Red", "Green"},
        },
        {
            Lights = {leftLight4, topLight4, rightLight4},
            States = {"Off", "Off", "Off", "Red", "Green", "Blue"},
        },
        {
            Lights = {leftLight5, topLight5, rightLight5},
            States = {"Off", "Off", "Red", "Green", "Blue", "Off"},
        },
        {
            Lights = {leftLight6, topLight6, rightLight6},
            States = {"Off", "Red", "Green", "Blue", "Off", "Off"},
        },
    }

    -- Cycles light groups through their states on a timer
    local stateCounter = 1
    local timer = Timer.Start(self.PHASE_TIME, function (_)
        if not System.Overlay.UI:IsVisible() then return end -- Skip updates if the UI is closed. TODO have programs just be disposed automatically in this case

        -- Progress lights to next state in each group
        for _,group in ipairs(groups) do
            local state = group.States[math.indexmodulo(stateCounter, #group.States)]
            for _,light in ipairs(group.Lights) do
                state = (state == "Blue" and math.random() < self.PIP_PURPLE_CHANCE) and "Purple" or state -- Random chance to switch blue for Pip-ish purple (couldn't fit it into the sequence otherwise)

                light:SetState(state)

                -- Tween state transitions so they look less epileptic
                local fadeDurationOffset = math.random() * self.MAX_RANDOM_FADEIN_OFFSET
                local fadeTime = self.FADEIN_TIME + fadeDurationOffset
                if state ~= "Off" then
                    -- Tween alpha from low to 1
                    light.Texture:Tween({
                        EventID = "BlinkStart",
                        StartingValues = {
                            alpha = self.BASE_OPACITY,
                        },
                        FinalValues = {
                            alpha = 1,
                        },
                        Function = "Cubic",
                        Ease = "EaseInOut",
                        Duration = fadeTime,
                        -- Bring alpha back to 1 at the end of the phase
                        OnComplete = function (_)
                            light.Texture:Tween({
                                EventID = "BlinkEnd",
                                StartingValues = {
                                    alpha = 1,
                                },
                                FinalValues = {
                                    alpha = self.BASE_OPACITY,
                                },
                                Function = "Cubic",
                                Ease = "EaseInOut",
                                Duration = self.PHASE_TIME - fadeTime,
                            })
                        end
                    })
                elseif light.State ~= "Off" then -- Don't play this tween if there is no state change.
                    light.Texture:Tween({
                        EventID = "BlinkStart",
                        StartingValues = {
                            alpha = 1,
                        },
                        FinalValues = {
                            alpha = self.BASE_OPACITY,
                        },
                        Function = "Cubic",
                        Ease = "EaseInOut",
                        Duration = fadeTime,
                    })
                end
            end
        end
        stateCounter = stateCounter + 1
    end, self.TIMER_ID)
    timer:SetRepeatCount(-1) -- Christmas cheer is eternal

    -- Life hack: print mouse coordinates relative to the root to help with positioning. Feel free to reuse
    GameState.Events.Tick:Subscribe(function (_)
        local mc = root:GetMovieClip()
        print("Light root mouse coords", mc.mouseX, mc.mouseY)
    end, {EnabledFunctor = function () return false end})
end

---@override
function Program:Shutdown()
    local timer = Timer.GetTimer(self.TIMER_ID)
    if timer then
        timer:Cancel()
    end
end

---Convenience override to avoid passing light scale explicitly all the time.
---@override
function Program:CreateLight(root, light, pos, rotation, scale)
    return BaseProgramClass.CreateLight(self, root, light, pos, rotation, scale or self.LIGHTS_SCALE)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Run this program on christmas.
SettingsMenu.Events.TabRendered:Subscribe(function (_)
    System.SetProgram(Program)
    SettingsMenu.Events.TabRendered:Unsubscribe("Features.ProgrammableLights.Programs.Default")
end, {EnabledFunctor = Epip.IsChristmas, StringID = "Features.ProgrammableLights.Programs.Default"})
