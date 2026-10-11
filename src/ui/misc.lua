-- Misc tab controls (logic: features/nofog.lua, features/removals.lua).
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Reg = C.Reg

local sec = C.Tabs.misc:AddSection("Removals", "Strip effects and obstacles out of the world.", { Column = "left" })
Reg("remove_winds", sec:AddToggle({
    Title = "Remove Winds",
    Tooltip = "Moves the SuperWall parts in Layer2Floor1 far below the map. Puts them back when turned off.",
    Default = false,
    ConfigKey = "deepwoken.misc.removeWinds",
}))
Reg("no_fog", sec:AddToggle({
    Title = "No Fog",
    Tooltip = "Keeps Lighting fog far away and writes Atmosphere Density to 0 while enabled.",
    Default = false,
    ConfigKey = "deepwoken.visuals.noFog",
}))
Reg("no_shadows", sec:AddToggle({
    Title = "No Shadows",
    Tooltip = "Turns off global shadows (writes the GlobalShadows byte on Lighting). Restores the original value when turned off.",
    Default = false,
    ConfigKey = "deepwoken.misc.noShadows",
}))
Reg("no_golem_turrets", sec:AddToggle({
    Title = "No Golem Turrets",
    Tooltip = "Moves the TurretTrigger parts out of reach so the turrets never fire. Puts them back when turned off.",
    Default = false,
    ConfigKey = "deepwoken.misc.noGolemTurrets",
}))
Reg("no_kill_bricks", sec:AddToggle({
    Title = "No Kill Bricks",
    Tooltip = "Moves kill bricks, kill planes, life fields and chasm bricks out of reach. Puts them back when turned off.",
    Default = false,
    ConfigKey = "deepwoken.misc.noKillBricks",
}))
Reg("no_rain_sound", sec:AddToggle({
    Title = "No Rain Sound",
    Tooltip = "Sets the rain sound's playback speed to 0.",
    Default = false,
    ConfigKey = "deepwoken.misc.noRainSound",
}))
