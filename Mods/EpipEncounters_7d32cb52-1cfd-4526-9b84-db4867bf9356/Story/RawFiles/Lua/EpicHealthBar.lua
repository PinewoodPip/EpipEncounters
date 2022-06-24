-- FlashObject is the actual flash obj instance itself, you can access its props and methods with .
-- Ext.GetUI seems to give you something different (UIObject), you need to use GetRoot to get the flashobject

local harriedStatuses = {
    ['<font color="c80000">Harried x1</font>'] = 1,
    ['<font color="c80000">Harried x2</font>'] = 2,
    ['<font color="c80000">Harried x3</font>'] = 3,
    ['<font color="c80000">Harried x4</font>'] = 4,
    ['<font color="c80000">Harried x5</font>'] = 5,
    ['<font color="c80000">Harried x6</font>'] = 6,
    ['<font color="c80000">Harried x7</font>'] = 7,
    ['<font color="c80000">Harried x8</font>'] = 8,
    ['<font color="c80000">Harried x9</font>'] = 9,
    ['<font color="c80000">Harried x10</font>'] = 10,
}

local batteredStatuses = {
    ['<font color="c80000">Battered x1</font>'] = 1,
    ['<font color="c80000">Battered x2</font>'] = 2,
    ['<font color="c80000">Battered x3</font>'] = 3,
    ['<font color="c80000">Battered x4</font>'] = 4,
    ['<font color="c80000">Battered x5</font>'] = 5,
    ['<font color="c80000">Battered x6</font>'] = 6,
    ['<font color="c80000">Battered x7</font>'] = 7,
    ['<font color="c80000">Battered x8</font>'] = 8,
    ['<font color="c80000">Battered x9</font>'] = 9,
    ['<font color="c80000">Battered x10</font>'] = 10,
}

cachedText = ""

function UpdateHealthBar(uiObject, methodName, param1)
    if (not DevMode()) then
        return
    end

    local interface = Ext.UI.GetByType(42)
    local root = interface:GetRoot()

    -- interface:Invoke("setText", "test1", "test2", false)

    -- for i,v in pairs(param1) do
    --     Ext.Print(v)
    -- end
    Ext.Print("happening")

    local regularText = root.hp_mc.barTextsHolder_mc.health_txt.htmlText

    Ext.Print(root.hp_mc.barTextsHolder_mc.health_txt.htmlText)

    local hp = string.match(regularText, "(%d+/%d+).*")

    if (hp == nil) then
        hp = regularText
    end

    -- param 1 is fullness in 0-1. string is text. param 4 away from 0 seems to break it, or cause another update. or its responsible for some text field?
    -- 0 is hp, 1 is phys arm, 2 is mag arm

    -- sleep(1)

    root.hp_mc.setBar(1, false, hp .. "       " .. cachedText, 0, false)
    -- root.hp_mc.barTextsHolder_mc.health_txt.htmlText = hp .. "       " .. cachedText

    return

    -- Ext.Print(root.hp_mc)
    -- interface.hp_mc:Invoke("setBar", 1, false, "test", 0, false)
    -- that seems to be the way to call stuff from UIObject
end

function GetStatuses(uiObj, methodName, param3)
    local interface = Ext.UI.GetByType(42)
    local root = uiObj:GetRoot()

    local statusesTable = Game.Tooltip.TableFromFlash(interface, "status_array")

    local harried = 0
    local battered = 0

    for i,v in ipairs(statusesTable) do
        if i % 6 == 0 then
            -- Ext.Print(v)
            if (harriedStatuses[v] ~= nil) then
                harried = harriedStatuses[v]
            end

            if (batteredStatuses[v] ~= nil) then
                battered = batteredStatuses[v]
            end
        end
    end

    local bhText = battered .. "B & " .. harried .. "H"

    cachedText = bhText
    Ext.Print("Cached text as " .. cachedText)

    UpdateHealthBar(uiObj, methodName, param3)
end

Ext.Events.SessionLoaded:Subscribe(function()
    if (not DevMode()) then
        return
    end

    Ext.Print("Healthbar Hooks added")
    Ext.RegisterUITypeInvokeListener(42, "updateStatuses", UpdateStatuses, "Before")
    Ext.RegisterUITypeInvokeListener(42, "show", Show, "After")

    Ext.RegisterUITypeInvokeListener(42, "setHPBars", SetHPBars, "After")
    Ext.RegisterUITypeInvokeListener(42, "setArmourBar", SetArmourBar, "After")
    Ext.RegisterUITypeInvokeListener(42, "setMagicArmourBar", SetMagicArmourBar, "After")
    Ext.RegisterUITypeInvokeListener(42, "setBar", SetBar, "After")
    Ext.RegisterUITypeInvokeListener(42, "setStatus", setStatus, "After")

    Ext.RegisterUINameInvokeListener("setText", setText)

    -- Ext.RegisterUINameInvokeListener("MainTimeline", mainTimeline)

    -- does not work
    -- Ext.RegisterUINameInvokeListener("setBar", setBarHandler)
end)

function setBarHandler(uiObject, methodName, param1)
    Ext.Print("setBar")
    Ext.Print(uiObject.GetTypeId())

    -- UpdateHealthBar(uiObject, methodName, param1)
end

function setText(uiObject, methodName, param1)
    Ext.Print("setText")

    UpdateHealthBar(uiObject, methodName, param1)
end

function setStatus(uiObject, methodName, param1)
    Ext.Print("setStatus")

    UpdateHealthBar(uiObject, methodName, param1)
end

function Show(uiObject, methodName, param1)
    Ext.Print("Show")

    UpdateHealthBar(uiObject, methodName, param1)
end

function SetBar(uiObject, methodName, param1)
    Ext.Print("SetBar")

    UpdateHealthBar(uiObject, methodName, param1)
end

function SetHPBars(uiObject, methodName, param1)
    Ext.Print("SetHPBars")

    UpdateHealthBar(uiObject, methodName, param1)
end

function SetMagicArmourBar(uiObject, methodName, param1)
    Ext.Print("SetMagicArmourBar")

    UpdateHealthBar(uiObject, methodName, param1)
end

function SetArmourBar(uiObject, methodName, param1)
    Ext.Print("SetArmourBar")

    UpdateHealthBar(uiObject, methodName, param1)
end

function UpdateStatuses(uiObject, methodName, param1)
    Ext.Print("UpdateStatuses")

    GetStatuses(uiObject, methodName, param1)
end