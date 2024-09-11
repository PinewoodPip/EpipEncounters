
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local GenericComponent = Navigation:GetClass("GenericUI.Navigation.Components.Generic")
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")
local CommonStrings = Text.CommonStrings
local Input = Client.Input
local V = Vector.Create

---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")
local TSK = Support.TranslatedStrings

local UI = Generic.Create("Features.MeditateControllerSupport.Overlay", {Layer = 99}) ---@class Features.MeditateControllerSupport.Overlay : GenericUI_Instance
UI.CONTROLLER_STICK_SELECT_THRESHOLD = 0.8
---@type table<integer, number[]> Maps subnodes amount to angle (in degrees) limit for each segment. Ex. if the angle is below the Nth limit, it's considered to be within the Nth segment. If the angle is beyond the last limit, it's considered to be within the first segment.
UI.SUBNODE_WHEEL_ANGLES = {
    [2] = {180, 360},
    [3] = {90, 180, 270},
    [4] = {75, 180, 250, 340}, -- This is such an annoying layout. TODO have some deadzone at the top?
    [5] = {52, 124, 196, 268, 340},
}
---@type table<integer, integer[]> Remaps segments of subnodes (in clockwise order) to their actual subnode index (1-based).
UI.SUBNODE_INDEX_REMAP = {
    [2] = {2, 1},
    [3] = {1, 3, 2},
    [4] = {2, 4, 3, 1},
    [5] = {1, 3, 5, 4, 2},
}
UI.ZOOM_STICK_THRESHOLD = 0.5
UI.ZOOM_COOLDOWN = 0.25 -- Time between zoom requests, in seconds.
UI.WHEEL_SCROLL_REPEAT_RATE = 0.25 -- In seconds.

UI._Pages = DefaultTable.Create({}) ---@type table<string, table<string, Features.MeditateControllerSupport.Page>> Maps UI to map of its pages.
UI._GraphIndexMaps = {} ---@type table<string, table<string, integer>> Maps page ID to map of node IDs to container child index.
UI._PageToContainerChildIndex = DefaultTable.Create({}) ---@type table<string, table<string, integer>> Maps UI to map of page indexes.

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.MeditateControllerSupport.Page.Type "Wheel"|"Graph"|"AspectGraph"

---@class Features.MeditateControllerSupport.Page
---@field UI string
---@field ID string
---@field Type Features.MeditateControllerSupport.Page.Type

---@class Features.MeditateControllerSupport.Page.Wheel : Features.MeditateControllerSupport.Page
---@field WheelID string
---@field SelectEventID string

---@class Features.MeditateControllerSupport.Page.Graph.Node
---@field ID string
---@field CollectionID string
---@field EventID string
---@field Neighbours string[] In clock-wise order.
---@field Rotation number? Rotation offset for determining where the "top" (first) node is relative to stick direction, in degrees. Defaults to `0`.

---@class Features.MeditateControllerSupport.Page.Graph : Features.MeditateControllerSupport.Page
---@field StartingNode string
---@field Nodes table<string, Features.MeditateControllerSupport.Page.Graph.Node>

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the overlay.
function UI.Setup()
    UI._Initialize()
    UI:Show()
    UI:TogglePlayerInput(not Client.IsInSelectorMode()) -- Restore player input if the UI was previously closed while in selector mode (ex. from manually pressing the exit button)
    Support:DebugLog("UI setup complete")
end

---Sets the current page of the UI.
---@param ui string
---@param pageID string
function UI.SetPage(ui, pageID) -- TODO move to Support
    local page = UI._Pages[ui][pageID]
    Support.ClearPage()
    if not page then
        UI:__LogWarning("Page not registered, disabling overlay", pageID)
        UI._RootNav:FocusByIndex(1) -- Focus the dummy element, so the input handlers from the previous page are no longer used.
    else
        UI._PageContainerNav:FocusByIndex(UI._PageToContainerChildIndex[ui][pageID]) -- Focus the page's element
        UI._RootNav:FocusByIndex(2) -- Focus page container
        Support._CurrentUI = ui
        Support._CurrentPage = page

        -- Select starting node
        if page.Type == "Graph" then
            ---@cast page Features.MeditateControllerSupport.Page.Graph
            UI._SelectNode(page.Nodes[page.StartingNode])
        end
        Support:DebugLog("Page set", page.ID)
    end
