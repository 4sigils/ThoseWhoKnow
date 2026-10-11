-- Auto Parry tab: targets, timings, feints, ping compensation.
local C = ...
local Reg, Tab, cfg = C.Reg, C.Tabs.main, C.cfg

local parrySec = Tab:AddSection("Auto Parry", "Targets and feint handling.", { Column = "left" })

local enabledToggle = Reg("sb_parry_on", parrySec:AddToggle({
    Title = "Enabled",
    Default = false,
    ConfigKey = "deepwoken.parry.enabled",
}))
enabledToggle:AddKeybind({
    Title = "Enable bind",
    Default = "none",
    Mode = "Toggle",
    ConfigKey = "deepwoken.parry.enabled.bind",
    OnPressed = function() enabledToggle:SetValue(not enabledToggle:GetValue()) end,
})
Reg("sb_parry_players", parrySec:AddToggle({
    Title = "Auto Parry Players",
    Default = true,
    ConfigKey = "deepwoken.parry.players",
}))
Reg("sb_parry_npcs", parrySec:AddToggle({
    Title = "Auto Parry NPCs",
    Default = true,
    ConfigKey = "deepwoken.parry.npcs",
}))
Reg("sb_parry_unparryables", parrySec:AddToggle({
    Title = "Parry Unparryables",
    Tooltip = "Unparryable actions press F (parry) instead of Q (for armor that allows it). Dodge-only actions always press Q.",
    Default = false,
    ConfigKey = "deepwoken.parry.unparryables",
}))
Reg("sb_parry_chance", parrySec:AddSlider({
    Title = "Parry Chance",
    Min = 1, Max = 100, Step = 1, Default = 100, Suffix = "%",
    ConfigKey = "deepwoken.parry.chance",
}))
Reg("sb_range", parrySec:AddSlider({
    Title = "Range",
    Tooltip = "Only react to animations from enemies within this many studs",
    Min = 5, Max = 100, Step = 1, Default = 20, Suffix = " studs",
    ConfigKey = "deepwoken.parry.range",
}))
Reg("sb_t_uncrouch", parrySec:AddSlider({
    Title = "Uncrouch Timing",
    Tooltip = "Crouch is a toggle: how long after crouching it presses the key again to stand up",
    Min = 0, Max = 2000, Step = 10, Default = 500, Suffix = "ms",
    ConfigKey = "deepwoken.timing.uncrouch",
}))
Reg("sb_t_rollcancel", parrySec:AddSlider({
    Title = "Roll Cancel Timing",
    Tooltip = "How long after a dodge (Q) it waits before right-clicking to roll cancel. 0 = off",
    Min = 0, Max = 1000, Step = 5, Default = 0, Suffix = "ms",
    ConfigKey = "deepwoken.timing.rollCancel",
}))

local feintSec = Tab:AddSection("Feints", "Handling for canceled swings.", { Column = "right" })
Reg("sb_parry_feint_chance", feintSec:AddSlider({
    Title = "Parry Feint Chance",
    Tooltip = "Chance to still act when a swing gets canceled early (a feint)",
    Min = 0, Max = 100, Step = 1, Default = 0, Suffix = "%",
    ConfigKey = "deepwoken.parry.feintChance",
}))
Reg("sb_parry_feint_grace", feintSec:AddSlider({
    Title = "Feint Grace",
    Tooltip = "How long after the normal moment to keep watching for a late feint before committing",
    Min = 0, Max = 300, Step = 5, Default = 100, Suffix = "ms",
    ConfigKey = "deepwoken.parry.feintGrace",
}))

-- PING COMP (own section)
local pingSec = Tab:AddSection("Ping Compensation", "Fires actions earlier to cover your latency.", { Column = "right" })
local autoPingToggle = Reg("sb_t_autoping", pingSec:AddToggle({
    Title = "Auto Ping Comp",
    Tooltip = "On: uses your live (smoothed) ping and fires the one-way trip (ping / 2) earlier, nothing under 25 ms. Off: uses the Ping Comp slider.",
    Default = true,
    ConfigKey = "deepwoken.timing.autoPing",
}))
local pingSlider = Reg("sb_t_ping", pingSec:AddSlider({
    Title = "Ping Comp",
    Tooltip = "Used when Auto Ping Comp is off: fires actions this many ms earlier. Timings are tuned for ~60 ping; auto-set from your ping on inject.",
    Min = -cfg.BASE_PING, Max = 300, Step = 1, Default = 0, Suffix = "ms",
    ConfigKey = "deepwoken.timing.ping",
}))
pingSlider:SetEnabled(not autoPingToggle.Value)
autoPingToggle:OnChanged(function(v) pingSlider:SetEnabled(not v) end)
