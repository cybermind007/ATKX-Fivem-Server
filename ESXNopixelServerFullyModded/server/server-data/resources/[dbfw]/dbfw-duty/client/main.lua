local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}


--- action functions
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil


local GUI = {}
DBFWCore                           = nil
GUI.Time                      = 0
local PlayerData              = {}

Citizen.CreateThread(function ()
  while DBFWCore == nil do
    TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
    Citizen.Wait(0)
 	PlayerData = DBFWCore.GetPlayerData()
  end
end)

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
  PlayerData.job = job
end)

----markers
AddEventHandler('dbfw-duty:hasEnteredMarker', function (zone)
  if zone == 'AmbulanceDuty' then
    CurrentAction     = 'ambulance_duty'
    CurrentActionMsg  = _U('duty')
    CurrentActionData = {}
  end
  if zone == 'DOJDuty' then
    CurrentAction     = 'doj_duty'
    CurrentActionMsg  = _U('duty')
    CurrentActionData = {}
  end
  if zone == 'PoliceDuty' then
    CurrentAction     = 'police_duty'
    CurrentActionMsg  = _U('duty')
    CurrentActionData = {}
  end
end)

AddEventHandler('dbfw-duty:hasExitedMarker', function (zone)
  CurrentAction = nil
end)


--keycontrols
Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)

      local playerPed = GetPlayerPed(-1)

    if CurrentAction ~= nil then

      if IsControlPressed(0, Keys['E']) then
        if CurrentAction == 'ambulance_duty' then
          if PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'offambulance' then
            TriggerServerEvent('duty:ambulance')
          if PlayerData.job.name == 'ambulance' then
            TriggerEvent("DoLongHudText", "Off-Duty 10-42", 1)
            TriggerServerEvent("TokoVoip:removePlayerFromAllRadio",GetPlayerServerId(PlayerId()))
            Wait(1000)
          else
            TriggerEvent("DoLongHudText", "On-Duty 10-41", 1)
            TriggerServerEvent("TokoVoip:addPlayerToRadio", 1.0, GetPlayerServerId(PlayerId()))
            Wait(1000)
          end
        else
          TriggerEvent("DoLongHudText", "You are not part of the Medical Team! Consider joining by applying on the government website", 2)
          Wait(1000)
        end
      end

      if CurrentAction == 'doj_duty' then
          if PlayerData.job.name == 'doj' or PlayerData.job.name == 'offdoj' then
            TriggerServerEvent('duty:doj')
          if PlayerData.job.name == 'doj' then
            TriggerEvent("DoLongHudText", "Off Duty", 1)
            Wait(1000)
          else
            TriggerEvent("DoLongHudText", "On Duty", 1)
            Wait(1000)
          end
        else
          TriggerEvent("DoLongHudText", "You are not part of the Department of Justice! Consider joining by applying on the government website", 2)
          Wait(1000)
        end
      end

        if CurrentAction == 'police_duty' then
          if PlayerData.job.name == 'police' or PlayerData.job.name == 'offpolice' then
            TriggerServerEvent('duty:police')
          if PlayerData.job.name == 'police' then
            TriggerEvent("DoLongHudText", "You have gone off-duty", 1)
            TriggerServerEvent("TokoVoip:removePlayerFromAllRadio",GetPlayerServerId(PlayerId()))
            Wait(1000)
          else
            TriggerEvent("DoLongHudText", "10-41 & Re-Stocked", 1)
            TriggerServerEvent("TokoVoip:addPlayerToRadio", 1.0, GetPlayerServerId(PlayerId()))
            Wait(1000)
          end
        else
          TriggerEvent("DoLongHudText", "You are not part of the Police/Sheriff Department! Consider joining by applying on the government website", 2)
          Wait(1000)
          end
        end
      end
    end
  end       
end)

-- Display markers
Citizen.CreateThread(function ()
  while true do
    Wait(0)

    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k,v in pairs(Config.Zones) do
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        closestString = "Press [E] Go On/Off Duty"
        DBFWCore.Game.Utils.DrawText3D(vector3(v.Pos.x, v.Pos.y, v.Pos.z), closestString, 0.4)
      end
    end
  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function ()
  while true do
    Wait(0)

    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
        isInMarker  = true
        currentZone = k
      end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('dbfw-duty:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('dbfw-duty:hasExitedMarker', LastZone)
    end
  end
end)