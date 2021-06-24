resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

fx_version 'bodacious'
games { 'rdr3', 'gta5' }

client_script {
  "client.lua",
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}


export "GetClosestNPC"
export "IsPedNearCoords"
export "isPed"
export "GroupRank"
export "GlobalObject"
export "retreiveBusinesses"