DBFWCore          = nil
local IsDead = false
local IsAnimated = false
local IsAlreadyDrunk = false
local DrunkLevel     = -1

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('dbfw_basicneeds:resetStatus', function()
	TriggerEvent('dbfw_status:set', 'hunger', 1000000)
	TriggerEvent('dbfw_status:set', 'thirst', 1000000)
	TriggerEvent('dbfw_status:set', 'stress', 100000)
end)

RegisterNetEvent('dbfw_basicneeds:healPlayer')
AddEventHandler('dbfw_basicneeds:healPlayer', function()
	-- restore hunger & thirst
	TriggerEvent('dbfw_status:set', 'hunger', 1000000)
	TriggerEvent('dbfw_status:set', 'thirst', 1000000)
	TriggerEvent('dbfw_status:set', 'stress', 200000)


	-- restore hp
	local playerPed = PlayerPedId()
	SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
end)

AddEventHandler('dbfw:onPlayerDeath', function()
	IsDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	if IsDead then
		TriggerEvent('dbfw_basicneeds:resetStatus')
	end

	IsDead = false
end)

AddEventHandler('dbfw_status:loaded', function(status)

	TriggerEvent('dbfw_status:registerStatus', 'hunger', 1000000, '#CFAD0F', function(status)
		return true
	end, function(status)
		status.remove(100)
	end)

	TriggerEvent('dbfw_status:registerStatus', 'thirst', 1000000, '#0C98F1', function(status)
		return true
	end, function(status)
		status.remove(75)
	end)

	TriggerEvent('dbfw_status:registerStatus', 'stress', 100000, '#cadfff', function(status)
		return false
	end, function(status)
		status.add(20)
	end)
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000)

			local playerPed  = PlayerPedId()
			local prevHealth = GetEntityHealth(playerPed)
			local health     = prevHealth
			local stressVal  = 0

			TriggerEvent('dbfw_status:getStatus', 'hunger', function(status)
				if status.val == 0 then
					if prevHealth <= 150 then
						health = health - 5
					else
						health = health - 1
					end
				end
			end)

			TriggerEvent('dbfw_status:getStatus', 'thirst', function(status)
				if status.val == 0 then
					if prevHealth <= 150 then
						health = health - 5
					else
						health = health - 1
					end
				end
			end)

			TriggerEvent('dbfw_status:getStatus', 'stress', function(status)
				stressVal = status.val
			end)

			if health ~= prevHealth then
				SetEntityHealth(playerPed, health)
			end

			if stressVal >= 750000 then
				Citizen.Wait(3000)
				---ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.16)
			elseif stressVal >= 700000 then
				Citizen.Wait(4000)
				--ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.12)
			elseif stressVal >= 600000 then
				Citizen.Wait(5000)
				--ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.07)
			elseif stressVal >= 350000 then
				Citizen.Wait(6000)
				--ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.03)
			end
		end
	end)
end)

AddEventHandler('dbfw_basicneeds:isEating', function(cb)
	cb(IsAnimated)
end)

