-- EletroCast Framework Player Management (VRP-style)
ECPlayer = {}

-- Player Management Functions
function ECPlayer.LoadPlayer(source)
    local identifiers = GetPlayerIdentifiers(source)
    local identifier = nil
    
    -- Get primary identifier (license)
    for _, id in pairs(identifiers) do
        if string.match(id, 'license:') then
            identifier = id
            break
        end
    end
    
    if not identifier then
        ECUtils.Log('error', 'Player has no valid identifier', {source = source})
        return false
    end
    
    -- Get user data from database
    ECDatabase.GetUser(identifier, function(userData)
        if userData then
            -- Get user's characters
            ECDatabase.GetCharacters(userData.id, function(characters)
                local playerData = {
                    source = source,
                    identifier = identifier,
                    user_id = userData.id,
                    group = userData.group or 'user',
                    name = GetPlayerName(source),
                    characters = characters,
                    character = nil,
                    spawned = false
                }
                
                EC.Players[source] = playerData
                
                ECUtils.Log('info', 'Player loaded', {
                    source = source,
                    identifier = identifier,
                    characters = #characters
                })
                
                -- Trigger character selection
                if Config.UseMultiCharacter and #characters == 0 then
                    TriggerClientEvent('ec:client:showCharacterCreation', source)
                elseif Config.UseMultiCharacter then
                    TriggerClientEvent('ec:client:showCharacterSelection', source, characters)
                else
                    -- Single character mode - auto-select first character
                    if characters[1] then
                        ECPlayer.SelectCharacter(source, characters[1].char_id)
                    else
                        TriggerClientEvent('ec:client:showCharacterCreation', source)
                    end
                end
            end)
        else
            ECUtils.Log('error', 'User not found in database', {source = source, identifier = identifier})
            DropPlayer(source, 'User data not found')
        end
    end)
    
    return true
end

function ECPlayer.SelectCharacter(source, charId)
    local playerData = EC.Players[source]
    if not playerData then return false end
    
    ECDatabase.GetCharacter(playerData.user_id, charId, function(character)
        if character then
            -- Parse JSON data
            character.position = json.decode(character.position or '{"x": 195.17, "y": -933.77, "z": 29.7, "w": 144.5}')
            character.skin = json.decode(character.skin or '{}')
            
            -- Set character data
            playerData.character = {
                id = character.id,
                char_id = character.char_id,
                firstname = character.firstname,
                lastname = character.lastname,
                dob = character.dob,
                sex = character.sex,
                height = character.height,
                cash = character.cash,
                bank = character.bank,
                dirty_money = character.dirty_money,
                position = character.position,
                skin = character.skin,
                job = {
                    name = character.job,
                    grade = character.job_grade,
                    label = Jobs[character.job] and Jobs[character.job].label or 'Unknown',
                    payment = Jobs[character.job] and Jobs[character.job].grades[character.job_grade] and Jobs[character.job].grades[character.job_grade].payment or 0,
                    isboss = Jobs[character.job] and Jobs[character.job].grades[character.job_grade] and Jobs[character.job].grades[character.job_grade].isboss or false
                },
                phone = character.phone,
                is_dead = character.is_dead == 1,
                inventory = {},
                metadata = {}
            }
            
            -- Load inventory
            ECDatabase.GetInventory(character.id, function(inventory)
                playerData.character.inventory = inventory
                
                -- Update client with player data
                TriggerClientEvent('ec:client:characterSelected', source, playerData.character)
                TriggerClientEvent('ec:client:spawnPlayer', source, character.position)
                
                -- Trigger events for other resources
                TriggerEvent('ec:server:playerLoaded', source, playerData)
                
                ECUtils.Log('info', 'Character selected', {
                    source = source,
                    character = character.firstname .. ' ' .. character.lastname,
                    job = character.job
                })
            end)
        else
            ECUtils.Log('error', 'Character not found', {source = source, charId = charId})
            TriggerClientEvent('ec:client:showCharacterSelection', source, playerData.characters)
        end
    end)
