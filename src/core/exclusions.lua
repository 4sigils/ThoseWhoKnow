-- Persistent friend / guild exclusions (never auto-parried). State lives in C.Excl.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local HttpService, Nexa, cfg = C.HttpService, C.Nexa, C.cfg

local Ex = { Friends = {}, FriendsLower = {}, Guilds = {} }
C.Excl = Ex

local function loadNameSet(file)
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return nil end
    local ok, raw = pcall(function()
        if isfile(file) then return readfile(file) end
    end)
    if not ok or type(raw) ~= "string" or raw == "" then return nil end
    local good, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if not (good and type(decoded) == "table") then return nil end
    local set = {}
    for _, name in ipairs(decoded) do
        if type(name) == "string" then set[name] = true end
    end
    return set
end

local function sortedNames(set)
    local names = {}
    for name in pairs(set) do names[#names + 1] = name end
    table.sort(names)
    return names
end

-- lower-cased lookup; enemies carry a pre-lowered name (lname) so the scan never allocates strings
function C.RebuildFriendsLower()
    Ex.FriendsLower = {}
    for name in pairs(Ex.Friends) do Ex.FriendsLower[string.lower(name)] = true end
end

function C.SaveIgnoredFriends()
    if type(writefile) ~= "function" then
        Nexa:Notify({ Title = "Friends", Content = "This executor does not support saving files.", Type = "warning", Duration = 3 })
        return
    end
    local names = sortedNames(Ex.Friends)
    local ok = pcall(function() writefile(cfg.FRIENDS_FILE, HttpService:JSONEncode(names)) end)
    Nexa:Notify({ Title = "Friends", Content = ok and ("Saved " .. #names .. " excluded name(s).") or "Could not save friend list.", Type = ok and "success" or "error", Duration = 3 })
end

function C.SaveIgnoredGuilds()
    if type(writefile) ~= "function" then return end
    local names = sortedNames(Ex.Guilds)
    pcall(function() writefile(cfg.GUILDS_FILE, HttpService:JSONEncode(names)) end)
end

Ex.Friends = loadNameSet(cfg.FRIENDS_FILE) or {}
Ex.Guilds  = loadNameSet(cfg.GUILDS_FILE) or {}
C.RebuildFriendsLower()
