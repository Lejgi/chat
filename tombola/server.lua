local oxmysql = exports.oxmysql
ESX = exports['es_extended']:getSharedObject()

local function _T(key, ...)
    local locale = Locales[Config.Locale] or {}
    local str = locale[key] or key
    if ... then
        return str:format(...)
    end
    return str
end

lib.callback.register('tombola:canOpen', function(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { allowed = false } end

    local isBoss = xPlayer.job.name == job and xPlayer.job.grade_name == 'boss'

    local result = oxmysql:executeSync('SELECT ticketPrice FROM lottery_jobs WHERE job = ?', { job })
    local price = result[1] and tonumber(result[1].ticketPrice) or (Config.Lotteries[job] and Config.Lotteries[job].ticketPrice or 100)

    return {
        allowed = true,
        isBoss = isBoss,
        ticketPrice = price,
    }
end)

lib.callback.register('tombola:getPlayerRanges', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= data.job or xPlayer.job.grade_name ~= 'boss' then
        return {}
    end

    return exports.oxmysql:executeSync([[
        SELECT range_start, range_end
        FROM lottery_tickets
        WHERE job = ? AND name = ?
        ORDER BY range_start ASC
    ]], { data.job, data.name })
end)


RegisterNetEvent('tombola:buyTickets', function(job, count, method)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local result = oxmysql:executeSync('SELECT ticketPrice FROM lottery_jobs WHERE job = ?', { job })
    local pricePer = result[1] and tonumber(result[1].ticketPrice) or (Config.Lotteries[job] and Config.Lotteries[job].ticketPrice or 100)
    local price = pricePer * count

    if method == 'cash' and xPlayer.getMoney() < price then return end
    if method == 'bank' and xPlayer.getAccount('bank').money < price then return end

    local identifier = xPlayer.identifier
    local name = xPlayer.getName()

    oxmysql:execute('SELECT range_end FROM lottery_tickets WHERE job = ? ORDER BY range_end DESC LIMIT 1', {job}, function(result)
        local last_end = result[1] and result[1].range_end or 0
        local range_start = last_end + 1
        local range_end = range_start + count - 1

        oxmysql:insert('INSERT INTO lottery_tickets (identifier, name, range_start, range_end, total_paid, method, job) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            identifier, name, range_start, range_end, price, method, job
        })

        if method == 'cash' then
            xPlayer.removeMoney(price)
        else
            xPlayer.removeAccountMoney('bank', price)
        end

        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. job, function(account)
            if account then
                account.addMoney(price)
            end
        end)

        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = _T('bought_tickets', count)
        })
    end)
end)

RegisterNetEvent('tombola:reset', function(job)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or xPlayer.job.name ~= job then return end

    oxmysql:execute('DELETE FROM lottery_tickets WHERE job = ?', {job})
    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = _T('resetting')
    })
end)

lib.callback.register('tombola:getPrizePool', function(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= job or xPlayer.job.grade_name ~= 'boss' then return 0 end

    local result = oxmysql:executeSync('SELECT SUM(total_paid) as total FROM lottery_tickets WHERE job = ?', { job })
    local pool = result and result[1] and result[1].total or 0
    return pool or 0
end)

lib.callback.register('tombola:getPlayerSummary', function(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= job or xPlayer.job.grade_name ~= 'boss' then return {} end

    local result = oxmysql:executeSync([[
        SELECT name, SUM(range_end - range_start + 1) as total
        FROM lottery_tickets
        WHERE job = ?
        GROUP BY name
        ORDER BY total DESC
    ]], { job })

    return result or {}
end)

RegisterNetEvent('tombola:setTicketPrice', function(job, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if xPlayer.job.name ~= job or xPlayer.job.grade_name ~= 'boss' then return end

    price = tonumber(price)
    if not price or price < 1 then return end

    oxmysql:execute([[INSERT INTO lottery_jobs (job, ticketPrice) VALUES (?, ?) ON DUPLICATE KEY UPDATE ticketPrice = ?]], {
        job, price, price
    })

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = _T('price_set', price)
    })

    TriggerClientEvent('tombola:updateTicketPrice', src, price)
end)

lib.callback.register('tombola:getTickets', function(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer and xPlayer.identifier
    if not identifier then return {} end

    local results = oxmysql:executeSync('SELECT range_start, range_end FROM lottery_tickets WHERE identifier = ? AND job = ?', {identifier, job})
    return results
end)

lib.callback.register('tombola:getAllTickets', function(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= job or xPlayer.job.grade_name ~= 'boss' then
        return {}
    end

    local results = oxmysql:executeSync('SELECT name, range_start, range_end FROM lottery_tickets WHERE job = ?', { job })
    return results or {}
end)
