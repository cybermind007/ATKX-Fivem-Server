fx_version 'bodacious'
games { 'rdr3', 'gta5' }

author 'Ghost'
description 'dbfw Vehicle Damage'
version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua',
}

client_scripts {
	'client.lua',
}