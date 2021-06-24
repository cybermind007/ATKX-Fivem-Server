fx_version 'adamant'
games { 'gta5' }

migration_files {
    'migrations/0001_create_user.cs',
	'migrations/0002_add_roles.cs'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua'
}

dependencies {
	'dbfw-base',
	'mysql-async'
}