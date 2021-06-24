fx_version 'bodacious'
games { 'rdr3', 'gta5' }

version '1.0.0'

ui_page 'nui/ui.html'

files {
	'nui/ui.html',
	'nui/pricedown.ttf',
	'nui/default.png',
	'nui/background.png',
	'nui/invbg.png',
	'nui/styles.css',
	'nui/scripts.js',
	'nui/debounce.min.js',
	'nui/loading.gif',
	'nui/loading.svg',
	'nui/icons/*',
}

shared_script 'shared_list.js'
client_script 'client.js'
client_script 'functions.lua'
server_script 'server.js'
server_script 'sv_functions.lua'
server_script '@mysql-async/lib/MySQL.lua'
server_script '@dbfw-core/locale.lua'
client_script '@dbfw-core/locale.lua'

exports{
	'getCash',
	'hasEnoughOfItem',
	'getQuantity',
	'GetCurrentWeapons',
	'GetItemInfo'
}