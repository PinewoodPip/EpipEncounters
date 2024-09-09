
---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")
Support._AspectGraphs = nil ---@type table<string, Features.MeditateControllerSupport.AspectGraph>
Support._CurrentAspectID = nil ---@type string?
Support._CurrentAspectNode = nil ---@type integer?

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests to return to the previous page.
function Support.RequestReturnToPreviousPage()
    Net.PostToServer(Support.NETMSG_BACK, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end

---Requests the current element to be deselected.
function Support.RequestDeselectElement()
    Net.PostToServer(Support.NETMSG_DESELECT, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end

---Returns the amount of subnodes of a node.
---@param aspectID string
---@param nodeID string
---@return integer
function Support.GetSubnodesCount(aspectID, nodeID)
    local aspect = Support.GetAspect(aspectID)
    return aspect.Nodes[nodeID].Subnodes
end

---Returns the graph data for an aspect.
---@param aspectID string? Defaults to current aspect.
---@return Features.MeditateControllerSupport.AspectGraph
function Support.GetAspect(aspectID)
    return Support._AspectGraphs[aspectID or Support._CurrentAspectID]
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update aspect node data from the server.
Net.RegisterListener(Support.NETMSG_SEND_NODE_DATA, function (payload)
    Support._AspectGraphs = payload.Aspects
end)
Net.RegisterListener(Support.NETMSG_SET_ASPECT, function (payload)
    Support._CurrentAspectID = payload.AspectID
    Support:DebugLog("Aspect set", payload.AspectID)
end)
Net.RegisterListener(Support.NETMSG_SET_ASPECT_NODE, function (payload)
    if payload.NodeID then
        Support._CurrentAspectNode = table.reverseLookup(Support.GetAspect(Support._CurrentAspectID).NodeOrder, payload.NodeID)
    else
        Support._CurrentAspectNode = nil
    end
    Support:DebugLog("Aspect node set", payload.NodeID)
end)
