-- EletroCast Framework Server Main
EC = {}
EC.Players = {}
EC.Commands = {}
EC.ServerCallbacks = {}

-- Framework Initialization
CreateThread(function()
    ECUtils.Log('info', 'Initializing EletroCast Framework...')
    
    -- Initialize database
    ECDatabase.Initialize()
    
    -- Load framework data
    LoadFrameworkData()
    
    -- Start periodic tasks
    StartPeriodicTasks()
    
    ECUtils.Log('info', 'EletroCast Framework initialized successfully')
end)

-- Load Framework Data
function LoadFrameworkData()
    ECUtils.Log('info', 'Loading framework data...')
    
    -- Load jobs into memory (if needed for caching)
    -- Load items into memory (if needed for caching)
    -- Load vehicles into memory (if needed for caching)
    
    ECUtils.Log('info', 'Framework data loaded')
end

-- Start Periodic Tasks
function StartPeriodicTasks()
    -- Paycheck system
    if Config.PaycheckInterval > 0 then
        CreateThread(function()
            while true do
                Wait(Config.PaycheckInterval)
                TriggerEvent('ec:server:paycheck')
            end
        end)
    end
    
    -- Auto-save player data
    CreateThread(function()
        while true do
            Wait(300000) -- 5 minutes
            TriggerEvent('ec:server:autosave')
        end
    end)
    
    -- Cleanup tasks
    CreateThread(function()
        while true do
            Wait(3600000) -- 1 hour
            TriggerEvent('ec:server:cleanup')
        end
    end)
end

-- Player Connection Handling
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    
    deferrals.defer()
    deferrals.update('Loading EletroCast Framework...')
    
    Wait(100)
    
    -- Extract identifiers
    local identifier = nil
    local steam = nil
    local license = nil
    local discord = nil
    
    for _, id in pairs(identifiers) do
        if string.match(id, 'steam:') then
            steam = id
        elseif string.match(id, 'license:') then
            license = id
            identifier = id -- Use license as primary identifier
        elseif string.match(id, 'discord:') then
            discord = id
        end
    end
    
    if not identifier then
        deferrals.done('No valid identifier found. Please ensure you have a Rockstar Games Social Club account.')
        return
    end
    
    -- Check if player is banned
    ECDatabase.GetUser(identifier, function(userData)
        if userData and userData.banned == 1 then
            deferrals.done('You are banned from this server. Reason: ' .. (userData.ban_reason or 'No reason provided'))
            return
        end
        
        deferrals.done()
        
        -- Create or update user record
        if not userData then
            local newUserData = {
                identifier = identifier,
                steam = steam,
                license = license,
                discord = discord,
                group = 'user'
            }
            
            ECDatabase.CreateUser(newUserData, function(userId)
                if userId then
                    ECUtils.Log('info', 'New user created', {identifier = identifier, id = userId})
                end
            end)
        else
            -- Update last login
            ECDatabase.UpdateUser(identifier, {last_login = os.date('%Y-%m-%d %H:%M:%S')})
        end
    end)
end)

-- Player Dropped Handling
AddEventHandler('playerDropped', function(reason)
    local source = source
    local playerData = EC.Players[source]
    
    if playerData then
        ECUtils.Log('info', 'Player disconnected', {
            source = source,
            name = playerData.name or 'Unknown',
            reason = reason
        })
        
        -- Save player data before removing
        if playerData.character then
            ECDatabase.UpdateCharacter(playerData.character.id, {
                position = playerData.character.position,
                cash = playerData.character.cash,
                bank = playerData.character.bank,
                dirty_money = playerData.character.dirty_money
            })
        end
        
        -- Clean up player data
        EC.Players[source] = nil
        
        -- Trigger event for other resources
        TriggerEvent('ec:server:playerDropped', source, playerData)
    end
end)

-- Resource Stop Handling
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ECUtils.Log('info', 'Framework shutting down, saving all player data...')
        
        for source, playerData in pairs(EC.Players) do
            if playerData.character then
                ECDatabase.UpdateCharacter(playerData.character.id, {
                    position = playerData.character.position,
                    cash = playerData.character.cash,
                    bank = playerData.character.bank,
                    dirty_money = playerData.character.dirty_money
                })
            end
        end
        
        ECUtils.Log('info', 'All player data saved')
    end
end)

-- Player Management Functions
function EC.GetPlayer(source)
    return EC.Players[source]
end

function EC.GetPlayerByIdentifier(identifier)
    for source, playerData in pairs(EC.Players) do
        if playerData.identifier == identifier then
            return playerData
        end
    end
    return nil
end

