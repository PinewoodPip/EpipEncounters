
---@class Feature_Vanity_Outfits : Feature
local Outfits = {
    SavedOutfits = {}, ---@type table<string, VanityOutfit>

    Events = {},
    Hooks = {}
}
Epip.RegisterFeature("Vanity_Outfits", Outfits)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Vanity.Outfits.SaveData : Features.Vanity.SaveData
---@field Outfits table<string, VanityOutfit>
