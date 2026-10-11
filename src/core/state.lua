-- Shared mutable state. Always access through C.State.X (never cache the table in a local),
-- because several fields are replaced wholesale (e.g. S.Queue = {}).
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX

C.Players     = game:GetService("Players")
C.HttpService = game:GetService("HttpService")
C.Lighting    = game:GetService("Lighting")

C.State = {
    AnimDB       = {},   -- id -> {name, actions}
    IgnoredIds   = {},   -- animation ids hidden from the tracker
    Active       = {},   -- enemy|anim -> start time
    Queue        = {},   -- scheduled parry/dodge actions
    Releases     = {},   -- pending key releases
    Enemies      = {},
    EnemyCache   = {},
    NextRefresh  = 0,
    LocalHRP     = nil,
    Tracked      = {},
    TrackedCount = 0,
    Hist         = {},
    HistDirty    = true,
    ConfigDirty  = false,
}

C.Status = { loaded = 0, ignored = 0, tracked = 0, last = "none", lastDist = 0, loopMs = 0, scanMs = 0, ping = 0 }
C.PingInfo = { Method = "none", Error = nil }
C.QolActions = {} -- filled in by features/qol_actions.lua, called from ui/qol.lua

function C.Log(msg) print("[Deepwoken] " .. tostring(msg)) end
