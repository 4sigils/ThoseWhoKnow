-- Animation data: download + parse Animations.lua and IgnoredAnimations.lua.
-- Entry formats: number | { t1, t2 } | { type = "parry", t = {..}, unparryable = true } | { { type = "jump", t = 0.4 }, ... }
-- types: parry, dodge (dodge-only, always Q), unparryable (Q, or F with "Parry Unparryables"), jump, crouch
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local S, Status = C.State, C.Status
local cfg, Log = C.cfg, C.Log
local CleanId = C.CleanId

-- Fallback parser for executors where loadstring on the data file fails.
local function ParseLua(src)
    local pos, len = 1, #src
    local parseValue

    local function skip()
        while pos <= len do
            local _, ws = src:find("^%s+", pos)
            if ws then pos = ws + 1 end
            if src:sub(pos, pos + 1) == "--" then
                local lvl = src:match("^%-%-%[(=*)%[", pos)
                if lvl then
                    local _, e = src:find("]" .. lvl .. "]", pos, true)
                    pos = e and e + 1 or len + 1
                else
                    local nl = src:find("\n", pos, true)
                    pos = nl and nl + 1 or len + 1
                end
            elseif not ws then
                break
            end
        end
    end

    local function parseTable()
        pos = pos + 1
        local t, n = {}, 0
        while pos <= len do
            skip()
            local c = src:sub(pos, pos)
            if c == "}" then pos = pos + 1 break end
            if c == "" then break end

            if c == "[" then
                pos = pos + 1
                local k = parseValue()
                skip(); pos = pos + 1
                skip(); pos = pos + 1
                t[k] = parseValue()
            else
                local name = src:match("^([%a_][%w_]*)%s*=", pos)
                if name then
                    pos = pos + #name
                    skip(); pos = pos + 1
                    t[name] = parseValue()
                else
                    n = n + 1
                    t[n] = parseValue()
                end
            end

            skip()
            local sep = src:sub(pos, pos)
            if sep == "," or sep == ";" then pos = pos + 1 end
        end
        return t
    end

    parseValue = function()
        skip()
        local c = src:sub(pos, pos)
        if c == "{" then return parseTable() end
        if c == '"' or c == "'" then
            local e = src:find(c, pos + 1, true) or len
            local s = src:sub(pos + 1, e - 1)
            pos = e + 1
            return s
        end
        local num = src:match("^-?[%d%.]+", pos)
        if num then pos = pos + #num return tonumber(num) end
        local word = src:match("^[%a_][%w_]*", pos)
        if word then
            pos = pos + #word
            if word == "true" then return true end
            if word == "false" then return false end
            return nil
        end
        pos = pos + 1
        return nil
    end

    skip()
    if src:match("^return", pos) then pos = pos + 6 end
    return parseValue()
end

local function Normalize(v)
    local actions = {}
    local function add(kind, t, unparryable)
        if type(t) == "table" then
            for _, x in ipairs(t) do add(kind, x, unparryable) end
        elseif type(t) == "number" then
            local k = string.lower(tostring(kind))
            if unparryable and k ~= "dodge" then k = "unparryable" end
            actions[#actions + 1] = {kind = k, t = t}
        end
    end

    if type(v) == "number" then
        add("parry", v)
    elseif type(v) == "table" then
        if v.type or v.t then
            add(v.type or "parry", v.t, v.unparryable)
        else
            for _, item in ipairs(v) do
                if type(item) == "number" then
                    add("parry", item)
                elseif type(item) == "table" then
                    add(item.type or "parry", item.t, item.unparryable)
                end
            end
        end
    end
    return #actions > 0 and actions or nil
end

function C.LoadData()
    S.AnimDB = {}
    Status.loaded = 0

    local src = C.HttpGet(cfg.DATA_URL)
    if not src then
        Log("Failed to download anim data from " .. cfg.DATA_URL)
        return
    end

    local data
    if type(loadstring) == "function" then
        local fn = loadstring(src)
        if fn then
            local ok, res = pcall(fn)
            if ok and type(res) == "table" then data = res end
        end
    end
    if not data then
        local ok, res = pcall(ParseLua, src)
        if ok and type(res) == "table" then data = res end
    end
    if not data then
        Log("Could not read anim data. First 80 chars: " .. src:sub(1, 80))
        return
    end

    local n = 0
    for id, value in pairs(data) do
        local actions = Normalize(value)
        if actions then
            local clean = CleanId(id) or tostring(id)
            S.AnimDB[clean] = {name = clean, actions = actions}
            n = n + 1
        end
    end
    Status.loaded = n
    Log("Loaded " .. n .. " animations")
end

function C.LoadIgnored()
    S.IgnoredIds = {}

    local src = C.HttpGet(cfg.IGNORE_URL)
    if not src then
        Log("Failed to download ignore list from " .. cfg.IGNORE_URL)
        return
    end

    for line in src:gmatch("[^\r\n]+") do
        line = line:gsub("%-%-.*$", "")
        for id in line:gmatch("%d+") do S.IgnoredIds[id] = true end
    end

    local n = 0
    for _ in pairs(S.IgnoredIds) do n = n + 1 end
    Status.ignored = n
    Log("Ignoring " .. n .. " animations")
end
