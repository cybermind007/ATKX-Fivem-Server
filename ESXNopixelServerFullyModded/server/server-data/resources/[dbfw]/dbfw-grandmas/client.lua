DBFWCore = nil

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
end)

function Draw3DText(x,y,z, text)
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

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

local hospitalCheckin = { x = 2433.91, y = 4965.50, z = 42.00, h = 43.69 }

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
    local plyCoords = GetEntityCoords(PlayerPedId(), 0)
    local pos = GetEntityCoords(GetPlayerPed(-1))
        local distance = #(vector3(hospitalCheckin.x, hospitalCheckin.y, hospitalCheckin.z) - plyCoords)
        if distance < 10 then
            if not IsPedInAnyVehicle(PlayerPedId(), true) then
                if distance < 3 then
                    --PrintHelpText('Press ~INPUT_CONTEXT~ ~s~to check in')
			        Draw3DText(hospitalCheckin.x, hospitalCheckin.y, hospitalCheckin.z + 0.5, '[E] - Check in for $1,000')
                    if IsControlJustReleased(0, 54) then
                        if (GetEntityHealth(PlayerPedId()) <= 200) then
                            loadAnimDict('missheistdockssetup1clipboard@base')
                            TaskPlayAnim( PlayerPedId(), "missheistdockssetup1clipboard@base", "base", 3.0, 1.0, -1, 49, 0, 0, 0, 0 ) 
                            exports["dbfw-taskbar"]:taskBar(10500, "Checking In")
                                exports["dbfw-taskbar"]:taskBar(60000, "Treating, Do not move")
                                    TriggerEvent('dbfw-ambulancejob:revive')
                                    TriggerServerEvent('mythic_hospital:server:HealSomeShit')
                                    ClearPedTasks(PlayerPedId())
                                else
                            TriggerEvent('DoLongHudText', 'You do not need medical attention', 2)
                        end
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)