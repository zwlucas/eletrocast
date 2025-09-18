-- EletroCast Framework Shared Functions
ECFunctions = {}

-- Framework Core Functions
function ECFunctions.GetFrameworkObject()
    if IsDuplicityVersion() then
        return EC -- Server-side framework object
    else
        return EC -- Client-side framework object
    end
end

-- Player Functions (used by both server and client)
function ECFunctions.GetPlayerData(source)
    if IsDuplicityVersion() then
        -- Server-side: get player data by source
        return EC.Players[source] or nil
    else
        -- Client-side: get local player data
        return EC.PlayerData or nil
    end
end

function ECFunctions.GetJob(source)
    local playerData = ECFunctions.GetPlayerData(source)
    if playerData and playerData.job then
        return playerData.job
    end
    return {name = 'unemployed', label = 'Unemployed', grade = 0}
end

function ECFunctions.HasJob(source, jobName)
    local job = ECFunctions.GetJob(source)
    return job.name == jobName
end

function ECFunctions.GetJobGrade(source)
    local job = ECFunctions.GetJob(source)
    return job.grade or 0
end

function ECFunctions.IsJobBoss(source)
    local playerData = ECFunctions.GetPlayerData(source)
    if not playerData or not playerData.job then return false end
    
    local job = Jobs[playerData.job.name]
    if not job or not job.grades[playerData.job.grade] then return false end
    
    return job.grades[playerData.job.grade].isboss or false
end

-- Money Functions
function ECFunctions.GetMoney(source, moneyType)
    local playerData = ECFunctions.GetPlayerData(source)
    if not playerData then return 0 end
    
    moneyType = moneyType or 'cash'
    return playerData.money[moneyType] or 0
end

function ECFunctions.HasMoney(source, amount, moneyType)
    local currentMoney = ECFunctions.GetMoney(source, moneyType)
    return currentMoney >= amount
end

-- Item Functions
function ECFunctions.GetItemData(itemName)
    return Items[itemName] or nil
end

function ECFunctions.GetItemLabel(itemName)
    local item = ECFunctions.GetItemData(itemName)
    return item and item.label or itemName
end

function ECFunctions.GetItemWeight(itemName)
    local item = ECFunctions.GetItemData(itemName)
    return item and item.weight or 0
end

function ECFunctions.IsItemUseable(itemName)
    local item = ECFunctions.GetItemData(itemName)
    return item and item.useable or false
end

-- Vehicle Functions
function ECFunctions.GetVehicleData(model)
    return Vehicles[model] or nil
end

function ECFunctions.GetVehicleLabel(model)
    local vehicle = ECFunctions.GetVehicleData(model)
    return vehicle and vehicle.name or model
end

function ECFunctions.GetVehiclePrice(model)
    local vehicle = ECFunctions.GetVehicleData(model)
    return vehicle and vehicle.price or 0
end

function ECFunctions.IsVehicleOwned(source, plate)
    if not IsDuplicityVersion() then return false end
    
    -- This would typically query the database
    -- For now, return false as placeholder
    return false
end

-- Zone Functions
function ECFunctions.IsPlayerInZone(coords, zoneName)
    local zone = Config.Zones[zoneName]
    if not zone then return false end
    
    local distance = ECUtils.GetDistance(coords, zone.coords)
    return distance <= zone.radius
end

function ECFunctions.GetClosestZone(coords)
    local closestZone = nil
    local closestDistance = math.huge
    
    for zoneName, zone in pairs(Config.Zones) do
        local distance = ECUtils.GetDistance(coords, zone.coords)
        if distance < closestDistance then
            closestDistance = distance
            closestZone = {name = zoneName, data = zone, distance = distance}
        end
    end
    
    return closestZone
end

-- Notification Functions (using ox_lib)
function ECFunctions.Notify(source, message, type, duration)
    if not Config.UI.UseOxLib then return end
    
    type = type or 'info'
    duration = duration or 5000
    
    if IsDuplicityVersion() then
        -- Server-side notification
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'EletroCast Framework',
            description = message,
            type = type,
            duration = duration,
            position = Config.UI.NotificationPosition
        })
    else
        -- Client-side notification
        lib.notify({
            title = 'EletroCast Framework',
            description = message,
            type = type,
            duration = duration,
            position = Config.UI.NotificationPosition
        })
    end
end

-- Progress Bar Functions (using ox_lib)
function ECFunctions.ProgressBar(data)
    if not Config.UI.UseOxLib or IsDuplicityVersion() then return end
    
    return lib.progressBar({
        duration = data.duration or 5000,
        label = data.label or 'Processing...',
        useWhileDead = data.useWhileDead or false,
        canCancel = data.canCancel or true,
        disable = data.disable or {
            car = true,
        },
        anim = data.anim or {},
        prop = data.prop or {}
    })
end

