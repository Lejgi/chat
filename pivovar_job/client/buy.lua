
local shopNPC = nil

local function createShop()
    local model = Config.ShopNPC.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    shopNPC = CreatePed(0, model, Config.ShopNPC.coords.x, Config.ShopNPC.coords.y, Config.ShopNPC.coords.z - 1.0, Config.ShopNPC.coords.w, false, true)
    FreezeEntityPosition(shopNPC, true)
    SetEntityInvincible(shopNPC, true)
    SetBlockingOfNonTemporaryEvents(shopNPC, true)

    exports.ox_target:addLocalEntity(shopNPC, {
        {
            name = "pivovar_shop_target",
            icon = Config.ShopNPC.icon,
            label = _L(Config.ShopNPC.targetLabel),
            canInteract = function(entity, distance, coords, name)
                return ESX.GetPlayerData().job.name == Config.ShopNPC.requiredJob
            end,
            onSelect = function()
                local options = {}
                for _, item in pairs(Config.ShopNPC.items) do
                    table.insert(options, {
                        title = (_L(item.label) or item.name) .. " ($" .. item.price .. ")",
                        icon = 'cart-shopping',
                        onSelect = function()
                            local input = lib.inputDialog(_L('Nákup: ') .. _L(item.label), {
                                {
                                    type = 'number',
                                    label = _L('Kolik chceš koupit?'),
                                    default = 1,
                                    min = 1
                                }
                            })

                            if input and input[1] then
                                TriggerServerEvent("pivovar:buyItem", item.name, tonumber(input[1]), item.price)
                            end
                        end
                    })
                end

                lib.registerContext({
                    id = 'pivovar_shop_menu',
                    title = _L('pivovar obchod'),
                    options = options
                })

                lib.showContext('pivovar_shop_menu')
            end
        }
    })
end

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    createShop()
end)
