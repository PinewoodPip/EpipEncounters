
---@class Features.CustomPortraits : Feature
local CustomPortraits = Epip.GetFeature("Features.CustomPortraits")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to set portraits.
Net.RegisterListener(CustomPortraits.NETMSG_SET_PORTRAIT, function (payload)
    -- Set portrait server-side
    local char = payload:GetCharacter()
    local img = Image.CreateFromRawData(payload.ImageRawData)
    local dds = Image.ToDDS(img)

    Ext.Entity.SetPortrait(char.Handle, img.Width, img.Height, dds)

    -- Send portrait to clients
    Net.Broadcast(CustomPortraits.NETMSG_SET_PORTRAIT, payload)
end)
