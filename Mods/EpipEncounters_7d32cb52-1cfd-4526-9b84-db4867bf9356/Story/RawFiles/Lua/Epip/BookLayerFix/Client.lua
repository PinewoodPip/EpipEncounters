---------------------------------------------
-- Fixes the layer of the Book UI appearing behind Fade and panels like PartyInventory after the Trade UI is used once.
-- It's unknown what exactly causes this issue within Epip, but it likely has to do with layer adjustments to the other UIs.
---------------------------------------------

local Fade = Client.UI.Fade

---@type Feature
local BookLayerFix = {}
Epip.RegisterFeature("Features.BookLayerFix", BookLayerFix)

-- Adjust Book UI layer when it is opened.
Ext.Events.UIInvoke:Subscribe(function (ev)
    if ev.UI:GetTypeId() == Ext.UI.TypeID.book and ev.Function == "clearBtnHints" and ev.UI.OF_Visible then
        local ui = ev.UI
        ui.Layer = Fade:GetUI().Layer + 5 -- Somehow the Book UI's layer already reports it to be above Fade, yet it shows underneath.
        ui:Show() -- Required for the layer change to take effect
    end
end, {EnabledFunctor = BookLayerFix:GetEnabledFunctor()})
