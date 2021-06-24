local hasBeenUnlocked = {}
local vehicleHotwired = {}
local gotKeys = false
local failedAttempt = {}
local vehicleSearched = {}
local disableH = false
local showText = true
local hasKilledNPC = false
local useLockpick = false
local vehicleBlacklist = {
 ['BMX'] = true,
 ['CRUISER'] = true,
 ['FIXTER'] = true,
 ['SCORCHER'] = true,
 ['TRIBIKE'] = true,
 ['TRIBIKE2'] = true,
 ['TRIBIKE3'] = true,
 ['FLATBED'] = true,
 ['BOXVILLE2'] = true,
 ['BENSON'] = true,
 ['PHANTOM'] = true,
 ['RUBBLE'] = true,
 ['RUMPO'] = true,
 ['YOUGA2'] = true,
 ['BOXVILLE'] = true,
 ['TAXI'] = true,
 ['DINGHY'] = true
 }

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

 DBFWCore = nil

 Citizen.CreateThread(function()
  while DBFWCore == nil do
      TriggerEvent('dbfw:getSharedObject', function(obj)
          DBFWCore = obj
      end)
      Citizen.Wait(0)
  end

  while DBFWCore.GetPlayerData().job == nil do
      Citizen.Wait(10)
  end

  DBFWCore.PlayerData = DBFWCore.GetPlayerData()
end)

Citizen.CreateThread(function()
 while true do
  Citizen.Wait(5)


  if IsPedInAnyVehicle(PlayerPedId(), false) then
   local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
   local plate = GetVehicleNumberPlateText(vehicle)

   if IsControlJustPressed(0, 47) and GetLastInputMethod(2) then
    if not vehicleSearched[plate] and not hasVehicleKey(plate) and showText and not vehicleHotwired[plate] and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
     showText = false
      exports["dbfw-taskbar"]:taskBar(10000, "Searching Vehicle")
      vehicleSearched[plate] = true
      if not hasVehicleKey(plate) then
       TriggerServerEvent('garage:searchItem', plate)
       showText = true
      end
    elseif vehicleSearched[plate]  then
     TriggerEvent('DoLongHudText', 'You have already searched this vehicle', 1)
    end
   end
  end


  if disableF then
   DisableControlAction(0, 23, true)
  end

  if disableH then
   DisableControlAction(0, 74, true)
   DisableControlAction(0, 47, true)
  end
 end
end)

