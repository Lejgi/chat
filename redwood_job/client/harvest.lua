
local Config = Config or {}
local ESX = exports["es_extended"]:getSharedObject()

local spawnedPlants = {}

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)



function SpawnPlants()
    if not ESX or not ESX.GetPlayerData then
        return
    end

    local playerData = ESX.GetPlayerData()
    if not playerData or not playerData.job then
        return
    end

    if playerData.job.name ~= Config.RequiredJob then
        return
    end

    RequestModel(Config.PlantModel)
    while not HasModelLoaded(Config.PlantModel) do
        Wait(10)
    end

    for i = 1, Config.MaxPlants do
        local offsetX = math.random(-Config.HarvestRadius, Config.HarvestRadius)
        local offsetY = math.random(-Config.HarvestRadius, Config.HarvestRadius)
        local pos = vector3(Config.HarvestCenter.x + offsetX, Config.HarvestCenter.y + offsetY, Config.HarvestCenter.z)
        local _, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, 0)

        local plant = CreateObject(Config.PlantModel, pos.x, pos.y, groundZ, false, false, false)
        PlaceObjectOnGroundProperly(plant)
        FreezeEntityPosition(plant, true)

        exports.ox_target:addLocalEntity(plant, {
            {
                icon = "fas fa-seedling",
                label = "Sesbírat tabák",
                canInteract = function(entity, distance, coords, name)
                    return ESX.GetPlayerData().job.name == Config.RequiredJob
                end,
                onSelect = function()
                    local ped = cache.ped
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                    Wait(Config.HarvestTime or 5000)
                    ClearPedTasks(ped)
                    TriggerServerEvent("redwood:harvestPlant")
                    DeleteEntity(plant)
                end
            }
        })

        table.insert(spawnedPlants, plant)

        
    end
end

local nearZone = false
local cooldown = false

CreateThread(function()
    while true do
        Wait(1500)

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local distance = #(coords - Config.HarvestCenter)

        if distance < Config.HarvestRadius and not nearZone and not cooldown then
            nearZone = true
            cooldown = true
            SpawnPlants()

            SetTimeout(30000, function()
                cooldown = false
            end)
        elseif distance >= Config.HarvestRadius then
            nearZone = false
        end
    end
end)