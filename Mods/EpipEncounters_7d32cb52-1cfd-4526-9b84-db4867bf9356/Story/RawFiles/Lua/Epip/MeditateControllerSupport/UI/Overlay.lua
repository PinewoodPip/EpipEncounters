
local Generic = Client.UI.Generic
local Navigation = Generic.Navigation
local Controller = Navigation:GetClass("GenericUI.Navigation.Controller")
local ListComponent = Navigation:GetClass("GenericUI.Navigation.Components.List")
local Input = Client.Input
local V = Vector.Create

---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")
Support:Debug()

local UI = Generic.Create("Features.MeditateControllerSupport.Overlay", {Layer = 99}) ---@class Features.MeditateControllerSupport.Overlay : GenericUI_Instance
UI.CONTROLLER_STICK_SELECT_THRESHOLD = 0.8

UI._Pages = {} ---@type table<string, Features.MeditateControllerSupport.Page>
UI._GraphIndexMaps = {} ---@type table<string, table<string, integer>> Maps page ID to map of node IDs to container child index.
UI._CurrentPage = nil ---@type Features.MeditateControllerSupport.Page
UI._PageToContainerChildIndex = {} ---@type table<string, integer>
UI._CurrentGraphNode = nil ---@type Features.MeditateControllerSupport.Page.Graph.Node

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.MeditateControllerSupport.Page.Type "Wheel"|"Graph"

---@class Features.MeditateControllerSupport.Page
---@field UI string
---@field ID string
---@field Type Features.MeditateControllerSupport.Page.Type

---@class Features.MeditateControllerSupport.Page.Wheel : Features.MeditateControllerSupport.Page

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
    UI.SetPage(UI._Pages["Page_MainHub"])
    UI:Show()
    Support:DebugLog("UI setup complete")
end

---Sets the current page of the UI.
---@param page Features.MeditateControllerSupport.Page
function UI.SetPage(page)
    if not UI._Pages[page.ID] then
        UI.RegisterPage(page)
    end
    UI._PageContainerNav:FocusByIndex(UI._PageToContainerChildIndex[page.ID])
    UI._CurrentPage = page
    if page.Type == "Graph" then
        ---@cast page Features.MeditateControllerSupport.Page.Graph
        _D(page.Nodes[page.StartingNode])
        _D(page.Nodes)
        UI._SelectNode(page.Nodes[page.StartingNode])
    else
        UI._CurrentGraphNode = nil
    end
    Support:DebugLog("Page set", page.ID)
end

---Registers a page for use within the UI.
---@param page Features.MeditateControllerSupport.Page
function UI.RegisterPage(page)
    UI._Initialize()
    UI._Pages[page.ID] = page
    UI._PageToContainerChildIndex[page.ID] = table.getKeyCount(UI._Pages) -- Should be done after writing to _Pages.

    -- Create elements
    if page.Type == "Wheel" then
        UI:ThrowNotImplemented("RegisterPage Wheel type")
    elseif page.Type == "Graph" then
        ---@cast page Features.MeditateControllerSupport.Page.Graph
        UI._CreateGraphPage(page)
    end
end

---Requests the meditate UI to be exited entirely.
function UI.RequestExit()
    Net.PostToServer(Support.NETMSG_EXIT, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end

---Creates the elements for a graph page.
---@param page Features.MeditateControllerSupport.Page.Graph
function UI._CreateGraphPage(page)
    local _ = UI:CreateElement(page.ID .. "." .. "Container", "GenericUI_Element_Empty", UI._PageContainer)
end

---Selects a node from the graph.
---@param node Features.MeditateControllerSupport.Page.Graph.Node
function UI._SelectNode(node)
    if UI._CurrentPage.Type ~= "Graph" then
        UI:__Error("_SelectNode", "Not in a graph page")
    end
    UI._CurrentGraphNode = node -- TODO wait for confirmation from the server
    if UI._CanInteract() then
        UI._Interact()
    end
end

---Returns whether there is a currently-selected element that can be interacted with.
---@return boolean
function UI._CanInteract()
    local page = UI._CurrentPage
    local canInteract = false
    if page.Type == "Wheel" then
        UI:__ThrowNotImplemented("_CanInteract wheel type")
    elseif page.Type == "Graph" then
        canInteract = UI._CurrentGraphNode ~= nil
    end
    return canInteract
end

---Interacts with the current element.
function UI._Interact()
    local page = UI._CurrentPage
    if page.Type == "Wheel" then
        UI:ThrowNotImplemented("_Interact wheel type")
    elseif page.Type == "Graph" then
        local node = UI._CurrentGraphNode
        ---@type Features.MeditateControllerSupport.NetMsg.InteractWithElement
        local msg = {
            CharacterNetID = Client.GetCharacter().NetID,
            CollectionID = node.CollectionID,
            EventID = node.EventID,
            PageID = UI._CurrentPage.ID,
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
        ID = "Exit",
        Name = Text.CommonStrings.Exit,
        Inputs = {["ToggleInGameMenu"] = true},
    })
    rootNav.Hooks.ConsumeInput:Subscribe(function (ev)
        if ev.Event.Timing == "Up" then
            if ev.Action.ID == "Interact" and UI._CanInteract() then
                UI._Interact()
                ev.Consumed = true
            elseif ev.Action.ID == "Exit" then
                UI.RequestExit()
                ev.Consumed = true
            end
        end
    end)
    rootNav:SetChildren({pageNav})
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

-- Navigate graphs with the left stick
local isPastThreshold = false
Input.Events.StickMoved:Subscribe(function (ev)
    local direction = V(table.unpack(ev.NewState))
    local directionLength = Vector.GetLength(direction)
    if directionLength >= UI.CONTROLLER_STICK_SELECT_THRESHOLD then -- Consider a deadzone.
        -- Do not consider more inputs until the stick is reset to a neutral position.
        if isPastThreshold then return end
        isPastThreshold = true
        local page = UI._CurrentPage ---@cast page Features.MeditateControllerSupport.Page.Graph Valid cast due to the EnabledFunctor checks.
        local node = UI._CurrentGraphNode
        local rotation = node.Rotation or 0
        local slotsAmount = #node.Neighbours
        local anglePerSlot = (2 * math.pi) / slotsAmount
        local firstSegmentStart = V(0, -1) -- Top of the stick is (0, -1)
        firstSegmentStart = Vector.Rotate(firstSegmentStart, -math.deg(anglePerSlot / 2) + rotation) -- But the first segment's left boundary does not necessarily start at (0, -1)
        local angle = Vector.Angle(direction, firstSegmentStart)

        -- Determine if the stick is on the other side of the wheel (past the 180 deg point) to calculate the 360 angle
        local crossProd = firstSegmentStart[1] * direction[2] - firstSegmentStart[2] * direction[1]
        if crossProd < 0 then
            angle = math.rad(360) - angle
        end
        local fraction = angle / (2 * math.pi)
        local slotIndex = math.floor(slotsAmount * fraction) + 1
        slotIndex = math.clamp(slotIndex, 1, slotsAmount)
        UI._SelectNode(page.Nodes[node.Neighbours[slotIndex]])
    elseif directionLength > 0 then
        isPastThreshold = false
    end
end, {EnabledFunctor = function ()
    return UI:IsVisible() and UI._CurrentPage.Type == "Graph"
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