Citizen.CreateThread(function()
    while true do
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
            local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local pedd = GetPedInVehicleSeat(veh, -1)

            if DoesEntityExist(pedd) and not IsPedAPlayer(pedd) and not IsEntityDead(pedd) then
             SetVehicleDoorsLocked(veh, 2)
             SetPedCanBeDraggedOut(pedd, false)
             TaskVehicleMissionPedTarget(pedd, veh, PlayerPedId(), 8, 50.0, 790564, 300.0, 15.0, 1)
             disableF = true
             Wait(1500)
             disableF = false
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('vehicle:start')
AddEventHandler('vehicle:start', function()
 local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
 SetVehicleEngineOn(vehicle, true, true)
end)

Citizen.CreateThread(function()
 while true do
  Citizen.Wait(5)

  if not IsPedInAnyVehicle(PlayerPedId(), false) then
   showText = true


   -- Exiting
   local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
   if aiming then
    if DoesEntityExist(targetPed) and not IsPedAPlayer(targetPed) and IsPedArmed(PlayerPedId(), 7) then
     local vehicle = GetVehiclePedIsIn(targetPed, false)
     local plate = GetVehicleNumberPlateText(vehicle)
     local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), true), GetEntityCoords(vehicle, true), false)
     local playerped = PlayerPedId()
     local targetVehicle = GetVehiclePedIsUsing(playerped)

     if distance < 10 and IsPedFacingPed(targetPed, PlayerPedId(), 60.0) then
     
     SetVehicleForwardSpeed(vehicle, 0)

     hasBeenUnlocked[plate] = false

     SetVehicleForwardSpeed(vehicle, 0)
     TaskLeaveVehicle(targetPed, vehicle, 256)

     while IsPedInAnyVehicle(targetPed, false) do
      Citizen.Wait(5)
     end

     RequestAnimDict('missfbi5ig_22')
     RequestAnimDict('mp_common')

     SetPedDropsWeaponsWhenDead(targetPed,false)
     ClearPedTasks(targetPed)
     TaskTurnPedToFaceEntity(targetPed, GetPlayerPed(-1), 3.0)
     TaskSetBlockingOfNonTemporaryEvents(targetPed, true)
     SetPedFleeAttributes(targetPed, 0, 0)
     SetPedCombatAttributes(targetPed, 17, 1)
     SetPedSeeingRange(targetPed, 0.0)
     SetPedHearingRange(targetPed, 0.0)
     SetPedAlertness(targetPed, 0)
     SetPedKeepTask(targetPed, true)
     TriggerEvent("dbfw-dispatch:carjacking")
     TaskPlayAnim(targetPed, "missfbi5ig_22", "hands_up_anxious_scientist", 8.0, -8, -1, 12, 1, 0, 0, 0)
     Wait(1500)
     TaskPlayAnim(targetPed, "missfbi5ig_22", "hands_up_anxious_scientist", 8.0, -8, -1, 12, 1, 0, 0, 0)
     Wait(2500)

     local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId(), true), GetEntityCoords(vehicle, true), false)

     if not IsEntityDead(targetPed) and distance < 12 then
      hasBeenUnlocked[plate] = true
      TaskPlayAnim(targetPed, "mp_common", "givetake1_a", 8.0, -8, -1, 12, 1, 0, 0, 0)
      Wait(750)
      TriggerEvent('DoLongHudText', 'You have been handed the keys!', 1)
      TriggerServerEvent('garage:addKeys', plate)
      Citizen.Wait(500)
      TaskReactAndFleePed(targetPed, GetPlayerPed(-1))
      SetPedKeepTask(targetPed, true)
      Wait(2500)
      TaskReactAndFleePed(targetPed, GetPlayerPed(-1))
      SetPedKeepTask(targetPed, true)
      Wait(2500)
      TaskReactAndFleePed(targetPed, GetPlayerPed(-1))
      SetPedKeepTask(targetPed, true)
      Wait(2500)
      TaskReactAndFleePed(targetPed, GetPlayerPed(-1))
      SetPedKeepTask(targetPed, true)
      end
     end
    end
   end
  end
 end
end)


Citizen.CreateThread(function()
 while true do
  Citizen.Wait(5)

  if IsPedShooting(PlayerPedId()) then
   hasKilledNPC = true
  end

  if IsPedInAnyVehicle(PlayerPedId(), false) then
   local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
   local plate = GetVehicleNumberPlateText(vehicle)

   if DoesEntityExist(vehicle) and not hasVehicleKey(plate) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not vehicleHotwired[plate] and not vehicleBlacklist[GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))] then
    while not IsPedInAnyVehicle(PlayerPedId(), false) do
     Citizen.Wait(5)
    end

    SetVehicleEngineOn(vehicle, false, false)

    if showText then
     local pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 2.0, 1.0)
     DrawText3Ds(pos["x"],pos["y"],pos["z"], "[G] Search/[H] Hotwire" )
    end

    if IsControlJustPressed(0, 74) and showText and GetLastInputMethod(2) then
     if not failedAttempt[plate] and not vehicleSearched[plate] and not vehicleHotwired[plate] then
      if math.random(1, 10) <= 6 then
          SetVehicleAlarm(vehicle, true)
          StartVehicleAlarm(vehicle)
          SetVehicleAlarmTimeLeft(vehicle, 60000)
      end
       TriggerEvent('animation:hotwire', true)
       showText = false
        exports["dbfw-taskbar"]:taskBar(15000, "Attempting Hotwire")
        TriggerEvent('animation:hotwire', false)
        if math.random(1, 10) <= 5 then
         vehicleHotwired[plate] = true
         SetVehicleEngineOn(vehicle, true, true)
         TriggerEvent('DoLongHudText', 'You successfully hotwired this hotwire', 1)
         showText = true
        else
          TriggerEvent('DoLongHudText', 'You can not work out this hotwire', 2)
         failedAttempt[plate] = true
         showText = true
        end
     elseif failedAttempt[plate] then
      TriggerEvent('DoLongHudText', 'You can not work out this hotwire', 2)
     elseif vehicleHotwired[plate] then
      TriggerEvent('DoLongHudText', 'You can not work out this hotwire', 2)
     else
      TriggerEvent('DoLongHudText', 'You can not work out this hotwire', 2)
     end
    elseif useLockpick then
      if math.random(1, 10) <= 4 then
          SetVehicleAlarm(vehicle, true)
          StartVehicleAlarm(vehicle)
          SetVehicleAlarmTimeLeft(vehicle, 60000)
      end
     useLockpick = false
     TriggerEvent('animation:hotwire', true)
     showText = false

     exports["dbfw-taskbar"]:taskBar(20000, "Modifying Ignition Stage 1")
      Citizen.Wait(500)
     exports["dbfw-taskbar"]:taskBar(20000, "Modifying Ignition Stage 2")
      Citizen.Wait(500)
     exports["dbfw-taskbar"]:taskBar(20000, "Modifying Ignition Stage 3")
      TriggerEvent('animation:hotwire', false)
      vehicleHotwired[plate] = true
      SetVehicleEngineOn(vehicle, true, true)

      local plate = GetVehicleNumberPlateText(vehicle)
      TriggerServerEvent('garage:addKeys', plate)
      TriggerEvent('DoLongHudText', 'ignition Working', 1)
      TriggerEvent('DoLongHudText', 'Engine Started', 1)
      SetVehicleEngineOn(vehicle, true, true)
      showText = true
      SetVehicleEngineOn(vehicle, true, true)
      TriggerServerEvent('removelockpick')
    end
   end
  end
 end
