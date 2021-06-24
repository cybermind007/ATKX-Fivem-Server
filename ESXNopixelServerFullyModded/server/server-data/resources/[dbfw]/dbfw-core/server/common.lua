DBFWCore                      = {}
DBFWCore.Players              = {}
DBFWCore.UsableItemsCallbacks = {}
DBFWCore.Items                = {}
DBFWCore.ServerCallbacks      = {}
DBFWCore.TimeoutCount         = -1
DBFWCore.CancelledTimeouts    = {}
DBFWCore.LastPlayerData       = {}
DBFWCore.Pickups              = {}
DBFWCore.PickupId             = 0
DBFWCore.Jobs                 = {}

AddEventHandler('dbfw:getSharedObject', function(cb)
	cb(DBFWCore)
end)

function getSharedObject()
	return DBFWCore
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for i=1, #result, 1 do
			DBFWCore.Items[result[i].name] = {
				label     = result[i].label,
				limit     = result[i].limit,
				rare      = (result[i].rare       == 1 and true or false),
				canRemove = (result[i].can_remove == 1 and true or false),
			}
		end
	end)

	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result do
		DBFWCore.Jobs[result[i].name] = result[i]
		DBFWCore.Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2 do
		if DBFWCore.Jobs[result2[i].job_name] then
			DBFWCore.Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
		else
			print(('dbfw-core: invalid job "%s" from table job_grades ignored!'):format(result2[i].job_name))
		end
	end

	for k,v in pairs(DBFWCore.Jobs) do
		if next(v.grades) == nil then
			DBFWCore.Jobs[v.name] = nil
			print(('dbfw-core: ignoring job "%s" due to missing job grades!'):format(v.name))
		end
	end
end)

AddEventHandler('dbfw:playerLoaded', function(source)
	local xPlayer         = DBFWCore.GetPlayerFromId(source)
	local accounts        = {}
	local items           = {}
	local xPlayerAccounts = xPlayer.getAccounts()

	for i=1, #xPlayerAccounts, 1 do
		accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
	end

	DBFWCore.LastPlayerData[source] = {
		accounts = accounts,
		items    = items
	}
end)

RegisterServerEvent('dbfw:clientLog')
AddEventHandler('dbfw:clientLog', function(msg)
	RconPrint(msg .. "\n")
end)

RegisterServerEvent('dbfw:triggerServerCallback')
AddEventHandler('dbfw:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	DBFWCore.TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('dbfw:serverCallback', _source, requestId, ...)
	end, ...)
end)
