
local buyerNPC = nil

local function createBuyer()
    local model = Config.BuyerNPC.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    buyerNPC = CreatePed(0, model, Config.BuyerNPC.coords.x, Config.BuyerNPC.coords.y, Config.BuyerNPC.coords.z - 1.0, Config.BuyerNPC.coords.w, false, true)
    FreezeEntityPosition(buyerNPC, true)
    SetEntityInvincible(buyerNPC, true)
    SetBlockingOfNonTemporaryEvents(buyerNPC, true)

    exports.ox_target:addLocalEntity(buyerNPC, {
        {
            name = "redwood_buyer_target",
            icon = Config.BuyerNPC.icon,
            label = _L(Config.BuyerNPC.targetLabel),
            canInteract = function(entity, distance, coords, name)
                return ESX.GetPlayerData().job.name == Config.BuyerNPC.requiredJob
            end,
            onSelect = function()
                local options = {}
                for _, item in pairs(Config.BuyerNPC.items) do
                    local count = exports.ox_inventory:Search('count', item.name)
                    if count and count > 0 then
                        table.insert(options, {
                        title = ('%s ($%s / ks)'):format(_L(item.label), item.price),
                        description = (_L('Máš %s ks')):format(count),
                            icon = 'dollar-sign',
                            onSelect = function()
                                local input = lib.inputDialog(_L('Prodej: ') .. _L(item.label), {
                                    {
                                        type = 'number',
                                        label = _L('Kolik chceš prodat?'),
                                        default = 1,
                                        min = 1,
                                        max = count
                                    }
                                })

                                if input and input[1] then
                                    TriggerServerEvent("redwood:sellItem", item.name, tonumber(input[1]), item.price)
                                end
                            end
                        })
                    end
                end

                if #options == 0 then
                    lib.notify({ type = 'error', description = _L('Nemáš nic na prodej.') })
                    return
                end

                lib.registerContext({
                    id = 'redwood_sell_menu',
                    title = _L('Výkup surovin'),
                    options = options
                })

                lib.showContext('redwood_sell_menu')
            end
        }
    })
end

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    createBuyer()
end)
