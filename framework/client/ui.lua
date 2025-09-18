-- EletroCast Framework Client UI Components (ox_lib integration)
ECUI = {}

-- UI State Management
ECUI.ActiveMenus = {}
ECUI.OpenInventories = {}

-- Notification System
function ECUI.Notify(message, type, duration)
    if not Config.UI.UseOxLib then
        -- Fallback notification
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, false)
        return
    end
    
    lib.notify({
        title = 'EletroCast Framework',
        description = message,
        type = type or 'info',
        duration = duration or 5000,
        position = Config.UI.NotificationPosition or 'top-right'
    })
end

-- Progress Bar System
function ECUI.ProgressBar(options)
    if not Config.UI.UseOxLib then
        ECFunctions.Notify('Progress bars require ox_lib', 'error')
        return false
    end
    
    local defaultOptions = {
        duration = 5000,
        label = 'Processing...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = false,
            combat = true
        },
        anim = {},
        prop = {}
    }
    
    options = ECUtils.TableMerge(defaultOptions, options or {})
    
    return lib.progressBar(options)
end

-- Context Menu System
function ECUI.ShowContextMenu(menuId, title, options)
    if not Config.UI.UseOxLib then
        ECFunctions.Notify('Context menus require ox_lib', 'error')
        return
    end
    
    -- Format options for ox_lib
    local formattedOptions = {}
    for _, option in pairs(options) do
        table.insert(formattedOptions, {
            title = option.title or option.label,
            description = option.description,
            icon = option.icon,
            iconColor = option.iconColor,
            metadata = option.metadata,
            disabled = option.disabled,
            onSelect = option.onSelect,
            args = option.args
        })
    end
    
    lib.registerContext({
        id = menuId,
        title = title,
        options = formattedOptions
    })
    
    lib.showContext(menuId)
    ECUI.ActiveMenus[menuId] = true
end

function ECUI.HideContextMenu(menuId)
    if ECUI.ActiveMenus[menuId] then
        lib.hideContext()
        ECUI.ActiveMenus[menuId] = nil
    end
end

-- Input Dialog System
function ECUI.InputDialog(header, inputs)
    if not Config.UI.UseOxLib then
        ECFunctions.Notify('Input dialogs require ox_lib', 'error')
        return nil
    end
    
    return lib.inputDialog(header, inputs)
end

-- Alert Dialog System
function ECUI.AlertDialog(header, content, options)
    if not Config.UI.UseOxLib then
        ECFunctions.Notify('Alert dialogs require ox_lib', 'error')
        return nil
    end
    
    local defaultOptions = {
        centered = true,
        cancel = false,
        labels = {
            confirm = 'OK',
            cancel = 'Cancel'
        }
    }
    
    options = ECUtils.TableMerge(defaultOptions, options or {})
    
    return lib.alertDialog({
        header = header,
        content = content,
        centered = options.centered,
        cancel = options.cancel,
        labels = options.labels
    })
end

-- Inventory UI
function ECUI.OpenInventory()
    if not EC.PlayerData.character then
        ECFunctions.Notify('No character loaded', 'error')
        return
    end
    
    local inventory = EC.PlayerData.character.inventory or {}
    local options = {}
    
    -- Add inventory items
    for slot, item in pairs(inventory) do
        if item and item.name and Items[item.name] then
            local itemData = Items[item.name]
            table.insert(options, {
                title = item.count .. 'x ' .. itemData.label,
                description = itemData.description or 'No description',
                icon = 'box',
                metadata = {
                    'Weight: ' .. (itemData.weight * item.count) .. 'g',
                    'Slot: ' .. slot
                },
                onSelect = function()
                    ECUI.ShowItemActions(slot, item, itemData)
                end
            })
        end
    end
    
    -- Add empty slots info
    local emptySlots = Config.MaxInventorySlots - ECUtils.TableLength(inventory)
    local currentWeight = ECInventory and exports['framework']:call('GetInventoryWeight', PlayerId()) or 0
    
    table.insert(options, 1, {
        title = 'Inventory Status',
        description = 'Weight and slot information',
        icon = 'info',
        metadata = {
            'Weight: ' .. currentWeight .. '/' .. Config.MaxInventoryWeight .. 'g',
            'Slots: ' .. ECUtils.TableLength(inventory) .. '/' .. Config.MaxInventorySlots,
            'Empty Slots: ' .. emptySlots
        },
        disabled = true
    })
    
    ECUI.ShowContextMenu('inventory_main', 'Inventory', options)
