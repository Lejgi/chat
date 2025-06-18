ESX = exports["es_extended"]:getSharedObject()

local function _T(key, ...)
    local locale = Locales[Config.Locale] or {}
    local str = locale[key] or key
    if ... then
        return str:format(...)
    end
    return str
end

local function RegisterNPC(job, data)
    local model = data.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(0, model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'tombola_target_' .. job,
            icon = 'fa-solid fa-ticket',
            label = _T('open_label'),
            distance = 2.5,
            canInteract = function()
                return true
            end,
            onSelect = function()
                if lib then
                    lib.callback('tombola:canOpen', false, function(result)
                        if result and result.allowed then
                            SetNuiFocus(true, true)
                            SendNUIMessage({
                                action = 'openUI',
                                job = job,
                                isBoss = result.isBoss,
                                ticketPrice = result.ticketPrice or 0,
                                translations = Locales[Config.Locale]
                            })

                            if result.isBoss then
                                loadAllTickets(job)
                                loadPrizePool(job)
                            else
                                loadTickets(job)
                            end
                        else
                            lib.notify({ type = 'error', description = _T('access_denied') })
                        end
                    end, job)
                else
              end
            end
        }
    })
end

RegisterNUICallback('buyTickets', function(data, cb)
    TriggerServerEvent('tombola:buyTickets', data.job, data.count, data.method)
    cb(true)
end)



function loadTickets(job)
    lib.callback('tombola:getTickets', false, function(tickets)
        SendNUIMessage({
            action = 'setTickets',
            tickets = tickets
        })
    end, job)
end

function loadAllTickets(job)
    lib.callback('tombola:getAllTickets', false, function(entries)
        SendNUIMessage({
            action = 'setAllTickets',
            entries = entries
        })
    end, job)
end

RegisterNUICallback('confirmReset', function(data, cb)
    local result = lib.alertDialog({
        header = _T('confirm_title'),
        content = _T('confirm_reset'),
        centered = true,
        cancel = true
    })

    if result == 'confirm' then
        TriggerServerEvent('tombola:reset', data.job)
    end

    cb(true)
end)

RegisterNetEvent('tombola:updateTicketPrice', function(price)
    SendNUIMessage({
        action = 'updatePrice',
        price = price
    })
end)


function loadPrizePool(job)
    lib.callback('tombola:getPrizePool', false, function(pool)
        SendNUIMessage({
            action = 'setPrizePool',
            pool = pool
        })
    end, job)
end

RegisterNUICallback('setTicketPrice', function(data, cb)
    TriggerServerEvent('tombola:setTicketPrice', data.job, data.price)
    cb(true)
end)


CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    Wait(500)

    for job, data in pairs(Config.Lotteries) do
        RegisterNPC(job, data.npc)
    end
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb(true)
end)

