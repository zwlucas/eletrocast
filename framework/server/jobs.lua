-- EletroCast Framework Jobs System (QBCore-style)
ECJobs = {}

-- Job Management Functions
function ECJobs.GetJob(jobName)
    return Jobs[jobName]
end

function ECJobs.GetAllJobs()
    return Jobs
end

function ECJobs.DoesJobExist(jobName)
    return Jobs[jobName] ~= nil
end

function ECJobs.GetJobGrade(jobName, grade)
    local job = Jobs[jobName]
    if job and job.grades[grade] then
        return job.grades[grade]
    end
    return nil
end

function ECJobs.IsJobWhitelisted(jobName)
    local job = Jobs[jobName]
    return job and job.whitelisted or false
end

function ECJobs.GetJobEmployees(jobName)
    local employees = {}
    for source, playerData in pairs(EC.Players) do
        if playerData.character and playerData.character.job.name == jobName then
            table.insert(employees, {
                source = source,
                character = playerData.character,
                name = playerData.character.firstname .. ' ' .. playerData.character.lastname,
                grade = playerData.character.job.grade,
                online = true
            })
        end
    end
    return employees
end

-- Player Job Functions
function ECJobs.SetPlayerJob(source, jobName, grade, notify)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local job = Jobs[jobName]
    if not job then
        ECUtils.Log('error', 'Job does not exist', {job = jobName})
        return false
    end
    
    local jobGrade = job.grades[grade]
    if not jobGrade then
        ECUtils.Log('error', 'Job grade does not exist', {job = jobName, grade = grade})
        return false
    end
    
    -- Update player data
    playerData.character.job = {
        name = jobName,
        grade = grade,
        label = job.label,
        payment = jobGrade.payment,
        isboss = jobGrade.isboss
    }
    
    -- Update database
    ECDatabase.UpdateCharacter(playerData.character.id, {
        job = jobName,
        job_grade = grade
    }, function(success)
        if success then
            -- Update client
            TriggerClientEvent('ec:client:updatePlayerData', source, playerData.character)
            TriggerClientEvent('ec:client:jobUpdated', source, playerData.character.job)
            
            -- Trigger events
            TriggerEvent('ec:server:jobUpdated', source, jobName, grade)
            TriggerClientEvent('ec:client:onJobUpdate', source, jobName, grade)
            
            if notify ~= false then
                ECFunctions.Notify(source, 'Job updated to ' .. job.label .. ' - ' .. jobGrade.name, 'success')
            end
            
            ECUtils.Log('info', 'Player job updated', {
                source = source,
                job = jobName,
                grade = grade,
                label = job.label
            })
        end
    end)
    
    return true
end

function ECJobs.PromotePlayer(source, targetSource, notify)
    local playerData = EC.Players[source]
    local targetData = EC.Players[targetSource]
    
    if not playerData or not targetData or not playerData.character or not targetData.character then
        return false
    end
    
    -- Check if source has permission to promote
    if not playerData.character.job.isboss then
        ECFunctions.Notify(source, 'You don\'t have permission to promote employees', 'error')
        return false
    end
    
    -- Check if they are in the same job
    if playerData.character.job.name ~= targetData.character.job.name then
        ECFunctions.Notify(source, 'Player is not in your job', 'error')
        return false
    end
    
    local job = Jobs[targetData.character.job.name]
    local currentGrade = targetData.character.job.grade
    local newGrade = currentGrade + 1
    
    -- Check if promotion is possible
    if not job.grades[newGrade] then
        ECFunctions.Notify(source, 'Player is already at maximum grade', 'error')
        return false
    end
    
    -- Check if source can promote to this grade
    if newGrade >= playerData.character.job.grade then
        ECFunctions.Notify(source, 'You cannot promote someone to your grade or higher', 'error')
        return false
    end
    
    ECJobs.SetPlayerJob(targetSource, targetData.character.job.name, newGrade, notify)
    
    if notify ~= false then
        ECFunctions.Notify(source, 'Promoted ' .. targetData.character.firstname .. ' ' .. targetData.character.lastname .. ' to ' .. job.grades[newGrade].name, 'success')
        ECFunctions.Notify(targetSource, 'You have been promoted to ' .. job.grades[newGrade].name, 'success')
    end
    
    return true
