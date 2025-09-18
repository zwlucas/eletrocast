-- EletroCast Framework Database Layer
ECDatabase = {}

-- Initialize database connection
function ECDatabase.Initialize()
    ECUtils.Log('info', 'Initializing database connection...')
    
    if Config.MySQL.UseOxMySQL then
        -- OxMySQL is already initialized by the resource dependency
        ECUtils.Log('info', 'Using OxMySQL for database operations')
        
        -- Test database connection
        MySQL.Async.fetchAll('SELECT 1 as test', {}, function(result)
            if result then
                ECUtils.Log('info', 'Database connection successful')
            else
                ECUtils.Log('error', 'Database connection failed')
            end
        end)
    else
        ECUtils.Log('error', 'OxMySQL is required for this framework')
    end
end

-- User Management Functions
function ECDatabase.GetUser(identifier, cb)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = ?', {identifier}, function(result)
        if result and result[1] then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end

function ECDatabase.CreateUser(userData, cb)
    local query = 'INSERT INTO users (identifier, steam, license, discord, `group`, created_at) VALUES (?, ?, ?, ?, ?, NOW())'
    local params = {
        userData.identifier,
        userData.steam,
        userData.license,
        userData.discord,
        userData.group or 'user'
    }
    
    MySQL.Async.insert(query, params, function(insertId)
        if insertId then
            ECUtils.Log('info', 'Created new user', {identifier = userData.identifier, id = insertId})
            cb(insertId)
        else
            ECUtils.Log('error', 'Failed to create user', userData)
            cb(nil)
        end
    end)
end

function ECDatabase.UpdateUser(identifier, updateData, cb)
    local setClause = {}
    local params = {}
    
    for key, value in pairs(updateData) do
        table.insert(setClause, key .. ' = ?')
        table.insert(params, value)
    end
    
    table.insert(params, identifier)
    local query = 'UPDATE users SET ' .. table.concat(setClause, ', ') .. ', last_login = NOW() WHERE identifier = ?'
    
    MySQL.Async.execute(query, params, function(affectedRows)
        if cb then cb(affectedRows > 0) end
    end)
end

-- Character Management Functions
function ECDatabase.GetCharacters(userId, cb)
    MySQL.Async.fetchAll('SELECT * FROM characters WHERE user_id = ? ORDER BY char_id', {userId}, function(result)
        cb(result or {})
    end)
end

