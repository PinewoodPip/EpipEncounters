
---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")
Support._AspectGraphs = nil ---@type table<string, Features.MeditateControllerSupport.AspectGraph>?

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the UI to the previous page.
---@param char EsvCharacter
function Support.ReturnToPreviousPage(char)
    local instanceID = Support._GetInstanceID(char)
    local element = Support._GetElement(instanceID, Support._GetCurrentUI(instanceID), "Back", "Back")
    if element then
        Osiris.CharacterUseItem(char, element, "AMER_UI_Ascension_NavBar_Back")
    else -- Exit the UI if it's at the starting page.
        Support.ExitUI(char)
    end
end

---Deselects any selected element. Equivalent to clicking the background.
---@param char EsvCharacter
function Support.DeselectElement(char)
    Osiris.PROC_AMER_UI_Ascension_BackgroundClicked(Support._GetInstanceID(char), char.CurrentTemplate.Id .. "_" .. char.MyGuid)
    Net.PostToCharacter(char, Support.NETMSG_SET_ASPECT_NODE, {
        NodeID = nil,
    })
end

---Causes char to exit their current meditate UI.
---@param char EsvCharacter
function Support.ExitUI(char)
    if Osi.DB_AMER_UI_UsersInUI:Get(nil, nil, char.RootTemplate.Id .. "_" .. char.MyGuid)[1] ~= nil then
        Osiris.CharacterUseSkill(char, EpicEncounters.Meditate.MEDITATE_SKILL_ID, char, 1, 1, 1)
    end
end

---Scrolls a Wheel element.
---@param instance integer
---@param ui string
---@param wheel string
---@param direction "Previous"|"Next"
function Support.ScrollWheel(instance, ui, wheel, direction)
    local charGUID = Support._GetInstanceCharacter(instance)
    local element = Support._GetElement(instance, ui, wheel, nil)
    if direction == "Previous" then
        Osi.PROC_AMER_UI_ElementWheel_Scroll_Down(charGUID, element)
    else -- "Next" direction case.
        Osi.PROC_AMER_UI_ElementWheel_Scroll_Up(charGUID, element)
    end
end

---Returns the item of an element.
---@param instance integer
---@param ui string
---@param collection string?
---@param name string?
---@return GUID?
function Support._GetElement(instance, ui, collection, name)
    return Osiris.GetFirstFactOrEmpty("DB_AMER_UI_ElementsOfInstance", instance, ui, collection, name, nil)[5]
end

---Returns the character of an instance.
---@param instance integer
---@return GUID
function Support._GetInstanceCharacter(instance)
    return Osiris.GetFirstFact("DB_AMER_UI_UsersInUI", instance, nil, nil)[3]
end

---Returns the instance ID of char.
---@param char EsvCharacter|GUID
---@return integer
function Support._GetInstanceID(char)
    local charGuid = GetExtType(char) ~= nil and char.RootTemplate.Id .. "_" .. char.MyGuid or char -- Object overload.
    return Osiris.GetFirstFact("DB_AMER_UI_UsersInUI", nil, nil, charGuid)[1]
end

---Returns the current page of an instance.
---@param instance integer
---@return string, integer -- Page ID and stack index.
function Support._GetCurrentPage(instance)
    local fact = Osiris.GetFirstFact("DB_AMER_UI_CurrentPage", instance, nil, nil, nil)
    return fact[3], fact[4]
end

---Returns the current UI of an instance.
---@param instance integer
---@return string
function Support._GetCurrentUI(instance)
    local fact = Osiris.GetFirstFact("DB_AMER_UI_CurrentPage", instance, nil, nil, nil)
    return fact[2]
end

