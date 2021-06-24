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

inside = false
closesthouse = nil
hasKey = false
isOwned = false

isLoggedIn = false
local contractOpen = false

local servername = 'dbfw Development'
local cam = nil
local viewCam = false
local showClothing = false

stashLocation = nil
stash2Location = nil
outfitLocation = nil
logoutLocation = nil

local OwnedHouseBlips = {}

local CurrentDoorBell = 0
local rangDoorbell = nil

DBFWCore = nil

local inHoldersMenu = false

Citizen.CreateThread(function() 
    while DBFWCore == nil do 
        TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('dbfw-housing:client:sellHouse')
AddEventHandler('dbfw-housing:client:sellHouse', function()
    if closesthouse ~= nil and hasKey then
        TriggerServerEvent('dbfw-housing:server:viewHouse', closesthouse)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)

        if isLoggedIn then
            SetClosestHouse()
        end
    end
end)

function doorText(x, y, z, text)
    SetTextScale(0.325, 0.325)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.011, -0.025+ factor, 0.03, 0, 0, 0, 68)
    ClearDrawOrigin()
end

local houseObj = {}
local POIOffsets = nil
local entering = false
local data = nil

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function()
    TriggerServerEvent('dbfw-housing:client:setHouses')
    isLoggedIn = true
    SetClosestHouse()
    TriggerEvent('dbfw-housing:client:setupHouseBlips')
    Citizen.Wait(100)
    TriggerServerEvent("dbfw-housing:server:setHouses")
end)

RegisterNetEvent('dbfw-housing:client:setHouseConfig')
AddEventHandler('dbfw-housing:client:setHouseConfig', function(houseConfig)
    Config.Houses = houseConfig
    --TriggerEvent("dbfw-housing:client:refreshHouse")
	
end)

RegisterNetEvent('dbfw-housing:client:lockHouse')
AddEventHandler('dbfw-housing:client:lockHouse', function(bool, house)
    Config.Houses[house].locked = bool
end)

RegisterNetEvent('dbfw-housing:client:createHouses')
AddEventHandler('dbfw-housing:client:createHouses', function(price, tier)
    local pos = GetEntityCoords(GetPlayerPed(-1))
	local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
    local heading = GetEntityHeading(GetPlayerPed(-1))
    local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local street1 = GetStreetNameFromHashKey(s1)
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z, currentStreetHash, intersectStreetHash)
    currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    zone = tostring(GetNameOfZone(x, y, z))
    local area = GetLabelText(zone)
    playerStreetsLocation = area
    local coords = {
        enter 	= { x = pos.x, y = pos.y, z = pos.z, h = heading},
        cam 	= { x = pos.x, y = pos.y, z = pos.z, h = heading, yaw = -10.00},
    }
    TriggerServerEvent('dbfw-housing:server:addNewHouse', area, coords, price, tier)
end)

RegisterNetEvent('dbfw-housing:client:toggleDoorlock')
AddEventHandler('dbfw-housing:client:toggleDoorlock', function()
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    
    if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, true) < 1.5)then
        if hasKey then
            if Config.Houses[closesthouse].locked then
                TriggerServerEvent('dbfw-housing:server:lockHouse', false, closesthouse)
				TriggerEvent('DoLongHudText', 'The Door is unlocked.', 1)
            else
                TriggerServerEvent('dbfw-housing:server:lockHouse', true, closesthouse)
				TriggerEvent('DoLongHudText', 'The Door is locked.', 3)
            end
        else
			TriggerEvent('DoLongHudText', 'You dont have the keys to the house.', 2)
        end
    else
		TriggerEvent('DoLongHudText', 'You are not near any door to be able to close it', 2)
    end
end)

