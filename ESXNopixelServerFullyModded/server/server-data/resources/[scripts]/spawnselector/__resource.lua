fx_version 'adamant'

game 'gta5'

description 'Spawn Selector for wise'

version '1.0.0'


ui_page 'ui/index.html'
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'sv_spawn.lua'
}

client_scripts {
	'cl_spawn.lua',
}

files{
    "ui/index.html",
    "ui/main.js",
    "ui/style.css",
    "ui/bg.png"
}





