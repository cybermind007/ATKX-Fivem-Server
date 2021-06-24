local msgCount2 = 0
local scary2 = 0
local scaryloop2 = false
local dicks2 = 0
local dicks3 = 0
local dicks = 0
local ped = PlayerPedId()
local isInVehicle = IsPedInAnyVehicle(ped, true)

Citizen.CreateThread( function()
    while true do
        Wait(1000)
        ped = PlayerPedId()
        isInVehicle = IsPedInAnyVehicle(ped, true)
    end
end)

RegisterCommand('me', function(source, args)
    local text = '' -- edit here if you want to change the language : EN: the person / FR: la personne
    for i = 1,#args do
        text = text .. ' ' .. args[i]
    end
    text = text .. ''
	TriggerServerEvent('3dme:shareDisplay', text)
end)

RegisterNetEvent('Do3DText')
AddEventHandler("Do3DText", function(text, source)
    TriggerEvent('DoHudTextCoords', GetPlayerFromServerId(source), text)
end)

RegisterNetEvent('DoHudTextCoords')
AddEventHandler('DoHudTextCoords', function(mePlayer, text)
    dicks2 = 600
    msgCount2 = msgCount2 + 0.22
    local mycount2 = msgCount2

    scary2 = 600 - (msgCount2 * 100)
    TriggerEvent("scaryLoop2")
    local power2 = true
    while dicks2 > 0 do

        dicks2 = dicks2 - 1
        local plyCoords2 = GetEntityCoords(GetPlayerPed(-1))
        local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
        local dist = Vdist2(coordsMe, plyCoords2)

        output = dicks2

        if output > 255 then
            output = 255
        end
        if dist < 500 then
            if HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(mePlayer), 17 ) then

                if not isInVehicle and GetFollowPedCamViewMode() == 0 then
                    DrawText3DTest(coordsMe["x"],coordsMe["y"],coordsMe["z"]+(mycount2/2) - 0.2, text, output,power2)
                elseif not isInVehicle and GetFollowPedCamViewMode() == 4 then
                    DrawText3DTest(coordsMe["x"],coordsMe["y"],coordsMe["z"]+(mycount2/7) - 0.1, text, output,power2)
                elseif GetFollowPedCamViewMode() == 4 then
                    DrawText3DTest(coordsMe["x"],coordsMe["y"],coordsMe["z"]+(mycount2/7) - 0.2, text, output,power2)
                else
                    DrawText3DTest(coordsMe["x"],coordsMe["y"],coordsMe["z"]+mycount2 - 1.25, text, output,power2)
                end
            end
        end

        Citizen.Wait(1)
    end

end)

function DrawText3DTest(x,y,z, text, dicks,power)

    local onScreen,_x,_y=World3dToScreen2d(x,y,z + 0.1)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    if dicks > 255 then
        dicks = 255
    end
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 155)
        SetTextEdge(1, 0, 0, 0, 250)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        SetTextColour(255, 255, 255, dicks)

        DrawText(_x,_y)
        local factor = (string.len(text)) / 250
        if dicks < 115 then
            DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 11, 1, 11, dicks)
        else
            DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 11, 1, 11, 115)
        end
    end
end

RegisterNetEvent('scaryLoop2')
AddEventHandler('scaryLoop2', function()
    if scaryloop2 then return end
    scaryloop2 = true
    while scary2 > 0 do
        if msgCount2 > 2.6 then
            scary2 = 0
        end
        Citizen.Wait(1)
        scary2 = scary2 - 1
    end
    dicks2 = 0
    scaryloop2 = false
    scary2 = 0
    msgCount2 = 0
end)