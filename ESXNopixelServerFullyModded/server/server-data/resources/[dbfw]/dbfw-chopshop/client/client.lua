local HasAlreadyEnteredMarker = false
local CurrentActionMsg        = nil
DBFWCore                       = nil
local beingchopped            = false

Citizen.CreateThread(function ()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
end)

local chopshop_mechanic
Citizen.CreateThread(function()

    local hashkey = GetHashKey(Config.NPCName)

	RequestModel(hashkey)
	while not HasModelLoaded(hashkey) do Wait(1) end

	chopshop_mechanic = CreatePed(1, hashkey, Config.NPCLocation.x, Config.NPCLocation.y, Config.NPCLocation.z, Config.NPCLocation.h, false, true)
	SetBlockingOfNonTemporaryEvents(chopshop_mechanic, true)
	SetPedDiesWhenInjured(chopshop_mechanic, false)
	SetPedCanPlayAmbientAnims(chopshop_mechanic, true)
	SetPedCanRagdollFromPlayerImpact(chopshop_mechanic, false)
	SetEntityInvincible(chopshop_mechanic, true)
	FreezeEntityPosition(chopshop_mechanic, true)
    TaskStartScenarioInPlace(chopshop_mechanic, Config.NPCScenerioCurrent, 0, true);

end)

function Draw3dText(x,y,z, text)
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


Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false

		if(GetDistanceBetweenCoords(coords, Config.MarkerPos.x, Config.MarkerPos.y, Config.MarkerPos.z, true) < 5.0) then
			isInMarker  = true
		end

		if (isInMarker) then
            HasAlreadyEnteredMarker = true
            if beingchopped == false then
                TriggerEvent('dbfw-chopshop:entered')
            end
            if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and beingchopped == false then
                Draw3dText(Config.MarkerPos.x, Config.MarkerPos.y, Config.MarkerPos.z + 1.0, "[E] - Start Chopping")
            elseif not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) and beingchopped == false then
                Draw3dText(Config.MarkerPos.x, Config.MarkerPos.y, Config.MarkerPos.z + 1.0, "Not in vehicle")
            end
		end

		if not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
			TriggerEvent('dbfw-chopshop:exited')
        end

        if beingchopped then
            DisableActions()
        end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(10)
        if CurrentActionMsg == nil then
            Citizen.Wait(500)
        else
            if not beingchopped then
                if IsControlJustReleased(0, Config.ActionButton) then
                    ClearPedTasksImmediately(chopshop_mechanic)
                    TaskStartScenarioInPlace(chopshop_mechanic, Config.NPCScenerioInProg, 0, true)
                    SetVehicleEngineOn(GetVehiclePedIsUsing(GetPlayerPed(-1)), false, false, true)
                    TriggerEvent('dbfw-chopshop:startchop')
                end
            end
        end
    end
end)

function OpenParts()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsUsing(ped)
    exports["dbfw-taskbar"]:taskBar(3000, "Opening Driver Door")
    Citizen.Wait(3000)
    SetVehicleDoorOpen(vehicle, 0, false, false)
    exports["dbfw-taskbar"]:taskBar(3000, "Opening Passenger Door")
    Citizen.Wait(3000)
    SetVehicleDoorOpen(vehicle, 1, false, false)
    if GetEntityBoneIndexByName(vehicle, 'door_dside_r') ~= -1 then
        exports["dbfw-taskbar"]:taskBar(3000, "Opening Back Left Door")
        Citizen.Wait(3000)
        SetVehicleDoorOpen(vehicle, 2, false, false)
        exports["dbfw-taskbar"]:taskBar(3000, "Opening Back Right Door")
        Citizen.Wait(3000)
        SetVehicleDoorOpen(vehicle, 3, false, false)
    end
    if GetEntityBoneIndexByName(vehicle, 'bonnet') ~= -1 then
        exports["dbfw-taskbar"]:taskBar(3000, "Opening Hood")
        Citizen.Wait(3000)
        SetVehicleDoorOpen(vehicle, 4, false, false)
    end
    if GetEntityBoneIndexByName(vehicle, 'boot') ~= -1 then
        exports["dbfw-taskbar"]:taskBar(3000, "Opening Trunk")
        Citizen.Wait(3000)
        SetVehicleDoorOpen(vehicle, 5, false, false)
    end
