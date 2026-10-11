-- HTTP helper with executor fallbacks.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX

function C.HttpGet(url)
    local attempts = {
        function() return game:HttpGet(url) end,
        function()
            local req = request or http_request or (syn and syn.request)
            local res = req and req({Url = url, Method = "GET"})
            return res and res.Body
        end,
    }
    for _, try in ipairs(attempts) do
        local ok, body = pcall(try)
        -- GitHub returns the literal text "404: Not Found" for bad URLs; don't treat that as data
        if ok and type(body) == "string" and #body > 0 and not body:match("^%s*404:") then
            return body
        end
    end
    return nil
end
