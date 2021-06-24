Currentstates = {
	[1] = { ["text"] = "Red Hands", ["status"] = false, ["timer"] = 0 },
	[2] = { ["text"] = "Dialated Eyes", ["status"] = false, ["timer"] = 0 },
	[3] = { ["text"] = "Red Eyes", ["status"] = false, ["timer"] = 0 },
	[4] = { ["text"] = "Smells Like Marijuana", ["status"] = false, ["timer"] = 0 },
	[5] = { ["text"] = "Fresh Bandaging", ["status"] = false, ["timer"] = 0 },
	[6] = { ["text"] = "Agitated", ["status"] = false, ["timer"] = 0 },
	[7] = { ["text"] = "Uncoordinated", ["status"] = false, ["timer"] = 0 },
	[8] = { ["text"] = "Breath smells like Alcohol", ["status"] = false, ["timer"] = 0 },
	[9] = { ["text"] = "Smells like Gasoline", ["status"] = false, ["timer"] = 0 },
	[10] = { ["text"] = "Red Gunpowder Residue", ["status"] = false, ["timer"] = 0 },
	[11] = { ["text"] = "Smells of Chemicals", ["status"] = false, ["timer"] = 0 },
	[12] = { ["text"] = "Smells of Oil / Metalwork", ["status"] = false, ["timer"] = 0 },
	[13] = { ["text"] = "Ink Stained Hands", ["status"] = false, ["timer"] = 0 },
	[14] = { ["text"] = "Smells like smoke", ["status"] = false, ["timer"] = 0 },
	[15] = { ["text"] = "Has camping equipment", ["status"] = false, ["timer"] = 0 },
	[16] = { ["text"] = "Smells like burnt Aluminum and iron", ["status"] = false, ["timer"] = 0 },
	[17] = { ["text"] = "Has metal specs on clothing", ["status"] = false, ["timer"] = 0 },
	[18] = { ["text"] = "Smells Like Cigarette Smoke", ["status"] = false, ["timer"] = 0 },
	[19] = { ["text"] = "Labored Breathing", ["status"] = false, ["timer"] = 0 },
	[20] = { ["text"] = "Body Sweat", ["status"] = false, ["timer"] = 0 },
	[21] = { ["text"] = "Clothing Sweat", ["status"] = false, ["timer"] = 0 },	
    [22] = { ["text"] = "Wire Cuts", ["status"] = false, ["timer"] = 0 },
	[23] = { ["text"] = "Saturated Clothing", ["status"] = false, ["timer"] = 0 },		
    [24] = { ["text"] = "Looks Dazed", ["status"] = false, ["timer"] = 0 },
    [25] = { ["text"] = "Looks Well Fed", ["status"] = false, ["timer"] = 0 },
    [26] = { ["text"] = "Has scratches on hands.", ["status"] = false, ["timer"] = 0 }, 
    [27] = { ["text"] = "Looks Alert", ["status"] = false, ["timer"] = 0 }, 
}



RegisterNetEvent("dbfw-state:stateSet")
AddEventHandler("dbfw-state:stateSet",function(stateId,stateLength)
	if Currentstates[stateId]["timer"] < 10 and stateLength ~= 0 then
		TriggerEvent('chatMessagess', 'STATUS: ', 1, Currentstates[stateId]["text"])
	end
	Currentstates[stateId]["timer"] = stateLength
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
					TriggerEvent("dbfw-state:stateSet",1,300)
        			lastTarget = target
        		end
        	else
				if IsPedAPlayer(target) then
					TriggerEvent("dbfw-state:stateSet",1,300)
	        		targetLastHealth = GetEntityHealth(target)
	        		lastTarget = target
	        	end
        	end
        end

        if IsPedSwimming(PlayerPedId()) then
        	local speed = GetEntitySpeed(PlayerPedId())
        	if speed > 0 then
        		sweatTriggered = true
        		TriggerEvent("dbfw-state:stateSet",20,0)
        		TriggerEvent("dbfw-state:stateSet",21,0)
        		TriggerEvent("dbfw-state:stateSet",23,600)
        		if bodySweat < 180000 then
        			bodySweat = bodySweat + (150 + math.ceil(speed * 40))
        		else
        			bodySweat = bodySweat + (150 + math.ceil(speed * 11))
        		end
        		

        		if bodySweat > 210000 then
        			TriggerEvent("dbfw-state:stateSet",19,600)
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
			TriggerEvent("dbfw-state:stateSet",19,300)
        end  

        if bodySweat > 300000 and not IsPedSwimming(PlayerPedId()) and Currentstates[22]["timer"] < 50 then
			TriggerEvent("dbfw-state:stateSet",20,450)
        end 
        if bodySweat > 800000 and not IsPedSwimming(PlayerPedId()) and Currentstates[22]["timer"] < 50 then
        	sweatTriggered = true
			TriggerEvent("dbfw-state:stateSet",21,600)
        end

    end
end)