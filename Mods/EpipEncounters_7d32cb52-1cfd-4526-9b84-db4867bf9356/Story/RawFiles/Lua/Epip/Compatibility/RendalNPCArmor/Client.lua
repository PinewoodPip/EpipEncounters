
---------------------------------------------
-- Adjusts templates from Rendal's NPC Armor mod for use with Vanity.
---------------------------------------------

local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")

---@type Feature
local Rendal = {
    PREFIXED_GUID = "Rendal_ItemVisuals_4dfe4bfe-2f7c-772f-9ce9-a83052a39ad2",
}
Epip.RegisterFeature("RendalNPCArmorCompatibility", Rendal)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Remove "Rendal" prefix from template names.
Transmog.Hooks.GetTemplateName:Subscribe(function (ev)
    local data = ev.TemplateEntry
    if data.Mod == Rendal.PREFIXED_GUID then
        ev.Name = string.gsub(ev.Name, "^Rendal *", "")
    end
end)
