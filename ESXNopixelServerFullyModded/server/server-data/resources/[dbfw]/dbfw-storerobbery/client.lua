DBFWCore = nil
local DBFWCoreLoaded = false
local robbing = false

Citizen.CreateThread(function ()
    while DBFWCore == nil do
        TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
        Citizen.Wait(0)
    end

    while DBFWCore.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

    DBFWCoreLoaded = true
end)

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
    DBFWCore.PlayerData = xPlayer
end)

RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
    DBFWCore.PlayerData.job = job
end)

local peds = {}
local objects = {}

RegisterNetEvent('dbfw-storerobbery:onPedDeath')
AddEventHandler('dbfw-storerobbery:onPedDeath', function(store)
    SetEntityHealth(peds[store], 0)
end)

RegisterNetEvent('dbfw-storerobbery:msgPolice')
AddEventHandler('dbfw-storerobbery:msgPolice', function(store, robber)
    --TriggerEvent('dbfw-alerts:storerob')
    TriggerEvent('dbfw-dispatch:storerobbery')
end)

RegisterNetEvent('dbfw-storerobbery:removePickup')
AddEventHandler('dbfw-storerobbery:removePickup', function(bank)
    for i = 1, #objects do 
        if objects[i].bank == bank and DoesEntityExist(objects[i].object) then 
            DeleteObject(objects[i].object) 
        end 
    end
end)

RegisterNetEvent('dbfw-storerobbery:robberyOver')
AddEventHandler('dbfw-storerobbery:robberyOver', function()
    robbing = false
end)

RegisterNetEvent('dbfw-storerobbery:talk')
AddEventHandler('dbfw-storerobbery:talk', function(store, text, time)
    robbing = false
    local endTime = GetGameTimer() + 1000 * time
    while endTime >= GetGameTimer() do
        local x = GetEntityCoords(peds[store])
        DrawText3D(vector3(x.x, x.y, x.z + 1.0), text)
        Wait(0)
    end
end)

RegisterCommand('animation', function(source, args)
    if args[1] and args[2] then
        loadDict(args[1])
        TaskPlayAnim(PlayerPedId(), args[1], args[2], 8.0, -8.0, -1, 2, 0, false, false, false)
    end
end)

