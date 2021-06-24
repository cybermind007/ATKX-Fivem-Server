DBFWCore = nil
Citizen.CreateThread(function()
    while DBFWCore == nil do
        TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
        Citizen.Wait(0)
    end
end)
local isFishing = false
local inZone = false
local cancel = false
local veh = 0
local canSpawn = true
local zones = {
    'OCEANA',
    'ELYSIAN',
    'CYPRE',
    'DELSOL',
    'LAGO',
    'ZANCUDO',
    'ALAMO',
    'NCHU',
    'CCREAK',
    'PALCOV',
    'PALETO',
    'PROCOB',
    'ELGORL',
    'SANCHIA',
    'PALHIGH',
    'DELBE',
    'PBLUFF',
    'SANDY',
    'GRAPES',
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local plyCords = GetEntityCoords(PlayerPedId())
        local dis = GetDistanceBetweenCoords(plyCords, -1846.707, -1190.704, 14.32304, true) 
        if dis <= 5 then
            DrawText3Ds(-1846.707, -1190.704, 14.32304,'[E] Sell Fish')
            if IsControlJustReleased(0, 38) then
                local finished = exports["dbfw-taskbar"]:taskBar(2000,"Selling Fish",true,false,playerVeh)
                if finished == 100 then
                    SellItems()
                end
            end
        end
        local dis3 = GetDistanceBetweenCoords(plyCords, -3424.41, 982.81, 8.43, true) 
        if dis3 <= 5 and veh == 0 then
            DrawText3Ds(-3424.41, 982.81, 8.43, '[E] Rent A Boat') 
            if IsControlJustReleased(0, 38) then
                if canSpawn == true then
                    if DBFWCore.GetPlayerData().money >= 500 then
                    TriggerServerEvent('fish:checkAndTakeDepo')
                    Citizen.Wait(500)
                        canSpawn = false
                        DBFWCore.Game.SpawnVehicle('marquis', vector3(-3448.48, 971.98, 1.91), 45, function(vehicle) 
                            veh = vehicle
                            SetEntityAsMissionEntity(veh, true, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                            TriggerServerEvent('garage:addKeys', GetVehicleNumberPlateText(veh))
                        end)
                    elseif DBFWCore.GetPlayerData().money < 500 then
                        TriggerEvent('DoLongHudText', 'You cant afford the Deposit!', 2)
                    end
                else
                    TriggerEvent('DoLongHudText', 'Vehicle is already out!', 2)
                end
            end
        elseif dis3 <= 20 and veh ~= 0 then
            DrawText3Ds(-3424.41, 982.81, 8.43,'[E] Return the Boat (Reward $500)') 
            if IsControlJustReleased(0, 38) then
                DeleteVehicle(veh)
                veh = 0
                TriggerEvent('DoLongHudText', 'Vehicle Returned and your Deposit was Refunded!', 1)
                TriggerServerEvent('fish:returnDepo')
                SetEntityCoords(GetPlayerPed(-1), -3424.41, 982.81, 8.43)
                Citizen.Wait(2000)
                canSpawn = true
            end
        end
        --Mortal 
        local dis3 = GetDistanceBetweenCoords(plyCords, -806.02, -1496.73, 1.6, true) 
        if dis3 <= 5 and veh == 0 then
            DrawText3Ds(-806.02, -1496.73, 1.6, '[E] Rent A Boat') 
            if IsControlJustReleased(0, 38) then
                if canSpawn == true then
                    if DBFWCore.GetPlayerData().money >= 500 then
                    TriggerServerEvent('fish:checkAndTakeDepo')
                    Citizen.Wait(500)
                        canSpawn = false
                        DBFWCore.Game.SpawnVehicle('marquis', vector3(-821.73, -1513.48, -0.47), 45, function(vehicle) 
                            veh = vehicle
                            SetEntityAsMissionEntity(veh, true, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                            TriggerServerEvent('garage:addKeys', GetVehicleNumberPlateText(veh))
                        end)
                    elseif DBFWCore.GetPlayerData().money < 500 then
                        TriggerEvent('DoLongHudText', 'You cant afford the Deposit!', 2)
                    end
                else
                    TriggerEvent('DoLongHudText', 'Vehicle is already out!', 2)
                end
            end
        elseif dis3 <= 20 and veh ~= 0 then
            DrawText3Ds(-806.76, -1506.02, 2.14,'[E] Return the Boat (Reward $500)') 
            if IsControlJustReleased(0, 38) then
                DeleteVehicle(veh)
                veh = 0
                TriggerEvent('DoLongHudText', 'Vehicle Returned and your Deposit was Refunded!', 1)
                TriggerServerEvent('fish:returnDepo')
                SetEntityCoords(GetPlayerPed(-1), -787.14, -1489.82, 1.6)
                Citizen.Wait(2000)
                canSpawn = true
            end
        end
        --Mortal END 
        local dis4 = GetDistanceBetweenCoords(plyCords, 1308.91, 4362.29, 41.55, true) 
        local dis2 = GetDistanceBetweenCoords(plyCords, 1302.839, 4225.832, 33.9087, true) 
        if dis4 <= 5 and veh == 0 then
            DrawText3Ds(1308.91, 4362.29, 41.55, '[E] Rent A Boat') -- need to change
            if IsControlJustReleased(0, 38) then
                if canSpawn == true then
                    if DBFWCore.GetPlayerData().money >= 500 then
                    TriggerServerEvent('fish:checkAndTakeDepo')
                    Citizen.Wait(500)
                        canSpawn = false
                        DBFWCore.Game.SpawnVehicle('suntrap', vector3(1299.69, 4194.82, 30.91), 45, function(vehicle) 
                            veh = vehicle
                            SetEntityAsMissionEntity(veh, true, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                            TriggerServerEvent('garage:addKeys', GetVehicleNumberPlateText(veh))
                        end)
                    elseif DBFWCore.GetPlayerData().money < 500 then
                        TriggerEvent('DoLongHudText', 'You cant afford the Deposit!', 2)
                    end
                else
                    TriggerEvent('DoLongHudText', 'Vehicle is already out!', 2)
                end
            end
        elseif dis2 <= 20 and veh ~= 0 then
            DrawText3Ds(1302.839, 4225.832, 33.9087,'[E] Return the Boat (Reward $500)') 
            if IsControlJustReleased(0, 38) then
                DeleteVehicle(veh)
                veh = 0
                TriggerEvent('DoLongHudText', 'Vehicle Returned and your Deposit was Refunded!', 1)
                TriggerServerEvent('fish:returnDepo')
                SetEntityCoords(GetPlayerPed(-1), 1302.839, 4225.832, 33.9087)
                Citizen.Wait(2000)
                canSpawn = true
            end
        end
        local dis5 = GetDistanceBetweenCoords(plyCords, 3807.98, 4478.62, 6.37, true) 
        local dis6 = GetDistanceBetweenCoords(plyCords, 3865.944, 4463.568, 2.73844, true) 
        if dis5 <= 5 and veh == 0 then
            DrawText3Ds(3807.98, 4478.62, 6.37, '[E] Rent A Boat') 
            if IsControlJustReleased(0, 38) then
                if canSpawn == true then
                    if DBFWCore.GetPlayerData().money >= 500 then
                    TriggerServerEvent('fish:checkAndTakeDepo')
                    Citizen.Wait(500)
                        canSpawn = false
                        DBFWCore.Game.SpawnVehicle('tropic', vector3(3865.89, 4476.66, 1.53), 45, function(vehicle) 
                            veh = vehicle
                            SetEntityAsMissionEntity(veh, true, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                            TriggerServerEvent('garage:addKeys', GetVehicleNumberPlateText(veh))
                        end)
                    elseif DBFWCore.GetPlayerData().money < 500 then
                        TriggerEvent('DoLongHudText', 'You cant afford the Deposit!', 2)
                    end
                else
                    TriggerEvent('DoLongHudText', 'Vehicle is already out!', 2)
                end
            end
        elseif dis6 <= 20 and veh ~= 0 then
            DrawText3Ds(3865.944, 4463.568, 2.73844,'[E] Return the Boat (Reward $500)') 
            if IsControlJustReleased(0, 38) then
                DeleteVehicle(veh)
                veh = 0
                TriggerEvent('DoLongHudText', 'Vehicle Returned and your Deposit was Refunded!', 1)
                TriggerServerEvent('fish:returnDepo')
                SetEntityCoords(GetPlayerPed(-1), 3865.944, 4463.568, 2.73844)
                Citizen.Wait(2000)
                canSpawn = true
            end
        end
    end
end)
--- suntrap tropic marquis

RegisterNetEvent('dbfw-fish:lego')
AddEventHandler('dbfw-fish:lego', function()
    if isFishing == false then
        StartFish()
    elseif isFishing == true then
        TriggerEvent('DoLongHudText', 'You are already fishing dingus.', 2)
    end
end)

function checkZone()
    local ply = PlayerPedId()
    local coords = GetEntityCoords(ply)
    local currZone = GetNameOfZone(coords)
    for k,v in pairs(zones) do
        if currZone == v then
            inZone = true
            break
        else
            inZone = false
        end
    end
    
end

function StartFish()
    local ply = PlayerPedId()
    local onBoat = false
    local function GetEntityBelow()
        local Ent = nil
        local CoA = GetEntityCoords(ply, 1)
        local CoB = GetOffsetFromEntityInWorldCoords(ply, 0.0, 0.0, 5.0)
        local RayHandle = CastRayPointToPoint(CoA.x, CoA.y, CoA.z, CoB.x, CoB.y, CoB.z, 10, ply, 0)
        local A,B,C,D,Ent = GetRaycastResult(RayHandle)
        return Ent
    end
    local boat = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.000, 0, 12294)
    checkZone()
    Citizen.Wait(250)
    if IsEntityInWater(boat) and IsPedSwimming(ply) == false and inZone == true then
        if exports["dbfw-inventory"]:hasEnoughOfItem('fishingrod',1,false) then
            isFishing = true
            cancel = false
            Fish()
        end
    elseif IsEntityInWater(ply) and IsPedSwimming(ply) == false and inZone == true then 
        if exports["dbfw-inventory"]:hasEnoughOfItem('fishingrod',1,false) then
            isFishing = true
            cancel = false
            Fish()
        end
    end
end  


function Fish()
    if cancel == false then
        local ply = PlayerPedId()
       --playerAnim() 
        TaskStartScenarioInPlace(ply, 'WORLD_HUMAN_STAND_FISHING', 0, true)
        timer = math.random(10000,30000)
        Citizen.Wait(timer)
        Catch()
    end
end

function Repeat()
    timer = math.random(10000,30000)
    if cancel == false then
        Citizen.Wait(timer)
        Catch()
    end
end

function Catch()
    if cancel == false then
        local ply = PlayerPedId()
        TriggerEvent('DoLongHudText', 'There is a fish on the line.', 1)
        local finished = exports["dbfw-taskbarskill"]:taskBar(2000,math.random(7,14))
        if finished == 100 then
            isFishing = false
            local rdn = math.random(1,100)
            if rdn <= 10 then
                TriggerEvent("inventory:removeItem", "fishingrod", 1)
                SetCurrentPedWeapon(ply, `WEAPON_UNARMED`, true)
                ClearPedTasksImmediately(ply)
            elseif rdn > 11 then
                TriggerEvent('DoLongHudText', 'You caught a Fish!', 1)
                TriggerServerEvent('dbfw-fish:getFish')
                SetCurrentPedWeapon(ply, `WEAPON_UNARMED`, true)
                ClearPedTasksImmediately(ply)
            end
        elseif finished ~= 100 then
            TriggerEvent('DoLongHudText', 'The fish got away.', 2)
            Repeat()
        else
            isFishing = false
        end
    end
end


function DrawText3Ds(x,y,z, text)
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

function SellItems()
    local sellfish = math.random(40, 80)
        if exports["dbfw-inventory"]:hasEnoughOfItem("fish",2,false) then 
        TriggerEvent("inventory:removeItem", "fish", 2)
        TriggerServerEvent('dbfw-fish:payShit', sellfish)
    else
        TriggerEvent('DoLongHudText', 'You dont have enough fish in your pockets to sell!', 2)
    end
end

local blips = {
    {title="Chumash Boat Rental", colour=3, id=356, scale=0.7, x = -3424.41, y = 982.81, z = 8.43},
    {title="North Boat Rental", colour=3, id=356, scale=0.7, x = 1308.91, y = 4362.29, z = 41.55},
    {title="Catfish View Boat Rental", colour=3, id=356, scale=0.7, x = 3807.98, y = 4478.62, z = 6.37},
    {title="LS Boat Rental", colour=3, id=356, scale=0.7, x = -806.02, y = -1496.73, z = 1.6},
    {title="Fish Sell Point", colour=81, id=317, scale=0.8, x = -1846.707, y = -1190.704, z = 14.32304},
 }
     
Citizen.CreateThread(function()
   for _, info in pairs(blips) do
     info.blip = AddBlipForCoord(info.x, info.y, info.z)
     SetBlipSprite(info.blip, info.id)
     SetBlipDisplay(info.blip, 4)
     SetBlipScale(info.blip, info.scale)
     SetBlipColour(info.blip, info.colour)
     SetBlipAsShortRange(info.blip, true)
     BeginTextCommandSetBlipName("STRING")
     AddTextComponentString(info.title)
     EndTextCommandSetBlipName(info.blip)
   end
end)