RegisterNetEvent('lihovar:washinganim')
AddEventHandler('lihovar:washinganim', function()
    local count = lib.callback.await('lihovar:getItemCount')
    local count2 = lib.callback.await('lihovar:getItemCount2')
    if count <= 0 then
        lib.notify({
            title = _L('Lihovar'),
            description = _L('Nemáš špinavé láhve'),
            type = 'error'
        })
        washing = false
    elseif count2 <= 0 then
        local alert = lib.alertDialog({
            header = _L('Lihovar'),
            content = _L('Nemáš houbičku na mytí, chceš umýt láhve pouze rukou?'),
            centered = true,
            cancel = true
        })
        if alert == 'confirm' then
            local success = lib.skillCheck({
                'easy', 'easy', {areaSize = 60, speedMultiplier = 1}
            }, {'w', 'a', 's', 'd'})
            if success then
                if not washing then
                    washing = true
                    exports.ox_inventory:Progress({
                        duration = 2500,
                        label = _L('Umýváš láhve'),
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = false,
                            car = true,
                            combat = true,
                            mouse = false
                        }
                    }, function(cancel)
                        if not cancel then
                            TriggerServerEvent('lihovar:washbottle')
                        end
                    end)
                    washing = false
                end
            else
                lib.notify({
                    title = _L('Lihovar'),
                    description = _L('Nepovedlo se ti umýt flašku v ruce'),
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = _L('Lihovar'),
                description = _L('Nemáš houbičku na mytí'),
                type = 'error'
            })
            washing = false
        end
    else
        if not washing then
            washing = true
            exports.ox_inventory:Progress({
                duration = 2500,
                label = _L('Umýváš láhve'),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = false,
                    car = true,
                    combat = true,
                    mouse = false
                }
            }, function(cancel)
                if not cancel then
                    TriggerServerEvent('lihovar:washbottle')
                end
            end)
            washing = false
        end
    end
end)

Citizen.CreateThread(function()
    exports.qtarget:AddCircleZone("pwash", vector3(-147.13, 6283.05, 31.61), 0.85,
                                  {
        name = "pwash",
        debugPoly = false,
        useZ = true
    }, {
        options = {
            {
                event = "lihovar:washinganim",
                label = _L('Umít láhve')
            }
        },
        job = {"lihovar"},
        distance = 2.4
    })
end)