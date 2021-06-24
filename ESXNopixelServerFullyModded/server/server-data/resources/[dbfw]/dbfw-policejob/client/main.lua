local PlayerData, CurrentActionData, handcuffTimer, dragStatus, blipsCops, currentTask, spawnedVehicles = {}, {}, {}, {}, {}, {}, {}
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
DBFWCore = nil
local isInService = false
local rank = "inconnu"
local checkpoints = {}
local existingVeh = nil
local handCuffed = false
local isMedic = false
local isCop = false
local isDoctor = false
local isNews = false
local IsDead = false
local hasAlreadyJoined = false
local playerInService = false
local currentCallSign = ""

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(10)
	end

	while DBFWCore.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = DBFWCore.GetPlayerData()
end)

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end


RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
	PlayerData.job = job

	TriggerServerEvent('dbfw-policejob:forceBlip')
end)

function getIsCop()
	return isCop
end

function getIsInService()
	return isCop or isMedic
end

function getIsCuffed()
	return handCuffed
end

RegisterNetEvent("orp:playerBecameJob")
AddEventHandler("orp:playerBecameJob", function(job, name, notify)
	if job == "police" then 
		DecorSetInt(PlayerPedId(), "EmergencyType", 1)
		isCop = true 
		TriggerEvent('nowCopSpawn')
		currentCallSign = "Officer"
	end
	if job == "ambulance" then DecorSetInt(PlayerPedId(), "EmergencyType", 2) isMedic = true  currentCallSign = "EMS" end
end)

function ChangeToSkinNoUpdatePolice(skin)
	local model = GetHashKey(skin)
	if IsModelInCdimage(model) and IsModelValid(model) then
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(1)
		end
		SetPlayerModel(PlayerId(), model)
		SetPedRandomComponentVariation(PlayerPedId(), true)
		SetModelAsNoLongerNeeded(model)
	else
		TriggerEvent("DoLongHudText","Model not found",2)
	end
end

-- don't show dispatches if the player isn't in service
AddEventHandler('dbfw-phone:cancelMessage', function(dispatchNumber)
	if PlayerData.job and PlayerData.job.name == 'police' and PlayerData.job.name == dispatchNumber then
		-- if DBFWCore_service is enabled
		if Config.MaxInService ~= -1 and not playerInService then
			CancelEvent()
		end
	end
end)

Citizen.CreateThread(function()
	local refreshed = false

	while true do
		local dist = #(vector3(448.23,-996.44,30.69) - GetEntityCoords(PlayerPedId()))
		if dist < 100 and not refreshed then
			DisableInterior(137473, false)
			if not IsInteriorReady(137473) then
				LoadInterior(137473)
			else
				RefreshInterior(137473)
			end
			refreshed = true
		end
		if refreshed and dist > 100 then
			DisableInterior(137473, true)
			refreshed = false
		end
		Wait(2000)
	end
end)

local evidencelocker = { -- #MarkedForMarker
	vector3(475.0727, -994.6176, 26.27327), -- mrpd
    vector3(2059.51,2993.21,-72.70),
	vector3(325.05,-1629.5, -66.78),
	vector3(1848.47,3694.51,34.28), -- sandy
}

local evidencelocker2 = { -- #MarkedForMarker
	vector3(472.6465, -995.2656, 26.27327), -- mrpd
}

local trashlocker = {
	vector3(472.6465, -995.2656, 00.27327), -- mrpd
	vector3(1840.45, 2572.82, 46.02), -- jail
	vector3(1851.14,3694.54,34.28), -- sandy
	vector3(-442.0,6005.38,31.72) -- paleto
}

local personalLockers = {
	-- MRPD 
	vector3(474.49,-991.32,24.23),
	vector3(480.81,-992.78,24.23),
	vector3(477.3,-993.21,24.27),
	-- sandy
	vector3(1860.99,3691.32,34.28),
	-- paleto
	vector3(-451.61,6016.21,31.72),
}

RegisterCommand('kneel', function(source, args)
	TriggerEvent("KneelHU")
end)

-- hEntity(PlayerPedId(), true, false)	
-- end)

-- #MarkedForMarker

function MenuGarage()
    ped = GetPlayerPed(-1);
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicles", "VehicleList", nil)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    ped = GetPlayerPed(-1);
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Config.Vehicles) do
            Menu.addButton(v.label, "TakeOutVehicle", v.name, "Garage", " Motor: 100%", " Body: 100%", " Fuel: 100%")
        
    end
        
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    ClearMenu()
    DBFWCore.Game.SpawnVehicle(vehicleInfo, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), function(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        local hashVehicule = GetEntityModel(vehicle)
        local VehName = GetDisplayNameFromVehicleModel(hashVehicule)
        TriggerServerEvent('garage:addKeys', GetVehicleNumberPlateText(vehicle))
    end)


end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end


Citizen.CreateThread(function()
	local dstCheck = 1000.0
	while true do
		Citizen.Wait(0)
		if PlayerData.job and PlayerData.job.name == 'police' then
			
			local nearby = false
			local myCoord = GetEntityCoords(PlayerPedId())
			for i,v in ipairs(evidencelocker) do
				dstCheck = #(v - myCoord)
				if dstCheck < 30 then nearby = true end
				if dstCheck < 0.7 then
				 	DrawText3DTest(v.x, v.y, v.z,"~r~E~w~ Open OLD Evidence Locker - use /evidence case# ")
					 if IsControlJustReleased(0, Keys["E"]) then
						TriggerEvent("event:control:police", 2)
					 end

				end
				
			end
			for k, v in pairs(Config.Locations["vehicle"]) do
				if (GetDistanceBetweenCoords(myCoord, v.x, v.y, v.z, true) < 7.5) then
					 if true then
						 DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
						 if (GetDistanceBetweenCoords(myCoord, v.x, v.y, v.z, true) < 1.5) then
							 if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
								DrawText3DTest(v.x, v.y, v.z, "~g~E~w~ - Store the vehicle")
							 else
								DrawText3DTest(v.x, v.y, v.z, "~g~E~w~ - Vehicles")
							 end
							 if IsControlJustReleased(0, Keys["E"]) then
								 if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
									local veh = GetVehiclePedIsIn(GetPlayerPed(-1))
									 DBFWCore.Game.DeleteVehicle(veh)
									 local hashVehicule = GetEntityModel(veh)
									 local VehName = GetDisplayNameFromVehicleModel(hashVehicule)
									
								 else
									 MenuGarage()
									 currentGarage = k
									 Menu.hidden = not Menu.hidden
								
							   end
							 end
							 Menu.renderGUI()
						 end  
					 end
				 end
			end

			for i,v in ipairs(evidencelocker2) do
				dstCheck = #(v - myCoord)
				if dstCheck < 30 then nearby = true end
				if dstCheck < 2 then
				 	DrawText3DTest(v.x, v.y, v.z,"~r~E~w~ Open Evidence Locker")
					 if IsControlJustReleased(0, Keys["E"]) then
						TriggerEvent("event:control:police", 3)
					 end
				end
			end
			
			for i,v in ipairs(trashlocker) do
				dstCheck = #(v - myCoord)
				if dstCheck < 30 then nearby = true end
				if dstCheck < 2 then
				 	DrawText3DTest(v.x, v.y, v.z,"~r~E~w~ Open Trash Locker")
					 if IsControlJustReleased(0, Keys["E"]) then
						TriggerEvent("event:control:police", 4)
					 end
				end
			end

			for i,v in ipairs(personalLockers) do
				dstCheck = #(v - myCoord)
				if dstCheck < 30 then nearby = true end
				if dstCheck < 2 then
				 	DrawText3DTest(v.x, v.y, v.z,"~r~E~w~ Open Personal Locker")
				end
			end

			
			-- if not nearby then
			-- 	Citizen.Wait(dstCheck)
			-- end
		else
			Citizen.Wait(10000)
		end
	end
end)

function isOppositeDir(a,b)
	local result = 0 
	if a < 90 then
		a = 360 + a
	end
	if b < 90 then
		b = 360 + b
	end	
	if a > b then
		result = a - b
	else
		result = b - a
	end
	if result > 110 then
		return true
	else
		return false
	end
end

RegisterNetEvent('police:remmaskAccepted')
AddEventHandler('police:remmaskAccepted', function()
	TriggerEvent("facewear:adjust", 1, true)
	TriggerEvent("facewear:adjust", 3, true)
	TriggerEvent("facewear:adjust", 4, true)
	--TriggerEvent("facewear:adjust", 5, true)
	TriggerEvent("facewear:adjust", 2, true)
end)

RegisterNetEvent('pd:deathcheck')
AddEventHandler('pd:deathcheck', function()
  if not isDead then
    isDead = true
  else
    isDead = false
  end
end)

RegisterNetEvent('evidence:container')
AddEventHandler('evidence:container', function(arg)
	if tonumber(arg) == nil then
		return
	end
	local cid = exports["isPed"]:isPed("cid")
	TriggerServerEvent("server-inventory-open", GetEntityCoords(PlayerPedId()), cid, "1", "Case-"..arg);
end)



RegisterNetEvent('event:control:police')
AddEventHandler('event:control:police', function(useID)
	if useID == 1 then
		TriggerServerEvent('police:checkForBar')

	elseif useID == 2  then
		TriggerEvent("server-inventory-open", "1", "evidenceLocker")
		TriggerServerEvent('police:viewEvidenceLockup')
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'LockerOpen', 0.4)

	elseif useID == 3  then
		TriggerEvent("server-inventory-open", "1", "evidenceLocker2")
		TriggerServerEvent('police:viewEvidenceLockup')
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'LockerOpen', 0.4)

	elseif useID == 4 then 
		TriggerEvent("server-inventory-open", "1", "trash-1")

	elseif useID == 5 and not handCuffed and GetLastInputMethod(2) then 
		TriggerEvent('Police:Radio')

	elseif useID == 6 and not handCuffed and GetLastInputMethod(2) then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if isInVeh then
			TriggerEvent("toggle:cruisecontrol")
		end
	end
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
	TriggerEvent("hud:insidePrompt",true)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) 
	blockinput = true
  
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
	  Citizen.Wait(0)
	end
	  
	if UpdateOnscreenKeyboard() ~= 2 then
	  local result = GetOnscreenKeyboardResult()
	  Citizen.Wait(500)
	  blockinput = false
	  TriggerEvent("hud:insidePrompt",false)
	  return result
	else
	  Citizen.Wait(500)
	  blockinput = false
	  TriggerEvent("hud:insidePrompt",false)
	  return nil 
	end
	
  end

