DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj)
	DBFWCore = obj
end)

RegisterServerEvent('chickenpayment:pay')
AddEventHandler('chickenpayment:pay', function()
local _source = source
local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.addMoney(math.random(55,76))
end)