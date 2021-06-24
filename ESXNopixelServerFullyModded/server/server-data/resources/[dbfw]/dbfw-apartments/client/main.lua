DBFWCore = nil
Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

local isLoggedIn = false
local InApartment = false
local ClosestHouse = nil
local CurrentApartment = nil
local IsOwned = false
local showClothing = false
local CurrentDoorBell = 0

local CurrentOffset = 0

local houseObj = {}
local POIOffsets = nil

local rangDoorbell = nil



Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end

	while DBFWCore.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = DBFWCore.GetPlayerData()
end)
  

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if  not InApartment then
            SetClosestApartment()
        end
        Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if  ClosestHouse ~= nil then
            if InApartment then
                local pos = GetEntityCoords(GetPlayerPed(-1))

                if CurrentDoorBell ~= 0 then
                    if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z, true) < 1.2)then
                        DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z + 0.1, '~g~G~w~ - Enter')
                        if IsControlJustPressed(0, Keys["G"]) then
                            TriggerServerEvent("apartments:server:OpenDoor", CurrentDoorBell, CurrentApartment, ClosestHouse)
                            CurrentDoorBell = 0
                            showClothing = true
                        end
                    end
                end
                --exit
                if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z, true) < 3)then
                    DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z, '~g~E~w~ - Exit')
                    if IsControlJustPressed(0, Keys["E"]) then
                        LeaveApartment(ClosestHouse)
                        showClothing = false
                    end
                end
                --stash
                if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z, true) < 1.5)then
                    DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z, '~g~E~w~ - Storage')
                    if IsControlJustPressed(0, Keys["E"]) then
                        if CurrentApartment ~= nil then
							TriggerEvent("server-inventory-open", "1", "motel2-"..CurrentApartment)
--							TriggerScreenblurFadeIn(0)
                        end
                    end
                end
                --outfits
                if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z, true) < 1.5)then
                    DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z, '/outfits')
                    showClothing = true
                else
                    showClothing = false
                end
                --logout
                if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z, true) < 1.5)then
                    DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z, '~g~E~w~ - Switch Character')
                    if IsControlJustPressed(0, Keys["E"]) then
                        TriggerEvent('dbfw-login:swapcharacter')
                    end
                end
            else
                if IsOwned then
                    local pos = GetEntityCoords(GetPlayerPed(-1))
                    if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y,Apartments.Locations[ClosestHouse].coords.enter.z, true) < 1.2)then
                        DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y, Apartments.Locations[ClosestHouse].coords.enter.z, '~g~E~w~ - Enter')
                        if IsControlJustPressed(0, Keys["E"]) then
                            DBFWCore.TriggerServerCallback('apartments:GetOwnedApartment', function(result)
                                if result ~= nil then
                                    EnterApartment(ClosestHouse, result.name)
                                end
                            end)
                        end
                    end
                elseif not IsOwned then
                    --[[local pos = GetEntityCoords(GetPlayerPed(-1))
                    if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y,Apartments.Locations[ClosestHouse].coords.enter.z, true) < 1.2)then
                        QBCore.Functions.DrawText3D(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y, Apartments.Locations[ClosestHouse].coords.enter.z, '~g~G~w~ - Verander van appartement')
                        if IsControlJustPressed(0, Keys["G"]) then
                            TriggerServerEvent("apartments:server:UpdateApartment", ClosestHouse)
                            IsOwned = true
                        end
                    end]]--
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local distance = #(GetEntityCoords(PlayerPedId()) - vector3(Config.Apartmanal["x"], Config.Apartmanal["y"], Config.Apartmanal["z"]))
        if distance < 0.7 then
            DrawText3D(Config.Apartmanal["x"], Config.Apartmanal["y"], Config.Apartmanal["z"], "[E] Buy Apartment")
            if IsControlJustReleased(0, 38) then
                apartal()
            end
        end
    end
end)

