-- EletroCast Framework Client Player Management
ECPlayer = {}

-- Player State Management
ECPlayer.IsLoggedIn = false
ECPlayer.PlayerLoaded = false

-- Character Creation/Selection UI
function ECPlayer.ShowCharacterCreator()
    if not Config.UI.UseOxLib then
        -- Fallback character creation
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
    
    -- Enhanced character creator with more options
    SetNuiFocus(true, true)
    
    local input = lib.inputDialog('Create Your Character', {
        {
            type = 'input',
            label = 'First Name',
            description = 'Your character\'s first name',
            required = true,
            min = 2,
            max = 20,
            pattern = '^[a-zA-Z]+$'
        },
        {
            type = 'input',
            label = 'Last Name',
            description = 'Your character\'s last name',
            required = true,
            min = 2,
            max = 20,
            pattern = '^[a-zA-Z]+$'
        },
        {
            type = 'date',
            label = 'Date of Birth',
            description = 'When was your character born?',
            default = '1990-01-01',
            min = '1950-01-01',
            max = '2005-12-31',
            required = true
        },
        {
            type = 'select',
            label = 'Gender',
            description = 'Your character\'s gender',
            options = {
                {value = 'M', label = 'Male'},
                {value = 'F', label = 'Female'}
            },
            required = true
        },
        {
            type = 'number',
            label = 'Height (cm)',
            description = 'Your character\'s height in centimeters',
            min = 150,
            max = 200,
            default = 175
        }
    })
    
    if input then
        -- Validate input
        if not input[1] or not input[2] or not input[3] or not input[4] then
            ECFunctions.Notify('Please fill in all required fields', 'error')
            return ECPlayer.ShowCharacterCreator()
        end
        
        local charData = {
            firstname = input[1],
            lastname = input[2],
            dob = input[3],
            sex = input[4],
            height = input[5] or 175
        }
        
        -- Show preview before creating
        ECPlayer.PreviewCharacter(charData)
    else
        SetNuiFocus(false, false)
    end
end

function ECPlayer.PreviewCharacter(charData)
    -- Create preview ped
    local model = charData.sex == 'F' and `mp_f_freemode_01` or `mp_m_freemode_01`
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    -- Position for character preview
    local previewCoords = vector4(402.8, -996.4, -99.0, 180.0)
    
    local previewPed = CreatePed(4, model, previewCoords.x, previewCoords.y, previewCoords.z, previewCoords.w, false, true)
    FreezeEntityPosition(previewPed, true)
    SetEntityInvincible(previewPed, true)
    SetBlockingOfNonTemporaryEvents(previewPed, true)
    
    -- Camera setup
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, previewCoords.x, previewCoords.y - 2.0, previewCoords.z + 0.5)
    PointCamAtEntity(cam, previewPed, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
    
    -- Confirmation dialog
    local alert = lib.alertDialog({
        header = 'Character Preview',
        content = 'Are you happy with your character?\n\n' ..
                 'Name: ' .. charData.firstname .. ' ' .. charData.lastname .. '\n' ..
                 'Gender: ' .. (charData.sex == 'M' and 'Male' or 'Female') .. '\n' ..
                 'Height: ' .. charData.height .. 'cm',
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Create Character',
            cancel = 'Go Back'
        }
    })
    
    if alert == 'confirm' then
        -- Create the character
        TriggerServerEvent('ec:server:createCharacter', charData)
    else
        -- Go back to character creator
        ECPlayer.ShowCharacterCreator()
    end
    
    -- Cleanup
    SetCamActive(cam, false)
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
    DeleteEntity(previewPed)
    SetModelAsNoLongerNeeded(model)
end

