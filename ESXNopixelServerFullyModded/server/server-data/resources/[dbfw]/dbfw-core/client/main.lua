
local isLoadoutLoaded, isPaused, isPlayerSpawned, isDead = false, false, false, false
local lastLoadout, pickups = {}, {}
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local paycheckReady = false

local stackTwice = false

local stackThree = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60 * 60000)
		if paycheckReady == true and stackTwice == false and stackThree == false then
			DBFWCore.TriggerServerCallback('paycheck:checkSalary', function(result)
				if result ~= nil or result ~= false then
					stackTwice = true
					TriggerEvent('DoLongHudText', 'Your payslip of $' .. result .. ' was saved. Your new payslip is now $' .. (result * 2) .. '.', 1)
				end
			end)
		elseif paycheckReady == true and stackTwice == true and stackThree == false then
			DBFWCore.TriggerServerCallback('paycheck:checkSalary', function(result)
				if result ~= nil or result ~= false then
					stackThree = true
					TriggerEvent('DoLongHudText', 'Your payslip of $' .. (result * 2) .. ' was saved. Your new payslip is now $' .. (result * 3) .. '.', 1)
				end
			end)
		elseif paycheckReady == true and stackTwice == true and stackThree == true then
			DBFWCore.TriggerServerCallback('paycheck:checkSalary', function(result)
				if result ~= nil or result ~= false then
					TriggerEvent('DoLongHudText', 'Your payslip of $' .. result .. ' was revoked. Your payslip of $' .. (result * 3) .. ' is still waiting for you.', 1)
				end
			end)
		else
			DBFWCore.TriggerServerCallback('paycheck:checkSalary', function(result)
				if result ~= nil or result ~= false then
					paycheckReady = true
					TriggerEvent('DoLongHudText', 'Your payslip of $' .. result .. ' is ready for pick-up at LifeInvader.', 1)
				end
			end)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local ply = PlayerPedId()
		local plyCoords = GetEntityCoords(ply, 0)
		local payDst = #(vector3(-1083.176, -248.0483, 37.76324) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
		if payDst < 1 then
			if paycheckReady == true or paycheckReady == false then
				drawTxt('Push ~b~E~s~ to pick up your paycheck!',0,1,0.5,0.8,0.35,255,255,255,255)
				DrawMarker(27,-1082.81, -248.19, 36.77, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.5001, 0, 155, 255, 200, 0, 0, 0, 0) 
			end
			if IsControlJustPressed(0, 38) then
				if paycheckReady == true and stackTwice == false and stackThree == false then
					TriggerServerEvent('paycheck:collectPay')
					Citizen.Wait(1500)
					paycheckReady = false
				elseif stackTwice == true and paycheckReady == true and stackThree == false then
					TriggerServerEvent('paycheck:collectPayStack')
					Citizen.Wait(1500)
					stackTwice = false
					paycheckReady = false
				elseif stackTwice == true and paycheckReady == true and stackThree == true then
					TriggerServerEvent('paycheck:collectPayStack3')
					Citizen.Wait(1500)
					stackTwice = false
					paycheckReady = false
					stackThree = false
				else
					TriggerEvent('DoLongHudText', 'You don\'t have a paycheck ready to be picked up!', 2)
				end
			end
		end
	end
end)


RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
	DBFWCore.PlayerLoaded = true
	DBFWCore.PlayerData = xPlayer

	if Config.EnableHud then
		TriggerEvent('es:setMoneyDisplay', 0.0)
		DBFWCore.UI.HUD.SetDisplay(0.0)
		for k,v in ipairs(xPlayer.accounts) do
			local accountTpl = '<div><img src="img/accounts/' .. v.name .. '.png"/>&nbsp;{{money}}</div>'

			DBFWCore.UI.HUD.RegisterElement('account_' .. v.name, k - 1, 0, accountTpl, {
				money = 0
			})

			DBFWCore.UI.HUD.UpdateElement('account_' .. v.name, {
				money = DBFWCore.Math.GroupDigits(v.money)
			})
		end

		local jobTpl = '<div>{{job_label}} - {{grade_label}}</div>'

		if xPlayer.job.grade_label == '' then
			jobTpl = '<div>{{job_label}}</div>'
		end

		DBFWCore.UI.HUD.RegisterElement('job', #xPlayer.accounts, 0, jobTpl, {
			job_label   = '',
			grade_label = ''
		})

		DBFWCore.UI.HUD.UpdateElement('job', {
			job_label   = xPlayer.job.label,
			grade_label = xPlayer.job.grade_label
		})
	else
		TriggerEvent('es:setMoneyDisplay', 0.0)
		DBFWCore.UI.HUD.SetDisplay(0.0)
	end