function apartal()
        local myListMenu = {
		menutype = "list",
		menulabel = "Apartment",
		showBack = false,
		menu = {
			{label = 'South Rockford Drive', value = {label = 'South Rockford Drive', value = 'apartment1'}},
			{label = 'Morningwood Blvd', value = {label = 'Morningwood Blvd', value = 'apartment2'}},
			{label = 'Integrity Way', value = {label = 'Integrity Way', value = 'apartment3'}},
			{label = 'Tinsel Towers', value = {label = 'Tinsel Towers', value = 'apartment4'}},
			{label = 'Fantastic Plaza', value = {label = 'Fantastic Plaza', value = 'apartment5'}}
		}
	}

	TriggerEvent("dbfw-uimenu:createMenu", myListMenu, function(data)
		if not data then return end
		TriggerServerEvent('apartments:server:CreateApartment', data.value, data.label)
	end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if houseObj ~= nil then
            exports['dbfw-interior']:DespawnInterior(houseObj, function()
                CurrentApartment = nil
                TriggerEvent('dbfw-weathersync:client:EnableSync')
                DoScreenFadeIn(500)
                while not IsScreenFadedOut() do
                    Citizen.Wait(10)
                end
                SetEntityCoords(GetPlayerPed(-1), Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y,Apartments.Locations[ClosestHouse].coords.enter.z)
                SetEntityHeading(GetPlayerPed(-1), Apartments.Locations[ClosestHouse].coords.enter.h)
                Citizen.Wait(1000)
                InApartment = false
                DoScreenFadeIn(1000)
            end)
        end
    end
end)

RegisterNetEvent('apartments:client:setupSpawnUI')
AddEventHandler('apartments:client:setupSpawnUI', function(cData)
    DBFWCore.TriggerServerCallback('apartments:GetOwnedApartment', function(result)
        if result ~= nil then
            TriggerEvent("apartments:client:SetHomeBlip", result.type)
      
        end
    end)
end)

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    TriggerEvent("apartments:client:setupSpawnUI")
   
end)


RegisterNetEvent('apartments:client:SpawnInApartment')
AddEventHandler('apartments:client:SpawnInApartment', function(apartmentId, apartment)
    if rangDoorbell ~= nil then
        if(GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Apartments.Locations[rangDoorbell].coords.enter.x, Apartments.Locations[rangDoorbell].coords.enter.y,Apartments.Locations[rangDoorbell].coords.enter.z, true) > 5)then
            return
        end
    end
    ClosestHouse = apartment
    EnterApartment(apartment, apartmentId, true)
    IsOwned = true
end)

RegisterNetEvent('dbfw-apartments:client:LastLocationHouse')
AddEventHandler('dbfw-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
    ClosestHouse = apartmentType
    EnterApartment(apartmentType, apartmentId, false)
end)

RegisterNetEvent('apartments:client:SetHomeBlip')
AddEventHandler('apartments:client:SetHomeBlip', function(home)
    Citizen.CreateThread(function()
        SetClosestApartment()
        for name, apartment in pairs(Apartments.Locations) do
            RemoveBlip(Apartments.Locations[name].blip)

            Apartments.Locations[name].blip = AddBlipForCoord(Apartments.Locations[name].coords.enter.x, Apartments.Locations[name].coords.enter.y, Apartments.Locations[name].coords.enter.z)
            if (name == home) then
                SetBlipSprite(Apartments.Locations[name].blip, 350)
            else
                SetBlipSprite(Apartments.Locations[name].blip, 476)
            end
            SetBlipDisplay(Apartments.Locations[name].blip, 4)
            SetBlipScale(Apartments.Locations[name].blip, 0.65)
            SetBlipAsShortRange(Apartments.Locations[name].blip, true)
            SetBlipColour(Apartments.Locations[name].blip, 4)
    
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Apartments.Locations[name].label)
            EndTextCommandSetBlipName(Apartments.Locations[name].blip)
        end
    end)
end)

RegisterNetEvent('apartments:client:RingDoor')
AddEventHandler('apartments:client:RingDoor', function(player, house)
    CurrentDoorBell = player
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    TriggerEvent('DoLongHudText', ('Someone is knocking on the door!'), 2)
end)