RegisterNetEvent('police:remmask')
AddEventHandler('police:remmask', function(t)
	t, distance = GetClosestPlayer()
	if (distance ~= -1 and distance < 5) then
		if isOppositeDir(GetEntityHeading(t),GetEntityHeading(PlayerPedId())) and not IsPedInVehicle(t,GetVehiclePedIsIn(t, false),false) then
			TriggerServerEvent("police:remmaskGranted", GetPlayerServerId(t))
			AnimSet = "mp_missheist_ornatebank"
			AnimationOn = "stand_cash_in_bag_intro"
			AnimationOff = "stand_cash_in_bag_intro"
			loadAnimDict( AnimSet )
			TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 8.0, -8, -1, 49, 0, 0, 0, 0 )
			Citizen.Wait(500)
			ClearPedTasks(PlayerPedId())						
		end
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end
end)

RegisterNetEvent('police:remweapons')
AddEventHandler('police:remweapons', function(t)
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 5) then
		TriggerServerEvent("police:remweaponsGranted", GetPlayerServerId(t))
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end
end)

tryingcuff = false
RegisterNetEvent('police:cuff2')
AddEventHandler('police:cuff2', function(t,softcuff)

	if not tryingcuff then

		
		tryingcuff = true

		t, distance, ped = GetClosestPlayer()

		Citizen.Wait(1500)
		if(distance ~= -1 and #(GetEntityCoords(ped) - GetEntityCoords(PlayerPedId())) < 2.5 and GetEntitySpeed(ped) < 1.0) then
			TriggerServerEvent("police:cuffGranted2", GetPlayerServerId(t), softcuff)
		else
			ClearPedSecondaryTask(PlayerPedId())
			TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
		end

		tryingcuff = false

	end

end)

RegisterNetEvent('police:cuff')
AddEventHandler('police:cuff', function(t)
	if not tryingcuff then
		TriggerEvent("Police:ArrestingAnim")
		tryingcuff = true

		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 1.5) then
			TriggerServerEvent("police:cuffGranted", GetPlayerServerId(t))
		else
			TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
		end


		tryingcuff = false
	end
end)

local cuffstate = false


RegisterNetEvent('civ:cuffFromMenu')
AddEventHandler('civ:cuffFromMenu', function()
	TriggerEvent("police:cuffFromMenu",false)
end)

RegisterNetEvent('police:cuffFromMenu')
AddEventHandler('police:cuffFromMenu', function(softcuff)
	if not cuffstate and not handCuffed and not IsPedRagdoll(PlayerPedId()) and not IsPlayerFreeAiming(PlayerId()) and not IsPedInAnyVehicle(PlayerPedId(), false) then
		cuffstate = true

		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 2 and not IsPedRagdoll(PlayerPedId())) then
			if softcuff then
				TriggerEvent("DoLongHudText", "You soft cuffed a player!",1)
			else
				TriggerEvent("DoLongHudText", "You hard cuffed a player!",1)
			end
			
			TriggerEvent("police:cuff2", GetPlayerServerId(t),softcuff)
		end

		cuffstate = false
	end
end)

RegisterNetEvent('police:gsr')
AddEventHandler('police:gsr', function(t)
	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, 1)
	local finished = exports["dbfw-taskbar"]:taskBar(15000,"GSR Testing")
    if finished == 100 then
		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 7) then
			TriggerServerEvent("dbfw-policejob:checkgsr", GetPlayerServerId(t))
		end
	end
end)

local shotRecently = false

Citizen.CreateThread(function()
	local lastShot = 0
	
	while true do
		Citizen.Wait(1)

		if IsPedShooting(PlayerPedId()) then
			local name = GetSelectedPedWeapon(PlayerPedId())
			if name ~= `WEAPON_STUNGUN` then
				lastShot = GetGameTimer()
				shotRecently = true
			end
		end

		if shotRecently and GetGameTimer() - lastShot >= 1200000 then shotRecently = false end 
	end
end)

RegisterNetEvent("police:hasShotRecently")
AddEventHandler("police:hasShotRecently", function(copId)
	TriggerServerEvent("police:hasShotRecently", shotRecently, copId)
end)

RegisterNetEvent('police:uncuffMenu')
AddEventHandler('police:uncuffMenu', function()
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 2) then
		TriggerServerEvent("falseCuffs", GetPlayerServerId(t))
		TriggerEvent("DoLongHudText", "You uncuffed a player!",1)
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end
end)

-- hopefully resolve the death / revive restrain bug.

RegisterNetEvent('resetCuffs')
AddEventHandler('resetCuffs', function()
	ClearPedTasksImmediately(PlayerPedId())
	handcuffType = 49
	handCuffed = false
	handCuffedWalking = false
	TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
	--TriggerEvent("DensityModifierEnable",true)
	TriggerEvent("handcuffed",false)
end)

RegisterNetEvent('falseCuffs')
AddEventHandler('falseCuffs', function()
	ClearPedTasksImmediately(PlayerPedId())
	handcuffType = 49
	handCuffed = false
	handCuffedWalking = false
	TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
	--TriggerEvent("DensityModifierEnable",true)
	TriggerEvent("handcuffed",false)
end)

RegisterNetEvent('police:getArrested2')
AddEventHandler('police:getArrested2', function(cuffer)

	ClearPedTasksImmediately(PlayerPedId())
	CuffAnimation(cuffer)
	
	local cuffPed = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))

	local finished = 0
	if not exports["dbfw-ambulancejob"]:GetDeath() then
		finished = exports["dbfw-taskbarskill"]:taskBar(1200,7)
	end
	
	if #(GetEntityCoords( PlayerPedId()) - GetEntityCoords(cuffPed)) < 2.5 and finished ~= 100 then
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'handcuff', 0.4)
		handcuffType = 16
		handCuffed = true
		handCuffedWalking = false
		TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
		TriggerEvent("DoLongHudText", "Cuffed!",1)
		TriggerEvent("handcuffed",true)
		TriggerEvent("DensityModifierEnable",false)	
	end	

end)

function CuffAnimation(cuffer)
	loadAnimDict("mp_arrest_paired")
	local cuffer = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))
	local dir = GetEntityHeading(cuffer)
	--TriggerEvent('police:cuffAttach',cuffer)
	SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))
	Citizen.Wait(100)
	SetEntityHeading(PlayerPedId(),dir)
	TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 8.0, -8, -1, 32, 0, 0, 0, 0)
end

RegisterNetEvent('police:cuffAttach')
AddEventHandler('police:cuffAttach', function(cuffer)
	local count = 350
	while count > 0 do
		Citizen.Wait(1)
		count = count - 1
		AttachEntityToEntity(PlayerPedId(), cuffer, 11816, 0.0, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	end
	DetachEntity(PlayerPedId(), true, false)	
end)

RegisterNetEvent('police:cuffTransition')
AddEventHandler('police:cuffTransition', function()
	loadAnimDict("mp_arrest_paired")
	Citizen.Wait(100)
	TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "cop_p2_back_right", 8.0, -8, -1, 48, 0, 0, 0, 0)
	Citizen.Wait(3500)
	ClearPedTasksImmediately(PlayerPedId())
end)

RegisterNetEvent('police:getArrested')
AddEventHandler('police:getArrested', function(cuffer)

		if(handCuffed) then
			Citizen.Wait(3500)
			ClearPedTasksImmediately(PlayerPedId())
			handCuffed = false
			handcuffType = 49
			TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
			TriggerEvent("handcuffed",true)
			TriggerEvent("DensityModifierEnable",true)
		else
			ClearPedTasksImmediately(PlayerPedId())
			CuffAnimation(cuffer) 

			local cuffPed = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))
			if Vdist2( GetEntityCoords( GetPlayerPed(-1) , GetEntityCoords(cuffPed) ) ) < 1.5 then
				handcuffType = 49
				handCuffed = true
				TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)
				TriggerEvent("handcuffed",false)
				TriggerEvent("DensityModifierEnable",false)
			end
		end
end)


RegisterNetEvent('police:jailing')
AddEventHandler('police:jailing', function(args)
	Citizen.Trace("Jailing in process.")
	TriggerServerEvent( 'police:jailGranted', args )
end)

RegisterNetEvent('police:payFines')
AddEventHandler('police:payFines', function(amount)

	TriggerServerEvent('bank:withdrawAmende', amount)
	TriggerEvent('chatMessage', "BILL ", {255, 140, 0}, "You were billed for ^2" .. tonumber(amount) .. " ^0dollar(s).")
end)

RegisterNetEvent('police:forceEnter')
AddEventHandler('police:forceEnter', function(id)

	ped, distance, t = GetClosestPedIgnoreCar()
	if(distance ~= -1 and distance < 3) then

		local isInVeh = IsPedInAnyVehicle(ped, true)
		if not isInVeh then
			playerped = PlayerPedId()
	        coordA = GetEntityCoords(playerped, 1)
	        coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
	        v = getVehicleInDirection(coordA, coordB)
	        if GetVehicleEngineHealth(v) < 100.0 then
	        	TriggerEvent("DoLongHudText", "That vehicle is too damaged!",2)
	        	return
	        end
			local netid = NetworkGetNetworkIdFromEntity(v)	
			TriggerServerEvent("police:forceEnterAsk", GetPlayerServerId(t), netid)
			TriggerEvent("dr:releaseEscort")
		else
			TriggerEvent("unseatPlayer")
		end

	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end

end)

