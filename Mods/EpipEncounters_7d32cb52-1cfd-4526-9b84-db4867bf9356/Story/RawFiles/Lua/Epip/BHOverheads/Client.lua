
local Input = Client.Input

---@class Feature_BHOverheads
local BHOverheads = Epip.GetFeature("Feature_BHOverheads")
BHOverheads._CurrentUIs = {} ---@type table<ComponentHandle, Features.BHOverheads.UIFactory.Instance>

BHOverheads.SEARCH_RADIUS = 20 -- Search radius for characters, centered on the camera position.

---------------------------------------------
-- INPUT ACTIONS
---------------------------------------------

BHOverheads.InputActions.Show = BHOverheads:RegisterInputAction("Show", {
    Name = BHOverheads.TranslatedStrings.InputAction_Show_Name,
    Description = BHOverheads.TranslatedStrings.InputAction_Show_Description,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Shows overheads for characters near the camera.
function BHOverheads.Show()
    local factory = BHOverheads._GetUIFactory()
    local chars = BHOverheads._GetCharacters()

    BHOverheads:DebugLog("Showing overheads")

    -- Remove previous instances
    BHOverheads.Hide()

    for _,char in ipairs(chars) do
        local ui = factory.Create(char)

        BHOverheads._CurrentUIs[char.Handle] = ui

        ui:Show()
    end

    BHOverheads:DebugLog(string.format("%s characters eligible", table.getKeyCount(BHOverheads._CurrentUIs)))
end

---Diposes of all related UIs.
function BHOverheads.Hide()
    local factory = BHOverheads._GetUIFactory()

    for _,ui in pairs(BHOverheads._CurrentUIs) do
        factory.Dispose(ui)
    end

    BHOverheads._CurrentUIs = {}
end

---Returns whether a character is eligible to have its B/H shown.
---@see Feature_BHOverheads_Hook_IsEligible
---@param char EclCharacter
---@return boolean
function BHOverheads.IsCharacterEligible(char)
    local hook = BHOverheads.Hooks.IsEligible:Throw({
        Character = char,
        IsEligible = true,
    })
    return hook.IsEligible
end

---Returns the characters eligible for BH overheads.
---@return EclCharacter[]
function BHOverheads._GetCharacters()
    local camera = Client.Camera.GetPlayerCamera() ---@cast camera EclGameCamera
    local originPos = Vector.Create(camera.LookAt)
    local level = Entity.GetLevel()
    local levelID = Entity.GetLevelID(level)
    local chars = {}

    for _,char in pairs(level.EntityManager.CharacterConversionHelpers.ActivatedCharacters[levelID]) do
        local pos = Vector.Create(char.WorldPos)
        local dist = pos - originPos

        if Vector.GetLength(dist) <= BHOverheads.SEARCH_RADIUS and BHOverheads.IsCharacterEligible(char) then
            table.insert(chars, char)
        end
    end

    return chars
end

---Returns the UI factory class.
---@return Feature_BHOverheads_UIFactory
function BHOverheads._GetUIFactory()
    return BHOverheads:GetClass("Feature_BHOverheads_UIFactory")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show or hide the overheads when the input action is toggled.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action == BHOverheads.InputActions.Show and BHOverheads:IsEnabled() then
        BHOverheads.Show()
    end
end)
Input.Events.ActionReleased:Subscribe(function (ev)
    if ev.Action == BHOverheads.InputActions.Show then
        BHOverheads.Hide()
    end
end)

-- Default implementation of IsEligible.
BHOverheads.Hooks.IsEligible:Subscribe(function (ev)
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