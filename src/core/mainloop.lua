-- Main loop: key releases, auto-parry scan/fire, tracker stepping, status UI. Also the unload cleanup.
local C = ...
local S, Status, Controls, Nexa, cfg = C.State, C.Status, C.Controls, C.Nexa, C.cfg

local cOn = Controls.sb_parry_on

Nexa:OnDestroy(function()
    for _, r in ipairs(S.Releases) do pcall(keyrelease, r.vk) end
    S.Releases = {}
    S.Queue, S.Active, S.Tracked, S.TrackedCount = {}, {}, {}, 0
end)

task.spawn(function()
    local lastLoop, lastScan, lastErr = os.clock(), 0, nil
    local nextTrackerAt = 0

    while Nexa:IsAlive() do
        local now = os.clock()
        -- nothing to scan, track or release: sleep longer instead of spinning every frame
        local idle = not cOn.Value and S.TrackedCount == 0 and #S.Releases == 0
        if not idle then
            Status.loopMs = Status.loopMs * 0.8 + (now - lastLoop) * 1000 * 0.2
        end
        lastLoop = now

        if #S.Releases > 0 then
            for i = #S.Releases, 1, -1 do
                if now >= S.Releases[i].at then
                    pcall(keyrelease, S.Releases[i].vk)
                    table.remove(S.Releases, i)
                end
            end
        end

        if cOn.Value then
            if Controls.sb_t_autoping.Value then C.UpdateAutoPing(now) end
            if now - lastScan >= cfg.SCAN_INTERVAL then
                lastScan = now
                local ok, err = pcall(C.ScanStep, now)
                if not ok and err ~= lastErr then lastErr = err warn("[Deepwoken] scan error: " .. tostring(err)) end
            end
            if #S.Queue > 0 then
                local ok, err = pcall(C.FireDue)
                if not ok and err ~= lastErr then lastErr = err warn("[Deepwoken] fire error: " .. tostring(err)) end
            end
        else
            if #S.Queue > 0 then S.Queue = {} end
            if next(S.Active) ~= nil then S.Active = {} end
        end

        if S.TrackedCount > 0 and now >= nextTrackerAt then
            nextTrackerAt = now + cfg.TRACKER_INTERVAL
            local ok, err = pcall(C.TrackerStep)
            if not ok and err ~= lastErr then lastErr = err warn("[Deepwoken] tracker error: " .. tostring(err)) end
        end

        pcall(C.UpdateStatusUI, now)
        if idle then task.wait(0.1) else task.wait() end
    end

    for _, r in ipairs(S.Releases) do pcall(keyrelease, r.vk) end
end)