end

---Registers a page for use within the UI.
---@param page Features.MeditateControllerSupport.Page
function UI.RegisterPage(page)
    UI._Initialize()
    UI._Pages[page.UI][page.ID] = page
    Support._RegisteredPagesCount = Support._RegisteredPagesCount + 1
    UI._PageToContainerChildIndex[page.UI][page.ID] = Support._RegisteredPagesCount -- Should be done after writing to _Pages.

    -- Create elements
    if page.Type == "Wheel" then
        ---@cast page Features.MeditateControllerSupport.Page.Wheel
        UI._CreateWheelPage(page)
    elseif page.Type == "Graph" then
        ---@cast page Features.MeditateControllerSupport.Page.Graph
        UI._CreateEmptyPage(page)
    elseif page.Type == "AspectGraph" then
        ---@cast page Features.MeditateControllerSupport.Page.AspectGraph
        UI._CreateAspectGraphPage(page)
    end
end

---Requests the meditate UI to be exited entirely.
function UI.RequestExit()
    Net.PostToServer(Support.NETMSG_EXIT, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end

---Creates the elements for a page that doesn't use dummy elements.
---@param page Features.MeditateControllerSupport.Page
function UI._CreateEmptyPage(page)
    local element = UI:CreateElement(page.ID .. "." .. "Container", "GenericUI_Element_Empty", UI._PageContainer)
    -- TODO create an "empty" component instead of abusing List
    local _ = ListComponent:Create(element, {
        ScrollForwardEvents = {},
        ScrollBackwardEvents = {},
        Wrap = false,
    })
end

---Creates the elements for a wheel page.
---@param page Features.MeditateControllerSupport.Page.Wheel
function UI._CreateWheelPage(page)
    local element = UI:CreateElement(page.ID .. "." .. "Container", "GenericUI_Element_Empty", UI._PageContainer)
    local nav = GenericComponent:Create(element)
    nav:AddAction({
        ID = "Previous",
        Name = CommonStrings.Previous,
        Inputs = {["UILeft"] = true, ["UITabPrev"] = true},
    })
    nav:AddAction({
        ID = "Next",
        Name = CommonStrings.Next,
        Inputs = {["UIRight"] = true, ["UITabNext"] = true},
    })
    local actionLastUseTime = {} ---@type table<string, integer?> Maps ID to last use timestamp.
    nav.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Event.Timing == "Down" then
            local lastUseTime = actionLastUseTime[ev.Action.ID] or -1
            local now = Ext.Utils.MonotonicTime()
            if now - lastUseTime < UI.WHEEL_SCROLL_REPEAT_RATE * 1000 then return end -- Impose a repeat rate restriction, as the default for the InputEvents is too fast.

            if ev.Action.ID == "Previous" then
                Net.PostToServer(Support.NETMSG_SCROLL_WHEEL, {
                    CharacterNetID = Client.GetCharacter().NetID,
                    PageID = page.ID,
                    WheelID = page.WheelID,
                    Direction = "Previous",
                })
                ev.Consumed = true
            elseif ev.Action.ID == "Next" then
                Net.PostToServer(Support.NETMSG_SCROLL_WHEEL, {
                    CharacterNetID = Client.GetCharacter().NetID,
                    PageID = page.ID,
                    WheelID = page.WheelID,
                    Direction = "Next",
                })
                ev.Consumed = true
            elseif ev.Action.ID == "Interact" then
                Net.PostToServer(Support.NETMSG_INTERACT_WHEEL, {
                    CharacterNetID = Client.GetCharacter().NetID,
                    PageID = page.ID,
                    WheelID = page.WheelID,
                    EventID = page.SelectEventID,
                })
                ev.Consumed = true
            end

            actionLastUseTime[ev.Action.ID] = now
        elseif ev.Event.Timing == "Up" then
            -- Clear repeat rate cooldown.
            actionLastUseTime[ev.Action.ID] = nil
        end
    end)
