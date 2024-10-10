fx_version 'bodacious'
game 'gta5'
lua54 'yes'
description 'ultrax_garaze //krez1#6045'
version '1.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	'client.lua',
	'config.lua',
}

server_scripts {
	'server.lua',
	'config.lua',
	'@oxmysql/lib/MySQL.lua',
}

