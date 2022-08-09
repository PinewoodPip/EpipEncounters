
local GameTalentsClient = {
    CharacterCreation = {},
    CharacterCreationC = {},
    ui = nil,
    root = nil,

    hiddenTalents = {},
    talentToRender = "",
    talentPoints = 0,
    characterCreationTalentOffset = 0,
    mirrorModifiedTalents = {},
    isCharacterCreation = false,

    TALENT_DISPLAY_STATE = {
        ACTIVE = 0,
        GRANTED_FROM_ITEM = 1,
        AVAILABLE = 2,
        UNAVAILABLE = 3,
    },

    COLORS = {
        TALENT_AVAILABLE = "#403625",
        TALENT_UNAVAILABLE = "#C80030"
    },
}
for i,v in pairs(GameTalentsClient) do Game.Talents[i] = v end

local Talents = Game.Talents

function Talents.AddTalent(self, char, id, isMirror)
    -- Keep track of talents added in mirror. These are not yet present as tags on the character.
    if isMirror then
        Talents.mirrorModifiedTalents[id] = 1
    end

    Net.PostToServer("EPIPENCOUNTERS_CharacterSheet_AddTalent", {NetID = char.NetID, Talent = id})
end

function Talents.RemoveTalent(self, char, id, isMirror)
    if isMirror then
        Talents.mirrorModifiedTalents[id] = -1
    end

    Net.PostToServer("EPIPENCOUNTERS_CharacterSheet_RemoveTalent", {NetID = char.NetID, Talent = id})
end

function Talents:HideTalent(id)
    self.hiddenTalents[id] = true
end

Net.RegisterListener("EPIPENCOUNTERS_Talents_SendPoints", function(channel, payload)
    -- Ext.Print("set from net")
    if not Talents.isCharacterCreation then
        Talents.talentPoints = payload.Points
        Talents:RenderTalents(Ext.UI.GetByType(Client.UI.Data.UITypes.characterSheet))
    end
end)

Ext.RegisterNetListener("EPIPENCOUNTERS_CharacterSheet_RefreshTalents", function(cmd, payload)
    -- This breaks updating the sheet the next time it is opened, and was completely unnecessary.
    -- Talents.root.stats_mc.ClickTab(3)

    local contents = Ext.Json.Parse(payload)

    Talents.characterCreationTalentOffset = Talents.characterCreationTalentOffset + contents.TalentPointsOffset

    -- Ext.Print("refreshing...")
    -- Ext.Print(Talents.characterCreationTalentOffset)

    local characterCreation = Ext.UI.GetByType(Client.UI.Data.UITypes.characterCreation)
    if characterCreation then
        local root = characterCreation:GetRoot()

        Talents.UpdateTalentPointsCounter()

        Talents:RenderTalents(characterCreation)
    end
end)

function Talents:ResetCharacterCreation()
    Talents.characterCreationTalentOffset = 0
    Talents.mirrorModifiedTalents = {}
    Talents:RenderTalents(Ext.UI.GetByType(Client.UI.Data.UITypes.characterCreation))
end
-- Reset points offset and mirror talent tracking when preset is changed
Utilities.Hooks.RegisterListener("UI_CharacterCreation", "PresetWasChanged", function(option)
    Talents:ResetCharacterCreation()
end)

Net.RegisterListener("EPIPENCOUNTERS_Talents_CharacterCreationFinished", function(channel, payload)
    Talents.characterCreationTalentOffset = 0
    Talents.mirrorModifiedTalents = {}

    -- Talents.ui:Show() -- todo find the cause of this - sheet no longer receives update the first time it is opened after respec
    -- Talents.ui:Hide()
end)

function Talents.IsTalentAvailable(self, char, talent, isVanilla)
    if isVanilla then
        Utilities.LogWarning("CharacterSheet.Talents", "Vanilla talent checks unimplemented")
        return true
    end

    local data = self:GetCustomTalentData(talent)

    if Talents.mirrorModifiedTalents[talent] ~= nil then
        return true
    end

    return self:MeetsRequirements(char, talent)
end

function Talents.HasTalent(self, char, talent, isVanilla)
    if isVanilla then
        Utilities.LogWarning("CharacterSheet.Talents", "Vanilla talent checkcs unimplemented")
        return true
    end

    -- if we're in the mirror, use the temporary table
    if Talents.mirrorModifiedTalents[talent] ~= nil then
        return Talents.mirrorModifiedTalents[talent] == 1
    end

    return char:HasTag(talent)
end

-- TODO keep track of ability changes within the mirror
-- Net.RegisterListener("EPIPENCOUNTERS_Talents_CountAbilities", function(channel, payload)
--     local char = Client.GetCharacter()

--     Ext.Print("stats:")
--     Ext.Print(char.Stats.WarriorLore)
-- end)

