--[[
    Deepwoken - modular entry point

    Run this single file from your executor:

        loadstring(game:HttpGet("https://raw.githubusercontent.com/4sigils/Deepwoken/refs/heads/main/main.lua"))()

    Every file under src/ is downloaded, compiled and called with the shared context table `C` as its
    first vararg (`local C = ...`). Modules talk to each other only through `C`.

    Optional globals (set them BEFORE running this file):
        getgenv().DEEPWOKEN_BASE  = "https://raw.githubusercontent.com/<user>/<repo>/refs/heads/<branch>/"
        getgenv().DEEPWOKEN_LOCAL = "Deepwoken/"   -- load src/ from your executor's workspace folder instead of GitHub
]]

local env = (type(getgenv) == "function" and getgenv()) or _G

local C = {}
C.BASE  = env.DEEPWOKEN_BASE or "https://raw.githubusercontent.com/4sigils/Deepwoken/refs/heads/main/"
C.LOCAL = env.DEEPWOKEN_LOCAL

function C.fetch(path)
    if C.LOCAL and type(readfile) == "function" then
        local ok, src = pcall(readfile, C.LOCAL .. path)
        if ok and type(src) == "string" and #src > 0 then return src end
    end
    local ok, src = pcall(function() return game:HttpGet(C.BASE .. path) end)
    -- GitHub answers bad paths with the literal text "404: Not Found"
    if not ok or type(src) ~= "string" or #src == 0 or src:match("^%s*404:") then
        error("could not download " .. path .. " (" .. tostring(src) .. ")", 0)
    end
    return src
end

function C.load(path)
    if type(loadstring) ~= "function" then error("this environment does not provide loadstring", 0) end
    local fn, err = loadstring(C.fetch(path), "@" .. path)
    if not fn then error("compile error in " .. path .. ": " .. tostring(err), 0) end
    return fn(C)
end

-- Load order matters: core -> UI (creates every control) -> features (read the controls) -> startup/loop.
local MODULES = {
    -- core
    "src/core/state.lua",
    "src/core/config.lua",
    "src/core/nexa.lua",
    "src/core/controls.lua",
    "src/core/http.lua",
    "src/core/memory.lua",
    "src/core/enemies.lua",
    "src/core/input.lua",
    "src/core/ping.lua",
    "src/core/data.lua",
    "src/core/exclusions.lua",
    -- ui
    "src/ui/window.lua",
    "src/ui/whitelists.lua",
    "src/ui/autoparry.lua",
    "src/ui/automation.lua",
    "src/ui/misc.lua",
    "src/ui/qol.lua",
    "src/ui/tracker.lua",
    "src/ui/debug.lua",
    "src/core/autosave.lua",
    -- features
    "src/features/autoparry.lua",
    "src/features/tracker.lua",
    "src/features/ritual.lua",
    "src/features/ragdoll.lua",
    "src/features/nofog.lua",
    "src/features/removals.lua",
    "src/features/statfarm.lua",
    "src/features/tp_objectives.lua",
    "src/features/qol_actions.lua",
    -- boot
    "src/core/startup.lua",
    "src/core/mainloop.lua",
}

for _, path in ipairs(MODULES) do
    local ok, err = pcall(C.load, path)
    if not ok then error("[Deepwoken] module " .. path .. " failed: " .. tostring(err), 0) end
end

return C.Nexa
