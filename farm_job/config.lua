Config = {}

-- Coordinates for interaction points
Config.HarvestPoints = {
    {coords = vec3(2300.0, 4885.0, 41.8), item = 'grain', count = 1, label = 'Harvest Grain'},
    {coords = vec3(2310.0, 4885.0, 41.8), item = 'chicken', count = 1, label = 'Collect Chicken'},
    {coords = vec3(2320.0, 4885.0, 41.8), item = 'duck', count = 1, label = 'Collect Duck'}
}

Config.ProcessPoints = {
    {coords = vec3(2330.0, 4885.0, 41.8), from = 'chicken', to = 'frozen_chicken', count = 1, label = 'Freeze Chicken'},
    {coords = vec3(2340.0, 4885.0, 41.8), from = 'duck', to = 'frozen_duck', count = 1, label = 'Freeze Duck'}
}

Config.CookPoints = {
    {coords = vec3(2350.0, 4885.0, 41.8), items = { {item = 'frozen_chicken', count = 1}, {item = 'grain', count = 2} }, result = 'roasted_chicken', count = 1, label = 'Cook Roasted Chicken'},
    {coords = vec3(2360.0, 4885.0, 41.8), items = { {item = 'frozen_duck', count = 1}, {item = 'grain', count = 1} }, result = 'duck_soup', count = 1, label = 'Cook Duck Soup'}
}

-- Time in milliseconds for progress bars
Config.Progress = {
    Harvest = 3000,
    Process = 4000,
    Cook = 5000
}
