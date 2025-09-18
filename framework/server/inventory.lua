-- EletroCast Framework Inventory System
ECInventory = {}

-- Inventory Management
function ECInventory.GetInventory(source)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return {} end
    
    return playerData.character.inventory or {}
end

function ECInventory.GetInventoryWeight(source)
    local inventory = ECInventory.GetInventory(source)
    local weight = 0
    
    for slot, item in pairs(inventory) do
        if item and item.name and Items[item.name] then
            weight = weight + (Items[item.name].weight * item.count)
        end
    end
    
    return weight
end

function ECInventory.GetEmptySlot(source)
    local inventory = ECInventory.GetInventory(source)
    
    for slot = 1, Config.MaxInventorySlots do
        if not inventory[slot] then
            return slot
        end
    end
    
    return nil
end

function ECInventory.GetItemCount(source, itemName)
    local inventory = ECInventory.GetInventory(source)
    local count = 0
    
    for slot, item in pairs(inventory) do
        if item and item.name == itemName then
            count = count + item.count
        end
    end
    
    return count
end

function ECInventory.HasItem(source, itemName, amount)
    amount = amount or 1
    return ECInventory.GetItemCount(source, itemName) >= amount
end

function ECInventory.AddItem(source, itemName, count, metadata, slot)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local item = Items[itemName]
    if not item then
        ECUtils.Log('error', 'Item not found', {item = itemName})
        return false
    end
    
    count = count or 1
    metadata = metadata or {}
    
    -- Check weight limit
    local currentWeight = ECInventory.GetInventoryWeight(source)
    local itemWeight = item.weight * count
    
    if currentWeight + itemWeight > Config.MaxInventoryWeight then
        ECFunctions.Notify(source, 'Not enough space in inventory', 'error')
        return false
    end
    
    local inventory = playerData.character.inventory
    
    -- If no slot specified, try to stack or find empty slot
    if not slot then
        -- Try to stack with existing items (if not unique)
        if not item.unique then
            for existingSlot, existingItem in pairs(inventory) do
                if existingItem.name == itemName then
                    existingItem.count = existingItem.count + count
                    existingItem.metadata = ECUtils.TableMerge(existingItem.metadata, metadata)
                    
                    -- Update database
                    ECDatabase.SetInventoryItem(playerData.character.id, existingSlot, existingItem, function(success)
                        if success then
                            TriggerClientEvent('ec:client:updateInventory', source, inventory)
                            ECFunctions.Notify(source, 'Added ' .. count .. 'x ' .. item.label, 'success')
                        end
                    end)
                    
                    return true
                end
            end
        end
        
        -- Find empty slot
        slot = ECInventory.GetEmptySlot(source)
        if not slot then
            ECFunctions.Notify(source, 'Inventory is full', 'error')
            return false
        end
    end
    
    -- Check if slot is available
    if inventory[slot] then
        ECFunctions.Notify(source, 'Slot is not empty', 'error')
        return false
    end
    
    -- Add item to inventory
    inventory[slot] = {
        name = itemName,
        count = count,
        metadata = metadata
    }
    
    -- Update database
    ECDatabase.SetInventoryItem(playerData.character.id, slot, inventory[slot], function(success)
        if success then
            TriggerClientEvent('ec:client:updateInventory', source, inventory)
            ECFunctions.Notify(source, 'Added ' .. count .. 'x ' .. item.label, 'success')
            
            ECUtils.Log('info', 'Item added to inventory', {
                source = source,
                item = itemName,
                count = count,
                slot = slot
            })
        else
            -- Remove from memory if database update failed
            inventory[slot] = nil
        end
    end)
    
    return true
end

