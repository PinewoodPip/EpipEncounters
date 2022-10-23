
local Reward = Client.UI.Reward
local CharacterSheet = Client.UI.CharacterSheet

local ItemComparison = {
    active = false,
}
Epip.AddFeature("RewardItemComparison", "RewardItemComparison", ItemComparison)

---------------------------------------------
-- METHODS
---------------------------------------------

function ItemComparison:IsEnabled()
    return Settings.GetSettingValue("Epip_Inventory", "Inventory_RewardItemComparison")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Reward:RegisterCallListener("acceptClicked", function(_)
    if ItemComparison:IsEnabled() then
        Reward:SetFlag("OF_PlayerModal1", true) -- Prevents a softlock.
        ItemComparison.active = false
        
        CharacterSheet:GetUI().Layer = CharacterSheet.DEFAULT_LAYER
        CharacterSheet:GetUI().RenderOrder = CharacterSheet.DEFAULT_RENDER_ORDER
    end
end, "Before")

Reward:RegisterInvokeListener("updateItems", function(_)
    if not ItemComparison.active and ItemComparison:IsEnabled() then
        ItemComparison.active = true
       
        CharacterSheet:Show()
        CharacterSheet:GetUI().Layer = Reward:GetUI().Layer + 1
        Reward:SetFlag("OF_PlayerModal1", false)
    end
end)