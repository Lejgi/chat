local basicCards = {"bulbasaur", "ivysaur", "charmander", "charmeleon", "squirtle", "wartortle", "caterpie", "metapod", "butterfree", "weedle", "kakuna", "beedrill", "pidgey","pidgeotto", "pidgeot", "rattata", "raticate", "spearow", "fearow", "ekans", "arbok", "pikachu", "sandshrew", "sandslash", "nidoran", "nidorina", "nidoqueen", "nidorino", "clefairy","clefable", "vulpix", "ninetails", "zubat", "golbat", "oddish", "gloom", "vileplume", "paras", "parasect", "venonat", "venomoth", "diglett", "dugtrio", "meowth", "persian", "psyduck","golduck", "mankey", "primeape", "growlithe", "arcanine", "poliwag", "poliwhirl", "poliwrath", "abra","machop", "machoke", "bellsprout", "weepinbell", "victreebel", "tentacool","tentacruel", "geodude", "graveler", "golem", "ponyta", "rapidash", "slowpoke", "slowbro", "magnemite", "magneton", "farfetchd", "doduo", "dodrio", "seel", "dewgong", "grimer", "muk", "shellder", "cloyster","gastly", "haunter", "gengar", "drowzee", "hypno", "krabby", "kingler", "voltorb", "electrode", "exeggcute", "exeggutor", "cubone", "marowak", "lickitung", "koffing", "weezing", "rhyhorn", "rhydon", "chansey", "tangela", "horsea", "seadra", "goldeen", "seaking", "staryu", "mrmime",  "electabuzz", "magmar", "pinsir", "tauros", "magikarp"}
local rareCards = {"lapras", "eevee", "togepi", "vaporeon", "jolteon", "flareon", "jigglypuff","wigglytuff", "kadabra","raichu", "nidoking",  "jynx", "kangaskhan", "gyarados","ditto","starmie", "onix", "machamp", "scyther", "hitmonlee", "hitmonchan", "venusaur" }
local ultraCards = {"charizard", "blastoise","porygon", "omanyte", "omastar", "dragonite", "mewtwo", "mew", "snorlax", "articuno", "zapdos", "kabuto", "kabutops", "aerodactyl", "moltres", "dratini", "dragonair"}
local vCards = {"blastoisev", "charizardv", "mewv", "pikachuv", "snorlaxv", "venusaurv"}
local vmaxCards = {"blastoisevmax", "mewtwogx", "snorlaxvmax", "venusaurvmax", "vmaxcharizard", "vmaxpikachu"}
local rainbowCards = {"rainbowmewtwogx", "rainbowvmaxcharizard", "rainbowvmaxpikachu", "snorlaxvmaxrainbow"}

local ESX = exports['es_extended']:getSharedObject()
local Ox = exports.ox_inventory

local registeredStashes = {}

local function notify(source, description, notifType)
    TriggerClientEvent('Cards:client:notify', source, {
        description = description,
        type = notifType or 'inform'
    })
end

local function getPlayer(source)
    local player = ESX.GetPlayerFromId(source)
    if not player then
        print(('[cards] failed to fetch player for source %s'):format(source))
    end
    return player
end

local function getItemLabel(item)
    if ESX.GetItemLabel then
        local label = ESX.GetItemLabel(item)
        if label then
            return label
        end
    end

    local items = ESX.Items
    if items and items[item] and items[item].label then
        return items[item].label
    end

    return item
end

local function ensurePlayerStash(player)
    if not player then return nil end

    local identifier = player.identifier or (player.getIdentifier and player:getIdentifier()) or tostring(player.source)
    local stashId = ('poke_%s'):format(identifier)

    if not registeredStashes[stashId] then
        Ox:RegisterStash(stashId, 'Pokemon Storage', 160, 100000, true)
        registeredStashes[stashId] = true
    end

    return stashId
end

math.randomseed(os.time())

Ox:RegisterUsableItem('boosterbox', function(data, slot)
    local source = data.source

    if Ox:RemoveItem(source, 'boosterbox', 1, nil, slot) then
        TriggerClientEvent('Cards:Client:OpenCards', source)
        if not Ox:AddItem(source, 'boosterpack', 4) then
            notify(source, 'Unable to give booster packs, refunding the box.', 'error')
            Ox:AddItem(source, 'boosterbox', 1)
            return
        end

        Wait(4000)
        notify(source, 'You got 4 booster packs!', 'success')
    end
end)

