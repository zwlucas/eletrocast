-- EletroCast Framework Client Main
EC = {}
EC.PlayerData = {}
EC.PlayerLoaded = false
EC.PlayerSpawned = false

-- Framework Initialization
CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(0)
    end
    
    ECUtils.Log('info', 'EletroCast Framework Client initializing...')
    
    -- Initialize UI systems
    if Config.UI.UseOxLib then
        ECUtils.Log('info', 'Using ox_lib for UI components')
    end
    
    -- Request player data from server
    TriggerServerEvent('ec:server:requestPlayerData')
    
    ECUtils.Log('info', 'EletroCast Framework Client initialized')
end)

-- Player Data Management
RegisterNetEvent('ec:client:receivePlayerData', function(playerData)
    EC.PlayerData = playerData
    EC.PlayerLoaded = true
    
    ECUtils.Log('info', 'Player data received', {
        identifier = playerData.identifier,
        hasCharacter = playerData.character ~= nil
    })
    
    TriggerEvent('ec:client:playerLoaded', playerData)
end)

RegisterNetEvent('ec:client:updatePlayerData', function(characterData)
    if EC.PlayerData then
        EC.PlayerData.character = characterData
        TriggerEvent('ec:client:playerDataUpdated', characterData)
    end
end)

-- Character Management
RegisterNetEvent('ec:client:showCharacterSelection', function(characters)
    ECUtils.Log('info', 'Showing character selection', {count = #characters})
    
    if not Config.UI.UseOxLib then
        -- Fallback to simple selection
        TriggerServerEvent('ec:server:selectCharacter', characters[1] and characters[1].char_id or 1)
        return
    end
    
    local options = {}
    
    for _, character in pairs(characters) do
        table.insert(options, {
            title = character.firstname .. ' ' .. character.lastname,
            description = 'Job: ' .. (character.job or 'Unemployed') .. ' | Cash: ' .. ECUtils.FormatMoney(character.cash or 0),
            icon = 'user',
            onSelect = function()
                TriggerServerEvent('ec:server:selectCharacter', character.char_id)
            end
        })
    end
    
    -- Add create new character option
    if #characters < Config.MaxCharacters then
        table.insert(options, {
            title = 'Create New Character',
            description = 'Create a new character',
            icon = 'plus',
            onSelect = function()
                TriggerEvent('ec:client:showCharacterCreation')
            end
        })
    end
    
    lib.registerContext({
        id = 'character_selection',
        title = 'Character Selection',
        options = options
    })
    
    lib.showContext('character_selection')
end)

RegisterNetEvent('ec:client:showCharacterCreation', function()
    ECUtils.Log('info', 'Showing character creation')
    
    if not Config.UI.UseOxLib then
        -- Simple character creation for testing
        local charData = {
            firstname = 'John',
            lastname = 'Doe',
            dob = '1990-01-01',
            sex = 'M',
            height = 180
        }
        TriggerServerEvent('ec:server:createCharacter', charData)
        return
    end
    
    local input = lib.inputDialog('Character Creation', {
        {type = 'input', label = 'First Name', placeholder = 'Enter first name', required = true, min = 2, max = 20},
        {type = 'input', label = 'Last Name', placeholder = 'Enter last name', required = true, min = 2, max = 20},
        {type = 'date', label = 'Date of Birth', default = '1990-01-01', required = true},
        {type = 'select', label = 'Gender', options = {
            {value = 'M', label = 'Male'},
            {value = 'F', label = 'Female'}
        }, required = true},
        {type = 'number', label = 'Height (cm)', placeholder = '180', min = 150, max = 200, default = 180}
    })
    
    if input then
        local charData = {
            firstname = input[1],
            lastname = input[2],
            dob = input[3],
            sex = input[4],
            height = input[5] or 180
        }
        
        TriggerServerEvent('ec:server:createCharacter', charData)
    end
end)

RegisterNetEvent('ec:client:characterSelected', function(character)
    EC.PlayerData.character = character
    EC.PlayerLoaded = true
    
    ECUtils.Log('info', 'Character selected', {
        name = character.firstname .. ' ' .. character.lastname,
        job = character.job.name
    })
    
    TriggerEvent('ec:client:characterLoaded', character)
end)

-- Player Spawning
RegisterNetEvent('ec:client:spawnPlayer', function(coords)
    local model = `mp_m_freemode_01`
    if EC.PlayerData.character and EC.PlayerData.character.sex == 'F' then
        model = `mp_f_freemode_01`
    end
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    
    -- Set spawn coordinates
    local spawnCoords = coords or Config.DefaultSpawn
    SetEntityCoordsNoOffset(PlayerPedId(), spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)
    SetEntityHeading(PlayerPedId(), spawnCoords.w or 0.0)
    
    -- Apply character customization
    if EC.PlayerData.character and EC.PlayerData.character.skin then
        ApplyCharacterSkin(EC.PlayerData.character.skin)
    end
    
    -- Freeze player temporarily
    FreezeEntityPosition(PlayerPedId(), true)
    
    -- Wait for world to load
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        Wait(0)
    end
    
    -- Unfreeze player
    FreezeEntityPosition(PlayerPedId(), false)
    
    -- Set player as spawned
    EC.PlayerSpawned = true
    TriggerEvent('ec:client:playerSpawned', EC.PlayerData.character)
    
    -- Start position tracking
    StartPositionTracking()
    
    ECUtils.Log('info', 'Player spawned', {coords = spawnCoords})
end)

-- Character Customization
function ApplyCharacterSkin(skinData)
    if not skinData or not next(skinData) then return end
    
    local ped = PlayerPedId()
    
    -- Apply basic appearance
    for component, data in pairs(skinData.components or {}) do
        SetPedComponentVariation(ped, tonumber(component), data.drawable, data.texture, data.palette or 0)
    end
    
    -- Apply props
    for prop, data in pairs(skinData.props or {}) do
        if data.drawable == -1 then
            ClearPedProp(ped, tonumber(prop))
        else
            SetPedPropIndex(ped, tonumber(prop), data.drawable, data.texture, true)
        end
    end
    
    -- Apply face features
    for i = 0, 19 do
        local value = skinData.faceFeatures and skinData.faceFeatures[tostring(i)] or 0.0
        SetPedFaceFeature(ped, i, value)
    end
    
    -- Apply overlays
    for i = 0, 12 do
        local overlay = skinData.overlays and skinData.overlays[tostring(i)]
        if overlay then
            SetPedHeadOverlay(ped, i, overlay.overlay, overlay.opacity)
            SetPedHeadOverlayColor(ped, i, overlay.colourType, overlay.firstColour, overlay.secondColour)
        end
    end
end

-- Position Tracking
function StartPositionTracking()
    CreateThread(function()
        while EC.PlayerSpawned do
            Wait(30000) -- Update every 30 seconds
            
            if EC.PlayerData.character then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                
                local position = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    w = heading
                }
                
                TriggerServerEvent('ec:server:updatePosition', position)
            end
        end
    end)
end

-- Vehicle Spawning
RegisterNetEvent('ec:client:spawnVehicle', function(model)
    local hash = GetHashKey(model)
    
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        ECFunctions.Notify('Invalid vehicle model', 'error')
        return
    end
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local vehicle = CreateVehicle(hash, coords.x + 2, coords.y + 2, coords.z, heading, true, false)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(hash)
    
    ECFunctions.Notify('Vehicle spawned: ' .. model, 'success')
end)

-- Teleportation
RegisterNetEvent('ec:client:teleport', function(coords)
    local ped = PlayerPedId()
    
    -- Fade out
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    
    -- Teleport
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    
    -- Wait for collision
    while not HasCollisionLoadedAroundEntity(ped) do
        Wait(0)
    end
    
    -- Fade in
    DoScreenFadeIn(500)
    
    ECFunctions.Notify('Teleported to ' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z, 'success')
end)

-- Health and Healing
RegisterNetEvent('ec:client:heal', function(amount)
    local ped = PlayerPedId()
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    local newHealth = math.min(currentHealth + amount, maxHealth)
    
    SetEntityHealth(ped, newHealth)
    ECFunctions.Notify('Health restored: +' .. amount, 'success')
end)

-- Vehicle Repair
RegisterNetEvent('ec:client:repairVehicle', function(repairType)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        ECFunctions.Notify('You must be in a vehicle', 'error')
        return
    end
    
    if repairType == 'basic' then
        -- Basic repair - engine and body
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        ECFunctions.Notify('Vehicle engine and body repaired', 'success')
    elseif repairType == 'advanced' then
        -- Advanced repair - everything
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0.0)
        ECFunctions.Notify('Vehicle fully repaired and cleaned', 'success')
    end
end)

