shared_script '@ox_lib/init.lua'

fx_version 'cerulean'
game 'gta5'

description 'Lihovar Job '
author 'Lejgi'
version '1.1.0'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_script 'config.lua'

client_script 'client/client.lua'
client_script 'client/buy.lua'
client_script 'client/sell.lua'
client_script 'client/bottle.lua'
client_script 'client/blips.lua'
client_script 'client/harvest.lua'
server_script 'server/server.lua'
server_script '@mysql-async/lib/MySQL.lua'

dependency 'ox_lib'
