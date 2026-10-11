-- Downloads, patches and loads the Nexa UI library. Exposes C.Nexa.
local C = ...
local NEXA_SOURCE = C.cfg.NEXA_SOURCE

local function isNexaLibrary(value)
    return type(value) == "table"
        and type(value.CreateWindow) == "function"
        and type(value.AddTab) == "function"
        and type(value.Notify) == "function"
end

local function findExportedNexa()
    local env = type(getgenv) == "function" and getgenv() or nil
    local candidates = {}
    if env then
        candidates[#candidates + 1] = env.Nexa
        candidates[#candidates + 1] = env.UI
        candidates[#candidates + 1] = env.DrawingUI
    end
    candidates[#candidates + 1] = rawget(_G, "Nexa")
    candidates[#candidates + 1] = rawget(_G, "UI")
    candidates[#candidates + 1] = rawget(_G, "DrawingUI")
    if type(shared) == "table" then
        candidates[#candidates + 1] = shared.Nexa
        candidates[#candidates + 1] = shared.UI
        candidates[#candidates + 1] = shared.DrawingUI
    end
    for _, candidate in ipairs(candidates) do
        if isNexaLibrary(candidate) then return candidate end
    end
    return nil
end

local function getNexa()
    -- destroy a previous instance so re-executing doesn't stack windows
    local old = findExportedNexa()
    if old then pcall(function() old:Destroy() end) end

    local okHttp, source = pcall(function() return game:HttpGet(NEXA_SOURCE) end)
    if not okHttp then error("[Deepwoken] Failed to download Nexa: " .. tostring(source)) end
    if type(source) ~= "string" or #source < 100 then
        error("[Deepwoken] Nexa download returned invalid/empty source.")
    end

    local islandPatch = [[local function DrawTitleBar(title, subtitle)
    local th = State.Theme]]
    local islandReplacement = [[local function DrawTitleBar(title, subtitle)
    if not State.Open then
        if State.ProfileAvatar and State.ProfileAvatar.Image then
            pcall(function() State.ProfileAvatar.Image.Visible = false end)
        end
        for _, action in ipairs(State.Island and State.Island.Actions or {}) do
            if action._IslandImage then
                pcall(function() action._IslandImage.Visible = false end)
            end
        end
        State.ProfileAvatarRect = nil
        return
    end
    local th = State.Theme]]
    if string.find(source, islandPatch, 1, true) then
        source = string.gsub(source, islandPatch, function()
            return islandReplacement
        end, 1)
    else
        warn("[Deepwoken] Nexa island visibility patch point not found; floating UI may remain visible.")
    end

    -- Notifications were drawn with the window's fade alpha, which is 0 while the menu is closed:
    -- the box and text vanished and only the (image) logo stayed visible. Draw them at full alpha.
    local patchedSource, notifPatches = string.gsub(source, "\n([ \t]*)DrawNotifications%(%)", function(indent)
        return "\n" .. indent .. "do local __pa = FrameAlpha FrameAlpha = 1 DrawNotifications() FrameAlpha = __pa end"
    end)
    if notifPatches > 0 then
        source = patchedSource
    else
        warn("[Deepwoken] Nexa notification patch point not found; notifications may only show the logo while the menu is closed.")
    end

    local chunk, compileError = loadstring(source)
    if not chunk then error("[Deepwoken] Nexa failed to compile: " .. tostring(compileError)) end

    local okRun, returned = pcall(chunk)
    if not okRun then error("[Deepwoken] Nexa failed while executing: " .. tostring(returned)) end

    if isNexaLibrary(returned) then return returned end
    local exported = findExportedNexa()
    if exported then return exported end

    error("[Deepwoken] Nexa executed, but no compatible Library API was exported.")
end

C.Nexa = getNexa()