end

function ShutParts()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsUsing(ped)
    SetVehicleUndriveable(vehicle, false)
    Citizen.Wait(1000)
    SetVehicleDoorsShut(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true, true)
end
function RemoveParts()
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsUsing(ped)
    exports["dbfw-taskbar"]:taskBar(3000, "Removing Driver Door")
    Citizen.Wait(3000)
    SetVehicleDoorBroken(vehicle,0, true)
    exports["dbfw-taskbar"]:taskBar(3000, "Removing Passenger Door")
    Citizen.Wait(3000)
    SetVehicleDoorBroken(vehicle,1, true)
    if GetEntityBoneIndexByName(vehicle, 'door_dside_r') ~= -1 then
        exports["dbfw-taskbar"]:taskBar(3000, "Removing Back Left Door")
        Citizen.Wait(3000)
        SetVehicleDoorBroken(vehicle,2, true)
        exports["dbfw-taskbar"]:taskBar(3000, "Removing Back Right Door")
        Citizen.Wait(3000)
        SetVehicleDoorBroken(vehicle,3, true)
    end
    if GetEntityBoneIndexByName(vehicle, 'bonnet') ~= -1 then
        exports["dbfw-taskbar"]:taskBar(3000, "Removing Hood")
        Citizen.Wait(3000)
        SetVehicleDoorBroken(vehicle,4, true)
    end
    if GetEntityBoneIndexByName(vehicle, 'boot') ~= -1 then
        exports["dbfw-taskbar"]:taskBar(3000, "Removing Trunk")
        Citizen.Wait(3000)
        SetVehicleDoorBroken(vehicle,5, true)
    end
end

RegisterNetEvent('dbfw-chopshop:startchop')
AddEventHandler('dbfw-chopshop:startchop', function ()
    beingchopped = true
    CurrentActionMsg = nil
    local ped = GetPlayerPed( -1 )
    for i = 1, #Config.Progress, 1 do
        local table2 = Config.Progress[i]
        if IsPedInAnyVehicle(ped, true) then

            for key, value in pairs(table2) do
                if IsPedInAnyVehicle(ped, true) then
                    exports["dbfw-taskbar"]:taskBar(key*250, value)
                    Citizen.Wait(key*250)
                else
                    break
                end
            end
        else
            break
        end
    end
    if IsPedInAnyVehicle(ped, true) then
        local vehicle = GetVehiclePedIsIn( ped, true )
        local plate = ''
        local carnamepedin = ''
        OpenParts()
        local ssstring = ''
        if ( GetPedInVehicleSeat( vehicle, -1 ) == ped ) then 
            SetEntityAsMissionEntity( vehicle, true, true )
            local vehicleData = DBFWCore.Game.GetVehicleProperties(vehicle)
            canchop = false
            plate = vehicleData.plate
            for key, value in pairs(Config.Cars) do
                if IsVehicleModel(vehicle, key) then
                    canchop = true
                end
            end
            carnamepedin = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(PlayerPedId()))))
            if canchop == true then
                RemoveParts()

                TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
				while IsPedInVehicle(PlayerPedId(), vehicle, true) do Citizen.Wait(0) end
				Citizen.Wait(500)
                NetworkFadeOutEntity(vehicle, true, true)
				Citizen.Wait(100)
                DBFWCore.Game.DeleteVehicle(vehicle)
                                
                ssstring = Config.Success
                ShutParts()
                ssstring = ssstring:gsub('%%car%%',carnamepedin)
                ssstring = ssstring:gsub('%%plate%%',plate)
                TriggerEvent('DoLongHudText', 'You got scaps and money for the vehicle.', 1)
                TriggerServerEvent('dbfw-chopshop:addCash')
                beingchopped = false
                return
            else
                ssstring = Config.FailChop
            end
        else
            ssstring = Config.FailSeat
        end
        ShutParts()
        ssstring = ssstring:gsub('%%car%%',carnamepedin)
        ssstring = ssstring:gsub('%%plate%%',plate)
        TriggerEvent('DoLongHudText', 'You got scaps and money for the vehicle.', 1)
    else
        TriggerEvent('DoLongHudText', Config.FailLeft, 2)
        ShutParts()
    end
    beingchopped = false
    ClearPedTasksImmediately(chopshop_mechanic)
	TaskStartScenarioInPlace(chopshop_mechanic, Config.NPCScenerioCurrent, 0, true);
