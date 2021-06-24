
description 'dbfw loading screen'

files {
    'loading.html',
    'style.css',
    'music/music.ogg'
}

loadscreen 'loading.html'
loadscreen_manual_shutdown "yes"
client_script "client.lua"