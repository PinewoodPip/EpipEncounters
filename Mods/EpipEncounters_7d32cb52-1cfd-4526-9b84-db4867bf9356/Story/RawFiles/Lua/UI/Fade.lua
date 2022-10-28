
---@class FadeUI : UI
local Fade = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
}
Epip.InitializeUI(Ext.UI.TypeID.uiFade, "Fade", Fade)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param duration number? Defaults to 0.8
function Fade.FadeIn(duration)
    local root = Fade:GetRoot()

    Fade:GetUI():Show()
    root.setFadeAlpha(0.5)
    root.fadeIn(duration or 0.8)
end

function Fade.FadeOut()
    Fade:Hide()
end

---@param ui UIObject
function Fade.PlaceBelow(ui)
    Fade:GetUI().Layer = ui.Layer - 1
end