-- Inventory Events
RegisterNetEvent('ec:client:updateInventory', function(inventory)
    if EC.PlayerData.character then
        EC.PlayerData.character.inventory = inventory
        TriggerEvent('ec:client:inventoryUpdated', inventory)
    end
end)

RegisterNetEvent('ec:client:consumeItem', function(itemData)
    -- Play consumption animation/effects
    local ped = PlayerPedId()
    
    if itemData.type == 'food' then
        -- Food consumption effects
        lib.progressBar({
            duration = 3000,
            label = 'Eating ' .. itemData.label,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true
            },
            anim = {
                dict = 'mp_player_inteat@burger',
                clip = 'mp_player_int_eat_burger'
            }
        })
    elseif itemData.type == 'drink' then
        -- Drink consumption effects
        lib.progressBar({
            duration = 2000,
            label = 'Drinking ' .. itemData.label,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true
            },
            anim = {
                dict = 'mp_player_intdrink',
                clip = 'loop_bottle'
            }
        })
    end
end)

-- UI Events
RegisterNetEvent('ec:client:openPhone', function()
    -- This would trigger a phone resource
    ECFunctions.Notify('Opening phone...', 'info')
end)

-- Job Events
RegisterNetEvent('ec:client:jobUpdated', function(jobData)
    if EC.PlayerData.character then
        EC.PlayerData.character.job = jobData
        TriggerEvent('ec:client:onJobUpdate', jobData)
    end
end)