end)



AddEventHandler('vehicle:setUnlocked', function(plate)
 hasBeenUnlocked[plate] = true
end)



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



Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsControlJustReleased(0, Keys['L']) then
      ToggleLocks()
    end
  end
end)
-- Giving Vehicle Keys
function ToggleLocks()
 local ped = PlayerPedId()
 local coords = GetEntityCoords(ped)
 local vehicle
 if IsPedInAnyVehicle(ped, false) then vehicle = GetVehiclePedIsIn(ped, false) else vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71) end
 if DoesEntityExist(vehicle) then
  Citizen.CreateThread(function()
   if hasVehicleKey(GetVehicleNumberPlateText(vehicle)) then
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
     playLockAnimation()
     if GetVehicleDoorLockStatus(vehicle) == 1 then
      SetVehicleDoorsLocked(vehicle, 2)
     TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "lock", 0.4)
     TriggerEvent('DoLongHudText', 'Vehicle Locked', 2)
 
     elseif GetVehicleDoorLockStatus(vehicle) == 2 then
     TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "unlock", 0.4)
     TriggerEvent('DoLongHudText', 'Vehicle Unlocked', 1)
      SetVehicleDoorsLocked(vehicle, 1)
     end
     SetVehicleEngineOn(vehicle, true, true, true)
     SetVehicleLights(vehicle, 2) Wait(200) SetVehicleLights(vehicle, 1) Wait(200) SetVehicleLights(vehicle, 2) Wait(200) SetVehicleLights(vehicle, 1)
     SetVehicleEngineOn(vehicle, false, false, false)
     SetVehicleLights(vehicle, 0)
    end
   end
  end)
 else
  TriggerEvent('DoLongHudText', 'No Vehicle Found', 2)
 end
end

function playLockAnimation()
 if not IsPedInAnyVehicle(PlayerPedId(), false) then
  RequestAnimDict('anim@heists@keycard@')
  ClearPedSecondaryTask(PlayerPedId())
  TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
  Citizen.Wait(850)
  ClearPedTasks(PlayerPedId())
 end
end


RegisterCommand('givekey', function(args, source)
  local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
  local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 100.0, 0.0)
  local latestveh = getVehicleInDirection(coordA, coordB)

  if latestveh == nil or not DoesEntityExist(latestveh) then
    TriggerEvent('DoLongHudText', 'no vehicle found', 2)
    return
  end

  if not hasVehicleKey(GetVehicleNumberPlateText(latestveh)) then
    TriggerEvent('DoLongHudText', 'No keys for target vehicle', 1)
      return
  end

  if GetDistanceBetweenCoords(GetEntityCoords(latestveh), GetEntityCoords(GetPlayerPed(-1), 0)) > 5 then
    TriggerEvent('DoLongHudText', 'You are to far away from the vehicle', 1)
    return
  end

  t, distance = GetClosestPlayer()
  if(distance ~= -1 and distance < 5) then
    TriggerServerEvent('garage:giveKey', GetPlayerServerId(t), GetVehicleNumberPlateText(latestveh))
    TriggerEvent('DoLongHudText', 'You just gave keys to your vehicle!', 1)
  else
    TriggerEvent('DoLongHudText', 'No player near you', 2)
  end