function ECPlayer.ShowCharacterSelector(characters)
    if not Config.UI.UseOxLib then
        -- Simple fallback
        if characters[1] then
            TriggerServerEvent('ec:server:selectCharacter', characters[1].char_id)
        end
        return
    end
    
    local options = {}
    
    for _, character in pairs(characters) do
        local jobInfo = character.job or 'Unemployed'
        local money = ECUtils.FormatMoney(character.cash or 0)
        
        table.insert(options, {
            title = character.firstname .. ' ' .. character.lastname,
            description = 'Job: ' .. jobInfo .. ' | Cash: ' .. money,
            icon = 'user',
            metadata = {
                'Level: ' .. (character.level or 1),
                'Bank: ' .. ECUtils.FormatMoney(character.bank or 0),
                'Phone: ' .. (character.phone or 'None')
            },
            onSelect = function()
                TriggerServerEvent('ec:server:selectCharacter', character.char_id)
            end
        })
    end
    
    -- Add option to create new character
    if #characters < Config.MaxCharacters then
        table.insert(options, {
            title = 'Create New Character',
            description = 'Start fresh with a new character',
            icon = 'plus',
            onSelect = function()
                ECPlayer.ShowCharacterCreator()
            end
        })
    end
    
    -- Add delete character option (for existing characters)
    if #characters > 0 then
        table.insert(options, {
            title = 'Delete Character',
            description = 'Permanently delete a character',
            icon = 'trash',
            iconColor = 'red',
            onSelect = function()
                ECPlayer.ShowCharacterDeleter(characters)
            end
        })
    end
    
    lib.registerContext({
        id = 'character_selector',
        title = 'Select Character',
        options = options
    })
    
    lib.showContext('character_selector')
end

function ECPlayer.ShowCharacterDeleter(characters)
    local options = {}
    
    for _, character in pairs(characters) do
        table.insert(options, {
            title = character.firstname .. ' ' .. character.lastname,
            description = 'Job: ' .. (character.job or 'Unemployed'),
            icon = 'user-minus',
            iconColor = 'red',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Delete Character',
                    content = 'Are you sure you want to delete ' .. character.firstname .. ' ' .. character.lastname .. '?\n\nThis action cannot be undone!',
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = 'Delete',
                        cancel = 'Cancel'
                    }
                })
                
                if alert == 'confirm' then
                    TriggerServerEvent('ec:server:deleteCharacter', character.char_id)
                else
                    ECPlayer.ShowCharacterSelector(characters)
                end
            end
        })
    end
    
    table.insert(options, {
        title = 'Back',
        description = 'Return to character selection',
        icon = 'arrow-left',
        onSelect = function()
            ECPlayer.ShowCharacterSelector(characters)
        end
    })
    
    lib.registerContext({
        id = 'character_deleter',
        title = 'Delete Character',
        options = options
    })
    
    lib.showContext('character_deleter')
end

-- Spawning Functions
function ECPlayer.SpawnPlayer(coords, model)
    local playerPed = PlayerPedId()
    
    -- Set model if specified
    if model then
        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(0)
        end
        SetPlayerModel(PlayerId(), hash)
        SetModelAsNoLongerNeeded(hash)
        playerPed = PlayerPedId()
    end
    
    -- Spawn at coordinates
    if coords then
        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
        SetEntityHeading(playerPed, coords.w or 0.0)
    end
    
    -- Camera fade in
    if not IsScreenFadedIn() then
        DoScreenFadeIn(1000)
    end
    
    -- Set player state
    SetPlayerInvincible(PlayerId(), false)
    FreezeEntityPosition(playerPed, false)
    
    -- Wait for world to load
    while not HasCollisionLoadedAroundEntity(playerPed) do
        Wait(0)
    end
    
    -- Notify spawned
    ECPlayer.PlayerLoaded = true
    TriggerEvent('ec:client:playerSpawned')
    
    ECUtils.Log('info', 'Player spawned successfully')
end