end

function ECJobs.DemotePlayer(source, targetSource, notify)
    local playerData = EC.Players[source]
    local targetData = EC.Players[targetSource]
    
    if not playerData or not targetData or not playerData.character or not targetData.character then
        return false
    end
    
    -- Check if source has permission to demote
    if not playerData.character.job.isboss then
        ECFunctions.Notify(source, 'You don\'t have permission to demote employees', 'error')
        return false
    end
    
    -- Check if they are in the same job
    if playerData.character.job.name ~= targetData.character.job.name then
        ECFunctions.Notify(source, 'Player is not in your job', 'error')
        return false
    end
    
    local job = Jobs[targetData.character.job.name]
    local currentGrade = targetData.character.job.grade
    local newGrade = currentGrade - 1
    
    -- Check if demotion is possible
    if newGrade < 0 or not job.grades[newGrade] then
        ECFunctions.Notify(source, 'Player is already at minimum grade', 'error')
        return false
    end
    
    -- Check if source can demote this grade
    if currentGrade >= playerData.character.job.grade then
        ECFunctions.Notify(source, 'You cannot demote someone of your grade or higher', 'error')
        return false
    end
    
    ECJobs.SetPlayerJob(targetSource, targetData.character.job.name, newGrade, notify)
    
    if notify ~= false then
        ECFunctions.Notify(source, 'Demoted ' .. targetData.character.firstname .. ' ' .. targetData.character.lastname .. ' to ' .. job.grades[newGrade].name, 'success')
        ECFunctions.Notify(targetSource, 'You have been demoted to ' .. job.grades[newGrade].name, 'error')
    end
    
    return true
end

function ECJobs.FirePlayer(source, targetSource, notify)
    local playerData = EC.Players[source]
    local targetData = EC.Players[targetSource]
    
    if not playerData or not targetData or not playerData.character or not targetData.character then
        return false
    end
    
    -- Check if source has permission to fire
    if not playerData.character.job.isboss then
        ECFunctions.Notify(source, 'You don\'t have permission to fire employees', 'error')
        return false
    end
    
    -- Check if they are in the same job
    if playerData.character.job.name ~= targetData.character.job.name then
        ECFunctions.Notify(source, 'Player is not in your job', 'error')
        return false
    end
    
    -- Check if source can fire this grade
    if targetData.character.job.grade >= playerData.character.job.grade then
        ECFunctions.Notify(source, 'You cannot fire someone of your grade or higher', 'error')
        return false
    end
    
    ECJobs.SetPlayerJob(targetSource, 'unemployed', 0, notify)
    
    if notify ~= false then
        ECFunctions.Notify(source, 'Fired ' .. targetData.character.firstname .. ' ' .. targetData.character.lastname, 'success')
        ECFunctions.Notify(targetSource, 'You have been fired from your job', 'error')
    end
    
    return true
end

