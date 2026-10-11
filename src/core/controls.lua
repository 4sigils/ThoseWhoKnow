-- Control registry: every setting that should be autosaved / read by features goes through Reg().
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX

local Controls = {}
C.Controls = Controls

-- ConfigDirty is set whenever a registered control changes; the autosave loop only writes when it is true
function C.Reg(flag, ctrl)
    Controls[flag] = ctrl
    ctrl:OnChanged(function() C.State.ConfigDirty = true end)
    return ctrl
end

function C.Get(flag)
    local c = Controls[flag]
    if c then return c:GetValue() end
    return nil
end