function EC.GetPlayers()
    return EC.Players
end

function EC.GetPlayersCount()
    local count = 0
    for _ in pairs(EC.Players) do
        count = count + 1
    end
    return count
end

-- Command System
function EC.RegisterCommand(name, callback, restricted, help)
    if EC.Commands[name] then
        ECUtils.Log('warn', 'Command already exists', {command = name})
        return
    end
    
    EC.Commands[name] = {
        callback = callback,
        restricted = restricted or false,
        help = help or 'No help available'
    }
    
    RegisterCommand(name, function(source, args, rawCommand)
        local playerData = EC.GetPlayer(source)
        
        if restricted and not ECFunctions.HasPermission(source, restricted) then
            ECFunctions.Notify(source, 'You don\'t have permission to use this command', 'error')
            return
        end
        
        callback(source, args, rawCommand, playerData)
    end, restricted)
    
    ECUtils.Log('debug', 'Registered command', {name = name, restricted = restricted})
end

-- Event System
RegisterNetEvent('ec:server:requestPlayerData', function()
    local source = source
    local playerData = EC.GetPlayer(source)
    
    if playerData then
        TriggerClientEvent('ec:client:receivePlayerData', source, playerData)
    end
end)

-- Paycheck Event
RegisterNetEvent('ec:server:paycheck', function()
    for source, playerData in pairs(EC.Players) do
        if playerData.character and playerData.character.job then
            local job = Jobs[playerData.character.job.name]
            if job and job.grades[playerData.character.job.grade] then
                local payment = job.grades[playerData.character.job.grade].payment
                if payment > 0 then
                    ECDatabase.UpdateMoney(playerData.character.id, 'bank', payment, 'Paycheck - ' .. job.label, function(success, newBalance)
                        if success then
                            playerData.character.bank = newBalance
                            ECFunctions.Notify(source, 'Paycheck received: ' .. ECUtils.FormatMoney(payment), 'success')
                            TriggerClientEvent('ec:client:updatePlayerData', source, playerData)
                        end
                    end)
                end
            end
        end
    end
end)

-- Auto-save Event
RegisterNetEvent('ec:server:autosave', function()
    local saveCount = 0
    for source, playerData in pairs(EC.Players) do
        if playerData.character then
            ECDatabase.UpdateCharacter(playerData.character.id, {
                position = playerData.character.position,
                cash = playerData.character.cash,
                bank = playerData.character.bank,
                dirty_money = playerData.character.dirty_money
            })
            saveCount = saveCount + 1
        end
    end
    ECUtils.Log('debug', 'Auto-saved player data', {players = saveCount})
end)

-- Cleanup Event
RegisterNetEvent('ec:server:cleanup', function()
    -- Clean up old transactions
    ECDatabase.CleanupOldTransactions(30)
    
    -- Clean up dropped items (if implemented)
    TriggerEvent('ec:server:cleanupDroppedItems')
    
    ECUtils.Log('info', 'Performed server cleanup')
end)

-- Basic Commands
EC.RegisterCommand('players', function(source, args)
    local count = EC.GetPlayersCount()
    ECFunctions.Notify(source, 'Players online: ' .. count .. '/' .. GetConvarInt('sv_maxclients', 32), 'info')
end, false, 'Check online player count')

EC.RegisterCommand('coords', function(source, args)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local coordsText = string.format('vector4(%.2f, %.2f, %.2f, %.2f)', coords.x, coords.y, coords.z, heading)
    print(coordsText) -- Print to server console
    ECFunctions.Notify(source, 'Coordinates printed to server console', 'info')
end, false, 'Get current coordinates')

EC.RegisterCommand('car', function(source, args)
    if not args[1] then
        ECFunctions.Notify(source, 'Usage: /car [vehicle_model]', 'error')
        return
    end
    
    TriggerClientEvent('ec:client:spawnVehicle', source, args[1])
end, 'admin', 'Spawn a vehicle')

EC.RegisterCommand('tp', function(source, args)
    if not args[1] or not args[2] then
        ECFunctions.Notify(source, 'Usage: /tp [x] [y] [z]', 'error')
        return
    end
    
    local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]) or 0
    if x and y then
        TriggerClientEvent('ec:client:teleport', source, vector3(x, y, z))
    end
end, 'admin', 'Teleport to coordinates')

-- Export framework functions
exports('GetPlayer', EC.GetPlayer)
exports('GetPlayerByIdentifier', EC.GetPlayerByIdentifier)
exports('GetPlayers', EC.GetPlayers)
exports('GetPlayersCount', EC.GetPlayersCount)
exports('RegisterCommand', EC.RegisterCommand)