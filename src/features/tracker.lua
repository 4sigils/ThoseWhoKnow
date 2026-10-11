-- Tracker stepping logic (UI: ui/tracker.lua): logs new animations seen on tracked targets.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local S, Log = C.State, C.Log
local HIST_MAX = C.cfg.HIST_MAX

local function AddHistory(id, targetName)
    local Hist = S.Hist
    for i, e in ipairs(Hist) do
        if e.id == id then
            e.count = e.count + 1
            e.target = targetName
            table.remove(Hist, i)
            table.insert(Hist, 1, e)
            S.HistDirty = true
            return
        end
    end
    table.insert(Hist, 1, {id = id, count = 1, target = targetName})
    if #Hist > HIST_MAX then table.remove(Hist) end
    S.HistDirty = true
end

local function GetParent(m) return m.Parent end

function C.TrackerStep()
    if S.TrackedCount == 0 then return end

    for addr, tgt in pairs(S.Tracked) do
        local okP, parent = pcall(GetParent, tgt.model)
        if not okP or not parent then
            S.Tracked[addr] = nil
            S.TrackedCount = S.TrackedCount - 1
            C.UpdateTrackingStatus()
        else
            if tgt.stale or not tgt.animator then
                tgt.animator = C.GetAnimatorAddr(tgt.model)
                tgt.stale = false
            end

            local seenNow = {}
            for _, anim in ipairs(C.GetPlayingAnims(tgt)) do
                seenNow[anim.track] = true
                if not tgt.seen[anim.track] then
                    tgt.seen[anim.track] = true
                    if not S.IgnoredIds[anim.id] then
                        AddHistory(anim.id, tgt.name)
                        Log(string.format("Track: %s | rbxassetid://%s | %.2fs in | %s",
                            tgt.name, anim.id, anim.elapsed or 0, S.AnimDB[anim.id] and "in data" or "new"))
                    end
                end
            end
            for k in pairs(tgt.seen) do
                if not seenNow[k] then tgt.seen[k] = nil end
            end
        end
    end
end