function EnterApartment(house, apartmentId, new)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    openHouseAnim()
    Citizen.Wait(250)
    DBFWCore.TriggerServerCallback('apartments:GetApartmentOffset', function(offset)
        if offset == nil or offset == 0 then
            DBFWCore.TriggerServerCallback('apartments:GetApartmentOffsetNewOffset', function(newoffset)
                if newoffset > 230 then
                    newoffset = 210
                end
                CurrentOffset = newoffset
                TriggerServerEvent("apartments:server:AddObject", apartmentId, house, CurrentOffset)
                
                local coords = { x = Apartments.Locations[house].coords.enter.x, y = Apartments.Locations[house].coords.enter.y, z = Apartments.Locations[house].coords.enter.z - CurrentOffset}
                data = exports['dbfw-interior']:CreateApartmentFurnished(coords)
                Citizen.Wait(100)
                houseObj = data[1]
                POIOffsets = data[2]

                InApartment = true
                CurrentApartment = apartmentId
                ClosestHouse = house
                rangDoorbell = nil
                
                Citizen.Wait(500)
                SetRainFxIntensity(0.0)
                TriggerEvent('dbfw-weathersync:client:DisableSync')
                Citizen.Wait(100)
                SetWeatherTypePersist('EXTRASUNNY')
                SetWeatherTypeNow('EXTRASUNNY')
                SetWeatherTypeNowPersist('EXTRASUNNY')
                NetworkOverrideClockTime(23, 0, 0)
                

                TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
            end, house)
        else
            if offset > 230 then
                offset = 210
            end
            CurrentOffset = offset
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
            TriggerServerEvent("apartments:server:AddObject", apartmentId, house, CurrentOffset)
            local coords = { x = Apartments.Locations[ClosestHouse].coords.enter.x, y = Apartments.Locations[ClosestHouse].coords.enter.y, z = Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset}
            data = exports['dbfw-interior']:CreateApartmentFurnished(coords)
            
            Citizen.Wait(100)
            houseObj = data[1]
            POIOffsets = data[2]

            InApartment = true
            CurrentApartment = apartmentId
            
            Citizen.Wait(500)
            SetRainFxIntensity(0.0)
            TriggerEvent('dbfw-weathersync:client:DisableSync')
            Citizen.Wait(100)
            SetWeatherTypePersist('EXTRASUNNY')
            SetWeatherTypeNow('EXTRASUNNY')
            SetWeatherTypeNowPersist('EXTRASUNNY')
            NetworkOverrideClockTime(23, 0, 0)

            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
        end
        if new ~= nil then
            if new then
                TriggerEvent('dbfw-interior:client:SetNewState', true)
            else
                TriggerEvent('dbfw-interior:client:SetNewState', false)
            end
        else
            TriggerEvent('dbfw-interior:client:SetNewState', false)
        end
    end, apartmentId)
end

DrawText3D = function(x, y, z, text)
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

function LeaveApartment(house)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    openHouseAnim()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    exports['dbfw-interior']:DespawnInterior(houseObj, function()
        TriggerEvent('dbfw-weathersync:client:EnableSync')
        SetEntityCoords(GetPlayerPed(-1), Apartments.Locations[house].coords.enter.x, Apartments.Locations[house].coords.enter.y,Apartments.Locations[house].coords.enter.z)
        SetEntityHeading(GetPlayerPed(-1), Apartments.Locations[house].coords.enter.h)
        Citizen.Wait(1000)
        TriggerServerEvent("apartments:server:RemoveObject", CurrentApartment, house)
        CurrentApartment = nil
        InApartment = false
        CurrentOffset = 0
        DoScreenFadeIn(1000)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
    end)
end