DrawText3Ds = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do

        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        local inRange = false

        if closesthouse ~= nil then
            if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, false) < 30)then
                inRange = true
                if hasKey then
                    -- ENTER HOUSE
                    if not inside then
                        if closesthouse ~= nil then
                            if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, true) < 1.5)then
                                if Config.Houses[closesthouse].locked then
                                    DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, '~b~E~w~ - Enter')
                                elseif not Config.Houses[closesthouse].locked then
                                    DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, '~b~E~w~ - Enter')
                                end
                                if IsControlJustPressed(0, Keys["E"]) then
                                    enterOwnedHouse(closesthouse)
									TriggerEvent("inhouse",true)
                                end
                            end
                        end
                    end

                    if CurrentDoorBell ~= 0 then
                        if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, true) < 1.5)then
                            DrawText3Ds(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z + 0.35, '~g~G~w~ - Open the door')
                            if IsControlJustPressed(0, Keys["G"]) then
                                TriggerServerEvent("dbfw-housing:server:OpenDoor", CurrentDoorBell, closesthouse)
                                CurrentDoorBell = 0
                            end
                        end
                    end
                    -- EXIT HOUSE
				    if inside then
                        if not entering then
                            if POIOffsets ~= nil then
                                if POIOffsets.exit ~= nil then
                                    if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, true) < 1.5)then
                                        DrawText3Ds(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - To leave the house')
                                        DrawText3Ds(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z - 0.1, '~g~H~w~ - Watch camera')
                                        if IsControlJustPressed(0, Keys["E"]) then
                                        leaveOwnedHouse(closesthouse)
									    TriggerEvent("inhouse",false)
                                        end
                                        if IsControlJustPressed(0, Keys["H"]) then
                                            FrontDoorCam(Config.Houses[closesthouse].coords.enter)
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if not isOwned then
                        if closesthouse ~= nil then
                            if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, true) < 1.5)then
                                if not viewCam and Config.Houses[closesthouse].locked then
                                    DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, '[~g~E~w~] See house')
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        TriggerServerEvent('dbfw-housing:server:viewHouse', closesthouse)
                                    end
                                elseif not viewCam and not Config.Houses[closesthouse].locked then
                                    DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, '[~g~E~w~] Enter')
                                    if IsControlJustPressed(0, Keys["E"])  then
                                        enterNonOwnedHouse(closesthouse)
                                    end
                                end
                            end
                        end
                    elseif isOwned then
                        if closesthouse ~= nil then
                            if not inOwned then
                                if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z, true) < 1.5)then
                                    if not Config.Houses[closesthouse].locked then
                                        DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, '[~g~E~w~] Enter')
                                        if IsControlJustPressed(0, Keys["E"])  then
                                            enterNonOwnedHouse(closesthouse)
                                        end
                                    else
                                        DrawText3Ds(Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 1.2, 'The door is ~r~closed / ~g~G~w~ - Call at the doorbell')
                                        if IsControlJustPressed(0, Keys["G"]) then
                                            TriggerServerEvent('dbfw-housing:server:RingDoor', closesthouse)
                                        end
                                    end
                                end
                            elseif inOwned then
                                if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, true) < 1.5)then
                                    DrawText3Ds(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - Leave')
                                    if IsControlJustPressed(0, Keys["E"]) then
                                        leaveNonOwnedHouse(closesthouse)
                                    end
                                end
                            end
                        end
                    end
                    if inside and not isOwned then
                        if not entering then
                            if(GetDistanceBetweenCoords(pos, Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, true) < 1.5)then
                                DrawText3Ds(Config.Houses[closesthouse].coords.enter.x + POIOffsets.exit.x, Config.Houses[closesthouse].coords.enter.y + POIOffsets.exit.y, Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset + POIOffsets.exit.z, '~g~E~w~ - Leave')
                                if IsControlJustPressed(0, Keys["E"]) then
                                    leaveNonOwnedHouse(closesthouse)
                                end
                            end
                        end
                    end
                end
                
                local StashObject = nil
                -- STASH
                if inside then
                    if closesthouse ~= nil then
                        if stashLocation ~= nil then
                            if(GetDistanceBetweenCoords(pos, stashLocation.x, stashLocation.y, stashLocation.z, true) < 1.5)then
                                DrawText3Ds(stashLocation.x, stashLocation.y, stashLocation.z, '~g~E~w~ - Drawer')
                                if IsControlJustPressed(0, Keys["E"]) then
									TriggerEvent("server-inventory-open", "1", "Property: "..closesthouse)
                                end
                            elseif(GetDistanceBetweenCoords(pos, stashLocation.x, stashLocation.y, stashLocation.z, true) < 3)then
                                DrawText3Ds(stashLocation.x, stashLocation.y, stashLocation.z, 'Drawer')
                            end
                        end
                    end
                end
				
				local Stash2Object = nil
                -- STASH
                if inside then
                    if closesthouse ~= nil then
                        if stash2Location ~= nil then
                            if(GetDistanceBetweenCoords(pos, stash2Location.x, stash2Location.y, stash2Location.z, true) < 1.5)then
                                DrawText3Ds(stash2Location.x, stash2Location.y, stash2Location.z, '~g~E~w~ - Drawer 2')
                                if IsControlJustPressed(0, Keys["E"]) then
									TriggerEvent("server-inventory-open", "1", "Property: "..closesthouse)
                                end
                            elseif(GetDistanceBetweenCoords(pos, stash2Location.x, stash2Location.y, stash2Location.z, true) < 3)then
                               DrawText3Ds(stash2Location.x, stash2Location.y, stash2Location.z, '~g~E~w~ - Drawer 2')
                            end
                        end
                    end
                end

                if inside then
                    if closesthouse ~= nil then
                        if outfitLocation ~= nil then
                            if(GetDistanceBetweenCoords(pos, outfitLocation.x, outfitLocation.y, outfitLocation.z, true) < 1.5)then
                                DrawText3Ds(outfitLocation.x, outfitLocation.y, outfitLocation.z, '/outfits')
                                showClothing = true
                            else
                                showClothing = false
                            end
                        end
                    end
                end

                if inside then
                    if closesthouse ~= nil then
                        if logoutLocation ~= nil then
                            if(GetDistanceBetweenCoords(pos, logoutLocation.x, logoutLocation.y, logoutLocation.z, true) < 1.5)then
                                DrawText3Ds(logoutLocation.x, logoutLocation.y, logoutLocation.z, '~g~E~w~ - Switch Character')
                                if IsControlJustPressed(0, Keys["E"]) then
                                    TriggerEvent('dbfw-login:swapcharacter')
                                    leaveOwnedHouse(closesthouse)
                                    showClothing = false
                                end
                            elseif(GetDistanceBetweenCoords(pos, logoutLocation.x, logoutLocation.y, logoutLocation.z, true) < 3)then
                                DrawText3Ds(logoutLocation.x, logoutLocation.y, logoutLocation.z, 'Switch Character')
                            end
                        end
                    end
                end
            end
        end
        if not inRange then
            Citizen.Wait(1500)
        end
    
        Citizen.Wait(3)
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if inHoldersMenu then
            Menu.renderGUI()
        end
    end
end)

function openHouseAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(400)
    ClearPedTasks(GetPlayerPed(-1))
end

RegisterNetEvent('dbfw-housing:client:RingDoor')
AddEventHandler('dbfw-housing:client:RingDoor', function(player, house)
    if closesthouse == house and inside then
        CurrentDoorBell = player
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
        --exports["mythic_notify"]:DoHudText('inform', 'Alguien está llamando a la puerta')
    end
end)



RegisterNetEvent('dbfw-housing:client:giveHouseKey')
AddEventHandler('dbfw-housing:client:giveHouseKey', function(data)
    local player, distance = DBFWCore.Game.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 and closesthouse ~= nil then
        local playerId = GetPlayerServerId(player)
        local housedist = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z)
        
        if housedist < 10 then
            TriggerServerEvent('dbfw-housing:server:giveHouseKey', playerId, closesthouse)
        else
			TriggerEvent('DoLongHudText', 'You are not near any house.', 2)
        end
    elseif closesthouse == nil then
		TriggerEvent('DoLongHudText', 'You are not near any house.', 2)
    else
		TriggerEvent('DoLongHudText', 'There is no one near you.', 2)
    end
end)

RegisterNetEvent('dbfw-housing:client:removeHouseKey')
AddEventHandler('dbfw-housing:client:removeHouseKey', function(data)
    if closesthouse ~= nil then 
        local housedist = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z)
        if housedist < 5 then
            DBFWCore.TriggerServerCallback('dbfw-housing:server:getHouseOwner', function(result)
                if DBFWCore.GetPlayerData().identifier == result then
                    inHoldersMenu = true
                    HouseKeysMenu()
                    Menu.hidden = not Menu.hidden
                else
					TriggerEvent('DoLongHudText', 'You are not a homeowner!', 2)
                end
            end, closesthouse)
        else
			TriggerEvent('DoLongHudText', 'You are not near any house!', 2)
        end
    else
		TriggerEvent('DoLongHudText', 'You are not near any house!', 2)
    end
end)

RegisterNetEvent('dbfw-housing:client:refreshHouse')
AddEventHandler('dbfw-housing:client:refreshHouse', function(data)
    Citizen.Wait(100)
    SetClosestHouse()
end)