RegisterNetEvent('police:forcedEnteringVeh')
AddEventHandler('police:forcedEnteringVeh', function(sender)
	local vehicleHandle = NetworkGetEntityFromNetworkId(sender)
    if vehicleHandle ~= nil then
        Citizen.Trace("22")
      if IsEntityAVehicle(vehicleHandle) then
      	TriggerEvent("respawn:sleepanims")
      	Citizen.Wait(1000)
        for i=1,GetVehicleMaxNumberOfPassengers(vehicleHandle) do
            Citizen.Trace("33")
          if IsVehicleSeatFree(vehicleHandle,i) then
		 	TriggerEvent("unEscortPlayer")
			Citizen.Wait(100)
            SetPedIntoVehicle(PlayerPedId(),vehicleHandle,i)
            
            Citizen.Trace("whatsasdsass")
            return true
          end
        end
	    if IsVehicleSeatFree(vehicleHandle,0) then
	    	TriggerEvent("unEscortPlayer") 
			Citizen.Wait(100)
	        SetPedIntoVehicle(PlayerPedId(),vehicleHandle,0)
	        
	    end
      end
    end
end)

RegisterNetEvent('police:tenThirteenA')
AddEventHandler('police:tenThirteenA', function()
	if(isCop) then
		
		local pos = GetEntityCoords(PlayerPedId(),  true)
		TriggerServerEvent("dispatch:svNotify", {
			dispatchCode = "10-13A",
			firstStreet = GetStreetAndZone(),
			callSign = "TEST NAME",--exports["isPed"]:isPed("lastname"),
			cid = exports["isPed"]:isPed("cid"),
			origin = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			  }
		})
	end
end)

RegisterNetEvent('police:tenThirteenB')
AddEventHandler('police:tenThirteenB', function()
	if(isCop) then
		local pos = GetEntityCoords(PlayerPedId(),  true)
		TriggerServerEvent("dispatch:svNotify", {
			dispatchCode = "10-13B",
			firstStreet = GetStreetAndZone(),
			callSign = currentCallSign,
			cid = exports["isPed"]:isPed("cid"),
			origin = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			}
		})
	end
end)

RegisterNetEvent("police:tenForteenA")
AddEventHandler("police:tenForteenA", function()	
	local pos = GetEntityCoords(PlayerPedId(),  true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-14A",
		firstStreet = GetStreetAndZone(),
		callSign = currentCallSign,
		cid = exports["isPed"]:isPed("cid"),
		origin = {
			x = pos.x,
			y = pos.y,
			z = pos.z
		}
	})
end)

RegisterNetEvent("police:tenForteenB")
AddEventHandler("police:tenForteenB", function()	
	local pos = GetEntityCoords(PlayerPedId(),  true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-14B",
		firstStreet = GetStreetAndZone(),
		callSign = currentCallSign,
		cid = exports["isPed"]:isPed("cid"),
		origin = {
			x = pos.x,
			y = pos.y,
			z = pos.z
		}
	})
end)

RegisterNetEvent("police:setCallSign")
AddEventHandler("police:setCallSign", function(pCallSign)
	if pCallSign ~= nil then currentCallSign = pCallSign end
end)


-- Create blips

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('policejob:unrestrain')
		if Config.MaxInService ~= -1 then
			TriggerServerEvent('dbfw-service:disableService', 'police')
		end
	end
end)


-- TODO
--   - return to garage if owned
--   - message owner that his vehicle has been impounded
function ImpoundVehicle(vehicle)
	DBFWCore.Game.DeleteVehicle(vehicle)
	local plate = GetVehicleNumberPlateText(vehicle)
	TriggerEvent('DoShortHudText', plate, 1)
	TriggerEvent('DoShortHudText', vehicle, 2)
	currentTask.busy = false
end


function ShowHelp(text, bleep)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, bleep, -1)
end

RegisterCommand("cuffs", function(source, args)
	if PlayerData.job.name == 'police' then
	TriggerServerEvent("police:cuffGranted2", args[1], "softcuff")
	end
end)


RegisterCommand("bill", function(src, args)
	if PlayerData.job and PlayerData.job.name == 'police' then
	local closestPlayer, closestDistance = DBFWCore.Game.GetClosestPlayer()
			if closestPlayer ~= -1 and closestDistance <= 3.0 then
				TriggerServerEvent('policejob:payBill', args)
			else
				TriggerEvent('DoLongHudText', 'There\'s no player nearby!', 2)
			end
		else
		TriggerEvent('DoLongHudText', 'Fuck off!', 2)
	end
end)



dragging = false
beingDragged = false
imdead = 0
RegisterNetEvent('pd:deathcheck')
AddEventHandler('pd:deathcheck', function()
	if imdead == 0 then 
		imdead = 1
	else
		beingDragged = false
		dragging = false
		imdead = 0
	end

	lasthealth = GetEntityHealth(PlayerPedId())
end)

local lastTarget
local target
local targetLastHealth
local bodySweat = 0
local sweatTriggered = false
Citizen.CreateThread(function()

    while true do
        Wait(300)

        if IsPedInAnyVehicle(PlayerPedId(), false) then
        	local vehicle = GetVehiclePedIsUsing(PlayerPedId())
        	local bicycle = IsThisModelABicycle( GetEntityModel(vehicle) )
        	local speed = GetEntitySpeed(vehicle)
        	if bicycle and speed > 0 then
        		sweatTriggered = true
        		if bodySweat < 180000 then
        			bodySweat = bodySweat + (150 + math.ceil(speed * 40))
        		else
        			bodySweat = bodySweat + (150 + math.ceil(speed * 11))
        		end

        		if bodySweat > 300000 then
	        		bodySweat = 300000
	        	end
        	end
        end        

        if IsPedInMeleeCombat(PlayerPedId()) then
        	bodySweat = bodySweat + 4000
        	sweatTriggered = true
        	target = GetMeleeTargetForPed(PlayerPedId())
        	if target == lastTarget or lastTarget == nil then
        		if IsPedAPlayer(target) then
        			lastTarget = target
        		end
        	else
        		if IsPedAPlayer(target) then
	        		targetLastHealth = GetEntityHealth(target)
	        		lastTarget = target
	        	end
        	end
        end

        if IsPedSwimming(PlayerPedId()) then
        	local speed = GetEntitySpeed(PlayerPedId())
        	if speed > 0 then
        		sweatTriggered = true
        		TriggerEvent("Evidence:StateSet",20,0)
        		TriggerEvent("Evidence:StateSet",21,0)
        		TriggerEvent("Evidence:StateSet",23,600)
        		if bodySweat < 180000 then
        			bodySweat = bodySweat + (150 + math.ceil(speed * 40))
        		else
        			bodySweat = bodySweat + (150 + math.ceil(speed * 11))
        		end
        		

        		if bodySweat > 210000 then
        			TriggerEvent("Evidence:StateSet",19,600)
	        		bodySweat = 210000
	        	end
        	end
        end

        if IsPedRunning(PlayerPedId()) then
        	bodySweat = bodySweat + 3000
        	if bodySweat > 800000 then
        		bodySweat = 800000
        	end
        elseif bodySweat > 0.0 then
        	if not sweatTriggered then
        		bodySweat = 0.0
        	end
        	if bodySweat < 100000 then
        		bodySweat = bodySweat - 1500
        	end
        	bodySweat = bodySweat - 100
        	if bodySweat == 0.0 then
        		sweatTriggered = false
        	end
        end
        if bodySweat > 200000 and not IsPedSwimming(PlayerPedId()) then
			TriggerEvent("Evidence:StateSet",19,300)
        end  

        if bodySweat > 300000 and not IsPedSwimming(PlayerPedId()) and Currentstates[22]["timer"] < 50 then
			TriggerEvent("Evidence:StateSet",20,450)
        end 
        if bodySweat > 800000 and not IsPedSwimming(PlayerPedId()) and Currentstates[22]["timer"] < 50 then
        	sweatTriggered = true
			TriggerEvent("Evidence:StateSet",21,600)
        end

    end
end)

handCuffedWalking = false
RegisterNetEvent('handCuffedWalking')
AddEventHandler('handCuffedWalking', function()

	if handCuffedWalking then
		handCuffedWalking = false
		TriggerEvent("handcuffed",false)
		TriggerEvent("animation:PlayAnimation","cancel")
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'handcuff', 0.4)
		TriggerEvent("police:currentHandCuffedState",false,false)
		return
	end
	
	handCuffedWalking = true
	handCuffed = false
	TriggerEvent("handcuffed",true)

	TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'handcuff', 0.4)

	TriggerEvent("police:currentHandCuffedState",handCuffed,handCuffedWalking)

end)

