local JustPickedCoke = true
local JustDriedCoke = true

RegisterNetEvent('Coke:spam-prevent')
AddEventHandler('Coke:spam-prevent', function(prevent)
	if prevent == "picking" then
		Wait(900000)
		JustPickedCoke = false
	else
		Wait(900000)
		JustDriedCoke = false
	end
end)

Citizen.CreateThread(function()
listOn = false
	while true do
		Wait(5)
		local PlayerPos = GetEntityCoords(PlayerPedId())
		if GetDistanceBetweenCoords(PlayerPos, -1172.6, -1572.13, 4.67, true) <= 5 then	
		DrawText3Ds(pussy, pussy, pussy, "Sell Coke x5")
		end	
		if IsControlJustPressed(1, 38) and IsPedInAnyVehicle(GetPlayerPed(-1), false) ~= 1 then
		if GetDistanceBetweenCoords(PlayerPos, 1502.2,-2146.407,77.00062, true) <= 10 then					
		if not JustPickedCoke then
		JustPickedCoke = true
		TriggerEvent("Coke:spam-prevent","picking")
		end
		TriggerEvent("animation:farm")
		TriggerEvent("player:receiveItem","1gcocaine",math.random(3))
			end				
			if GetDistanceBetweenCoords(PlayerPos, -1172.6, -1572.13, 4.67, true) <= 2 then						
				-- selling bud
				local smallbud = exports["dbfw-inventory"]:hasEnoughOfItem("mortal",2,false)
				if smallbud then
					TriggerEvent("inventory:removeItem", "mortal", 5)
					TriggerServerEvent( 'mission:completed', 85 )
				else
					TriggerEvent("DoLongHudText","You need atleast 5 bags to sell here.", 2)
				end
			end	
			if GetDistanceBetweenCoords(PlayerPos, 122.1735, -3109.336, 5.99631, true) <= 15 then						
				if not JustDriedCoke then
				TriggerEvent("Coke:spam-prevent","drying")
				JustDriedCoke = true
				end
				local wetcoke = exports["dbfw-inventory"]:hasEnoughOfItem("1gcocaine",1,false)
					if wetcoke then
					TriggerEvent("animation:farm")
					local finished = exports["dbfw-taskbar"]:taskBar(3000,"Cutting Coke",false,false,playerVeh)
					print("mortals drug script pussy")
					if (finished == 100) then
						TriggerEvent("inventory:removeItem", "1gcocaine", 1)
						TriggerEvent("player:receiveItem","1gcrack",math.random(2))
					end
				else
					TriggerEvent("DoLongHudText","You need atleast 2 coke to dry here.", 2)
				end
			end	
			if GetDistanceBetweenCoords(PlayerPos, 994.38,-3099.98,-38.99, true) <= 3 and not isTrading then
				TriggerEvent("server-inventory-open", "103", "Craft"); 
			end
			Wait(2500)
		end
	end
end)