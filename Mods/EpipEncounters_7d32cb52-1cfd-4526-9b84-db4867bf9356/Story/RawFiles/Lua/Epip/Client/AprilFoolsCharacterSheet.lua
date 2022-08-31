
local AF = {
    sheetOpen = false,
}
Epip.AddFeature("AprilFoolsCharacterSheet", "AprilFoolsCharacterSheet", AF)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local function OnTick()
    local sheet = Client.UI.CharacterSheet
    local currentlyOpen = AF.sheetOpen
    AF.sheetOpen = sheet:IsVisible()

    if not currentlyOpen and AF.sheetOpen then
        local sheetRoot = sheet:GetRoot()
        local vanityRoot = Client.UI.Vanity:GetRoot()
        local newRotation = sheetRoot.rotation + Ext.Random(1, 2) * math.randomSign()

        -- Wrapping!
        if newRotation < -6 then
            newRotation = 6
        elseif newRotation > 6 then
            newRotation = -6
        end

        sheetRoot.rotation = newRotation
        vanityRoot.rotation = sheetRoot.rotation

        -- local sheetPosition = sheet:GetUI():GetPosition()
        -- sheet:GetUI():SetPosition(sheetPosition[1] + 20, sheetPosition[2])

        -- local vanityPosition = Client.UI.Vanity:GetUI():GetPosition()
        -- Client.UI.Vanity:GetUI():SetPosition(vanityPosition[1] + 20, vanityPosition[2])
    end
end

---------------------------------------------
-- SETUP
---------------------------------------------

function AF.__Setup()
-- Ext.Events.SessionLoaded:Subscribe(function()
    local sheet = Client.UI.CharacterSheet

    if Epip.IsAprilFools() then
        Ext.Events.Tick:Subscribe(OnTick)

        -- Tried to workaround clipping, not gonna happen.
        sheet:GetUI():ExternalInterfaceCall("setMcSize", 2000, 2000)
        -- sheet:GetRoot().x = 500
        -- sheet:SetPosition(-500, 0)
    end
end