RegisterNetEvent('dbfw_basicneeds:onEatIceCream')
AddEventHandler('dbfw_basicneeds:onEatIceCream', function(prop_name)
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(6000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatPancakes')
AddEventHandler('dbfw_basicneeds:onEatPancakes', function(prop_name)
	if not IsAnimated then
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(8500, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEat')
AddEventHandler('dbfw_basicneeds:onEat', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_cs_burger_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.11, 0.045, 0.02, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(3000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatHotdog')
AddEventHandler('dbfw_basicneeds:onEatHotdog', function()
	if not IsAnimated then
		prop_name = 'prop_cs_hotdog_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 18905), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(6000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatChocolate')
AddEventHandler('dbfw_basicneeds:onEatChocolate', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_choc_ego'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.035, 0.009, -30.0, -240.0, -120.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(3000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatCandy')
AddEventHandler('dbfw_basicneeds:onEatCandy', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_candy_pqs'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.035, 0.009, -30.0, -240.0, -120.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(3000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatChips')
AddEventHandler('dbfw_basicneeds:onEatChips', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'v_ret_ml_chips4'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.035, 0.009, -30.0, -240.0, -120.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(3000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatCupCake')
AddEventHandler('dbfw_basicneeds:onEatCupCake', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'ng_proc_food_ornge1a'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.045, 0.06, 45.0, 175.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
				exports["taskbar"]:taskBar(6000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatNoProp')
AddEventHandler('dbfw_basicneeds:onEatNoProp', function(time)
	if not IsAnimated then
		IsAnimated = true
		time = time or 3000
		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(time, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onEatSandwich')
AddEventHandler('dbfw_basicneeds:onEatSandwich', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_sandwich_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.03, -240.0, -180.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(3000, "Eating")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkNoProp')
AddEventHandler('dbfw_basicneeds:onDrinkNoProp', function(time)
	if not IsAnimated then
		IsAnimated = true
		time = time or 5000
		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))


			DBFWCore.Streaming.RequestAnimDict("mp_player_inteat@pnq", function()
				TaskPlayAnim(playerPed, "mp_player_inteat@pnq", "loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(time, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrink')
AddEventHandler('dbfw_basicneeds:onDrink', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_ld_flow_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict("mp_player_inteat@pnq", function()
				TaskPlayAnim(playerPed, "mp_player_inteat@pnq", "loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)


RegisterNetEvent('dbfw_basicneeds:onDrinkOrange')
AddEventHandler('dbfw_basicneeds:onDrinkOrange', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_orang_can_01' --ng_proc_sodacan_01a
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_intdrink', function()
				TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkCocaCola')
AddEventHandler('dbfw_basicneeds:onDrinkCocaCola', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_ecola_can' --ng_proc_sodacan_01a
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_intdrink', function()
				TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)


RegisterNetEvent('dbfw_basicneeds:onDrinkIceTea')
AddEventHandler('dbfw_basicneeds:onDrinkIceTea', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_ld_can_01' --ng_proc_sodacan_01b
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_intdrink', function()
				TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkTaco')
AddEventHandler('dbfw_basicneeds:onDrinkTaco', function()
	local prop_name = 'prop_taco_01'
	local playerPed = GetPlayerPed(-1)
	Citizen.CreateThread(function()
		local playerPed = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(playerPed))
		local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
		local boneIndex = GetPedBoneIndex(playerPed, 18905)
		AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

		DBFWCore.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
			TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)

			exports['taskbar']:taskBar(4500, "Eating")
			IsAnimated = false
			ClearPedSecondaryTask(playerPed)
			DeleteObject(prop)
		end)
	end)
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkCoffe')
AddEventHandler('dbfw_basicneeds:onDrinkCoffe', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_fib_coffee'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.01, -0.03, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_intdrink', function()
				TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

-- Bar drinks
RegisterNetEvent('dbfw_basicneeds:onDrinkBeer')
AddEventHandler('dbfw_basicneeds:onDrinkBeer', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_amb_beer_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'amb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkWine')
AddEventHandler('dbfw_basicneeds:onDrinkWine', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_wine_bot_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.02, -0.3, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'amb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkVodka')
AddEventHandler('dbfw_basicneeds:onDrinkVodka', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_vodka_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.02, -0.3, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'amb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkWhisky')
AddEventHandler('dbfw_basicneeds:onDrinkWhisky', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_cs_whiskey_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.02, -0.2, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'amb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)

				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkTequila')
AddEventHandler('dbfw_basicneeds:onDrinkTequila', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_tequila_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.02, -0.3, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'amb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkMilk')
AddEventHandler('dbfw_basicneeds:onDrinkMilk', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_cs_milk_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, -0.009, -0.03, -0.1, -90.0, 270.0, -90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('mp_player_intdrink', function()
				TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)

				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

-- Disco
RegisterNetEvent('dbfw_basicneeds:onDrinkGin')
AddEventHandler('dbfw_basicneeds:onDrinkGin', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_rum_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.02, -0.3, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'amb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkAbsinthe')
AddEventHandler('dbfw_basicneeds:onDrinkAbsinthe', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_bottle_cognac'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.02, -0.3, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'mamb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)

				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('dbfw_basicneeds:onDrinkChampagne')
AddEventHandler('dbfw_basicneeds:onDrinkChampagne', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_wine_white'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 28422)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.008, -0.02, -0.3, 90.0, 270.0, 90.0, true, true, false, true, 1, true)

			DBFWCore.Streaming.RequestAnimDict('amb@code_human_wander_drinking@beer@male@base', function()
				TaskPlayAnim(playerPed, 'amb@code_human_wander_drinking@beer@male@base', 'static', 1.0, -1.0, 2000, 0, 1, true, true, true)
                exports["taskbar"]:taskBar(3000, "Drinking")
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

-- Cigarett 
RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('dbfw_cigarett:startSmoke')
AddEventHandler('dbfw_cigarett:startSmoke', function(source)
	SmokeAnimation()
end)

function SmokeAnimation()
	local playerPed = GetPlayerPed(-1)
	
	Citizen.CreateThread(function()
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING", 0, true)               
	end)
end

-- Optionalneeds
function Drunk(level, start)
  
  Citizen.CreateThread(function()
     local playerPed = GetPlayerPed(-1)
     if start then
      DoScreenFadeOut(800)
      Wait(1000)
    end
     if level == 0 then
       RequestAnimSet("move_m@drunk@slightlydrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@slightlydrunk") do
        Citizen.Wait(0)
      end
       SetPedMovementClipset(playerPed, "move_m@drunk@slightlydrunk", true)
     elseif level == 1 then
       RequestAnimSet("move_m@drunk@moderatedrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
        Citizen.Wait(0)
      end
       SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)
     elseif level == 2 then
       RequestAnimSet("move_m@drunk@verydrunk")
      
      while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Citizen.Wait(0)
      end
       SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)
     end
     SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    SetPedIsDrunk(playerPed, true)
     if start then
      DoScreenFadeIn(800)
    end
   end)
 end
 function Reality()
   Citizen.CreateThread(function()
     local playerPed = GetPlayerPed(-1)
     DoScreenFadeOut(800)
    Wait(1000)
     ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(playerPed, 0)
    SetPedIsDrunk(playerPed, false)
    SetPedMotionBlur(playerPed, false)
     DoScreenFadeIn(800)
   end)
 end
 AddEventHandler('dbfw_status:loaded', function(status)
   TriggerEvent('dbfw_status:registerStatus', 'drunk', 0, '#8F15A5', --roxo
    function(status)
      if status.val > 0 then
        return true
      else
        return false
      end
    end,
    function(status)
      status.remove(1500)
    end
  )
 	Citizen.CreateThread(function()
 		while true do
 			Wait(1000)
 			TriggerEvent('dbfw_status:getStatus', 'drunk', function(status)
				
				if status.val > 0 then
					
          local start = true
           if IsAlreadyDrunk then
            start = false
          end
           local level = 0
           if status.val <= 250000 then
            level = 0
          elseif status.val <= 500000 then
            level = 1
          else
            level = 2
          end
           if level ~= DrunkLevel then
            Drunk(level, start)
          end
           IsAlreadyDrunk = true
          DrunkLevel     = level
				end
 				if status.val == 0 then
          
          if IsAlreadyDrunk then
            Reality()
          end
           IsAlreadyDrunk = false
          DrunkLevel     = -1
 				end
 			end)
 		end
 	end)
 end)
 RegisterNetEvent('dbfw_optionalneeds:onDrink')
AddEventHandler('dbfw_optionalneeds:onDrink', function()
  
  local playerPed = GetPlayerPed(-1)
  
  TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_DRINKING", 0, 1)
  Citizen.Wait(1000)
  ClearPedTasksImmediately(playerPed)
 end) 
