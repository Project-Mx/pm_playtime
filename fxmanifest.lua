fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Project M'
version '1.0'



client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

escrow_ignore {
	'config.lua'
}