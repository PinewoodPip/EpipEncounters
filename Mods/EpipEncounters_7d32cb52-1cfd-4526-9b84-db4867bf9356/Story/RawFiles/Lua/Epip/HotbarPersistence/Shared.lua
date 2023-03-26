
---@class Feature_HotbarPresistence : Feature
local HotbarPersistence = {
    USERVAR_HOTBAR_STATE = "HotbarState",
}
Epip.RegisterFeature("HotbarPersistence", HotbarPersistence)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the saved hotbar state of char.
---@param char Character
---@return HotbarState
function HotbarPersistence.GetSavedState(char)
    return HotbarPersistence:GetUserVariable(char, HotbarPersistence.USERVAR_HOTBAR_STATE)
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register user var
HotbarPersistence:RegisterUserVariable(HotbarPersistence.USERVAR_HOTBAR_STATE, {
    WriteableOnServer = true,
    WriteableOnClient = true,
    SyncToClient = true,
    SyncToServer = true,
    Client = true,
    Server = true,
    Persistent = true,
})