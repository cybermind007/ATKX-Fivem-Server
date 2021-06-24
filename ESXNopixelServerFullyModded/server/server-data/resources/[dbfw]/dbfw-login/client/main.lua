DBFWCore             = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while  DBFWCore  == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) 
			DBFWCore  = obj 
		end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
  PlayerData.job = job
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if NetworkIsSessionStarted() then
			Citizen.Wait(500)
			TriggerServerEvent("dbfw-scoreboard:AddPlayer")
			TriggerServerEvent('dbfw-admin:AddPlayer')
			TriggerEvent("kashactersC:WelcomePage")
			TriggerEvent("kashactersC:SetupCharacters")
            return -- break the loop
        end
    end
end)


local IsChoosing = true
local cam = nil
local cam2 = nil
RegisterNetEvent('kashactersC:SetupCharacters')
AddEventHandler('kashactersC:SetupCharacters', function()
	TransitionToBlurred(500)
	local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    FreezeEntityPosition(GetPlayerPed(-1), true)
	SetCamRot(cam, 0.0, 0.0, -45.0, 2)
	SetCamCoord(cam, -682.0, -1092.0, 226.0)
	SetCamActive(cam, true)
	RenderScriptCams(true, false, 0, true, true)
end)
RegisterNetEvent('kashactersC:WelcomePage')
AddEventHandler('kashactersC:WelcomePage', function()
    SetNuiFocus(true, true)
	SendNUIMessage({
        action = "openwelcome"
    })
end)

RegisterNUICallback("disconnect", function(data, cb)
    TriggerServerEvent("dbfw-login:disconnectPlayer")
end)

RegisterNetEvent('kashactersC:SetupUI')
AddEventHandler('kashactersC:SetupUI', function(Characters)
	IsChoosing = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openui",
        characters = Characters,
    })
end)

RegisterNetEvent('kashactersC:Logout')
AddEventHandler('kashactersC:Logout', function(plyr)
	for i=1, #Config.Logouts, 1 do
		local player = GetPlayerPed(-1)
		local playerloc = GetEntityCoords(player, 0)
		local logoutspot = Config.Logouts[i]
		local logoutdistance = GetDistanceBetweenCoords(logoutspot['x'], logoutspot['y'], logoutspot['z'], playerloc['x'], playerloc['y'], playerloc['z'], true)

		if logoutdistance <= 3 then
			TriggerEvent('kashactersC:ReloadCharacters')
		else
			TriggerEvent("DoLongHudText", 'You cannot log out from here' ,2)
		end
	end
end)

RegisterNetEvent('kashactersC:SpawnCharacter')
AddEventHandler('kashactersC:SpawnCharacter', function(spawn, isnew)
	TriggerServerEvent('es:firstJoinProper')
	TriggerEvent('es:allowedToSpawn')
	Citizen.Wait(3700)
	if isnew then
		IsChoosing = false
		TriggerScreenblurFadeOut(0)
		TriggerEvent('dbfw-identity:showRegisterIdentity')
		SendNUIMessage({
        action = "displayback"
		})
		SetTimecycleModifier('default')
		cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -570.76,-1423.65,252.65, 0.00,0.00,10.00, 72.00, false, 0)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 1, true, true)
	else
		SetTimecycleModifier('default')
		local pos = spawn
		Citizen.Wait(900)
		exports.spawnmanager:setAutoSpawn(false)
		TriggerEvent('dbfw-ambulancejob:multicharacter', source)
		TriggerEvent("hotel:createRoom")
		TriggerEvent("DoLongHudText", "Tax is currently set to: 0%", 1)
		TriggerEvent('dbfw-clothing:get_character_current', source)
		TriggerEvent("dbfw-clothing:get_character_face", source)
		TriggerEvent("dbfw-clothing:get_character_current", source)
		TriggerEvent("hud:voice:transmitting", false)
		TriggerEvent('hud:voice:talking', false)
		TriggerScreenblurFadeOut(0)
	end
end)

RegisterNetEvent('kashactersC:ReloadCharacters')
AddEventHandler('kashactersC:ReloadCharacters', function()
    TriggerServerEvent("kashactersS:SetupCharacters")
    TriggerEvent("kashactersC:SetupCharacters")
end)

RegisterNUICallback("CharacterChosen", function(data, cb)
    SetNuiFocus(false,false)
    TriggerServerEvent('kashactersS:CharacterChosen', data.charid, data.ischar, data.spawnid or "1")
    cb("ok")
end)
RegisterNUICallback("DeleteCharacter", function(data, cb)
    SetNuiFocus(false,false)
    TriggerServerEvent('kashactersS:DeleteCharacter', data.charid)
    cb("ok")
end)
RegisterNUICallback("ShowSelection", function(data, cb)
	TriggerServerEvent("kashactersS:SetupCharacters")
end)

function DrawText3Ds(x,y,z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local p = GetGameplayCamCoords()
	local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov
	if onScreen then
		SetTextScale(0.30, 0.30)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
		local factor = (string.len(text)) / 370
		DrawRect(_x,_y+0.0120, factor, 0.026, 41, 11, 41, 68)
	end
end