function ECJobs.HirePlayer(source, targetSource, jobName, grade, notify)
    local playerData = EC.Players[source]
    local targetData = EC.Players[targetSource]
    
    if not playerData or not targetData or not playerData.character or not targetData.character then
        return false
    end
    
    -- Check if source has permission to hire
    if not playerData.character.job.isboss then
        ECFunctions.Notify(source, 'You don\'t have permission to hire employees', 'error')
        return false
    end
    
    -- Check if hiring for own job
    if playerData.character.job.name ~= jobName then
        ECFunctions.Notify(source, 'You can only hire for your own job', 'error')
        return false
    end
    
    -- Check if grade is valid and within permissions
    local job = Jobs[jobName]
    if not job or not job.grades[grade] then
        ECFunctions.Notify(source, 'Invalid job or grade', 'error')
        return false
    end
    
    if grade >= playerData.character.job.grade then
        ECFunctions.Notify(source, 'You cannot hire someone to your grade or higher', 'error')
        return false
    end
    
    ECJobs.SetPlayerJob(targetSource, jobName, grade, notify)
    
    if notify ~= false then
        ECFunctions.Notify(source, 'Hired ' .. targetData.character.firstname .. ' ' .. targetData.character.lastname .. ' as ' .. job.grades[grade].name, 'success')
        ECFunctions.Notify(targetSource, 'You have been hired as ' .. job.grades[grade].name .. ' at ' .. job.label, 'success')
    end
    
    return true
end

-- Duty System
ECJobs.DutyPlayers = {}

function ECJobs.ToggleDuty(source)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    local job = Jobs[playerData.character.job.name]
    if not job then return false end
    
    local isOnDuty = ECJobs.DutyPlayers[source] == true
    ECJobs.DutyPlayers[source] = not isOnDuty
    
    TriggerClientEvent('ec:client:dutyChanged', source, ECJobs.DutyPlayers[source])
    TriggerEvent('ec:server:dutyChanged', source, ECJobs.DutyPlayers[source])
    
    local dutyText = ECJobs.DutyPlayers[source] and 'on' or 'off'
    ECFunctions.Notify(source, 'You are now ' .. dutyText .. ' duty', 'info')
    
    ECUtils.Log('info', 'Duty status changed', {
        source = source,
        job = playerData.character.job.name,
        onDuty = ECJobs.DutyPlayers[source]
    })
    
    return true
end

function ECJobs.IsPlayerOnDuty(source)
    return ECJobs.DutyPlayers[source] == true
end

function ECJobs.GetOnDutyPlayers(jobName)
    local onDutyPlayers = {}
    for source, playerData in pairs(EC.Players) do
        if playerData.character and playerData.character.job.name == jobName and ECJobs.IsPlayerOnDuty(source) then
            table.insert(onDutyPlayers, {
                source = source,
                character = playerData.character,
                name = playerData.character.firstname .. ' ' .. playerData.character.lastname,
                grade = playerData.character.job.grade
            })
        end
    end
    return onDutyPlayers
end

-- Boss Actions Menu
function ECJobs.OpenBossMenu(source)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return false end
    
    if not playerData.character.job.isboss then
        ECFunctions.Notify(source, 'You don\'t have access to boss actions', 'error')
        return false
    end
    
    local employees = ECJobs.GetJobEmployees(playerData.character.job.name)
    local onDutyCount = #ECJobs.GetOnDutyPlayers(playerData.character.job.name)
    
    TriggerClientEvent('ec:client:openBossMenu', source, {
        job = playerData.character.job,
        employees = employees,
        onDutyCount = onDutyCount
    })
    
    return true
end

-- Network Events
RegisterNetEvent('ec:server:setJob', function(targetSource, jobName, grade)
    local source = source
    if not ECFunctions.HasPermission(source, 'admin') then
        ECFunctions.Notify(source, 'You don\'t have permission to set jobs', 'error')
        return
    end
    
    ECJobs.SetPlayerJob(targetSource, jobName, grade)
end)

RegisterNetEvent('ec:server:promotePlayer', function(targetSource)
    local source = source
    ECJobs.PromotePlayer(source, targetSource)
end)

RegisterNetEvent('ec:server:demotePlayer', function(targetSource)
    local source = source
    ECJobs.DemotePlayer(source, targetSource)
end)

RegisterNetEvent('ec:server:firePlayer', function(targetSource)
    local source = source
    ECJobs.FirePlayer(source, targetSource)
end)

RegisterNetEvent('ec:server:hirePlayer', function(targetSource, grade)
    local source = source
    local playerData = EC.Players[source]
    if playerData and playerData.character then
        ECJobs.HirePlayer(source, targetSource, playerData.character.job.name, grade)
    end
end)