end

---Creates the elements for an aspect graph page.
---@param page Features.MeditateControllerSupport.Page.AspectGraph
function UI._CreateAspectGraphPage(page)
    local element = UI:CreateElement(page.ID .. "." .. "Container", "GenericUI_Element_Empty", UI._PageContainer)
    local nav = GenericComponent:Create(element)
    nav:AddAction({
        ID = "PreviousNode",
        Name = TSK.Label_PreviousNode,
        Inputs = {["UITabPrev"] = true},
    })
    nav:AddAction({
        ID = "NextNode",
        Name = TSK.Label_NextNode,
        Inputs = {["UITabNext"] = true},
    })
    nav:AddAction({
        ID = "Back",
        Name = Text.CommonStrings.Back,
        Inputs = {["UICancel"] = true},
        IsConsumableFunctor = function (_)
            -- Only consumable when there is a node selected; otherwise let root consume it (to go back)
            return UI.IsInGraph() and Support._CurrentAspectNode or false
        end
    })
    local pressedActions = {} ---@type set<string> -- Used to prevent actions from repeating when their inputs are held down.
    nav.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Event.Timing == "Down" and not pressedActions[ev.Action.ID] then
            local aspect = Support.GetAspect()
            local currentNode = Support._CurrentGraphNode
            if ev.Action.ID == "PreviousNode" then
                if currentNode then
                    local previousNode = aspect.Nodes[currentNode.Neighbours[1]] -- Assumes no forking paths.
                    if table.reverseLookup(aspect.NodeOrder, previousNode.ID) < table.reverseLookup(aspect.NodeOrder, currentNode.ID) then -- Do not change nodes if the only neighbour is the next node.
                        UI._SelectNode(previousNode)
                        ev.Consumed = true
                    end
                else -- Select first node.
                    UI._SelectNode(aspect.Nodes[aspect.NodeOrder[1]])
                end
            elseif ev.Action.ID == "NextNode" then
                if currentNode then
                    local nextNode = aspect.Nodes[currentNode.Neighbours[2] or currentNode.Neighbours[1]] -- Assumes no forking paths.
                    if table.reverseLookup(aspect.NodeOrder, nextNode.ID) > table.reverseLookup(aspect.NodeOrder, currentNode.ID) then -- Do not change nodes if the only neighbour is the previous node.
                        UI._SelectNode(nextNode)
                        ev.Consumed = true
                    end
                else -- Select next available node.
                    Support.RequestSelectNextUnobtainedNode()
                    ev.Consumed = true
                end
            elseif ev.Action.ID == "Interact" then
                -- TODO select subnode
            elseif ev.Action.ID == "Back" and nav:GetAction("Back").IsConsumableFunctor(nav) then -- TODO remove functor check when the functor usage is made more consistent
                Support.RequestDeselectElement()
                ev.Consumed = true
            end
            pressedActions[ev.Action.ID] = true
        elseif ev.Event.Timing == "Up" then
            pressedActions[ev.Action.ID] = nil
        end
    end)
end

---Selects a node from the graph.
---@param node Features.MeditateControllerSupport.Page.Graph.Node
function UI._SelectNode(node)
    if Support._CurrentPage.Type ~= "Graph" and Support._CurrentPage.Type ~= "AspectGraph" then
        UI:__Error("_SelectNode", "Not in a graph page")
    end
    Support._CurrentGraphNode = node -- TODO wait for confirmation from the server
    if UI._CanInteract() then
        UI._Interact()
    end
end

