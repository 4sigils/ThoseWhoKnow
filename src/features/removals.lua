-- Misc removals: Remove Winds, No Shadows, No Golem Turrets, No Kill Bricks, No Rain Sound.
-- Anything that needed Parent = nil, :Remove() or signals is done differently because those don't work on
-- this executor: obstacles are moved far below the map (and put back when the toggle is turned off) and
-- signals are replaced by polling.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Nexa, Controls, Players, Lighting = C.Nexa, C.Controls, C.Players, C.Lighting

-- walk down a chain of child names, returning nil as soon as one is missing
local function find(root, ...)
    local current = root
    for _, name in ipairs({ ... }) do
        current = current and current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

-- Remembers every part it moves out of the way so RestoreAll can put them back exactly.
local function NewMover()
    local saved = {}
    local self = {}

    function self.Move(part)
        if saved[part] ~= nil then return end
        local ok = pcall(function()
            local cf = part.CFrame
            saved[part] = cf
            part.CFrame = cf + Vector3.new(0, -10000, 0)
        end)
        if not ok then saved[part] = nil end
    end

    -- a part is moved directly; for a model every part inside it is moved
    function self.MoveTree(inst)
        local ok, isPart = pcall(function() return inst:IsA("BasePart") end)
        if not ok or isPart then
            self.Move(inst)
            return
        end
        local okD, list = pcall(function() return inst:GetDescendants() end)
        if okD and type(list) == "table" then
            for _, d in ipairs(list) do
                local okP, p = pcall(function() return d:IsA("BasePart") end)
                if okP and p then self.Move(d) end
            end
        end
    end

    function self.RestoreAll()
        for part, cf in pairs(saved) do
            pcall(function() part.CFrame = cf end)
        end
        saved = {}
    end

    return self
end

-- Runs onTick while the toggle is on (every `interval` seconds, 0 = every frame) and onOff once when it
-- turns off or the script unloads. Only errors are printed.
local function Feature(flag, interval, onTick, onOff)
    local ctrl = Controls[flag]
    task.spawn(function()
        local wasOn, lastErr = false, nil
        while Nexa:IsAlive() do
            if ctrl.Value then
                wasOn = true
                local ok, err = pcall(onTick)
                if not ok and err ~= lastErr then
                    lastErr = err
                    warn(string.format("[Deepwoken] %s error: %s", flag, tostring(err)))
                end
                if interval > 0 then task.wait(interval) else task.wait() end
            else
                if wasOn then
                    wasOn = false
                    if onOff then pcall(onOff) end
                end
                task.wait(0.25)
            end
        end
    end)
    if onOff then Nexa:OnDestroy(function() pcall(onOff) end) end
end

-- REMOVE WINDS: SuperWall parts in Layer2Floor1 (the descendants scan only runs every few seconds)
do
    local WindWalls = {}   -- part -> original CFrame
    local WindList = {}
    local nextWindScan = 0

    local function MoveWall(v)
        if v.Position.Y > -5000 then
            if WindWalls[v] == nil then WindWalls[v] = v.CFrame end
            v.CFrame = v.CFrame + Vector3.new(0, -10000, 0)
        end
    end

    local function MoveWindWalls(now)
        if now >= nextWindScan then
            nextWindScan = now + 5
            WindList = {}
            local floor = workspace:FindFirstChild("Layer2Floor1")
            if floor then
                local ok, list = pcall(function() return floor:GetDescendants() end)
                if ok and type(list) == "table" then
                    for _, v in ipairs(list) do
                        if v.Name == "SuperWall" then WindList[#WindList + 1] = v end
                    end
                end
            end
        end
        for _, v in ipairs(WindList) do pcall(MoveWall, v) end
    end

    local function RestoreWinds()
        for part, cf in pairs(WindWalls) do
            pcall(function() part.CFrame = cf end)
        end
        WindWalls = {}
        WindList = {}
        nextWindScan = 0
    end

    Nexa:OnDestroy(function() pcall(RestoreWinds) end)

    task.spawn(function()
        local wasOn = false
        local cWinds = Controls.remove_winds
        while Nexa:IsAlive() do
            local on = cWinds.Value and true or false
            if on then
                pcall(MoveWindWalls, os.clock())
                task.wait(0.5)
            else
                if wasOn then pcall(RestoreWinds) end
                task.wait(0.5)
            end
            wasOn = on
        end
    end)
end

-- NO SHADOWS: the GlobalShadows byte on Lighting is set to 0 (offset from the offsets list when it has
-- one, otherwise 0x134). The original value is read first and put back when the toggle is turned off.
do
    local SHADOWS_OFF = 0x134
    pcall(function()
        local l = C.offsets.Lighting
        if type(l) == "table" and type(l.GlobalShadows) == "number" then SHADOWS_OFF = l.GlobalShadows end
    end)

    -- (the original script called a LightingAddress() helper that was never defined; defined here)
    local function LightingAddress() return Lighting.Address end

    local shadowOriginal = nil
    Feature("no_shadows", 0.5, function()
        local addr = LightingAddress() + SHADOWS_OFF
        if shadowOriginal == nil then
            local ok, v = pcall(memory_read, "byte", addr)
            shadowOriginal = (ok and type(v) == "number") and v or 1
        end
        memory_write("byte", addr, 0)
    end, function()
        if shadowOriginal ~= nil then
            local value = shadowOriginal
            shadowOriginal = nil
            pcall(function() memory_write("byte", LightingAddress() + SHADOWS_OFF, value) end)
        end
    end)
end

-- NO GOLEM TURRETS: move the TurretTrigger parts out of reach.
do
    local turretMover = NewMover()
    Feature("no_golem_turrets", 1, function()
        local thrown = workspace:FindFirstChild("Thrown")
        if not thrown then return end
        for _, child in ipairs(thrown:GetChildren()) do
            if child.Name == "TurretTrigger" then turretMover.MoveTree(child) end
        end
    end, function()
        turretMover.RestoreAll()
    end)
end

-- NO KILL BRICKS: move kill bricks and the Layer 2 kill brick model out of reach.
-- (The SuperWall handling from the original is already covered by Remove Winds.)
do
    local KILL_NAMES = { KillBrick = true, KillPlane = true, LifeField = true, ChasmBrick = true }
    local killMover = NewMover()
    Feature("no_kill_bricks", 2, function()
        for _, child in ipairs(workspace:GetChildren()) do
            if KILL_NAMES[child.Name] then killMover.MoveTree(child) end
        end
        local model = find(workspace, "Layer2Floor1", "Layer2KillbrickModel")
        if model then
            for _, part in ipairs(model:GetChildren()) do killMover.MoveTree(part) end
        end
    end, function()
        killMover.RestoreAll()
    end)
end

-- NO RAIN SOUND: keep the rain sound's playback speed at 0 (it is re-resolved once a second).
do
    local rain, rainCheckedAt = nil, 0
    Feature("no_rain_sound", 0, function()
        local now = os.clock()
        if not rain or now >= rainCheckedAt then
            rainCheckedAt = now + 1
            rain = find(Players.LocalPlayer, "PlayerGui", "WorldClient", "Weather", "Rain")
        end
        if rain and not pcall(function() rain.PlaybackSpeed = 0 end) then rain = nil end
    end)
end
