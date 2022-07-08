
local Generic = Client.UI.Generic

local Test = Generic.Create("PIP_Test")

---------------------------------------------
-- METHODS
---------------------------------------------

function Test.SetupTests()
    local ui = Test:GetUI()
    local root = ui:GetRoot()
    ui:Show()

    print(ui)
    print(root.Root.stringID)

    root.AddElement("tiledbgTest", "TiledBackground", "")
    root.AddElement("textTest", "Text", "tiledbgTest")

    root.tiledbgTest.textTest.SetText("Asd")
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function(_)
    Client.Timer.Start("", 2, function()
        Test.SetupTests()
    end)
end)
