RegisterServerEvent("dbfw-alerts:teenA")
AddEventHandler("dbfw-alerts:teenA",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:policealertA', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:teenB")
AddEventHandler("dbfw-alerts:teenB",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:policealertB', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:teenpanic")
AddEventHandler("dbfw-alerts:teenpanic",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:panic', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:fourA")
AddEventHandler("dbfw-alerts:fourA",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:tenForteenA', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:fourB")
AddEventHandler("dbfw-alerts:fourB",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:tenForteenB', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:downperson")
AddEventHandler("dbfw-alerts:downperson",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:downalert', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:sveh")
AddEventHandler("dbfw-alerts:sveh",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:vehiclesteal', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:shoot")
AddEventHandler("dbfw-alerts:shoot",function(targetCoords)
    TriggerClientEvent('dbfw-outlawalert:gunshotInProgress', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:figher")
AddEventHandler("dbfw-alerts:figher",function(targetCoords)
    TriggerClientEvent('dbfw-outlawalert:combatInProgress', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:storerob")
AddEventHandler("dbfw-alerts:storerob",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:storerobbery', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:houserob")
AddEventHandler("dbfw-alerts:houserob",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:houserobbery', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:tbank")
AddEventHandler("dbfw-alerts:tbank",function(targetCoords)
    TriggerClientEvent('dbfw-alerts:banktruck', -1, targetCoords)
	return
end)

RegisterServerEvent("dbfw-alerts:robjew")
AddEventHandler("dbfw-alerts:robjew",function()
    TriggerClientEvent('dbfw-alerts:jewelrobbey', -1)
	return
end)

RegisterServerEvent("dbfw-alerts:bjail")
AddEventHandler("dbfw-alerts:bjail",function()
    TriggerClientEvent('dbfw-alerts:jewelrobbey', -1)
	return
end)