end)

RegisterNetEvent('hotwire:giveKey')
AddEventHandler('hotwire:giveKey', function(args, source)
  local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
  local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 100.0, 0.0)
  local latestveh = getVehicleInDirection(coordA, coordB)

  if latestveh == nil or not DoesEntityExist(latestveh) then
    TriggerEvent('DoLongHudText', 'No vehicle found', 2)
    return
  end

  if not hasVehicleKey(GetVehicleNumberPlateText(latestveh)) then
    TriggerEvent('DoLongHudText', 'No keys for target vehicle', 1)
      return
  end

  if GetDistanceBetweenCoords(GetEntityCoords(latestveh), GetEntityCoords(GetPlayerPed(-1), 0)) > 5 then
    TriggerEvent('DoLongHudText', 'You ate to far away from the vehicle', 2)
    return
  end

  t, distance = GetClosestPlayer()
  if(distance ~= -1 and distance < 5) then
    TriggerServerEvent('garage:giveKey', GetPlayerServerId(t), GetVehicleNumberPlateText(latestveh))
    TriggerEvent('DoLongHudText', 'You just gave keys to your vehicle', 1)
  else
    TriggerEvent('DoLongHudText', 'No player near you', 2)
  end
end)


function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

function getVehicleInDirection(coordFrom, coordTo)
  local offset = 0
  local rayHandle
  local vehicle

  for i = 0, 100 do
    rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, GetPlayerPed(-1), 0)
    a, b, c, d, vehicle = GetRaycastResult(rayHandle)

    offset = offset - 1

    if vehicle ~= 0 then break end
  end

  local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))

  if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

local disable = false

RegisterNetEvent('animation:hotwire')
AddEventHandler('animation:hotwire', function(disable)
 local lPed = GetPlayerPed(-1)
 ClearPedTasks(lPed)
   ClearPedSecondaryTask(lPed)

 RequestAnimDict("mini@repair")
 while not HasAnimDictLoaded("mini@repair") do
  Citizen.Wait(0)
 end
 if disable ~= nil then
  if not disable then
   lockpicking = false
   return
  else
   lockpicking = true
  end
 end
 while lockpicking do

  if not IsEntityPlayingAnim(lPed, "mini@repair", "fixing_a_player", 3) then
   ClearPedSecondaryTask(lPed)
   TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
  end
  Citizen.Wait(1)
 end
 ClearPedTasks(lPed)
end)

-- Start stealing a car
local isLockpicking = false


RegisterNetEvent('lockpick:vehicleUse')
AddEventHandler('lockpick:vehicleUse', function()

 local coords = GetEntityCoords(GetPlayerPed(-1))
 local vehicle = nil
 if IsPedInAnyVehicle(PlayerPedId(), false) then
  vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
 else
  vehicle = GetClosestVehicle(coords, 8.0, 0, 70)
 end

  if DoesEntityExist(vehicle) then
   if not IsPedInAnyVehicle(PlayerPedId(), false) then
    if GetVehicleDoorLockStatus(vehicle) ~= 1 then
     RequestAnimDict("mini@repair")
     while not HasAnimDictLoaded("mini@repair") do
   	  Citizen.Wait(0)
     end

     TriggerEvent('carLockpickAnim')

     Citizen.CreateThread(function()
      exports["dbfw-taskbar"]:taskBar(20000, "Lockpicking Vehicle")
       isLockpicking = false
       SetVehicleDoorsLocked(vehicle, 1)
       SetVehicleDoorsLockedForAllPlayers(vehicle, false)
       hasBeenUnlocked[GetVehicleNumberPlateText(vehicle)] = true
       TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "lock", 0.1)
       TriggerEvent('DoLongHudText', 'vehicle unlocked', 1)
       SetVehicleEngineOn(vehicle, true, true, true)
       SetVehicleLights(vehicle, 2) Wait(200)
       SetVehicleLights(vehicle, 1) Wait(200)
       SetVehicleLights(vehicle, 2) Wait(200)
       SetVehicleLights(vehicle, 1) Wait(200)
       ClearPedTasksImmediately(GetPlayerPed(-1))
       Citizen.Wait(500)
       SetVehicleDoorsLocked(vehicle, 1)
       TaskEnterVehicle(GetPlayerPed(-1), vehicle, 10.0, -1, 16, 1, 0)
       TriggerServerEvent('removelockpick')
     end)
    end
   else
    local plate = GetVehicleNumberPlateText(vehicle)
    if failedAttempt[plate] or vehicleHotwired[plate] or vehicleSearched[plate] or hasVehicleKey(plate) then
     TriggerEvent('DoLongHudText', 'You can not work out this hotwire', 1)
    else
     useLockpick = true
    end
   end
 end
