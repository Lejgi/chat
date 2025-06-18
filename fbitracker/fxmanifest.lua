fx_version 'cerulean'
game 'gta5'

author 'Lejgi'
description 'FBI Tracker System - Kompletní systém GPS sledování, FBI Tablet, Instalace na hráče'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

lua54 'yes'