RegisterNetEvent('dbfw-storerobbery:rob')
AddEventHandler('dbfw-storerobbery:rob', function(i)
    if not IsPedDeadOrDying(peds[i]) then
        SetEntityCoords(peds[i], Config.Shops[i].coords)
        loadDict('mp_am_hold_up')
        TaskPlayAnim(peds[i], "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 2, 0, false, false, false)
        while not IsEntityPlayingAnim(peds[i], "mp_am_hold_up", "holdup_victim_20s", 3) do Wait(0) end
        local timer = GetGameTimer() + 10800
        while timer >= GetGameTimer() do
            if IsPedDeadOrDying(peds[i]) then
                break
            end
            Wait(0)
        end

        if not IsPedDeadOrDying(peds[i]) then
            local cashRegister = GetClosestObjectOfType(GetEntityCoords(peds[i]), 5.0, GetHashKey('prop_till_01'))
            if DoesEntityExist(cashRegister) then
                CreateModelSwap(GetEntityCoords(cashRegister), 0.5, GetHashKey('prop_till_01'), GetHashKey('prop_till_01_dam'), false)
            end

            timer = GetGameTimer() + 200 
            while timer >= GetGameTimer() do
                if IsPedDeadOrDying(peds[i]) then
                    break
                end
                Wait(0)
            end

            local model = GetHashKey('prop_poly_bag_01')
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end
            local bag = CreateObject(model, GetEntityCoords(peds[i]), false, false)
                        
            AttachEntityToEntity(bag, peds[i], GetPedBoneIndex(peds[i], 60309), 0.1, -0.11, 0.08, 0.0, -75.0, -75.0, 1, 1, 0, 0, 2, 1)
            timer = GetGameTimer() + 10000
            while timer >= GetGameTimer() do
                if IsPedDeadOrDying(peds[i]) then
                    break
                end
                Wait(0)
            end
            if not IsPedDeadOrDying(peds[i]) then
                DetachEntity(bag, true, false)
                timer = GetGameTimer() + 75
                while timer >= GetGameTimer() do
                    if IsPedDeadOrDying(peds[i]) then
                        break
                    end
                    Wait(0)
                end
                SetEntityHeading(bag, Config.Shops[i].heading)
                ApplyForceToEntity(bag, 3, vector3(0.0, 50.0, 0.0), 0.0, 0.0, 0.0, 0, true, true, false, false, true)
                table.insert(objects, {bank = i, object = bag})
                Citizen.CreateThread(function()
                    while true do
                        Wait(5)
                        if DoesEntityExist(bag) then
                            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(bag), true) <= 1.5 then
                                PlaySoundFrontend(-1, 'ROBBERY_MONEY_TOTAL', 'HUD_FRONTEND_CUSTOM_SOUNDSET', true)
                                TriggerServerEvent('dbfw-storerobbery:pickUp', i)
                                break
                            end
                        else
                            break
                        end
                    end
                end)
            else
                DeleteObject(bag)
            end
        end
        loadDict('mp_am_hold_up')
        TaskPlayAnim(peds[i], "mp_am_hold_up", "cower_intro", 8.0, -8.0, -1, 0, 0, false, false, false)
        timer = GetGameTimer() + 2500
        while timer >= GetGameTimer() do Wait(0) end
        TaskPlayAnim(peds[i], "mp_am_hold_up", "cower_loop", 8.0, -8.0, -1, 1, 0, false, false, false)
        local stop = GetGameTimer() + 120000
        while stop >= GetGameTimer() do
            Wait(50)
        end
        if IsEntityPlayingAnim(peds[i], "mp_am_hold_up", "cower_loop", 3) then
            ClearPedTasks(peds[i])
        end
    end
end)

RegisterNetEvent('dbfw-storerobbery:resetStore')
AddEventHandler('dbfw-storerobbery:resetStore', function(i)
    while not DBFWCoreLoaded do Wait(0) end
    if DoesEntityExist(peds[i]) then
        DeletePed(peds[i])
    end
    Wait(250)
    peds[i] = _CreatePed(Config.Shopkeeper, Config.Shops[i].coords, Config.Shops[i].heading)
    local brokenCashRegister = GetClosestObjectOfType(GetEntityCoords(peds[i]), 5.0, GetHashKey('prop_till_01_dam'))
    if DoesEntityExist(brokenCashRegister) then
        CreateModelSwap(GetEntityCoords(brokenCashRegister), 0.5, GetHashKey('prop_till_01_dam'), GetHashKey('prop_till_01'), false)
    end
end)

function _CreatePed(hash, coords, heading)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(5)
    end

    local ped = CreatePed(4, hash, coords, false, false)
    SetEntityHeading(ped, heading)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedHearingRange(ped, 0.0)
    SetPedSeeingRange(ped, 0.0)
    SetPedAlertness(ped, 0.0)
    SetPedFleeAttributes(ped, 0, 0)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, 0)
    return ped
end