function Talents.HasTalentPoint(self, char)
    local points = Talents.GetAvailablePoints()
    return points > 0
end

function Talents.RerenderPreviousContents()
    if not Talents.previousContents then return nil end
    for i,v in pairs(Talents.previousContents) do
        Talents.characterCreationUI:GetRoot().CCPanel_mc.talents_mc.addTalentElement(v.params.id, v.params.label, v.params.chosen, v.params.org, false)
    end
end

function Talents.RenderTalents(self, ui)
    if true then return nil end
    if ui == nil then
        Utilities.LogWarning("Client.Talents", "Tried to render talents without passing a UI!")
        return nil
    end
    local uiType = ui:GetTypeId()
    local char = Client.GetCharacter()

    local index = 999
    for id,data in pairs(self.customTalents) do
        local state = self.TALENT_DISPLAY_STATE.UNAVAILABLE
        local color = self.COLORS.TALENT_UNAVAILABLE
        local plusButtonActive = false
        local hasTalent = self:HasTalent(char, id)
        
        -- item-granted talents not implemented
        if self:HasTalent(char, id) then
            state = self.TALENT_DISPLAY_STATE.ACTIVE
            color = ""
        elseif self:IsTalentAvailable(char, id, false) then
            state = self.TALENT_DISPLAY_STATE.AVAILABLE
            color = self.COLORS.TALENT_AVAILABLE
        end

        plusButtonActive = state == self.TALENT_DISPLAY_STATE.AVAILABLE and self:HasTalentPoint(char)

        if uiType == Client.UI.Data.UITypes.characterSheet then
            self.root.stats_mc.addTalent(string.format("<font color='%s'>%s</font>", color, data.name), index, state, id)
            self.root.stats_mc.setTalentPlusVisible(index, plusButtonActive)
        elseif uiType == Client.UI.Data.UITypes.characterCreation then
            local root = ui:GetRoot()

            root.CCPanel_mc.talents_mc.addTalentElement(index, data.name, hasTalent, self:IsTalentAvailable(char, id, false) or hasTalent, false, id)

        elseif uiType == Client.UI.Data.UITypes.examine then
            local root = ui:GetRoot()

            -- TODO
            root.addStat(3, index, 0, data.name, "")
        end

        if uiType == Client.UI.Data.UITypes.characterCreation then
            Talents.UpdateTalentPointsCounter()

            ui:GetRoot().CCPanel_mc.talents_mc.talentList.positionElements()
            
            Talents.RerenderPreviousContents()
        end

        index = index + 1
    end
end

local function OnSheetArrayUpdate(ui, method)
    Talents.root.clearTalentsForReal()

    local contents = ParseFlashArray(ui:GetRoot().talent_array, {
        {name = "talent", params = {
            "label", "id", "state"
        }}
    }, 0)

    local buttonStates = ParseFlashArray(ui:GetRoot().lvlBtnTalent_array, {
        {name = "talent", params = {
            "operationType", "id", "bool"
        }}
    }, 0)

    -- Ext.Dump(buttonStates)
    -- Ext.Dump(contents)

    local newTable = {}
    for i,v in pairs(contents) do
        if not Talents.hiddenTalents[v.params.id] then
            table.insert(newTable, v.params.label)
            table.insert(newTable, v.params.id)
            table.insert(newTable, v.params.state)
        end
    end
    table.insert(newTable, -99)

    Game.Tooltip.TableToFlash(ui, "talent_array", newTable) -- send back to flash

    Talents:RenderTalents(ui)
end
Client.UI.CharacterSheet:RegisterInvokeListener("updateArraySystem", function(ev)
    local root = ev.UI:GetRoot()
    local arr = root.talent_array

    for i=1,128,1 do
        local index = (i - 1) * 3
        arr[index] = tostring(i)
        arr[index + 1] = i
        arr[index + 2] = false
    end
end)

local function OnTalentAdded(ui, method, id, customTalentId)
    if customTalentId == "" then
        ui:ExternalInterfaceCall("plusTalent", id)
        return nil
    end

    Talents:AddTalent(Client.GetCharacter(), customTalentId)
end

local function OnTalentRemoved(ui, method, id, customTalentId)
    if customTalentId == "" then
        ui:ExternalInterfaceCall("minusTalent", id)
        return nil
    end
end

local function OnTalentTooltipRequest(ui, method, tooltipId, x, y, loc6, height, align, id, customTalentId)

    local handle = ui:GetPlayerHandle()
    local player

    if not handle then
        player = Client.UI.EnemyHealthBar.latestCharacter
    else
        player = Ext.UI.HandleToDouble(handle)
    end

    Talents.talentToRender = customTalentId

    if customTalentId ~= "" then
        if ui:GetTypeId() == Client.UI.Data.UITypes.examine then
            ui:ExternalInterfaceCall("showTooltip", 3, tooltipId, x, y, loc6, height, "right")
        else
            ui:ExternalInterfaceCall("showTalentTooltip", 1, player, y, 340, loc6, height, "none")
        end
    else
        ui:ExternalInterfaceCall("showTalentTooltip", id, player, y, 340, loc6, height, "none")
    end