handcuffs = 0
function alterHandcuffs(cuffMode)
	local factor = cuffMode
	if cuffMode then
		local hcmodel = "prop_cs_cuffs_01"
		local plyCoords = GetEntityCoords(PlayerPedId(), false)
		local handcuffs = CreateObject(GetHashKey(hcmodel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
		AttachEntityToEntity(handcuffs, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.0, 0.05, 0.0, 0.0, 0.0, 80.0, 1, 0, 0, 0, 0, 1)
	else
		DeleteEntity(handcuffs)
		handcuffs = 0
	end
end


function DrawText3DTest(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

local notified = false
local disabledWeapons = false
RegisterNetEvent("disabledWeapons")
AddEventHandler("disabledWeapons", function(sentinfo)
	SetCurrentPedWeapon(PlayerPedId(), `weapon_unarmed`, 1)
	disabledWeapons = sentinfo
end)


Citizen.CreateThread(function() 

	while true do
  
	  Citizen.Wait(1)
  
	  if disabledWeapons then
		  DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
		  DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
	  end
  
	  if beingDragged or escort then
		  DisableControlAction(1, 23, true)  -- F
		  DisableControlAction(1, 106, true) -- VehicleMouseControlOverride
		  DisableControlAction(1, 140, true) --Disables Melee Actions
		  DisableControlAction(1, 141, true) --Disables Melee Actions
		  DisableControlAction(1, 142, true) --Disables Melee Actions	
		  DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
		  DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
		  DisableControlAction(2, 32, true)
		  DisableControlAction(1, 33, true)
		  DisableControlAction(1, 34, true)
		  DisableControlAction(1, 35, true)
		  DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
		  DisableControlAction(0, 59)
		  DisableControlAction(0, 60)
		  DisableControlAction(2, 31, true) 
		  SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
	  end
  
	  if handCuffedWalking or handCuffed then
		  
		  if handCuffed and CanPedRagdoll(PlayerPedId()) then
			  SetPedCanRagdoll(PlayerPedId(), false)
		  end
  
		  number = 49
  
		  if handCuffed then 
			  number = 16
		  else 
			  number = 49
		  end
  
		  DisableControlAction(1, 23, true)  -- F
		  DisableControlAction(1, 288, true) -- F1
		  DisableControlAction(1, 243, true) -- ~
		  DisableControlAction(1, 106, true) -- VehicleMouseControlOverride
		  DisableControlAction(1, 140, true) --Disables Melee Actions
		  DisableControlAction(1, 141, true) --Disables Melee Actions
		  DisableControlAction(1, 142, true) --Disables Melee Actions	
		  DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
		  DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
		  local dead = exports["dbfw-ambulancejob"]:GetDeath()
		  local intrunk = exports["isPed"]:isPed("intrunk")
		  if (not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) and not dead and not intrunk) or (IsPedRagdoll(PlayerPedId()) and not dead and not intrunk) then
			  RequestAnimDict('mp_arresting')
			  while not HasAnimDictLoaded("mp_arresting") do
				  Citizen.Wait(1)
			  end
			  TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, number, 0, 0, 0, 0)
		  end
		  if dead or intrunk then
			  Citizen.Wait(1000)
		  end
  
	  end
  
	  if not handCuffed and not CanPedRagdoll(PlayerPedId()) then
		  SetPedCanRagdoll(PlayerPedId(), true)
	  end
  
	end
  
  end)

  function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

Citizen.CreateThread(function()
	  local isNear = false
	  local cid = exports["isPed"]:isPed("cid")
	  while true do 
		  Wait(0)
  
			 if isCop then
  
				  local dist = #(vector3(449.79397583008,-993.05096435547,30.689556121826) - GetEntityCoords(PlayerPedId()))
				
				  if dist < 3 then isNear = true end

				  if dist < 3 then 
					if IsControlJustReleased(0, 38) then
						TriggerEvent("server-inventory-open", "1", "personalMRPD-"..cid)
					end
					DrawMarker(27,449.79397583008,-993.05096435547,29.689556121826, 0, 0, 0, 0, 0, 0, 0.69, 0.69, 0.3, 100, 255, 255, 60, 0, 0, 2, 0, 0, 0, 0) 
					DrawText3D(449.79397583008,-993.05096435547,30.689556121826,"[E] to Open MRPD personal stash.")
				  end
			  end
  
		  if not isNear then Wait(2000) end
	  end
  end)

  function DrawText3D(x,y,z, text) -- some useful function, use it if you want!
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.3,0.3)
        SetTextFont(0)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

RegisterNetEvent( 'Police:Radio' )
AddEventHandler( 'Police:Radio', function()
	if isCop then

		local ped = GetPlayerPed( -1 )

	    if ( DoesEntityExist( ped ) and not IsEntityDead( ped )) and exports["dbfw-ambulancejob"]:GetDeath() ~= 1 then

	   		local curw = GetSelectedPedWeapon(PlayerPedId())
			noweapon = `WEAPON_UNARMED`
			if noweapon == curw then
		    	--if GetPedConfigFlag(ped, 78, 1) then
		    	--	thisanim = "radio_chatter"
		    	--else
		    		thisanim = "generic_radio_enter"	
		    	--end

		        loadAnimDict( "random@arrests" )
		        if ( IsEntityPlayingAnim( ped, "random@arrests", "radio_chatter", 3 ) or IsEntityPlayingAnim( ped, "random@arrests", "generic_radio_enter", 3 ) ) then
						ClearPedSecondaryTask(ped)

						SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		        else
						TaskPlayAnim(ped, "random@arrests", thisanim, 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 )

						SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
		        end  
		          
		    end

	    end

	end

end)


intmenuopen = false
handcuffType = 16


local isTargetCuffed = false

function cuffCheck()
	if not handCuffed and not IsPedRagdoll(PlayerPedId()) and not IsPlayerFreeAiming(PlayerId()) and not IsPedInAnyVehicle(PlayerPedId(), false) then
		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 3 and not IsPedRagdoll(PlayerPedId())) then
			TriggerServerEvent("police:IsTargetCuffed", GetPlayerServerId(t)) 
		end
	end
end

RegisterNetEvent('police:isPlayerCuffed')
AddEventHandler('police:isPlayerCuffed', function(requestedID)
	TriggerServerEvent("police:confirmIsCuffed",requestedID,handCuffed)
end)


RegisterNetEvent('police:TargetIsCuffed')
AddEventHandler('police:TargetIsCuffed', function(result)
	isTargetCuffed = result
	if isTargetCuffed then
		TriggerEvent("openSubMenu","handcuffer")
	else
		TriggerEvent("police:cuffFromMenu")
	end
	isTargetCuffed = false
end)

RegisterNetEvent('police:AttemptCuffFromInventory')
AddEventHandler('police:AttemptCuffFromInventory', function()
	cuffCheck()
end)


local inmenus = false
RegisterNetEvent('inmenu')
AddEventHandler('inmenu', function(change)
	inmenus = change
end)


Citizen.CreateThread(function()
 	while true do
    Citizen.Wait(1)

  	-- Run cuff script if police is targeting someone with a weapon and pressed E
		if isCop and not inmenus then

			local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)

			if isInVeh then

				if IsControlJustReleased(0,172) or IsDisabledControlJustReleased(0,172) then
					TriggerEvent("platecheck:frontradar")
					Citizen.Wait(400)
				end

				if IsControlJustReleased(0,173) then
					TriggerEvent("platecheck:rearradar")
					Citizen.Wait(400)
				end

				if IsControlJustReleased(0,174) then
					TriggerEvent("startSpeedo")
					Citizen.Wait(400)
				end
																			
			else

				if IsControlJustReleased(2,172) and not IsControlPressed(0,19) then
					TriggerEvent("police:cuffFromMenu",false)
					Citizen.Wait(400)
				end

				if IsControlJustReleased(2,172) and IsControlPressed(0,19) then
					TriggerEvent("police:cuffFromMenu",true)
					Citizen.Wait(400)
				end

				if IsControlJustReleased(2,173) then
					TriggerEvent("police:uncuffMenu")
					Citizen.Wait(400)
				end
				-- left arrow
				if IsControlJustReleased(2,174) then
					TriggerEvent("escortPlayer")
					Citizen.Wait(400)
				end
				-- right arrow
				if IsControlJustReleased(2,175) then
					TriggerEvent("police:forceEnter")
					Citizen.Wait(400)
				end

			end

		end
		if isMedic and not inmenus then
			-- up arrow
			if IsControlJustReleased(2,172) then
				TriggerEvent("revive")
				Citizen.Wait(400)
			end
			-- down arrow
			if IsControlJustReleased(2,173) then
				TriggerEvent("ems:heal")
				Citizen.Wait(400)
			end
			-- left arrow
			if IsControlJustReleased(2,174) then
				TriggerEvent("escortPlayer")
				Citizen.Wait(400)
			end
			-- right arrow
			if IsControlJustReleased(2,175) then
				TriggerEvent("police:forceEnter")
				Citizen.Wait(400)
			end
		end
		if isDoctor and not inmenus then
			-- left arrow
			if IsControlJustReleased(2,174) then
				TriggerEvent("escortPlayer")
				Citizen.Wait(400)
			end
			-- up arrow
			if IsControlJustReleased(2,172) then
				TriggerEvent("ems:heal")
				Citizen.Wait(400)
			end
			-- down arrow
			if IsControlJustReleased(2,173) then
				TriggerEvent("revive")
				Citizen.Wait(400)
			end
			-- right arrow
			if IsControlJustReleased(2,175) then
				TriggerEvent("requestWounds")
				Citizen.Wait(400)
			end
		end

    	local ped = PlayerPedId()
        if ( IsEntityPlayingAnim( ped, "random@arrests", "radio_chatter", 3 ) or IsEntityPlayingAnim( ped, "random@arrests", "generic_radio_enter", 3 ) and not IsControlPressed(1,137) ) then
			ClearPedSecondaryTask(ped)
        end 

	end

end)

RegisterNetEvent("ems:heal")
AddEventHandler("ems:heal", function()
	t, distance = GetClosestPlayerAny()
	if t ~= nil and t ~= -1 then
		if(distance ~= -1 and distance < 5) then

			local myjob = exports["isPed"]:isPed("myjob")
			if myjob ~= "ambulance" then
				local bandages = exports["dbfw-inventory"]:getQuantity("bandage")
				if bandages == 0 then
					return
				else
					TriggerEvent('inventory:',"bandage", 1)
				end
			end

			TriggerEvent("animation:PlayAnimation","layspike")
			TriggerServerEvent("ems:healplayer", GetPlayerServerId(t))
		end
	end
end)

RegisterNetEvent("police:seizeCash")
AddEventHandler("police:seizeCash", function()

		t, distance, closestPed = GetClosestPlayer()

		if distance ~= -1 and distance < 5 then
			TriggerServerEvent("police:SeizeCash", GetPlayerServerId(t))
		else
			TriggerEvent("DoLongHudText", "No player near you!",2)
		end

end)

RegisterNetEvent("police:setAnimEmotes")
AddEventHandler("police:setAnimEmotes", function()
	TriggerServerEvent('police:getEmoteData')
	TriggerServerEvent('police:getAnimData')
end)

RegisterNetEvent("police:rob")
AddEventHandler("police:rob", function()
	if not exports["dbfw-ambulancejob"]:GetDeath() then
		RequestAnimDict("random@shop_robbery")
		while not HasAnimDictLoaded("random@shop_robbery") do
			Citizen.Wait(0)
		end

		local lPed = PlayerPedId()
		ClearPedTasksImmediately(lPed)

		TaskPlayAnim(lPed, "random@shop_robbery", "robbery_action_b", 8.0, -8, -1, 16, 0, 0, 0, 0)
		local finished = exports["dbfw-taskbar"]:taskBar(3500,"Robbing",false,true)	

		if finished == 100 then
			t, distance, closestPed = GetClosestPlayer()
			if distance ~= -1 and distance < 5 and ( IsEntityPlayingAnim(closestPed, "dead", "dead_a", 3) or IsEntityPlayingAnim(closestPed, "amb@code_human_cower_stand@male@base", "base", 3) or IsEntityPlayingAnim(closestPed, "amb@code_human_cower@male@base", "base", 3) or IsEntityPlayingAnim(closestPed, "random@arrests@busted", "idle_a", 3) or IsEntityPlayingAnim(closestPed, "mp_arresting", "idle", 3) or IsEntityPlayingAnim(closestPed, "random@mugging3", "handsup_standing_base", 3) or IsEntityPlayingAnim(closestPed, "missfbi5ig_22", "hands_up_anxious_scientist", 3) or IsEntityPlayingAnim(closestPed, "missfbi5ig_22", "hands_up_loop_scientist", 3) ) then
				ClearPedTasksImmediately(lPed)
				
				TriggerServerEvent("police:targetCheckInventory", GetPlayerServerId(t), false)
				TriggerServerEvent("police:rob:peeps", GetPlayerServerId(t))
			else
				TriggerEvent("DoLongHudText", "No player near you!",2)
			end
		end
	else
		TriggerEvent("DoLongHudText", "You are dead, you can't rob people you stupid fuck.",2)
	end
end)

