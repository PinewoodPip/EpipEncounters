
Client.UI.Mouse = {
    UI = nil,
    Root = nil,
}
local Mouse = Client.UI.Mouse

Ext.Print("MOUSE")
Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.mouseIcon, "setCrossVisible", function(ui, method, str)
    Ext.Print(str)
end)

---------------------------------------------
-- LISTENERS
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    Mouse.UI = Ext.UI.GetByType(Client.UI.Data.UITypes.mouseIcon)
    Mouse.Root = Mouse.UI:GetRoot()
end)