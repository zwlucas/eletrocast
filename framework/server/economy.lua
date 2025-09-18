-- EletroCast Framework Economy System
ECEconomy = {}

-- Transaction Types
ECEconomy.TransactionTypes = {
    ADD_MONEY = 'add_money',
    REMOVE_MONEY = 'remove_money',
    TRANSFER_MONEY = 'transfer_money',
    PAYCHECK = 'paycheck',
    PURCHASE = 'purchase',
    SALE = 'sale',
    FINE = 'fine',
    BONUS = 'bonus',
    TAX = 'tax',
    BUSINESS_INCOME = 'business_income',
    BUSINESS_EXPENSE = 'business_expense'
}

-- Money Types
ECEconomy.MoneyTypes = {
    CASH = 'cash',
    BANK = 'bank',
    DIRTY_MONEY = 'dirty_money'
}

-- Economy Functions
function ECEconomy.GetServerBalance()
    -- Get total money in circulation
    MySQL.Async.fetchAll('SELECT SUM(cash) as total_cash, SUM(bank) as total_bank, SUM(dirty_money) as total_dirty FROM characters', {}, function(result)
        if result and result[1] then
            local data = {
                cash = result[1].total_cash or 0,
                bank = result[1].total_bank or 0,
                dirty_money = result[1].total_dirty or 0,
                total = (result[1].total_cash or 0) + (result[1].total_bank or 0) + (result[1].total_dirty or 0)
            }
            
            TriggerEvent('ec:server:economyBalance', data)
            return data
        end
    end)
end

-- Player Money Functions (Enhanced)
function ECEconomy.AddMoney(source, amount, moneyType, reason, tax)
    if not ECPlayer.AddMoney(source, amount, moneyType, reason) then
        return false
    end
    
    -- Apply tax if specified
    if tax and tax > 0 and moneyType == ECEconomy.MoneyTypes.BANK then
        local taxAmount = math.floor(amount * (tax / 100))
        if taxAmount > 0 then
            ECPlayer.RemoveMoney(source, taxAmount, moneyType, 'Tax: ' .. reason)
            TriggerEvent('ec:server:taxCollected', source, taxAmount, reason)
        end
    end
    
    -- Log transaction
    TriggerEvent('ec:server:transactionLogged', source, ECEconomy.TransactionTypes.ADD_MONEY, amount, moneyType, reason)
    
    return true
end

function ECEconomy.RemoveMoney(source, amount, moneyType, reason)
    if not ECPlayer.RemoveMoney(source, amount, moneyType, reason) then
        return false
    end
    
    -- Log transaction
    TriggerEvent('ec:server:transactionLogged', source, ECEconomy.TransactionTypes.REMOVE_MONEY, -amount, moneyType, reason)
    
    return true
end

function ECEconomy.TransferMoney(sourcePlayer, targetPlayer, amount, moneyType, reason)
    local sourceData = EC.Players[sourcePlayer]
    local targetData = EC.Players[targetPlayer]
    
    if not sourceData or not targetData or not sourceData.character or not targetData.character then
        return false
    end
    
    -- Check if source has enough money
    if not ECPlayer.RemoveMoney(sourcePlayer, amount, moneyType, reason) then
        return false
    end
    
    -- Add money to target
    if not ECPlayer.AddMoney(targetPlayer, amount, moneyType, reason) then
        -- Rollback if adding to target fails
        ECPlayer.AddMoney(sourcePlayer, amount, moneyType, 'Rollback: ' .. reason)
        return false
    end
    
    -- Log transactions
    TriggerEvent('ec:server:transactionLogged', sourcePlayer, ECEconomy.TransactionTypes.TRANSFER_MONEY, -amount, moneyType, 'Transfer to ' .. targetData.character.firstname .. ' ' .. targetData.character.lastname)
    TriggerEvent('ec:server:transactionLogged', targetPlayer, ECEconomy.TransactionTypes.TRANSFER_MONEY, amount, moneyType, 'Transfer from ' .. sourceData.character.firstname .. ' ' .. sourceData.character.lastname)
    
    -- Notify players
    ECFunctions.Notify(sourcePlayer, 'You transferred ' .. ECUtils.FormatMoney(amount) .. ' to ' .. targetData.character.firstname .. ' ' .. targetData.character.lastname, 'success')
    ECFunctions.Notify(targetPlayer, 'You received ' .. ECUtils.FormatMoney(amount) .. ' from ' .. sourceData.character.firstname .. ' ' .. sourceData.character.lastname, 'success')
    
    return true
