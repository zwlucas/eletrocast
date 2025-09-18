-- EletroCast Framework Client Jobs System
ECJobs = {}

-- Job state tracking
ECJobs.CurrentJob = nil
ECJobs.OnDuty = false
ECJobs.JobBlips = {}
ECJobs.JobMarkers = {}

-- Job initialization
function ECJobs.Initialize()
    ECJobs.CreateJobBlips()
    ECJobs.CreateJobCenters()
    ECJobs.StartJobThreads()
end

-- Job Center Management
function ECJobs.CreateJobCenters()
    for _, center in pairs(JobCenters or {}) do
        -- Create blip
        local blip = AddBlipForCoord(center.coords.x, center.coords.y, center.coords.z)
        SetBlipSprite(blip, center.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, center.blip.scale)
        SetBlipColour(blip, center.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(center.blip.label)
        EndTextCommandSetBlipName(blip)
        
        table.insert(ECJobs.JobBlips, blip)
        
        -- Create marker thread
        CreateThread(function()
            while true do
                local sleep = 1000
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - center.coords)
                
                if distance < 50.0 then
                    sleep = 0
                    DrawMarker(1, center.coords.x, center.coords.y, center.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                    
                    if distance < 2.0 then
                        ECUtils.ShowHelpText('Press ~INPUT_CONTEXT~ to access Job Center')
                        
                        if IsControlJustReleased(0, 38) then -- E key
                            ECJobs.ShowJobCenter(center)
                        end
                    end
                end
                
                Wait(sleep)
            end
        end)
    end
end

function ECJobs.ShowJobCenter(center)
    TriggerServerEvent('ec:server:requestAvailableJobs')
end

RegisterNetEvent('ec:client:receiveAvailableJobs', function(availableJobs)
    local options = {}
    
    -- Add current job info
    if EC.PlayerData.character and EC.PlayerData.character.job then
        local currentJob = EC.PlayerData.character.job
        table.insert(options, {
            title = 'Current Job',
            description = currentJob.label .. ' - Grade ' .. currentJob.grade,
            icon = 'briefcase',
            metadata = {
                'Payment: ' .. ECUtils.FormatMoney(currentJob.payment or 0),
                'Type: ' .. (Jobs[currentJob.name] and Jobs[currentJob.name].type or 'Unknown')
            },
            disabled = true
        })
        
        table.insert(options, {
            title = '---',
            disabled = true
        })
    end
    
    -- Add available jobs
    for _, job in pairs(availableJobs) do
        table.insert(options, {
            title = job.label,
            description = 'Starting payment: ' .. ECUtils.FormatMoney(job.payment),
            icon = 'work',
            metadata = {
                'Type: ' .. (job.type or 'civilian'),
                'Whitelisted: No'
            },
            onSelect = function()
                local confirm = ECUI.AlertDialog(
                    'Change Job',
                    'Are you sure you want to change to ' .. job.label .. '?',
                    {cancel = true}
                )
                
                if confirm == 'confirm' then
                    TriggerServerEvent('ec:server:selectJob', job.name)
                    ECUI.HideContextMenu('job_center')
                end
            end
        })
    end
    
    ECUI.ShowContextMenu('job_center', 'Job Center', options)
end)

-- Boss Action Locations
function ECJobs.CreateBossActionPoints()
    for jobName, location in pairs(BossActions or {}) do
        CreateThread(function()
            while true do
                local sleep = 1000
                
                if EC.PlayerData.character and 
                   ECUtils.TableContains(location.jobs, EC.PlayerData.character.job.name) and
                   EC.PlayerData.character.job.grade >= location.grade then
                    
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - location.coords)
                    
                    if distance < 50.0 then
                        sleep = 0
                        DrawMarker(1, location.coords.x, location.coords.y, location.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 255, 0, 100, false, true, 2, nil, nil, false)
                        
                        if distance < 2.0 then
                            ECUtils.ShowHelpText('Press ~INPUT_CONTEXT~ to access Boss Actions')
                            
                            if IsControlJustReleased(0, 38) then -- E key
                                TriggerServerEvent('ec:server:requestBossMenu')
                            end
                        end
                    end
                end
                
                Wait(sleep)
            end
        end)
    end
end

