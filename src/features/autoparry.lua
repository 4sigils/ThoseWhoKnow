-- Auto parry core: scans enemies, schedules actions from the animation data, fires them (ping compensated).
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local S, Status, Controls, Get, Nexa = C.State, C.Status, C.Controls, C.Get, C.Nexa
local Ex, cfg, Log = C.Excl, C.cfg, C.Log
local PressKey, RightClick = C.PressKey, C.RightClick
local CleanName = C.CleanName

local KEY_PARRY, KEY_DODGE, KEY_JUMP, KEY_CROUCH = cfg.KEY_PARRY, cfg.KEY_DODGE, cfg.KEY_JUMP, cfg.KEY_CROUCH

local cPlayers = Controls.sb_parry_players
local cNpcs    = Controls.sb_parry_npcs
local cRange   = Controls.sb_range
local cChance  = Controls.sb_parry_chance
local cUnparry = Controls.sb_parry_unparryables

local function ActionKey(kind, hold)
    if kind == "jump" then
        return KEY_JUMP, hold
    elseif kind == "crouch" then
        return KEY_CROUCH, hold
    elseif kind == "dodge" then
        return KEY_DODGE, hold
    elseif kind == "unparryable" then
        if cUnparry.Value then return KEY_PARRY, hold end
        return KEY_DODGE, hold
    end
    return KEY_PARRY, hold
end

local function KeyName(vk)
    return vk == KEY_PARRY and "F" or vk == KEY_DODGE and "Q" or vk == KEY_JUMP and "Space" or "Ctrl"
end

-- report(stage, configuredMs) is optional: the Test buttons use it to show every step of the sequence
function C.Perform(kind, hold, tag, model, id, report)
    local vk, h = ActionKey(kind, hold)
    PressKey(vk, h)
    if report then report("Pressed " .. KeyName(vk) .. " (" .. kind .. ")", 0) end

    -- crouch is a toggle: press it again to stand back up
    if kind == "crouch" then
        local uncrouch = (Get("sb_t_uncrouch") or 500) / 1000
        task.spawn(function()
            task.wait(uncrouch)
            if Nexa:IsAlive() then
                PressKey(KEY_CROUCH, 0.05)
            else
                pcall(keypress, KEY_CROUCH)
                task.wait(0.05)
                pcall(keyrelease, KEY_CROUCH)
            end
            if report then report("Uncrouch (Ctrl again)", uncrouch * 1000) end
        end)
    end

    -- roll cancel: right click a set time after a dodge (Q) goes out
    if vk == KEY_DODGE then
        local rollCancel = Get("sb_t_rollcancel") or 0
        if rollCancel > 0 then
            task.spawn(function()
                task.wait(rollCancel / 1000)
                if Nexa:IsAlive() then RightClick() end
                if report then report("Roll cancel (right click)", rollCancel) end
            end)
        elseif report then
            report("Roll cancel is off (Roll Cancel Timing is 0)", 0)
        end
    end

    if Get("print_parries") then
        local okN, nm = pcall(function() return model.Name end)
        Log(string.format("%s%s -> %s | %s | rbxassetid://%s",
            kind, tag, KeyName(vk),
            okN and CleanName(nm) or "?", tostring(id)))
    end
end

local function Schedule(startTime, info, akey, model, id)
    local delay = 0
    local ping  = C.GetPingComp()
    local hold  = 0.05
    local grace = (Get("sb_parry_feint_grace") or 0) / 1000
    local now   = os.clock()

    for _, action in ipairs(info.actions) do
        local base = startTime + action.t
        if base >= now - 0.1 then
            local at = base + ((delay - ping) / 1000)
            S.Queue[#S.Queue + 1] = {
                at         = at,
                hold       = hold,
                kind       = action.kind,
                owner      = akey,
                model      = model,
                id         = id,
                graceUntil = at + grace,
            }
        end
    end
end

function C.FireDue()
    local Queue = S.Queue
    if #Queue == 0 then return end
    local t = os.clock()
    for i = #Queue, 1, -1 do
        local q = Queue[i]
        if t >= q.at then
            local feinted = not C.IsAnimAlive(q.model, q.id)
            local fire, tag = false, ""

            if feinted then
                if math.random(1, 100) <= (Get("sb_parry_feint_chance") or 0) then
                    fire, tag = true, " (feint)"
                end
            elseif t >= q.graceUntil then
                fire = true
            end

            if fire then C.Perform(q.kind, q.hold, tag, q.model, q.id) end

            if feinted or t >= q.graceUntil then
                table.remove(Queue, i)
            end
        end
    end
end

function C.ScanStep(now)
    local scanStart = os.clock()

    if now >= S.NextRefresh then
        C.RefreshEnemies(now)
        S.NextRefresh = now + 0.5
    end

    local doPlayers, doNpcs = cPlayers.Value, cNpcs.Value
    local range = cRange.Value or 20
    local nearRange = range * 1.5
    local seenNow, tracked = {}, 0

    for _, enemy in ipairs(S.Enemies) do
        if ((enemy.isPlayer and doPlayers) or (not enemy.isPlayer and doNpcs))
           and not (enemy.isPlayer and Ex.FriendsLower[enemy.lname])
           and not (enemy.guild and Ex.Guilds[enemy.guild])
           and now >= enemy.skipUntil then

            local dist = C.Dist(enemy)
            if dist > nearRange then
                enemy.skipUntil = now + 0.3
            else
                for _, anim in ipairs(C.GetPlayingAnims(enemy)) do
                    local id   = anim.id
                    local info = S.AnimDB[id]
                    if info then
                        local akey = enemy.key .. "|" .. id
                        tracked = tracked + 1
                        seenNow[akey] = true

                        if not S.Active[akey] then
                            Status.last, Status.lastDist = info.name or id, dist

                            if dist <= range and math.random(1, 100) <= (cChance.Value or 100) then
                                local start = os.clock() - (anim.elapsed or 0)
                                S.Active[akey] = start
                                Schedule(start, info, akey, enemy.model, id)
                            else
                                S.Active[akey] = now
                            end
                        end
                    end
                end
            end
        end
    end

    for k in pairs(S.Active) do
        if not seenNow[k] then S.Active[k] = nil end
    end
    Status.tracked = tracked
    Status.scanMs = Status.scanMs * 0.8 + (os.clock() - scanStart) * 1000 * 0.2
end
