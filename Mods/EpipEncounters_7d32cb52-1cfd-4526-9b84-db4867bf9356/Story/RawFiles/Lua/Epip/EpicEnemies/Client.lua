
local EpicEnemies = Epip.GetFeature("Feature_EpicEnemies")
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")

---@type EpicEnemies_Hook_GetActivationConditionDescription
EpicEnemies.Hooks.GetActivationConditionDescription = EpicEnemies:AddHook("GetActivationConditionDescription")

local tab = {
    ID = EpicEnemies.SETTINGS_MODULE_ID,
    ButtonLabel = "Epic Enemies",
    HeaderLabel = Text.Format("Epic Enemies", {Color = "7e72d6", Size = 23}),
    HostOnly = true,
    Entries = {
        {Type = "Label", Label = "Epic Enemies is a randomizer feature that gives enemies in combat<br>random keyword effects, artifacts and other boons.<br><br>The sliders in this menu control the relative chance of each effect being applied; you may set them to 0 to prevent the effect from being applied.<br><br>Every effect has a certain 'point cost', reducing the possibility of enemies appearing with numerous very strong effects. You may configure this points budget to control how many effects enemies gain.<br>Enemies affected by this feature gain 2 free Generic reaction charges per turn."},
    },
}
for _,setting in ipairs(EpicEnemies._SHARED_SETTINGS) do
    table.insert(tab.Entries, {Type = "Setting", Module = EpicEnemies.SETTINGS_MODULE_ID, ID = setting.ID})
end
SettingsMenu.RegisterTab(tab)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EclCharacter
---@param visibleOnly boolean? Defaults to false.
---@return EpicEnemiesEffect[] -- In order of application(? unconfirmed)
function EpicEnemies.GetAppliedEffects(char, visibleOnly)
    local effects = {}

    -- Grab effects from tags
    for _,tag in ipairs(char:GetTags()) do
        local effectID = tag:match(EpicEnemies.EFFECT_TAG_PREFIX .. "(.+)$")

        if effectID then
            local effectData = EpicEnemies.GetEffectData(effectID)

            if effectData then
                if not visibleOnly or (visibleOnly and effectData.Visible) then
                    table.insert(effects, effectData)
                end
            else
                EpicEnemies:LogError("Found an applied effect with no data registered: " .. effectID)
            end
        end
    end

    return effects
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class EpicEnemies_Hook_GetActivationConditionDescription : Hook
---@field RegisterHook fun(self, handler:fun(text:string, condition:EpicEnemiesActivationCondition, char:EclCharacter))
---@field Return fun(self, text:string, condition:EpicEnemiesActivationCondition, char:EclCharacter)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Render effect info into the status tooltip.
Game.Tooltip.RegisterListener("Status", nil, function(char, status, tooltip)
    if status.StatusId == "PIP_OSITOOLS_EpicBossesDisplay" then
        local effects = EpicEnemies.GetAppliedEffects(char)
        local str = ""

        for _,effect in ipairs(effects) do
            if effect.Visible or effect.Visible == nil then
                local activationConditionText = EpicEnemies.Hooks.GetActivationConditionDescription:Return("", effect.ActivationCondition, char)

                str = str .. Text.Format("%s<br>%s<br>%s", {
                    FormatArgs = {
                        Text.Format(Text.Format("• ", {Size = 28}) .. effect.Name, {FontType = Text.FONTS.BOLD, Color = "088cc4"}),
                        Text.Format("      " .. effect.Description, {Size = 17}),
                        Text.Format("      " .. activationConditionText, {Size = 16}),
                    }
                })
                str = str .. "<br>"
            end
        end

        table.insert(tooltip.Data, {
            Label = str,
            Type = "StatusDescription",
            Value = 1,
        })
    end
end)

-- Render category selector.
SettingsMenu.Hooks.GetTabEntries:Subscribe(function (ev)
    if ev.Tab.ID == EpicEnemies.SETTINGS_MODULE_ID then
        ---@type Feature_SettingsMenu_Entry_Category
        local option = {
            ID = "EpicEnemies_CategorySelector",
            Type = "Category",
            Label = Text.Format("Effect Categories", {FontType = Text.FONTS.BOLD}),
            Options = {},
        }

        for i,category in ipairs(EpicEnemies.CATEGORIES) do
            ---@type Feature_SettingsMenu_Entry_Category_Option
            local optionEntry = {
                ID = i,
                Label = category.Name,
                SubEntries = {
                    {Type = "Setting", Module = EpicEnemies.SETTINGS_MODULE_ID, ID = "EpicEnemies_CategoryWeight_" .. category.ID,}
                },
            }
        
            for _,effectID in ipairs(category.Effects) do
                table.insert(optionEntry.SubEntries, {Type = "Setting", Module = EpicEnemies.SETTINGS_MODULE_ID, ID = effectID})
            end
        
            table.insert(option.Options, optionEntry)
        end

        table.insert(ev.Entries, option)
    end
end)

-- Render within Quick Examine.
local QuickExamine = Epip.Features.QuickExamine
local Generic = Client.UI.Generic
local _T = Generic.ELEMENTS.Text
QuickExamine.Events.EntityChanged:RegisterListener(function (entity)
    local container = QuickExamine.GetContainer()

    ---@type EpicEnemiesExtendedEffect[]
    local effects = EpicEnemies.GetAppliedEffects(entity, true)

    if #effects > 0 then
        -- Sort effects
        local sortedEffects = {
            Artifacts = {},
            Other = {},
        }

        for _,effect in ipairs(effects) do
            if effect.Artifact then
                table.insert(sortedEffects.Artifacts, effect)
            else
                table.insert(sortedEffects.Other, effect)
            end
        end

        effects = {}
        for _,eff in pairs(sortedEffects.Artifacts) do table.insert(effects, eff) end
        for _,eff in pairs(sortedEffects.Other) do table.insert(effects, eff) end

        local header = container:AddChild("EpicEnemies_Header", "GenericUI_Element_Text")
        header:SetText(Text.Format("Epic Enemies Effects", {Color = "ffffff", Size = 19}))
        header:SetSize(QuickExamine.GetContainerWidth(), 30)

        -- Artifact powers are already handled through the base QuickExamine script

        for _,effect in ipairs(sortedEffects.Other) do
            local entry = container:AddChild(effect.ID, "GenericUI_Element_Text")
            local activationConditionText = EpicEnemies.Hooks.GetActivationConditionDescription:Return("", effect.ActivationCondition, entity)

            local text = Text.Format(Text.Format("• ", {Size = 28}) .. effect.Name, {FontType = Text.FONTS.BOLD, Color = "088cc4"})

            if effect.Description and string.len(effect.Description) > 0 then
                text = text .. "<br>" .. Text.Format("      " .. effect.Description, {Size = 17})
            end

            if effect.ActivationCondition.Type ~= "EffectApplied" then
                text = text .. "<br>" .. Text.Format("      " .. activationConditionText, {Size = 16})
            end

            entry:SetType(_T.TYPES.LEFT_ALIGN)
            entry:SetText(Text.Format(text, {
                Color = "ffffff",
                Size = 17,
            }))
            entry:GetMovieClip().text_txt.width = QuickExamine.WIDTH
            entry:GetMovieClip().text_txt.height = entry:GetMovieClip().text_txt.textHeight
        end

        local div = container:AddChild("MainDiv", "GenericUI_Element_Divider")
        div:SetSize(QuickExamine.DIVIDER_WIDTH)
        div:SetCenterInLists(true)
    end
end)