---Returns whether there is a currently-selected element that can be interacted with.
---@return boolean
function UI._CanInteract()
    local page = Support._CurrentPage
    local canInteract = page ~= nil
    if page then
        if page.Type == "Wheel" then
            canInteract = true
        elseif page.Type == "Graph" or page.Type == "AspectGraph" then
            canInteract = Support._CurrentGraphNode ~= nil
        end
    end
    return canInteract
end

---Interacts with the current element.
function UI._Interact()
    local page = Support._CurrentPage
    if page.Type == "Wheel" then
        -- TODO? just do the useless click?
    elseif page.Type == "Graph" or page.Type == "AspectGraph" then
        local node = Support._CurrentGraphNode
        ---@type Features.MeditateControllerSupport.NetMsg.InteractWithElement
        local msg = {
            CharacterNetID = Client.GetCharacter().NetID,
            CollectionID = node.CollectionID,
            EventID = node.EventID,
            PageID = Support._CurrentPage.ID,
            ElementID = node.ID,
        }
        Net.PostToServer(Support.NETMSG_INTERACT, msg)
    end
end

---Initializes the static elements of the UI.
function UI._Initialize()
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    local pageContainer = root:AddChild("PageContainer", "GenericUI_Element_Empty")
    UI._PageContainer = pageContainer

    -- Navigation
    local pageNav = ListComponent:Create(pageContainer, {
        ScrollBackwardEvents = {}, -- The user cannot change pages manually. Flow is controlled by element interactions and global shortcuts.
        ScrollForwardEvents = {},
        Wrap = false,
    })
    local dummy = root:AddChild("Dummy", "GenericUI_Element_Empty") -- Dummy element that consumes no inputs; used for unregistered pages/UIs.
    local dummyNav = ListComponent:Create(dummy, {
        ScrollBackwardEvents = {},
        ScrollForwardEvents = {},
        Wrap = false,
    })
    UI._PageContainerNav = pageNav
    local rootNav = ListComponent:Create(root, {
        ScrollBackwardEvents = {},
        ScrollForwardEvents = {},
    })
    rootNav:AddAction({
        ID = "Interact",
        Name = Text.CommonStrings.Interact,
        Inputs = {["UIAccept"] = true},
    })
    rootNav:AddAction({
        ID = "Back",
        Name = Text.CommonStrings.Back,
        Inputs = {["UICancel"] = true},
    })
    rootNav:AddAction({
        ID = "Exit",
        Name = Text.CommonStrings.Exit,
        Inputs = {["ToggleInGameMenu"] = true},
    })
    rootNav.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Event.Timing == "Down" then
            if ev.Action.ID == "Interact" and UI._CanInteract() then
                UI._Interact()
                ev.Consumed = true
            elseif ev.Action.ID == "Back" then
                Support.RequestReturnToPreviousPage()
                ev.Consumed = true
            elseif ev.Action.ID == "Exit" then
                UI.RequestExit()
                ev.Consumed = true
            end
        end
    end)
    rootNav:SetChildren({dummyNav, pageNav})
    UI._RootNav = rootNav
    Controller.Create(UI, rootNav)
    rootNav:FocusByIndex(1)

    UI:Hide()
    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Enable the overlay when entering meditate.
Game.Ascension:RegisterListener("ClientToggledMeditating", function (entered)
    if entered then
        UI.Setup()
    else
        UI:Hide()
    end
end)

-- Disable the overlay when in selector mode.
Client.Events.SelectorModeChanged:Subscribe(function (ev)
    UI:TogglePlayerInput(not ev.Enabled)
end, {EnabledFunctor = function () return UI:IsVisible() end})

