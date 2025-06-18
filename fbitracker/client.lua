-- Upravený client.lua - kompletní funkční verze

local ESX = exports['es_extended']:getSharedObject()
local activeBlips = {}
local trackingPlayers = {}

-- Enumerate Vehicles helper
function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        if not handle or handle == 0 then
            return
        end
        local finished = false
        repeat
            coroutine.yield(vehicle)
            finished, vehicle = FindNextVehicle(handle)
        until not finished
        EndFindVehicle(handle)
    end)
end

-- Skillcheck minihra pro odstranění trackeru
function startTrackerRemovalMinigame(type, id)
    local success = lib.skillCheck({'easy', 'easy', 'medium'}, {'w', 'a', 's', 'd'})
    if success then
        TriggerServerEvent('fbi:completeTrackerRemoval', type, id)
    else
        lib.notify({title = 'GPS Detector', description = '❌ Nepodařilo se odstranit tracker!', type = 'error'})
    end
end



-- Instalace GPS na hráče commandem
RegisterCommand('installgps', function()
    local player = ESX.GetPlayerData()
    if player.job.name ~= Config.RequiredJob then
        lib.notify({title = 'FBI', description = '🚫 Nemáš oprávnění instalovat GPS!', type = 'error'})
        return
    end

    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local nearbyPlayers = {}

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local ped = GetPlayerPed(playerId)
            local coords = GetEntityCoords(ped)
            if #(myCoords - coords) <= 3.0 then
                table.insert(nearbyPlayers, { serverId = GetPlayerServerId(playerId), name = GetPlayerName(playerId) })
            end
        end
    end

    if #nearbyPlayers == 0 then
        lib.notify({title = 'FBI', description = '🚫 Nikdo v blízkosti.', type = 'error'})
        return
    end

    local options = {}
    for _, player in pairs(nearbyPlayers) do
        table.insert(options, {
            title = ('🎯 [%s] %s'):format(player.serverId, player.name),
            onSelect = function()
                TriggerServerEvent('fbi:installGpsTracker', player.serverId)
            end
        })
    end

    lib.registerContext({
        id = 'fbi_install_gps_menu',
        title = '📡 Instalace GPS Trackeru',
        options = options
    })
    lib.showContext('fbi_install_gps_menu')
end)

-- Instalace GPS na vozidla přes ox_target
CreateThread(function()
    exports['ox_target']:addGlobalVehicle({
        {
            name = 'install_gps_vehicle',
            icon = 'fa-solid fa-location-crosshairs',
            label = '🚗 Nainstalovat GPS Tracker na vozidlo',
            canInteract = function(entity)
                local player = ESX.GetPlayerData()
                return player.job.name == Config.RequiredJob
            end,
            onSelect = function(data)
                local vehicle = data.entity
                local plate = GetVehicleNumberPlateText(vehicle)
                TriggerServerEvent('fbi:installGpsTrackerVehicle', plate)
            end
        }
    })
end)

-- Hlavní tablet
lib.registerContext({
    id = 'fbi_tablet_main',
    title = '📂 FBI Tablet',
    options = {
        {
            title = '📂 Sledování osob',
            onSelect = function()
                TriggerServerEvent('fbi:getActiveGpsTaps', 'gps_person')
            end
        },
        {
            title = '🚗 Sledování vozidel',
            onSelect = function()
                TriggerServerEvent('fbi:getActiveGpsTaps', 'gps_vehicle')
            end
        }
    }
})

-- Target na otevření tabletu a instalaci
CreateThread(function()
    exports['ox_target']:addBoxZone({
        coords = Config.TabletZone.coords,
        size = Config.TabletZone.size,
        rotation = Config.TabletZone.rotation,
        debug = false,
        options = {
            {
                name = 'open_fbi_tablet',
                icon = 'fa-solid fa-tablet-screen-button',
                label = '📂 Otevřít FBI Tablet',
                canInteract = function()
                    local player = ESX.GetPlayerData()
                    return player.job.name == Config.RequiredJob
                end,
                onSelect = function()
                    lib.showContext('fbi_tablet_main')
                end
            }
        }
    })

    exports['ox_target']:addGlobalPlayer({
        {
            name = 'install_gps',
            icon = 'fa-solid fa-location-crosshairs',
            label = '📡 Nainstalovat GPS Tracker',
            canInteract = function()
                local player = ESX.GetPlayerData()
                return player.job.name == Config.RequiredJob
            end,
            onSelect = function(data)
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                TriggerServerEvent('fbi:installGpsTracker', targetId)
            end
        }
    })
end)

RegisterCommand('fbitablet', function()
    local player = ESX.GetPlayerData()
    if player.job.name == Config.RequiredJob then
        lib.showContext('fbi_tablet_main')
    else
        lib.notify({title = 'FBI', description = '🚫 Nemáš přístup k FBI Tabletu!', type = 'error'})
    end
end)

