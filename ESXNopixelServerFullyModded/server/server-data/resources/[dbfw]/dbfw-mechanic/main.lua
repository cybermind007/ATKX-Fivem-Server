DBFWCore = nil

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent("dbfw:getSharedObject", function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("dbfw:playerLoaded")
AddEventHandler("dbfw:playerLoaded", function(xPlayer)
	DBFWCore.PlayerData = xPlayer
end)

RegisterNetEvent("dbfw:setJob")
AddEventHandler("dbfw:setJob", function(job)
	DBFWCore.PlayerData.job = job
end)


local degHealth = {
	["breaks"] = 0,-- has neg effect
	["axle"] = 0,	-- has neg effect
	["radiator"] = 0, -- has neg effect
	["clutch"] = 0,	-- has neg effect
	["transmission"] = 0, -- has neg effect
	["electronics"] = 0, -- has neg effect
	["fuel_injector"] = 0, -- has neg effect
	["fuel_tank"] = 0 
}
local engineHealth = 0
local bodyHealth = 0

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(947.4976,-972.4548,39.49981)
	SetBlipSprite (blip, 326)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.8)
	SetBlipColour (blip, 3)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Tuner Shop')
	EndTextCommandSetBlipName(blip)
end)
-- #MarkedForMarker
Citizen.CreateThread(function()
      while true do
       Citizen.Wait(5)
       local plyId = PlayerPedId()
       local plyCoords = GetEntityCoords(plyId)
       local dstStorage = #(plyCoords - vector3(-347.0924, -133.5083, 39.00967))
       local dstRepair = #(plyCoords - vector3(947.4976,-972.4548,39.49981))
       local dstRepair2 = #(plyCoords - vector3(947.4976,-972.4548,39.49981))
       
       if DBFWCore.PlayerData.job and DBFWCore.PlayerData.job.name == "mechanic" then
       if dstStorage < 2.0  then
        DrawMarker(22,-347.0924, -133.5083, 39.00967, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.5001, 0, 155, 255, 200, 0, 0, 0, 0) 
        RegisterCommand('mech', function(source, args)
            TriggerEvent("mech:tools", args)
        end)
       elseif dstRepair < 10.0 then
        RegisterCommand('repair', function(source, args)
            repairVeh(args)
        end)
    elseif dstRepair2 < 25.0 then
        RegisterCommand('repair', function(source, args)
            repairVeh(args)
        end)
       else
         if dstStorage > 10.0 and dstRepair > 10.0 then
           Citizen.Wait(2000)
         end
       end
     end
    end
end)

RegisterNetEvent("mech:tools")
AddEventHandler("mech:tools", function(args)
    if args[1] == "check" then
        TriggerServerEvent("mech:check:materials")
    elseif args[1] == "add" then
        if exports["dbfw-inventory"]:hasEnoughOfItem(args[2],1,false) then
            TriggerServerEvent("mech:add:materials", args[2],tonumber(args[3]))
        else
            TriggerEvent("DoShortHudText", "You don't have the materials",2)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        if DBFWCore.PlayerData.job and DBFWCore.PlayerData.job.name == "mechanic" then
        TriggerEvent('chat:addSuggestion', '/mech', 'Use by mechanic!')
        TriggerEvent('chat:addSuggestion', '/mech add', '/mech add [materials] [amount]')
        TriggerEvent('chat:addSuggestion', '/repair', '/repair [parts] [amount]')
        end
    end
end)

