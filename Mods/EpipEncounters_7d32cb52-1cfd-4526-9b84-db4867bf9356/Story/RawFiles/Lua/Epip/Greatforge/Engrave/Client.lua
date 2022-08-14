
---@class Feature_GreatforgeEngrave
local Engrave = Epip.Features.GreatforgeEngrave
local MessageBox = Client.UI.MessageBox

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_GreatforgeEngrave", function(payload)
    local item = Item.Get(payload.ItemNetID)

    Engrave.currentItemHandle = item.Handle

    MessageBox.Open({
        ID = "GreatforgeEngrave",
        Type = "Input",
        AcceptEmpty = false,
        Header = "Engrave Item",
        Message = Text.Format("Choose a name to engrave.", {}),
        Buttons = {
            {ID = 1, Text = "Confirm"},
        },
    })

    Engrave:DebugLog("Opening message box for " .. item.DisplayName)
end)

MessageBox.RegisterMessageListener("GreatforgeEngrave", MessageBox.Events.InputSubmitted, function(text)
    local item = Item.Get(Engrave.currentItemHandle)

    item.CustomDisplayName.Handle.Handle = Text.UNKNOWN_HANDLE
    item.CustomDisplayName.Handle.ReferenceString = text

    Net.PostToServer("EPIPENCOUNTERS_GreatforgeEngrave_Confirm", {
        ItemNetID = item.NetID,
        Name = text,
    })

    Engrave.currentItemHandle = nil
end)