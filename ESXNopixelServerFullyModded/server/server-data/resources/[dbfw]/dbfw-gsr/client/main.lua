DBFWCore = nil
local hasShot = false

Citizen.CreateThread(function()
    while DBFWCore == nil do
        TriggerEvent('dbfw:getSharedObject', function(obj)DBFWCore = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        ped = PlayerPedId()
        if IsPedShooting(ped) then
            TriggerServerEvent('GSR:SetGSR', timer)
            hasShot = true
            Citizen.Wait(Config.gsrUpdate)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(2000)
        if Config.waterClean and hasShot then
            ped = PlayerPedId()
            if IsEntityInWater(ped) then
                TriggerEvent('DoLongHudText', 'You begin cleaning off the Gunshot Residue... stay in the water.', 1)
                Wait(100)
            	if IsEntityInWater(ped) then
                    hasShot = false
                    TriggerServerEvent('GSR:Remove')
                    TriggerEvent('DoLongHudText', 'You washed off all the Gunshot Residue in the water.', 2)
                	else
                    TriggerEvent('DoLongHudText', 'You left the water too early and did not wash off the gunshot residue.', 2)
                	end
				Citizen.Wait(Config.waterCleanTime)
            end
        end
    end
end)

function status()
    if hasShot then
        DBFWCore.TriggerServerCallback('GSR:Status', function(cb)
            if not cb then
                hasShot = false
            end
        end)
    end
end

function updateStatus()
    status()
    SetTimeout(Config.gsrUpdateStatus, updateStatus)
end

updateStatus()
