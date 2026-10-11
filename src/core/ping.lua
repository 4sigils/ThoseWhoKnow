-- Ping reading (many fallbacks, executors differ) and ping compensation.
local C = ...
local Players = C.Players
local Controls, Get = C.Controls, C.Get
local BASE_PING = C.cfg.BASE_PING

-- Matcha provides its own global GetPingValue(). Grab it here so it is never shadowed.
local NativeGetPingValue = GetPingValue
if type(NativeGetPingValue) ~= "function" and type(getgenv) == "function" then
    local ok, fn = pcall(function() return getgenv().GetPingValue end)
    if ok and type(fn) == "function" then NativeGetPingValue = fn end
end
if type(NativeGetPingValue) ~= "function" then NativeGetPingValue = nil end

local function ValidPing(v)
    return type(v) == "number" and v == v and v > 0 and v < 10000
end

-- tried in order until one returns a usable number
local PING_METHODS = {
    { "native GetPingValue", function()
        if not NativeGetPingValue then error("no native GetPingValue global") end
        return NativeGetPingValue()
    end },
    { "Data Ping", function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end },
    { "Data Ping (string)", function()
        local s = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        return tonumber(tostring(s):match("[%d%.]+"))
    end },
    { "PerformanceStats.Ping", function()
        return game:GetService("Stats").PerformanceStats.Ping:GetValue()
    end },
    -- Matcha-style access: FindFirstChild + property read instead of method calls
    { "FindFirstChild .Value", function()
        local stats = game:GetService("Stats")
        local net = stats:FindFirstChild("Network")
        local sItem = net and net:FindFirstChild("ServerStatsItem")
        local item = sItem and sItem:FindFirstChild("Data Ping")
        return item and item.Value
    end },
    { "FindFirstChild GetValue", function()
        local stats = game:GetService("Stats")
        local net = stats:FindFirstChild("Network")
        local sItem = net and net:FindFirstChild("ServerStatsItem")
        local item = sItem and sItem:FindFirstChild("Data Ping")
        return item and item:GetValue()
    end },
    { "PerformanceStats .Value", function()
        local item = game:GetService("Stats").PerformanceStats:FindFirstChild("Ping")
        return item and item.Value
    end },
    { "GetNetworkPing", function()
        return Players.LocalPlayer:GetNetworkPing() * 1000
    end },
}

function C.GetPingMs()
    local errs = {}
    for _, method in ipairs(PING_METHODS) do
        local ok, v = pcall(method[2])
        if ok and ValidPing(v) then
            C.PingInfo.Method, C.PingInfo.Error = method[1], nil
            return v
        end
        errs[#errs + 1] = method[1] .. ": " .. tostring(ok and ("returned " .. tostring(v)) or v)
    end
    C.PingInfo.Method, C.PingInfo.Error = "none", table.concat(errs, "\n[Deepwoken]   ")
    return nil
end

function C.GetPingValue()
    return C.GetPingMs()
end

function C.PingToComp(ping)
    local comp = math.floor(ping - BASE_PING + 0.5)
    return math.max(-BASE_PING, math.min(300, comp))
end

-- AUTO PING COMP: live ping, smoothed with a 0.25 factor, compensate the one-way trip (ping / 2),
-- and no compensation at all under 25 ms.
local AutoPing = { smoothing = 0.25, min = 25, max = 300, smooth = nil, at = 0, comp = 0 }
C.AutoPing = AutoPing

function C.UpdateAutoPing(now)
    if now - AutoPing.at < 0.2 then return end
    local raw = C.GetPingMs()
    if not raw then return end

    if AutoPing.smooth == nil or now - AutoPing.at > 1.5 then
        AutoPing.smooth = raw -- first sample or a long gap: start fresh
    else
        AutoPing.smooth = AutoPing.smooth + (raw - AutoPing.smooth) * AutoPing.smoothing
    end
    AutoPing.at = now

    if AutoPing.smooth < AutoPing.min then
        AutoPing.comp = 0
    else
        AutoPing.comp = math.min(AutoPing.smooth / 2, AutoPing.max)
    end
end

-- ms to fire earlier: automatic when "Auto Ping Comp" is on, otherwise the Ping Comp slider
function C.GetPingComp()
    local auto = Controls.sb_t_autoping
    if auto and auto.Value then
        C.UpdateAutoPing(os.clock())
        return AutoPing.comp
    end
    return Get("sb_t_ping") or 0
end

-- Samples ping and writes the result into the Ping Comp slider.
function C.ApplyPing(samples, silent)
    samples = samples or 1
    local sum, n = 0, 0
    for i = 1, samples do
        local p = C.GetPingValue()
        if p then sum = sum + p n = n + 1 end
        if i < samples then task.wait(0.25) end
    end

    if n == 0 then
        if not silent then
            C.Nexa:Notify({ Title = "Ping", Content = "Could not read your ping.", Type = "warning", Duration = 3 })
        end
        return nil
    end

    local ping = sum / n
    local comp = C.PingToComp(ping)
    C.Status.ping = ping
    C.Status.comp = comp

    local ctrl = Controls.sb_t_ping
    if ctrl then pcall(function() ctrl:SetValue(comp) end) end

    C.Log(string.format("Ping %.0f ms -> Ping Comp %d ms", ping, comp))
    C.Nexa:Notify({
        Title = "Ping",
        Content = string.format("%.0f ms - Ping Comp set to %d ms", ping, comp),
        Type = "success",
        Duration = 3,
    })
    return ping
end
