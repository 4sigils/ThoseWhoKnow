-- Auto Ragdoll Cancel: right-clicks every 0.5s while the local character is ragdolled.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Players, Nexa, Controls = C.Players, C.Nexa, C.Controls
local CleanName = C.CleanName

local function FindLiveByName(name)
    local live = workspace:FindFirstChild("Live")
    if not live then return nil end
    for _, model in ipairs(live:GetChildren()) do
        if CleanName(model.Name) == name then return model end
    end
    return nil
end

local function IsRagdolled()
    local lp = Players.LocalPlayer
    if not lp then return false end
    local live = workspace:FindFirstChild("Live")
    if not live then return false end

    local model = live:FindFirstChild(lp.Name) or FindLiveByName(lp.Name)
    if not model then return false end

    local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
    if not torso then return false end

    return torso:FindFirstChild("RagdollAttach") ~= nil
end

task.spawn(function()
    local lastClick = 0
    local cRag = Controls.auto_ragdoll_cancel
    while Nexa:IsAlive() do
        if cRag.Value then
            task.wait(0.05)
            local ok, ragdolled = pcall(IsRagdolled)
            if ok and ragdolled then
                local now = os.clock()
                if now - lastClick >= 0.5 then
                    lastClick = now
                    C.RightClick()
                end
            else
                lastClick = 0
            end
        else
            task.wait(0.25) -- idle
        end
    end
end)
