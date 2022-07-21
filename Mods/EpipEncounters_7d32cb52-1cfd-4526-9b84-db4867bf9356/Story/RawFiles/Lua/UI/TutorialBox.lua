
TutorialBox = {
    ui = nil,
    root = nil,

    modals = {},
}

Ext.Events.InputEvent:Subscribe(function(event)
    event = event.Event
    if event.EventId == 377 then -- ping hotkey

        

        -- TutorialBox.root.addNonModalBox("MyNonModal", "UNUSED", "Title", "Body")

        -- TutorialBox.root.fadeInModal("UNUSED", "Move Item", '<font color="008858">Move</font> objects by clicking and dragging them.', -1, -1)
    end
end)

function TutorialBox:Setup(data)
    TutorialBox.ui:Show()

    local acceptText = data.acceptText or "Accept"
    local checkboxText = data.checkboxText or "TODO"

    acceptText = acceptText:upper()

    TutorialBox.ui:ExternalInterfaceCall("registerAnchorId", "pip_tutorialBox")
    TutorialBox.ui:ExternalInterfaceCall("setAnchor", "center", "screen", "center")
    TutorialBox.root.setWindow(self.root.stageWidth, self.root.stageHeight)

    TutorialBox.root.setCheckboxLabel(checkboxText)
    TutorialBox.root.modalPointer_mc.ok_mc.text_txt.htmlText = acceptText
    TutorialBox.root.tutorialBox_mc.ok_mc.text_txt.htmlText = acceptText
    TutorialBox.root.tutorialBox_mc.checkbox_mc.label_txt.autoSize = "left"
    TutorialBox.root.tutorialBoxBgWidth = 537 -- default value in swf is not right, might be re-set by engine?
end

-- TODO handling
function TutorialBox:ShowModal(id, data)
    self:Setup(data)
    self.root.fadeInModal("UNUSED", data.header, data.description, -1, -1)
end

Ext.Events.SessionLoaded:Subscribe(function()
    if Client.IsUsingController() then return nil end
    
    TutorialBox.ui = Ext.UI.Create("pip_tutorial", "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/tutorialBox.swf", 100)

    TutorialBox.root = TutorialBox.ui:GetRoot()
    TutorialBox.root.onEventInit()

    TutorialBox.ui:Hide()

    Ext.RegisterUICall(TutorialBox.ui, "pipResolutionChanged", function(ui, method, width, height)
        TutorialBox.root.setWindow(width, height)
    end)
end)