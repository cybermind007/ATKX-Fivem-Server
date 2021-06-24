DBFWCore               = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

----
DBFWCore.RegisterUsableItem('gauze', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('gauze', 1)

	TriggerClientEvent('dbfw-hospital:items:gauze', source)
end)

DBFWCore.RegisterUsableItem('bandaids', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bandaids', 1)

	TriggerClientEvent('dbfw-hospital:items:bandage', source)
end)

DBFWCore.RegisterUsableItem('firstaid', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('firstaid', 1)

	TriggerClientEvent('dbfw-hospital:items:firstaid', source)
end)

DBFWCore.RegisterUsableItem('vicodin', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vicodin', 1)

	TriggerClientEvent('dbfw-hospital:items:vicodin', source)
end)

DBFWCore.RegisterUsableItem('ifak', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('ifak', 1)

	TriggerClientEvent('dbfw-hospital:items:ifak', source)
end)

DBFWCore.RegisterUsableItem('hydrocodone', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('hydrocodone', 1)

	TriggerClientEvent('dbfw-hospital:items:hydrocodone', source)
end)

DBFWCore.RegisterUsableItem('morphine', function(source)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('morphine', 1)

	TriggerClientEvent('dbfw-hospital:items:morphine', source)
end)