RegisterNetEvent('police:seizeInventory')
AddEventHandler('police:seizeInventory', function()
		t, distance = GetClosestPlayer()
		if(distance ~= -1 and distance < 5) then
			TriggerServerEvent("police:targetseizeInventory", GetPlayerServerId(t))
		else

			TriggerEvent("DoLongHudText", "No player near you!",2)
		end
end)

inanim = false
cancelled = false
RegisterNetEvent( 'KneelHU' )
AddEventHandler( 'KneelHU', function()
    local player = GetPlayerPed( -1 )
	if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
        loadAnimDict( "random@arrests" )
		loadAnimDict( "random@arrests@busted" )
 			
		TaskPlayAnim( player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
		local finished = exports["dbfw-taskbar"]:taskBar(2500,"Surrendering")					
		
    
    end
end )


function KneelMedic()
    local player = GetPlayerPed( -1 )
	if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 

	        loadAnimDict( "amb@medic@standing@tendtodead@enter" )
	        loadAnimDict( "amb@medic@standing@timeofdeath@enter" )
	        loadAnimDict( "amb@medic@standing@tendtodead@idle_a" )
	        loadAnimDict( "random@crash_rescue@help_victim_up" )

			TaskPlayAnim( player, "amb@medic@standing@tendtodead@enter", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (1000)
			TaskPlayAnim( player, "amb@medic@standing@tendtodead@idle_a", "idle_b", 8.0, 1.0, -1, 9, 0, 0, 0, 0 )
			Wait (3000)
			TaskPlayAnim( player, "amb@medic@standing@tendtodead@exit", "exit_flee", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (1000)
            TaskPlayAnim( player, "amb@medic@standing@timeofdeath@enter", "enter", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )  
            Wait (500)
            TaskPlayAnim( player, "amb@medic@standing@timeofdeath@enter", "helping_victim_to_feet_player", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )  

    end
end



RegisterNetEvent('revive')
AddEventHandler('revive', function(t)

	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 10) then
		TriggerServerEvent("reviveGranted", GetPlayerServerId(t))
		KneelMedic()
		--TriggerServerEvent("take100",GetPlayerServerId(t))
		TriggerServerEvent("job:payment", "Player Revival", 100)
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end

end)

RegisterNetEvent('police:vin')
AddEventHandler('police:vin', function()
	if isCop then
	  playerped = PlayerPedId()
      coordA = GetEntityCoords(playerped, 1)
      coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
      targetVehicle = getVehicleInDirection(coordA, coordB)
     	targetspeed = GetEntitySpeed(targetVehicle) * 3.6
     	herSpeedMph = GetEntitySpeed(targetVehicle) * 2.236936
      licensePlate = GetVehicleNumberPlateText(targetVehicle)

      if licensePlate == nil then

      	TriggerEvent("DoLongHudText", 'Can not target vehicle',2)

      else
			TriggerServerEvent('checkVehVin',licensePlate)
		end
	end
end)


RegisterNetEvent('clientcheckLicensePlate')
AddEventHandler('clientcheckLicensePlate', function()
	if isCop then
	  playerped = PlayerPedId()
      coordA = GetEntityCoords(playerped, 1)
      coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
      targetVehicle = getVehicleInDirection(coordA, coordB)
     	targetspeed = GetEntitySpeed(targetVehicle) * 3.6
     	herSpeedMph = GetEntitySpeed(targetVehicle) * 2.236936
      licensePlate = GetVehicleNumberPlateText(targetVehicle)
      local vehicleClass = GetVehicleClass(targetVehicle)

      if licensePlate == nil then

      	TriggerEvent("DoLongHudText", 'Can not target vehicle',2)

      else
			TriggerServerEvent('checkLicensePlate',licensePlate,vehicleClass)
		end
	end
end)

RegisterNetEvent('sniffVehicle')
AddEventHandler('sniffVehicle', function()
	if isCop then
	  playerped = PlayerPedId()
      coordA = GetEntityCoords(playerped, 1)
      coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
      targetVehicle = getVehicleInDirection(coordA, coordB)
     	targetspeed = GetEntitySpeed(targetVehicle) * 3.6
     	herSpeedMph = GetEntitySpeed(targetVehicle) * 2.236936
      licensePlate = GetVehicleNumberPlateText(targetVehicle)

      if licensePlate == nil then

      	TriggerEvent("DoLongHudText", 'Can not target vehicle',2)

      else
			TriggerServerEvent('sniffLicensePlateCheck',licensePlate)
		end
	end
end)

RegisterNetEvent('showID')
AddEventHandler('showID', function()
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 5) then
		TriggerEvent("DoLongHudText", 'Player Found: ' .. GetPlayerServerId(t) .. ' ID#',1)

		 TriggerServerEvent('gc:showthemIdentity', GetPlayerServerId(t))
    else
    	TriggerEvent("DoLongHudText", 'No Player Found',2)

    end
end)
inanimation = false


RegisterNetEvent('animation:point')
AddEventHandler('animation:point', function()

		if not handCuffed then

			local lPed = PlayerPedId()

			RequestAnimDict("gestures@f@standing@casual")
			while not HasAnimDictLoaded("gestures@f@standing@casual") do
				Citizen.Wait(1)
			end
			
			if IsEntityPlayingAnim(lPed, "gestures@f@standing@casual", "gesture_point", 3) then
				ClearPedSecondaryTask(lPed)

			else
				TaskPlayAnim(lPed, "gestures@f@standing@casual", "gesture_point", 8.0, -8, -1, 49, 0, 0, 0, 0)
				seccount = 1
				while seccount > 0 do
					Citizen.Wait(1200)
					seccount = seccount - 1

				end
				ClearPedSecondaryTask(lPed)

			end		
		else
			ClearPedSecondaryTask(lPed)
		end

end)

cruisecontrol = false


RegisterNetEvent('toggle:cruisecontrol')
AddEventHandler('toggle:cruisecontrol', function()

	local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local driverPed = GetPedInVehicleSeat(currentVehicle, -1)

	if driverPed == PlayerPedId() then

		if cruisecontrol then
			SetEntityMaxSpeed(currentVehicle, 999.0)
			cruisecontrol = false
			TriggerEvent("DoLongHudText","Speed Limiter Inactive",1)
		else
			speed = GetEntitySpeed(currentVehicle)
			if speed > 15.0 then
			SetEntityMaxSpeed(currentVehicle, speed)
			cruisecontrol = true
				TriggerEvent("DoLongHudText","Speed Limiter Active",1)
			else
				TriggerEvent("DoLongHudText","Speed Limiter can only activate over 35mph",2)
			end
		end

	end
end)


RegisterNetEvent('animation:wave')
AddEventHandler('animation:wave', function()

		if not handCuffed then

			local lPed = PlayerPedId()

			RequestAnimDict("friends@frj@ig_1")
			while not HasAnimDictLoaded("friends@frj@ig_1") do
				Citizen.Wait(0)
			end
			
			if IsEntityPlayingAnim(lPed, "friends@frj@ig_1", "wave_a", 3) then
				ClearPedSecondaryTask(lPed)

			else
				TaskPlayAnim(lPed, "friends@frj@ig_1", "wave_a", 8.0, -8, -1, 49, 0, 0, 0, 0)
				seccount = 5
				while seccount > 0 do
					Citizen.Wait(1000)
					seccount = seccount - 1

				end
				ClearPedSecondaryTask(lPed)

			end		
		else
			ClearPedSecondaryTask(lPed)
		end

end)

RegisterNetEvent('animation:nod')
AddEventHandler('animation:nod', function()

		if not handCuffed then

			local lPed = PlayerPedId()

			RequestAnimDict("random@getawaydriver")
			while not HasAnimDictLoaded("random@getawaydriver") do
				Citizen.Wait(0)
			end
			
			if IsEntityPlayingAnim(lPed, "random@getawaydriver", "gesture_nod_yes_hard", 3) then
				ClearPedSecondaryTask(lPed)

			else
				TaskPlayAnim(lPed, "random@getawaydriver", "gesture_nod_yes_hard", 8.0, -8, -1, 49, 0, 0, 0, 0)
				seccount = 10
				while seccount > 0 do
					Citizen.Wait(1000)
					seccount = seccount - 1

				end
				ClearPedSecondaryTask(lPed)
			end		
		else
			ClearPedSecondaryTask(lPed)
		end

end)

RegisterNetEvent('animation:lockpickcar')
AddEventHandler('animation:lockpickcar', function()
	inanimation = true
	local lPed = PlayerPedId()
	ClearPedTasks(IPed)
	if not handCuffed then

		

		RequestAnimDict("mini@repair")
		while not HasAnimDictLoaded("mini@repair") do
			Citizen.Wait(0)
		end
		
		if IsEntityPlayingAnim(lPed, "mini@repair", "fixing_a_player", 3) then
			ClearPedSecondaryTask(lPed)
			TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
		else
			ClearPedTasksImmediately(IPed)
			TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
		end		
	else
		ClearPedSecondaryTask(lPed)
	end
	inanimation = false
end)

RegisterNetEvent('animation:repaircar')
AddEventHandler('animation:repaircar', function()

inanimation = true

		ClearPedTasksImmediately(IPed)
		if not handCuffed then

			local lPed = PlayerPedId()

			RequestAnimDict("mini@repair")
			while not HasAnimDictLoaded("mini@repair") do
				Citizen.Wait(0)
			end
			
			if IsEntityPlayingAnim(lPed, "mini@repair", "fixing_a_player", 3) then
				ClearPedSecondaryTask(lPed)
				TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
			else
				ClearPedTasksImmediately(IPed)
				TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
				seccount = 20
				while seccount > 0 do
					Citizen.Wait(1000)
					seccount = seccount - 1

				end
				ClearPedSecondaryTask(lPed)
			end		
		else
			ClearPedSecondaryTask(lPed)
		end
inanimation = false
end)



RegisterNetEvent('animation:phonecall')
AddEventHandler('animation:phonecall', function()
inanimation = true
		if not handCuffed then

			local lPed = PlayerPedId()

			RequestAnimDict("random@arrests")
			while not HasAnimDictLoaded("random@arrests") do
				Citizen.Wait(0)
			end
			
			if IsEntityPlayingAnim(lPed, "random@arrests", "idle_c", 3) then
				ClearPedSecondaryTask(lPed)

			else
				TaskPlayAnim(lPed, "random@arrests", "idle_c", 8.0, -8, -1, 49, 0, 0, 0, 0)
				seccount = 10
				while seccount > 0 do
					Citizen.Wait(1000)
					seccount = seccount - 1

				end
				ClearPedSecondaryTask(lPed)
			end		
		else
			ClearPedSecondaryTask(lPed)
		end
inanimation = false
end)

RegisterNetEvent('animation:facepalm')
AddEventHandler('animation:facepalm', function()

		if not handCuffed then

			local lPed = PlayerPedId()

			RequestAnimDict("random@car_thief@agitated@idle_a")
			while not HasAnimDictLoaded("random@car_thief@agitated@idle_a") do
				Citizen.Wait(0)
			end
			
			if IsEntityPlayingAnim(lPed, "random@car_thief@agitated@idle_a", "agitated_idle_a", 3) then
				ClearPedSecondaryTask(lPed)

			else
				TaskPlayAnim(lPed, "random@car_thief@agitated@idle_a", "agitated_idle_a", 8.0, -8, -1, 49, 0, 0, 0, 0)
				seccount = 6
				while seccount > 0 do
					Citizen.Wait(1000)
					seccount = seccount - 1

				end
				ClearPedSecondaryTask(lPed)
			end		
		else
			ClearPedSecondaryTask(lPed)
		end

end)

RegisterNetEvent('client:takephone')
AddEventHandler('client:takephone', function(t)
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 10) then
		TriggerServerEvent("server:takephone", GetPlayerServerId(t))
		TriggerEvent("DoLongHudText", 'Removed Phone Devices..',1)
	else
		TriggerEvent("DoLongHudText", 'No Player Found',2)
	end
end)