-- Job-specific blips and markers
function ECJobs.CreateJobBlips()
    -- Police stations
    if Jobs['police'] then
        local policeStations = {
            {coords = vector3(428.9, -984.5, 30.7), name = 'Mission Row PD'},
            {coords = vector3(1855.1, 3678.9, 34.3), name = 'Sandy Shores PD'},
            {coords = vector3(-449.1, 6012.9, 31.7), name = 'Paleto Bay PD'}
        }
        
        for _, station in pairs(policeStations) do
            local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
            SetBlipSprite(blip, 60)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 3)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(station.name)
            EndTextCommandSetBlipName(blip)
            table.insert(ECJobs.JobBlips, blip)
        end
    end
    
    -- Hospitals
    if Jobs['ambulance'] then
        local hospitals = {
            {coords = vector3(298.6, -584.4, 43.3), name = 'Pillbox Medical'},
            {coords = vector3(1839.6, 3672.9, 34.3), name = 'Sandy Shores Medical'},
            {coords = vector3(-247.8, 6331.5, 32.4), name = 'Paleto Bay Medical'}
        }
        
        for _, hospital in pairs(hospitals) do
            local blip = AddBlipForCoord(hospital.coords.x, hospital.coords.y, hospital.coords.z)
            SetBlipSprite(blip, 61)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 1)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(hospital.name)
            EndTextCommandSetBlipName(blip)
            table.insert(ECJobs.JobBlips, blip)
        end
    end
    
    -- Mechanic shops
    if Jobs['mechanic'] then
        local mechanicShops = {
            {coords = vector3(-347.99, -133.43, 39.01), name = 'LS Customs'},
            {coords = vector3(1174.8, 2640.8, 37.8), name = 'LS Customs Sandy'},
            {coords = vector3(110.9, 6626.6, 31.9), name = 'LS Customs Paleto'}
        }
        
        for _, shop in pairs(mechanicShops) do
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, 446)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 5)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(shop.name)
            EndTextCommandSetBlipName(blip)
            table.insert(ECJobs.JobBlips, blip)
        end
    end
end

-- Job-specific functionality
function ECJobs.OnJobUpdate(jobData)
    ECJobs.CurrentJob = jobData
    ECJobs.RefreshJobBlips()
    ECJobs.UpdateJobUI()
    
    -- Job-specific initialization
    if jobData.name == 'police' then
        ECJobs.InitializePoliceJob()
    elseif jobData.name == 'ambulance' then
        ECJobs.InitializeEMSJob()
    elseif jobData.name == 'mechanic' then
        ECJobs.InitializeMechanicJob()
    elseif jobData.name == 'taxi' then
        ECJobs.InitializeTaxiJob()
    end
end

function ECJobs.RefreshJobBlips()
    -- This would update job-specific blips based on current job
    -- For example, show police blips only for police officers
end

function ECJobs.UpdateJobUI()
    -- Update any job-related UI elements
    if ECJobs.CurrentJob then
        ECFunctions.Notify('Job updated: ' .. ECJobs.CurrentJob.label, 'info')
    end
end

-- Police Job Functions
function ECJobs.InitializePoliceJob()
    -- Police-specific initialization
    ECJobs.CreatePoliceActions()
end

function ECJobs.CreatePoliceActions()
    -- Handcuff nearby players
    RegisterKeyMapping('police:handcuff', 'Handcuff Player', 'keyboard', 'G')
    RegisterCommand('police:handcuff', function()
        if ECJobs.CurrentJob and ECJobs.CurrentJob.name == 'police' and ECJobs.OnDuty then
            local nearbyPlayers = ECUI.GetNearbyPlayers(3.0)
            if #nearbyPlayers > 0 then
                -- Show handcuff menu
                ECJobs.ShowHandcuffMenu(nearbyPlayers)
            else
                ECFunctions.Notify('No players nearby', 'error')
            end
        end
    end)
end

function ECJobs.ShowHandcuffMenu(players)
    local options = {}
    
    for _, player in pairs(players) do
        table.insert(options, {
            title = player.name,
            description = 'Handcuff ' .. player.name,
            icon = 'handcuffs',
            onSelect = function()
                TriggerServerEvent('ec:server:handcuffPlayer', player.source)
                ECUI.HideContextMenu('handcuff_menu')
            end
        })
    end
    
    ECUI.ShowContextMenu('handcuff_menu', 'Handcuff Player', options)
end

-- EMS Job Functions
function ECJobs.InitializeEMSJob()
    ECJobs.CreateEMSActions()
end

function ECJobs.CreateEMSActions()
    -- Revive nearby players
    RegisterKeyMapping('ems:revive', 'Revive Player', 'keyboard', 'G')
    RegisterCommand('ems:revive', function()
        if ECJobs.CurrentJob and ECJobs.CurrentJob.name == 'ambulance' and ECJobs.OnDuty then
            local nearbyPlayers = ECUI.GetNearbyPlayers(3.0)
            if #nearbyPlayers > 0 then
                ECJobs.ShowReviveMenu(nearbyPlayers)
            else
                ECFunctions.Notify('No players nearby', 'error')
            end
        end
    end)
end

function ECJobs.ShowReviveMenu(players)
    local options = {}
    
    for _, player in pairs(players) do
        table.insert(options, {
            title = player.name,
            description = 'Revive ' .. player.name,
            icon = 'heart',
            onSelect = function()
                -- Start revive process
                local success = ECFunctions.ProgressBar({
                    duration = 10000,
                    label = 'Reviving ' .. player.name,
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true
                    },
                    anim = {
                        dict = 'mini@cpr@char_a@cpr_str',
                        clip = 'cpr_pumpchest'
                    }
                })
                
                if success then
                    TriggerServerEvent('ec:server:revivePlayer', player.source)
                    ECFunctions.Notify('Successfully revived ' .. player.name, 'success')
                else
                    ECFunctions.Notify('Revival cancelled', 'error')
                end
                
                ECUI.HideContextMenu('revive_menu')
            end
        })
    end
    
    ECUI.ShowContextMenu('revive_menu', 'Revive Player', options)
