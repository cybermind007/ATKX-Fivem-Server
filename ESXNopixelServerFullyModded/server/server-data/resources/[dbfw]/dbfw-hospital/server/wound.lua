local playerInjury = {}

function GetCharsInjuries(source)
    return playerInjury[source]
end

RegisterServerEvent('dbfw-hospital:server:SyncInjuries')
AddEventHandler('dbfw-hospital:server:SyncInjuries', function(data)
    playerInjury[source] = data
end)