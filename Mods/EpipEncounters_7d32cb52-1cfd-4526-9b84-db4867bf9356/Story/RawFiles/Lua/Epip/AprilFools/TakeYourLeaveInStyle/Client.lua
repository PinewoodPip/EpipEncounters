
---------------------------------------------
-- Replaces "Take your leave" and similar farewell messages with cooler ones that have more style.
---------------------------------------------

local Dialog = Client.UI.Dialog

---@type Feature
local TakeYourLeave = {
    ---@type pattern[]
    DIALOG_EXIT_KEYWORDS = {
        "Take your leave",
        "take your leave",
        "turn to leave",
        "Leave him to be",
        "Leave him to it",
        "^%*Leave ",
        "^%(end%)",
        "Excuse yourself",
        "Walk away%.%*$",
    },
    REPLACEMENTS = {
        "*See you later, alligator.*",
        "*See ya.*",
        "*Wish them a nice day and leave.*",
        "*Til we meet again.*",
        "*Tell them to shut up.*",
        "*Do a 360 and walk away from the conversation.*",
        "*Blow a kiss and bid farewell.*",
        "*Blow a kiss and bid farewell.*",
        "*Toodle-oo, kangaroo!*",
        "*Smell you later.*",
        "*Gotta bounce!*",
        "*Au revoir!*",
        "*Hasta la vista, baby.*",
        "*Tip your hat and moonwalk out of the conversation.*",
        "*Drop your mic and leave.*",
        "*I'll be back... actually, no promises.*",
        "*Zoinks, I'm gone!*",
        "*Say you've got an important meeting and drop out.*",
        "*Toodles, noodles!*",
        "*See you on the other side.*",
        "*I'll miss you.*",
        "*Share fake contact information with them and leave.*",
        "*Cough awkwardly and leave.*",
        "*Wink seductively, but leave.*",
        "*Bye bye, butterfly!*",
        "*Wave frantically until they're out of sight.*",
        "*Back away slowly, maintaining eye contact.*",
        "*Vroom vroom, leaving the room!*",
        "*Trip on the way out but play it cool.*",
    },
}
Epip.RegisterFeature("Features.AprilFools.TakeYourLeaveInStyle", TakeYourLeave)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Replace "Take your leave" and similar farewell messages with ones that have more style.
Dialog.Hooks.AddAnswers:Subscribe(function (ev)
    for _,answer in ipairs(ev.Answers) do
        for _,pattern in ipairs(TakeYourLeave.DIALOG_EXIT_KEYWORDS) do
            if string.match(answer.Label, pattern) then
                local replacement = TakeYourLeave.REPLACEMENTS[Ext.Random(1, #TakeYourLeave.REPLACEMENTS)]
                answer.Label = replacement
            end
        end
    end
end, {EnabledFunctor = Epip.IsAprilFools})
