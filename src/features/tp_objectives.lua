-- TP to Objectives: Layer 2 objective helper. While the toggle is on it repeatedly does the next step:
-- door key and door, Galewax, blood jars (chaser), buzz obelisks, bone spears and altars. Movement flies
-- your root part toward the target at 200 studs/s (CFrame writes); signals/library helpers are plain lookups.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Players, Nexa, Controls, Log = C.Players, C.Nexa, C.Controls, C.Log

local SPEED = 200
local warnedPrompt = false

local function enabled()
    return Nexa:IsAlive() and Controls.tp_objectives.Value
end

local function localRoot()
    local lp = Players.LocalPlayer
    local char = lp and lp.Character
    return char, char and char:FindFirstChild("HumanoidRootPart")
end

-- FindFirstChild(name, true), with a descendants scan as fallback if the recursive flag isn't supported
local function findDeep(inst, name)
    local ok, result = pcall(function() return inst:FindFirstChild(name, true) end)
    if ok then return result end
    local okD, list = pcall(function() return inst:GetDescendants() end)
    if okD and type(list) == "table" then
        for _, d in ipairs(list) do
            if d.Name == name then return d end
        end
    end
    return nil
end

-- world position of a part, model or ObjectValue target
local function getPosition(inst)
    if not inst then return nil end
    local ok, isPart = pcall(function() return inst:IsA("BasePart") end)
    if ok and isPart then return inst.Position end

    local okM, isModel = pcall(function() return inst:IsA("Model") end)
    if okM and isModel then
        local okP, pivot = pcall(function() return inst:GetPivot() end)
        if okP and pivot then return pivot.Position end
        if inst.PrimaryPart then return inst.PrimaryPart.Position end
        local okD, list = pcall(function() return inst:GetDescendants() end)
        if okD and type(list) == "table" then
            for _, d in ipairs(list) do
                local okB, isBase = pcall(function() return d:IsA("BasePart") end)
                if okB and isBase then return d.Position end
            end
        end
        return nil
    end

    local okO, isObj = pcall(function() return inst:IsA("ObjectValue") end)
    if okO and isObj and inst.Value then return getPosition(inst.Value) end
    return nil
end

local function getNearest(list, filter)
    local _, root = localRoot()
    if not root then return nil end
    local rootPos = root.Position
    local best, bestDist = nil, 9e9
    for _, v in ipairs(list) do
        local pos = getPosition(v)
        if pos and filter(v) then
            local d = (pos - rootPos).Magnitude
            if d < bestDist then best, bestDist = v, d end
        end
    end
    return best
end

-- fly the root part to `target` at SPEED studs/s; returns false if interrupted
local function moveTo(target)
    if not target then return false end
    local last = os.clock()
    while enabled() do
        local _, root = localRoot()
        if not root then return false end
        local diff = target - root.Position
        local dist = diff.Magnitude
        if dist < 1 then return true end

        local now = os.clock()
        local step = SPEED * math.min(now - last, 0.1)
        last = now
        local delta = (dist <= step) and diff or diff * (step / dist)
        root.CFrame = root.CFrame + delta
        task.wait()
    end
    return false
end

local function firePrompt(prompt)
    if not prompt then return end
    if type(fireproximityprompt) ~= "function" then
        if not warnedPrompt then
            warnedPrompt = true
            Log("TP to Objectives: this executor has no fireproximityprompt, prompts can't be triggered")
            Nexa:Notify({ Title = "TP to Objectives", Content = "No fireproximityprompt here, so prompts won't be triggered.", Type = "warning", Duration = 5 })
        end
        return
    end
    pcall(fireproximityprompt, prompt)
end

-- keeps firing the dialogue exit remote for 2 seconds (closes the prompt window)
local function closePrompt()
    local rs = game:GetService("ReplicatedStorage")
    local requests = rs:FindFirstChild("Requests")
    local send = requests and requests:FindFirstChild("SendDialogue")
    if not send then return end
    local start = os.clock()
    while os.clock() - start < 2 do
        pcall(function() send:FireServer({ exit = true }) end)
        task.wait()
    end
end

local function pingWait()
    task.wait(((C.GetPingValue() or 0) / 1000) * 2 + 0.05)
end