function ECDatabase.GetCharacter(userId, charId, cb)
    MySQL.Async.fetchAll('SELECT * FROM characters WHERE user_id = ? AND char_id = ?', {userId, charId}, function(result)
        if result and result[1] then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end

function ECDatabase.CreateCharacter(characterData, cb)
    local query = [[
        INSERT INTO characters (user_id, char_id, firstname, lastname, dob, sex, height, cash, bank, dirty_money, position, skin, job, job_grade, phone, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ]]
    
    local params = {
        characterData.user_id,
        characterData.char_id,
        characterData.firstname,
        characterData.lastname,
        characterData.dob,
        characterData.sex or 'M',
        characterData.height or 175,
        characterData.cash or Config.StartingCash,
        characterData.bank or Config.StartingBank,
        characterData.dirty_money or 0,
        json.encode(characterData.position or {}),
        json.encode(characterData.skin or {}),
        characterData.job or 'unemployed',
        characterData.job_grade or 0,
        characterData.phone or nil
    }
    
    MySQL.Async.insert(query, params, function(insertId)
        if insertId then
            ECUtils.Log('info', 'Created new character', {id = insertId, name = characterData.firstname .. ' ' .. characterData.lastname})
            cb(insertId)
        else
            ECUtils.Log('error', 'Failed to create character', characterData)
            cb(nil)
        end
    end)
end

function ECDatabase.UpdateCharacter(characterId, updateData, cb)
    local setClause = {}
    local params = {}
    
    for key, value in pairs(updateData) do
        if key == 'position' or key == 'skin' then
            value = json.encode(value)
        end
        table.insert(setClause, key .. ' = ?')
        table.insert(params, value)
    end
    
    table.insert(params, characterId)
    local query = 'UPDATE characters SET ' .. table.concat(setClause, ', ') .. ', updated_at = NOW() WHERE id = ?'
    
    MySQL.Async.execute(query, params, function(affectedRows)
        if cb then cb(affectedRows > 0) end
    end)
end

function ECDatabase.DeleteCharacter(characterId, cb)
    MySQL.Async.execute('DELETE FROM characters WHERE id = ?', {characterId}, function(affectedRows)
        if cb then cb(affectedRows > 0) end
    end)
end

-- Money Transaction Functions
function ECDatabase.UpdateMoney(characterId, moneyType, amount, reason, cb)
    -- First get current balance
    MySQL.Async.fetchAll('SELECT cash, bank, dirty_money FROM characters WHERE id = ?', {characterId}, function(result)
        if result and result[1] then
            local currentBalance = result[1][moneyType] or 0
            local newBalance = currentBalance + amount
            
            -- Update character money
            local updateQuery = 'UPDATE characters SET ' .. moneyType .. ' = ? WHERE id = ?'
            MySQL.Async.execute(updateQuery, {newBalance, characterId}, function(affectedRows)
                if affectedRows > 0 then
                    -- Log transaction
                    local logQuery = 'INSERT INTO transactions (character_id, type, amount, reason, balance_before, balance_after, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())'
                    MySQL.Async.execute(logQuery, {characterId, moneyType, amount, reason, currentBalance, newBalance}, function()
                        if cb then cb(true, newBalance) end
                    end)
                else
                    if cb then cb(false, currentBalance) end
                end
            end)
        else
            if cb then cb(false, 0) end
        end
    end)
end

-- Inventory Functions
function ECDatabase.GetInventory(characterId, cb)
    MySQL.Async.fetchAll('SELECT * FROM character_inventory WHERE character_id = ? ORDER BY slot', {characterId}, function(result)
        local inventory = {}
        for _, item in pairs(result or {}) do
            inventory[item.slot] = {
                name = item.item,
                count = item.count,
                metadata = json.decode(item.metadata or '{}')
            }
        end
        cb(inventory)
    end)
end

function ECDatabase.SetInventoryItem(characterId, slot, itemData, cb)
    if not itemData or not itemData.name then
        -- Remove item from slot
        MySQL.Async.execute('DELETE FROM character_inventory WHERE character_id = ? AND slot = ?', {characterId, slot}, function(affectedRows)
            if cb then cb(affectedRows > 0) end
        end)
    else
        -- Insert or update item
        local query = [[
            INSERT INTO character_inventory (character_id, item, count, slot, metadata, created_at)
            VALUES (?, ?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE
            item = VALUES(item), count = VALUES(count), metadata = VALUES(metadata)
        ]]
        
        local params = {
            characterId,
            itemData.name,
            itemData.count or 1,
            slot,
            json.encode(itemData.metadata or {})
        }
        
        MySQL.Async.execute(query, params, function(affectedRows)
            if cb then cb(affectedRows > 0) end
        end)
    end
end

-- Vehicle Functions
function ECDatabase.GetPlayerVehicles(ownerId, cb)
    MySQL.Async.fetchAll('SELECT * FROM vehicles WHERE owner = ?', {ownerId}, function(result)
        cb(result or {})
    end)
end

function ECDatabase.CreateVehicle(vehicleData, cb)
    local query = 'INSERT INTO vehicles (owner, plate, model, mods, garage, fuel, engine, body, state, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())'
    local params = {
        vehicleData.owner,
        vehicleData.plate,
        vehicleData.model,
        json.encode(vehicleData.mods or {}),
        vehicleData.garage or 'pillboxgarage',
        vehicleData.fuel or 100,
        vehicleData.engine or 1000.0,
        vehicleData.body or 1000.0,
        vehicleData.state or 1
    }
    
    MySQL.Async.insert(query, params, function(insertId)
        if cb then cb(insertId) end
    end)
end

function ECDatabase.UpdateVehicle(vehicleId, updateData, cb)
    local setClause = {}
    local params = {}
    
    for key, value in pairs(updateData) do
        if key == 'mods' then
            value = json.encode(value)
        end
        table.insert(setClause, key .. ' = ?')
        table.insert(params, value)
    end
    
    table.insert(params, vehicleId)
    local query = 'UPDATE vehicles SET ' .. table.concat(setClause, ', ') .. ' WHERE id = ?'
    
    MySQL.Async.execute(query, params, function(affectedRows)
        if cb then cb(affectedRows > 0) end
    end)
end

-- Business Functions
function ECDatabase.GetBusinesses(cb)
    MySQL.Async.fetchAll('SELECT * FROM businesses', {}, function(result)
        cb(result or {})
    end)
end

function ECDatabase.GetPlayerBusinesses(ownerId, cb)
    MySQL.Async.fetchAll('SELECT * FROM businesses WHERE owner = ?', {ownerId}, function(result)
        cb(result or {})
    end)
end

function ECDatabase.UpdateBusiness(businessId, updateData, cb)
    local setClause = {}
    local params = {}
    
    for key, value in pairs(updateData) do
        if key == 'employees' or key == 'data' then
            value = json.encode(value)
        end
        table.insert(setClause, key .. ' = ?')
        table.insert(params, value)
    end
    
    table.insert(params, businessId)
    local query = 'UPDATE businesses SET ' .. table.concat(setClause, ', ') .. ' WHERE id = ?'
    
    MySQL.Async.execute(query, params, function(affectedRows)
        if cb then cb(affectedRows > 0) end
    end)
end

-- Stash Functions
function ECDatabase.GetStash(stashId, cb)
    MySQL.Async.fetchAll('SELECT * FROM stashes WHERE stash = ?', {stashId}, function(result)
        if result and result[1] then
            local items = json.decode(result[1].items or '{}')
            cb(items)
        else
            cb({})
        end
    end)
end

function ECDatabase.UpdateStash(stashId, items, cb)
    local query = [[
        INSERT INTO stashes (stash, items, created_at, updated_at)
        VALUES (?, ?, NOW(), NOW())
        ON DUPLICATE KEY UPDATE
        items = VALUES(items), updated_at = NOW()
    ]]
    
    MySQL.Async.execute(query, {stashId, json.encode(items)}, function(affectedRows)
        if cb then cb(affectedRows > 0) end
    end)
end

-- Cleanup Functions
function ECDatabase.CleanupOldTransactions(days, cb)
    days = days or 30
    local query = 'DELETE FROM transactions WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)'
    MySQL.Async.execute(query, {days}, function(affectedRows)
        ECUtils.Log('info', 'Cleaned up old transactions', {deleted = affectedRows})
        if cb then cb(affectedRows) end
    end)
end

-- Export database functions
exports('GetUser', ECDatabase.GetUser)
exports('CreateUser', ECDatabase.CreateUser)
exports('UpdateUser', ECDatabase.UpdateUser)
exports('GetCharacters', ECDatabase.GetCharacters)
exports('GetCharacter', ECDatabase.GetCharacter)
exports('CreateCharacter', ECDatabase.CreateCharacter)
exports('UpdateCharacter', ECDatabase.UpdateCharacter)
exports('UpdateMoney', ECDatabase.UpdateMoney)
exports('GetInventory', ECDatabase.GetInventory)
exports('SetInventoryItem', ECDatabase.SetInventoryItem)
exports('GetPlayerVehicles', ECDatabase.GetPlayerVehicles)
exports('CreateVehicle', ECDatabase.CreateVehicle)