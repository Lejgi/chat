ESX = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
    end
end)

local function harvest(data)
    if lib.progressBar({duration = Config.Progress.Harvest, label = data.label}) then
        TriggerServerEvent('farm_job:harvest', data.item, data.count)
    end
end

local function processItem(data)
    if lib.progressBar({duration = Config.Progress.Process, label = data.label}) then
        TriggerServerEvent('farm_job:process', data.from, data.to, data.count)
    end
end

local function cookItem(data)
    if lib.progressBar({duration = Config.Progress.Cook, label = data.label}) then
        TriggerServerEvent('farm_job:cook', data.items, data.result, data.count)
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
end

CreateThread(setupTargets)
