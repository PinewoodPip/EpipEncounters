function OnGiftbagsUIInit(uiObj, methodName, param3, num1, str1, str2, bool1)
    Ext.Print("-------")
    Ext.Print(num1)
    Ext.Print(str1)
    Ext.Print(str2)
    Ext.Print(bool1)
end

Ext.Events.SessionLoading:Subscribe(function()
    Ext.Print("YES")
    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.giftBagsMenu, "selectGiftBag", OnGiftbagsUIInit, "Before")
end)