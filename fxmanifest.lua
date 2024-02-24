fx_version 'adamant'

game 'gta5'

lua54 'yes'

author 'HUEHUE'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/cl_*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv*.lua'
} 