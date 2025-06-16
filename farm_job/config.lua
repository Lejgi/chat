Config = {}

-- Language selection ('en' or 'cz')
Config.Locale = 'en'

-- Translation strings
Config.Lang = {
    en = {
        not_farmer = 'You are not a farmer',
        harvest_grain = 'Harvest Grain',
        collect_tomato = 'Collect Tomato',
        collect_carrot = 'Collect Carrot',
        catch_chicken = 'Catch Chicken',
        catch_duck = 'Catch Duck',
        freeze_chicken = 'Freeze Chicken',
        freeze_duck = 'Freeze Duck',
        chop_tomato = 'Chop Tomato',
        chop_carrot = 'Chop Carrot',
        cook_roasted_chicken = 'Cook Roasted Chicken',
        cook_duck_soup = 'Cook Duck Soup',
        sell_roasted_chicken = 'Sell Roasted Chicken',
        sell_duck_soup = 'Sell Duck Soup'
    },
    cz = {
        not_farmer = 'Nejsi farmář',
        harvest_grain = 'Sklidit obilí',
        collect_tomato = 'Sebrat rajče',
        collect_carrot = 'Sebrat mrkev',
        catch_chicken = 'Chytit kuře',
        catch_duck = 'Chytit kachnu',
        freeze_chicken = 'Zmrazit kuře',
        freeze_duck = 'Zmrazit kachnu',
        chop_tomato = 'Nakrájet rajče',
        chop_carrot = 'Nakrájet mrkev',
        cook_roasted_chicken = 'Uvařit pečené kuře',
        cook_duck_soup = 'Uvařit kachní polévku',
        sell_roasted_chicken = 'Prodat pečené kuře',
        sell_duck_soup = 'Prodat kachní polévku'
    }
}

function _L(key)
    local lang = Config.Lang[Config.Locale] or {}
    return lang[key] or key
end

-- Require this ESX job to use the farm
Config.Job = 'farmer'

-- Coordinates for interaction points
Config.HarvestPoints = {
    {coords = vec3(2300.0, 4885.0, 41.8), item = 'grain',   count = 1, label = 'harvest_grain'},
    {coords = vec3(2310.0, 4885.0, 41.8), item = 'tomato',  count = 1, label = 'collect_tomato'},
    {coords = vec3(2320.0, 4885.0, 41.8), item = 'carrot',  count = 1, label = 'collect_carrot'},
    {coords = vec3(2330.0, 4885.0, 41.8), item = 'chicken', count = 1, label = 'catch_chicken'},
    {coords = vec3(2340.0, 4885.0, 41.8), item = 'duck',    count = 1, label = 'catch_duck'}
}

Config.ProcessPoints = {
    {coords = vec3(2350.0, 4885.0, 41.8), from = 'chicken', to = 'frozen_chicken', count = 1, label = 'freeze_chicken'},
    {coords = vec3(2360.0, 4885.0, 41.8), from = 'duck',    to = 'frozen_duck',    count = 1, label = 'freeze_duck'},
    {coords = vec3(2370.0, 4885.0, 41.8), from = 'tomato',  to = 'chopped_tomato', count = 2, label = 'chop_tomato'},
    {coords = vec3(2380.0, 4885.0, 41.8), from = 'carrot',  to = 'chopped_carrot', count = 2, label = 'chop_carrot'}
}

Config.CookPoints = {
    {
        coords = vec3(2390.0, 4885.0, 41.8),
        items  = {
            {item = 'frozen_chicken', count = 1},
            {item = 'chopped_carrot', count = 1},
            {item = 'grain',         count = 2}
        },
        result = 'roasted_chicken',
        count  = 1,
        label  = 'cook_roasted_chicken'
    },
    {
        coords = vec3(2400.0, 4885.0, 41.8),
        items  = {
            {item = 'frozen_duck',   count = 1},
            {item = 'chopped_tomato',count = 1},
            {item = 'grain',         count = 1}
        },
        result = 'duck_soup',
        count  = 1,
        label  = 'cook_duck_soup'
}
}

-- Sell cooked meals for money
Config.SellPoints = {
    {coords = vec3(2410.0, 4885.0, 41.8), item = 'roasted_chicken', price = 150, label = 'sell_roasted_chicken'},
    {coords = vec3(2420.0, 4885.0, 41.8), item = 'duck_soup',       price = 180, label = 'sell_duck_soup'}
}

-- Time in milliseconds for progress bars
Config.Progress = {
    Harvest = 3000,
    Process = 4000,
    Cook    = 5000,
    Sell    = 2000
}