end

function ECPlayer.CreateCharacter(source, charData)
    local playerData = EC.Players[source]
    if not playerData then return false end
    
    -- Validate character data
    if not charData.firstname or not charData.lastname or not charData.dob or not charData.sex then
        ECFunctions.Notify(source, 'Invalid character data provided', 'error')
        return false
    end
    
    -- Check character limit
    if #playerData.characters >= Config.MaxCharacters then
        ECFunctions.Notify(source, 'You have reached the maximum character limit', 'error')
        return false
    end
    
    -- Generate character ID
    local charId = 1
    for _, char in pairs(playerData.characters) do
        if char.char_id >= charId then
            charId = char.char_id + 1
        end
    end
    
    local characterData = {
        user_id = playerData.user_id,
        char_id = charId,
        firstname = ECUtils.Trim(charData.firstname),
        lastname = ECUtils.Trim(charData.lastname),
        dob = charData.dob,
        sex = charData.sex,
        height = charData.height or 175,
        position = charData.spawn or Config.DefaultSpawn
    }
    
    ECDatabase.CreateCharacter(characterData, function(characterId)
        if characterId then
            ECFunctions.Notify(source, 'Character created successfully', 'success')
            
            -- Reload characters and select new one
            ECDatabase.GetCharacters(playerData.user_id, function(characters)
                playerData.characters = characters
                ECPlayer.SelectCharacter(source, charId)
            end)
        else
            ECFunctions.Notify(source, 'Failed to create character', 'error')
        end
    end)
end

function ECPlayer.DeleteCharacter(source, charId)
    local playerData = EC.Players[source]
    if not playerData then return false end
    
    -- Find character
    local characterToDelete = nil
    for _, char in pairs(playerData.characters) do
        if char.char_id == charId then
            characterToDelete = char
            break
        end
    end
    
    if not characterToDelete then
        ECFunctions.Notify(source, 'Character not found', 'error')
        return false
    end
    
    ECDatabase.DeleteCharacter(characterToDelete.id, function(success)
        if success then
            ECFunctions.Notify(source, 'Character deleted successfully', 'success')
            
            -- Reload characters
            ECDatabase.GetCharacters(playerData.user_id, function(characters)
                playerData.characters = characters
                TriggerClientEvent('ec:client:showCharacterSelection', source, characters)
            end)
        else
            ECFunctions.Notify(source, 'Failed to delete character', 'error')
        end
    end)
end

function ECPlayer.SaveCharacter(source)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local character = playerData.character
    local updateData = {
        cash = character.cash,
        bank = character.bank,
        dirty_money = character.dirty_money,
        position = character.position,
        skin = character.skin,
        job = character.job.name,
        job_grade = character.job.grade,
        is_dead = character.is_dead and 1 or 0
    }
    
    ECDatabase.UpdateCharacter(character.id, updateData, function(success)
        if success then
            ECUtils.Log('debug', 'Character saved', {source = source, character = character.id})
        else
            ECUtils.Log('error', 'Failed to save character', {source = source, character = character.id})
        end
    end)
end

-- Position Management
function ECPlayer.UpdatePosition(source, coords)
    local playerData = EC.Players[source]
    if playerData and playerData.character then
        playerData.character.position = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            w = coords.w or 0.0
        }
    end
end

-- Money Management Functions
function ECPlayer.GetMoney(source, moneyType)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return 0 end
    
    moneyType = moneyType or 'cash'
    return playerData.character[moneyType] or 0
end

function ECPlayer.AddMoney(source, amount, moneyType, reason)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    moneyType = moneyType or 'cash'
    reason = reason or 'Unknown'
    
    if amount <= 0 then return false end
    
    ECDatabase.UpdateMoney(playerData.character.id, moneyType, amount, reason, function(success, newBalance)
        if success then
            playerData.character[moneyType] = newBalance
            TriggerClientEvent('ec:client:updatePlayerData', source, playerData.character)
            
            ECUtils.Log('info', 'Money added', {
                source = source,
                type = moneyType,
                amount = amount,
                reason = reason,
                newBalance = newBalance
            })
            
            return true
        end
        return false
    end)
