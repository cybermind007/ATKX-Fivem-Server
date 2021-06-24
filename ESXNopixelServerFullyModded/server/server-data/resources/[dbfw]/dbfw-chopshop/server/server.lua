DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('dbfw-chopshop:addCash')
AddEventHandler('dbfw-chopshop:addCash', function()
	local _source = source
	local xPlayer = DBFWCore.GetPlayerFromId(_source)
	local randomChance = math.random(0, 2)
	local money = math.random(100, 250)
	local payout = math.random(2,4)
	if xPlayer ~= nil then	
		if randomChance == 0 then
			Citizen.Wait(5)
			TriggerClientEvent('player:receiveItem', _source,'scrapmetal', payout)
			TriggerClientEvent('player:receiveItem', _source, 'rubber', payout)
			xPlayer.addMoney(money)
		elseif randomChance == 1 then
			Citizen.Wait(5)
			TriggerClientEvent('player:receiveItem', _source, 'glass', payout)
			TriggerClientEvent('player:receiveItem', _source, 'steel', payout)
			TriggerClientEvent('player:receiveItem', _source, 'plastic', payout)
			xPlayer.addMoney(money)
		elseif randomChance == 2 then
			TriggerClientEvent('player:receiveItem', _source, 'electronics', payout)
			TriggerClientEvent('player:receiveItem', _source, 'aluminium', payout)
			TriggerClientEvent('player:receiveItem', _source, 'copper', payout)
			xPlayer.addMoney(money)
		end
	end
end)

function RemoveOwnedVehicle(plate)
	MySQL.Async.execute('DELETE FROM '..Config.SQLOwnedVehicleTable..' WHERE '..Config.SQLVehiclePlateColoumn..' = @'..Config.SQLVehiclePlateColoumn, {
		['@'..Config.SQLVehiclePlateColoumn] = plate
	})
end

function SaveInfoToDatabase(plate, ownername, choppedcarname, choppername, chopperidentifier)
	MySQL.Async.execute('INSERT INTO '..Config.SQLChopInfoTable..' ('..Config.SQLChopPlateColoumn..', '..Config.SQLChopCarOwnerColoumn..', '..Config.SQLChopCarModelColoumn..', '..Config.SQLChoppperNameColoumn..', '..Config.SQLChoppperIdentifierColoumn..') VALUES (@'..Config.SQLChopPlateColoumn..', @'..Config.SQLChopCarOwnerColoumn..', @'..Config.SQLChopCarModelColoumn..', @'..Config.SQLChoppperNameColoumn..', @'..Config.SQLChoppperIdentifierColoumn..')',
	{
		['@'..Config.SQLChopPlateColoumn]   = plate,
		['@'..Config.SQLChopCarOwnerColoumn]   = ownername,
		['@'..Config.SQLChopCarModelColoumn]   = choppedcarname,
		['@'..Config.SQLChoppperNameColoumn]   = choppername,
		['@'..Config.SQLChoppperIdentifierColoumn]   = chopperidentifier,

	}, function (rowsChanged)
	end)
end

DBFWCore.RegisterServerCallback('dbfw-chopshop:isdead', function(source, cb)
	local identifier = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchScalar('SELECT '..Config.SQLPlayerIsDeadColoumn..' FROM '..Config.SQLPlayerInfoTable..' WHERE '..Config.SQLPlayerIdentifierColoumn..' = @'..Config.SQLPlayerIdentifierColoumn, {
		['@'..Config.SQLPlayerIdentifierColoumn] = identifier
	}, function(isDead)
		cb(isDead)
	end)
end)

DBFWCore.RegisterServerCallback('dbfw-chopshop:getVehInfos', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT '..Config.SQLVehicleOwnerColoumn..' FROM '..Config.SQLOwnedVehicleTable..' WHERE '..Config.SQLVehiclePlateColoumn..' = @'..Config.SQLVehiclePlateColoumn, {
		['@'..Config.SQLVehiclePlateColoumn] = plate
	}, function(result)
		local retrivedInfo = {
			plate = plate
		}
		if result[1] then
			MySQL.Async.fetchAll('SELECT '..Config.SQLPlayerNameColoumn..', '..Config.SQLPlayerFirstNameColoumn..', '..Config.SQLPlayerLastNameColoumn..' FROM '..Config.SQLPlayerInfoTable..' WHERE '..Config.SQLPlayerIdentifierColoumn..' = @'..Config.SQLPlayerIdentifierColoumn,  {
				['@'..Config.SQLPlayerIdentifierColoumn] = result[1].owner
			}, function(result2)

				if Config.EnableDBFWCoreIdentity then
					retrivedInfo.owner = result2[1].firstname .. ' ' .. result2[1].lastname
				else
					retrivedInfo.owner = result2[1].name
				end

				cb(retrivedInfo)
			end)
		else
			cb(retrivedInfo)
		end
	end)
end)