function ECInventory.RemoveItem(source, itemName, count, metadata)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    count = count or 1
    local inventory = playerData.character.inventory
    local totalRemoved = 0
    
    for slot, item in pairs(inventory) do
        if item and item.name == itemName then
            -- Check metadata match if specified
            if metadata then
                local metadataMatch = true
                for key, value in pairs(metadata) do
                    if item.metadata[key] ~= value then
                        metadataMatch = false
                        break
                    end
                end
                if not metadataMatch then
                    goto continue
                end
            end
            
            local removeFromSlot = math.min(item.count, count - totalRemoved)
            item.count = item.count - removeFromSlot
            totalRemoved = totalRemoved + removeFromSlot
            
            if item.count <= 0 then
                -- Remove item completely
                inventory[slot] = nil
                ECDatabase.SetInventoryItem(playerData.character.id, slot, nil)
            else
                -- Update item count
                ECDatabase.SetInventoryItem(playerData.character.id, slot, item)
            end
            
            if totalRemoved >= count then
                break
            end
            
            ::continue::
        end
    end
    
    if totalRemoved > 0 then
        TriggerClientEvent('ec:client:updateInventory', source, inventory)
        ECFunctions.Notify(source, 'Removed ' .. totalRemoved .. 'x ' .. Items[itemName].label, 'success')
        
        ECUtils.Log('info', 'Item removed from inventory', {
            source = source,
            item = itemName,
            count = totalRemoved
        })
        
        return true
    end
    
    ECFunctions.Notify(source, 'You don\'t have this item', 'error')
    return false
end

function ECInventory.UseItem(source, slot)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local inventory = playerData.character.inventory
    local item = inventory[slot]
    
    if not item then
        ECFunctions.Notify(source, 'No item in this slot', 'error')
        return false
    end
    
    local itemData = Items[item.name]
    if not itemData then
        ECFunctions.Notify(source, 'Invalid item', 'error')
        return false
    end
    
    if not itemData.useable then
        ECFunctions.Notify(source, 'This item cannot be used', 'error')
        return false
    end
    
    -- Trigger item use event
    TriggerEvent('ec:server:useItem', source, item.name, item, slot)
    
    -- Default item usage effects
    if itemData.type == 'food' or itemData.type == 'drink' then
        ECInventory.RemoveItem(source, item.name, 1)
        TriggerClientEvent('ec:client:consumeItem', source, itemData)
    end
    
    ECUtils.Log('info', 'Item used', {
        source = source,
        item = item.name,
        slot = slot
    })
    
    return true
end

function ECInventory.MoveItem(source, fromSlot, toSlot)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local inventory = playerData.character.inventory
    local fromItem = inventory[fromSlot]
    local toItem = inventory[toSlot]
    
    if not fromItem then
        ECFunctions.Notify(source, 'No item to move', 'error')
        return false
    end
    
    if toItem then
        -- Swap items
        inventory[fromSlot] = toItem
        inventory[toSlot] = fromItem
        
        ECDatabase.SetInventoryItem(playerData.character.id, fromSlot, toItem)
        ECDatabase.SetInventoryItem(playerData.character.id, toSlot, fromItem)
    else
        -- Move to empty slot
        inventory[toSlot] = fromItem
        inventory[fromSlot] = nil
        
        ECDatabase.SetInventoryItem(playerData.character.id, toSlot, fromItem)
        ECDatabase.SetInventoryItem(playerData.character.id, fromSlot, nil)
    end
    
    TriggerClientEvent('ec:client:updateInventory', source, inventory)
    return true
end

-- Stash System
ECInventory.Stashes = {}

function ECInventory.OpenStash(source, stashId, maxWeight, maxSlots)
    maxWeight = maxWeight or 100000 -- 100kg default
    maxSlots = maxSlots or 50 -- 50 slots default
    
    ECDatabase.GetStash(stashId, function(stashData)
        ECInventory.Stashes[stashId] = {
            items = stashData,
            maxWeight = maxWeight,
            maxSlots = maxSlots,
            players = {}
        }
        
        -- Add player to stash users
        ECInventory.Stashes[stashId].players[source] = true
        
        TriggerClientEvent('ec:client:openStash', source, stashId, stashData, maxWeight, maxSlots)
        
        ECUtils.Log('info', 'Stash opened', {
            source = source,
            stash = stashId
        })
    end)
