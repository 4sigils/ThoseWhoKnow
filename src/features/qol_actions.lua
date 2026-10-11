-- Button actions for the QOL tab: Knock Self and Reset (wired up via C.QolActions in ui/qol.lua).
-- Each step that needs something this executor may not have (remotes, the cheat's KeyHandler, property
-- writes) is wrapped, and failures are reported instead of silently doing nothing.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Players, Nexa, Log, QolActions = C.Players, C.Nexa, C.Log, C.QolActions

-- walk down a chain of child names, returning nil as soon as one is missing
local function child(root, ...)
    local current = root
    for _, name in ipairs({ ... }) do
        current = current and current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

local function localParts()
    local lp = Players.LocalPlayer
    local char = lp and lp.Character
    return char and char:FindFirstChild("Humanoid"), char and char:FindFirstChild("HumanoidRootPart")
end

-- KNOCK SELF: take acid damage until under 45 health, then three fall-damage hits
local knockBusy = false
QolActions.KnockSelf = function()
    if knockBusy then return end
    knockBusy = true
    task.spawn(function()
        local ok, err = pcall(function()
            local humanoid = localParts()
            if not humanoid then error("no Humanoid found") end

            local env = type(getgenv) == "function" and getgenv() or nil
            local keyHandler = (env and env.KeyHandler) or KeyHandler
            if not keyHandler then
                -- fall back to the game's own module: ReplicatedStorage.Modules.ClientManager.KeyHandler
                local module = child(game:GetService("ReplicatedStorage"), "Modules", "ClientManager", "KeyHandler")
                local req = (env and env.require) or require
                if module and type(req) == "function" then
                    local okReq, result = pcall(req, module)
                    if okReq then keyHandler = result end
                end
            end
            if not keyHandler then
                error("KeyHandler isn't available (no global, and the game module can't be required here)")
            end
            if type(keyHandler) ~= "table" or type(keyHandler.get_key) ~= "function" then
                error("the KeyHandler module doesn't expose get_key, so the FallDamage remote can't be found")
            end

            if humanoid.Health > 45 then
                local acid = child(game:GetService("ReplicatedStorage"), "Requests", "AcidCheck")
                if not acid then error("Requests.AcidCheck not found") end
                local startedAt = os.clock()
                repeat
                    acid:FireServer()
                    task.wait(0.025)
                until humanoid.Health < 45 or os.clock() - startedAt > 10 -- the original had no time limit
            end

            for hit = 1, 3 do
                keyHandler:get_key("FallDamage"):FireServer(20 + math.random(), false)
                if hit < 3 then task.wait(0.25) end
            end
        end)

        if not ok then
            Log("Knock Self failed: " .. tostring(err))
            Nexa:Notify({ Title = "Knock Self", Content = "Failed: " .. tostring(err), Type = "error", Duration = 5 })
        end
        knockBusy = false
    end)
end

-- RESET: throw the root part far out of the map
QolActions.Reset = function()
    local ok, err = pcall(function()
        local _, root = localParts()
        if not root then error("no HumanoidRootPart found") end
        root.CFrame = root.CFrame + Vector3.new(0, 9000000000, 0)
    end)
    if not ok then
        Log("Reset failed: " .. tostring(err))
        Nexa:Notify({ Title = "Reset", Content = "Failed: " .. tostring(err), Type = "error", Duration = 4 })
    end
end