end

-- Business System
ECEconomy.Businesses = {}

function ECEconomy.LoadBusinesses()
    ECDatabase.GetBusinesses(function(businesses)
        for _, business in pairs(businesses) do
            ECEconomy.Businesses[business.id] = {
                id = business.id,
                name = business.name,
                owner = business.owner,
                employees = json.decode(business.employees or '{}'),
                balance = business.balance,
                type = business.type,
                data = json.decode(business.data or '{}')
            }
        end
        
        ECUtils.Log('info', 'Loaded businesses', {count = #businesses})
    end)
end

function ECEconomy.GetBusiness(businessId)
    return ECEconomy.Businesses[businessId]
end

function ECEconomy.GetPlayerBusinesses(source)
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return {} end
    
    local businesses = {}
    for _, business in pairs(ECEconomy.Businesses) do
        if business.owner == playerData.character.id then
            table.insert(businesses, business)
        end
    end
    
    return businesses
end

function ECEconomy.IsBusinessEmployee(businessId, characterId)
    local business = ECEconomy.GetBusiness(businessId)
    if not business then return false end
    
    if business.owner == characterId then return true end
    
    for _, employeeId in pairs(business.employees) do
        if employeeId == characterId then return true end
    end
    
    return false
end

function ECEconomy.AddBusinessIncome(businessId, amount, reason)
    local business = ECEconomy.GetBusiness(businessId)
    if not business then return false end
    
    business.balance = business.balance + amount
    
    -- Update database
    ECDatabase.UpdateBusiness(businessId, {balance = business.balance}, function(success)
        if success then
            TriggerEvent('ec:server:businessTransaction', businessId, amount, reason)
            ECUtils.Log('info', 'Business income added', {business = businessId, amount = amount, reason = reason})
        end
    end)
    
    return true
end

function ECEconomy.RemoveBusinessExpense(businessId, amount, reason)
    local business = ECEconomy.GetBusiness(businessId)
    if not business then return false end
    
    if business.balance < amount then return false end
    
    business.balance = business.balance - amount
    
    -- Update database
    ECDatabase.UpdateBusiness(businessId, {balance = business.balance}, function(success)
        if success then
            TriggerEvent('ec:server:businessTransaction', businessId, -amount, reason)
            ECUtils.Log('info', 'Business expense removed', {business = businessId, amount = amount, reason = reason})
        end
    end)
    
    return true
end

-- ATM System
ECEconomy.ATMs = {
    vector3(147.4, -1035.8, 29.3),
    vector3(145.9, -1035.2, 29.3),
    vector3(112.4, -819.8, 31.3),
    vector3(112.9, -818.7, 31.3),
    vector3(119.9, -880.5, 31.1),
    vector3(285.2, 143.5, 104.2),
    vector3(157.7, 233.5, 106.6),
    vector3(-164.2, 233.5, 94.9),
    vector3(-1827.04, 785.5, 138.0),
    vector3(-386.733, 6045.9, 31.5),
    vector3(-284.037, 6224.385, 31.187),
    vector3(-135.165, 6365.738, 31.101),
    vector3(-110.753, 6467.703, 31.784),
    vector3(-94.9690, 6455.301, 31.784),
    vector3(155.4300, 6641.991, 31.784),
    vector3(174.6720, 6637.218, 31.784),
    vector3(1703.138, 6426.783, 32.730),
    vector3(1735.114, 6411.035, 35.164)
}

-- Tax System
ECEconomy.TaxRates = {
    income = 0.15, -- 15% income tax
    sales = 0.08,  -- 8% sales tax
    property = 0.02, -- 2% property tax
    business = 0.12  -- 12% business tax
}

function ECEconomy.CalculateTax(amount, taxType)
    local rate = ECEconomy.TaxRates[taxType] or 0
    return math.floor(amount * rate)
end

function ECEconomy.ApplyIncomeTax(source, amount)
    local taxAmount = ECEconomy.CalculateTax(amount, 'income')
    if taxAmount > 0 then
        ECPlayer.RemoveMoney(source, taxAmount, ECEconomy.MoneyTypes.BANK, 'Income Tax')
        TriggerEvent('ec:server:taxCollected', source, taxAmount, 'Income Tax')
        return taxAmount
    end
    return 0
end

-- Banking System
ECEconomy.Banks = {
    {
        name = 'Fleeca Bank',
        coords = vector3(150.266, -1040.203, 29.374),
        blip = {sprite = 108, color = 2, scale = 0.8}
    },
    {
        name = 'Fleeca Bank',
        coords = vector3(-1212.980, -330.841, 37.787),
        blip = {sprite = 108, color = 2, scale = 0.8}
    },
    {
        name = 'Fleeca Bank',
        coords = vector3(-2962.582, 482.627, 15.703),
        blip = {sprite = 108, color = 2, scale = 0.8}
    },
    {
        name = 'Fleeca Bank',
        coords = vector3(-112.202, 6469.295, 31.626),
        blip = {sprite = 108, color = 2, scale = 0.8}
    },
    {
        name = 'Fleeca Bank',
        coords = vector3(314.187, -278.621, 54.170),
        blip = {sprite = 108, color = 2, scale = 0.8}
    },
    {
        name = 'Fleeca Bank',
        coords = vector3(-351.534, -49.529, 49.042),
        blip = {sprite = 108, color = 2, scale = 0.8}
    },
    {
        name = 'Pacific Standard Bank',
        coords = vector3(241.727, 220.706, 106.286),
        blip = {sprite = 108, color = 5, scale = 1.0}
    }
}

-- Salary/Paycheck System
function ECEconomy.ProcessPaychecks()
    for source, playerData in pairs(EC.Players) do
        if playerData.character and playerData.character.job then
            local job = Jobs[playerData.character.job.name]
            if job and job.grades[playerData.character.job.grade] then
                local payment = job.grades[playerData.character.job.grade].payment
                if payment > 0 then
                    -- Calculate tax
                    local taxAmount = ECEconomy.CalculateTax(payment, 'income')
                    local netPayment = payment - taxAmount
                    
                    ECPlayer.AddMoney(source, netPayment, ECEconomy.MoneyTypes.BANK, 'Paycheck - ' .. job.label)
                    
                    if taxAmount > 0 then
                        TriggerEvent('ec:server:taxCollected', source, taxAmount, 'Payroll Tax')
                    end
                    
                    ECFunctions.Notify(source, 'Paycheck received: ' .. ECUtils.FormatMoney(netPayment) .. (taxAmount > 0 and ' (Tax: ' .. ECUtils.FormatMoney(taxAmount) .. ')' or ''), 'success')
                    
                    ECUtils.Log('info', 'Paycheck processed', {
                        source = source,
                        job = job.label,
                        gross = payment,
                        tax = taxAmount,
                        net = netPayment
                    })
                end
            end
        end
    end
end

-- Network Events
RegisterNetEvent('ec:server:transferMoney', function(targetSource, amount, moneyType)
    local source = source
    if not targetSource or not amount or amount <= 0 then return end
    
    ECEconomy.TransferMoney(source, targetSource, amount, moneyType or ECEconomy.MoneyTypes.CASH, 'Player Transfer')
end)

RegisterNetEvent('ec:server:depositMoney', function(amount)
    local source = source
    if not amount or amount <= 0 then return end
    
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return end
    
    if playerData.character.cash >= amount then
        ECPlayer.RemoveMoney(source, amount, ECEconomy.MoneyTypes.CASH, 'Bank Deposit')
        ECPlayer.AddMoney(source, amount, ECEconomy.MoneyTypes.BANK, 'Bank Deposit')
        
        ECFunctions.Notify(source, 'Deposited ' .. ECUtils.FormatMoney(amount), 'success')
    else
        ECFunctions.Notify(source, 'Insufficient cash', 'error')
    end
end)

RegisterNetEvent('ec:server:withdrawMoney', function(amount)
    local source = source
    if not amount or amount <= 0 then return end
    
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return end
    
    if playerData.character.bank >= amount then
        ECPlayer.RemoveMoney(source, amount, ECEconomy.MoneyTypes.BANK, 'Bank Withdrawal')
        ECPlayer.AddMoney(source, amount, ECEconomy.MoneyTypes.CASH, 'Bank Withdrawal')
        
        ECFunctions.Notify(source, 'Withdrew ' .. ECUtils.FormatMoney(amount), 'success')
    else
        ECFunctions.Notify(source, 'Insufficient bank balance', 'error')
    end
end)

-- Business Events
RegisterNetEvent('ec:server:withdrawBusinessMoney', function(businessId, amount)
    local source = source
    local playerData = EC.Players[source]
    if not playerData or not playerData.character then return end
    
    local business = ECEconomy.GetBusiness(businessId)
    if not business then
        ECFunctions.Notify(source, 'Business not found', 'error')
        return
    end
    
    -- Check if player is owner
    if business.owner ~= playerData.character.id then
        ECFunctions.Notify(source, 'You are not the owner of this business', 'error')
        return
    end
    
    if business.balance >= amount then
        ECEconomy.RemoveBusinessExpense(businessId, amount, 'Owner Withdrawal')
        ECPlayer.AddMoney(source, amount, ECEconomy.MoneyTypes.BANK, 'Business Withdrawal: ' .. business.name)
        
        ECFunctions.Notify(source, 'Withdrew ' .. ECUtils.FormatMoney(amount) .. ' from ' .. business.name, 'success')
    else
        ECFunctions.Notify(source, 'Insufficient business balance', 'error')
    end
end)

-- Commands
EC.RegisterCommand('givemoney', function(source, args)
    if #args < 3 then
        ECFunctions.Notify(source, 'Usage: /givemoney [player_id] [amount] [money_type]', 'error')
        return
    end
    
    local targetSource = tonumber(args[1])
    local amount = tonumber(args[2])
    local moneyType = args[3] or ECEconomy.MoneyTypes.CASH
    
    if not targetSource or not EC.Players[targetSource] then
        ECFunctions.Notify(source, 'Player not found', 'error')
        return
    end
    
    if not amount or amount <= 0 then
        ECFunctions.Notify(source, 'Invalid amount', 'error')
        return
    end
    
    ECPlayer.AddMoney(targetSource, amount, moneyType, 'Admin Give Money')
    ECFunctions.Notify(source, 'Gave ' .. ECUtils.FormatMoney(amount) .. ' to player ' .. targetSource, 'success')
    
end, 'admin', 'Give money to a player')

EC.RegisterCommand('setmoney', function(source, args)
    if #args < 3 then
        ECFunctions.Notify(source, 'Usage: /setmoney [player_id] [amount] [money_type]', 'error')
        return
    end
    
    local targetSource = tonumber(args[1])
    local amount = tonumber(args[2])
    local moneyType = args[3] or ECEconomy.MoneyTypes.CASH
    
    if not targetSource or not EC.Players[targetSource] then
        ECFunctions.Notify(source, 'Player not found', 'error')
        return
    end
    
    if not amount or amount < 0 then
        ECFunctions.Notify(source, 'Invalid amount', 'error')
        return
    end
    
    ECPlayer.SetMoney(targetSource, amount, moneyType, 'Admin Set Money')
    ECFunctions.Notify(source, 'Set ' .. moneyType .. ' to ' .. ECUtils.FormatMoney(amount) .. ' for player ' .. targetSource, 'success')
    
end, 'admin', 'Set player money amount')

-- Initialize economy system
CreateThread(function()
    ECEconomy.LoadBusinesses()
end)

-- Export economy functions
exports('AddMoney', ECEconomy.AddMoney)
exports('RemoveMoney', ECEconomy.RemoveMoney)
exports('TransferMoney', ECEconomy.TransferMoney)
exports('GetBusiness', ECEconomy.GetBusiness)
exports('AddBusinessIncome', ECEconomy.AddBusinessIncome)
exports('RemoveBusinessExpense', ECEconomy.RemoveBusinessExpense)