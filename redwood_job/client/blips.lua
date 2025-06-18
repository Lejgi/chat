local ESX = exports["es_extended"]:getSharedObject()
local blips = {}

local function createBlips()
    local locations = {
        { label = _L('Sber tabaku'), coords = vec3(2845.7898, 4608.7529, 47.9798), sprite = 496, color = 25 },
        { label = _L('Vyroba Redwood'), coords = vec3(2913.0964, 4475.8999, 48.3450), sprite = 566, color = 1 },
        { label = _L('Koupe surovin'), coords = vec3(-59.3794, 6523.7188, 31.4908), sprite = 566, color = 1 },
        { label = _L('Prodej produktu'), coords = vec3(2145.3823, 4774.7847, 41.0054), sprite = 566, color = 1 }
    }

    for _, loc in pairs(locations) do
        local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(blip, loc.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, loc.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(loc.label)
        EndTextCommandSetBlipName(blip)
        table.insert(blips, blip)
    end
end

local function removeBlips()
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    local job = ESX.GetPlayerData().job.name
    if job == "redwood" then
        createBlips()
    end
end)

RegisterNetEvent("esx:setJob", function(job)
    if job.name == "redwood" then
        createBlips()
    else
        removeBlips()
    end
end)