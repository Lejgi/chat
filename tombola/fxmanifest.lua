fx_version 'cerulean'
game 'gta5'

lua54 'yes'
description 'Tombola systém pro více jobů'
author 'Lejgi '
version '1.0.0'

dependency 'ox_lib'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
    'html/index.html'
}

nui_background 'none'

