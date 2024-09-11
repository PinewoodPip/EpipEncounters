
---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")
Support._AspectGraphs = nil ---@type table<string, Features.MeditateControllerSupport.AspectGraph>
Support._CurrentUI = nil ---@type string?
Support._CurrentPage = nil ---@type Features.MeditateControllerSupport.Page?
Support._CurrentAspectID = nil ---@type string?
Support._CurrentAspectNode = nil ---@type integer?
Support._CurrentGraphNode = nil ---@type Features.MeditateControllerSupport.Page.Graph.Node
Support._RegisteredPagesCount = 0

---------------------------------------------
-- METHODS
---------------------------------------------

---Unselects the current page, effectively disabling the overlay.
function Support.ClearPage()
    Support._CurrentUI = nil
    Support._CurrentAspectID = nil
    Support._CurrentAspectNode = nil
    Support._CurrentGraphNode = nil
    Support._CurrentPage = nil
end

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

---Requests the next unobtained node of the current aspect to be selected.
function Support.RequestSelectNextUnobtainedNode()
    if not Support._CurrentAspectID then
        Support:__Error("RequestSelectNextUnobtainedNode", "Not in aspect")
        return
    end
    Net.PostToServer(Support.NETMSG_SELECT_NEXT_UNOBTAINED_NODE, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end

---Requests the zoom level to be adjusted.
---@param adjustment Features.MeditateControllerSupport.ZoomAdjustment
function Support.RequestAdjustZoom(adjustment)
    Net.PostToServer(Support.NETMSG_ADJUST_ZOOM, {
        CharacterNetID = Client.GetCharacter().NetID,
        Adjustment = adjustment,
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
        local aspect = Support.GetAspect(Support._CurrentAspectID)
        Support._CurrentAspectNode = table.reverseLookup(aspect.NodeOrder, payload.NodeID)
        Support._CurrentGraphNode = aspect.Nodes[payload.NodeID]
    else
        Support._CurrentAspectNode = nil
        Support._CurrentGraphNode = nil
    end
    Support:DebugLog("Aspect node set", payload.NodeID)
end)