end

function ECPlayer.RemoveMoney(source, amount, moneyType, reason)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    moneyType = moneyType or 'cash'
    reason = reason or 'Unknown'
    
    if amount <= 0 then return false end
    
    local currentMoney = playerData.character[moneyType] or 0
    if currentMoney < amount then return false end
    
    ECDatabase.UpdateMoney(playerData.character.id, moneyType, -amount, reason, function(success, newBalance)
        if success then
            playerData.character[moneyType] = newBalance
            TriggerClientEvent('ec:client:updatePlayerData', source, playerData.character)
            
            ECUtils.Log('info', 'Money removed', {
                source = source,
                type = moneyType,
                amount = amount,
                reason = reason,
                newBalance = newBalance
            })
            
            return true
        end
        return false
    end)
end

function ECPlayer.SetMoney(source, amount, moneyType, reason)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    moneyType = moneyType or 'cash'
    reason = reason or 'Set money'
    
    local currentMoney = playerData.character[moneyType] or 0
    local difference = amount - currentMoney
    
    ECDatabase.UpdateMoney(playerData.character.id, moneyType, difference, reason, function(success, newBalance)
        if success then
            playerData.character[moneyType] = newBalance
            TriggerClientEvent('ec:client:updatePlayerData', source, playerData.character)
            
            ECUtils.Log('info', 'Money set', {
                source = source,
                type = moneyType,
                amount = amount,
                reason = reason
            })
            
            return true
        end
        return false
    end)
end

-- Job Management Functions
function ECPlayer.SetJob(source, jobName, grade)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local job = Jobs[jobName]
    if not job or not job.grades[grade] then
        ECUtils.Log('error', 'Invalid job or grade', {job = jobName, grade = grade})
        return false
    end
    
    playerData.character.job = {
        name = jobName,
        grade = grade,
        label = job.label,
        payment = job.grades[grade].payment,
        isboss = job.grades[grade].isboss
    }
    
    -- Update database
    ECDatabase.UpdateCharacter(playerData.character.id, {
        job = jobName,
        job_grade = grade
    }, function(success)
        if success then
            TriggerClientEvent('ec:client:updatePlayerData', source, playerData.character)
            TriggerEvent('ec:server:jobUpdated', source, jobName, grade)
            
            ECFunctions.Notify(source, 'Job updated to ' .. job.label .. ' - ' .. job.grades[grade].name, 'success')
            
            ECUtils.Log('info', 'Job updated', {
                source = source,
                job = jobName,
                grade = grade
            })
        end
    end)
    
    return true
end

-- Network Events
RegisterNetEvent('ec:server:selectCharacter', function(charId)
    local source = source
    ECPlayer.SelectCharacter(source, charId)
end)

RegisterNetEvent('ec:server:createCharacter', function(charData)
    local source = source
    ECPlayer.CreateCharacter(source, charData)
end)

RegisterNetEvent('ec:server:deleteCharacter', function(charId)
    local source = source
    ECPlayer.DeleteCharacter(source, charId)
end)

RegisterNetEvent('ec:server:updatePosition', function(coords)
    local source = source
    ECPlayer.UpdatePosition(source, coords)
end)

RegisterNetEvent('ec:server:saveCharacter', function()
    local source = source
    ECPlayer.SaveCharacter(source)
end)

-- Player Spawned Event
AddEventHandler('playerSpawned', function()
    local source = source
    if not EC.Players[source] then
        ECPlayer.LoadPlayer(source)
    end
end)

-- Export player functions
exports('GetMoney', ECPlayer.GetMoney)
exports('AddMoney', ECPlayer.AddMoney)
exports('RemoveMoney', ECPlayer.RemoveMoney)
exports('SetMoney', ECPlayer.SetMoney)
exports('SetJob', ECPlayer.SetJob)
exports('SaveCharacter', ECPlayer.SaveCharacter)