end

function ECUI.ShowItemActions(slot, item, itemData)
    local options = {}
    
    -- Use item option
    if itemData.useable then
        table.insert(options, {
            title = 'Use Item',
            description = 'Use ' .. itemData.label,
            icon = 'hand',
            onSelect = function()
                TriggerServerEvent('ec:server:useItem', slot)
                ECUI.HideContextMenu('item_actions')
            end
        })
    end
    
    -- Drop item option
    table.insert(options, {
        title = 'Drop Item',
        description = 'Drop this item on the ground',
        icon = 'arrow-down',
        onSelect = function()
            local input = ECUI.InputDialog('Drop Item', {
                {
                    type = 'number',
                    label = 'Amount',
                    description = 'How many to drop?',
                    min = 1,
                    max = item.count,
                    default = 1
                }
            })
            
            if input and input[1] then
                TriggerServerEvent('ec:server:dropItem', slot, input[1])
                ECUI.HideContextMenu('item_actions')
            end
        end
    })
    
    -- Give item option (if other players are nearby)
    local nearbyPlayers = ECUI.GetNearbyPlayers()
    if #nearbyPlayers > 0 then
        table.insert(options, {
            title = 'Give Item',
            description = 'Give item to nearby player',
            icon = 'hand-heart',
            onSelect = function()
                ECUI.ShowGiveItemMenu(slot, item, itemData, nearbyPlayers)
            end
        })
    end
    
    -- Back option
    table.insert(options, {
        title = 'Back',
        description = 'Return to inventory',
        icon = 'arrow-left',
        onSelect = function()
            ECUI.OpenInventory()
        end
    })
    
    ECUI.ShowContextMenu('item_actions', itemData.label, options)
end

function ECUI.ShowGiveItemMenu(slot, item, itemData, nearbyPlayers)
    local options = {}
    
    for _, player in pairs(nearbyPlayers) do
        table.insert(options, {
            title = player.name,
            description = 'Give item to ' .. player.name,
            icon = 'user',
            onSelect = function()
                local input = ECUI.InputDialog('Give Item', {
                    {
                        type = 'number',
                        label = 'Amount',
                        description = 'How many to give?',
                        min = 1,
                        max = item.count,
                        default = 1
                    }
                })
                
                if input and input[1] then
                    TriggerServerEvent('ec:server:giveItem', player.source, slot, input[1])
                    ECUI.HideContextMenu('give_item')
                end
            end
        })
    end
    
    table.insert(options, {
        title = 'Back',
        description = 'Return to item actions',
        icon = 'arrow-left',
        onSelect = function()
            ECUI.ShowItemActions(slot, item, itemData)
        end
    })
    
    ECUI.ShowContextMenu('give_item', 'Give ' .. itemData.label, options)
end

function ECUI.GetNearbyPlayers(radius)
    radius = radius or 5.0
    local players = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, playerId in pairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance <= radius then
                table.insert(players, {
                    source = GetPlayerServerId(playerId),
                    name = GetPlayerName(playerId),
                    distance = distance
                })
            end
        end
    end
    
    return players
end

