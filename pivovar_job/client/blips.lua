local ESX = exports["es_extended"]:getSharedObject()
local blips = {}

local function createBlips()
    local locations = {
        { label = _L('Sber Obilí'), coords = vec3(255.1872, 6457.7681, 31.4509), sprite = 496, color = 25 },
        { label = _L('Vyroba pivovar'), coords = vec3(-53.1422, 6426.6831, 32.4901), sprite = 566, color = 1 },
        { label = _L('Koupe surovin'), coords = vec3(-58.2537, 6522.5308, 31.4908), sprite = 566, color = 1 },
        { label = _L('Prodej produktu'), coords = vec3(-1581.5283, 5174.4487, 19.5250), sprite = 566, color = 1 }
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
    if job == "pivovar" then
        createBlips()
    end
end)

RegisterNetEvent("esx:setJob", function(job)
    if job.name == "pivovar" then
        createBlips()
    else
        removeBlips()
    end
end)