-- Creates the Nexa window and every tab. Other ui/* modules add sections to C.Tabs.*
local C = ...
local Nexa, cfg = C.Nexa, C.cfg

Nexa:CreateWindow({
    Title = "Deepwoken",
    Subtitle = "Tungity Tungity Sahurity",
    GameName = "Tungity Tungity Sahurity",
    Width = 860,
    Height = 610,
    Theme = "Obsidian",
    Background = "none",
    Opacity = 100,
    MenuKey = "p",
    Logo = cfg.LOGO_URL,
    BackgroundImage = cfg.BG_IMG,
    Splash = { Image = cfg.LOGO_URL },
    ShowLogo = cfg.LOGO_URL ~= nil,
    ShowGameName = true,
    IslandExpanded = true,
})

-- UI performance defaults (turn back on via the island icons / Settings tab if you want them)
do
    local S = Nexa.State
    S.Settings.KeybindOverlay = false
    S.Settings.PerformanceOverlay = false

    local settingsTab = Nexa:GetTab("Settings")
    if settingsTab then
        for _, row in ipairs(settingsTab.Rows or {}) do
            for _, ctrl in ipairs(row.Rows or {}) do
                if ctrl.Title == "Border animation" and ctrl.SetValue then ctrl:SetValue(false) end
            end
        end
    end
end

C.Tabs = {
    main       = Nexa:AddTab({ Title = "Auto Parry", Icon = "shield", Select = true }),
    automation = Nexa:AddTab({ Title = "Automation", Icon = "zap" }),
    visuals    = Nexa:AddTab({ Title = "Visuals", Icon = "eye" }),
    misc       = Nexa:AddTab({ Title = "Misc", Icon = "layers" }),
    qol        = Nexa:AddTab({ Title = "QOL", Icon = "zap" }),
    tracker    = Nexa:AddTab({ Title = "Tracker", Icon = "crosshair" }),
    whitelist  = Nexa:AddTab({ Title = "Whitelists", Icon = "users" }),
    debug      = Nexa:AddTab({ Title = "Debug", Icon = "search" }),
}