-- Job UI Components
function ECUI.ShowJobMenu()
    if not EC.PlayerData.character then return end
    
    local job = EC.PlayerData.character.job
    local options = {}
    
    -- Job info
    table.insert(options, {
        title = 'Job Information',
        description = job.label .. ' - ' .. (Jobs[job.name] and Jobs[job.name].grades[job.grade] and Jobs[job.name].grades[job.grade].name or 'Unknown'),
        icon = 'briefcase',
        metadata = {
            'Payment: ' .. ECUtils.FormatMoney(job.payment or 0),
            'Grade: ' .. job.grade,
            'Boss: ' .. (job.isboss and 'Yes' or 'No')
        },
        disabled = true
    })
    
    -- Duty toggle
    table.insert(options, {
        title = 'Toggle Duty',
        description = 'Go on/off duty',
        icon = 'clock',
        onSelect = function()
            TriggerServerEvent('ec:server:toggleDuty')
            ECUI.HideContextMenu('job_menu')
        end
    })
    
    -- Boss actions (if player is boss)
    if job.isboss then
        table.insert(options, {
            title = 'Boss Actions',
            description = 'Manage employees and business',
            icon = 'crown',
            onSelect = function()
                TriggerServerEvent('ec:server:requestBossMenu')
            end
        })
    end
    
    ECUI.ShowContextMenu('job_menu', 'Job Menu', options)
end

RegisterNetEvent('ec:client:openBossMenu', function(data)
    ECUI.ShowBossMenu(data)
end)

function ECUI.ShowBossMenu(data)
    local options = {}
    
    -- Employee management
    table.insert(options, {
        title = 'Manage Employees',
        description = 'Hire, fire, promote employees',
        icon = 'users',
        onSelect = function()
            ECUI.ShowEmployeeManagement(data.employees)
        end
    })
    
    -- Recruit nearby players
    local nearbyPlayers = ECUI.GetNearbyPlayers(10.0)
    if #nearbyPlayers > 0 then
        table.insert(options, {
            title = 'Recruit Player',
            description = 'Hire nearby players',
            icon = 'user-plus',
            onSelect = function()
                ECUI.ShowRecruitMenu(nearbyPlayers, data.job)
            end
        })
    end
    
    -- Business statistics
    table.insert(options, {
        title = 'Statistics',
        description = 'View business statistics',
        icon = 'chart-bar',
        metadata = {
            'Total Employees: ' .. #data.employees,
            'On Duty: ' .. data.onDutyCount,
            'Job: ' .. data.job.label
        },
        disabled = true
    })
    
    ECUI.ShowContextMenu('boss_menu', 'Boss Actions - ' .. data.job.label, options)
end

function ECUI.ShowEmployeeManagement(employees)
    local options = {}
    
    for _, employee in pairs(employees) do
        local statusText = employee.online and 'Online' or 'Offline'
        table.insert(options, {
            title = employee.name,
            description = 'Grade ' .. employee.grade .. ' - ' .. statusText,
            icon = 'user',
            onSelect = function()
                if employee.online then
                    ECUI.ShowEmployeeActions(employee)
                else
                    ECFunctions.Notify('Employee is offline', 'error')
                end
            end
        })
    end
    
    table.insert(options, {
        title = 'Back',
        description = 'Return to boss menu',
        icon = 'arrow-left',
        onSelect = function()
            TriggerServerEvent('ec:server:requestBossMenu')
        end
    })
    
    ECUI.ShowContextMenu('employee_management', 'Employee Management', options)
end

function ECUI.ShowEmployeeActions(employee)
    local options = {
        {
            title = 'Promote',
            description = 'Promote this employee',
            icon = 'arrow-up',
            iconColor = 'green',
            onSelect = function()
                TriggerServerEvent('ec:server:promotePlayer', employee.source)
                ECUI.HideContextMenu('employee_actions')
            end
        },
        {
            title = 'Demote',
            description = 'Demote this employee',
            icon = 'arrow-down',
            iconColor = 'orange',
            onSelect = function()
                TriggerServerEvent('ec:server:demotePlayer', employee.source)
                ECUI.HideContextMenu('employee_actions')
            end
        },
        {
            title = 'Fire',
            description = 'Fire this employee',
            icon = 'user-minus',
            iconColor = 'red',
            onSelect = function()
                local confirm = ECUI.AlertDialog(
                    'Fire Employee',
                    'Are you sure you want to fire ' .. employee.name .. '?',
                    {cancel = true}
                )
                
                if confirm == 'confirm' then
                    TriggerServerEvent('ec:server:firePlayer', employee.source)
                    ECUI.HideContextMenu('employee_actions')
                end
            end
        },
        {
            title = 'Back',
            description = 'Return to employee list',
            icon = 'arrow-left',
            onSelect = function()
                TriggerServerEvent('ec:server:requestBossMenu')
            end
        }
    }
    
    ECUI.ShowContextMenu('employee_actions', employee.name, options)