-- Character Customization
function ECPlayer.OpenCharacterCustomization()
    if not Config.UI.UseOxLib then
        ECFunctions.Notify('Character customization not available', 'error')
        return
    end
    
    -- This would typically open a more complex character customization menu
    -- For now, we'll show a simple appearance menu
    
    local options = {
        {
            title = 'Change Hairstyle',
            description = 'Modify your character\'s hairstyle',
            icon = 'scissors',
            onSelect = function()
                ECPlayer.ChangeHairstyle()
            end
        },
        {
            title = 'Change Clothes',
            description = 'Modify your character\'s clothing',
            icon = 'shirt',
            onSelect = function()
                ECPlayer.ChangeClothing()
            end
        },
        {
            title = 'Facial Features',
            description = 'Adjust facial features',
            icon = 'face-smile',
            onSelect = function()
                ECPlayer.ChangeFacialFeatures()
            end
        }
    }
    
    lib.registerContext({
        id = 'character_customization',
        title = 'Character Customization',
        options = options
    })
    
    lib.showContext('character_customization')
end

function ECPlayer.ChangeHairstyle()
    local ped = PlayerPedId()
    local currentHair = GetPedDrawableVariation(ped, 2)  -- Hair component
    local maxHairs = GetNumberOfPedDrawableVariations(ped, 2)
    
    local input = lib.inputDialog('Change Hairstyle', {
        {
            type = 'slider',
            label = 'Hairstyle',
            min = 0,
            max = maxHairs - 1,
            default = currentHair
        },
        {
            type = 'slider',
            label = 'Hair Color',
            min = 0,
            max = 63,
            default = 0
        }
    })
    
    if input then
        SetPedComponentVariation(ped, 2, input[1], 0, 0)
        SetPedHairColor(ped, input[2], input[2])
        
        -- Save to server
        local skinData = ECPlayer.GetCurrentSkin()
        TriggerServerEvent('ec:server:saveSkin', skinData)
        
        ECFunctions.Notify('Hairstyle changed', 'success')
    end
end

function ECPlayer.ChangeClothing()
    local ped = PlayerPedId()
    
    local options = {}
    local components = {
        [1] = 'Mask',
        [3] = 'Arms',
        [4] = 'Legs',
        [5] = 'Bag',
        [6] = 'Shoes',
        [7] = 'Accessory',
        [8] = 'Undershirt',
        [9] = 'Body Armor',
        [10] = 'Decals',
        [11] = 'Torso'
    }
    
    for component, name in pairs(components) do
        table.insert(options, {
            title = name,
            description = 'Change ' .. name:lower(),
            onSelect = function()
                ECPlayer.ChangeComponent(component, name)
            end
        })
    end
    
    lib.registerContext({
        id = 'clothing_customization',
        title = 'Clothing Options',
        options = options
    })
    
    lib.showContext('clothing_customization')
end

function ECPlayer.ChangeComponent(component, name)
    local ped = PlayerPedId()
    local maxVariations = GetNumberOfPedDrawableVariations(ped, component)
    local currentDrawable = GetPedDrawableVariation(ped, component)
    local maxTextures = GetNumberOfPedTextureVariations(ped, component, currentDrawable)
    
    local input = lib.inputDialog('Change ' .. name, {
        {
            type = 'slider',
            label = 'Style',
            min = 0,
            max = math.max(0, maxVariations - 1),
            default = currentDrawable
        },
        {
            type = 'slider',
            label = 'Texture',
            min = 0,
            max = math.max(0, maxTextures - 1),
            default = GetPedTextureVariation(ped, component)
        }
    })
    
    if input then
        SetPedComponentVariation(ped, component, input[1], input[2], 0)
        
        -- Save to server
        local skinData = ECPlayer.GetCurrentSkin()
        TriggerServerEvent('ec:server:saveSkin', skinData)
        
        ECFunctions.Notify(name .. ' changed', 'success')
    end
end