RegisterNetEvent('police:remweapons')
AddEventHandler('police:remweapons', function(t)
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 10) then
		TriggerServerEvent("police:remweaponsGranted", GetPlayerServerId(t))
	else
		TriggerEvent("DoLongHudText", 'No Player Found',1)
	end
end)

RegisterNetEvent('unseatPlayer')
AddEventHandler('unseatPlayer', function()

	t, distance = GetClosestPlayerIgnoreCar()
	if(distance ~= -1 and distance < 10) then
		local ped = PlayerPedId()  
		pos = GetEntityCoords(ped,  true)

		TriggerServerEvent('unseatAccepted',GetPlayerServerId(t),pos["x"], pos["y"], pos["z"])
		Citizen.Wait(1000)
		TriggerServerEvent("police:escortAsk", GetPlayerServerId(t))
	else
		TriggerEvent("DoLongHudText", 'No Player Found',1)
	end


end)

Citizen.CreateThread(function()

	while true do
		Citizen.Wait(1)
	  if (GetLastInputMethod(2) and IsControlPressed(1, 244)) then	
		TriggerEvent("event:control:police", 6) 	
	  end
	end
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/911', 'Submits a 911 call to the Emergency Services!', {
    { name="Report", help="Enter the incident/report here!" }
})
TriggerEvent('chat:addSuggestion', '/911r', 'Submits a 911r reply to the witness!', {
    { name="Target]".."[Reply", help="Enter your reply here!" }
})
end)

TimerEnabled = false


RegisterNetEvent('unseatPlayerFinish')
AddEventHandler('unseatPlayerFinish', function(x,y,z)
	local intrunk = exports["isPed"]:isPed("intrunk")
	--if not intrunk then
		local ped = PlayerPedId()  
		ClearPedTasksImmediately(ped)
		local veh = GetVehiclePedIsIn(ped, false)
        TaskLeaveVehicle(ped, veh, 256)
		SetEntityCoords(ped, x, y, z)
	--end
end)

-- random@shop_robbery robbery_action_a
local lastRob = false

RegisterNetEvent('robPlayer')
AddEventHandler('robPlayer', function()

	local finishedanim = false

	if lastRob and GetGameTimer() - lastRob < 600000 then TriggerEvent("DoLongHudText", "You can only mug once every 10 minutes",2) return end

	if not handCuffed then

		local lPed = PlayerPedId()

		RequestAnimDict("random@shop_robbery")
		while not HasAnimDictLoaded("random@shop_robbery") do
			Citizen.Wait(0)
		end
		
		if IsEntityPlayingAnim(lPed, "random@shop_robbery", "robbery_action_b", 3) then
			ClearPedSecondaryTask(lPed)
			finishedanim = false
		else
			ClearPedTasksImmediately(lPed)
			TaskPlayAnim(lPed, "random@shop_robbery", "robbery_action_b", 8.0, -8, -1, 16, 0, 0, 0, 0)
			local seccount = 7
			while seccount > 0 do
				Citizen.Wait(1200)
				seccount = seccount - 1

			end
			if IsEntityPlayingAnim(lPed, "random@shop_robbery", "robbery_action_b", 3) then
				finishedanim = true
			else
				finishedanim = false
			end
			ClearPedTasksImmediately(lPed)
		end		
	else
		ClearPedSecondaryTask(lPed)
	end

	if not finishedanim then return end

	t, distance = GetClosestPlayer()
	if distance ~= -1 and distance < 5 then

		if IsEntityPlayingAnim ( GetPlayerPed(t), "random@mugging3", "handsup_standing_base", 3) or IsEntityPlayingAnim(GetPlayerPed(t), "random@arrests@busted", "idle_a", 3) or isCop or IsPedRagdoll(GetPlayerPed(t))  then
			TriggerServerEvent("bank:steal", GetPlayerServerId(t))
			lastRob = GetGameTimer()
		else
			TriggerEvent("DoLongHudText", "You can only rob players that have their hands up.",2)
		end

	else
		--TriggerEvent("DoLongHudText","No target found.")
	end

end)

function LoadAnimationDictionary(animationD) -- Simple way to load animation dictionaries to save lines.
	while(not HasAnimDictLoaded(animationD)) do
		RequestAnimDict(animationD)
		Citizen.Wait(1)
	end
end





otherid = 0
escort = false
keystroke = 49
triggerkey = false

dragging = false
beingDragged = false

escortStart = false
shitson = false

RegisterNetEvent('dragPlayer')
AddEventHandler('dragPlayer', function()
	local handcuffed = exports["isPed"]:isPed("handcuffed")
	if handcuffed then
		TriggerEvent("DoLongHudText","You are in handcuffs!",2)
		return
	end
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 1.0) then
		if not beingDragged then
			DetachEntity(PlayerPedId(), true, false)
			TriggerServerEvent("police:dragAsk", GetPlayerServerId(t))
		end
	end
end)

RegisterNetEvent('drag:stopped')
AddEventHandler('drag:stopped', function(sentid)
	if tonumber(sentid) == tonumber(otherid) and beingDragged then
		shitson = false
		beingDragged = false
		DetachEntity(PlayerPedId(), true, false)
		TriggerEvent("deathdrop",beingDragged)
	end
end)

RegisterNetEvent('escortPlayer')
AddEventHandler('escortPlayer', function()
	local handcuffed = exports["isPed"]:isPed("handcuffed")
	-- if handcuffed then
	-- 	TriggerEvent("DoLongHudText","You are in handcuffs!",2)
	-- 	return
	-- end
	t, distance = GetClosestPlayer()
	if(distance ~= -1 and distance < 5) then
		if not escort then

			--TriggerServerEvent("inv:weightAsk", GetPlayerServerId(t))
			Wait(800)
			-- if targetsWeight > 90 then
			-- 	TriggerEvent("DoLongHudText","Cannot Escort Someone who is overburdened.",2)
			-- else
			TriggerServerEvent("police:escortAsk", GetPlayerServerId(t))
			--end
		end
	else
		escorting = false
	end
end)

RegisterNetEvent("unEscortPlayer")
AddEventHandler("unEscortPlayer", function()
	escort = false
	beingDragged = false
	ClearPedTasks(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)


RegisterNetEvent("dr:dragging")
AddEventHandler('dr:dragging', function()

	dragging = not dragging

	if not dragging and IsPedInAnyVehicle(PlayerPedId(), false) then
		return
	end
	
	if dragging then
		print("Dragging")
	else
		ClearPedTasksImmediately(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
	end

end)

local escorting = false

RegisterNetEvent("dr:releaseEscort")
AddEventHandler("dr:releaseEscort", function()
	escorting = false
end)




RegisterNetEvent("dr:escort")
AddEventHandler('dr:escort', function(pl)
	otherid = tonumber(pl)
	if not escort and IsPedInAnyVehicle(PlayerPedId(), false) then
		return
	end
	escort = not escort
	if not escort then
		TriggerServerEvent("dr:releaseEscort",otherid)
	end

end)

RegisterNetEvent("dr:drag")
AddEventHandler('dr:drag', function(pl)
	otherid = tonumber(pl)
	beingDragged = not beingDragged
	if beingDragged then
		SetEntityCoords(PlayerPedId(),GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(otherid))))
	end
	Citizen.Wait(1000)
	TriggerEvent("deathdrop",beingDragged)
end)





RegisterNetEvent("dr:escortingEnabled")
AddEventHandler('dr:escortingEnabled', function()
	escorting = true
end)




--GetEntityAttachedTo(PlayerPedId())

