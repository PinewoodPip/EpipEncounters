
---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests to return to the previous page.
function Support.RequestReturnToPreviousPage()
    Net.PostToServer(Support.NETMSG_BACK, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end
