-- Boot sequence: load data, populate labels, greet, auto-set ping comp.
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX
local Nexa, Status = C.Nexa, C.Status

C.LoadData()
C.LoadIgnored()
C.RefreshHistLabels()

Nexa:Notify({
    Title = "Deepwoken",
    Content = "Loaded " .. Status.loaded .. " animations. Press P to toggle the menu.",
    Type = "success",
    Duration = 5,
})

task.spawn(function()
    task.wait(1)
    C.ApplyPing(6, true)
end)