Citizen.CreateThread(function()
	while true do
		if escorting or dragging then
			if IsPedRunning(PlayerPedId()) or IsPedSprinting(PlayerPedId()) then
				SetPlayerControl(PlayerId(), 0, 0)
				Citizen.Wait(1000)
				SetPlayerControl(PlayerId(), 1, 1)
			end
		else
			Citizen.Wait(1000)
		end
		Citizen.Wait(1)
	end
end)


Citizen.CreateThread(function()
	while true do

		if IsEntityDead(GetPlayerPed(GetPlayerFromServerId(otherid))) and (escort) then 
			DetachEntity(PlayerPedId(), true, false)
			shitson = false	
			escort = false
			local pos = GetOffsetFromEntityInWorldCoords(GetPlayerPed(GetPlayerFromServerId(otherid)), 0.0, 0.8, 2.8)
			SetEntityCoords(PlayerPedId(),pos)
		end


		if escort or beingDragged then
			local ped = GetPlayerPed(GetPlayerFromServerId(otherid))
			local myped = PlayerPedId()
			if escort then
				x,y,z = 0.54, 0.44, 0.0
			else
				x,y,z = 0.0, 0.44, 0.0
			end
			if not beingDragged then
				AttachEntityToEntity(myped, ped, 11816, x, y, z, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			else
				AttachEntityToEntity(myped, ped, 1, -0.68, -0.2, 0.94, 180.0, 180.0, 60.0, 1, 1, 0, 1, 0, 1)
			end
			
			shitson = true
			--escortStart = true
		else
			if not beingDragged and not escort and shitson then
				DetachEntity(PlayerPedId(), true, false)	
				shitson = false	
				Citizen.Trace("no escort or drag")
				ClearPedTasksImmediately(PlayerPedId())
			end
		end

		if dragging then

			if not IsEntityPlayingAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 3) then
				LoadAnimationDictionary( "missfinale_c2mcs_1" ) 
				TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, 1.0, -1, 50, 0, 0, 0, 0)
			end
			local dead = exports["dbfw-ambulancejob"]:GetDeath()
			if dead or IsControlJustPressed(0, 38) or (`WEAPON_UNARMED` ~= GetSelectedPedWeapon(PlayerPedId())) then
				dragging = false
				ClearPedTasks(PlayerPedId())
				TriggerServerEvent("dragPlayer:disable")
			end

		end

		if beingDragged then
			if not IsEntityPlayingAnim(PlayerPedId(), "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 3) then
				LoadAnimationDictionary( "amb@world_human_bum_slumped@male@laying_on_left_side@base" ) 
				TaskPlayAnim(PlayerPedId(), "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
			end
		end
		Citizen.Wait(1)
	end
end)



RegisterNetEvent('FlipVehicle')
AddEventHandler('FlipVehicle', function()
	local finished = exports["dbfw-taskbar"]:taskBar(5000,"Flipping Vehicle Over",false,true)	

	if finished == 100 then
		local playerped = PlayerPedId()
	    local coordA = GetEntityCoords(playerped, 1)
	    local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
		local targetVehicle = getVehicleInDirection(coordA, coordB)
		local pPitch, pRoll, pYaw = GetEntityRotation(playerped)
		local vPitch, vRoll, vYaw = GetEntityRotation(targetVehicle)
		SetEntityRotation(targetVehicle, pPitch, vRoll, vYaw, 1, true)
		Wait(10)
		SetVehicleOnGroundProperly(targetVehicle)
	end

end)

function deleteVeh(ent)

	SetVehicleHasBeenOwnedByPlayer(ent, true)
	NetworkRequestControlOfEntity(ent)
	local finished = exports["dbfw-taskbar"]:taskBar(1000,"Impounding",false,true)	
	Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(ent))
	DeleteEntity(ent)
	DeleteVehicle(ent)
	SetEntityAsNoLongerNeeded(ent)
end

RegisterNetEvent('impoundVehicle')
AddEventHandler('impoundVehicle', function()

	playerped = PlayerPedId()
    coordA = GetEntityCoords(playerped, 1)
    coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
   -- targetVehicle = getVehicleInDirection(coordA, coordB)


    targetVehicle = getVehicleInDirection(coordA, coordB)

	licensePlate = GetVehicleNumberPlateText(targetVehicle)

	TriggerServerEvent("garages:SetVehImpounded",targetVehicle,licensePlate,false)
	TriggerEvent("DoLongHudText","Impounded with retrieval price of $100",1)
	deleteVeh(targetVehicle)
end)



RegisterNetEvent('fullimpoundVehicle')
AddEventHandler('fullimpoundVehicle', function()
	playerped = PlayerPedId()
    coordA = GetEntityCoords(playerped, 1)
    coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
    --targetVehicle = getVehicleInDirection(coordA, coordB)
   	targetVehicle = getVehicleInDirection(coordA, coordB)



	licensePlate = GetVehicleNumberPlateText(targetVehicle)
	TriggerServerEvent("garages:SetVehImpounded",targetVehicle,licensePlate,true)
	TriggerEvent("DoLongHudText","Impounded with retrieval price of $1500",1)

	deleteVeh(targetVehicle)
end)

--------------------------------------------------------------------------------------------------------------
------------------------------------------VEHICLE FUNCTIONS---------------------------------------------------
local emsVehicleListWhite = { 
	{"Ambulance", "emsa"},
	{"Helicopter", "emsair"},
	{"Charger", "emsc"},
	{"F350", "emsf"},
	{"Tahoe", "emst"},
	{"Coroner", "emsv"},
	{"Firetruck", "firetruk"},
	{"Boat", "dinghy4"},
}

local emsVehicleList = { 
	"ambulance"
}

local copVehicleList = { 
	{"LSPD Vic", "POLVIC"},
	{"BCSO/SASP Vic", "POLVIC2"},
	{"Taurus", "POLTAURUS"},
	{"Tahoe", "POLTAH"},
	--{"Motorbike", "pol8"},
	{"Raptor", "POLRAPTOR"},
	{"Charger", "POLCHAR"},
	--{"SWAT Suburban", "pol10"},
	--{"Helicopter", "maverick2"},
	{"Boat", "predator"},
	--{"Prison Bus", "pbus2"},
	{"Armored Van", "policet"},
	{"Mustang", "2015POLSTANG"},
	{"FBI Buffalo", "fbi"},
	-- {"FBI Granger", "fbi2"},

	-- {"UC Washington", "ucwashington"},
	-- {"UC Banshee", "ucbanshee"},
	-- {"UC Rancher", "ucrancher"},
	-- {"UC Primo", "ucprimo"},
	-- {"UC Coquette", "uccoquette"},
	-- {"UC Buffalo", "ucbuffalo"},
	-- {"UC Baller", "ucballer"},
	-- {"UC Comet", "uccomet"},

	--"flatbed2", -- PD tow truck.
}

local pullout = false

local function serviceVehicle(arg, livery, isEmsWhiteListed, cb)
	if not arg then cb("No argument was given") return end

	local function printHelp(list)
		copVehStrList = ""
		for i=1, #list do
			copVehStrList = copVehStrList.."["..i.."] "..list[i][1].."\n"
		end
		TriggerEvent("chatMessagess", "SYSTEM ", 2, copVehStrList)
	end
	if arg == "help" then
	end
	if arg == "help" then
		if isCop then
			printHelp(copVehicleList)
		elseif isEmsWhiteListed then
			printHelp(emsVehicleListWhite)
		end
		return
	end

	arg = tonumber(arg)
	if not arg then cb("Invalid argument") return end


	if isCop then
		if arg > #copVehicleList then arg = 1 end

		selectedSkin = copVehicleList[arg][2]

	else
		if isEmsWhiteListed then
			if arg > #emsVehicleListWhite then arg = 1 end
			selectedSkin = emsVehicleListWhite[arg][2]
		else
			if arg > #emsVehicleList then arg = 1 end
			selectedSkin = emsVehicleList[arg]
		end
	end


	Citizen.CreateThread(function()
		
		if not pullout then
			pullout = true
		else
			--TriggerServerEvent("MayorCashAdjust",250,2,"New Emergency Vehicle")
		end

		local hash = GetHashKey(selectedSkin)

		if not IsModelAVehicle(hash) then cb("Model isn't a vehicle") return end
		if not IsModelInCdimage(hash) or not IsModelValid(hash) then cb("Model doesn't exist") return end

		TriggerEvent("np-admin:runSpawnCommand",selectedSkin, livery)
	end)
end

local policeSkinsList = {"s_m_y_cop_01", "s_f_y_sheriff_01", "s_m_y_hwaycop_01", "s_m_y_ranger_01", "s_m_y_sheriff_01", "s_m_y_swat_01", "s_f_y_cop_02C"}


RegisterNetEvent("police:chatCommand")
AddEventHandler("police:chatCommand", function(args)
	print(args[1])
	serviceVehicle(args[1], args[2])
end)

local LastVehicle = nil
RegisterNetEvent("np-admin:runSpawnCommand")
AddEventHandler("np-admin:runSpawnCommand", function(model, livery)
    Citizen.CreateThread(function()

        local hash = GetHashKey(model)

        if not IsModelAVehicle(hash) then return end
        if not IsModelInCdimage(hash) or not IsModelValid(hash) then return end
        
        RequestModel(hash)

        while not HasModelLoaded(hash) do
            Citizen.Wait(0)
        end

        local localped = PlayerPedId()
        local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 1.5, 5.0, 0.0)

        local heading = GetEntityHeading(localped)
        local vehicle = CreateVehicle(hash, coords, heading, true, false)

        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 11, 3, false)
        SetVehicleMod(vehicle, 12, 2, false)
        SetVehicleMod(vehicle, 13, 2, false)
        SetVehicleMod(vehicle, 15, 3, false)
        SetVehicleMod(vehicle, 16, 4, false)


        if model == "pol1" then
            SetVehicleExtra(vehicle, 5, 0)
        end

        if model == "police" then
            SetVehicleWheelType(vehicle, 2)
            SetVehicleMod(vehicle, 23, 10, false)
            SetVehicleColours(vehicle, 0, false)
            SetVehicleExtraColours(vehicle, 0, false)
        end

        if model == "pol7" then
            SetVehicleColours(vehicle,0)
            SetVehicleExtraColours(vehicle,0)
        end

        if model == "pol5" or model == "pol6" then
            SetVehicleExtra(vehicle, 1, -1)
        end


        local plate = GetVehicleNumberPlateText(vehicle)
		TriggerServerEvent('garage:addKeys', plate)
        TriggerServerEvent('garages:addJobPlate', plate)
        SetModelAsNoLongerNeeded(hash)
        
        SetVehicleDirtLevel(vehicle, 0)
        SetVehicleWindowTint(vehicle, 0)

        if livery ~= nil then
            SetVehicleLivery(vehicle, tonumber(livery))
        end
        LastVehicle = vehicle
    end)
