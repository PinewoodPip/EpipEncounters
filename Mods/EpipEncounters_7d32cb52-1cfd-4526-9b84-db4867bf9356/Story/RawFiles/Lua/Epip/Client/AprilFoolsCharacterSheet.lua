
local AF = {
    sheetOpen = false,
    MAX_ROTATION = 4,
    MAX_INCREMENT = 1,
}
Epip.RegisterFeature("AprilFoolsCharacterSheet", AF)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local function OnTick()
    local sheet = Client.UI.CharacterSheet
    local currentlyOpen = AF.sheetOpen
    AF.sheetOpen = sheet:IsVisible()

    -- If the sheet was opened on this tick, rotate it
    if not currentlyOpen and AF.sheetOpen then
        local sheetRoot = sheet:GetRoot()
        local vanityRoot = Client.UI.Vanity:GetRoot()
        local newRotation = sheetRoot.rotation + Ext.Random() * AF.MAX_INCREMENT * math.randomSign()

        -- Wrapping!
        if newRotation < -(AF.MAX_ROTATION) then
            newRotation = AF.MAX_ROTATION
        elseif newRotation > AF.MAX_ROTATION then
            newRotation = -(AF.MAX_ROTATION)
        end

        sheetRoot.rotation = newRotation
        vanityRoot.rotation = sheetRoot.rotation
    end
end

---------------------------------------------
-- SETUP
---------------------------------------------

function AF.__Setup()
    local sheet = Client.UI.CharacterSheet

    if Epip.IsAprilFools() then
        Ext.Events.Tick:Subscribe(OnTick)

        -- Tried to workaround clipping, not gonna happen.
        sheet:GetUI():ExternalInterfaceCall("setMcSize", 2000, 2000)
        -- sheet:GetRoot().x = 500
        -- sheet:SetPosition(-500, 0)
    end
end