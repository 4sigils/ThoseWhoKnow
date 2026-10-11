-- Automation tab controls (logic: features/ritual.lua, features/ragdoll.lua).
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Reg = C.Reg

local generalSec = C.Tabs.automation:AddSection("General", "Quality-of-life automation.", { Column = "left" })
Reg("auto_ritual", generalSec:AddToggle({
    Title = "Auto Ritual",
    Tooltip = "Automatically types the ritual key sequence when the spell GUI opens",
    Default = false,
    ConfigKey = "deepwoken.automation.ritual",
}))
Reg("auto_ragdoll_cancel", generalSec:AddToggle({
    Title = "Auto Ragdoll Cancel",
    Tooltip = "Right-clicks every 0.5s while you are ragdolled until it clears",
    Default = false,
    ConfigKey = "deepwoken.automation.ragdollCancel",
}))
