-- No Fog: keeps Lighting.FogEnd huge and Atmosphere.Density at 0 via memory writes.
local C = ...
local Nexa, Controls, HttpService, Lighting = C.Nexa, C.Controls, C.HttpService, C.Lighting
local RunService = game:GetService("RunService")
local Log = C.Log

local FOG_TARGET = 1000000
local fogAddress = nil
local densityOffset = nil
local fogConnection = nil
local atmosphereConnection = nil

local function InitNoFogOffsets()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(C.cfg.OFFSETS_URL))
    end)
    if not ok or type(data) ~= "table" then
        error("Could not download or decode Offsets.json")
    end

    local currentOffsets = data.Offsets or data
    local lightingOffsets = currentOffsets.Lighting
    if type(lightingOffsets) ~= "table" then error("Lighting offsets missing") end

    local fogOffset = lightingOffsets.FogEnd
    if type(fogOffset) ~= "number" then error("FogEnd offset missing or not numeric") end

    local lightingAddress = Lighting.Address
    if type(lightingAddress) ~= "number" then error("Lighting.Address unavailable") end
    fogAddress = lightingAddress + fogOffset

    local atmosphereOffsets = currentOffsets.Atmosphere
    densityOffset = type(atmosphereOffsets) == "table" and atmosphereOffsets.Density
    if type(densityOffset) ~= "number" then
        densityOffset = 0xC0
        Log("Atmosphere.Density offset missing; using fallback 0xC0")
    end

    Log("Lighting address: " .. string.format("0x%X", lightingAddress))
    Log("Fog address: " .. string.format("0x%X", fogAddress))
    Log("Atmosphere density offset: " .. string.format("0x%X", densityOffset))
end

local function writeFog()
    if not fogAddress then return end
    local success, err = pcall(function()
        memory_write("float", fogAddress, FOG_TARGET)
    end)
    if not success then warn("[Deepwoken] No Fog write failed: " .. tostring(err)) end
end

local function fixAtmosphere(instance)
    local okClass, className = pcall(function() return instance.ClassName end)
    if not okClass or className ~= "Atmosphere" then return end

    local okAddress, address = pcall(function() return instance.Address end)
    if not okAddress or type(address) ~= "number" then return end

    local densityAddress = address + densityOffset
    pcall(function()
        local currentDensity = memory_read("float", densityAddress)
        if type(currentDensity) == "number" and currentDensity ~= 0 then
            memory_write("float", densityAddress, 0)
        end
    end)
end

local function writeAtmosphereDensity()
    local ok, descendants = pcall(function() return Lighting:GetDescendants() end)
    if not ok or not descendants then return end
    for _, instance in ipairs(descendants) do
        fixAtmosphere(instance)
    end
end

local function RestoreFogEnd()
    if fogConnection then pcall(function() fogConnection:Disconnect() end) fogConnection = nil end
    if atmosphereConnection then pcall(function() atmosphereConnection:Disconnect() end) atmosphereConnection = nil end
end

-- The implementation writes continuously and does not save originals; turning the toggle off
-- just stops the RenderStepped writers.
local function RestoreAtmosphere()
    RestoreFogEnd()
end

Nexa:OnDestroy(function()
    pcall(RestoreAtmosphere)
    pcall(RestoreFogEnd)
end)

task.spawn(function()
    local wasOn = false
    local cFog = Controls.no_fog
    while Nexa:IsAlive() do
        if cFog and cFog.Value then
            if not wasOn then
                wasOn = true
                local ok, err = pcall(InitNoFogOffsets)
                if not ok then
                    warn("[Deepwoken] No Fog error: " .. tostring(err))
                elseif type(memory_write) ~= "function" then
                    warn("[Deepwoken] No Fog error: memory_write is unavailable")
                elseif type(memory_read) ~= "function" then
                    warn("[Deepwoken] No Fog error: memory_read is unavailable")
                else
                    writeFog()
                    writeAtmosphereDensity()
                    fogConnection = RunService.RenderStepped:Connect(writeFog)
                    atmosphereConnection = RunService.RenderStepped:Connect(writeAtmosphereDensity)
                    Log("Fog loop and Atmosphere density suppression started")
                end
            end
            task.wait(0.1)
        else
            if wasOn then
                wasOn = false
                RestoreFogEnd()
            end
            task.wait(0.25)
        end
    end
    RestoreFogEnd()
end)
