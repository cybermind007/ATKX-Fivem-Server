DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('garages:SetVehOut')
RegisterServerEvent('garages:CheckGarageForVeh')
RegisterServerEvent('garages:CheckForHouseSell')



RegisterServerEvent("garages:CheckForVeh")

-- RegisterServerEvent("garages:CheckGarageForVeh")
-- AddEventHandler("garages:CheckGarageForVeh",function(data)
-- 	TriggerClientEvent('garages:getVehicles', 'vehicle')
-- 	Trigger
-- end)
-- RegisterNetEvent("garages:CheckGarageForVeh")
-- AddEventHandler("garages:CheckGarageForVeh", function()

--     local src = source
--     local xPlayer = DBFWCore.GetPlayerFromId(src)
--     local identifier = xPlayer.identifier
    
--     MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier', { ['@identifier'] = identifier }, function(vehicles)
-- 		TriggerClientEvent('phone:Garage', src, vehicles)
-- 		TriggerClientEvent('garages:getVehicles', 'vehicle')
--     end)
-- end)

AddEventHandler("garages:CheckGarageForVeh", function()

    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier', { ['@identifier'] = identifier }, function(vehicles)
		TriggerClientEvent('phone:Garage', src, vehicles)
		TriggerClientEvent('garages:getVehicles', 'vehicle')
    end)
end)

-- AddEventHandler("garages:CheckForHouseSell", function()
-- 	print('coming here?')
--     local src = source
--     local xPlayer = DBFWCore.GetPlayerFromId(src)
--     local identifier = xPlayer.identifier
    
--     MySQL.Async.fetchAll('SELECT * FROM houses_ WHERE failBuy = @failBuy', { ['failBuy'] = "false" }, function(housing)
-- 		TriggerClientEvent('phone:SellHouse', src, housing)
-- 		-- TriggerClientEvent('garages:getVehicles', 'vehicle')
--     end)
-- end)

local DontShowPoundCarsInGarage = true


DBFWCore.RegisterServerCallback('dbfw-garage:getOwnedCars', function(source, cb)
	local ownedCars = {}
	--print("SERVER SIDE: "..source[2].. ' | ' ..source[1])
	if DontShowPoundCarsInGarage == true then
		MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type LIMIT 25', {
			['@owner']  = GetPlayerIdentifiers(source)[1],
			['@Type']   = 'car',
			['@state'] = 'In'
		}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				local body = v.body_damage
				local engine = v.engine_damage
				table.insert(ownedCars, {vehicle = vehicle, id = v.id, state = v.state, garage = v.garage, plate = v.plate, body_damage = v.body_damage, engine_damage = v.engine_damage})
			end
			cb(ownedCars)
		end)
	else
		MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type', {
			['@owner']  = GetPlayerIdentifiers(source)[1],
			['@Type']   = 'car',
			['@state'] = 'Out',
		}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				local body = v.body_damage
				local engine = v.engine_damage
				table.insert(ownedCars, {vehicle = vehicle, id = v.id, state = v.state, garage = v.garage, plate = v.plate})
			end
			cb(ownedCars)
		end)
	end
end)
RegisterServerEvent("garages:SetVehIn")
AddEventHandler("garages:SetVehIn",function(plate, garage, vehicleProps, livery, realFuel)

	local user = DBFWCore.GetPlayerFromId(source)

	local characterId = user.identifier
	
	local state = "In"
	local modLivery = livery
	--print("this is Livery "..livery)
	local vehProp = json.encode(vehicleProps)
	-- print(vehProp.modLivery)
	-- print(vehicleProps.fuelLevel)
	MySQL.Async.execute("UPDATE owned_vehicles SET vehicle = @vehicle, state = @state, garage = @garage, modLivery = @modLivery, fuel = @fuel, engine_damage = @engine_damage   WHERE plate = @plate", {['vehicle'] = vehProp, ['garage'] = garage, ['modLivery'] = vehicleProps.modLivery, ['fuel'] = realFuel, ['state'] = state, ['engine_damage'] = vehicleProps.engineHealth, ['body_damage'] = vehicleProps.bodyHealth, ['plate'] = plate})

end)