end

-- Mechanic Job Functions
function ECJobs.InitializeMechanicJob()
    ECJobs.CreateMechanicActions()
end

function ECJobs.CreateMechanicActions()
    -- Repair nearby vehicles
    RegisterKeyMapping('mechanic:repair', 'Repair Vehicle', 'keyboard', 'G')
    RegisterCommand('mechanic:repair', function()
        if ECJobs.CurrentJob and ECJobs.CurrentJob.name == 'mechanic' and ECJobs.OnDuty then
            local vehicle = ECJobs.GetClosestVehicle()
            if vehicle then
                ECJobs.ShowRepairMenu(vehicle)
            else
                ECFunctions.Notify('No vehicle nearby', 'error')
            end
        end
    end)
end

function ECJobs.GetClosestVehicle()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 71)
    
    if vehicle ~= 0 then
        return vehicle
    end
    
    return nil
end

function ECJobs.ShowRepairMenu(vehicle)
    local options = {
        {
            title = 'Basic Repair',
            description = 'Repair engine and body damage',
            icon = 'wrench',
            onSelect = function()
                ECJobs.RepairVehicle(vehicle, 'basic')
            end
        },
        {
            title = 'Full Repair',
            description = 'Complete vehicle restoration',
            icon = 'tools',
            onSelect = function()
                ECJobs.RepairVehicle(vehicle, 'full')
            end
        }
    }
    
    ECUI.ShowContextMenu('repair_menu', 'Vehicle Repair', options)
end

function ECJobs.RepairVehicle(vehicle, repairType)
    local duration = repairType == 'full' and 15000 or 8000
    local label = repairType == 'full' and 'Fully repairing vehicle' or 'Repairing vehicle'
    
    local success = ECFunctions.ProgressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        }
    })
    
    if success then
        if repairType == 'full' then
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
        else
            SetVehicleEngineHealth(vehicle, 1000.0)
            SetVehicleBodyHealth(vehicle, 1000.0)
        end
        
        ECFunctions.Notify('Vehicle repaired successfully', 'success')
    else
        ECFunctions.Notify('Repair cancelled', 'error')
    end
    
    ECUI.HideContextMenu('repair_menu')
end

-- Taxi Job Functions
function ECJobs.InitializeTaxiJob()
    ECJobs.CreateTaxiActions()
end

function ECJobs.CreateTaxiActions()
    -- Toggle taxi meter
    RegisterKeyMapping('taxi:meter', 'Toggle Taxi Meter', 'keyboard', 'G')
    RegisterCommand('taxi:meter', function()
        if ECJobs.CurrentJob and ECJobs.CurrentJob.name == 'taxi' and ECJobs.OnDuty then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= 0 then
                ECJobs.ToggleTaxiMeter(vehicle)
            else
                ECFunctions.Notify('You must be in a vehicle', 'error')
            end
        end
    end)
end

function ECJobs.ToggleTaxiMeter(vehicle)
    -- Taxi meter logic would go here
    ECFunctions.Notify('Taxi meter toggled', 'info')
end

-- Duty Management
function ECJobs.ToggleDuty()
    TriggerServerEvent('ec:server:toggleDuty')
end

RegisterNetEvent('ec:client:dutyChanged', function(onDuty)
    ECJobs.OnDuty = onDuty
    local status = onDuty and 'ON DUTY' or 'OFF DUTY'
    ECFunctions.Notify('You are now ' .. status, 'info')
end)

-- Job-specific threads
function ECJobs.StartJobThreads()
    -- Thread for job-specific actions and checks
    CreateThread(function()
        while true do
            Wait(1000)
            
            if ECJobs.CurrentJob and ECJobs.OnDuty then
                -- Job-specific periodic actions
                if ECJobs.CurrentJob.name == 'police' then
                    -- Police-specific checks
                elseif ECJobs.CurrentJob.name == 'ambulance' then
                    -- EMS-specific checks
                elseif ECJobs.CurrentJob.name == 'mechanic' then
                    -- Mechanic-specific checks
                end
            end
        end
    end)
end

-- Cleanup
function ECJobs.Cleanup()
    -- Remove all job blips
    for _, blip in pairs(ECJobs.JobBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    ECJobs.JobBlips = {}
end

-- Event handlers
RegisterNetEvent('ec:client:onJobUpdate', function(jobData)
    ECJobs.OnJobUpdate(jobData)
end)

RegisterNetEvent('ec:client:onDutyChange', function(onDuty)
    ECJobs.OnDuty = onDuty
end)

-- Initialize when player is loaded
RegisterNetEvent('ec:client:playerLoaded', function()
    ECJobs.Initialize()
    ECJobs.CreateBossActionPoints()
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ECJobs.Cleanup()
    end
end)

-- Show help text utility
function ECUtils.ShowHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Export job functions
exports('ToggleDuty', ECJobs.ToggleDuty)
exports('GetCurrentJob', function() return ECJobs.CurrentJob end)
exports('IsOnDuty', function() return ECJobs.OnDuty end)