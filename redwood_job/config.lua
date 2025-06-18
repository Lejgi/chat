Config = {}

Config.Locale = 'en'
Config.Lang = {
    en = {
        ['Sber tabaku'] = 'Collect tobacco',
        ['Vyroba Redwood'] = 'Redwood Production',
        ['Koupe surovin'] = 'Buy Supplies',
        ['Prodej produktu'] = 'Sell Products',
        ['Sesbírat tabák'] = 'Harvest tobacco',
        ['Nákup: '] = 'Purchase: ',
        ['Prodej: '] = 'Sell: ',
        ['Kolik chceš koupit?'] = 'How many do you want to buy?',
        ['Kolik chceš prodat?'] = 'How many do you want to sell?',
        ['Nemáš nic na prodej.'] = 'Nothing to sell.',
        ['Výkup surovin'] = 'Material Buyer',
        ['redwood obchod'] = 'Redwood Shop',
        ['Zpracování tabáku'] = 'Tobacco Processing',
        ['Výroba cigaret'] = 'Make Cigarettes',
        ['Výroba doutníků'] = 'Make Cigars',
        ['Balení'] = 'Packing',
        ['Probíhá výroba...'] = 'Processing...'
    },
    cz = {}
}

function _L(key)
    local lang = Config.Lang[Config.Locale] or {}
    return lang[key] or key
end

Config.RequiredJob = "redwood"

Config.HarvestCenter = vector3(2845.7898, 4608.7529, 47.9798)
Config.HarvestRadius = 20.0
Config.MaxPlants = 5
Config.PlantModel = `prop_plant_01a`
Config.HarvestTime = 5000


