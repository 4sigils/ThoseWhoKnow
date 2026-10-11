-- Enemy discovery and animation reading (Live folder -> animator -> active animation tracks).
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local S = C.State
local Players = C.Players
local KnownOffsets, OFF_ANIM = C.KnownOffsets, C.OFF_ANIM
local ReadPointer, ReadString = C.ReadPointer, C.ReadString

local function CleanName(name)
    return (tostring(name):gsub("^%.", ""))
end
C.CleanName = CleanName

local AnimCache, AnimCacheN = {}, 0
local AnimatorCache, AnimatorCacheN = {}, 0

local function GetAnimatorAddr(model)
    local key = model.Address
    local addr = AnimatorCache[key]
    if addr then return addr end

    local hum = model:FindFirstChild("Humanoid")
    local animator = hum and hum:FindFirstChild("Animator")
    if not animator then return nil end

    if AnimatorCacheN > 300 then AnimatorCache, AnimatorCacheN = {}, 0 end
    addr = animator.Address
    AnimatorCache[key] = addr
    AnimatorCacheN = AnimatorCacheN + 1
    return addr
end
C.GetAnimatorAddr = GetAnimatorAddr

local function GuildAttr(m) return m:GetAttribute("Guild") end
local function GetGuild(model)
    local ok, g = pcall(GuildAttr, model)
    if ok and type(g) == "string" and g ~= "" then return g end
    return nil
end
C.GetGuild = GetGuild

local function BuildEntry(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local animator = hrp and GetAnimatorAddr(model)
    if not animator then return nil end
    local name = CleanName(model.Name)
    return {
        model = model,
        name = name,
        lname = string.lower(name),
        key = tostring(model.Address),
        hrp = hrp,
        animator = animator,
        isPlayer = Players:FindFirstChild(name) ~= nil,
        skipUntil = 0,
        guildAt = 0,
    }
end

function C.RefreshEnemies(now)
    local list, nextCache = {}, {}
    local lp = Players.LocalPlayer
    S.LocalHRP = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") or nil

    local live = workspace:FindFirstChild("Live")
    if not live then S.Enemies, S.EnemyCache = list, nextCache return end

    local myName = lp and lp.Name
    for _, model in ipairs(live:GetChildren()) do
        local addr = model.Address
        local cached = S.EnemyCache[addr]
        if cached and cached.dead and now < cached.retryAt then
            nextCache[addr] = cached
        else
            local entry = (cached and not cached.dead and not cached.stale) and cached or BuildEntry(model)
            if entry then
                nextCache[addr] = entry
                -- guilds rarely change, so only re-read them every few seconds
                if entry.isPlayer and now >= entry.guildAt then
                    entry.guildAt = now + 5
                    local plr = Players:FindFirstChild(entry.name)
                    entry.guild = plr and GetGuild(plr) or nil
                end
                if entry.name ~= myName then list[#list + 1] = entry end
            else
                nextCache[addr] = {dead = true, retryAt = now + 3}
            end
        end
    end
    S.Enemies, S.EnemyCache = list, nextCache
end

local function DistFn(a, b) return (a.Position - b.Position).Magnitude end
function C.Dist(enemy)
    if not S.LocalHRP then return math.huge end
    local ok, d = pcall(DistFn, S.LocalHRP, enemy.hrp)
    return ok and d or math.huge
end

function C.GetPlayingAnims(enemy)
    local out = {}
    local addr = enemy.animator or GetAnimatorAddr(enemy.model)
    if not addr then return out end

    local listHead = ReadPointer(addr + KnownOffsets.ActiveAnimations)
    if not listHead then
        AnimatorCache[enemy.model.Address] = nil
        enemy.stale = true
        return out
    end

    local node, count = ReadPointer(listHead), 0
    while node and node ~= listHead and count < 50 do
        count = count + 1
        local track = ReadPointer(node + KnownOffsets.NodeNext)
        local anim = track and ReadPointer(track + OFF_ANIM)
        if anim then
            local id = AnimCache[anim]
            if id == nil then
                id = false
                if C.GetClassName(anim) == "Animation" then
                    id = C.CleanId(ReadString(ReadPointer(anim + KnownOffsets.AnimationId))) or false
                end
                if AnimCacheN > 800 then AnimCache, AnimCacheN = {}, 0 end
                AnimCache[anim] = id
                AnimCacheN = AnimCacheN + 1
            end
            if id then
                local ok, t = pcall(memory_read, "float", track + KnownOffsets.TimePosition)
                local good = ok and type(t) == "number" and t == t and t >= 0 and t < 30
                out[#out + 1] = {id = id, elapsed = good and t or 0, track = track}
            end
        end
        node = ReadPointer(node)
    end
    return out
end

function C.IsAnimAlive(model, id)
    if not model or not id then return false end
    for _, anim in ipairs(C.GetPlayingAnims({model = model})) do
        if anim.id == id then return true end
    end
    return false
end