function SetClosestApartment()
    local pos = GetEntityCoords(GetPlayerPed(-1), true)
    local current = nil
    local dist = nil

    for id, house in pairs(Apartments.Locations) do
        if current ~= nil then
            if(GetDistanceBetweenCoords(pos, Apartments.Locations[id].coords.enter.x, Apartments.Locations[id].coords.enter.y, Apartments.Locations[id].coords.enter.z, true) < dist)then
                current = id
                dist = GetDistanceBetweenCoords(pos, Apartments.Locations[id].coords.enter.x, Apartments.Locations[id].coords.enter.y, Apartments.Locations[id].coords.enter.z, true)
            end
        else
            dist = GetDistanceBetweenCoords(pos, Apartments.Locations[id].coords.enter.x, Apartments.Locations[id].coords.enter.y, Apartments.Locations[id].coords.enter.z, true)
            current = id
        end
    end
    if current ~= ClosestHouse  and not InApartment then
        ClosestHouse = current
        DBFWCore.TriggerServerCallback('apartments:IsOwner', function(result)
            IsOwned = result
        end, ClosestHouse)
    end
end

function openHouseAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(400)
    ClearPedTasks(GetPlayerPed(-1))
end

function MenuOwners()
    ped = GetPlayerPed(-1);
    MenuTitle = "Owners"
    ClearMenu()
    Menu.addButton("Zil", "OwnerList", nil)
    Menu.addButton("Kapat", "closeMenuFull", nil) 
end

function OwnerList()
    DBFWCore.TriggerServerCallback('apartments:GetAvailableApartments', function(apartments)
        ped = GetPlayerPed(-1);
        MenuTitle = "Kapi zilini cal: "
        ClearMenu()

        if apartments == nil then
            TriggerEvent('DoLongHudText', ('There is no one..'), 1)
            closeMenuFull()
        else
            for k, v in pairs(apartments) do
                Menu.addButton(v, "RingDoor", k) 
            end
        end
        Menu.addButton("Geri", "MenuOwners",nil)
    end, ClosestHouse)
end

function RingDoor(apartmentId)
    rangDoorbell = ClosestHouse
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    TriggerServerEvent("apartments:server:RingDoor", apartmentId, ClosestHouse)
end

function MenuOutfits()
    ped = GetPlayerPed(-1);
    MenuTitle = "Clothing"
    ClearMenu()
    Menu.addButton("Kıyafetler", "OutfitsLijst", nil)
    Menu.addButton("Kapat", "closeMenuFull", nil) 
end

function changeOutfit()
	Wait(200)
    loadAnimDict("clothingshirt")    	
	TaskPlayAnim(GetPlayerPed(-1), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Wait(3100)
	TaskPlayAnim(GetPlayerPed(-1), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function OutfitsLijst()
    DBFWCore.TriggerServerCallback('apartments:GetOutfits', function(outfits)
        ped = GetPlayerPed(-1);
        MenuTitle = "Clothing :"
        ClearMenu()

        if outfits == nil then
            TriggerEvent('DoLongHudText', ('You have no clothes..'), 1)
            closeMenuFull()
        else
            for k, v in pairs(outfits) do
                Menu.addButton(outfits[k].outfitname, "optionMenu", outfits[k]) 
            end
        end
        Menu.addButton("Geri", "MenuOutfits",nil)
    end)
end

function optionMenu(outfitData)
    ped = GetPlayerPed(-1);
    MenuTitle = "Ne var?"
    ClearMenu()

    Menu.addButton("Kıyafet Sec", "selectOutfit", outfitData) 
    Menu.addButton("Kıyafet Sil", "removeOutfit", outfitData) 
    Menu.addButton("Geri", "OutfitsLijst",nil)
end

function selectOutfit(oData)
    TriggerServerEvent('clothes:selectOutfit', oData.model, oData.skin)
    TriggerEvent('DoLongHudText', (oData.outfitname..' Selected'), 1)
    closeMenuFull()
    changeOutfit()
end

function removeOutfit(oData)
    TriggerServerEvent('clothes:removeOutfit', oData.outfitname)
    TriggerEvent('DoLongHudText', (oData.outfitname..' deleted'), 1)
    closeMenuFull()
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

imClosesToRoom3 = function()
    local ply = PlayerPedId()
    if showClothing then
      return true
    else
      return false
    end
  end