-- altars on one floor that don't hold a BoneSpear yet
local function pendingAltars(folder, modelsOnly)
    local pending = {}
    if not folder then return pending end
    for _, altar in ipairs(folder:GetChildren()) do
        local isAltar = altar.Name:match("Altar") ~= nil
        if isAltar and modelsOnly then
            local ok, isModel = pcall(function() return altar:IsA("Model") end)
            isAltar = ok and isModel
        end
        if isAltar and not findDeep(altar, "BoneSpear") then
            pending[#pending + 1] = altar
        end
    end
    return pending
end

local function ObjectiveStep()
    local live = workspace:FindFirstChild("Live")
    local ingredients = workspace:FindFirstChild("Ingredients")
    local npcs = workspace:FindFirstChild("NPCs")
    local floor1 = workspace:FindFirstChild("Layer2Floor1")
    local doorKey = floor1 and floor1:FindFirstChild("DoorKey")
    local door = npcs and npcs:FindFirstChild("TheDoor")
    local key = npcs and npcs:FindFirstChild("TheKey")
    local doorPrompt = door and door:FindFirstChild("InteractPrompt")
    local keyPrompt = key and key:FindFirstChild("InteractPrompt")
    local collection = game:GetService("CollectionService")

    local hasChaser = false
    if live then
        for _, entity in ipairs(live:GetChildren()) do
            if entity.Name:match(".chaser") then
                hasChaser = true
                break
            end
        end
    end

    -- door and key
    if doorPrompt and keyPrompt and doorKey then
        moveTo(getPosition(doorKey))
        if not enabled() then return end
        pingWait()

        if keyPrompt.Parent then
            firePrompt(keyPrompt)
            task.spawn(closePrompt)
        end

        moveTo(getPosition(door))
        if not enabled() then return end
        pingWait()

        if doorPrompt.Parent then
            firePrompt(doorPrompt)
            task.spawn(closePrompt)
        end
    end

    -- Galewax
    if floor1 and not hasChaser and not keyPrompt and ingredients then
        local galewax = getNearest(ingredients:GetChildren(), function(v) return v.Name == "Galewax" end)
        if galewax then moveTo(getPosition(galewax)) end
        if not enabled() then return end
    end

    -- blood jars while a chaser is around
    if hasChaser then
        local jar = getNearest(collection:GetTagged("BloodJar"), function(v) return findDeep(v, "JarLight") ~= nil end)
        if jar then moveTo(getPosition(jar)) end
        if not enabled() then return end
    end

    -- buzz obelisks / bone spears / altars
    local char = localRoot()
    local obelisks = collection:GetTagged("BuzzObelisk")
    if #obelisks > 0 then
        local obelisk = getNearest(obelisks, function(v) return v.Name:match("BuzzPart") ~= nil end)
        if obelisk then
            moveTo(getPosition(obelisk))
            if not enabled() then return end
            local prompt = obelisk:FindFirstChild("InteractPrompt")
            firePrompt(prompt)
        end

    elseif char and not char:FindFirstChild("BoneSpear") and workspace:FindFirstChild("Layer2Floor2") then
        local thrown = workspace:FindFirstChild("Thrown")
        local candidates = {}
        if thrown then
            for _, object in ipairs(thrown:GetChildren()) do
                if object.Name:match("BoneSpear") and object:FindFirstChild("InteractPrompt") then
                    candidates[#candidates + 1] = object
                end
            end
        end
        local spear = getNearest(candidates, function() return true end)
        if spear then
            moveTo(getPosition(spear))
            if not enabled() then return end
            task.wait(0.2)
            firePrompt(spear:FindFirstChild("InteractPrompt"))
        end

    elseif char and char:FindFirstChild("BoneSpear") and workspace:FindFirstChild("Layer2Floor2") then
        local room = workspace:FindFirstChild("TrueAvatarBossRoom")
        if not room then return end

        -- floors are done in order: the first floor that still has an empty altar is the target
        local pending = pendingAltars(room:FindFirstChild("Floor1Stuff"), true)
        if #pending == 0 then pending = pendingAltars(room:FindFirstChild("Floor2Stuff"), true) end
        if #pending == 0 then pending = pendingAltars(room:FindFirstChild("Floor3Stuff"), false) end

        local altar = getNearest(pending, function() return true end)
        if not altar or altar:FindFirstChild("BoneSpear") then return end

        local center = altar:FindFirstChild("Center")
        moveTo(getPosition(center) or getPosition(altar))
    end
end

task.spawn(function()
    local lastErr = nil
    while Nexa:IsAlive() do
        if Controls.tp_objectives.Value then
            local ok, err = pcall(ObjectiveStep)
            if not ok and err ~= lastErr then
                lastErr = err
                warn("[Deepwoken] TP to Objectives error: " .. tostring(err))
            end
            task.wait(0.2)
        else
            task.wait(0.25)
        end
    end
end)