Config.BuyerNPC = {
    model = "s_m_m_dockwork_01",
    coords = vec4(2145.3823, 4774.7847, 41.0054, 23.7466),
    targetLabel = "Prodej surovin",
    icon = "fa-solid fa-hand-holding-dollar",
    requiredJob = "redwood",
    items = {
        { name = "karton_lucky", label = "Karton Lucky Smoke", price = 2750 },        
        { name = "karton_nofilter", label = "Karton bezfiltr cigaret", price = 2750 },    
        { name = "karton_vanilla", label = "Karton vanilkových cigaret", price = 2750 }, 
        
        { name = "krabicka_doutniku_vanilka", label = "Krabička vanilkových doutníků", price = 2750 }, 
        { name = "krabicka_doutniku", label = "Krabička doutníků", price = 2750 },                     
        { name = "karton_cigaret", label = "Karton cigaret Redwood", price = 2750 }                  
        
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
    coords = vec4(-59.3794, 6523.7188, 31.4908, 311.3297),
    icon = "fa-solid fa-store",
    targetLabel = "Nakoupit suroviny",
    requiredJob = "redwood",
    items = {
        { name = "aroma_vanilka", label = "Aroma Vanilka", price = 25 },   
        { name = "aroma_mata", label = "Aroma Máta", price = 25 },          
        { name = "krabicka_prazdna", label = "Prázdná krabička", price = 20 }, 
        { name = "cigaretovy_papirek", label = "Cigaretový papírek", price = 12 },
        { name = "cigaretovy_filtr", label = "Cigaretový filtr", price = 12 }, 
        { name = "drevena_krabicka", label = "Dřevěná krabička", price = 35 }, 
        { name = "igelit_baleni", label = "Igelitové balení", price = 30 }, 
        { name = "doutnikova_paska", label = "Páska na doutník", price = 20 }  
        
    }
}




Config.RequiredJob = "redwood"

Config.CraftingZones = {
    {
        coords = vec3(2913.0964, 4475.8999, 48.3450),
        type = "process",
        label = "Zpracování tabáku"
    },
    {
        coords = vec3(2922.6436, 4473.1499, 48.2982),
        type = "cigarettes",
        label = "Výroba cigaret"
    },
    {
        coords = vec3(2924.6011, 4474.6680, 48.3902),
        type = "cigars",
        label = "Výroba doutníků"
    },
    {
        coords = vec3(2918.9180, 4470.2520, 48.3944),
        type = "pack",
        label = "Balení"
    }
}

Config.CraftOptions = {
    process = {
        { title = "Zpracování listů", event = "redwood:craft", args = "celylist" },
        { title = "Třídění listů", event = "redwood:craft", args = "trideni" },
        { title = "Sušení tabáku", event = "redwood:craft", args = "suseni" },
        { title = "Čištění tabáku", event = "redwood:craft", args = "ocisteni" },
        { title = "Krájení tabáku", event = "redwood:craft", args = "krajenie" }
    },
    cigarettes = {
        { title = "Cigarety Redwood", event = "redwood:craft", args = "cigarettes" },
        { title = "Cigarety Lucky Smoke", event = "redwood:craft", args = "lucky" },
        { title = "Bezfiltr cigarety", event = "redwood:craft", args = "nofilter" },
        { title = "Vanilkové cigarety", event = "redwood:craft", args = "vanilla" }
    },
    cigars = {
        { title = "Doutník", event = "redwood:craft", args = "cigars" },
        { title = "Vanilkový doutník", event = "redwood:craft", args = "cigar_vanilla" },
        { title = "Krabička doutníků", event = "redwood:craft", args = "box_cigar" },
        { title = "Krabička vanilkových", event = "redwood:craft", args = "box_cigar_vanilla" }
    },
    pack = {
        { title = "Karton cigaret", event = "redwood:craft", args = "karton" },
        { title = "Karton Lucky", event = "redwood:craft", args = "karton_lucky" },
        { title = "Karton Bezfiltr", event = "redwood:craft", args = "karton_nofilter" },
        { title = "Karton Vanilkové", event = "redwood:craft", args = "karton_vanilla" }

    }
}

Config.Recipes = {
    trideni = {
        requires = { { name = "tabak_surovy", amount = 4 } },
        result = "tabak_trideny",
        outputAmount = 3,
        success = "Třídíš tabák."
    },
    celylist = {
        requires = { { name = "tabak_cely", amount = 1 } },
        result = "tabak_surovy",
        outputAmount = 3,
        success = "Třídíš tabák."
    },
    suseni = {
        requires = { { name = "tabak_trideny", amount = 3 } },
        result = "tabak_suseny",
        outputAmount = 3,
        success = "Sušíš tabák."
    },
    ocisteni = {
        requires = { { name = "tabak_suseny", amount = 3 } },
        result = "tabak_ocisteny",
        outputAmount = 3,
        success = "Čistíš tabák."
    },
    krajenie = {
        requires = { { name = "tabak_ocisteny", amount = 3 } },
        result = "tabak_krajeny",
        outputAmount = 3,
        success = "Krájíš tabák."
    },

    cigarettes = {
        requires = {
            { name = "tabak_krajeny", amount = 50 },
            { name = "cigaretovy_papirek", amount = 10 },
            { name = "cigaretovy_filtr", amount = 10 },
            { name = "krabicka_prazdna", amount = 10 }
        },
        result = "krabicka_cigaret",
        outputAmount = 10,
        duration = 4000,
        success = "Vyrobil jsi 10x krabiček cigaret."
    },
    lucky = {
        requires = {
            { name = "tabak_krajeny", amount = 50 },
            { name = "cigaretovy_papirek", amount = 10 },
            { name = "cigaretovy_filtr", amount = 10 },
            { name = "krabicka_prazdna", amount = 10 },
            { name = "aroma_mata", amount = 10 }
        },
        result = "krabicka_lucky",
        outputAmount = 10,
        duration = 4000,
        success = "Vyrobil jsi 10x Lucky Smoke cigaret."
    },
    nofilter = {
        requires = {
            { name = "tabak_krajeny", amount = 50 },
            { name = "cigaretovy_papirek", amount = 10 },
            { name = "krabicka_prazdna", amount = 10 }
        },
        result = "krabicka_nofilter",
        outputAmount = 10,
        duration = 4000,
        success = "Vyrobil jsi 10x bezfiltr cigaret."
    },
    vanilla = {
        requires = {
            { name = "tabak_krajeny", amount = 50 },
            { name = "cigaretovy_papirek", amount = 10 },
            { name = "cigaretovy_filtr", amount = 10 },
            { name = "krabicka_prazdna", amount = 10 },
            { name = "aroma_vanilka", amount = 10 }
        },
        result = "krabicka_vanilla",
        outputAmount = 10,
        duration = 4000,
        success = "Vyrobil jsi 10x vanilkových cigaret."
    },

    cigars = {
        requires = {
            { name = "tabak_ocisteny", amount = 5 },
            { name = "tabak_cely", amount = 1 },
            { name = "doutnikova_paska", amount = 1 }
        },
        result = "doutnik",
        outputAmount = 5,
        duration = 4000,
        success = "Vyrobil jsi 5x doutníků."
    },
    cigar_vanilla = {
        requires = {
            { name = "tabak_cely", amount = 2 },
            { name = "doutnikova_paska", amount = 2 },
            { name = "aroma_vanilka", amount = 2 }
        },
        result = "doutnik_vanilla",
        outputAmount = 2,
        duration = 4000,
        success = "Vyrobil jsi vanilkový doutník."
    },

    box_cigar = {
        requires = {
            { name = "doutnik", amount = 5 },
            { name = "drevena_krabicka", amount = 1 }
        },
        result = "krabicka_doutniku",
        outputAmount = 1,
        duration = 4000,
        success = "Zabalil jsi 5x doutníků do krabičky."
    },
    box_cigar_vanilla = {
        requires = {
            { name = "doutnik_vanilla", amount = 5 },
            { name = "drevena_krabicka", amount = 1 }
        },
        result = "krabicka_doutniku_vanilka",
        outputAmount = 1,
        duration = 4000,
        success = "Zabalil jsi 5x vanilkových doutníků."
    },

    karton = {
        requires = {
            { name = "krabicka_cigaret", amount = 10 },
            { name = "igelit_baleni", amount = 1 }
        },
        result = "karton_cigaret",
        outputAmount = 1,
        duration = 4000,
        success = "Zabalil jsi karton cigaret."
    },
    karton_lucky = {
        requires = {
            { name = "krabicka_lucky", amount = 10 },
            { name = "igelit_baleni", amount = 1 }
        },
        result = "karton_lucky",
        outputAmount = 1,
        duration = 4000,
        success = "Zabalil jsi karton Lucky Smoke cigaret."
    },
    karton_nofilter = {
        requires = {
            { name = "krabicka_nofilter", amount = 10 },
            { name = "igelit_baleni", amount = 1 }
        },
        result = "karton_nofilter",
        outputAmount = 1,
        duration = 4000,
        success = "Zabalil jsi karton bezfiltr cigaret."
    },
    karton_vanilla = {
        requires = {
            { name = "krabicka_vanilla", amount = 10 },
            { name = "igelit_baleni", amount = 1 }
        },
        result = "karton_vanilla",
        outputAmount = 1,
        duration = 4000,
        success = "Zabalil jsi karton vanilkových cigaret."
    }
}

