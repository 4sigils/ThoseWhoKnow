-- Auto Intelligence / Auto Charisma: answers the "ChoicePrompt" GUI (polling, no signals).
local C = ...
local Players, Nexa, Get, Log = C.Players, C.Nexa, C.Get, C.Log

local INTEL_DELAY    = 1.0 -- wait before answering a math question
local CHARISMA_DELAY = 0.5 -- wait before sending the chat line
local POLL_INTERVAL  = 0.25

local lastHandled = nil    -- signature of the prompt we already answered
local warnedRemote = false

local function warnRemote(err)
    if warnedRemote then return end
    warnedRemote = true
    Log("Stat Farm: remote call failed: " .. tostring(err))
    Nexa:Notify({ Title = "Stat Farm", Content = "Your executor can't fire remotes (see console).", Type = "error", Duration = 5 })
end

-- Returns the ChoicePrompt and its ChoiceFrame, or nil if no prompt is open.
local function getPrompt()
    local lp = Players.LocalPlayer
    local gui = lp and lp:FindFirstChild("PlayerGui")
    local prompt = gui and gui:FindFirstChild("ChoicePrompt")
    local frame = prompt and prompt:FindFirstChild("ChoiceFrame")
    if not frame then return nil end
    return prompt, frame
end

local function isButton(inst)
    local ok, result = pcall(function() return inst:IsA("TextButton") end)
    return not ok or result
end

-- Splits on newlines but keeps empty lines, so line numbers match the on-screen text.
local function splitLines(text)
    local lines = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = line
    end
    return lines
end

-- INTELLIGENCE: "What is 12 plus 5?" -> 17
local NUMBER = "(%-?%d+%.?%d*)"
local OPERATIONS = {
    { "plus",       function(a, b) return a + b end },
    { "minus",      function(a, b) return a - b end },
    { "times",      function(a, b) return a * b end },
    { "divided by", function(a, b) return b ~= 0 and a / b or nil end },
}

local function solveQuestion(text)
    text = string.lower(text)
    for _, op in ipairs(OPERATIONS) do
        local a, b = text:match(NUMBER .. "%s+" .. op[1] .. "%s+" .. NUMBER)
        a, b = tonumber(a), tonumber(b)
        if a and b then return op[2](a, b) end
    end
    return nil
end

-- Picks the option whose name (the number it stands for) is closest to the answer, within 1.
local function pickOption(optionsFolder, answer)
    local best, bestDiff
    for _, option in ipairs(optionsFolder:GetChildren()) do
        local value = tonumber(option.Name)
        if value and isButton(option) then
            local diff = math.abs(value - answer)
            if diff <= 1 and (not bestDiff or diff < bestDiff) then
                best, bestDiff = option, diff
            end
        end
    end
    return best
end

local function answerIntelligence(prompt, frame, descLabel)
    local question = descLabel.Text
    local answer = solveQuestion(question)
    if not answer then
        Log("Stat Farm: could not read the question: " .. tostring(question))
        return
    end

    task.wait(INTEL_DELAY)
    if not getPrompt() then return end -- prompt closed while waiting

    local options = frame:FindFirstChild("Options")
    local choice = options and pickOption(options, answer)
    if not choice then
        Log("Stat Farm: no option within 1 of " .. tostring(answer))
        return
    end

    local remote = prompt:FindFirstChild("Choice")
    if not remote then
        Log("Stat Farm: Choice remote not found")
        return
    end

    Log(string.format("Stat Farm: intelligence answer %s -> option %s", tostring(answer), choice.Name))
    local ok, err = pcall(function() remote:FireServer(choice.Name) end)
    if not ok then warnRemote(err) end
end

-- CHARISMA: the line to say is on the prompt's second line, wrapped in quotes.
local function answerCharisma(prompt, descLabel)
    local line = splitLines(descLabel.Text)[2]
    if not line or line == "" then
        Log("Stat Farm: no charisma line found in the prompt text")
        return
    end
    local reply = string.sub(line, 2, -2) -- strip the surrounding quotes

    task.wait(CHARISMA_DELAY)
    if not getPrompt() then return end

    local chat = prompt:FindFirstChild("ChatChoice")
    if not chat then
        Log("Stat Farm: ChatChoice remote not found")
        return
    end

    Log("Stat Farm: charisma reply -> " .. reply)
    local ok, err = pcall(function() chat:InvokeServer(reply) end)
    if not ok then warnRemote(err) end
end

local function StatFarmStep()
    local prompt, frame = getPrompt()
    if not prompt then
        lastHandled = nil
        return
    end

    local descSheet = frame:FindFirstChild("DescSheet")
    local useIntel = descSheet ~= nil and Get("auto_intel")
    local useCharisma = not useIntel and Get("auto_charisma")
    if not useIntel and not useCharisma then return end

    local descLabel = useIntel and descSheet:FindFirstChild("Desc") or frame:FindFirstChild("Desc")
    if not descLabel or descLabel.Text == "" then return end -- text not loaded yet

    local signature = tostring(prompt.Address) .. "|" .. descLabel.Text
    if signature == lastHandled then return end
    lastHandled = signature

    if useIntel then
        answerIntelligence(prompt, frame, descLabel)
    else
        answerCharisma(prompt, descLabel)
    end
end

task.spawn(function()
    while Nexa:IsAlive() do
        if Get("auto_intel") or Get("auto_charisma") then
            local ok, err = pcall(StatFarmStep)
            if not ok then warn("[Deepwoken] stat farm error: " .. tostring(err)) end
            task.wait(POLL_INTERVAL)
        else
            lastHandled = nil
            task.wait(0.5) -- idle
        end
    end
end)
