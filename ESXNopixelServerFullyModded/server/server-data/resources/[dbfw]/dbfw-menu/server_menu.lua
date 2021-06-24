DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj)
    DBFWCore = obj
end)

RegisterServerEvent('dbfw-interactions:putInVehicle')
AddEventHandler('dbfw-interactions:putInVehicle', function(target)
    TriggerClientEvent('dbfw-interactions:putInVehicle', target)
end)

RegisterServerEvent('dbfw-interactions:outOfVehicle')
AddEventHandler('dbfw-interactions:outOfVehicle', function(target)
    TriggerClientEvent('dbfw-interactions:outOfVehicle', target)
end)
