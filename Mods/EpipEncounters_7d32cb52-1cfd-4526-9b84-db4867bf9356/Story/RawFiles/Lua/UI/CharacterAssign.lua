
---------------------------------------------
-- APIs for the "Party Management" UI.
---------------------------------------------

---@class UI.CharacterAssign : UI
local CharacterAssign = {
    ENTRY_TEMPLATES = {
        CHARACTER = {
            "CharacterIndex",
            "PlayerIndex",
            "IconID",
        }
    }
}
Epip.InitializeUI(Ext.UI.TypeID.characterAssign, "CharacterAssign", CharacterAssign)

-- Override the UI to add additional character slots -
-- these are otherwise hardcoded to just 4.
-- This technically allows party members beyond the 4th to be assigned from the UI,
-- however, the extra portraits are cropped through the right of the UI normally -
-- see the CharacterAssignScrolling feature for how they're made accessible.
Ext.IO.AddPathOverride("Public/Game/GUI/characterAssign.swf", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/characterAssign.swf")

---@class UI.CharacterAssign.Entries.Character
---@field CharacterIndex integer
---@field PlayerIndex integer
---@field IconID string
