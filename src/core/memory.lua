-- Memory access helpers + offsets (downloaded from offsets.imtheo.lol).
local C = (type(getgenv) == "function" and getgenv() or _G).__DW_CTX

local offsets = C.HttpService:JSONDecode(game:HttpGet(C.cfg.OFFSETS_URL)).Offsets
C.offsets = offsets

C.KnownOffsets = {
    AnimationId      = offsets.Misc.AnimationId,
    ClassDescriptor  = offsets.Instance.ClassDescriptor,
    ClassName        = offsets.Instance.ClassName,
    TimePosition     = offsets.AnimationTrack.TimePosition or 0xD8,
    ActiveAnimations = offsets.Animator.ActiveAnimations,
    NodeNext         = 0x10,
}
C.OFF_ANIM = offsets.AnimationTrack.Animation

function C.ReadPointer(addr)
    local ok, v = pcall(memory_read, "uintptr_t", addr)
    if ok and v and v > 4096 then return v end
    return nil
end

function C.ReadString(addr)
    if not addr or addr <= 4096 then return nil end
    local ok, s = pcall(memory_read, "string", addr)
    return ok and s or nil
end

function C.GetClassName(addr)
    if not addr or addr <= 4096 then return "Invalid" end
    local desc = C.ReadPointer(addr + C.KnownOffsets.ClassDescriptor)
    if not desc then return "Error" end
    return C.ReadString(C.ReadPointer(desc + C.KnownOffsets.ClassName)) or "Unknown"
end

function C.CleanId(id)
    return id and tostring(id):match("%d+")
end
