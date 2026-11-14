
local Input = Client.Input

---@class Features.OverheadInfos
local OverheadInfos = Epip.GetFeature("Features.OverheadInfos")
OverheadInfos._CurrentUIs = {} ---@type table<ComponentHandle, Features.OverheadInfos.UIFactory.Instance>

OverheadInfos.SEARCH_RADIUS = 20 -- Search radius for characters, centered on the camera position.

---------------------------------------------
-- INPUT ACTIONS
---------------------------------------------

OverheadInfos.InputActions.Show = OverheadInfos:RegisterInputAction("Show", {
    Name = OverheadInfos.TranslatedStrings.InputAction_Show_Name,
    Description = OverheadInfos.TranslatedStrings.InputAction_Show_Description,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Shows overheads for characters near the camera.
function OverheadInfos.Show()
    local factory = OverheadInfos._GetUIFactory()
    local chars = OverheadInfos._GetCharacters()

    OverheadInfos:DebugLog("Showing overheads")

    -- Remove previous instances
    OverheadInfos.Hide()

    for _,char in ipairs(chars) do
        local ui = factory.Create(char)

        OverheadInfos._CurrentUIs[char.Handle] = ui

        ui:Show()
    end

    OverheadInfos:DebugLog(string.format("%s characters eligible", table.getKeyCount(OverheadInfos._CurrentUIs)))
end

---Diposes of all related UIs.
function OverheadInfos.Hide()
    local factory = OverheadInfos._GetUIFactory()

    for _,ui in pairs(OverheadInfos._CurrentUIs) do
        factory.Dispose(ui)
    end

    OverheadInfos._CurrentUIs = {}
end

---Returns whether a character is eligible to have its B/H shown.
---@see Feature_BHOverheads_Hook_IsEligible
---@param char EclCharacter
---@return boolean
function OverheadInfos.IsCharacterEligible(char)
    local hook = OverheadInfos.Hooks.IsEligible:Throw({
        Character = char,
        IsEligible = true,
    })
    return hook.IsEligible
end

---Returns the characters eligible for BH overheads.
---@return EclCharacter[]
function OverheadInfos._GetCharacters()
    local camera = Client.Camera.GetPlayerCamera() ---@cast camera EclGameCamera
    local originPos = Vector.Create(camera.LookAt)
    local level = Entity.GetLevel()
    local levelID = Entity.GetLevelID(level)
    local chars = {}

    for _,char in pairs(level.EntityManager.CharacterConversionHelpers.ActivatedCharacters[levelID]) do
        local pos = Vector.Create(char.WorldPos)
        local dist = pos - originPos

        if Vector.GetLength(dist) <= OverheadInfos.SEARCH_RADIUS and OverheadInfos.IsCharacterEligible(char) then
            table.insert(chars, char)
        end
    end

    return chars
end

---Returns the UI factory class.
---@return Features.OverheadInfos.UIFactory
function OverheadInfos._GetUIFactory()
    return OverheadInfos:GetClass("Features.OverheadInfos.UIFactory")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show or hide the overheads when the input action is toggled.
Input.RegisterActionExecutedListener(OverheadInfos.InputActions.Show, function (_)
    if OverheadInfos:IsEnabled() then
        OverheadInfos.Show()
    end
end)
Input.RegisterActionReleasedListener(OverheadInfos.InputActions.Show, function (_)
    OverheadInfos.Hide()
end)

-- Default implementation of IsEligible.
OverheadInfos.Hooks.IsEligible:Subscribe(function (ev)
    local char = ev.Character
    local eligible = ev.IsEligible

    eligible = eligible and not Character.IsDead(char)
    eligible = eligible and Character.IsInCombat(char)

    -- Stealthed non-player characters are ineligible.
    if not Character.IsPlayer(char) then
        eligible = eligible and not Character.IsInStealth(char)
    end

    ev.IsEligible = eligible
end, {StringID = "DefaultImplementation"})
