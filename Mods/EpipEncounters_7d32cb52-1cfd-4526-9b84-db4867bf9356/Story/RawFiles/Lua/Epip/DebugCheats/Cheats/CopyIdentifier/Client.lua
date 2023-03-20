
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local action = DebugCheats.GetAction("CopyIdentifier")

---@type {Type: "Skill"|"Item"|"Character", Identifier: any}?
local lastEntity = nil

local function GetEntity()
    local data = lastEntity
    local entity

    if data then
        local entityType = data.Type

        if entityType == "Item" then
            entity = Item.Get(data.Identifier)
        end
    end

    return entity
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for skill tooltips
Client.Tooltip.Hooks.RenderSkillTooltip:Subscribe(function (ev)
    lastEntity = {
        Type = "Skill",
        Identifier = ev.SkillID,
    }
end)

-- Listen for item tooltips.
Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    lastEntity = {
        Type = "Item",
        Identifier = ev.Item.NetID,
    }
end)

-- Listen for characters being hovered.
Pointer.Events.HoverCharacterChanged:Subscribe(function (ev)
    if ev.Character then
        lastEntity = {
            Type = "Character",
            Identifier = ev.Character.NetID,
        }
    end
end)
Pointer.Events.HoverCharacter2Changed:Subscribe(function (ev)
    if ev.Character then
        lastEntity = {
            Type = "Character",
            Identifier = ev.Character.NetID,
        }
    end
end)

-- Listen for items being hovered.
Pointer.Events.HoverItemChanged:Subscribe(function (ev)
    if ev.Item then
        lastEntity = {
            Type = "Item",
            Identifier = ev.Item.NetID,
        }
    end
end)

-- Clear entity data when tooltips disappear
Client.Tooltip.Events.TooltipHidden:Subscribe(function (_)
    lastEntity = nil
end)

-- Listen for the action being executed.
action:Subscribe(function (ev) -- TODO remake into its own action type
    local entity = GetEntity() or ev.Context.TargetGameObject
    local text = entity.MyGuid

    Client.UI.MessageBox.CopyToClipboard(text)

    print("Copied " .. text .. " to clipboard.")
end)