end

function ECInventory.CloseStash(source, stashId)
    if ECInventory.Stashes[stashId] and ECInventory.Stashes[stashId].players[source] then
        ECInventory.Stashes[stashId].players[source] = nil
        
        -- If no players are using the stash, save and unload it
        local hasPlayers = false
        for playerId, _ in pairs(ECInventory.Stashes[stashId].players) do
            if EC.Players[playerId] then
                hasPlayers = true
                break
            end
        end
        
        if not hasPlayers then
            ECDatabase.UpdateStash(stashId, ECInventory.Stashes[stashId].items)
            ECInventory.Stashes[stashId] = nil
        end
        
        TriggerClientEvent('ec:client:closeStash', source)
    end
end

function ECInventory.AddItemToStash(stashId, itemName, count, metadata, slot)
    local stash = ECInventory.Stashes[stashId]
    if not stash then return false end
    
    local item = Items[itemName]
    if not item then return false end
    
    count = count or 1
    metadata = metadata or {}
    
    -- Check weight limit
    local currentWeight = ECInventory.GetStashWeight(stashId)
    local itemWeight = item.weight * count
    
    if currentWeight + itemWeight > stash.maxWeight then
        return false
    end
    
    -- Find empty slot if not specified
    if not slot then
        for i = 1, stash.maxSlots do
            if not stash.items[i] then
                slot = i
                break
            end
        end
        
        if not slot then return false end
    end
    
    -- Add item
    stash.items[slot] = {
        name = itemName,
        count = count,
        metadata = metadata
    }
    
    -- Update all players using this stash
    for playerId, _ in pairs(stash.players) do
        if EC.Players[playerId] then
            TriggerClientEvent('ec:client:updateStash', playerId, stashId, stash.items)
        end
    end
    
    return true
end

function ECInventory.GetStashWeight(stashId)
    local stash = ECInventory.Stashes[stashId]
    if not stash then return 0 end
    
    local weight = 0
    for slot, item in pairs(stash.items) do
        if item and item.name and Items[item.name] then
            weight = weight + (Items[item.name].weight * item.count)
        end
    end
    
    return weight
end

-- Drop System
ECInventory.DroppedItems = {}
local nextDropId = 1

function ECInventory.DropItem(source, slot, count)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local inventory = playerData.character.inventory
    local item = inventory[slot]
    
    if not item then return false end
    
    count = count or item.count
    if count > item.count then count = item.count end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    
    -- Create dropped item
    local dropId = nextDropId
    nextDropId = nextDropId + 1
    
    ECInventory.DroppedItems[dropId] = {
        id = dropId,
        name = item.name,
        count = count,
        metadata = item.metadata,
        coords = coords,
        created = GetGameTimer()
    }
    
    -- Remove from inventory
    item.count = item.count - count
    if item.count <= 0 then
        inventory[slot] = nil
        ECDatabase.SetInventoryItem(playerData.character.id, slot, nil)
    else
        ECDatabase.SetInventoryItem(playerData.character.id, slot, item)
    end
    
    -- Spawn item in world
    TriggerClientEvent('ec:client:spawnDroppedItem', -1, ECInventory.DroppedItems[dropId])
    TriggerClientEvent('ec:client:updateInventory', source, inventory)
    
    -- Auto cleanup after timeout
    if Config.CleanupDroppedItems and Config.DropTimeout > 0 then
        SetTimeout(Config.DropTimeout, function()
            ECInventory.RemoveDroppedItem(dropId)
        end)
    end
    
    return true
end

function ECInventory.PickupItem(source, dropId)
    local droppedItem = ECInventory.DroppedItems[dropId]
    if not droppedItem then return false end
    
    if ECInventory.AddItem(source, droppedItem.name, droppedItem.count, droppedItem.metadata) then
        ECInventory.RemoveDroppedItem(dropId)
        return true
    end
    
    return false
