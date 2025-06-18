
ESX = exports["es_extended"]:getSharedObject()

for categoryName, category in pairs(Config.CraftOptions) do
    for _, option in pairs(category) do
        if option.event == "redwood:craft" and option.args then
            local recipe = Config.Recipes[option.args]
            if recipe then
                local desc = {}
                for _, item in ipairs(recipe.requires) do
                    table.insert(desc, item.amount .. "x " .. item.name)
                end
                option.description = table.concat(desc, ", ")
            end
            option.onSelect = function()
                TriggerServerEvent("redwood:craft", option.args)
            end
        end
    end
end

local icons = {
    process = "fa-solid fa-leaf",
    cigarettes = "fa-solid fa-smoking",
    cigars = "fa-solid fa-fire",
    pack = "fa-solid fa-box"
}

local labels = {
    process = "Zpracování tabáku",
    cigarettes = "Výroba cigaret",
    cigars = "Výroba doutníků",
    pack = "Balení produktů"
}

local craftingZoneIds = {}

local function registerCraftingTargets()
    for _, id in pairs(craftingZoneIds) do
        exports.ox_target:removeZone(id)
    end
    craftingZoneIds = {}

    local data = ESX.GetPlayerData()
    if not data or not data.job or data.job.name ~= Config.RequiredJob then
        return
    end

    for i, zone in pairs(Config.CraftingZones) do
        local id = "redwood_craft_target_" .. i

        exports.ox_target:addBoxZone({
            name = id,
            coords = zone.coords,
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            options = {{
                icon = icons[zone.type] or "fa-solid fa-cogs",
                label = labels[zone.type] or "Výroba",
                onSelect = function()
                    local menuId = 'redwood_menu_' .. zone.type
                    lib.registerContext({
                        id = menuId,
                        title = labels[zone.type] or zone.label,
                        options = Config.CraftOptions[zone.type] or {}
                    })
                    lib.showContext(menuId)
                end
            }}
        })

        table.insert(craftingZoneIds, id)
    end
end

RegisterNetEvent('redwood:playCraftAnim', function(type)
    local recipe = Config.Recipes[type]
    if not recipe then return end

    local dict = "mini@repair"
    local anim = "fixing_a_ped"
    lib.requestAnimDict(dict)

    local duration = recipe.duration or 3000

    lib.progressBar({
        duration = duration,
        label = 'Probíhá výroba...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = dict,
            clip = anim
        }
    })

    TriggerServerEvent('redwood:finishCraft', type)
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(100) end
    registerCraftingTargets()
end)

RegisterNetEvent('esx:setJob', function(job)
    Wait(250)
    registerCraftingTargets()
end)