RegisterNetEvent('dbfw-housing:client:setstash')
AddEventHandler('dbfw-housing:client:setstash', function(data)
ExecuteCommand("setlocation stash")
end)

RegisterNetEvent('dbfw-housing:client:setstash2')
AddEventHandler('dbfw-housing:client:setstash2', function(data)
ExecuteCommand("setlocation stash2")
end)

RegisterNetEvent('dbfw-housing:client:setoutfit')
AddEventHandler('dbfw-housing:client:setoutfit', function(data)
ExecuteCommand("setlocation outfit")
end)

RegisterNetEvent('dbfw-housing:client:setlogout')
AddEventHandler('dbfw-housing:client:setlogout', function(data)
ExecuteCommand("setlocation logout")
end)

RegisterNetEvent('dbfw-housing:client:SpawnInApartment')
AddEventHandler('dbfw-housing:client:SpawnInApartment', function(house)
    local pos = GetEntityCoords(GetPlayerPed(-1))
    if rangDoorbell ~= nil then
        if(GetDistanceBetweenCoords(pos, Config.Houses[house].coords.enter.x, Config.Houses[house].coords.enter.y, Config.Houses[house].coords.enter.z, true) > 5)then
            return
        end
    end
    closesthouse = house
    enterNonOwnedHouse(house)
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 



function changeOutfit()
	Wait(200)
    loadAnimDict("clothingshirt")    	
	TaskPlayAnim(GetPlayerPed(-1), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Wait(3100)
	TaskPlayAnim(GetPlayerPed(-1), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end



function removeHouseKey(citizenData)
    TriggerServerEvent('dbfw-housing:server:removeHouseKey', closesthouse, citizenData)
    closeMenuFull()
end

function closeMenuFull()
    Menu.hidden = true
    inHoldersMenu = false
    ClearMenu()
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function openContract(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "toggle",
        status = bool,
    })
    contractOpen = bool
end

function enterOwnedHouse(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    Citizen.Wait(250)
    local coords = { x = Config.Houses[house].coords.enter.x, y = Config.Houses[house].coords.enter.y, z= Config.Houses[house].coords.enter.z - Config.MinZOffset}
    LoadDecorations(house)
    if Config.Houses[house].tier == 1 then
        data = exports['dbfw-interior']:CreateTier1House(coords)
	elseif Config.Houses[house].tier == 2 then
        data = exports['dbfw-interior']:CreateMichaelShell(coords)
	elseif Config.Houses[house].tier == 3 then
        data = exports['dbfw-interior']:CreateTrevorsShell(coords)
	elseif Config.Houses[house].tier == 4 then
        data = exports['dbfw-interior']:CreateFranklinShell(coords)
	elseif Config.Houses[house].tier == 5 then
        data = exports['dbfw-interior']:CreateFranklinAuntShell(coords)
	elseif Config.Houses[house].tier == 6 then
        data = exports['dbfw-interior']:CreateApartmentShell(coords)
	elseif Config.Houses[house].tier == 7 then
        data = exports['dbfw-interior']:CreateCaravanShell(coords)
    end
    Citizen.Wait(100)
    houseObj = data[1]
    POIOffsets = data[2]
    inside = true
    entering = true
    Citizen.Wait(500)
    SetRainFxIntensity(0.0)
    TriggerEvent('dbfw-weathersync:client:DisableSync')
    TriggerEvent('dbfw-weed:client:getHousePlants', house)
    Citizen.Wait(100)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
    entering = false
    showClothing = true
    setHouseLocations()
end

RegisterNetEvent('dbfw-housing:client:enterOwnedHouse')
AddEventHandler('dbfw-housing:client:enterOwnedHouse', function(house)
	enterOwnedHouse(house)
end)

RegisterNUICallback('HasEnoughMoney', function(data, cb)
    DBFWCore.TriggerServerCallback('dbfw-housing:server:HasEnoughMoney', function(hasEnough)
        
    end, data.objectData)
end)

RegisterNetEvent('dbfw-housing:client:LastLocationHouse')
AddEventHandler('dbfw-housing:client:LastLocationHouse', function(houseId)
	enterOwnedHouse(houseId)
end)

function leaveOwnedHouse(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    Citizen.Wait(250)
    DoScreenFadeOut(250)
    Citizen.Wait(500)
    exports['dbfw-interior']:DespawnInterior(houseObj, function()
        UnloadDecorations()
        TriggerEvent('dbfw-weathersync:client:EnableSync')
        Citizen.Wait(250)
        DoScreenFadeIn(250)
        SetEntityCoords(GetPlayerPed(-1), Config.Houses[closesthouse].coords.enter.x, Config.Houses[closesthouse].coords.enter.y, Config.Houses[closesthouse].coords.enter.z + 0.5)
        SetEntityHeading(GetPlayerPed(-1), Config.Houses[closesthouse].coords.enter.h)
        inside = false
        TriggerEvent('dbfw-weed:client:leaveHouse')
        showClothing = false
    end)
end

function enterNonOwnedHouse(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    Citizen.Wait(250)
    local coords = { x = Config.Houses[closesthouse].coords.enter.x, y = Config.Houses[closesthouse].coords.enter.y, z= Config.Houses[closesthouse].coords.enter.z - Config.MinZOffset}
    LoadDecorations(house)
    if Config.Houses[house].tier == 1 then
        data = exports['dbfw-interior']:CreateTier1House(coords)
	elseif Config.Houses[house].tier == 2 then
        data = exports['dbfw-interior']:CreateMichaelShell(coords)
	elseif Config.Houses[house].tier == 3 then
        data = exports['dbfw-interior']:CreateTrevorsShell(coords)
	elseif Config.Houses[house].tier == 4 then
        data = exports['dbfw-interior']:CreateFranklinShell(coords)
	elseif Config.Houses[house].tier == 5 then
        data = exports['dbfw-interior']:CreateFranklinAuntShell(coords)
	elseif Config.Houses[house].tier == 6 then
        data = exports['dbfw-interior']:CreateApartmentShell(coords)
	elseif Config.Houses[house].tier == 7 then
        data = exports['dbfw-interior']:CreateCaravanShell(coords)
    end
    houseObj = data[1]
    POIOffsets = data[2]
    inside = true
    entering = true
    Citizen.Wait(500)
    SetRainFxIntensity(0.0)
    TriggerServerEvent('dbfw-housing:server:SetInsideMeta', house, true)
    TriggerEvent('dbfw-weathersync:client:DisableSync')
    TriggerEvent('dbfw-weed:client:getHousePlants', house)
    Citizen.Wait(100)
    SetWeatherTypePersist('EXTRASUNNY')
    SetWeatherTypeNow('EXTRASUNNY')
    SetWeatherTypeNowPersist('EXTRASUNNY')
    NetworkOverrideClockTime(23, 0, 0)
    entering = false
    inOwned = true
    showClothing = false
    setHouseLocations()
end

function leaveNonOwnedHouse(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
    openHouseAnim()
    Citizen.Wait(250)
    DoScreenFadeOut(250)
    Citizen.Wait(500)
    exports['dbfw-interior']:DespawnInterior(houseObj, function()
        UnloadDecorations()
        TriggerEvent('dbfw-weathersync:client:EnableSync')
        Citizen.Wait(250)
        DoScreenFadeIn(250)
        SetEntityCoords(GetPlayerPed(-1), Config.Houses[house].coords.enter.x, Config.Houses[house].coords.enter.y, Config.Houses[house].coords.enter.z + 0.5)
        SetEntityHeading(GetPlayerPed(-1), Config.Houses[house].coords.enter.h)
        inOwned = false
        inside = false
        showClothing = false
        TriggerEvent('dbfw-weed:client:leaveHouse')
        TriggerServerEvent('dbfw-housing:server:SetInsideMeta', house, false)
    end)
end

function setViewCam(coords, h, yaw)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, yaw, 0.00, h, 120.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    viewCam = true
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if inHoldersMenu then
            Menu.renderGUI()
        end
    end
end)


function HouseKeysMenu()
    ped = GetPlayerPed(-1);
    MenuTitle = "Keys"
    ClearMenu()
    DBFWCore.TriggerServerCallback('dbfw-housing:server:getHouseKeyHolders', function(holders)
        ped = GetPlayerPed(-1);
        MenuTitle = "House Keys:"
        ClearMenu()
        if holders == nil or next(holders) == nil then
            TriggerEvent('DoLongHudText', 'No key holders found..', 2)
            closeMenuFull()
        else
            for k, v in pairs(holders) do
                Menu.addButton(holders[k].firstname .. " " .. holders[k].lastname, "optionMenu", holders[k]) 
            end
        end
        Menu.addButton("Close Menu", "closeMenuFull", nil) 
    end, closesthouse)
end

function optionMenu(citizenData)
    ped = GetPlayerPed(-1);
    MenuTitle = "What now?"
    ClearMenu()
    Menu.addButton("Remove house key", "removeHouseKey", citizenData) 
    Menu.addButton("idk wtf this is", "HouseKeysMenu",nil)
end


function FrontDoorCam(coords)
    DoScreenFadeOut(150)
    Citizen.Wait(500)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z + 0.5, 0.0, 0.00, coords.h - 180, 80.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    FrontCam = true
    FreezeEntityPosition(GetPlayerPed(-1), true)
    Citizen.Wait(500)
    DoScreenFadeIn(150)
    SendNUIMessage({
        type = "frontcam",
        toggle = true,
        label = Config.Houses[closesthouse].adress
    })
    Citizen.CreateThread(function()
        while FrontCam do

            local instructions = CreateInstuctionScaleform("instructional_buttons")
            DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
            SetTimecycleModifier("scanline_cam_cheap")
            SetTimecycleModifierStrength(1.0)

            if IsControlJustPressed(1, Keys["BACKSPACE"]) then
                DoScreenFadeOut(150)
                SendNUIMessage({
                    type = "frontcam",
                    toggle = false,
                })
                Citizen.Wait(500)
                RenderScriptCams(false, true, 500, true, true)
                FreezeEntityPosition(GetPlayerPed(-1), false)
                SetCamActive(cam, false)
                DestroyCam(cam, true)
                ClearTimecycleModifier("scanline_cam_cheap")
                cam = nil
                FrontCam = false
                Citizen.Wait(500)
                DoScreenFadeIn(150)
            end

            local getCameraRot = GetCamRot(cam, 2)

            -- ROTATE UP
            if IsControlPressed(0, Keys["W"]) then
                if getCameraRot.x <= 0.0 then
                    SetCamRot(cam, getCameraRot.x + 0.7, 0.0, getCameraRot.z, 2)
                end
            end

            -- ROTATE DOWN
            if IsControlPressed(0, Keys["S"]) then
                if getCameraRot.x >= -50.0 then
                    SetCamRot(cam, getCameraRot.x - 0.7, 0.0, getCameraRot.z, 2)
                end
            end

            -- ROTATE LEFT
            if IsControlPressed(0, Keys["A"]) then
                SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
            end

            -- ROTATE RIGHT
            if IsControlPressed(0, Keys["D"]) then
                SetCamRot(cam, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
            end

            Citizen.Wait(1)
        end
    end)
end

function CreateInstuctionScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 194, true))
    InstructionButtonMessage("Exit Camera")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function disableViewCam()
    if viewCam then
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        viewCam = false
    end
end


RegisterNetEvent('dbfw-housing:client:setupHouseBlips')
AddEventHandler('dbfw-housing:client:setupHouseBlips', function()
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        if isLoggedIn then
            DBFWCore.TriggerServerCallback('dbfw-housing:server:getOwnedHouses', function(ownedHouses)
                if ownedHouses ~= nil then
                    for k, v in pairs(ownedHouses) do
                        local house = Config.Houses[ownedHouses[k]]
                        HouseBlip = AddBlipForCoord(house.coords.enter.x, house.coords.enter.y, house.coords.enter.z)

                        SetBlipSprite (HouseBlip, 40)
                        SetBlipDisplay(HouseBlip, 4)
                        SetBlipScale  (HouseBlip, 0.7)
                        SetBlipAsShortRange(HouseBlip, true)
                        SetBlipColour(HouseBlip, 7)

                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentSubstringPlayerName(house.adress)
                        EndTextCommandSetBlipName(HouseBlip)

                        table.insert(OwnedHouseBlips, HouseBlip)
                    end
                end
            end)
        end
    end)
end)

RegisterNetEvent('dbfw-housing:client:SetClosestHouse')
AddEventHandler('dbfw-housing:client:SetClosestHouse', function()
    SetClosestHouse()
end)

function setViewCam(coords, h, yaw)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, yaw, 0.00, h, 80.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    viewCam = true
end

function disableViewCam()
    if viewCam then
        RenderScriptCams(false, true, 500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        viewCam = false
    end
end

RegisterNUICallback('buy', function()
    openContract(false)
    disableViewCam()
    TriggerServerEvent('dbfw-housing:server:buyHouse', closesthouse)
end)

RegisterCommand('buy', function()
    openContract(true)
end)

RegisterNUICallback('exit', function()
    openContract(false)
    disableViewCam()
end)

RegisterNetEvent('dbfw-housing:client:viewHouse')
AddEventHandler('dbfw-housing:client:viewHouse', function(houseprice, brokerfee, bankfee, taxes, firstname, lastname)
    setViewCam(Config.Houses[closesthouse].coords.cam, Config.Houses[closesthouse].coords.cam.h, Config.Houses[closesthouse].coords.yaw)
    Citizen.Wait(500)
    openContract(true)
    SendNUIMessage({
        type = "setupContract",
        firstname = firstname,
        lastname = lastname,
        street = Config.Houses[closesthouse].adress,
        houseprice = houseprice,
        brokerfee = brokerfee,
        bankfee = bankfee,
        taxes = taxes,
        totalprice = (houseprice + brokerfee + bankfee + taxes)
    })
end)

function SetClosestHouse()
    local pos = GetEntityCoords(GetPlayerPed(-1), true)
    local current = nil
    local dist = nil
    if not inside then
        for id, house in pairs(Config.Houses) do
            if current ~= nil then
                if(GetDistanceBetweenCoords(pos, Config.Houses[id].coords.enter.x, Config.Houses[id].coords.enter.y, Config.Houses[id].coords.enter.z, true) < dist)then
                    current = id
                    dist = GetDistanceBetweenCoords(pos, Config.Houses[id].coords.enter.x, Config.Houses[id].coords.enter.y, Config.Houses[id].coords.enter.z, true)
                end
            else
                dist = GetDistanceBetweenCoords(pos, Config.Houses[id].coords.enter.x, Config.Houses[id].coords.enter.y, Config.Houses[id].coords.enter.z, true)
                current = id
            end
        end
        closesthouse = current
    
        if closesthouse ~= nil then 
            DBFWCore.TriggerServerCallback('dbfw-housing:server:hasKey', function(result)
                hasKey = result
            end, closesthouse)
        
            DBFWCore.TriggerServerCallback('dbfw-housing:server:isOwned', function(result)
                isOwned = result
            end, closesthouse)
        end
    end
end

function setHouseLocations()
    if closesthouse ~= nil then
        DBFWCore.TriggerServerCallback('dbfw-housing:server:getHouseLocations', function(result)
            if result ~= nil then
                if result.stash ~= nil then
                    stashLocation = json.decode(result.stash)
                end
				
				 if result.stash2 ~= nil then
                    stash2Location = json.decode(result.stash2)
                end

                if result.outfit ~= nil then
                    outfitLocation = json.decode(result.outfit)
                end

                if result.logout ~= nil then
                    logoutLocation = json.decode(result.logout)
                end
            end
        end, closesthouse)
    end
end

RegisterNetEvent('dbfw-housing:client:setLocation')
AddEventHandler('dbfw-housing:client:setLocation', function(data)
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local coords = {x = pos.x, y = pos.y, z = pos.z}

    if inside then
        if hasKey then
            if data == 'stash' then
                TriggerServerEvent('dbfw-housing:server:setLocation', coords, closesthouse, 1)
            elseif data == 'outift' then
                TriggerServerEvent('dbfw-housing:server:setLocation', coords, closesthouse, 2)
            elseif data == 'logout' then
                TriggerServerEvent('dbfw-housing:server:setLocation', coords, closesthouse, 3)
			elseif data == 'stash2' then
                TriggerServerEvent('dbfw-housing:server:setLocation', coords, closesthouse, 4)
            end
        else
			TriggerEvent('DoLongHudText', 'You dont have keys to this house', 2)
        end
    else
		TriggerEvent('DoLongHudText', 'You are not inside any house', 2)
    end
end)

RegisterNetEvent('dbfw-housing:client:refreshLocations')
AddEventHandler('dbfw-housing:client:refreshLocations', function(house, location, type)
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)

    if closesthouse == house then
        if inside then
            TriggerEvent('dbfw-housing:getid', closesthouse, house)
            if type == 1 then
                stashLocation = json.decode(location)
            elseif type == 2 then
                outfitLocation = json.decode(location)
            elseif type == 3 then
                logoutLocation = json.decode(location)
			elseif type == 4 then
                stash2Location = json.decode(location)
            end
        end
    end
end)

imClosesToRoom2 = function()
    local ply = PlayerPedId()
    if showClothing then
      return true
    else
      return false
    end
  end