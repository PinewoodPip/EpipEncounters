
Client.UI.TextDisplay = {
    UI = nil,
    Root = nil,

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/textDisplay.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/textDisplay.swf",
    }
}
local TextDisplay = Client.UI.TextDisplay
local Inv = Client.UI.PartyInventory

function TextDisplay.ClearText()
    TextDisplay.Root.addText("", 0, 0, false)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

Utilities.Hooks.RegisterListener("UI_TextDisplay", "TextRendered", function(text, x, y)
    if true then return nil end
    if not Inv.draggedItemHandle or not Game.AMERUI.ClientIsInSocketScreen() then return nil end
    
    TextDisplay.Root.addText("Release to start Greatforging.", x, y, false)
    -- TextDisplay.Root.addText(string.format("<font color='%s'>Release to start Greatforging.</font>", Data.Colors.AreaInteract), x, y, false)
end)

Utilities.Hooks.RegisterListener("UI_TextDisplay", "TextCleared", function(text, x, y)
    if true then return nil end
    if not Inv.draggedItemHandle or not Game.AMERUI.ClientIsInSocketScreen() then return nil end
    
    Net.PostToServer("EPIPENCOUNTERS_Greatforge_BenchItem", {Char = Client.GetCharacter().NetID, NetID = Ext.GetItem(Ext.UI.DoubleToHandle(Inv.draggedItemHandle)).NetID})

    Inv.draggedItemHandle = nil

    TextDisplay.ClearText()
end)

Ext.RegisterUITypeCall(Client.UI.Data.UITypes.textDisplay, "pipAddText", function(ui, method, text, num1, num2)

    if text == "" then
        Utilities.Hooks.FireEvent("UI_TextDisplay", "TextCleared", text, num1, num2)
    else
        Utilities.Hooks.FireEvent("UI_TextDisplay", "TextRendered", text, num1, num2)
    end
end)

-- Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.textDisplay, "addText", function(ui, method, text, num1, num2)
    
-- end, "After")

Ext.Events.SessionLoaded:Subscribe(function()
    TextDisplay.UI = Ext.UI.GetByType(Client.UI.Data.UITypes.textDisplay)
    TextDisplay.Root = TextDisplay.UI:GetRoot()
end)