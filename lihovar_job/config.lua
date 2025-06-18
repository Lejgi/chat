Config = {}

Config.RequiredJob = "lihovar"

Config.HarvestCenter = vector3(349.99, 6517.27, 28.6)
Config.HarvestRadius = 20.0
Config.MaxPlants = 20
Config.PlantModel = `prop_plant_01a`
Config.HarvestTime = 5000


Config.BuyerNPC = {
    model = "s_m_m_dockwork_01",
    coords = vec4(3798.9663, 4446.5811, 4.3378, 329.3774),
    targetLabel = "Prodej surovin",
    icon = "fa-solid fa-hand-holding-dollar",
    requiredJob = "lihovar",
    items = {
        { name = "corona", label = "Coruna Beer", price = 1900 },        
        { name = "vodka", label = "Láhev Vodky", price = 2400 },        
        { name = "rhum", label = "Láhev Rumu", price = 2450 },           
        { name = "gin", label = "Láhev Ginu", price = 2500 },
        { name = "slivovice", label = "Láhev Švestkovice", price = 2600 },
        { name = "whisky", label = "Láhev Whiskey", price = 2700 },
        { name = "shot_captain", label = "Captain Danken", price = 2750 } 
        
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
    coords = vec4(-56.9761, 6521.2544, 31.4908, 315.4835),
    icon = "fa-solid fa-store",
    targetLabel = "Nakoupit suroviny",
    requiredJob = "lihovar",
    items = {
        { name = "cukr", label = "Cukr", price = 15 },            
        { name = "ovoce", label = "Ovoce", price = 25 },          
        { name = "bylinky", label = "Bylinky", price = 30 },       
        { name = "water", label = "Kanystr vody", price = 10 }, 
        { name = "dirty_bottle2", label = "Špinavá láhev na lihoviny", price = 5 }, 
        { name = "bottle2", label = "Láhev na lihoviny", price = 60 }, 
        { name = "sugarcane", label = "Cukrová třtina", price = 25 }  
        

    }
}




Config.RequiredJob = "lihovar"

Config.CraftingZones = {


    {
        coords = vec3(-139.6086, 6290.1304, 31.6617),
        type = "destilace",
        label = "Destilace lihovin"
    },
}


Config.CraftOptions = {
    destilace = {
        { title = "Výroba Ginu", event = "lihovar:craft", args = "gin" },
        { title = "Výroba Švestkovice", event = "lihovar:craft", args = "slivovice" },
        { title = "Výroba Whiskey", event = "lihovar:craft", args = "whisky" },
        { title = "Výroba Vodky", event = "lihovar:craft", args = "vodka" },
        { title = "Výroba Rumu", event = "lihovar:craft", args = "rhum" },
        { title = "Výroba Piva Coruna", event = "lihovar:craft", args = "coruna" },
        { title = "Výroba Caption Dankena", event = "lihovar:craft", args = "danken" }
    }
}

Config.Recipes = {
    gin = {
        requires = {
            { name = "water", amount = 2 },
            { name = "cukr", amount = 8 },
            { name = "bylinky", amount = 5 },
            { name = "bottle2", amount = 10 }
        },
        result = "gin",
        outputAmount = 10,
        success = "Vyrobil jsi Gin."
    },
    danken = {
        requires = {
            { name = "water", amount = 2 },
            { name = "cukr", amount = 9 },
            { name = "sugarcane", amount = 5 },
            { name = "bottle2", amount = 10 }
        },
        result = "shot_captain",
        outputAmount = 10,
        success = "Vyrobil jsi Captain Dankena."
    },
    slivovice = {
        requires = {
            { name = "water", amount = 2 },
            { name = "cukr", amount = 8 },
            { name = "ovoce", amount = 5 },
            { name = "bottle2", amount = 10 }
        },
        result = "slivovice",
        outputAmount = 10,
        success = "Vyrobil jsi Švestkovici."
    },
    whisky = {
        requires = {
            { name = "water", amount = 2 },
            { name = "cukr", amount = 9 },
            { name = "obili", amount = 5 },
            { name = "bottle2", amount = 10 }
        },
        result = "whisky",
        outputAmount = 10,
        success = "Vyrobil jsi Whiskey."
    },
    vodka = {
        requires = {
            { name = "water", amount = 2 },
            { name = "cukr", amount = 10 },
            { name = "bottle2", amount = 10 }
        },
        result = "vodka",
        outputAmount = 10,
        success = "Vyrobil jsi Vodku."
    },
    rhum = {
        requires = {
            { name = "water", amount = 2 },
            { name = "cukr", amount = 9 },
            { name = "ovoce", amount = 5 },
            { name = "bottle2", amount = 10 }
        },
        result = "rhum",
        outputAmount = 10,
        success = "Vyrobil jsi Rum."
    },
    coruna = {
        requires = {
            { name = "water", amount = 2 },
            { name = "obili", amount = 6 },
            { name = "bottle2", amount = 10 }
        },
        result = "corona",
        outputAmount = 10,
        success = "Uvařil jsi pivo Coruna."
    }
}
