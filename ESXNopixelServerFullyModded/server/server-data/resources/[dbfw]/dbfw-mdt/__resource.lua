-- This resource is licensed to Inland Empire Roleplay as a thank you for a non-refundable donation of 50USD.
-- Do not sell, or share this resource to any unlicensed parties. 
-- Also, please don't claim this code as your own without my permission, thank you. <3

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page "ui/index.html"

files {
    "ui/index.html",
    "ui/vue.min.js",
    "ui/script.js",
    "ui/badge.png",
	"ui/footer.png",
	"ui/mugshot.png"
}

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	"sv_mdt.lua",
	"sv_vehcolors.lua"
}

client_script "cl_mdt.lua"