end

local function OnSheetTalentTooltipRender(char, stat, tooltip)
    if Talents.talentToRender == "" then return nil end

    local data = Talents:GetCustomTalentData(Talents.talentToRender)
    local selectable = Talents:IsTalentAvailable(char, Talents.talentToRender)

    -- name and description
    tooltip:GetElement("StatName").Label = data.name
    local descElement = tooltip:GetElement("TalentDescription")
    descElement.Description = data.tooltip
    descElement.Selectable = selectable

    -- requirements text
    local requirements = ""
    for req,amount in pairs(data.requirements.abilities) do
        requirements = requirements .. string.format("Requires %d %s", amount, Data.Game.ABILITIES[req]) .. "\n"
    end
    for req,amount in pairs(data.requirements.attributes) do
        requirements = requirements .. string.format("Requires %d %s", amount, Data.Game.ATTRIBUTES[req]) .. "\n"
    end
    descElement.Requirement = requirements

    -- set icon
    local tooltipUI = Ext.UI.GetByType(Client.UI.Data.UITypes.tooltip)
    tooltipUI:SetCustomIcon("tt_talent_" .. Text.RemoveTrailingZeros(descElement.TalentId), data.icon, 128, 128)

    Talents.talentToRender = ""
end

function Talents.UpdateTalentPointsCounter()
    local root = Ext.UI.GetByType(Client.UI.Data.UITypes.characterCreation):GetRoot()
    local points = Talents.GetAvailablePoints()

    -- Ext.Print("---")
    -- Ext.Print(Talents.talentPoints)
    -- Ext.Print(Talents.characterCreationTalentOffset)

    if root.textArray == nil or root.textArray[15] == nil then return nil end

    root.availableTalentPoints = points
    root.CCPanel_mc.talents_mc.availablePoints_txt.htmlText = root.textArray[15] .. " " .. Text.RemoveTrailingZeros(points);
end

function Talents.GetAvailablePoints() -- todo figure out what bugs this... happens when you add a normal and custom talent before entering mirror, fixed on uses afterwards
    return math.max(Talents.talentPoints + Talents.characterCreationTalentOffset, 0)
end

function OnCharacterCreationTalents(ui, method)
    local contents = ParseFlashArray(ui:GetRoot().talentArray, {
        {name = "talent", params = {
            "id", "label", "chosen", "org",
        }}
    }, 1) -- first element are talent points
    -- Ext.Dump(contents)

    Talents.previousContents = contents

    for i,v in pairs(Talents.previousContents) do
        if Talents.hiddenTalents[v.params.id] then
            table.remove(Talents.previousContents, i)
        end
    end

    Talents.characterCreationUI = ui

    Talents:RenderTalents(ui)

    -- local root = ui:GetRoot()
    -- for i=1,#Talents.previousContents,1 do
    --     local data = Talents.previousContents[i]
    --     local baseIndex = (i - 1) * 4

    --     root.talentArray[baseIndex] = 
    -- end
    -- for i,v in ipairs(Talents.previousContents) do
    --     ui:GetRoot().CCPanel_mc.talents_mc.addTalentElement(v.params.id, v.params.label, v.params.chosen, v.params.org, false)
    -- end

    -- Net.PostToServer("EPIPENCOUNTERS_Talents_RequestPoints", {NetID = Client.GetCharacter().NetID})
end

Client.UI.CharacterCreation:RegisterInvokeListener("updateTalents", function(ev)
    local root = ev.UI:GetRoot()
    local talents = root.talentArray
    local racials = root.racialTalentArray

    for i=1,#talents-1,4 do
        if not Talents.hiddenTalents[talents[i]] then
            root.CCPanel_mc.talents_mc.addTalentElement(talents[i], talents[i+1], talents[i+2], talents[i+3], false)
        end
    end

    for i=0,#racials-1,2 do
        root.CCPanel_mc.talents_mc.addTalentElement(racials[i], racials[i+1], true, false, true)
    end

    root.CCPanel_mc.talents_mc.positionLists()
    ev:PreventAction()
end)

