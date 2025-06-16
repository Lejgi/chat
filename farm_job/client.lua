ESX = nil
local PlayerData = {}

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
    end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

local function hasJob()
    return PlayerData.job and PlayerData.job.name == Config.Job
end

local function harvest(data)
    if not hasJob() then
        lib.notify({type = 'error', description = 'You are not a farmer'})
        return
    end
    if lib.progressBar({duration = Config.Progress.Harvest, label = data.label}) then
        TriggerServerEvent('farm_job:harvest', data.item, data.count)
    end
end

local function processItem(data)
    if not hasJob() then
        lib.notify({type = 'error', description = 'You are not a farmer'})
        return
    end
    if lib.progressBar({duration = Config.Progress.Process, label = data.label}) then
        TriggerServerEvent('farm_job:process', data.from, data.to, data.count)
    end
end

local function cookItem(data)
    if not hasJob() then
        lib.notify({type = 'error', description = 'You are not a farmer'})
        return
    end
    if lib.progressBar({duration = Config.Progress.Cook, label = data.label}) then
        TriggerServerEvent('farm_job:cook', data.items, data.result, data.count)
    end
end

local function sellItem(data)
    if not hasJob() then
        lib.notify({type = 'error', description = 'You are not a farmer'})
        return
    end
    if lib.progressBar({duration = Config.Progress.Sell, label = data.label}) then
        TriggerServerEvent('farm_job:sell', data.item, data.price)
    end
end

local function setupTargets()
    for i, data in pairs(Config.HarvestPoints) do
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = vec3(2, 2, 2),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'farm_harvest_' .. i,
                    icon = 'fa-solid fa-seedling',
                    label = data.label,
                    onSelect = function()
                        harvest(data)
                    end
                }
            }
        })
    end

    for i, data in pairs(Config.ProcessPoints) do
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = vec3(2, 2, 2),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'farm_process_' .. i,
                    icon = 'fa-solid fa-snowflake',
                    label = data.label,
                    onSelect = function()
                        processItem(data)
                    end
                }
            }
        })
    end

    for i, data in pairs(Config.CookPoints) do
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = vec3(2, 2, 2),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'farm_cook_' .. i,
                    icon = 'fa-solid fa-utensils',
                    label = data.label,
                    onSelect = function()
                        cookItem(data)
                    end
                }
            }
        })
    end

    for i, data in pairs(Config.SellPoints) do
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = vec3(2, 2, 2),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'farm_sell_' .. i,
                    icon = 'fa-solid fa-dollar-sign',
                    label = data.label,
                    onSelect = function()
                        sellItem(data)
                    end
                }
            }
        })
    end
end

CreateThread(setupTargets)
