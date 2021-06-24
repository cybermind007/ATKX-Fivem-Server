DBFWCore               = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

DBFWCore.RegisterUsableItem('binoculars', function(source)
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local drill = xPlayer.getInventoryItem('binoculars')

    TriggerClientEvent('binoculars:Activate', source)
end)