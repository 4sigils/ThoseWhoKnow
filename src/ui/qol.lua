-- QOL tab controls (logic: features/statfarm.lua, features/tp_objectives.lua, features/qol_actions.lua).
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Reg, Tab, QolActions = C.Reg, C.Tabs.qol, C.QolActions

local statSec = Tab:AddSection("Stat Farming", "Answers the Intelligence and Charisma prompts for you.", { Column = "left" })
Reg("auto_intel", statSec:AddToggle({
    Title = "Auto Intelligence",
    Tooltip = "Solves the math question in the choice prompt and picks the matching answer (within 1).",
    Default = false,
    ConfigKey = "deepwoken.misc.autoIntel",
}))
Reg("auto_charisma", statSec:AddToggle({
    Title = "Auto Charisma",
    Tooltip = "Sends the line quoted in the choice prompt as your chat choice.",
    Default = false,
    ConfigKey = "deepwoken.misc.autoCharisma",
}))

local helpSec = Tab:AddSection("Quality of Life", "Small helpers.", { Column = "right" })
Reg("tp_objectives", helpSec:AddToggle({
    Title = "TP to Objectives",
    Tooltip = "Flies you (200 studs/s) to the current Layer 2 objective: door and key, Galewax, blood jars, buzz obelisks, bone spears and altars. Leave it on while you progress. Not saved to the auto config.",
    Default = false,
    ConfigKey = "deepwoken.qol.tpObjectives",
}))
helpSec:AddButton({
    Title = "Knock Self",
    ButtonText = "Knock",
    Tooltip = "Drops you under 45 health with acid checks, then fires three fall-damage hits. Needs remote firing and KeyHandler.",
    Callback = function() QolActions.KnockSelf() end,
})
helpSec:AddButton({
    Title = "Reset",
    ButtonText = "Reset",
    Tooltip = "Throws your root part far out of the map to reset your character.",
    Callback = function() QolActions.Reset() end,
})