-- Správa blipů
RegisterNetEvent('fbi:updatePlayerTrackerBlip', function(trackerId, x, y, z, type)
    if activeBlips[trackerId] then
        SetBlipCoords(activeBlips[trackerId], x, y, z)
    else
        local blip = AddBlipForCoord(x, y, z)

        if type == 'gps_vehicle' then
            SetBlipSprite(blip, 225)
            SetBlipColour(blip, 2)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('🚗 Sledované vozidlo')
        else
            SetBlipSprite(blip, 480)
            SetBlipColour(blip, 1)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('🎯 Sledovaná osoba')
        end

        EndTextCommandSetBlipName(blip)
        SetBlipScale(blip, 0.85)
        SetBlipCategory(blip, 7)
        activeBlips[trackerId] = blip
    end
end)

RegisterNetEvent('fbi:removePlayerTrackerBlip', function(trackerId)
    if activeBlips[trackerId] then
        RemoveBlip(activeBlips[trackerId])
        activeBlips[trackerId] = nil
    end
end)

-- Zobrazení obsahu tabletu
RegisterNetEvent('fbi:showTablet', function(taps, tapType)
    if not taps or type(taps) ~= 'table' then return end
    tapType = tapType or 'gps_person'

    local options = {}
    for _, tap in pairs(taps) do
        local title = tapType == 'gps_person'
            and ('🎯 %s %s'):format(tap.firstname or '', tap.lastname or '')
            or ('🚗 Vozidlo: %s'):format(tap.target_charid or 'Neznámé')

        table.insert(options, {
            title = title,
            description = 'Klikni pro operace',
            onSelect = function()
                lib.registerContext({
                    id = 'fbi_gps_options_' .. tap.id,
                    title = '📡 Operace s GPS',
                    options = {
                        {
                            title = '📍 Sledovat',
                            onSelect = function()
                                if tapType == 'gps_person' then
                                    TriggerServerEvent('fbi:startTrackingPlayer', tap.target_charid)
                                else
                                    TriggerServerEvent('fbi:startTrackingVehicle', tap.target_charid)
                                end
                            end
                        },
                        {
                            title = '🛑 Ukončit sledování',
                            onSelect = function()
                                TriggerServerEvent('fbi:stopTrackingPlayer', tap.target_charid)
                                TriggerEvent('fbi:removePlayerTrackerBlip', tap.target_charid)
                            end
                        },
                        {
                            title = '🗑️ Odstranit tracker',
                            onSelect = function()
                                TriggerServerEvent('fbi:deleteGpsTracker', tap.id, tap.target_charid)
                                TriggerEvent('fbi:removePlayerTrackerBlip', tap.target_charid)
                                lib.notify({title = 'FBI', description = '✅ Tracker odstraněn.', type = 'success'})
                            end
                        }
                    }
                })
                lib.showContext('fbi_gps_options_' .. tap.id)
            end
        })
    end

    lib.registerContext({
        id = 'fbi_tap_tablet_' .. tapType,
        title = tapType == 'gps_person' and '📂 Sledování osob' or '🚗 Sledování vozidel',
        options = options
    })
    lib.showContext('fbi_tap_tablet_' .. tapType)
end)

-- Fáze 2: GPS Detector
RegisterNetEvent('fbi:scanNearbyVehicle', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local nearbyVehicle = nil

    for vehicle in EnumerateVehicles() do
        if #(coords - GetEntityCoords(vehicle)) <= Config.DetectorRadius then
            nearbyVehicle = vehicle
            break
        end
    end

    if nearbyVehicle then
        local plate = GetVehicleNumberPlateText(nearbyVehicle)
        startTrackerRemovalMinigame('vehicle', plate)
    else
        lib.notify({title = 'GPS Detector', description = '❌ Žádné vozidlo poblíž.', type = 'error'})
    end
end)



exports('useGpsDetector', function(data, slot)
    lib.registerContext({
        id = 'gps_detector_menu',
        title = '🛰️ Vyber akci s GPS Detektorem',
        options = {
            {
                title = '🎯 Skenuj hráče',
                onSelect = function()
                    TriggerServerEvent('fbi:checkTrackerOnPlayer')
                end
            },
            {
                title = '🚗 Skenuj vozidlo',
                onSelect = function()
                    TriggerEvent('fbi:scanNearbyVehicle')
                end
            }
        }
    })
    lib.showContext('gps_detector_menu')
end)

RegisterNetEvent('fbi:requestInstallWebhookLocation', function(type, id)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = streetHash and GetStreetNameFromHashKey(streetHash) or 'Neznámá'

    -- Odešle jen název ulice (žádné souřadnice)
    TriggerServerEvent('fbi:finalizeInstallWebhook', type, id, street)
end)




RegisterNetEvent('fbi:getLocationForWebhook', function(type, id)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = streetHash and GetStreetNameFromHashKey(streetHash) or 'Neznámá'

    -- Jen ulice bez souřadnic
    TriggerServerEvent('fbi:sendTrackerWebhookFromClient', type, id, street)
end)




RegisterNetEvent('fbi:showTrackerFound', function(type)
    lib.registerContext({
        id = 'fbi_tracker_found',
        title = '🔍 Tracker Detected',
        options = {
            {
                title = '❌ Pokusit se odstranit tracker',
                onSelect = function()
                    startTrackerRemovalMinigame(type, nil)
                end
            }
        }
    })
    lib.showContext('fbi_tracker_found')
end)