end)

AddEventHandler('playerSpawned', function()
	while not DBFWCore.PlayerLoaded do
		Citizen.Wait(1)
	end

	local playerPed = PlayerPedId()

	-- Restore position
	if DBFWCore.PlayerData.lastPosition then
		SetEntityCoords(playerPed, DBFWCore.PlayerData.lastPosition.x, DBFWCore.PlayerData.lastPosition.y, DBFWCore.PlayerData.lastPosition.z)
	end

	TriggerEvent('dbfw:restoreLoadout') -- restore loadout

	isLoadoutLoaded = true
	isPlayerSpawned = true
	isDead = false
end)

AddEventHandler('dbfw:onPlayerDeath', function()
	isDead = true
end)

AddEventHandler('skinchanger:loadDefaultModel', function()
	isLoadoutLoaded = false
end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not DBFWCore.PlayerLoaded do
		Citizen.Wait(1)
	end

	TriggerEvent('dbfw:restoreLoadout')
end)

RegisterNetEvent('dbfw:setAccountMoney')
AddEventHandler('dbfw:setAccountMoney', function(account)
	for k,v in ipairs(DBFWCore.PlayerData.accounts) do
		if v.name == account.name then
			DBFWCore.PlayerData.accounts[k] = account
			break
		end
	end

	if Config.EnableHud then
		DBFWCore.UI.HUD.UpdateElement('account_' .. account.name, {
			money = DBFWCore.Math.GroupDigits(account.money)
		})
	end
end)

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(money)
	DBFWCore.PlayerData.money = money
end)

RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
	DBFWCore.PlayerData.job = job
end)

-- Commands
RegisterNetEvent('dbfw:teleport')
AddEventHandler('dbfw:teleport', function(pos)
	pos.x = pos.x + 0.0
	pos.y = pos.y + 0.0
	pos.z = pos.z + 0.0

	RequestCollisionAtCoord(pos.x, pos.y, pos.z)

	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
		RequestCollisionAtCoord(pos.x, pos.y, pos.z)
		Citizen.Wait(1)
	end

	SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z)
end)

RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
	if Config.EnableHud then
		DBFWCore.UI.HUD.UpdateElement('job', {
			job_label   = job.label,
			grade_label = job.grade_label
		})
	end
end)

RegisterNetEvent('dbfw:loadIPL')
AddEventHandler('dbfw:loadIPL', function(name)
	Citizen.CreateThread(function()
		LoadMpDlcMaps()
		RequestIpl(name)
	end)
end)

RegisterNetEvent('dbfw:unloadIPL')
AddEventHandler('dbfw:unloadIPL', function(name)
	Citizen.CreateThread(function()
		RemoveIpl(name)
	end)
end)

RegisterNetEvent('dbfw:playAnim')
AddEventHandler('dbfw:playAnim', function(dict, anim)
	Citizen.CreateThread(function()
		local playerPed = PlayerPedId()
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end

		TaskPlayAnim(playerPed, dict, anim, 1.0, -1.0, 20000, 0, 1, true, true, true)
	end)
end)

RegisterNetEvent('dbfw:playEmote')
AddEventHandler('dbfw:playEmote', function(emote)
	Citizen.CreateThread(function()

		local playerPed = PlayerPedId()

		TaskStartScenarioInPlace(playerPed, emote, 0, false);
		Citizen.Wait(20000)
		ClearPedTasks(playerPed)

	end)
end)

RegisterNetEvent('dbfw:spawnVehicle')
AddEventHandler('dbfw:spawnVehicle', function(model)
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	DBFWCore.Game.SpawnVehicle(model, coords, 90.0, function(vehicle)
		local plate = GetVehicleNumberPlateText(vehicle)
		TriggerServerEvent('garage:addKeys', plate)
		TriggerEvent('DoLongHudText', 'You took your keys', 1)
		TaskWarpPedIntoVehicle(playerPed,  vehicle, -1)
	end)
end)

RegisterNetEvent('dbfw:spawnObject')
AddEventHandler('dbfw:spawnObject', function(model)
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local forward   = GetEntityForwardVector(playerPed)
	local x, y, z   = table.unpack(coords + forward * 1.0)

	DBFWCore.Game.SpawnObject(model, {
		x = x,
		y = y,
		z = z
	}, function(obj)
		SetEntityHeading(obj, GetEntityHeading(playerPed))
		PlaceObjectOnGroundProperly(obj)
	end)
end)

