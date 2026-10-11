-- Config autoload (applies saved values to registered controls) + event-driven autosave.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local S, Controls, HttpService, Nexa = C.State, C.Controls, C.HttpService, C.Nexa
local CONFIG_FILE = C.cfg.CONFIG_FILE

-- flags that are never saved / restored
local SKIP = { sb_t_ping = true, print_parries = true, tp_objectives = true }

if type(readfile) == "function" and type(isfile) == "function" then
    local ok, raw = pcall(function()
        if isfile(CONFIG_FILE) then return readfile(CONFIG_FILE) end
    end)
    if ok and type(raw) == "string" and raw ~= "" then
        local good, saved = pcall(function() return HttpService:JSONDecode(raw) end)
        if good and type(saved) == "table" then
            for flag, ctrl in pairs(Controls) do
                if not SKIP[flag] and saved[flag] ~= nil then
                    pcall(function() ctrl:SetValue(saved[flag]) end)
                end
            end
        end
    end
end

if type(writefile) == "function" then
    -- nothing is polled or compared, we only write when a control actually changed
    task.spawn(function()
        S.ConfigDirty = false
        while Nexa:IsAlive() do
            task.wait(1)
            if S.ConfigDirty then
                S.ConfigDirty = false
                local snap = {}
                for flag, ctrl in pairs(Controls) do
                    if not SKIP[flag] then
                        local v = ctrl.Value
                        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                            snap[flag] = v
                        end
                    end
                end
                pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(snap)) end)
            end
        end
    end)
end
