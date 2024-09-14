
local Support = Epip.GetFeature("Features.MeditateControllerSupport")

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
            Deadzones = {
                {0, 120},
                {240, 360},
            },
        },
        ["Life"] = {
            ID = "Life",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_1",
            },
            Deadzones = {
                {0, 45},
                {180, 360},
            },
        },
        ["Form"] = {
            ID = "Form",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_2",
            },
            Deadzones = {
                {0, 220},
            },
        },
        ["Inertia"] = {
            ID = "Inertia",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_3",
            },
            Deadzones = {
                {90, 280},
            },
        },
        ["Entropy"] = {
            ID = "Entropy",
            CollectionID = "MainHub_Gateway",
            EventID = "AMER_UI_Ascension_PathGateway",
            Neighbours = {
                "Node_4",
            },
            Deadzones = {
                {0, 180},
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
    StartingNodes = {
        "Node_0",
        "Node_4",
        "Node_2",
        "Node_3",
        "Node_1",
    },
}

GameState.Events.ClientReady:Subscribe(function (_)
    Support.Overlay.RegisterPage(Crossroads)
end)
