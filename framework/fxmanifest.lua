fx_version 'cerulean'
game 'gta5'

name 'EletroCast Framework'
author 'EletroCast Team'
version '1.0.0'
description 'Comprehensive FiveM framework combining VRP and QBCore features'

dependencies {
    'ox_lib',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/utils.lua',
    'shared/functions.lua',
    'config/config.lua',
    'config/jobs.lua',
    'config/items.lua',
    'config/vehicles.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/database.lua',
    'server/player.lua',
    'server/economy.lua',
    'server/inventory.lua',
    'server/jobs.lua'
}

client_scripts {
    'client/main.lua',
    'client/player.lua',
    'client/ui.lua',
    'client/jobs.lua'
}

files {
    'sql/framework.sql'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'