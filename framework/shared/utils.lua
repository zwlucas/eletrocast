-- EletroCast Framework Shared Utilities
ECUtils = {}

-- Math Utilities
function ECUtils.Round(value, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10^numDecimalPlaces
        return math.floor((value * power) + 0.5) / power
    else
        return math.floor(value + 0.5)
    end
end

function ECUtils.RandomFloat(lower, greater)
    return lower + math.random() * (greater - lower)
end

function ECUtils.RandomInt(min, max)
    return math.random(min, max)
end

-- String Utilities
function ECUtils.Trim(s)
    if not s then return nil end
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function ECUtils.StartsWith(str, start)
    return str:sub(1, #start) == start
end

function ECUtils.EndsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function ECUtils.Split(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from-1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
end

function ECUtils.FormatMoney(amount)
    local formatted = amount
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return '$' .. formatted
end

-- Table Utilities
function ECUtils.TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function ECUtils.TableCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ECUtils.TableCopy(orig_key)] = ECUtils.TableCopy(orig_value)
        end
        setmetatable(copy, ECUtils.TableCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function ECUtils.TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function ECUtils.TableMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                ECUtils.TableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

-- Distance and Coordinate Utilities
function ECUtils.GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    local dz = pos1.z - pos2.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function ECUtils.GetDistance2D(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

-- Time Utilities
function ECUtils.GetCurrentTime()
    return os.time()
end

function ECUtils.FormatTime(seconds)
    if seconds <= 0 then
        return "00:00:00"
    else
        local hours = string.format("%02.f", math.floor(seconds/3600))
        local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
        local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins*60))
        return hours..":"..mins..":"..secs
    end
end

-- Validation Utilities
function ECUtils.IsValidEmail(email)
    if not email then return false end
    local pattern = "^[%w%._%+%-]+@[%w%._%+%-]+%.%w+$"
    return string.match(email, pattern) ~= nil
end

function ECUtils.IsValidPhone(phone)
    if not phone then return false end
    local pattern = "^%d%d%d%-%d%d%d%-%d%d%d%d$"
    return string.match(phone, pattern) ~= nil
end

function ECUtils.IsValidPlate(plate)
    if not plate then return false end
    return string.len(plate) >= 2 and string.len(plate) <= 8
end

-- Logging Utilities
function ECUtils.Log(level, message, data)
    if not Config.Logging.Enable then return end
    
    local logLevels = {debug = 1, info = 2, warn = 3, error = 4}
    local currentLevel = logLevels[Config.Logging.LogLevel] or 2
    local messageLevel = logLevels[level] or 2
    
    if messageLevel >= currentLevel then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local logMessage = string.format("[%s] [%s] %s", timestamp, string.upper(level), message)
        
        if data then
            logMessage = logMessage .. " | Data: " .. json.encode(data)
        end
        
        if Config.Logging.LogToConsole then
            print(logMessage)
        end
        
        if Config.Logging.LogToFile then
            -- In a real implementation, you would write to a file here
            -- For now, we'll just print with a file prefix
            print("[FILE] " .. logMessage)
        end
    end
end

-- UUID Generation (simple version)
function ECUtils.GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local uuid = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
    return uuid
end

-- Color Utilities
ECUtils.Colors = {
    Red = "^1",
    Green = "^2",
    Yellow = "^3",
    Blue = "^4",
    Cyan = "^5",
    Pink = "^6",
    White = "^7",
    Grey = "^8",
    Reset = "^7"
}

function ECUtils.ColorText(text, color)
    return (ECUtils.Colors[color] or ECUtils.Colors.White) .. text .. ECUtils.Colors.Reset
end

-- Permission Utilities
function ECUtils.GetPermissionLevel(group)
    if not group or not Config.Groups[group] then
        return 0
    end
    return Config.Groups[group].level or 0
end

function ECUtils.HasPermission(userGroup, requiredGroup)
    local userLevel = ECUtils.GetPermissionLevel(userGroup)
    local requiredLevel = ECUtils.GetPermissionLevel(requiredGroup)
    return userLevel >= requiredLevel
end

-- Export utilities for server/client use
if IsDuplicityVersion() then
    -- Server-side exports
    exports('Round', ECUtils.Round)
    exports('FormatMoney', ECUtils.FormatMoney)
    exports('GetDistance', ECUtils.GetDistance)
    exports('Log', ECUtils.Log)
else
    -- Client-side exports
    exports('Round', ECUtils.Round)
    exports('FormatMoney', ECUtils.FormatMoney)
    exports('GetDistance', ECUtils.GetDistance)
end