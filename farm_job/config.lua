Config = {}

-- Require this ESX job to use the farm
Config.Job = 'farmer'

-- Coordinates for interaction points
Config.HarvestPoints = {
    {coords = vec3(2300.0, 4885.0, 41.8), item = 'grain',   count = 1, label = 'Harvest Grain'},
    {coords = vec3(2310.0, 4885.0, 41.8), item = 'tomato',  count = 1, label = 'Collect Tomato'},
    {coords = vec3(2320.0, 4885.0, 41.8), item = 'carrot',  count = 1, label = 'Collect Carrot'},
    {coords = vec3(2330.0, 4885.0, 41.8), item = 'chicken', count = 1, label = 'Catch Chicken'},
    {coords = vec3(2340.0, 4885.0, 41.8), item = 'duck',    count = 1, label = 'Catch Duck'}
}

Config.ProcessPoints = {
    {coords = vec3(2350.0, 4885.0, 41.8), from = 'chicken', to = 'frozen_chicken', count = 1, label = 'Freeze Chicken'},
    {coords = vec3(2360.0, 4885.0, 41.8), from = 'duck',    to = 'frozen_duck',    count = 1, label = 'Freeze Duck'},
    {coords = vec3(2370.0, 4885.0, 41.8), from = 'tomato',  to = 'chopped_tomato', count = 2, label = 'Chop Tomato'},
    {coords = vec3(2380.0, 4885.0, 41.8), from = 'carrot',  to = 'chopped_carrot', count = 2, label = 'Chop Carrot'}
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
        label  = 'Cook Roasted Chicken'
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
        label  = 'Cook Duck Soup'
    }
}

-- Sell cooked meals for money
Config.SellPoints = {
    {coords = vec3(2410.0, 4885.0, 41.8), item = 'roasted_chicken', price = 150, label = 'Sell Roasted Chicken'},
    {coords = vec3(2420.0, 4885.0, 41.8), item = 'duck_soup',       price = 180, label = 'Sell Duck Soup'}
}

-- Time in milliseconds for progress bars
Config.Progress = {
    Harvest = 3000,
    Process = 4000,
    Cook    = 5000,
    Sell    = 2000
}