end

function ECInventory.RemoveDroppedItem(dropId)
    if ECInventory.DroppedItems[dropId] then
        TriggerClientEvent('ec:client:removeDroppedItem', -1, dropId)
        ECInventory.DroppedItems[dropId] = nil
    end
end

-- Network Events
RegisterNetEvent('ec:server:useItem', function(slot)
    local source = source
    ECInventory.UseItem(source, slot)
end)

RegisterNetEvent('ec:server:moveItem', function(fromSlot, toSlot)
    local source = source
    ECInventory.MoveItem(source, fromSlot, toSlot)
end)

RegisterNetEvent('ec:server:dropItem', function(slot, count)
    local source = source
    ECInventory.DropItem(source, slot, count)
end)

RegisterNetEvent('ec:server:pickupItem', function(dropId)
    local source = source
    ECInventory.PickupItem(source, dropId)
end)

RegisterNetEvent('ec:server:openStash', function(stashId, maxWeight, maxSlots)
    local source = source
    ECInventory.OpenStash(source, stashId, maxWeight, maxSlots)
end)

RegisterNetEvent('ec:server:closeStash', function(stashId)
    local source = source
    ECInventory.CloseStash(source, stashId)
end)

-- Item Usage Events (examples)
RegisterNetEvent('ec:server:useItem', function(source, itemName, itemData, slot)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return end
    
    -- Custom item usage logic
    if itemName == 'bandage' then
        TriggerClientEvent('ec:client:heal', source, 25)
        ECInventory.RemoveItem(source, itemName, 1)
    elseif itemName == 'lockpick' then
        -- Lockpick usage would be handled by a lockpicking resource
        TriggerEvent('lockpicking:useLockpick', source)
    elseif itemName == 'repairkit' then
        TriggerClientEvent('ec:client:repairVehicle', source, 'basic')
        ECInventory.RemoveItem(source, itemName, 1)
    elseif itemName == 'phone' then
        TriggerClientEvent('ec:client:openPhone', source)
    end
end)

-- Commands
EC.RegisterCommand('giveitem', function(source, args)
    if #args < 3 then
        ECFunctions.Notify(source, 'Usage: /giveitem [player_id] [item_name] [count]', 'error')
        return
    end
    
    local targetSource = tonumber(args[1])
    local itemName = args[2]
    local count = tonumber(args[3]) or 1
    
    if not targetSource or not EC.Players[targetSource] then
        ECFunctions.Notify(source, 'Player not found', 'error')
        return
    end
    
    if not Items[itemName] then
        ECFunctions.Notify(source, 'Item not found', 'error')
        return
    end
    
    if ECInventory.AddItem(targetSource, itemName, count) then
        ECFunctions.Notify(source, 'Gave ' .. count .. 'x ' .. Items[itemName].label .. ' to player ' .. targetSource, 'success')
    else
        ECFunctions.Notify(source, 'Failed to give item', 'error')
    end
    
end, 'admin', 'Give item to a player')

-- Cleanup task
RegisterNetEvent('ec:server:cleanupDroppedItems', function()
    local currentTime = GetGameTimer()
    local cleanupCount = 0
    
    for dropId, droppedItem in pairs(ECInventory.DroppedItems) do
        if currentTime - droppedItem.created > Config.DropTimeout then
            ECInventory.RemoveDroppedItem(dropId)
            cleanupCount = cleanupCount + 1
        end
    end
    
    if cleanupCount > 0 then
        ECUtils.Log('info', 'Cleaned up dropped items', {count = cleanupCount})
    end
end)

-- Export inventory functions
exports('GetInventory', ECInventory.GetInventory)
exports('GetItemCount', ECInventory.GetItemCount)
exports('HasItem', ECInventory.HasItem)
exports('AddItem', ECInventory.AddItem)
exports('RemoveItem', ECInventory.RemoveItem)
exports('UseItem', ECInventory.UseItem)
exports('OpenStash', ECInventory.OpenStash)