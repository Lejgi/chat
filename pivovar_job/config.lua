Config = {}

Config.Locale = 'en'
Config.Lang = {
    en = {
        ['Sber Obilí'] = 'Gather Grain',
        ['Vyroba pivovar'] = 'Brewery',
        ['Koupe surovin'] = 'Buy Supplies',
        ['Prodej produktu'] = 'Sell Products',
        ['Sesbírat rostlinu'] = 'Harvest plant',
        ['Umýváš láhve'] = 'Washing bottles',
        ['Umít láhve'] = 'Wash bottles',
        ['Kolik chceš koupit?'] = 'How many do you want to buy?',
        ['Kolik chceš prodat?'] = 'How many do you want to sell?',
        ['Nemáš nic na prodej.'] = 'Nothing to sell.',
        ['Nákup: '] = 'Purchase: ',
        ['Prodej: '] = 'Sell: ',
        ['Výkup surovin'] = 'Material Buyer',
        ['pivovar obchod'] = 'Brewery Shop',
        ['Destilace Piva'] = 'Beer Brewing',
        ['Výroba Piva'] = 'Brew Beer',
        ['Probíhá výroba...'] = 'Processing...'
    },
    cz = {}
}

function _L(key)
    local lang = Config.Lang[Config.Locale] or {}
    return lang[key] or key
end

Config.RequiredJob = "pivovar"

Config.HarvestCenter = vector3(255.1872, 6457.7681, 31.4509)
Config.HarvestRadius = 20.0
Config.MaxPlants = 5
Config.PlantModel = `prop_plant_01a`
Config.HarvestTime = 10000


Config.BuyerNPC = {
    model = "s_m_m_dockwork_01",
    coords = vec4(-1581.5283, 5174.4487, 19.5250, 210.7185),
    targetLabel = "Prodej surovin",
    icon = "fa-solid fa-hand-holding-dollar",
    requiredJob = "pivovar",
    items = {
        { name = "beer", label = "Láhev Piva", price = 550 }
    }
}




Config.WaterZones = {
    {
        coords = vec3(-33.6727, 6408.5938, 31.4904),
        size = vec3(2.0, 2.0, 2.0), -- Šířka/Délka/Výška boxu
        rotation = 0, -- Otočení boxu
        label = "Studna",
        rewardItem = "voda",
        rewardCount = 1
    }
}


Config.SaleSplit = {
    [0] = { player = 0.35, society = 0.65 },  -- Beginner
    [1] = { player = 0.50, society = 0.50 },  -- Collector
    [2] = { player = 0.50, society = 0.50 },  -- Manager
    [3] = { player = 0.75, society = 0.25 },  -- Brigadier
    [4] = { player = 0.00, society = 1.00 }   -- Boss
}

function CalculateSaleSplit(grade, totalAmount)
    local split = Config.SaleSplit[grade] or { player = 0.0, society = 1.0 }
    local playerAmount = math.floor(totalAmount * split.player)
    local societyAmount = totalAmount - playerAmount
    return playerAmount, societyAmount
end




Config.ShopNPC = {
    model = "mp_m_shopkeep_01",
    coords = vec4(-58.2537, 6522.5308, 31.4908, 319.0894),
    icon = "fa-solid fa-store",
    targetLabel = "Nakoupit suroviny",
    requiredJob = "pivovar",
    items = {
        { name = "cornbag", label = "Pytel kukuřice", price = 15 },
        { name = "yeast", label = "Kvasnice", price = 25 },
        { name = "hop", label = "Chmel", price = 30 },
        { name = "dirty_bottle2", label = "Špinavá láhev na lihoviny", price = 5 },
        { name = "barleybag", label = "Pytel ječmene", price = 20 }
        

    }
}




Config.RequiredJob = "pivovar"

Config.CraftingZones = {


    {
        coords = vec3(-53.1422, 6426.6831, 32.4901),
        type = "destilace",
        label = "Destilace Piva"
    },
}


Config.CraftOptions = {
    destilace = {
        { title = "Výroba Piva", event = "pivovar:craft", args = "pivo1" }
    }
}

Config.Recipes = {
    pivo1 = {
        requires = {
            { name = "water", amount = 5 },
            { name = "cornbag", amount = 3 },
            { name = "yeast", amount = 3 },
            { name = "bottle2", amount = 5 },
            { name = "hop", amount = 2 },
            { name = "lemon", amount = 1 },
            { name = "barleybag", amount = 2 }
        },
        result = "beer",
        outputAmount = 5,
        duration = 30000,
        success = "Vyrobil jsi Pivo."
    }
}