end)





AddEventHandler('carLockpickAnim', function()
 isLockpicking = true
 loadAnimDict('veh@break_in@0h@p_m_one@')
 while isLockpicking do
  if not IsEntityPlayingAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3) then
   TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 1, 0.0, 0, 0, 0)
   Citizen.Wait(1500)
   ClearPedTasks(PlayerPedId())
  end
  Citizen.Wait(1)
 end
 ClearPedTasks(PlayerPedId())
end)


function loadAnimDict(dict)
 RequestAnimDict(dict)
 while not HasAnimDictLoaded(dict) do
  Citizen.Wait(5)
 end
end


Citizen.CreateThread(function()
 while true do
  Citizen.Wait(50)
  if GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)) ~= nil and GetVehiclePedIsTryingToEnter(GetPlayerPed(-1)) ~= 0 and not gotKeys then
   local curveh = GetVehiclePedIsTryingToEnter(GetPlayerPed(-1))
   local plate1 = GetVehicleNumberPlateText(curveh)
   if not hasVehicleKey(GetVehicleNumberPlateText(curveh)) then
    local pedDriver = GetPedInVehicleSeat(curveh, -1)
    if DoesEntityExist(pedDriver) and IsEntityDead(pedDriver) and not IsPedAPlayer(pedDriver) and not hasVehicleKey(GetVehicleNumberPlateText(curveh)) and hasKilledNPC then
      TriggerEvent("dbfw-dispatch:carjacking")
     hasKilledNPC = false
     gotKeys = true
     Wait(500)
     TriggerEvent("dbfw-dispatch:carjacking")
     exports["dbfw-taskbar"]:taskBar(2000, "Taking Keys")
      TriggerServerEvent('garage:addKeys', plate1)
      Wait(10000)
      TriggerEvent("dbfw-dispatch:carjacking")
      gotKeys = false
    end
   end
  end
 end
end)


local vehicleKeys = {}
local myCharacterID = 0

RegisterNetEvent("garage:updateKeys")
AddEventHandler("garage:updateKeys", function(data, char_id)
 vehicleKeys = data
 myCharacterID = char_id
end)

function hasVehicleKey(plate)
 if vehicleKeys[plate] ~= nil then
  for id,v in pairs(vehicleKeys[plate]) do
   if v.id == myCharacterID then
    return true
   end
  end
 else
  return false
 end
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    local playerPed = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(playerPed)
    local plate = GetVehicleNumberPlateText(vehicle)
    if IsControlJustPressed(1, 244) and IsPedInAnyVehicle(PlayerPedId(), false) then
      if vehicleKeys[plate] == nil then
        DBFWCore.TriggerServerCallback('dbfw-keys:checkOwner', function(owner)
          if owner then
            exports["dbfw-taskbar"]:taskBar(3000, "Taking Keys")
              vehicleKeys[plate] = {}
              vehicleHotwired[plate] = true
              SetVehicleEngineOn(vehicle, true, true)
              TriggerServerEvent('garage:addKeys', plate)
              TriggerEvent('vehicle:start')
              TriggerEvent('DoLongHudText', 'you took your keys', 1)
          else
            TriggerEvent('DoLongHudText', 'failed to find keys', 2)
          end
        end, plate)
      end
    end
  end
end)