--Payed Impound Car using Phone
RegisterServerEvent("garages:PayedImpoundCar")
AddEventHandler("garages:PayedImpoundCar",function(plate)
	src = source
	local user = DBFWCore.GetPlayerFromId(source)
	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local characterId = user.identifier
	
	local state = "In"
	local garage = "T"
	--print('Im paying for my shit', plate)
	if xPlayer.get('bank') >= 700 then
	xPlayer.removeAccountMoney('bank', 700)
	TriggerClientEvent('DoShortHudText', src, 'You payed $700 for this transaction with tax. Please always check your email for car delivery.')
	Citizen.Wait(60000)
	--TriggerClientEvent('DoShortHudText',src, 'Your car is delivered in Garage T.')
	TriggerClientEvent('phone:addnotification', src, 'kevin', 'Your car was delivered on garage(T)')
	MySQL.Async.execute("UPDATE owned_vehicles SET state = @state, garage = @garage WHERE plate = @plate", {['garage'] = garage, ['state'] = state, ['plate'] = plate})
	else
		TriggerClientEvent("notification",src,"You dont have enough money to do this transaction.",2)
	end
	
end)


RegisterServerEvent('garages:CheckForSpawnVeh')
AddEventHandler('garages:CheckForSpawnVeh', function(veh_id, garageCost)
	local src = (not pSrc and source or pSrc)
	--print("This is the cost: "..garageCost)	
	local user = DBFWCore.GetPlayerFromId(source)
	if user.get('money') >= garageCost then
	if garageCost >= 1 then
	TriggerClientEvent('DoShortHudText', src, 'You\'ve been deducted $'..garageCost, 1)
	else
		TriggerClientEvent('DoLongHudText', src, 'It will cost $120 to $138.0 @ $15 x (carCount x CarCount x2)', 1)
	end
	user.removeMoney(garageCost)

	
	
	  local veh_id = veh_id
	  local player = user.identifier
	  MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE id = @id', {['@id'] = veh_id}, function(result)
		--print("This is Plate: "..result[1].plate)
		local plate = result[1].plate
		local state = result[1].state
		local FuelSet = result[1].fuel
		vehiclse = json.decode(result[1].vehicle)
		vehicle = vehiclse
		-- print("VEhicle is set out")
		-- print("Fuel to set is "..FuelSet)
		TriggerClientEvent('garages:SpawnVehicle', src, vehicle, plate, state, FuelSet)
	 -- TriggerClientEvent('garages:SpawnVehicle', src, vehicle, plate, state, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, tyrecolor, mods)
	end)
else
	TriggerClientEvent('DoShortHudText', src, 'You don\'t have enough money to retrieve your car', 2)
end
  end)

  AddEventHandler('garages:SetVehOut', function(vehicle, plate)
	-- print("DUDE?")
	local user = DBFWCore.GetPlayerFromId(source)
	local src = (not pSrc and source or pSrc)
	  local player = user.identifier
	  local vehicle = vehicle
	  local vehicle_state = "Out"
	  local plate = plate
	  local player = user.identifier
	  MySQL.Async.execute("UPDATE owned_vehicles SET state = @state WHERE plate = @plate", {['garage'] = garage, ['state'] = vehicle_state, ['plate'] = plate})
  end)


  AddEventHandler('garages:CheckForVeh', function()
	local src = (not pSrc and source or pSrc)
	local user = DBFWCore.GetPlayerFromId(source)
	  local state = "Out"
	  local player = user.identifier

	 
	  MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND state = @state', {['@owner'] = player, ['@state'] = state, ['@vehicle'] = vehicle}, function(result)
		--print(result[1])
		if result[1] ~= nil then
			local plates = result[1].plate
		
		vehiclse = json.decode(result[1].vehicle)
		vehicle = vehiclse.model
		fuel = vehiclse.fuelLevel
		-- print("CHECFORVEH: "..vehicle)
		-- print("THIS IS PLATE: "..plates)
		-- print("THIS IS PLATE: "..fuel)
		--TriggerClientEvent('garages:SpawnVehicle', src, vehicle, plate, state)
	  TriggerClientEvent('garages:StoreVehicle', src, plate)
		else
			TriggerClientEvent('DoShortHudText', src, 'Theres no car or is not yours', 2)
		end
		
	end)
  end)

  AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() == 'dbfw-garage' then
		Citizen.CreateThread(function()
			Citizen.Wait(1)
			ImpoundCarOut()
		end)
	end
  end)

  RegisterServerEvent('dbfw-garage:putcaringarage')
  AddEventHandler('dbfw-garage:putcaringarage', function()
	if GetCurrentResourceName() == 'dbfw-garage' then
		Citizen.CreateThread(function()
			Citizen.Wait(1)
			ImpoundCarOut()
		end)
	end
  end)

function ImpoundCarOut()
Citizen.CreateThread(function()
  	MySQL.Async.execute("UPDATE owned_vehicles SET garage = @garage, state = @state WHERE state = @state", {['garage'] = 'Q', ['state'] = 'In', ['state'] = 'Out'})
  	  Citizen.Wait(1000)
  		MySQL.Async.execute("UPDATE owned_vehicles SET state = @state WHERE garage = @garage", {['state'] = 'In', ['garage'] = 'Q'})
	end)
end