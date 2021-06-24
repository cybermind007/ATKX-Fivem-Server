local truckId, jobStatus, currentRoute, currentDestination = nil, CONST_NOTWORKING, nil, nil
local currentDestination, routeBlip, trailerId, lastDropCoordinates, totalRouteDistance = nil, nil, nil, nil, nil, nil

local PickupCoordinates = nil

Citizen.CreateThread(function()
	EncoreHelper.CreateBlip(Config.JobStart.Coordinates, 'Trucking', Config.Blip.SpriteID, Config.Blip.ColorID, Config.Blip.Scale)

	while true do
		Citizen.Wait(0)

		local playerId             = PlayerPedId()
		local playerCoordinates    = GetEntityCoords(playerId)
		local distanceFromJobStart = GetDistanceBetweenCoords(playerCoordinates, Config.JobStart.Coordinates, false)
		local sleep                = 1000

		if distanceFromJobStart < Config.Marker.DrawDistance then
			sleep = 0
		
			DrawMarker(Config.Marker.Type, Config.JobStart.Coordinates, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.Size,  Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, 100, false, true, 2, false, nil, nil, false)

			if distanceFromJobStart < Config.Marker.Size.x then

				if truckId and GetVehiclePedIsIn(playerId, false) == truckId and GetPedInVehicleSeat(truckId, -1) == playerId then
					EncoreHelper.ShowAlert('Press ~INPUT_PICKUP~ to return your truck.', true)

					if IsControlJustReleased(0, 38) then
						TriggerServerEvent('dbfw_Trucking:returnTruck')

						abortJob()
					end
				elseif not IsPedInAnyVehicle(playerId, false) then
					EncoreHelper.ShowAlert('Press ~INPUT_PICKUP~ to rent a truck for $' .. Config.TruckRentalPrice .. '.', true)

					if IsControlJustReleased(0, 38) then
						TriggerServerEvent('dbfw_Trucking:rentTruck')
					end
				end
			end
		end

		if jobStatus ~= CONST_NOTWORKING then
			sleep = 0

			if jobStatus == CONST_WAITINGFORTASK then
				assignTask()
			elseif jobStatus == CONST_PICKINGUP then
				pickingUpThread(playerId, playerCoordinates)
			elseif jobStatus == CONST_DELIVERING then
				deliveringThread(playerId, playerCoordinates)
			end
		
			if IsControlJustReleased(0, Config.AbortKey) then
				TriggerEvent("DoLongHudText", "Press X again to confirm abort job.",1)
				local time = 5000

				while true do
					Wait(0)

					if IsControlJustReleased(0, Config.AbortKey) then
						abortJob()
						break
					else
						time = time - 1
						
						if time <= 0 then
							TriggerEvent("DoLongHudText", "You chose not to abort job.",1)
							break
						end
					end
				end
			end
		end

		if sleep > 0 then
			Citizen.Wait(sleep)
		end
	end
end)

function pickingUpThread(playerId, playerCoordinates)
	if currentRoute ~= nil then
		if not trailerId and GetDistanceBetweenCoords(playerCoordinates, currentRoute.PickupCoordinates, true) < 100.0 then
			TriggerEvent("DoLongHudText", "Press [E] to spawn the trailer.",1)
				while true do
					Wait(0)
			
					if currentRoute ~= nil and not trailerId and GetDistanceBetweenCoords(playerCoordinates, currentRoute.PickupCoordinates, true) < 100.0 then
						if IsControlJustReleased(0, 38) or IsControlJustReleased(1, 46) or IsControlJustReleased(1, 86) or IsControlJustReleased(0, 20) then
							TriggerEvent("DoLongHudText", "TRUCKING.",1)
							trailerId = EncoreHelper.SpawnVehicle(currentRoute.TrailerModel, currentRoute.PickupCoordinates, currentRoute.PickupHeading)
							break
						end
					else
						TriggerEvent("DoLongHudText", "STARTED TRUCKING.",1)
						break
					end
				end
		end

		if trailerId and IsEntityAttachedToEntity(trailerId, truckId) then
			RemoveBlip(routeBlip)
			Wait(100)
			EncoreHelper.CreateRouteBlip(currentDestination)
			TriggerEvent("DoLongHudText", "Take the delivery to the drop off point.",1)
			jobStatus = CONST_DELIVERING
		end
	end
