resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'



server_scripts {
	"config.lua",
	'@mysql-async/lib/MySQL.lua',
	"server/sv.lua",
}

client_scripts {
	"config.lua",
	"client/carhud.lua",
}


ui_page('html/index.html')
files({
	"html/index.html",
	"html/script.js",
	"html/styles.css",
	"html/img/*.svg",
	"html/img/*.png",
	'html/gta-ui.ttf'
})

exports {
	"playerLocation",
	"playerZone"
}
