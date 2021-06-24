resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'


client_scripts {
  '@dbfw-core/locale.lua',
  'locales/en.lua',
  'client/chicken_c.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  '@dbfw-core/locale.lua',
  'locales/en.lua',
  'server/chicken_s.lua',
}

dependencies {
	'dbfw-core'
}