Ox:RegisterUsableItem('boosterpack', function(data, slot)
    local source = data.source

    TriggerClientEvent('Cards:Client:OpenPack', source)
    Wait(4000)
    notify(source, 'You got 4 cards!', 'success')
end)

Ox:RegisterUsableItem('pokebox', function(data, slot)
    local source = data.source
    local player = getPlayer(source)
    local stashId = ensurePlayerStash(player)

    if stashId then
        TriggerClientEvent('Cards:client:UseBox', source, stashId)
    end
end)

RegisterNetEvent('Cards:Server:RemoveItem')
AddEventHandler('Cards:Server:RemoveItem', function()
    local src = source
    local count = Ox:Search(src, 'count', 'boosterpack') or 0

    if count <= 0 then
        notify(src, 'You do not have a booster pack!', 'error')
        return
    end

    Ox:RemoveItem(src, 'boosterpack', 1)
end)

RegisterServerEvent('Cards:Server:rewarditem')
AddEventHandler('Cards:Server:rewarditem', function()
    local src = source
    local card = ''
    local randomChance = math.random(1, 1000)

    if randomChance <= 5 then
        card = rainbowCards[math.random(1,#rainbowCards)]
    elseif randomChance >= 6 and randomChance <= 19 then
        card = vmaxCards[math.random(1, #vmaxCards)]
    elseif randomChance >= 20 and randomChance <= 50 then
        card = vCards[math.random(1, #vCards)]
    elseif randomChance >= 51 and randomChance <= 100 then
        card = ultraCards[math.random(1, #ultraCards)]
    elseif randomChance >= 101 and randomChance <= 399 then
        card = rareCards[math.random(1, #rareCards)]
    else
        card = basicCards[math.random(1, #basicCards)]
    end

    Wait(10)

    if card ~= '' then
        TriggerClientEvent('Cards:Client:CardChoosed', src, card)
    else
        notify(src, 'There is a problem in cards!', 'error')
    end
end)

RegisterServerEvent('Cards:Server:GetPokemon')
AddEventHandler('Cards:Server:GetPokemon', function(pokemon)
    local src = source
    if not pokemon then return end

    if Ox:AddItem(src, pokemon, 1) then
        notify(src, ('You got %s'):format(getItemLabel(pokemon)), 'success')
    else
        notify(src, 'Unable to add the selected card.', 'error')
    end
end)

RegisterServerEvent('Cards:server:badges')
AddEventHandler('Cards:server:badges', function(badgeType)
    local src = source
    local badgeConfig = Config.Badge[badgeType]

    if not badgeConfig then
        return
    end

    for item, amount in pairs(badgeConfig.cards) do
        local count = Ox:Search(src, 'count', item) or 0
        if count < amount then
            notify(src, 'Come back when you have all the items for the '..badgeConfig.label, 'error')
            return
        end
    end

    for item, amount in pairs(badgeConfig.cards) do
        Ox:RemoveItem(src, item, amount)
    end

    Wait(2000)

    if Ox:AddItem(src, badgeType, 1) then
        notify(src, 'You got a '..badgeConfig.label..'!', 'success')
    else
        notify(src, 'Unable to give the badge reward, refunding your cards.', 'error')
        for item, amount in pairs(badgeConfig.cards) do
            Ox:AddItem(src, item, amount)
        end
    end
end)

RegisterServerEvent('Cards:sellItem')
AddEventHandler('Cards:sellItem', function(itemName, amount, price)
    local src = source
    local player = getPlayer(src)

    if not player or not itemName or not amount or amount <= 0 or not price or price <= 0 then
        return
    end

    if Ox:RemoveItem(src, itemName, amount) then
        player.addAccountMoney('money', price)
        notify(src, ('You sold %d %s for $%d'):format(amount, itemName, price), 'success')
    else
        notify(src, 'You do not have enough of that item.', 'error')
    end
end)

ESX.RegisterServerCallback('Cards:server:get:drugs:items', function(source, cb)
    local available = {}

    for item, _ in pairs(Config.CardshopItems) do
        local count = Ox:Search(source, 'count', item) or 0
        if count > 0 then
            available[#available+1] = { ['Item'] = item, ['Amount'] = count }
        end
    end

    cb(available)
end)
