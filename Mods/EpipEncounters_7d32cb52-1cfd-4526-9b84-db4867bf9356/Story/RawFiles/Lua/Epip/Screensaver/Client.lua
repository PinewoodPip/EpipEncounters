
---------------------------------------------
-- Plays a DVD-style screensaver when the user is idle.
---------------------------------------------

local Generic = Client.UI.Generic
local Textures = Epip.GetFeature("Feature_GenericUITextures")
local V = Vector.Create

---@type Feature
local Screensaver = {
    IDLE_TIMER = 25, -- Time in seconds before the screensaver appears.

    _TimeSinceLastInput = 0, -- In seconds.
}
Epip.RegisterFeature("Features.Screensaver", Screensaver)

local UI = Generic.Create("PIP_Screensaver")
UI.TEXTURE = Textures.TEXTURES.MISC.DVD
UI.LOGO_SIZE = V(270, 170)
UI.SPEED = 500
UI.RANDOM_SPEED_FACTOR = 0.1
UI.COLLISION_SOUND = "UI_Generic_Click"
UI.MIN_VELOCITY = 0.4 -- Normalized.
UI._INITIAL_POS = V(60, 60)
UI._Velocity = V(math.random() * math.randomSign(), math.random() * math.randomSign())
UI._Pos = UI._INITIAL_POS

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a new randomized velocity after colliding.
---@param prev Vector2
---@return Vector2
function UI.GetNewVelocity(prev)
    local offsetX = math.random() * math.randomSign() * UI.RANDOM_SPEED_FACTOR
    local offsetY = math.random() * math.randomSign() * UI.RANDOM_SPEED_FACTOR
    local newVelocity = V(math.clamp(prev[1] + offsetX, -1, 1), math.clamp(prev[2] + offsetY, -1, 1))

    -- Do not allow the speed to get too close to 0 on either axe (or flip over)
    if prev[1] < 0 then
        newVelocity[1] = math.min(newVelocity[1], -UI.MIN_VELOCITY)
    else
        newVelocity[1] = math.max(newVelocity[1], UI.MIN_VELOCITY)
    end
    if prev[2] < 0 then
        newVelocity[2] = math.min(newVelocity[2], -UI.MIN_VELOCITY)
    else
        newVelocity[2] = math.max(newVelocity[2], UI.MIN_VELOCITY)
    end

    return newVelocity
end

---@override
function UI:Show()
    self:_Initialize()
    Client.UI._BaseUITable.Show(self)
end

function UI:_Initialize()
    if not UI._Initialized then
        local texture = UI:CreateElement("Logo", "GenericUI_Element_Texture")
        texture:SetTexture(UI.TEXTURE, UI.LOGO_SIZE)
        texture:SetAlpha(0.9)

        UI.Logo = texture

        -- Reset position when viewport changes, to prevent it from getting stuck out of bounds.
        Client.Events.ViewportChanged:Subscribe(function (_)
            UI._Pos = UI._INITIAL_POS
        end)

        -- Update the logo position each tick.
        GameState.Events.RunningTick:Subscribe(function (ev)
            local scale = UI:GetUI():GetUIScaleMultiplier()
            local viewport = Client.GetViewportSize()
            local pos = UI._Pos
            local velocity = UI._Velocity
            local w, h = UI.LOGO_SIZE:unpack()
            w = w * scale
            h = h * scale

            -- Calculate new position and check for collision
            local newPos = V(pos[1] + velocity[1]*UI.SPEED*ev.DeltaTime/1000, pos[2] + velocity[2]*UI.SPEED*ev.DeltaTime/1000)
            local collided = false
            if newPos[1] <= 0 then -- Left edge
                velocity = UI.GetNewVelocity(V(-velocity[1], velocity[2]))
                collided = true
            elseif newPos[1] + w >= viewport[1] then -- Right edge
                velocity = UI.GetNewVelocity(V(-velocity[1], velocity[2]))
                collided = true
            elseif newPos[2] <= 0 and velocity[2] < 0 then -- Top edge
                velocity = UI.GetNewVelocity(V(velocity[1], -velocity[2]))
                collided = true
            elseif newPos[2] + h >= viewport[2] and velocity[2] > 0 then -- Bottom edge
                velocity = UI.GetNewVelocity(V(velocity[1], -velocity[2]))
                collided = true
            end

            if collided then
                UI:PlaySound(UI.COLLISION_SOUND)
            end
            newPos = V(pos[1] + velocity[1]*UI.SPEED*ev.DeltaTime/1000, pos[2] + velocity[2]*UI.SPEED*ev.DeltaTime/1000)

            UI._Pos = newPos
            UI._Velocity = velocity

            newPos = V(math.floor(newPos[1]), math.floor(newPos[2]))
            UI:SetPosition(newPos)
        end, {EnabledFunctor = function ()
            return UI:IsVisible()
        end})

        UI:SetPosition(UI._INITIAL_POS)
        UI:TogglePlayerInput(false)
        UI._Initialized = true
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Activate the feature on April Fools.
GameState.Events.ClientReady:Subscribe(function (_)
    if Epip.IsAprilFools() then
        GameState.Events.Tick:Subscribe(function (ev)
            Screensaver._TimeSinceLastInput = Screensaver._TimeSinceLastInput + ev.DeltaTime / 1000

            -- Toggle the UI based on time since last input.
            if Screensaver._TimeSinceLastInput > Screensaver.IDLE_TIMER then
                UI:Show()
            else
                UI:Hide()
            end
        end)

        -- Reset timer anytime an input happens.
        Client.Input.Events.KeyStateChanged:Subscribe(function (_)
            Screensaver._TimeSinceLastInput = 0
        end)
    end
end)