end

-- Banking UI
function ECUI.ShowBankMenu()
    if not EC.PlayerData.character then return end
    
    local character = EC.PlayerData.character
    local options = {
        {
            title = 'Account Balance',
            description = 'Current account information',
            icon = 'wallet',
            metadata = {
                'Cash: ' .. ECUtils.FormatMoney(character.cash or 0),
                'Bank: ' .. ECUtils.FormatMoney(character.bank or 0)
            },
            disabled = true
        },
        {
            title = 'Deposit Money',
            description = 'Deposit cash into your account',
            icon = 'arrow-down',
            onSelect = function()
                local input = ECUI.InputDialog('Deposit Money', {
                    {
                        type = 'number',
                        label = 'Amount',
                        description = 'Amount to deposit',
                        min = 1,
                        max = character.cash or 0
                    }
                })
                
                if input and input[1] then
                    TriggerServerEvent('ec:server:depositMoney', input[1])
                    ECUI.HideContextMenu('bank_menu')
                end
            end
        },
        {
            title = 'Withdraw Money',
            description = 'Withdraw money from your account',
            icon = 'arrow-up',
            onSelect = function()
                local input = ECUI.InputDialog('Withdraw Money', {
                    {
                        type = 'number',
                        label = 'Amount',
                        description = 'Amount to withdraw',
                        min = 1,
                        max = character.bank or 0
                    }
                })
                
                if input and input[1] then
                    TriggerServerEvent('ec:server:withdrawMoney', input[1])
                    ECUI.HideContextMenu('bank_menu')
                end
            end
        }
    }
    
    ECUI.ShowContextMenu('bank_menu', 'Banking', options)
end

-- Vehicle UI
function ECUI.ShowVehicleMenu(vehicle)
    local options = {
        {
            title = 'Engine',
            description = 'Toggle engine on/off',
            icon = 'engine',
            onSelect = function()
                local engine = GetIsVehicleEngineRunning(vehicle)
                SetVehicleEngineOn(vehicle, not engine, false, true)
                ECFunctions.Notify('Engine ' .. (not engine and 'started' or 'stopped'), 'info')
                ECUI.HideContextMenu('vehicle_menu')
            end
        },
        {
            title = 'Lock/Unlock',
            description = 'Toggle vehicle locks',
            icon = 'lock',
            onSelect = function()
                local lockStatus = GetVehicleDoorLockStatus(vehicle)
                local newStatus = lockStatus == 1 and 2 or 1
                SetVehicleDoorsLocked(vehicle, newStatus)
                ECFunctions.Notify('Vehicle ' .. (newStatus == 2 and 'locked' or 'unlocked'), 'info')
                ECUI.HideContextMenu('vehicle_menu')
            end
        }
    }
    
    ECUI.ShowContextMenu('vehicle_menu', 'Vehicle Options', options)
end

-- Export UI functions
exports('Notify', ECUI.Notify)
exports('ProgressBar', ECUI.ProgressBar)
exports('ShowContextMenu', ECUI.ShowContextMenu)
exports('InputDialog', ECUI.InputDialog)
exports('AlertDialog', ECUI.AlertDialog)
exports('OpenInventory', ECUI.OpenInventory)
exports('ShowJobMenu', ECUI.ShowJobMenu)
exports('ShowBankMenu', ECUI.ShowBankMenu)