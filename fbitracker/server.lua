
local ESX = exports['es_extended']:getSharedObject()
local activeTrackers = {}

function getSourceFromIdentifier(identifier)
    for _, id in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(id)
        if xPlayer and xPlayer.identifier == identifier then
            return id
        end
    end
    return nil
end



RegisterNetEvent('fbi:startTrackingPlayer', function(targetCharId)
    local src = source
    activeTrackers[src] = activeTrackers[src] or {}
    table.insert(activeTrackers[src], targetCharId)
end)

RegisterNetEvent('fbi:stopTrackingPlayer', function(targetCharId)
    local src = source
    if activeTrackers[src] then
        for k,v in pairs(activeTrackers[src]) do
            if v == targetCharId then
                table.remove(activeTrackers[src], k)
                break
            end
        end
    end

    local target = getSourceFromIdentifier(targetCharId)
    if target then
        TriggerClientEvent('fbi:removePlayerTrackerBlip', src, target)
    end
end)

RegisterNetEvent('fbi:deleteGpsTracker', function(tapId, targetCharId)
    exports.oxmysql:execute('DELETE FROM fbi_taps WHERE id = ?', { tapId })
    for agentId, targets in pairs(activeTrackers) do
        for i, v in ipairs(targets) do
            if v == targetCharId then
                table.remove(targets, i)
                break
            end
        end
    end
end)

RegisterNetEvent('fbi:installGpsTrackerVehicle', function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local item = xPlayer.getInventoryItem(Config.GpsTrackerItem)
    if item and item.count > 0 then
        exports.oxmysql:insert('INSERT INTO fbi_taps (target_charid, agent_id, tap_type, active) VALUES (?, ?, ?, 1)', {
            plate, src, 'gps_vehicle'
        })

        local coords = GetEntityCoords(GetPlayerPed(src))
        TriggerClientEvent('fbi:getLocationForWebhook', src, 'install', {
            agent = xPlayer.getName(),
            target = 'SPZ: ' .. plate, -- nebo target.getName()..(...)
            type = 'gps_vehicle' -- nebo 'gps_person'
        })
        
        xPlayer.removeInventoryItem(Config.GpsTrackerItem, 1)
        TriggerClientEvent('ox_lib:notify', src, {title = 'FBI', description = '✅ GPS Tracker nainstalován na vozidlo!', type = 'success'})
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'FBI', description = '🚫 Nemáš GPS tracker!', type = 'error'})
    end
end)

RegisterNetEvent('fbi:startTrackingVehicle', function(plate)
    local src = source

    for _, veh in ipairs(GetAllVehicles()) do
        if DoesEntityExist(veh) then
            local vehPlate = GetVehicleNumberPlateText(veh)
            if vehPlate == plate then
                local coords = GetEntityCoords(veh)
                TriggerClientEvent('fbi:updatePlayerTrackerBlip', src, plate, coords.x, coords.y, coords.z, 'gps_vehicle')
                return
            end
        end
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'FBI',
        description = '🚗 Vozidlo nebylo nalezeno!',
        type = 'error'
    })
end)

RegisterNetEvent('fbi:getActiveGpsTaps', function(tapType)
    local src = source
    tapType = tapType or 'gps_person'

    if tapType == 'gps_vehicle' then
        exports.oxmysql:execute('SELECT * FROM fbi_taps WHERE tap_type = "gps_vehicle" AND active = 1', {}, function(taps)
            if taps and #taps > 0 then
                TriggerClientEvent('fbi:showTablet', src, taps, 'gps_vehicle')
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'FBI',
                    description = '🚗 Žádné aktivní GPS trackery na vozidla.',
                    type = 'info'
                })
            end
        end)
    else
        exports.oxmysql:execute([[
            SELECT fbi_taps.*, users.firstname, users.lastname 
            FROM fbi_taps 
            JOIN users 
                ON fbi_taps.target_charid COLLATE utf8mb4_unicode_ci = users.identifier COLLATE utf8mb4_unicode_ci 
            WHERE fbi_taps.active = 1 
              AND fbi_taps.tap_type = "gps_person"
        ]], {}, function(taps)
            TriggerClientEvent('fbi:showTablet', src, taps, tapType)
        end)
        
    end
