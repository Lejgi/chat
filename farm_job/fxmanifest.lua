fx_version 'cerulean'
game 'gta5'

description 'Example farm job using ESX, ox_inventory, ox_lib and ox_target'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_inventory',
    'ox_lib',
    'ox_target'
}