Citizen.CreateThread(function()
    while not DBFWCoreLoaded do Wait(0) end
    for i = 1, #Config.Shops do 
        peds[i] = _CreatePed(Config.Shopkeeper, Config.Shops[i].coords, Config.Shops[i].heading)

        if Config.Shops[i].blip then
            local blip = AddBlipForCoord(Config.Shops[i].coords)
            SetBlipSprite(blip, 156)
            SetBlipColour(blip, 40)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Shops[i].name)
            EndTextCommandSetBlipName(blip)
        end

        local brokenCashRegister = GetClosestObjectOfType(GetEntityCoords(peds[i]), 5.0, GetHashKey('prop_till_01_dam'))
        if DoesEntityExist(brokenCashRegister) then
            CreateModelSwap(GetEntityCoords(brokenCashRegister), 0.5, GetHashKey('prop_till_01_dam'), GetHashKey('prop_till_01'), false)
        end
    end

    Citizen.CreateThread(function()
        while true do
            for i = 1, #peds do
                if IsPedDeadOrDying(peds[i]) then
                    TriggerServerEvent('dbfw-storerobbery:pedDead', i)
                end
            end
            Wait(5000)
        end
    end)

    while true do
        Wait(5)
        local me = PlayerPedId()
        if IsPedArmed(me, 7) then
            if IsPlayerFreeAiming(PlayerId()) then
                for i = 1, #peds do
                    if HasEntityClearLosToEntityInFront(me, peds[i], 19) and not IsPedDeadOrDying(peds[i]) and GetDistanceBetweenCoords(GetEntityCoords(me), GetEntityCoords(peds[i]), true) <= 5.0 then
                        if not robbing then
                            local canRob = nil
                            DBFWCore.TriggerServerCallback('dbfw-storerobbery:canRob', function(cb)
                                canRob = cb
                            end, i)
                            while canRob == nil do
                                Wait(0)
                            end
                            if canRob == true then
                                robbing = true
                                Citizen.CreateThread(function()
                                    while robbing do Wait(0) if IsPedDeadOrDying(peds[i]) then robbing = false end end
                                end)
                                loadDict('missheist_agency2ahands_up')
                                TaskPlayAnim(peds[i], "missheist_agency2ahands_up", "handsup_anxious", 8.0, -8.0, -1, 1, 0, false, false, false)
                                TriggerServerEvent('dbfw-storerobbery:notif', i)

                                local scared = 0
                                while scared < 100 and not IsPedDeadOrDying(peds[i]) and GetDistanceBetweenCoords(GetEntityCoords(me), GetEntityCoords(peds[i]), true) <= 7.5 do
                                    local sleep = 600
                                    SetEntityAnimSpeed(peds[i], "missheist_agency2ahands_up", "handsup_anxious", 1.0)
                                    if IsPlayerFreeAiming(PlayerId()) then
                                        sleep = 600
                                        SetEntityAnimSpeed(peds[i], "missheist_agency2ahands_up", "handsup_anxious", 1.3)
                                    end
                                    sleep = GetGameTimer() + sleep
                                    while sleep >= GetGameTimer() and not IsPedDeadOrDying(peds[i]) do
                                        Wait(0)
                                        DrawRect(0.5, 0.9, 0.2, 0.03, 75, 75, 75, 200)
                                        local draw = scared/500
                                        DrawRect(0.5, 0.9, draw, 0.03, 165, 196, 255, 216)
                                    end
                                    scared = scared + 1
                                end
                                if GetDistanceBetweenCoords(GetEntityCoords(me), GetEntityCoords(peds[i]), true) <= 7.5 then
                                    if not IsPedDeadOrDying(peds[i]) then
                                        TriggerServerEvent('dbfw-storerobbery:rob', i)
                                        while robbing do Wait(0) if IsPedDeadOrDying(peds[i]) then robbing = false end end
                                    end
                                else
                                    ClearPedTasks(peds[i])
                                    local wait = GetGameTimer()+5000
                                    while wait >= GetGameTimer() do
                                        Wait(0)
                                        DrawText3D(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.5, 0.4), Translation[Config.Locale]['walked_too_far'])
                                    end
                                    robbing = false
                                end
                            elseif canRob == 'no_cops' then
                                local wait = GetGameTimer()+5000
                                while wait >= GetGameTimer() do
                                    Wait(0)
                                    DrawText3D(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.5, 0.4), Translation[Config.Locale]['no_cops'])
                                end
                            else
                                TriggerEvent('dbfw-storerobbery:talk', i, '~g~*' .. Translation[Config.Locale]['shopkeeper'] .. '* ~w~' .. Translation[Config.Locale]['robbed'], 5)
                                Wait(2500)
                            end
                        end
                    end
                end
            end
        end
    end
end)

loadDict = function(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

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
