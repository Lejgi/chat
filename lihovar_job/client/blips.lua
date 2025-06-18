local ESX = exports["es_extended"]:getSharedObject()
local blips = {}

local function createBlips()
    local locations = {
        { label = "Sber Obilí", coords = vec3(349.99, 6517.27, 28.6), sprite = 496, color = 25 },
        { label = "Vyroba lihovar", coords = vec3(2913.0964, 4475.8999, 48.3450), sprite = 566, color = 1 },
        { label = "Koupe surovin", coords = vec3(-56.9761, 6521.2544, 31.4908), sprite = 566, color = 1 },
        { label = "Prodej produktu", coords = vec3(3798.9663, 4446.5811, 4.3378), sprite = 566, color = 1 }
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
    if job == "lihovar" then
        createBlips()
    end
end)

RegisterNetEvent("esx:setJob", function(job)
    if job.name == "lihovar" then
        createBlips()
    else
        removeBlips()
    end
end)