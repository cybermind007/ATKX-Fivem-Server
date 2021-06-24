DBFWCore = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)


function getMoney(playerId)
	local player = DBFWCore.GetPlayerFromId(playerId)

	if player ~= nil then
		local money = player.getMoney()
		return money
	end
end

function addMoney(playerId, amount)
	local player = DBFWCore.GetPlayerFromId(playerId)

	if player ~= nil then
		player.addMoney(amount)
		return true
	end
end

function removeMoney(playerId, amount)
	local player = DBFWCore.GetPlayerFromId(playerId)

	if player ~= nil then
		player.removeMoney(amount)
		return true
	end
end


RegisterNetEvent('dbfw_Trucking:loadDelivered')
AddEventHandler('dbfw_Trucking:loadDelivered', function(totalRouteDistance)
	local playerId = source
	local payout   = math.floor(totalRouteDistance * Config.PayPerMeter) / 2

	addMoney(playerId, payout)
	TriggerClientEvent('dbfw_notify:client:SendAlert', playerId, { type = 'inform', text = 'Received £'..payout..' commission from trucking.', length = 7500 })
end)

RegisterNetEvent('dbfw_Trucking:rentTruck')
AddEventHandler('dbfw_Trucking:rentTruck', function()
	local playerId = source

	if getMoney(playerId) < Config.TruckRentalPrice then
		TriggerClientEvent('dbfw_notify:client:SendAlert', playerId, { type = 'error', text = 'You do not have enough money to rent a truck.', length = 7500 })
		return
	end

	removeMoney(playerId, Config.TruckRentalPrice)

	TriggerClientEvent('dbfw_Trucking:startJob', playerId)
end)

RegisterNetEvent('dbfw_Trucking:returnTruck')
AddEventHandler('dbfw_Trucking:returnTruck', function()
	local playerId = source

	addMoney(playerId, Config.TruckRentalPrice)

	TriggerClientEvent('dbfw_notify:client:SendAlert', playerId, { type = 'inform', text = 'Your £' .. Config.TruckRentalPrice .. ' deposit was returned to you.', length = 7500 })
end)
