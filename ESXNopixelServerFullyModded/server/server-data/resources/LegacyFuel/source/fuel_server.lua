DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('fuel:pay')
AddEventHandler('fuel:pay', function(price)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local amount = DBFWCore.Math.Round(price)

	if price > 0 then
		xPlayer.removeMoney(amount)
	end
end)



RegisterServerEvent('fuel:addcan')
AddEventHandler('fuel:addcan', function()
	local item = "WEAPON_PETROLCAN"
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	xPlayer.addInventoryItem(item, 1)
end)