-- Menu Functions (using ox_lib)
function ECFunctions.ShowMenu(data)
    if not Config.UI.UseOxLib or IsDuplicityVersion() then return end
    
    return lib.showContext(data.id or 'ec_menu', data.options or {})
end

-- Input Functions (using ox_lib)
function ECFunctions.InputDialog(data)
    if not Config.UI.UseOxLib or IsDuplicityVersion() then return end
    
    return lib.inputDialog(data.header or 'Input', data.inputs or {})
end

-- Alert Functions (using ox_lib)
function ECFunctions.AlertDialog(data)
    if not Config.UI.UseOxLib or IsDuplicityVersion() then return end
    
    return lib.alertDialog({
        header = data.header or 'Alert',
        content = data.content or 'Alert message',
        centered = data.centered or true,
        cancel = data.cancel or false
    })
end

-- Permission Functions
function ECFunctions.HasPermission(source, permission)
    local playerData = ECFunctions.GetPlayerData(source)
    if not playerData then return false end
    
    local userGroup = playerData.group or 'user'
    return ECUtils.HasPermission(userGroup, permission)
end

function ECFunctions.IsAdmin(source)
    return ECFunctions.HasPermission(source, 'admin')
end

function ECFunctions.IsModerator(source)
    return ECFunctions.HasPermission(source, 'mod')
end

-- Callback System (simplified version)
ECFunctions.Callbacks = {}
ECFunctions.CallbackRequestId = 0

function ECFunctions.CreateCallback(name, cb)
    ECFunctions.Callbacks[name] = cb
end

function ECFunctions.TriggerCallback(name, cb, ...)
    if not IsDuplicityVersion() then
        -- Client-side: trigger server callback
        ECFunctions.CallbackRequestId = ECFunctions.CallbackRequestId + 1
        local requestId = ECFunctions.CallbackRequestId
        
        RegisterNetEvent('ec:callback:response:' .. requestId, function(...)
            cb(...)
            RemoveNetEvent('ec:callback:response:' .. requestId)
        end)
        
        TriggerServerEvent('ec:callback:request', name, requestId, ...)
    end
end

if IsDuplicityVersion() then
    -- Server-side callback handling
    RegisterNetEvent('ec:callback:request', function(name, requestId, ...)
        local source = source
        local callback = ECFunctions.Callbacks[name]
        
        if callback then
            callback(source, function(...)
                TriggerClientEvent('ec:callback:response:' .. requestId, source, ...)
            end, ...)
        end
    end)
end

-- Utility Functions for Common Operations
function ECFunctions.GenerateCharacterId()
    -- Generate a unique character ID (simplified)
    return ECUtils.RandomInt(10000, 99999)
end

function ECFunctions.GeneratePlate()
    local numbers = ECUtils.RandomInt(100, 999)
    local letters = ""
    for i = 1, 3 do
        letters = letters .. string.char(ECUtils.RandomInt(65, 90)) -- A-Z
    end
    return numbers .. letters
end

function ECFunctions.FormatPlayerName(firstname, lastname)
    if not firstname or not lastname then return "Unknown" end
    return ECUtils.Trim(firstname) .. " " .. ECUtils.Trim(lastname)
end

-- Framework Events
function ECFunctions.TriggerEvent(eventName, ...)
    if IsDuplicityVersion() then
        TriggerEvent(eventName, ...)
    else
        TriggerEvent(eventName, ...)
    end
end

function ECFunctions.TriggerClientEvent(eventName, source, ...)
    if IsDuplicityVersion() then
        TriggerClientEvent(eventName, source, ...)
    end
end

function ECFunctions.TriggerServerEvent(eventName, ...)
    if not IsDuplicityVersion() then
        TriggerServerEvent(eventName, ...)
    end
end

-- Export functions for use in other resources
if IsDuplicityVersion() then
    -- Server exports
    exports('GetPlayerData', ECFunctions.GetPlayerData)
    exports('GetJob', ECFunctions.GetJob)
    exports('HasJob', ECFunctions.HasJob)
    exports('GetMoney', ECFunctions.GetMoney)
    exports('HasMoney', ECFunctions.HasMoney)
    exports('Notify', ECFunctions.Notify)
    exports('HasPermission', ECFunctions.HasPermission)
    exports('CreateCallback', ECFunctions.CreateCallback)
    exports('TriggerCallback', ECFunctions.TriggerCallback)
else
    -- Client exports
    exports('GetPlayerData', ECFunctions.GetPlayerData)
    exports('GetJob', ECFunctions.GetJob)
    exports('Notify', ECFunctions.Notify)
    exports('ProgressBar', ECFunctions.ProgressBar)
    exports('ShowMenu', ECFunctions.ShowMenu)
    exports('InputDialog', ECFunctions.InputDialog)
    exports('AlertDialog', ECFunctions.AlertDialog)
    exports('TriggerCallback', ECFunctions.TriggerCallback)
end