function OnCharacterCreationTalentToggle(ui, method, id, customTalentId, isActive)
    local char = Client.GetCharacter()

    if customTalentId == "" or customTalentId == nil then
        ui:ExternalInterfaceCall("toggleTalent", id)
        if isActive then
            Talents.talentPoints = Talents.talentPoints + 1
        else
            Talents.talentPoints = Talents.talentPoints - 1
        end
    else
        if Talents:HasTalent(char, customTalentId, false) then
            Talents:RemoveTalent(char, customTalentId, true)
        else
            Talents:AddTalent(char, customTalentId, true)
        end
    end
    
    Talents.UpdateTalentPointsCounter()
    Talents:RenderTalents(ui)
end

-- Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.characterSheet, "setAvailableStatPoints", function(ui, method, num)
--     Ext.Print(num)
-- end)

Ext.Events.SessionLoaded:Subscribe(function()
    Talents.ui = Ext.UI.GetByType(Client.UI.Data.UITypes.characterSheet)
    Talents.root = Talents.ui:GetRoot()

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.characterSheet, "updateArraySystem", OnSheetArrayUpdate)

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.characterCreation, "updateTalents", OnCharacterCreationTalents)
    Ext.RegisterUITypeCall(Client.UI.Data.UITypes.characterCreation, "pipShowTalentTooltip", function(ui, method, handle, talentId, x, y, w, h, align, customTalentId)
        if customTalentId ~= "" and customTalentId ~= nil then
            talentId = 1
            Talents.talentToRender = customTalentId
        end
        ui:ExternalInterfaceCall("showTalentTooltip", handle, talentId, x, y, w, h, align)
    end)

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.characterCreation, "setPanel", function(ui, method, p1, p2)
        if p1 == 0 and p2 == 0 then
            Talents.isCharacterCreation = true
            -- Talents.characterCreationTalentOffset = Talents.characterCreationTalentOffset + 99 -- todo fix properly
            Talents.characterCreationTalentOffset = 0
        end

        Talents:RenderTalents(Ext.UI.GetByType(Client.UI.Data.UITypes.characterCreation))
    end)

    Ext.RegisterUITypeCall(Client.UI.Data.UITypes.characterCreation, "plusAbility", function(ui, method, id, isCivil)
        Talents:RenderTalents(Ext.UI.GetByType(Client.UI.Data.UITypes.characterCreation))
    end)

    Ext.RegisterUITypeCall(Client.UI.Data.UITypes.characterCreation, "minAbility", function(ui, method, id, isCivil)
        Talents:RenderTalents(Ext.UI.GetByType(Client.UI.Data.UITypes.characterCreation))
    end)

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.characterSheet, "setAvailableTalentPoints", function(ui, method, amount)
        -- TODO does this cause issues?
        -- Ext.Print("set from sheet")
        Talents.talentPoints = amount
    end)

    Ext.RegisterUICall(Talents.ui, "pipMinusTalent", OnTalentRemoved)
    Ext.RegisterUICall(Talents.ui, "pipPlusTalent", OnTalentAdded)
    Ext.RegisterUICall(Talents.ui, "pipShowTalentTooltip", OnTalentTooltipRequest)
    Ext.RegisterUICall(Client.UI.Examine:GetUI(), "pipShowTalentTooltip", OnTalentTooltipRequest)
    Ext.RegisterUINameCall("pipToggleTalent", OnCharacterCreationTalentToggle)

    -- Character creation point update
    Ext.RegisterUINameCall("pipAvailablePointsSet", function(ui, method, pointType, amount)
        if pointType == 4 then
            -- Ext.Print("set from pip call")
            Talents.talentPoints = amount
        end
        Talents.UpdateTalentPointsCounter()
        Talents:RenderTalents(ui)
    end)

    -- re-render all talents after the normal update to properly update the visibility of the + button.
    Ext.RegisterUINameCall("pipTalentsUpdated", function(ui, method, p1, p2)
        -- Talents.UpdateTalentPointsCounter()
        
        -- local points = Talents.GetAvailablePoints()
        -- for i,v in pairs(Talents.previousContents) do
        --     Talents.characterCreationUI:GetRoot().CCPanel_mc.talents_mc.addTalentElement(v.params.id, v.params.label, v.params.chosen, v.params.org, false)
        -- end
    end, "After")

    Game.Tooltip.RegisterListener("Talent", nil, OnSheetTalentTooltipRender)
end)

-- Show custom talents in examine menu
Client.UI.Examine:RegisterHook("Update", function(examineData)
    local char = Client.UI.EnemyHealthBar.latestCharacter
    if not char then return nil else char = Character.Get(char) end

    local category = examineData:GetCategory(Client.UI.Examine.CATEGORIES.TALENTS)

    for id,data in pairs(Talents.customTalents) do
        if (Talents:HasTalent(char, id)) then
            examineData:InsertElement(category.id, {
                id = 1,
                label = data.name,
                iconID = Client.UI.Examine.ICONS.NONE,
                value = id,
                type = Client.UI.Examine.ENTRY_TYPES.TALENT,
            })
        end
    end

    return examineData
end)