end)

RegisterNetEvent('fbi:installGpsTracker', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local target = ESX.GetPlayerFromId(targetId)

    if not target then
        TriggerClientEvent('ox_lib:notify', src, {title = 'FBI', description = 'Cíl nenalezen.', type = 'error'})
        return
    end

    local item = xPlayer.getInventoryItem(Config.GpsTrackerItem)
    if item and item.count > 0 then
        exports.oxmysql:insert('INSERT INTO fbi_taps (target_charid, agent_id, tap_type, active) VALUES (?, ?, ?, 1)', {
            target.identifier, src, 'gps_person'
        })

        local coords = GetEntityCoords(GetPlayerPed(src))
        TriggerClientEvent('fbi:getLocationForWebhook', src, 'install', {
            agent = xPlayer.getName(),
            target = 'SPZ: ' .. plate, -- nebo target.getName()..(...)
            type = 'gps_vehicle' -- nebo 'gps_person'
        })
                

        xPlayer.removeInventoryItem(Config.GpsTrackerItem, 1)
        TriggerClientEvent('ox_lib:notify', src, {title = 'FBI', description = '✅ GPS Tracker nainstalován!', type = 'success'})
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'FBI', description = '🚫 Nemáš GPS tracker!', type = 'error'})
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        for agentId, targets in pairs(activeTrackers) do
            if targets then
                for _, targetCharId in pairs(targets) do
                    local agent = ESX.GetPlayerFromId(agentId)
                    local target = getSourceFromIdentifier(targetCharId)

                    if agent and target then
                        local ped = GetPlayerPed(target)
                        if ped then
                            local coords = GetEntityCoords(ped)
                            TriggerClientEvent('fbi:updatePlayerTrackerBlip', agent.source, targetCharId, coords.x, coords.y, coords.z, 'gps_person')
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        exports.oxmysql:execute('SELECT * FROM fbi_taps WHERE active = 1 AND tap_type = "gps_vehicle"', {}, function(vehicleTaps)
            for _, tap in pairs(vehicleTaps) do
                local agent = ESX.GetPlayerFromId(tonumber(tap.agent_id))
                if agent then
                    for _, veh in ipairs(GetAllVehicles()) do
                        if DoesEntityExist(veh) then
                            local plate = GetVehicleNumberPlateText(veh)
                            if plate == tap.target_charid then
                                local coords = GetEntityCoords(veh)
                                TriggerClientEvent('fbi:updatePlayerTrackerBlip', agent.source, plate, coords.x, coords.y, coords.z, 'gps_vehicle')
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- fáze 2


-- Server: Použití GPS Detector itemu
RegisterNetEvent('fbi:useGpsDetector', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    exports.oxmysql:execute('SELECT * FROM fbi_taps WHERE target_charid = ? AND tap_type = "gps_person" AND active = 1', {xPlayer.identifier}, function(taps)
        if taps and #taps > 0 then
            TriggerClientEvent('fbi:showTrackerFound', src, 'person')
        else
            TriggerClientEvent('fbi:scanNearbyVehicle', src)
        end
    end)
end)

math.randomseed(os.time())


RegisterNetEvent('fbi:completeTrackerRemoval', function(type, id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local random = math.random(1,100)
    if random <= Config.DetectorFailureChance then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'GPS Detector',
            description = '❌ Nepodařilo se odstranit tracker (neúspěch)!',
            type = 'error'
        })
        return
    end

    -- Odstranění v DB
    if type == 'person' then
        exports.oxmysql:execute('DELETE FROM fbi_taps WHERE target_charid = ? AND tap_type = "gps_person" AND active = 1', {xPlayer.identifier})
    elseif type == 'vehicle' then
        exports.oxmysql:execute('DELETE FROM fbi_taps WHERE target_charid = ? AND tap_type = "gps_vehicle" AND active = 1', {id})
    end

    -- Odebrání blipu všem
    TriggerClientEvent('fbi:removePlayerTrackerBlip', -1, (type == 'person' and xPlayer.identifier or id))

    -- Notifikace jobu
    for _, id in ipairs(GetPlayers()) do
        local xTarget = ESX.GetPlayerFromId(id)
        if xTarget and xTarget.job and xTarget.job.name == Config.RequiredJob then
            TriggerClientEvent('ox_lib:notify', xTarget.source, {
                title = 'FBI Tracker',
                description = ('⚠️ Cíl odstranil tracker (%s)'):format(type),
                type = 'warning'
            })
        end
    end

    -- Získej lokaci z klienta
    TriggerClientEvent('fbi:getLocationForWebhook', src, type, (type == 'person' and xPlayer.identifier or id))

    -- Vlastní notifikace hráči
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'GPS Detector',
        description = '✅ Tracker byl odstraněn!',
        type = 'success'
    })
