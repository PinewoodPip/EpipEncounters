
local Vanity = Client.UI.Vanity

---@class VanityShapeshift : Feature
local Shapeshift = Epip.Features.VanityShapeshift

local Tab = Vanity.CreateTab({
    Name = "Shapeshift",
    ID = "PIP_Vanity_Shapeshift",
    Icon = Client.UI.Hotbar.ACTION_ICONS.BREWING,
})
Shapeshift.Tab = Tab

---------------------------------------------
-- METHODS
---------------------------------------------

function Shapeshift.RevertForm()
    Net.PostToServer("EPIPENCOUNTERS_Vanity_Shapeshift_Revert", {
        NetID = Client.GetCharacter().NetID,
    })
end

---@param form VanityShapeshiftForm
function Shapeshift.ApplyForm(form)
    Net.PostToServer("EPIPENCOUNTERS_Vanity_Shapeshift_Apply", {
        NetID = Client.GetCharacter().NetID,
        TemplateGUID = form.Template,
    })
end

---------------------------------------------
-- TAB
---------------------------------------------

function Tab:Render()
    Vanity.RenderText("Shapeshift_Header", Text.Format("Shapeshift into various creatures.", {}))

    Vanity.RenderButton("Shapeshift_Revert", "Revert Form", true)

    ---@type VanityShapeshiftForm[]
    local forms = {}
    for _,form in pairs(Shapeshift.FORMS) do table.insert(forms, form) end
    table.sort(forms, function(a, b) return a.Name < b.Name end)

    for _,form in ipairs(forms) do
        Vanity.RenderEntry(form.Template, form.Name, false, false, false, false, nil, false)
    end
end

Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "Shapeshift_Revert" then
        Shapeshift.RevertForm()
    end
end)

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Shapeshift.ApplyForm(Shapeshift.GetForm(id))
end)