end)

-- we can create these later if needed
--[[Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.MarkerPos.x, Config.MarkerPos.y, Config.MarkerPos.z)

	SetBlipSprite (blip, Config.BlipSprite)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, Config.BlipScale)
	SetBlipColour (blip, Config.BlipColor)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Config.Blipname)
	EndTextCommandSetBlipName(blip)
end)]]--

AddEventHandler('dbfw-chopshop:entered', function ()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, true) then
        CurrentActionMsg = Config.ActionMsg
    end
end)

AddEventHandler('dbfw-chopshop:exited', function ()
	CurrentActionMsg = nil
end)

function deleteCar( entity )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
end

function convertcolor(from, to)
    fade = Config.MarkerFadeTimer
    if from.r ~= to.r then
        if from.r < to.r then
            to.r = to.r - fade
            if from.r > to.r then
                to.r = to.r + 1
            end
        else
            to.r = to.r + fade
            if from.r > to.r then
                to.r = to.r - 1
            end
        end
    end
    if from.g ~= to.g then
        if from.g < to.g then
            to.g = to.g - fade
            if from.g > to.g then
                to.g = to.g + 1
            end
        else
            to.g = to.g + fade
            if from.g > to.g then
                to.g = to.g - 1
            end
        end
    end
    if from.b ~= to.b then
        if from.b < to.b then
            to.b = to.b - fade
            if from.b > to.b then
                to.b = to.b + 1
            end
        else
            to.b = to.b + fade
            if from.b > to.b then
                to.b = to.b - 1
            end
        end
    end
    if from.a ~= to.a then
        if from.a < to.a then
            to.a = to.a - fade
            if from.a > to.a then
                to.a = to.a + 1
            end
        else
            to.a = to.a + fade
            if from.a > to.a then
                to.a = to.a - 1
            end
        end
    end
    return to
end

function DisableActions()
    if Config.DisableMouse then
        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
    end

    if Config.DisableMovement then
        DisableControlAction(0, 30, true) -- disable left/right
        DisableControlAction(0, 31, true) -- disable forward/back
        DisableControlAction(0, 36, true) -- INPUT_DUCK
        DisableControlAction(0, 21, true) -- disable sprint
    end

    if Config.DisableCarMovement then
        DisableControlAction(0, 63, true) -- veh turn left
        DisableControlAction(0, 64, true) -- veh turn right
        DisableControlAction(0, 71, true) -- veh forward
        DisableControlAction(0, 72, true) -- veh backwards
        DisableControlAction(0, 75, true) -- disable exit vehicle
    end

    if Config.DisableCombat then
        DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
        DisableControlAction(0, 24, true) -- disable attack
        DisableControlAction(0, 25, true) -- disable aim
        DisableControlAction(1, 37, true) -- disable weapon select
        DisableControlAction(0, 47, true) -- disable weapon
        DisableControlAction(0, 58, true) -- disable weapon
        DisableControlAction(0, 140, true) -- disable melee
        DisableControlAction(0, 141, true) -- disable melee
        DisableControlAction(0, 142, true) -- disable melee
        DisableControlAction(0, 143, true) -- disable melee
        DisableControlAction(0, 263, true) -- disable melee
        DisableControlAction(0, 264, true) -- disable melee
        DisableControlAction(0, 257, true) -- disable melee
    end
end