function repairVeh(args)
    if DBFWCore.PlayerData.job and DBFWCore.PlayerData.job.name == "mechanic" then
        local degname = string.lower(args[1])
        local amount = tonumber(args[2])
        if amount == nil then
            TriggerEvent("DoShortHudText", "No amount? KEKW", 2)
            return
        end
        playerped = PlayerPedId()
        coordA = GetEntityCoords(playerped, 1)
        coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
        veh = getVehicleInDirection(coordA, coordB)
        local itemname = "Scrap"
        local itemid = 26
        local garagename = "NAME"
        local notfucked = false
        local current = 100

        if degname == "body" or degname == "Body" then
            itemid = 28
            itemname = "Glass"
            degname = "body"
            notfucked = false
            current = bodyHealth
        end

        if degname == "Engine" or degname == "engine" then
            degname = "engine"
            notfucked = false
            current = engineHealth
        end

        if degname == "brakes" or degname == "Brakes" then
            itemid = 33
            itemname = "Rubber"
            degname = "breaks"
            notfucked = true
            current = degHealth["breaks"]
        end

        if degname == "Axle" or degname == "axle" then
            degname = "axle"
            notfucked = true
            current = degHealth["axle"]
        end

        if degname == "Radiator" or degname == "radiator" then
            degname = "radiator"
            notfucked = true
            current = degHealth["radiator"]
        end

        if degname == "Clutch" or degname == "clutch" then
            degname = "clutch"
            notfucked = true
            current = degHealth["clutch"]
        end

        if degname == "electronics" or degname == "Electronics" then
            degname = "electronics"
            itemid = 27
            itemname = "Plastic"
            notfucked = true
            current = degHealth["electronics"]
        end

        if degname == "fuel" or degname == "Fuel" then
            itemid = 30
            itemname = "Steel"
            degname = "fuel_tank"
            notfucked = true
            current = degHealth["fuel_tank"]
        end

        if degname == "transmission" or degname == "Transmission" then
            itemid = 31
            itemname = "Aluminium"
            degname = "transmission"
            notfucked = true
            current = degHealth["transmission"]
        end

        if degname == "Injector" or degname == "injector" then
            itemid = 34
            itemname = "Copper"
            degname = "fuel_injector"
            notfucked = true
            current = degHealth["fuel_injector"]
        end

        if not notfucked then
            TriggerEvent("DoShortHudText","Only mechanics can repair this or not exist",2)
        else

            
            local playerped = PlayerPedId()
            RequestAnimDict("mp_car_bomb")
            TaskPlayAnim(playerped,"mp_car_bomb","car_bomb_mechanic",8.0, -8, -1, 49, 0, 0, 0, 0)
            Wait(100)
            TaskPlayAnim(playerped,"mp_car_bomb","car_bomb_mechanic",8.0, -8, -1, 49, 0, 0, 0, 0)

                local finished = exports["dbfw-taskbar"]:taskBar(15000,"Repairing")
                local coordA = GetEntityCoords(playerped, 1)
                local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
                local targetVehicle = getVehicleInDirection(coordA, coordB)

                if finished == 100 then
                    local plate = GetVehicleNumberPlateText(targetVehicle)
                    ---print(degname,string.lower(itemname),amount,current,plate)
                    if targetVehicle ~= nil  and targetVehicle ~= 0 then
                        TriggerServerEvent('scrap:towTake',degname,string.lower(itemname),amount,current,plate)
                    else
                        TriggerEvent("DoShortHudText","No Vehicle")
                    end
                else
                    --print("REPAIR: 12")
                end
        end
    end
end

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
    
    if distance > 3000 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function VehicleInFront()
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 4.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
  end
  
  RegisterCommand('clean', function()
    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)
    local PlayerData = DBFWCore.GetPlayerData()
    if PlayerData.job.name == 'mechanic' then
  
      if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
  
        local vehicle = nil
  
        if IsPedInAnyVehicle(playerPed, false) then
          vehicle = GetVehiclePedIsIn(playerPed, false)
        else
          vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
        end
  
        if DoesEntityExist(vehicle) then
          TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_MAID_CLEAN", 0, true)
          Citizen.CreateThread(function()
            Citizen.Wait(10000)
            SetVehicleDirtLevel(vehicle, 0)
            ClearPedTasksImmediately(playerPed)
            TriggerEvent('DoLongHudText', 'Vehicle Cleaned', 1)
          end)
        end
      end
    end
  end)  