function ECPlayer.GetCurrentSkin()
    local ped = PlayerPedId()
    local skinData = {
        components = {},
        props = {},
        faceFeatures = {},
        overlays = {}
    }
    
    -- Get all components
    for i = 0, 11 do
        skinData.components[tostring(i)] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i),
            palette = GetPedPaletteVariation(ped, i)
        }
    end
    
    -- Get all props
    for i = 0, 7 do
        skinData.props[tostring(i)] = {
            drawable = GetPedPropIndex(ped, i),
            texture = GetPedPropTextureIndex(ped, i)
        }
    end
    
    -- Get face features
    for i = 0, 19 do
        skinData.faceFeatures[tostring(i)] = GetPedFaceFeature(ped, i)
    end
    
    -- Get overlays
    for i = 0, 12 do
        skinData.overlays[tostring(i)] = {
            overlay = GetPedHeadOverlayValue(ped, i),
            opacity = GetPedHeadOverlayOpacity(ped, i),
            colourType = GetPedHeadOverlayColour(ped, i),
            firstColour = GetPedHeadOverlayColour(ped, i),
            secondColour = GetPedHeadOverlaySecondColour(ped, i)
        }
    end
    
    return skinData
end

-- Status Management
function ECPlayer.UpdateStatus(statusType, value)
    if not EC.PlayerData.character then return end
    
    -- Update local status
    if not EC.PlayerData.character.status then
        EC.PlayerData.character.status = {}
    end
    
    EC.PlayerData.character.status[statusType] = value
    
    -- Trigger status update event
    TriggerEvent('ec:client:statusUpdated', statusType, value)
    
    -- Send to server if needed
    TriggerServerEvent('ec:server:updateStatus', statusType, value)
end

function ECPlayer.GetStatus(statusType)
    if not EC.PlayerData.character or not EC.PlayerData.character.status then
        return 100 -- Default status
    end
    
    return EC.PlayerData.character.status[statusType] or 100
end

-- Death and Revival
function ECPlayer.OnPlayerDeath()
    if not EC.PlayerData.character then return end
    
    EC.PlayerData.character.is_dead = true
    TriggerServerEvent('ec:server:playerDied')
    TriggerEvent('ec:client:playerDied')
    
    ECFunctions.Notify('You have died! Wait for medical assistance or respawn', 'error', 10000)
    
    -- Disable controls while dead
    CreateThread(function()
        while EC.PlayerData.character and EC.PlayerData.character.is_dead do
            DisableAllControlActions(0)
            Wait(0)
        end
    end)
end

function ECPlayer.RevivePlayer()
    if not EC.PlayerData.character then return end
    
    local ped = PlayerPedId()
    
    -- Revive player
    ReviveInjuredPed(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    
    EC.PlayerData.character.is_dead = false
    TriggerServerEvent('ec:server:playerRevived')
    TriggerEvent('ec:client:playerRevived')
    
    ECFunctions.Notify('You have been revived!', 'success')
end

-- Network Events
RegisterNetEvent('ec:client:showCharacterCreation', ECPlayer.ShowCharacterCreator)
RegisterNetEvent('ec:client:showCharacterSelection', ECPlayer.ShowCharacterSelector)

RegisterNetEvent('ec:client:playerRevive', function()
    ECPlayer.RevivePlayer()
end)

RegisterNetEvent('ec:client:updateStatus', function(statusType, value)
    ECPlayer.UpdateStatus(statusType, value)
end)

-- Death detection
CreateThread(function()
    while true do
        Wait(1000)
        
        if EC.PlayerData.character and not EC.PlayerData.character.is_dead then
            local ped = PlayerPedId()
            if IsEntityDead(ped) then
                ECPlayer.OnPlayerDeath()
            end
        end
    end
end)

-- Export player functions
exports('ShowCharacterCreator', ECPlayer.ShowCharacterCreator)
exports('ShowCharacterSelector', ECPlayer.ShowCharacterSelector)
exports('OpenCharacterCustomization', ECPlayer.OpenCharacterCustomization)
exports('GetCurrentSkin', ECPlayer.GetCurrentSkin)
exports('RevivePlayer', ECPlayer.RevivePlayer)