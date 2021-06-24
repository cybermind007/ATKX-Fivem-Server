DBFWCore = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
local chicken = vehicleBaseRepairCost

RegisterServerEvent('dbfw-bennys:attemptPurchase')
AddEventHandler('dbfw-bennys:attemptPurchase', function(type, upgradeLevel)
    local source = source
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    if type == "repair" then
        if xPlayer.getMoney() >= chicken then
            xPlayer.removeMoney(chicken)
            TriggerClientEvent('dbfw-bennys:purchaseSuccessful', source)
        else
            TriggerClientEvent('dbfw-bennys:purchaseFailed', source)
        end
    elseif type == "performance" then
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('dbfw-bennys:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].prices[upgradeLevel])
        else
            TriggerClientEvent('dbfw-bennys:purchaseFailed', source)
        end
    else
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('dbfw-bennys:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].price)
        else
            TriggerClientEvent('dbfw-bennys:purchaseFailed', source)
        end
    end
end)

RegisterServerEvent('dbfw-bennys:updateRepairCost')
AddEventHandler('dbfw-bennys:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterServerEvent('updateVehicle')
AddEventHandler('updateVehicle', function(myCar)
    MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@plate']   = myCar.plate,
		['@vehicle'] = json.encode(myCar)
	})
end)