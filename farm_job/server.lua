ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local function hasItems(src, items)
    for _, data in pairs(items) do
        local count = exports.ox_inventory:Search(src, 'count', data.item)
        if count < data.count then
            return false
        end
    end
    return true
end

local function hasJob(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.Job
end

RegisterNetEvent('farm_job:harvest', function(item, count)
    local src = source
    if not hasJob(src) then return end
    exports.ox_inventory:AddItem(src, item, count)
end)

RegisterNetEvent('farm_job:process', function(from, to, count)
    local src = source
    if not hasJob(src) then return end
    if exports.ox_inventory:RemoveItem(src, from, count) then
        exports.ox_inventory:AddItem(src, to, count)
    end
end)

RegisterNetEvent('farm_job:cook', function(items, result, count)
    local src = source
    if not hasJob(src) then return end
    if not hasItems(src, items) then return end

    for _, item in pairs(items) do
        exports.ox_inventory:RemoveItem(src, item.item, item.count)
    end
    exports.ox_inventory:AddItem(src, result, count)
end)

RegisterNetEvent('farm_job:sell', function(item, price)
    local src = source
    if not hasJob(src) then return end
    if exports.ox_inventory:RemoveItem(src, item, 1) then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addMoney(price)
        end
    end
end)
