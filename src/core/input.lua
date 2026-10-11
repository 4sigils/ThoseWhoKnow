-- Keyboard / mouse helpers.
local C = ...
local S = C.State

-- Presses a key now and schedules its release (the main loop processes S.Releases).
function C.PressKey(vk, holdSeconds)
    local ok = pcall(keypress, vk)
    if not ok then
        print("[Deepwoken] keypress() failed - your executor may name it differently")
        return
    end
    S.Releases[#S.Releases + 1] = {at = os.clock() + (holdSeconds or 0.05), vk = vk}
end

function C.RightClick()
    if type(mouse2click) == "function" then
        pcall(mouse2click)
    elseif type(mouse2press) == "function" and type(mouse2release) == "function" then
        pcall(mouse2press)
        task.wait(0.03)
        pcall(mouse2release)
    end
end
