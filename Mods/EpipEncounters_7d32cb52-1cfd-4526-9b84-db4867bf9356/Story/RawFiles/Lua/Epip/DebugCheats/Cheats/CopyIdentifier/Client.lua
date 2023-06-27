
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local action = DebugCheats.GetAction("CopyIdentifier")

---@type {Type: "Skill"|"Item"|"Character", Identifier: any}?
local lastEntity = nil

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

-- Clear entity data when tooltips disappear
Client.Tooltip.Events.TooltipHidden:Subscribe(function (_)
    lastEntity = nil
end)

-- Listen for the action being executed.
action:Subscribe(function (ev) -- TODO remake into its own action type
    local text = nil
    
    if lastEntity then
        text = lastEntity.Identifier
    elseif ev.Context.TargetGameObject then
        text = ev.Context.TargetGameObject.MyGuid
    end

    if text then
        Client.UI.MessageBox.CopyToClipboard(text)
    
        print("Copied " .. text .. " to clipboard.")
    end
end)