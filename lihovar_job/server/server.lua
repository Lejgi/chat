ESX = exports["es_extended"]:getSharedObject()


local function logToDiscord(title, message, color)
    local webhook = 'https://discord.com/api/webhooks/1357819238462787708/ckeuwgWACi1VwjroDTLR_1tj98Cmmq9RgkIxL04TIabxNcO-kk5KfXcVjZauolCIT7Ol' 
    local embed = {
        {
            title = title,
            description = message,
            color = color or 16777215,
            footer = {
                text = os.date("%d.%m.%Y %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(webhook, function() end, 'POST', json.encode({ embeds = embed }), {
        ['Content-Type'] = 'application/json'
    })
end

RegisterServerEvent("lihovar:harvestPlant")
AddEventHandler("lihovar:harvestPlant", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        xPlayer.addInventoryItem("obili", math.random(5,10))
        TriggerClientEvent("ox_lib:notify", src, {
            type = "success",
            description = "Sebral jsi obilí."
        })
    end
end)

RegisterNetEvent('lihovar:collectWater', function(item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem(item, count)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Sbírání vody',
            description = ('Nabral jsi %sx %s!'):format(count, item),
            type = 'success'
        })
    end
end)


ESX.RegisterServerCallback('lihovar:checkJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job.name == 'lihovar' then
        cb(true)
    else
        cb(false)
    end
end)




RegisterServerEvent('lihovar:craft')
AddEventHandler('lihovar:craft', function(type)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local recipe = Config.Recipes[type]
    if not recipe then return end

    for _, req in ipairs(recipe.requires) do
        local invItem = xPlayer.getInventoryItem(req.name)
        if not invItem or invItem.count < req.amount then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = 'Chybí: ' .. (req.label or req.name)
            })
            return
        end
    end

    -- Spusť animaci a progress bar na klientovi
    TriggerClientEvent('lihovar:playCraftAnim', src, type)
end)

RegisterServerEvent('lihovar:finishCraft')
AddEventHandler('lihovar:finishCraft', function(type)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local recipe = Config.Recipes[type]
    if not recipe then return end

    for _, req in ipairs(recipe.requires) do
        xPlayer.removeInventoryItem(req.name, req.amount)
    end

    local amount = tonumber(recipe.outputAmount) or 1
    xPlayer.addInventoryItem(recipe.result, amount)

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = recipe.success or ('Vyrobil jsi ' .. amount .. 'x ' .. recipe.result)
    })
end)


local MySQL = exports.oxmysql

RegisterNetEvent("lihovar:sellItem")
AddEventHandler("lihovar:sellItem", function(item, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local count = exports.ox_inventory:Search(src, 'count', item)

    if not xPlayer or xPlayer.job.name ~= "lihovar" then return end

    local itemData = nil
    for _, v in pairs(Config.BuyerNPC.items) do
        if v.name == item then
            itemData = v
            break
        end
    end

    if not itemData then return end
    local pricePer = itemData.price
    local totalPrice = pricePer * amount

    local tax = 0
    local taxResult = MySQL:query_async('SELECT tax FROM doj WHERE type = ?', { 'npc-selling' })
    if taxResult and taxResult[1] and taxResult[1].tax then
        tax = taxResult[1].tax
    end

    local percentage = 0
    local percentResult = MySQL:query_async('SELECT percentage FROM sell_percentage WHERE job_name = ? AND grade = ?', {
        xPlayer.job.name,
        xPlayer.job.grade
    })
    if percentResult and percentResult[1] and percentResult[1].percentage then
        percentage = percentResult[1].percentage
    end

    local state_value = math.floor(totalPrice * (tax / 100))
    local player_value = math.floor((totalPrice - state_value) * (percentage / 100))
    local society_value = totalPrice - state_value - player_value

    if count < amount then
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            title = 'lihovar Výkup',
            description = 'Nemáš dostatek zboží na prodej.',
            type = 'error'
        })
        return
    end

    exports.ox_inventory:RemoveItem(xPlayer.source, item, amount)

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_lihovar', function(account)
        if account then
            account.addMoney(society_value)
        end
    end)

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_vlada', function(account)
        if account then
            account.addMoney(state_value)
        end
    end)

    if player_value > 0 then
        exports.ox_inventory:AddItem(xPlayer.source, 'money', player_value)
    end

    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
        title = 'lihovar Výkup',
        description = ('Získal jsi $%s'):format(player_value),
        type = 'success'
    })

    logToDiscord(
        "📦 Prodej surovin",
        string.format("Hráč **%s [%s]** prodal **%sx %s**\n💰 Hráč: `$%s`\n🏦 Frakce: `$%s`\n📊 Stát: `$%s`",
            xPlayer.getName(), xPlayer.source, amount, item, player_value, society_value, state_value),
        31487
    )

    TriggerEvent("logs:send", {
        player = xPlayer.source,
        action = "lihovar-sell",
        message = string.format("Hráč %s prodal %sx %s za $%s", GetPlayerName(xPlayer.source), amount, tostring(item), tostring(totalPrice)),
        data = {
            Autor = GetPlayerName(xPlayer.source),
            Coords = GetEntityCoords(GetPlayerPed(xPlayer.source)),
            Player_percentage = tostring(percentage),
            Player_amount = tostring(player_value),
            Society_amount = tostring(society_value),
            State_amount = tostring(state_value),
            item = tostring(item),
            count = tostring(count)
        }
    })
end)











RegisterNetEvent("lihovar:buyItem", function(itemName, amount, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not itemName or not amount or not price then return end

    local total = amount * price

    if xPlayer.getMoney() < total then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Nemáš dostatek peněz.'
        })
        return
    end

    xPlayer.removeMoney(total)
    xPlayer.addInventoryItem(itemName, amount)

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = ('Zakoupil jsi %sx %s za $%s'):format(amount, itemName, total)
    })
end)

lib.callback.register('lihovar:getItemCount', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local count = exports.ox_inventory:Search(source, 'count', 'dirty_bottle2')
    return count
end)

lib.callback.register('lihovar:getItemCount2', function()
  local xPlayer = ESX.GetPlayerFromId(source)
  local count = exports.ox_inventory:Search(source, 'count', 'sponge')
  return count
end)

RegisterNetEvent('lihovar:washbottle')
AddEventHandler('lihovar:washbottle', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local count = exports.ox_inventory:Search(source, 'count', 'dirty_bottle2')

    if xPlayer.job.name == "lihovar" then
        if xPlayer ~= nil then
            if xPlayer.canCarryItem('bottle2', 1) then
                if count >= 1 then
                    exports.ox_inventory:RemoveItem(source, 'dirty_bottle2', 10)
                    exports.ox_inventory:AddItem(source, 'bottle2', 10)
                elseif count < 1 then
                    TriggerClientEvent('ox_lib:notify', source, {
                        title = "Bar",
                        description = "Nemáš špinavé sklenice",
                        type = 'error',
                        duration = 3500
                    })
                end
            else
                TriggerClientEvent('ox_lib:notify', source, {
                    title = "Bar",
                    description = "víc už toho neuneseš",
                    type = 'error',
                    duration = 3500
                })
            end
        end
    end
end)

lib.callback.register('lihovar:canCarry', function(source, item, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local count = exports.ox_inventory:Search(source, 'count', item)
    if xPlayer ~= nil then
        if xPlayer.canCarryItem(item, count) then
            return true
        else
            return false
        end
    end
    return false
end)