end)
----------------------------------------POLICE THINGS MORE ---------------------------------------------------
local copOutfits = {
	
	[1] = {0,0,0,22,25,0,2,8,66,1,0,156,"male",false}, --BCSO 
	[2] = {0,0,0,22,25,0,2,6,57,2,0,24,"male",false}, --BCSO
	[3] = {0,0,0,22,32,0,13,6,57,2,0,24,"male",false}, --BCSO

	[4] = {0,0,0,14,31,0,9,6,32,14,0,91,"female",true}, --BCSO
	[5] = {0,0,0,14,41,0,25,6,34,14,0,91,"female",false}, --BCSO

	[6] = {0,0,0,0,59,0,24,0,44,20,0,93,"male",false}, --LSPD
	[7] = {0,0,0,1,25,0,51,6,57,13,0,26,"male",true}, --SASP
	[8] = {0,0,0,1,32,0,13,6,57,13,0,26,"male",false}, --SASP
	[9] = {0,0,0,0,25,0,51,6,57,13,0,118,"male",true}, --SASP
	[10] = {0,0,0,1,32,0,13,6,57,13,0,118,"male",false}, --SASP
	[11] = {0,0,0,19,33,0,50,6,57,12,0,102,"male",false}, --SASP K9
	[12] = {0,0,0,1,25,0,51,8,122,26,0,103,"male",true}, --SASP

	[13] = {0,0,0,0,35,0,25,8,39,13,0,149,"male",false}, --LSPD
	[14] = {0,0,0,1,35,0,25,8,39,13,0,143,"male",false}, --LSPD
	[15] = {0,0,0,14,31,0,9,8,64,0,0,153,"female",true}, --BCSO
}

local copOutfitColors = {
	[4] = {0,0,0,2,0,0,0,0,0,0,0,0},
	[7] = {0,0,0,1,0,0,0,0,0,0,0,0},
	[9] = {0,0,0,1,0,0,0,0,0,0,0,0},
	[12] = {0,0,0,1,0,0,0,0,0,0,0,0},
	[15] = {0,0,0,0,2,0,0,0,4,0,0,3},
}

function SkinNoUpdate(arg)
	local model
	if copOutfits[arg] then
		if copOutfits[arg][13] == "male" then
			 model = `mp_m_freemode_01`
		else
			 model = `mp_f_freemode_01`
		end
		if IsModelInCdimage(model) and IsModelValid(model) then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Citizen.Wait(0)
			end
			local head = GetPedDrawableVariation(PlayerPedId(),0)
			local hair = GetPedDrawableVariation(PlayerPedId(),2)
			local hairC = GetPedTextureVariation(PlayerPedId(),2)


			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)

			for i,v in ipairs(copOutfits[arg]) do
				if copOutfits[arg][14] then
					SetPedComponentVariation(PlayerPedId(),i-1,v,copOutfitColors[arg][i-1],0)
				else
					SetPedComponentVariation(PlayerPedId(),i-1,v,0,0)
				end	
			end

			SetPedComponentVariation(PlayerPedId(),0,head,0,0)
			SetPedComponentVariation(PlayerPedId(),2,hair,hairC,0)
		else
			TriggerEvent("DoLongHudText","Model not found",2)
		end
	else
		TriggerEvent("DoLongHudText","Outfit not found",2)
	end
end

RegisterNetEvent('police:checkInventory')
AddEventHandler('police:checkInventory', function(isFrisk)
		if isFrisk == nil then isFrisk = false end
		t, distance, closestPed = GetClosestPlayer()
		if(distance ~= -1 and distance < 5) then
			
			TriggerServerEvent("people-search", GetPlayerServerId(t))
		else
			TriggerEvent("DoLongHudText", "No player near you!",2)
		end
end)

RegisterNetEvent('police:checkBank')
AddEventHandler('police:checkBank', function()
	t, distance, closestPed = GetClosestPlayer()
	if(distance ~= -1 and distance < 7) then
		TriggerServerEvent("police:targetCheckBank", GetPlayerServerId(t))
	else
		TriggerEvent("DoLongHudText", "No player near you!",2)
	end
end)

--------------------------------------------------------------------------------------------------------------

function getVehicleInDirection(coordFrom, coordTo)
	local offset = 0
	local rayHandle
	local vehicle

	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)	
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		
		offset = offset - 1

		if vehicle ~= 0 then break end
	end
	
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
	
	if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function ShowRadarMessage(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end

function DisplayHelpText(str)
  SetTextComponentFormat("STRING")
  AddTextComponentString(str)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function GetStreetAndZone()
    local plyPos = GetEntityCoords(PlayerPedId(),  true)
    local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    zone = tostring(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
    local playerStreetsLocation = GetLabelText(zone)
    local street = street1 .. ", " .. playerStreetsLocation
    return street
end

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayers(targetVector,dist)
	local players = GetPlayers()
	local ply = PlayerPedId()
	local plyCoords = targetVector
	local closestplayers = {}
	local closestdistance = {}
	local closestcoords = {}

	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(distance < dist) then
				valueID = GetPlayerServerId(value)
				closestplayers[#closestplayers+1]= valueID
				closestdistance[#closestdistance+1]= distance
				closestcoords[#closestcoords+1]= {targetCoords["x"], targetCoords["y"], targetCoords["z"]}
				
			end
		end
	end
	return closestplayers, closestdistance, closestcoords
end

function GetClosestPlayerVehicleToo()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	if not IsPedInAnyVehicle(PlayerPedId(), false) then
		for index,value in ipairs(players) do
			local target = GetPlayerPed(value)
			if(target ~= ply) then
				local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
				local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
				if(closestDistance == -1 or closestDistance > distance) then
					closestPlayer = value
					closestDistance = distance
				end
			end
		end
		return closestPlayer, closestDistance
	else
		TriggerEvent("DoShortHudText","Inside Vehicle.",2)
	end
end

function GetClosestPlayerAny()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)


	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance



end



function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local closestPed = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	if not IsPedInAnyVehicle(PlayerPedId(), false) then

		for index,value in ipairs(players) do
			local target = GetPlayerPed(value)
			if(target ~= ply) then
				local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
				local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
				if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
					closestPlayer = value
					closestPed = target
					closestDistance = distance
				end
			end
		end
		
		return closestPlayer, closestDistance, closestPed

	else
		TriggerEvent("DoShortHudText","Inside Vehicle.",2)
	end

end
function GetClosestPedIgnoreCar()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local closestPlayerId = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = target
				closestPlayerId = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance, closestPlayerId
end
function GetClosestPlayerIgnoreCar()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end


function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end















------------------blips
-- Create blip for colleagues
function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		SetBlipColour (blip, 67)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end

function createBlip2(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		SetBlipColour (blip, 8)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('dbfw-policejob:updateBlip')
AddEventHandler('dbfw-policejob:updateBlip', function()

	-- Refresh all blips
	for k, existingBlip in pairs(blipsCops) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsCops = {}

	-- Enable blip?
	if Config.MaxInService ~= -1 and not playerInService then
		return
	end

	if not Config.EnableJobBlip then
		return
	end

	-- Is the player a cop? In that case show all the blips for other cops
	if PlayerData.job and PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
		DBFWCore.TriggerServerCallback('dbfw-society:getOnlinePlayers', function(players)
			for i=1, #players, 1 do
				if players[i].job.name == 'ambulance' then
					local id = GetPlayerFromServerId(players[i].source)
					if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						createBlip2(id)
					end
				end
			end
		end)
	end

end)

RegisterNetEvent('dbfw-policejob:updateBlip')
AddEventHandler('dbfw-policejob:updateBlip', function()

	-- Refresh all blips
	for k, existingBlip in pairs(blipsCops) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsCops = {}

	-- Enable blip?
	if Config.MaxInService ~= -1 and not playerInService then
		return
	end

	if not Config.EnableJobBlip then
		return
	end

	-- Is the player a cop? In that case show all the blips for other cops
	if PlayerData.job and PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
		DBFWCore.TriggerServerCallback('dbfw-society:getOnlinePlayers', function(players)
			for i=1, #players, 1 do
				if players[i].job.name == 'police' then
					local id = GetPlayerFromServerId(players[i].source)
					if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						createBlip(id)
					end
				end
			end
		end)
	end

end)

RegisterCommand('case', function(source,args)
	local case = args[1]
	if isCop then
		TriggerEvent('evidence:container', case)
	end
end)

AddEventHandler('playerSpawned', function(spawn)
	if not hasAlreadyJoined then
		TriggerServerEvent('dbfw-policejob:spawned')
	end
	hasAlreadyJoined = true
end)


RegisterNetEvent("police:setClientMetatest")
AddEventHandler("police:setClientMetatest",function(meta)
	-- print(meta.thirst)
	for i,v in ipairs(meta) do
		local sv = json.decode(v)
	end
end)

RegisterNetEvent("tp:pdrevive")
AddEventHandler("tp:pdrevive", function()
	local closestPlayer, closestDistance = DBFWCore.Game.GetClosestPlayer()
	local playerPed = GetPlayerPed(-1)
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerEvent('DoLongHudText', 'Revive In Progress', 1)
        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
        Wait(10000)
        ClearPedTasks(playerPed)
		TriggerServerEvent('dbfw-ambulancejob:revivePD', GetPlayerServerId(closestPlayer))
		TriggerEvent('dbfw-hospital:client:RemoveBleed')
		TriggerEvent('DoLongHudText', 'Revive was successful please head to pillbox to have them fully treated', 1)
	else
		TriggerEvent('DoLongHudText', 'There is no player(s) nearby!', 2)
    end
end)