-- Navigate graphs with the left stick.
local isPastThreshold = false
Input.Events.StickMoved:Subscribe(function (ev)
    if ev.Stick ~= "Left" then return end -- Only left stick is used for node navigation.
    local direction = V(table.unpack(ev.NewState))
    local directionLength = Vector.GetLength(direction)
    if directionLength >= UI.CONTROLLER_STICK_SELECT_THRESHOLD then -- Consider a deadzone.
        -- Do not consider more inputs until the stick is reset to a neutral position.
        if isPastThreshold then return end
        isPastThreshold = true

        -- If there is no node selected,
        -- select the starting node regardless of stick direction.
        if not Support._CurrentGraphNode and Support._CurrentAspectID then
            local aspect = Support.GetAspect(Support._CurrentAspectID)
            UI._SelectNode(aspect.Nodes[aspect.StartingNode])
            return
        end

        local page = Support._CurrentPage
        local node = Support._CurrentGraphNode
        local rotation = node.Rotation or 0
        local slotsAmount = Support._CurrentAspectNode and Support.GetSubnodesCount(Support._CurrentAspectID, node.ID) or #node.Neighbours -- In aspect graphs the left stick navigates subnodes instead.
        local anglePerSlot = (2 * math.pi) / slotsAmount
        local firstSegmentStart = V(0, -1) -- Top of the stick is (0, -1)
        if page.Type ~= "AspectGraph" then -- Adjust the "start" of the wheel outside of aspects (which have manually-defined angle limits for each subnode segment)
            firstSegmentStart = Vector.Rotate(firstSegmentStart, -math.deg(anglePerSlot / 2) + rotation)
        end
        local angle = Vector.Angle(direction, firstSegmentStart)

        -- Determine if the stick is on the other side of the wheel (past the 180 deg point) to calculate the 360 angle
        local crossProd = firstSegmentStart[1] * direction[2] - firstSegmentStart[2] * direction[1]
        if crossProd < 0 then
            angle = math.rad(360) - angle
        end
        local fraction = angle / (2 * math.pi)
        local slotIndex = math.floor(slotsAmount * fraction) + 1
        slotIndex = math.clamp(slotIndex, 1, slotsAmount)

        if page.Type == "Graph" then
            ---@cast page Features.MeditateControllerSupport.Page.Graph
            UI._SelectNode(page.Nodes[node.Neighbours[slotIndex]])
        elseif page.Type == "AspectGraph" then
            ---@cast page Features.MeditateControllerSupport.Page.AspectGraph
            ---@cast node Features.MeditateControllerSupport.Page.AspectGraph.Node

            -- Determine which segment and subnode is being selected
            local subnodesAmount = node.Subnodes
            local angles = UI.SUBNODE_WHEEL_ANGLES[subnodesAmount]
            local segmentIndex = 1
            local degrees = fraction * 360
            for i,angleLimit in ipairs(angles) do
                if degrees < angleLimit then
                    segmentIndex = i
                    break
                end
            end
            local subnodeIndex = UI.SUBNODE_INDEX_REMAP[subnodesAmount][segmentIndex]

            ---@type Features.MeditateControllerSupport.NetMsg.InteractWithElement
            local msg = {
                CharacterNetID = Client.GetCharacter().NetID,
                CollectionID = node.CollectionID,
                EventID = "AMER_UI_ElementChain_ChildNodeUse",
                PageID = page.ID,
                ElementID = string.format("Node_%s.%s", math.floor(Support._CurrentAspectNode - 1), math.floor(subnodeIndex - 1)),
            }
            Net.PostToServer(Support.NETMSG_INTERACT, msg)
        end
    elseif directionLength > 0 then
        isPastThreshold = false
    end
end, {EnabledFunctor = function ()
    return UI:IsVisible() and UI:GetUI().OF_PlayerInput1 and UI.IsInGraph()
end})

---Returns whether the navigation is currently within a graph-like collection.
---@return boolean
function UI.IsInGraph()
    local page = Support._CurrentPage
    return page and (page.Type == "Graph" or page.Type == "AspectGraph") or false
end

-- Track page changes.
Net.RegisterListener("EPIPENCOUNTERS_AMERUI_StateChanged", function (payload)
    if Character.Get(payload.Character) == Client.GetCharacter() then
        if payload.Interface then
            UI.SetPage(payload.Interface, payload.Page)
        else
            UI._RootNav:FocusByIndex(1) -- Focus the dummy element, so the input handlers from the previous page are no longer used.
            Support.ClearPage()
        end
    end
end)