RegisterNetEvent('ec:server:toggleDuty', function()
    local source = source
    ECJobs.ToggleDuty(source)
end)

RegisterNetEvent('ec:server:requestBossMenu', function()
    local source = source
    ECJobs.OpenBossMenu(source)
end)

-- Job Center Functions
function ECJobs.GetAvailableJobs()
    local availableJobs = {}
    for jobName, jobData in pairs(Jobs) do
        if not jobData.whitelisted then
            table.insert(availableJobs, {
                name = jobName,
                label = jobData.label,
                type = jobData.type,
                payment = jobData.grades[0] and jobData.grades[0].payment or 0
            })
        end
    end
    return availableJobs
end

RegisterNetEvent('ec:server:requestAvailableJobs', function()
    local source = source
    local availableJobs = ECJobs.GetAvailableJobs()
    TriggerClientEvent('ec:client:receiveAvailableJobs', source, availableJobs)
end)

RegisterNetEvent('ec:server:selectJob', function(jobName)
    local source = source
    local playerData = EC.Players[source]
    
    if not playerData or not playerData.character then return end
    
    local job = Jobs[jobName]
    if not job then
        ECFunctions.Notify(source, 'Invalid job selection', 'error')
        return
    end
    
    if job.whitelisted then
        ECFunctions.Notify(source, 'This job requires whitelisting', 'error')
        return
    end
    
    ECJobs.SetPlayerJob(source, jobName, 0)
end)

-- Commands
EC.RegisterCommand('job', function(source, args)
    if #args < 3 then
        ECFunctions.Notify(source, 'Usage: /job [player_id] [job_name] [grade]', 'error')
        return
    end
    
    local targetSource = tonumber(args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    
    if not targetSource or not EC.Players[targetSource] then
        ECFunctions.Notify(source, 'Player not found', 'error')
        return
    end
    
    if not Jobs[jobName] then
        ECFunctions.Notify(source, 'Job not found', 'error')
        return
    end
    
    if ECJobs.SetPlayerJob(targetSource, jobName, grade) then
        ECFunctions.Notify(source, 'Set job for player ' .. targetSource .. ' to ' .. jobName .. ' grade ' .. grade, 'success')
    else
        ECFunctions.Notify(source, 'Failed to set job', 'error')
    end
    
end, 'admin', 'Set player job')

EC.RegisterCommand('duty', function(source, args)
    ECJobs.ToggleDuty(source)
end, false, 'Toggle duty status')

EC.RegisterCommand('bossmenu', function(source, args)
    ECJobs.OpenBossMenu(source)
end, false, 'Open boss actions menu')

EC.RegisterCommand('employees', function(source, args)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return end
    
    local employees = ECJobs.GetJobEmployees(playerData.character.job.name)
    local onDutyCount = #ECJobs.GetOnDutyPlayers(playerData.character.job.name)
    
    ECFunctions.Notify(source, 'Job: ' .. playerData.character.job.label .. ' | Employees: ' .. #employees .. ' | On Duty: ' .. onDutyCount, 'info')
end, false, 'Check job employee status')

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    ECJobs.DutyPlayers[source] = nil
end)

-- Export job functions
exports('GetJob', ECJobs.GetJob)
exports('SetPlayerJob', ECJobs.SetPlayerJob)
exports('PromotePlayer', ECJobs.PromotePlayer)
exports('DemotePlayer', ECJobs.DemotePlayer)
exports('FirePlayer', ECJobs.FirePlayer)
exports('HirePlayer', ECJobs.HirePlayer)
exports('ToggleDuty', ECJobs.ToggleDuty)
exports('IsPlayerOnDuty', ECJobs.IsPlayerOnDuty)
exports('GetJobEmployees', ECJobs.GetJobEmployees)
exports('GetOnDutyPlayers', ECJobs.GetOnDutyPlayers)