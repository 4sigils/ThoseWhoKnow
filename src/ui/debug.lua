-- Debug tab: reload data, print tables/ping, test buttons, live status badges.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local S, Status, Nexa, Controls, Get = C.State, C.Status, C.Nexa, C.Controls, C.Get
local cfg, Log = C.cfg, C.Log
local Tab = C.Tabs.debug

local actionSec = Tab:AddSection("Actions", "Reload data from GitHub.", { Column = "left" })
actionSec:AddButton({ Title = "Reload Anim Data", ButtonText = "Reload", Callback = function() C.LoadData() end })
actionSec:AddButton({ Title = "Reload Ignored Anims", ButtonText = "Reload", Callback = function() C.LoadIgnored() end })
actionSec:AddButton({
    Title = "Print Anim Table",
    ButtonText = "Print",
    Tooltip = "Prints every animation loaded from GitHub (id and its actions) to the console",
    Callback = function()
        local ids = {}
        for id in pairs(S.AnimDB) do ids[#ids + 1] = id end
        table.sort(ids, function(a, b)
            local na, nb = tonumber(a), tonumber(b)
            if na and nb then return na < nb end
            return tostring(a) < tostring(b)
        end)

        print(string.format("[Deepwoken] ===== Animation table (%d entries) from %s =====", #ids, cfg.DATA_URL))
        for _, id in ipairs(ids) do
            local parts = {}
            for _, action in ipairs(S.AnimDB[id].actions) do
                parts[#parts + 1] = string.format("%s@%.3f", action.kind, action.t)
            end
            print(string.format("[Deepwoken] rbxassetid://%s = %s", id, table.concat(parts, ", ")))
        end
        print("[Deepwoken] ===== end of animation table =====")

        Nexa:Notify({ Title = "Anim Table", Content = "Printed " .. #ids .. " animations to the console.", Type = "success", Duration = 3 })
    end,
})

-- STATUS BADGES
local St = {}
do
    local statSec = Tab:AddSection("Status", "Live script info.", { Column = "right" })
    St.Loaded  = statSec:AddStatus({ Title = "Loaded anims",  Default = "0", Tone = "accent" })
    St.Ignored = statSec:AddStatus({ Title = "Ignored anims", Default = "0", Tone = "muted" })
    St.Track   = statSec:AddStatus({ Title = "Tracking",      Default = "0", Tone = "success" })
    St.Last    = statSec:AddStatus({ Title = "Last",          Default = "none", Tone = "muted" })
    St.Dist    = statSec:AddStatus({ Title = "Distance",      Default = "0.0", Tone = "muted" })
    St.Loop    = statSec:AddStatus({ Title = "Loop / Scan",   Default = "0 / 0 ms", Tone = "muted" })
    St.Ping    = statSec:AddStatus({ Title = "Ping / Comp",   Default = "-", Tone = "muted" })
    St.Atmos   = statSec:AddStatus({ Title = "Atmospheres",   Default = "0", Tone = "muted" })
end

actionSec:AddButton({
    Title = "Print Ping",
    ButtonText = "Print Ping",
    Callback = function()
        local myPing = C.GetPingValue()
        if not myPing then
            Log("Ping read failed. Every method tried:\n[Deepwoken]   " .. tostring(C.PingInfo.Error))
            Nexa:Notify({ Title = "Ping", Content = "Could not read your ping (see console).", Type = "warning", Duration = 4 })
            return
        end

        local comp = C.GetPingComp()
        Log(string.format("Ping: %.0f ms | Comp: %.0f ms | via %s", myPing, comp, C.PingInfo.Method))
        Nexa:Notify({
            Title = "Ping",
            Content = string.format("%.0f ms (comp %.0f ms) via %s", myPing, comp, C.PingInfo.Method),
            Type = "success",
            Duration = 3,
        })
    end,
})

C.Reg("print_parries", actionSec:AddToggle({
    Title = "Print Parries",
    Tooltip = "Prints every action the auto-parry fires (kind, key, enemy, animation id)",
    Default = false,
}))

-- TEST BUTTONS: wait 3 seconds (click back into the game), then run the FULL sequence through the same
-- Perform path as real actions: crouch -> uncrouch, dodge -> roll cancel. Every step is reported with the
-- delay you set and the delay actually measured.
do
    local testBusy = false

    local function TestAction(title, kind)
        actionSec:AddButton({
            Title = title,
            ButtonText = "Run in 3s",
            Callback = function()
                if testBusy then return end
                testBusy = true
                Nexa:Notify({ Title = title, Content = "Fires in 3 seconds", Type = "info", Duration = 3 })
                task.wait(3)

                if Nexa:IsAlive() then
                    local t0 = os.clock()
                    C.Perform(kind, 0.05, " (test)", { Name = "Test" }, "test", function(stage, configuredMs)
                        local actual = (os.clock() - t0) * 1000
                        local msg = configuredMs > 0
                            and string.format("%s - set %.0fms, measured %.0fms", stage, configuredMs, actual)
                            or stage
                        Log("Test: " .. msg)
                        Nexa:Notify({ Title = title, Content = msg, Type = "info", Duration = 3 })
                    end)

                    -- stay locked until the whole sequence has finished
                    local tail = math.max(Get("sb_t_uncrouch") or 0, Get("sb_t_rollcancel") or 0)
                    task.wait(0.4 + tail / 1000)
                end
                testBusy = false
            end,
        })
    end
    TestAction("Test Crouch", "crouch")
    TestAction("Test Dodge", "dodge")
    TestAction("Test Unparryable", "unparryable")
end

-- Called from the main loop: refreshes history labels and (only while the Debug tab is open) the badges.
local lastStatusUpdate = 0
function C.UpdateStatusUI(now)
    if now - lastStatusUpdate < 0.25 then return end
    lastStatusUpdate = now

    if S.HistDirty then C.RefreshHistLabels() end

    -- the status badges are only on screen in the Debug tab, so don't touch them otherwise
    if Nexa.State.Tabs[Nexa.State.ActiveIndex] ~= Tab then return end

    St.Loaded:SetValue(tostring(Status.loaded))
    St.Ignored:SetValue(tostring(Status.ignored))
    St.Track:SetValue(tostring(Status.tracked))
    St.Last:SetValue(tostring(Status.last))
    St.Dist:SetValue(string.format("%.1f", Status.lastDist))
    St.Loop:SetValue(string.format("%.0f / %.0f ms", Status.loopMs, Status.scanMs))
    local livePing = C.GetPingValue()
    if livePing then
        Status.ping = livePing
        if Controls.sb_t_autoping.Value then
            C.UpdateAutoPing(now)
            St.Ping:SetValue(string.format("%.0f / %.0f ms (auto)", C.AutoPing.smooth or livePing, C.AutoPing.comp), "accent")
        else
            St.Ping:SetValue(string.format("%.0f / %d ms", livePing, Controls.sb_t_ping.Value or 0), "accent")
        end
    else
        St.Ping:SetValue("unavailable", "muted")
    end
    St.Atmos:SetValue(tostring(Status.atmos or 0))
end
