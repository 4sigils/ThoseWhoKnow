-- Auto Ritual: types the ritual key sequence when the spell GUI opens.
local C = ...
local Players, Nexa, Get, Controls = C.Players, C.Nexa, C.Get, C.Controls

local RITUAL_HOLD = 0.05

-- Which ritual number each key is bound to (swap the numbers if the game rejects the inputs)
local KEY_TO_INDEX = { Z = 1, X = 2, C = 3, V = 4 }
local KEYCODES = { Z = 0x5A, X = 0x58, C = 0x43, V = 0x56 }

local ritualRemote
local function getRitualRemote()
    if ritualRemote then return ritualRemote end
    local rs = game:GetService("ReplicatedStorage")
    local requests = rs:FindFirstChild("Requests")
    local mantras = requests and requests:FindFirstChild("Mantras")
    ritualRemote = mantras and mantras:FindFirstChild("RitualSpellInput") or nil
    return ritualRemote
end

local function getSymbols()
    local lp = Players.LocalPlayer
    local gui = lp and lp:FindFirstChild("PlayerGui")
    local spellGui = gui and gui:FindFirstChild("SpellGui")
    local spellFrame = spellGui and spellGui:FindFirstChild("SpellFrame")
    return spellFrame and spellFrame:FindFirstChild("Symbols") or nil
end

local function frameX(frame)
    local ok, x = pcall(function() return frame.Position.X.Offset end)
    if ok and type(x) == "number" then return x end
    return nil
end

-- default Z/X/C/V, or any single letter/digit (players can rebind their keys)
local function validKey(text)
    return KEY_TO_INDEX[text] ~= nil or text:match("^[A-Z0-9]$") ~= nil
end

-- returns: seq (usable keys in order), id (frame addresses, stable while typing), frame count,
-- raw label texts, sig (id + labels: changes when a new ritual shows up even if frames are reused)
local function readRitual(symbols)
    local frames = {}
    for _, frame in ipairs(symbols:GetChildren()) do
        if frame:FindFirstChild("TextLabel") then frames[#frames + 1] = frame end
    end

    local idParts = { tostring(#frames) }
    for _, f in ipairs(frames) do idParts[#idParts + 1] = tostring(f.Address or "") end
    local ritualId = table.concat(idParts, ",")

    local xs, allX, seen = {}, #frames > 1, {}
    for _, f in ipairs(frames) do
        local x = frameX(f)
        xs[f] = x
        if x == nil or seen[x] then allX = false end
        if x ~= nil then seen[x] = true end
    end
    if allX then table.sort(frames, function(a, b) return xs[a] < xs[b] end) end

    local seq, raw = {}, {}
    for _, frame in ipairs(frames) do
        local label = frame:FindFirstChild("TextLabel")
        local text = string.upper((tostring(label.Text):gsub("%s+", "")))
        raw[#raw + 1] = text
        if validKey(text) then seq[#seq + 1] = text end
    end
    return seq, ritualId, #frames, raw, ritualId .. "|" .. table.concat(raw, "")
end

-- tries the game's remote first; falls back to simulated key presses if it errors or is missing
local remoteBroken = false
local function sendRitualInput(letter)
    if not remoteBroken and KEY_TO_INDEX[letter] then
        local r = getRitualRemote()
        if r then
            local ok = pcall(function() r:FireServer(KEY_TO_INDEX[letter]) end)
            if ok then return end
        end
        remoteBroken = true
    end
    local vk = KEYCODES[letter] or string.byte(letter)
    pcall(keypress, vk)
    task.wait(RITUAL_HOLD)
    pcall(keyrelease, vk)
end

local function RitualStep(lastSig)
    local symbols = getSymbols()
    if not symbols then return nil end

    local seq, _, count, _, sig = readRitual(symbols)
    if count == 0 then return nil end
    if sig == lastSig then return lastSig end
    if #seq == 0 then return sig end

    if not Get("auto_ritual") then return sig end

    local seq2, id2, _, _, sig2 = readRitual(symbols)
    if #seq2 == 0 then return sig end

    for i, letter in ipairs(seq2) do
        if not Nexa:IsAlive() or not Get("auto_ritual") then break end

        local sym = getSymbols()
        if not sym then break end
        if i > 1 then
            local _, curId = readRitual(sym)
            if curId ~= id2 then return nil end
        end

        sendRitualInput(letter)
    end
    return sig2
end

local cRitual = Controls.auto_ritual
task.spawn(function()
    local lastId = nil
    while Nexa:IsAlive() do
        if cRitual.Value then
            task.wait(0.1)
            local ok, res = pcall(RitualStep, lastId)
            if ok then
                lastId = res
            else
                warn("[Deepwoken] ritual error: " .. tostring(res))
            end
        else
            lastId = nil
            task.wait(0.25) -- idle: no need to poll fast
        end
    end
end)
