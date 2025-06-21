
---------------------------------------------
-- Implements context menu shortcuts for Greatforge operations.
---------------------------------------------

---@class Features.GreatforgeContextMenu : Feature
local GreatforgeContextMenu = {
    TranslatedStrings = {
        Label_ExtractRunes = {
            Handle = "he8b4b102g4280g45c0g9ebag15c97ee8c6a3",
            Text = "Extract Runes",
            ContextDescription = [[Context menu option]],
        },
        Label_Dismantle = {
            Handle = "hd0ca255cg4598g4a16g8a9ag89f96981f52f",
            Text = "Dismantle",
            ContextDescription = [[Context menu option]],
        },
        Overhead_ExtractedRunes = {
            Handle = "hc4043848g4c14g42cfg9d89g3b7c21c98b28",
            Text = "Extracted runes for %s Splinters.",
            ContextDescription = [[Overhead shown after extracting runes through the context menu. Param is splinters cost.]],
        },
    },
}
Epip.RegisterFeature("Features.GreatforgeContextMenu", GreatforgeContextMenu)