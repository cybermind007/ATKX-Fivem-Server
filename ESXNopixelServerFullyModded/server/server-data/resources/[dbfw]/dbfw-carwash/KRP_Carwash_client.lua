Key = 38 -- E

vehicleWashStation = {
	{26.5906,  -1392.0261,  27.3634},
	{167.1034,  -1719.4704,  27.2916},
	{-74.5693,  6427.8715,  29.4400},
	{-699.6325,  -932.7043,  17.0139},
	{1362.5385, 3592.1274, 33.9211}
}

Citizen.CreateThread(function ()
	Citizen.Wait(0)
	for i = 1, #vehicleWashStation do
		garageCoords = vehicleWashStation[i]
		stationBlip = AddBlipForCoord(garageCoords[1], garageCoords[2], garageCoords[3])
		SetBlipSprite(stationBlip, 100)
		SetBlipAsShortRange(stationBlip, true)
	end
    return
end)

local timer2 = false
local mycie = false

function dbfw_Carwash_DrawSubtitleTimed(m_text, showtime)
	SetTextEntry_2('STRING')
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function dbfw_Carwash_DrawNotification(m_text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(m_text)
	DrawNotification(true, false)
end

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		if IsPedSittingInAnyVehicle(PlayerPedId()) then 
			for i = 1, #vehicleWashStation do
				garageCoords2 = vehicleWashStation[i]
				DrawMarker(27, garageCoords2[1], garageCoords2[2], garageCoords2[3], 0, 0, 0, 0, 0, 0, 5.0, 5.0, 2.0, 0, 157, 0, 155, 0, 0, 2, 0, 0, 0, 0)
				if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), garageCoords2[1], garageCoords2[2], garageCoords2[3], true ) < 5 then
					if mycie == false then
					HelpPromt('Press ~INPUT_CONTEXT~ To ~b~Clean ~s~Your Vehicle For ~g~$250')
					if IsControlJustPressed(1, Key) then
						TriggerServerEvent('dbfw_Carwash:checkmoney')
					end
				else
					HelpPromt('Press ~INPUT_CONTEXT~ To ~o~Stop')
					if IsControlJustPressed(1, Key) then
						mycie = false
						timer2 = false
						StopParticleFxLooped(particles, 0)
						StopParticleFxLooped(particles2, 0)
						FreezeEntityPosition(GetVehiclePedIsUsing(PlayerPedId()), false)
					end
				end
				end
			end
		end
	end
end)

RegisterNetEvent('dbfw_Carwash:success')
AddEventHandler('dbfw_Carwash:success', function (price)
	local car = GetVehiclePedIsUsing(PlayerPedId())
	local coords = GetEntityCoords(PlayerPedId())
	mycie = true
	FreezeEntityPosition(car, true)
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Wait(1)
		end
	end
	UseParticleFxAssetNextCall("core")
	particles  = StartParticleFxLoopedAtCoord("ent_amb_waterfall_splash_p", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
	UseParticleFxAssetNextCall("core")
	particles2  = StartParticleFxLoopedAtCoord("ent_amb_waterfall_splash_p", coords.x + 2, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
	timer = 15
	timer2 = true
    Citizen.CreateThread(function()
		while timer2 do
            Citizen.Wait(0)
            Citizen.Wait(1000)
            if(timer > 0)then
				timer = timer - 1
			elseif (timer == 0) then
				mycie = false
				WashDecalsFromVehicle(car, 1.0)
				SetVehicleDirtLevel(car)
				FreezeEntityPosition(car, false)
               TriggerEvent("DoLongHudText", "You Paid $250 To Get Your Vehicle Cleaned", 1)
				StopParticleFxLooped(particles, 0)
				StopParticleFxLooped(particles2, 0)
				timer2 = false
			end
        end
    end)
	Citizen.CreateThread(function()
        while true do
			Citizen.Wait(0)
			if mycie == true then
				for i = 1, #vehicleWashStation do
				garageCoords3 = vehicleWashStation[i]
				if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), garageCoords3[1], garageCoords3[2], garageCoords3[3], true ) < 4 then
					DrawText3D(garageCoords3[1], garageCoords3[2], garageCoords3[3] + 3, '~b~Cleaning Vehicle... ~s~Time:~b~ '.. timer ..' ~s~Seconds.')
				end
				end
			end
		end
	end)
end)

RegisterNetEvent('dbfw_Carwash:notenoughmoney')
AddEventHandler('dbfw_Carwash:notenoughmoney', function (moneyleft)
	TriggerEvent("DoLongHudText", "You Dont Have Enough Money", 2)
	
end)

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

function HelpPromt(text)
	Citizen.CreateThread(function()
		SetTextComponentFormat("STRING")
		AddTextComponentString(text)
		DisplayHelpTextFromStringLabel(0, state, 0, -1)
   end)
end