ESX = nil
local blips = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local function createBlips()
    if #blips == 0 then
        for _, coords in pairs(Config.Locations) do
            local blip = AddBlipForCoord(coords)
            SetBlipSprite(blip, Config.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.9)
            SetBlipColour(blip, Config.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.JobName .. " location")
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end
    end
end

local function removeBlips()
    for _, blip in ipairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

local function refreshBlips()
    local playerData = ESX.GetPlayerData()
    if playerData.job and playerData.job.name == Config.JobName then
        createBlips()
    else
        removeBlips()
    end
end

AddEventHandler('esx:playerLoaded', function()
    refreshBlips()
end)

AddEventHandler('esx:setJob', function()
    refreshBlips()
end)

-- Check on script start
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
    end
    refreshBlips()
end)
