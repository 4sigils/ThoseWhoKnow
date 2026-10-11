-- Tracker tab: pick a target, watch which animations it plays (stepping logic: features/tracker.lua).
local C = ...
local S, Nexa, Players, Ex, cfg = C.State, C.Nexa, C.Players, C.Excl, C.cfg
local Tab = C.Tabs.tracker
local CleanName, GetAnimatorAddr = C.CleanName, C.GetAnimatorAddr

local NpcMap, FallbackMap = {}, {}

local function GetTargetFromPath(path)
    local function walk(p)
        local current = workspace
        for part in string.gmatch(p, "[^/]+") do
            current = current:FindFirstChild(part)
            if not current then return nil end
        end
        return current
    end
    return walk(path) or walk("Live/" .. path)
end

local function FindLiveByName(name)
    local live = workspace:FindFirstChild("Live")
    if not live then return nil end
    for _, model in ipairs(live:GetChildren()) do
        if CleanName(model.Name) == name then return model end
    end
    return nil
end

local function FindOwnModel()
    local lp = Players.LocalPlayer
    if not lp then return nil end
    local ch = lp.Character
    if ch then return ch end
    local ok, list = pcall(function() return workspace:GetDescendants() end)
    if ok and type(list) == "table" then
        for _, v in ipairs(list) do
            if v.Name == lp.Name and v:FindFirstChild("Humanoid") then return v end
        end
    end
    return nil
end

-- NOW PLAYING
local playingSec = Tab:AddSection("Now Playing", "Animations seen on tracked targets (ignored ones hidden).", { Column = "left" })
local emptyLabel = playingSec:AddLabel({ Title = "Nothing yet", Description = "Pick a target and press Start Tracking." })
local histLabels = {}
for i = 1, cfg.HIST_SLOTS do
    local l = playingSec:AddLabel({ Title = "", Description = "" })
    l:SetVisible(false)
    histLabels[i] = l
end

