fx_version 'bodacious'
games { 'rdr3', 'gta5' }

description 'DBFWCore'
version '1.0.0'


server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua',
	's_chopshop.lua'
}

client_script {
	'client.lua',
	'illegal_parts.lua',
	'chopshop.lua',
	'gui.lua'
}