RegisterNetEvent('dbfw:pickup')
AddEventHandler('dbfw:pickup', function(id, label, player)
	local ped     = GetPlayerPed(GetPlayerFromServerId(player))
	local coords  = GetEntityCoords(ped)
	local forward = GetEntityForwardVector(ped)
	local x, y, z = table.unpack(coords)
	pickups[id] = {
		id = id,
		label = label,
		inRange = false,
		coords = {
			x = x,
			y = y,
			z = z
		}
	}
	--[[DBFWCore.Game.SpawnLocalObject('prop_money_bag_01', {
		x = x,
		y = y,
		z = z - 2.0,
	}, function(obj)
		SetEntityAsMissionEntity(obj, true, false)
		PlaceObjectOnGroundProperly(obj)

		pickups[id] = {
			id = id,
			obj = obj,
			label = label,
			inRange = false,
			coords = {
				x = x,
				y = y,
				z = z
			}
		}
	end)]]--
end)

RegisterNetEvent('dbfw:removePickup')
AddEventHandler('dbfw:removePickup', function(id)
	DBFWCore.Game.DeleteObject(pickups[id].obj)
	pickups[id] = nil
end)

RegisterNetEvent('dbfw:spawnPed')
AddEventHandler('dbfw:spawnPed', function(model)
	model           = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)
	local forward   = GetEntityForwardVector(playerPed)
	local x, y, z   = table.unpack(coords + forward * 1.0)

	Citizen.CreateThread(function()
		RequestModel(model)

		while not HasModelLoaded(model) do
			Citizen.Wait(1)
		end

		CreatePed(5, model, x, y, z, 0.0, true, false)
	end)
end)

RegisterNetEvent('dbfw:deleteVehicle')
AddEventHandler('dbfw:deleteVehicle', function()
	local playerPed = PlayerPedId()
	local vehicle   = DBFWCore.Game.GetVehicleInDirection()

	if IsPedInAnyVehicle(playerPed, true) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	end

	if DoesEntityExist(vehicle) then
		DBFWCore.Game.DeleteVehicle(vehicle)
	end
end)

-- Pause menu disable HUD display
if Config.EnableHud then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(300)

			if IsPauseMenuActive() and not isPaused then
				isPaused = true
				TriggerEvent('es:setMoneyDisplay', 0.0)
				DBFWCore.UI.HUD.SetDisplay(0.0)
			elseif not IsPauseMenuActive() and isPaused then
				isPaused = false
				TriggerEvent('es:setMoneyDisplay', 1.0)
				DBFWCore.UI.HUD.SetDisplay(1.0)
			end
		end
	end)
end
-- Menu interactions


-- Disable wanted level
if Config.DisableWantedLevel then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)

			local playerId = PlayerId()
			if GetPlayerWantedLevel(playerId) ~= 0 then
				SetPlayerWantedLevel(playerId, 0, false)
				SetPlayerWantedLevelNow(playerId, false)
			end
		end
	end)
end

-- Pickups
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		
		-- if there's no nearby pickups we can wait a bit to save performance
		if next(pickups) == nil then
			Citizen.Wait(500)
		end

		for k,v in pairs(pickups) do
			local distance = GetDistanceBetweenCoords(coords, v.coords.x, v.coords.y, v.coords.z, true)
			local closestPlayer, closestDistance = DBFWCore.Game.GetClosestPlayer()

			if distance <= 3.5 then
				DBFWCore.Game.Utils.DrawText3D({
					x = v.coords.x,
					y = v.coords.y,
					z = v.coords.z + 0.1
				}, v.label)
				DrawMarker(20, v.coords.x, v.coords.y, v.coords.z - 0.25, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.6, 0.2, 0.5, 255, 255, 255, 255, false, true, 2, false, false, false, false)
			end
			

			if distance <= 1.0 and not v.inRange and IsPedOnFoot(playerPed) and IsControlJustReleased(0, Keys["E"]) then
				local dict = "pickup_object"		
        		RequestAnimDict(dict)
        		while not HasAnimDictLoaded(dict) do
            		Citizen.Wait(0)
        		end
        		TaskPlayAnim(GetPlayerPed(-1), dict, "pickup_low", 8.0, 8.0, -1, 0, 1, false, false, false)
				TriggerServerEvent('dbfw:onPickup', v.id)
				
				v.inRange = true
			end
		end
	end
end)

-- Last position
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local playerPed = PlayerPedId()

		if DBFWCore.PlayerLoaded and isPlayerSpawned then
			local coords = GetEntityCoords(playerPed)

			if not IsEntityDead(playerPed) then
				DBFWCore.PlayerData.lastPosition = {x = coords.x, y = coords.y, z = coords.z}
			end
		end

		if IsEntityDead(playerPed) and isPlayerSpawned then
			isPlayerSpawned = false
		end
	end
end)


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
  