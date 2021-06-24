DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('dbfw-uberkdshfksksdhfskdjjob:pay')
AddEventHandler('dbfw-uberkdshfksksdhfskdjjob:pay', function(amount)
	local _source = source
	local xPlayer = DBFWCore.GetPlayerFromId(_source)
	xPlayer.addMoney(tonumber(amount))
	TriggerClientEvent('chatMessagess', _source, '', 4, 'You got payed $' .. amount)
end)
