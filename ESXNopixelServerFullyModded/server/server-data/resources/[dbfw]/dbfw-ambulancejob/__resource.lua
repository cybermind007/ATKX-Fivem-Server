resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'EMS'

version '1.2.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@dbfw-core/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@dbfw-core/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',
	'config.lua',
	'client/main.lua',
	'client/gui.lua',
	'client/job.lua'
}

dependencies {
	'dbfw-core',
}

exports {
    'GetDeath',
}