RegisterNetEvent('ec:client:dutyChanged', function(onDuty)
    TriggerEvent('ec:client:onDutyChange', onDuty)
    
    local dutyText = onDuty and 'ON' or 'OFF'
    ECFunctions.Notify('Duty status: ' .. dutyText, 'info')
end)

-- Cleanup on disconnect
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Save character before disconnect
        if EC.PlayerData.character then
            TriggerServerEvent('ec:server:saveCharacter')
        end
    end
end)

-- Key Mappings (examples)
RegisterKeyMapping('ec:inventory', 'Open Inventory', 'keyboard', 'TAB')
RegisterKeyMapping('ec:phone', 'Open Phone', 'keyboard', 'F1')
RegisterKeyMapping('ec:job', 'Job Menu', 'keyboard', 'F6')

-- Command Handlers
RegisterCommand('ec:inventory', function()
    if EC.PlayerLoaded and EC.PlayerData.character then
        -- This would open inventory UI
        ECFunctions.Notify('Opening inventory...', 'info')
    end
end)

RegisterCommand('ec:phone', function()
    if EC.PlayerLoaded and EC.PlayerData.character then
        TriggerEvent('ec:client:openPhone')
    end
end)

RegisterCommand('ec:job', function()
    if EC.PlayerLoaded and EC.PlayerData.character then
        TriggerServerEvent('ec:server:requestBossMenu')
    end
end)

-- Export client functions
exports('GetPlayerData', function() return EC.PlayerData end)
exports('IsPlayerLoaded', function() return EC.PlayerLoaded end)
exports('IsPlayerSpawned', function() return EC.PlayerSpawned end)