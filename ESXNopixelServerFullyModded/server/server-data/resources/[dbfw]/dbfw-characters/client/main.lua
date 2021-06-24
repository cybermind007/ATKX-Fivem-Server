DBFWCore              = nil

local PlayerData = {}

Citizen.CreateThread(function()
    while DBFWCore == nil do
        Citizen.Wait(200)
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
	end
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

RegisterNetEvent('dbfw-login:swapcharacter')
AddEventHandler('dbfw-login:swapcharacter', function()
	TriggerEvent("kashactersC:WelcomePage")
	TriggerEvent("kashactersC:ReloadCharacters")
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

RegisterCommand("AdminTestOkay", function()
	TriggerEvent("hotel:createRoom")
end)

local function disconnect()
    TriggerServerEvent("dbfw-login:disconnectPlayer")
end

RegisterNetEvent('kashactersC:SetupUI')
AddEventHandler('kashactersC:SetupUI', function(Characters)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openui",
        characters = Characters,
    })
end)


local function nuiCallBack()
	SetNuiFocus(true, true)
	SendNUIMessage({
        disconnect = disconnect()
	})
end

RegisterNUICallback("DisconnectGame", nuiCallBack)


RegisterNetEvent('kashactersC:SpawnCharacter')
AddEventHandler('kashactersC:SpawnCharacter', function(spawn, isnew)
	TriggerServerEvent('es:firstJoinProper')
	TriggerEvent('es:allowedToSpawn')
	local pos = spawn
	Citizen.Wait(0)
	if isnew then
		IsChoosing = false
		SetEntityCoords(GetPlayerPed(-1), pos.x, pos.y, pos.z)
		TriggerEvent('dbfw-identity:showRegisterIdentity')
		TriggerEvent("hud:voice:transmitting", false)
		TriggerEvent('hud:voice:talking', false)
		SendNUIMessage({
        action = "displayback"
		})
		SetTimecycleModifier('default')
		FreezeEntityPosition(GetPlayerPed(-1), true)
		local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
		SetCamRot(cam, 0.0, 0.0, -45.0, 2)
		SetCamCoord(cam, -682.0, -1092.0, 226.0)
		FreezeEntityPosition(GetPlayerPed(-1), false)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 1, true, true)
		TriggerEvent("hud:voice:transmitting", false)
		TriggerEvent('hud:voice:talking', false)
		TriggerScreenblurFadeOut(0)
	else
		SetTimecycleModifier('default')
		local pos = spawn
		exports.spawnmanager:setAutoSpawn(false)
		IsChoosing = false
		Citizen.Wait(5)
        TriggerEvent('spawnselector:openspawner')
		TriggerEvent("DoLongHudText", "Tax is currently set to: 0%", 1)
		TriggerEvent('dbfw-clothing:get_character_current', source)
		TriggerEvent("dbfw-clothing:get_character_face", source)
		TriggerEvent("dbfw-clothing:get_character_current", source)
		TriggerEvent("hud:voice:transmitting", false)
		TriggerEvent('hud:voice:talking', false)
		TriggerScreenblurFadeOut(0)
	end
end)

RegisterNetEvent('kashactersC:ChoseCharacter')
AddEventHandler('kashactersC:ChoseCharacter', function(spawn)
	local pos = spawn
	SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z)
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
    TriggerServerEvent('kashactersS:Register', data.charid)
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