-- Request to change zoom level.
local lastZoomTime = -1
Input.Events.StickMoved:Subscribe(function (ev)
    if ev.Stick == "Right" then
        local direction = ev.NewState[2] -- Y axis.
        local now = Ext.Utils.MonotonicTime()
        if math.abs(direction) >= UI.ZOOM_STICK_THRESHOLD and (now - lastZoomTime) / 1000 >= UI.ZOOM_COOLDOWN then -- Consider deadzone and a cooldown to control "repeat rate" - the event is likely to fire so long as the stick is held due to micro-adjustments.
            Support.RequestAdjustZoom(direction > 0 and "ZoomOut" or "ZoomIn") -- Push up for zoom-in.
            lastZoomTime = Ext.Utils.MonotonicTime()
        end
    end
end, {EnabledFunctor = function ()
    return UI:IsVisible() and UI:GetUI().OF_PlayerInput1
end})

---------------------------------------------
-- SETUP
---------------------------------------------

---@type Features.MeditateControllerSupport.Page.Graph
local Crossroads = {
    UI = "AMER_UI_Ascension",
    ID = "Page_MainHub",
    Type = "Graph",
    Nodes = {
        ["Force"] = {
            ID = "Force",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_0",
            },
        },
        ["Life"] = {
            ID = "Life",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_1",
            },
        },
        ["Form"] = {
            ID = "Form",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_2",
            },
        },
        ["Inertia"] = {
            ID = "Inertia",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_3",
            },
        },
        ["Entropy"] = {
            ID = "Entropy",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_4",
            },
        },
        ["Node_0"] = {
            ID = "Node_0", -- Force
            CollectionID = "Crossroads",
            EventID = "AMER_UI_ElementChain_NodeUse",
            Neighbours = {
                "Force",
                "Node_4", -- Entropy
                "Node_1", -- Life
            },
        },
        ["Node_1"] = {
            ID = "Node_1", -- Life
            CollectionID = "Crossroads",
            EventID = "AMER_UI_ElementChain_NodeUse",
            Neighbours = {
                "Node_0", -- Force
                "Node_3", -- Inertia
                "Life",
            },
            Rotation = 45,
        },
        ["Node_2"] = {
            ID = "Node_2", -- Form
            CollectionID = "Crossroads",
            EventID = "AMER_UI_ElementChain_NodeUse",
            Neighbours = {
                "Node_4", -- Entropy
                "Form",
                "Node_3", -- Inertia
            },
            Rotation = 15,
        },
        ["Node_3"] = {
            ID = "Node_3", -- Inertia
            CollectionID = "Crossroads",
            EventID = "AMER_UI_ElementChain_NodeUse",
            Neighbours = {
                "Node_1", -- Life
                "Node_2", -- Form
                "Inertia",
            },
            Rotation = -15,
        },
        ["Node_4"] = {
            ID = "Node_4", -- Entropy
            CollectionID = "Crossroads",
            EventID = "AMER_UI_ElementChain_NodeUse",
            Neighbours = {
                "Node_0", -- Force
                "Entropy",
                "Node_2", -- Form
            },
            Rotation = -45,
        },
    },
    StartingNode = "Node_0"
}
UI.RegisterPage(Crossroads)

---@type Features.MeditateControllerSupport.Page.Wheel
local Gateway = {
    UI = "AMER_UI_Ascension",
    ID = "Page_Gateway",
    Type = "Wheel",
    WheelID = "PathWheel",
    SelectEventID = "AMER_UI_Ascension_ClusterChosen",
}
UI.RegisterPage(Gateway)

---@type Features.MeditateControllerSupport.Page.AspectGraph
local Aspect = {
    UI = "AMER_UI_Ascension",
    ID = "Page_Cluster",
    Type = "AspectGraph",
}
UI.RegisterPage(Aspect)
