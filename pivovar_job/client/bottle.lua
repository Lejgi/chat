RegisterNetEvent('pivovar:washinganim')
AddEventHandler('pivovar:washinganim', function()
    local count = lib.callback.await('pivovar:getItemCount')
    local count2 = lib.callback.await('pivovar:getItemCount2')
    if count <= 0 then
        lib.notify({
            title = _L('pivovar'),
            description = _L('Nemáš špinavé láhve'),
            type = 'error'
        })
        washing = false
    elseif count2 <= 0 then
        local alert = lib.alertDialog({
            header = _L('pivovar'),
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
                            TriggerServerEvent('pivovar:washbottle')
                        end
                    end)
                    washing = false
                end
            else
                lib.notify({
                    title = _L('pivovar'),
                    description = _L('Nepovedlo se ti umýt flašku v ruce'),
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = _L('pivovar'),
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
                    TriggerServerEvent('pivovar:washbottle')
                end
            end)
            washing = false
        end
    end
end)

Citizen.CreateThread(function()
    exports.qtarget:AddCircleZone("pwash", vector3(-39.62, 6431.04, 31.5), 0.85,
                                  {
        name = "pwash",
        debugPoly = false,
        useZ = true
    }, {
        options = {
            {
                event = "pivovar:washinganim",
                label = _L('Umít láhve')
            }
        },
        job = {"pivovar"},
        distance = 2.4
    })
end)