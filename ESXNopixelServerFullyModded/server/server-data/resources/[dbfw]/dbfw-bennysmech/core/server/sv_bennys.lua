DBFWCore = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
local chicken = vehicleBaseRepairCost

RegisterServerEvent('dbfw-bennysmech:attemptPurchase')
AddEventHandler('dbfw-bennysmech:attemptPurchase', function(type, upgradeLevel)
    local source = source
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    if type == "repair" then
        if xPlayer.getMoney() >= chicken then
            xPlayer.removeMoney(chicken)
            TriggerClientEvent('dbfw-bennysmech:purchaseSuccessful', source)
        else
            TriggerClientEvent('dbfw-bennysmech:purchaseFailed', source)
        end
    elseif type == "performance" then
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('dbfw-bennysmech:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].prices[upgradeLevel])
        else
            TriggerClientEvent('dbfw-bennysmech:purchaseFailed', source)
        end
    else
        if xPlayer.getMoney() >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('dbfw-bennysmech:purchaseSuccessful', source)
            xPlayer.removeMoney(vehicleCustomisationPrices[type].price)
        else
            TriggerClientEvent('dbfw-bennysmech:purchaseFailed', source)
        end
    end
end)

RegisterServerEvent('dbfw-bennysmech:updateRepairCost')
AddEventHandler('dbfw-bennysmech:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterServerEvent('dbfw-bennysmech:updateVehicle')
AddEventHandler('dbfw-bennysmech:updateVehicle', function(myCar)
    MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@plate']   = myCar.plate,
		['@vehicle'] = json.encode(myCar)
	})
end)