end)

RegisterNetEvent('fbi:sendTrackerWebhookFromClient', function(type, id, street)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local embed = {{
        title = '⚠️ Tracker Odstraněn',
        color = 16711680,
        fields = {
            { name = '👤 Hráč', value = xPlayer.getName(), inline = true },
            { name = '📦 Typ', value = type, inline = true },
            { name = '🧾 Info', value = id, inline = true },
            { name = '📍 Lokace', value = street, inline = false },
        },
        footer = { text = os.date('%Y-%m-%d %H:%M:%S') }
    }}

    PerformHttpRequest(Config.WebhookUrl, function() end, 'POST',
        json.encode({username = 'FBI Tracker Logs', embeds = embed}),
        { ['Content-Type'] = 'application/json' })
end)





RegisterNetEvent('fbi:finalizeInstallWebhook', function(type, id, street)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local embed = {{
        title = '🛰️ GPS Tracker Nainstalován',
        color = 31487,
        fields = {
            { name = '👮 Agent', value = xPlayer.getName(), inline = true },
            { name = '🎯 Cíl', value = id, inline = true },
            { name = '📦 Typ', value = type, inline = true },
            { name = '📍 Lokace', value = street, inline = false },
        },
        footer = { text = os.date('%Y-%m-%d %H:%M:%S') }
    }}

    PerformHttpRequest(Config.WebhookUrl, function() end, 'POST',
        json.encode({username = 'FBI Tracker Logs', embeds = embed}),
        { ['Content-Type'] = 'application/json' })
end)













function useGpsDetector(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    exports.oxmysql:execute('SELECT * FROM fbi_taps WHERE target_charid = ? AND tap_type = "gps_person" AND active = 1', {xPlayer.identifier}, function(taps)
        if taps and #taps > 0 then
            TriggerClientEvent('fbi:showTrackerFound', source, 'person')
        else
            TriggerClientEvent('fbi:scanNearbyVehicle', source)
        end
    end)
end

exports('useGpsDetector', useGpsDetector)


RegisterNetEvent('fbi:checkTrackerOnPlayer', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    exports.oxmysql:execute('SELECT * FROM fbi_taps WHERE target_charid = ? AND tap_type = "gps_person" AND active = 1', {xPlayer.identifier}, function(taps)
        if taps and #taps > 0 then
            -- Má osobní tracker ➔ otevři minihru
            TriggerClientEvent('fbi:showTrackerFound', src, 'person')
        else
            -- Nemá osobní tracker ➔ napiš chybu, NIC dalšího nedělej
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'GPS Detector',
                description = '🚫 Na sobě nemáš žádný aktivní tracker!',
                type = 'error'
            })
        end
    end)
end)