---Sends node graph data to all clients.
function Support._SendNodeData()
    local nodes = Osi.DB_AMER_UI_ElementChain_Node:Get(nil, "AMER_UI_Ascension", nil, nil, nil, nil, nil);
    local graphs = {} ---@type table<string, Features.MeditateControllerSupport.AspectGraph>
    for _,tuple in ipairs(nodes) do
        ---@diagnostic disable-next-line: unused-local
        local aspect, nodeID, x, y = tuple[3], tuple[4], tuple[6], tuple[7]
        if aspect == "Crossroads" then goto continue end -- The Core is a special case, already handled by the Graph page type.

        -- Initialize graph
        local graph
        if not graphs[aspect] then
            ---@type Features.MeditateControllerSupport.AspectGraph
            graphs[aspect] = {
                AspectID = aspect,
                StartingNode = nodeID, -- Nodes are defined in order.
                Nodes = {},
                NodeOrder = {},
            }
        end
        graph = graphs[aspect]

        ---@type Features.MeditateControllerSupport.Page.AspectGraph.Node
        local node = {
            ID = nodeID,
            CollectionID = aspect,
            EventID = "AMER_UI_ElementChain_NodeUse",
            Neighbours = {}, -- Determined later.
            Rotation = nil,
            Subnodes = Osiris.GetFirstFactOrEmpty("DB_AMER_UI_ElementChain_Node_ChildNode_Count", -1, "AMER_UI_Ascension", aspect, nodeID, nil)[5] or 0, -- The final Demilich node has no subnodes.
        }
        graph.Nodes[nodeID] = node
        table.insert(graph.NodeOrder, nodeID)
        ::continue::
    end

    for _,aspect in pairs(graphs) do
        for i,nodeID in ipairs(aspect.NodeOrder) do
            local node = aspect.Nodes[nodeID]

            -- Define neighbours
            -- Nodes with forking paths are deprecated; we assume all nodes are sequential.
            local previous, next = aspect.NodeOrder[i - 1], aspect.NodeOrder[i + 1]
            if previous then
                table.insert(node.Neighbours, previous)
            end
            if next then
                table.insert(node.Neighbours, next)
            end
        end
    end

    Support._AspectGraphs = graphs
    Net.Broadcast(Support.NETMSG_SEND_NODE_DATA, {
        Aspects = graphs,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- TODO remove
Osiris.RegisterSymbolListener("CharacterItemEvent", 3, "after", function(char, item, event)
    if string.find(event, "AMER") then
        print("CharacterItemEvent", char, item, event)
    end
end)

---Interacts with an element, simulating a click on it (item use).
---@param char EsvCharacter
---@param collectionID string
---@param elementID string
---@param eventID string
function Support.InteractWithElement(char, collectionID, elementID, eventID)
    local instanceID = Support._GetInstanceID(char)
    local element = Osi.DB_AMER_UI_ElementsOfInstance:Get(instanceID, Support._GetCurrentUI(instanceID), collectionID, elementID, nil)[1][5]
    Osiris.CharacterUseItem(char, element, eventID)
end

Net.RegisterListener(Support.NETMSG_INTERACT, function (payload)
    local char = payload:GetCharacter()
    -- TODO page sanity checks
    Support.InteractWithElement(char, payload.CollectionID, payload.ElementID, payload.EventID)
end)

-- Handle requests to scroll and interact with wheels.
Net.RegisterListener(Support.NETMSG_SCROLL_WHEEL, function (payload)
    local instanceID = Support._GetInstanceID(payload:GetCharacter())
    -- TODO page sanity checks
    Support.ScrollWheel(instanceID, Support._GetCurrentUI(instanceID), payload.WheelID, payload.Direction)
end)
Net.RegisterListener(Support.NETMSG_INTERACT_WHEEL, function (payload)
    local char = payload:GetCharacter()
    local instanceID = Support._GetInstanceID(char)
    -- TODO page sanity checks
    local tuples = Osi.DB_AMER_UI_ElementsOfInstance:Get(instanceID, Support._GetCurrentUI(instanceID), payload.WheelID, nil, nil)
    local element = tuples[2][5] -- The center element of the wheel is the one that's used to navigate to other pages.
    Osiris.CharacterUseItem(char, element, payload.EventID)
end)

-- Exit the UI when lua is reset, for testing convenience,
-- as the libraries do not support the UI being open right after initialization.
Ext.Events.ResetCompleted:Subscribe(function (_)
    local host = Character.Get(Osiris.CharacterGetHostCharacter())
    Support.ExitUI(host)
end)

-- Handle requests to return to the previous page, deselect elements or exit the UI.
Net.RegisterListener(Support.NETMSG_BACK, function (payload)
    local char = payload:GetCharacter()
    Support.ReturnToPreviousPage(char)
end)
Net.RegisterListener(Support.NETMSG_DESELECT, function (payload)
    Support.DeselectElement(payload:GetCharacter())
end)
Net.RegisterListener(Support.NETMSG_EXIT, function (payload)
    local char = payload:GetCharacter()
    Support.ExitUI(char)
end)

-- Track selected aspect and node changes.
Osiris.RegisterSymbolListener("PROC_AMER_UI_Ascension_SelectedElement_Set", 10, "after", function (instance, _, cluster) -- Second parameter is path.
    if cluster ~= "Crossroads" then
        local char = Support._GetInstanceCharacter(instance)
        Net.PostToCharacter(char, Support.NETMSG_SET_ASPECT, {
            AspectID = cluster,
        })
    end
end)
Osiris.RegisterSymbolListener("PROC_AMER_UI_ElementChain_Node_Used", 7, "after", function (char, _, _, cluster, node)
    if cluster ~= "Crossroads" then
        Net.PostToCharacter(Character.Get(char), Support.NETMSG_SET_ASPECT_NODE, {
            NodeID = node,
        })
    end
end)

-- Update state for clients when changing characters while in the UI.
Ext.Osiris.RegisterListener("PROC_AMER_UI_ActiveCharChanging", 5, "after", function(_, instance, _, _, newChar)
    local char = Character.Get(newChar)
    local page = Support._GetCurrentPage(instance)
    if page == "Page_Cluster" then
        local tuple = Osiris.GetFirstFact("DB_AMER_UI_Ascension_SelectedElement", instance, nil, nil, nil, nil)
        Net.PostToCharacter(char, Support.NETMSG_SET_ASPECT, {
            AspectID = tuple[3],
        })
        Net.PostToCharacter(char, Support.NETMSG_SET_ASPECT_NODE, {
            NodeID = nil, -- The subnode flower is closed on character change. TODO support this state better
        })
    end
end)

-- Handle requests to select subnodes.
Net.RegisterListener(Support.NETMSG_SELECT_SUBNODE, function (payload)
    local char = payload:GetCharacter()
    local instanceID = Support._GetInstanceID(char)
    local selectedElement = Osiris.GetFirstFactOrEmpty("DB_AMER_UI_Ascension_SelectedElement", instanceID, nil, nil, nil, nil)[4]
    local isDifferentNode = true
    if selectedElement then
        -- Check if the user is requesting to select the same node again;
        -- if so, interacting with it again would toggle the node.
        local subnodeIndex = string.match(selectedElement, "Node_%d+%.(%d+)")
        if subnodeIndex then -- The user might have the main node selected instead.
            isDifferentNode = (tonumber(subnodeIndex) + 1) ~= payload.SubnodeIndex
        end
    end
    -- Interact with the node if it's different from the previously-selected one,
    -- or if explicitly allowed to toggle subnodes.
    if isDifferentNode or payload.AllowToggle then
        Support.InteractWithElement(char, payload.CollectionID, payload.ElementID, "AMER_UI_ElementChain_ChildNodeUse")
    end
end)

-- Handle requests to toggle subnodes.
Net.RegisterListener(Support.NETMSG_TOGGLE_SUBNODE, function (payload)
    local char = payload:GetCharacter()
    local instanceID = Support._GetInstanceID(char)
    local selectedElement = Osiris.GetFirstFact("DB_AMER_UI_Ascension_SelectedElement", instanceID, nil, nil, nil, "Node")
    if selectedElement and string.find(selectedElement[4], "%.") then -- Ensure the selected element is a subnode (contains a dot).
        Support.InteractWithElement(char, selectedElement[3], selectedElement[4], "AMER_UI_ElementChain_ChildNodeUse")
    end
end)

-- Handle requests to select the next unobtained node of an aspect.
Net.RegisterListener(Support.NETMSG_SELECT_NEXT_UNOBTAINED_NODE, function (payload)
    local char = payload:GetCharacter()
    local instanceID = Support._GetInstanceID(char)
    local aspectID = Osi.DB_AMER_UI_Ascension_SelectedElement:Get(instanceID, nil, nil, nil, nil)[1][3]
    local aspect = Support._AspectGraphs[aspectID]

    -- Determine the next unobtained node
    local allocatedNodes = #Osi.DB_AMER_UI_ElementChain_Node_ChildNode_StateData:Get(char.CurrentTemplate.Id .. "_" .. char.MyGuid, "AMER_UI_Ascension", aspectID, nil, nil)
    local nextNodeIndex = math.clamp(allocatedNodes + 1, 1, #aspect.NodeOrder) -- Clamp to last node.

    -- Interact with the node
    local element = Osi.DB_AMER_UI_ElementsOfInstance:Get(instanceID, Support._GetCurrentUI(instanceID), aspectID, aspect.NodeOrder[nextNodeIndex], nil)[1][5]
    Support:DebugLog("Interacting with next unobtained node", nextNodeIndex, aspectID)
    Osiris.CharacterUseItem(char, element, "AMER_UI_ElementChain_NodeUse") -- State on the client will be updated by the PROC listener.
end)

-- Handle requests to adjust zoom level.
Net.RegisterListener(Support.NETMSG_ADJUST_ZOOM, function (payload)
    local char = payload:GetCharacter()
    Osiris.PROC_AMER_UI_Camera_Zoom(char, payload.Adjustment == "ZoomOut" and 1 or -1)
end)

-- Send node data to clients connecting.
GameState.Events.ClientReady:Subscribe(function (_)
    Support._SendNodeData()
end)
