
local MessageBox = Client.UI.MessageBox

---@class Feature_GreatforgeEngrave
local Engrave = Epip.GetFeature("Feature_GreatforgeEngrave")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener(Engrave.NETMSG_ENGRAVE_START, function(payload)
    local item = payload:GetItem()

    Engrave.currentItemHandle = item.Handle

    MessageBox.Open({
        ID = "GreatforgeEngrave",
        Type = "Input",
        AcceptEmpty = false,
        Header = Engrave.TranslatedStrings.MsgBox_Title:GetString(),
        Message = Engrave.TranslatedStrings.MsgBox_Body:GetString(),
        Buttons = {
            {ID = 1, Text = Text.CommonStrings.Confirm:GetString()},
        },
    })

    Engrave:DebugLog("Opening message box for " .. item.DisplayName)
end)

MessageBox.RegisterMessageListener("GreatforgeEngrave", MessageBox.Events.InputSubmitted, function(text)
    local success, err = pcall(function ()
        local item = Item.Get(Engrave.currentItemHandle)
        item.CustomDisplayName.Handle.Handle = Text.UNKNOWN_HANDLE
        item.CustomDisplayName.Handle.ReferenceString = text

        Net.PostToServer(Engrave.NETMSG_ENGRAVE_CONFIRM, {
            ItemNetID = item.NetID,
            NewItemName = text,
        })

        Engrave.currentItemHandle = nil
    end)
    if not success then -- Some users have gotten stuck in this dialogue; though we've yet to confirm why.
        Engrave:__LogError("Failed to engrave:", err)
    end
end)