end

function deliveringThread(playerId, playerCoordinates)
	local distanceFromDelivery = GetDistanceBetweenCoords(playerCoordinates, currentDestination, true)

	if distanceFromDelivery < Config.Marker.DrawDistance then
		DrawMarker(Config.Marker.Type, currentDestination, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.Size,  Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, 100, false, true, 2, false, nil, nil, false)	
	
		if distanceFromDelivery < Config.Marker.Size.x then
			EncoreHelper.ShowAlert('Press ~INPUT_PICKUP~ to deliver the load.', true)

			if IsControlJustReleased(0, 38) then
				TriggerServerEvent('dbfw_Trucking:loadDelivered', totalRouteDistance)
				cleanupTask()
			end
		end
	end

	if trailerId and (not DoesEntityExist(trailerId) or not IsEntityAttachedToEntity(trailerId, truckId)) then
		if DoesEntityExist(trailerId) then
			DeleteVehicle(trailerId)
		end

		RemoveBlip(routeBlip)

		currentRoute        = nil
		currentDestination  = nil
		lastDropCoordinates = playerCoordinates

		TriggerEvent("DoLongHudText", "You lost your load. A new route will be assigned.",1)

		jobStatus = CONST_WAITINGFORTASK
	end
end

function cleanupTask()
	if DoesEntityExist(trailerId) then
		DeleteVehicle(trailerId)
	end

	RemoveBlip(routeBlip)

	trailerId          = nil
	routeBlip          = nil
	currentDestination = nil
	currentRoute       = nil

	jobStatus = CONST_WAITINGFORTASK
end

function abortJob()
	DoScreenFadeOut(500)
	Citizen.Wait(500)

	if truckId and DoesEntityExist(truckId) then
		DeleteVehicle(truckId)
	end

	if trailerId and DoesEntityExist(trailerId) then
		DeleteVehicle(trailerId)
	end

	if routeBlip then
		RemoveBlip(routeBlip)
	end

	truckId  		    = nil
	trailerId		    = nil
	routeBlip			= nil
	currentDestination  = nil
	currentRoute        = nil
	lastDropCoordinates = nil
	totalRouteDistance  = nil

	Citizen.Wait(500)
	DoScreenFadeIn(500)
end

function assignTask()
	currentRoute       = Config.Routes[math.random(1, #Config.Routes)]
	currentDestination = currentRoute.Destinations[math.random(1, #currentRoute.Destinations)]
	routeBlip          = EncoreHelper.CreateRouteBlip(currentRoute.PickupCoordinates)

	local distanceToPickup   = GetDistanceBetweenCoords(lastDropCoordinates, currentRoute.PickupCoordinates)
	local distanceToDelivery = GetDistanceBetweenCoords(currentRoute.PickupCoordinates, currentDestination)

	totalRouteDistance  = distanceToPickup + distanceToDelivery
	lastDropCoordinates = currentDestination

	TriggerEvent("DoLongHudText", "Head to the <b>pickup</b> on your GPS.",1)
	jobStatus = CONST_PICKINGUP
end


RegisterNetEvent('dbfw_Trucking:startJob')
AddEventHandler('dbfw_Trucking:startJob', function()
	local playerId = PlayerPedId()

	truckId = EncoreHelper.SpawnVehicle(Config.TruckModel, Config.JobStart.Coordinates, Config.JobStart.Heading)
	SetPedIntoVehicle(playerId, truckId, -1)
	

	lastDropCoordinates = Config.JobStart.Coordinates

	jobStatus = CONST_WAITINGFORTASK
end)