function C.RefreshHistLabels()
    S.HistDirty = false
    emptyLabel:SetVisible(#S.Hist == 0)
    for i = 1, cfg.HIST_SLOTS do
        local l, e = histLabels[i], S.Hist[i]
        if e then
            l:SetTitle("rbxassetid://" .. e.id)
            l:SetDescription(string.format("%s  x%d  %s", e.target, e.count, S.AnimDB[e.id] and "(in data)" or "(new)"))
            l:SetVisible(true)
        else
            l:SetVisible(false)
        end
    end
end

-- TARGET SELECTION
local trackSec = Tab:AddSection("Track Target", "Who to watch.", { Column = "right" })

local function SetOptions(dd, names)
    if #names == 0 then names = {"None"} end
    local keep = dd.Value
    dd.Options = names
    dd._listScroll = 0
    dd._listScrollTo = 0
    local pick = names[1]
    for _, n in ipairs(names) do if n == keep then pick = n break end end
    dd:SetValue(pick, true)
end

local targetType, playerDD, npcDD, pathBox, fallbackDD, folderStatus

local function RefreshLists()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and not Ex.Friends[p.Name] then
            names[#names + 1] = p.Name
        end
    end
    table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
    SetOptions(playerDD, names)

    NpcMap = {}
    local npcNames = {}
    local live = workspace:FindFirstChild("Live")
    if live then
        for _, model in ipairs(live:GetChildren()) do
            local n = model.Name
            if not Players:FindFirstChild(CleanName(n)) and model:FindFirstChild("Humanoid") then
                local disp, c = n, 1
                while NpcMap[disp] do c = c + 1 disp = n .. " (" .. c .. ")" end
                NpcMap[disp] = model
                npcNames[#npcNames + 1] = disp
            end
        end
    end
    table.sort(npcNames, function(a, b) return string.lower(a) < string.lower(b) end)
    SetOptions(npcDD, npcNames)

    FallbackMap = {}
    local fbNames = {}
    local own = FindOwnModel()
    local folder = own and own.Parent
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model:FindFirstChild("Humanoid") then
                local n = CleanName(model.Name)
                local disp, c = n, 1
                while FallbackMap[disp] do c = c + 1 disp = n .. " (" .. c .. ")" end
                FallbackMap[disp] = model
                fbNames[#fbNames + 1] = disp
            end
        end
    end
    table.sort(fbNames, function(a, b) return string.lower(a) < string.lower(b) end)
    SetOptions(fallbackDD, fbNames)
    pcall(function() folderStatus:SetValue(folder and tostring(folder.Name) or "-", folder and "accent" or "muted") end)
end

local function UpdateTargetVisibility(kind)
    playerDD:SetVisible(kind == "Player")
    npcDD:SetVisible(kind == "NPC")
    fallbackDD:SetVisible(kind == "Fallback")
    pcall(function() folderStatus:SetVisible(kind == "Fallback") end)
    if pathBox then pathBox:SetVisible(kind == "NPC") end
end

targetType = trackSec:AddDropdown({
    Title = "Target Type",
    Options = { "LocalPlayer", "Player", "NPC", "Fallback" },
    Default = "LocalPlayer",
    ConfigKey = "deepwoken.tracker.type",
    Callback = function(v)
        UpdateTargetVisibility(v)
        if v ~= "LocalPlayer" then RefreshLists() end
    end,
})
playerDD   = trackSec:AddDropdown({ Title = "Player List", Options = { "None" }, Default = "None", VisibleRows = 8 })
npcDD      = trackSec:AddDropdown({ Title = "NPC List", Options = { "None" }, Default = "None", VisibleRows = 8 })
fallbackDD = trackSec:AddDropdown({ Title = "Fallback List", Options = { "None" }, Default = "None", VisibleRows = 8 })
folderStatus = trackSec:AddStatus({ Title = "Folder", Default = "-", Tone = "muted" })
pathBox = trackSec.AddTextbox and trackSec:AddTextbox({
    Title = "NPC Path",
    Placeholder = "Live/NpcName (optional)",
    Default = "",
})
UpdateTargetVisibility("LocalPlayer")

local trackingStatus = trackSec:AddStatus({ Title = "Tracking", Default = "None", Tone = "muted" })

function C.UpdateTrackingStatus()
    if S.TrackedCount == 0 then
        trackingStatus:SetValue("None", "muted")
    else
        trackingStatus:SetValue(S.TrackedCount .. " target" .. (S.TrackedCount > 1 and "s" or ""), "success")
    end
end

local function ResolveTarget()
    local kind = targetType:GetValue()
    if kind == "LocalPlayer" then
        local lp = Players.LocalPlayer
        return FindLiveByName(lp.Name), lp.Name
    elseif kind == "Player" then
        local n = playerDD:GetValue()
        if Ex.Friends[n] then return nil, n .. " (excluded)" end
        return FindLiveByName(n), n
    elseif kind == "Fallback" then
        local disp = fallbackDD:GetValue()
        return FallbackMap[disp], disp
    end

    local path = pathBox and tostring(pathBox:GetValue() or "") or ""
    if path ~= "" then
        local model = GetTargetFromPath(path)
        return model, path:match("([^/]+)$") or path
    end
    local disp = npcDD:GetValue()
    return NpcMap[disp], disp
end

local function StartTracking()
    if targetType:GetValue() ~= "LocalPlayer" then RefreshLists() end
    local model, label = ResolveTarget()
    if not model then
        Nexa:Notify({ Title = "Tracker", Content = "Target not found: " .. tostring(label), Type = "warning", Duration = 3 })
        return
    end
    local addr = model.Address
    if not S.Tracked[addr] then
        S.Tracked[addr] = { model = model, animator = GetAnimatorAddr(model), name = label, seen = {} }
        S.TrackedCount = S.TrackedCount + 1
    end
    C.UpdateTrackingStatus()
    Nexa:Notify({ Title = "Tracker", Content = "Tracking " .. tostring(label), Type = "success", Duration = 2 })
end

local function StopTracking()
    S.Tracked, S.TrackedCount = {}, 0
    C.UpdateTrackingStatus()
end

trackSec:AddButton({ Title = "", ButtonText = "Start Tracking", Variant = "primary", Expand = true, Callback = StartTracking })
trackSec:AddButton({ Title = "", ButtonText = "Stop All Tracking", Variant = "danger", Expand = true, Callback = StopTracking })

local ctrlSec = Tab:AddSection("Controls", "Tracker history controls.", { Column = "left" })
ctrlSec:AddButton({
    Title = "",
    ButtonText = "Refresh / Clear labels",
    Expand = true,
    Callback = function()
        S.Hist, S.HistDirty = {}, true
        for _, t in pairs(S.Tracked) do t.seen = {} end
        if targetType:GetValue() ~= "LocalPlayer" then RefreshLists() end
    end,
})

RefreshLists()
