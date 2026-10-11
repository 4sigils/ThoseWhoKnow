-- Whitelists tab: friends and guilds that auto-parry must never react to.
local C = ...
local Players, Ex, Tab = C.Players, C.Excl, C.Tabs.whitelist
local GetGuild = C.GetGuild

-- FRIENDS
do
    local friendsSec = Tab:AddSection("Friends", "Selected players will never be tracked by auto-parry.", { Column = "left" })
    local friendsDropdown

    local function GetPlayerNames()
        local found, names = {}, {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then found[player.Name] = true end
        end
        for name in pairs(Ex.Friends) do found[name] = true end
        for name in pairs(found) do names[#names + 1] = name end
        table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
        return names
    end

    local function GetIgnoredFriendNames()
        local names = {}
        for name in pairs(Ex.Friends) do names[#names + 1] = name end
        table.sort(names)
        return names
    end

    local function RefreshFriendDropdown()
        local options = GetPlayerNames()
        if #options == 0 then options = {"No other players"} end
        if friendsDropdown then
            friendsDropdown.Options = options
            friendsDropdown._listScroll = 0
            friendsDropdown._listScrollTo = 0
            local selected = {}
            for _, name in ipairs(GetIgnoredFriendNames()) do
                for _, option in ipairs(options) do
                    if option == name then selected[#selected + 1] = name end
                end
            end
            pcall(function() friendsDropdown:SetValue(selected, true) end)
        end
    end

    friendsDropdown = friendsSec:AddDropdown({
        Title = "Excluded players",
        Description = "Multi-select names to ignore.",
        Options = (#GetPlayerNames() > 0 and GetPlayerNames() or {"No other players"}),
        Default = GetIgnoredFriendNames(),
        Multi = true,
        VisibleRows = 8,
        ConfigKey = "deepwoken.friends.excluded",
        Callback = function(value)
            if type(value) ~= "table" then return end
            Ex.Friends = {}
            for _, name in ipairs(value) do
                if type(name) == "string" and name ~= "No other players" then
                    Ex.Friends[name] = true
                end
            end
            C.RebuildFriendsLower()
            C.SaveIgnoredFriends()
        end,
    })
    friendsSec:AddButton({ Title = "", ButtonText = "Refresh player list", Expand = true, Callback = RefreshFriendDropdown })
    friendsSec:AddButton({ Title = "", ButtonText = "Save exclusions", Expand = true, Callback = C.SaveIgnoredFriends })
end

-- GUILDS
do
    local guildSec = Tab:AddSection("Guild", "Members of selected guilds will never be tracked by auto-parry.", { Column = "right" })
    local guildDropdown
    local yourGuildStatus = guildSec:AddStatus({ Title = "Your guild", Default = "-", Tone = "muted" })

    local function GetGuildNames()
        local found, names = {}, {}
        for _, player in ipairs(Players:GetPlayers()) do
            local g = GetGuild(player)
            if g then found[g] = true end
        end
        for name in pairs(Ex.Guilds) do found[name] = true end
        for name in pairs(found) do names[#names + 1] = name end
        table.sort(names, function(a, b) return string.lower(a) < string.lower(b) end)
        return names
    end

    local function RefreshGuildDropdown()
        local options = GetGuildNames()
        if #options == 0 then options = {"No guilds found"} end

        local lp = Players.LocalPlayer
        local myGuild = lp and GetGuild(lp)
        pcall(function() yourGuildStatus:SetValue(myGuild or "-", myGuild and "accent" or "muted") end)

        if guildDropdown then
            guildDropdown.Options = options
            guildDropdown._listScroll = 0
            guildDropdown._listScrollTo = 0
            local selected = {}
            for _, option in ipairs(options) do
                if Ex.Guilds[option] then selected[#selected + 1] = option end
            end
            pcall(function() guildDropdown:SetValue(selected, true) end)
        end
    end

    do
        local initial = GetGuildNames()
        local defaults = {}
        for name in pairs(Ex.Guilds) do defaults[#defaults + 1] = name end
        guildDropdown = guildSec:AddDropdown({
            Title = "Whitelisted guilds",
            Description = "Multi-select guilds to ignore.",
            Options = (#initial > 0 and initial or {"No guilds found"}),
            Default = defaults,
            Multi = true,
            VisibleRows = 8,
            ConfigKey = "deepwoken.guild.excluded",
            Callback = function(value)
                if type(value) ~= "table" then return end
                Ex.Guilds = {}
                for _, name in ipairs(value) do
                    if type(name) == "string" and name ~= "No guilds found" then
                        Ex.Guilds[name] = true
                    end
                end
                C.SaveIgnoredGuilds()
            end,
        })
    end
    guildSec:AddButton({ Title = "", ButtonText = "Scan guilds", Variant = "primary", Expand = true, Callback = RefreshGuildDropdown })
    RefreshGuildDropdown()
end
