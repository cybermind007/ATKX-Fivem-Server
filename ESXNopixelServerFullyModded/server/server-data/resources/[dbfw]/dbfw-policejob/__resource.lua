resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Police Job'

version '1.3.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@dbfw-core/locale.lua',
	'locales/en.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@dbfw-core/locale.lua',
	'locales/en.lua',
	'config.lua',
	'client/main.lua',
	'client/client_trunk.lua',
	'client/gui.lua'
	--'client/evidence.lua',
	
}

dependencies {
	'dbfw-core'
}