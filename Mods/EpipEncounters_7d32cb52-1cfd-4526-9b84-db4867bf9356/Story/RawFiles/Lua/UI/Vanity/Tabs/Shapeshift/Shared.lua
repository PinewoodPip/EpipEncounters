
---@class VanityShapeshift
local Shapeshift = {
    Tab = nil,

    ---@type table<GUID, VanityShapeshiftForm>
    FORMS = {},
}
Epip.AddFeature("VanityShapeshift", "VanityShapeshift", Shapeshift)
Epip.Features.VanityShapeshift = Shapeshift
Shapeshift:Debug()

---@class VanityShapeshiftForm
---@field Template GUID
---@field Name string

---@class VanityShapeshiftForm
local _Form = {}

---@return string
function _Form:GetStatusName()
    return "PIP_VanityShapeshift_" .. self.Template
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param form VanityShapeshiftForm
function Shapeshift.RegisterForm(form)
    Inherit(form, _Form)
    local statusName = form:GetStatusName()
    local stat = Stats.Get("StatusData", statusName)

    if not stat then
        stat = Ext.Stats.Create(statusName, "StatusData")
    end

    stat.StatusType = "POLYMORPHED"
    stat.Icon = "Talent_Refined"
    stat.DisplayName = form.Name
    stat.Description = Text.Format("Character is taking onto the form of an adorable %s.", {
        FormatArgs = {form.Name:lower()}
    })
    stat.DescriptionRef = stat.Description
    stat.LoseControl = "No"
    stat.PolymorphResult = form.Template
    stat.DisableInteractions = "No"

    if Ext.IsServer() then
        Ext.Stats.Sync(statusName, true)
    end

    Shapeshift.FORMS[form.Template] = form
end

---@param id GUID
function Shapeshift.GetForm(id)
    return Shapeshift.FORMS[id]
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register default forms.
---@type VanityShapeshiftForm[]
local forms = {
    {
        Name = "Young Red Dragon",
        Template = "539e4fde-264b-4295-9c47-cc917e163257",
    },
    {
        Name = "Ice Dragon",
        Template = "214bc7ae-9e29-4afb-82d1-1de70d16039f",
    },
    {
        Name = "Crab",
        Template = "c816ba20-114b-47f2-b755-2ddcc9c40ea6",
    },
    {
        Name = "Rooster",
        Template = "187f09aa-ccdf-43b1-b04f-8806de3e4c0c",
    },
    {
        Name = "Fire Slug"  ,
        Template = "2580d64e-e0f2-4d4a-9186-efb47f5f81bd",
    },
    {
        Name = "Test Dummy",
        Template = "680e6e58-98f4-4684-9a84-d5a190f855d5",
    },
    {
        Name = "Cat",
        Template = "4f7cdf30-0d44-44d2-bcf2-91850728107d",
    },
    {
        Name = "Incarnate",
        Template = "118d7359-b7d5-41ea-8c55-86ce27afceba",
    },
    {
        Name = "Incarnate Champion",
        Template = "13f9314d-e744-4dc5-acf2-c6bf77a04892",
    },
}

Ext.Events.SessionLoaded:Subscribe(function (e)
    for _,form in ipairs(forms) do
        Shapeshift.RegisterForm(form)
    end
end)