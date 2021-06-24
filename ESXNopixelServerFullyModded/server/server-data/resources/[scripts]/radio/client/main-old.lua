DBWF = nil
local PlayerData                = {}

Citizen.CreateThread(function()
  while DBWF == nil do
    TriggerEvent('dbfw:getSharedObject', function(obj) DBWF = obj end)
    Citizen.Wait(0)
  end
  while DBWF.GetPlayerData().job == nil do
		Citizen.Wait(10)
  end
  PlayerData = DBWF.GetPlayerData()
end)

RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
  PlayerData.job = job
end)

-- Disable controls while GUI open

local GuiOpened = false

RegisterNetEvent('radioGui')
AddEventHandler('radioGui', function()
  openGui()
end)

RegisterNetEvent('ChannelSet')
AddEventHandler('ChannelSet', function(chan)
  SendNUIMessage({set = true, setChannel = chan})
end)

RegisterNetEvent('radio:resetNuiCommand')
AddEventHandler('radio:resetNuiCommand', function()
    SendNUIMessage({reset = true})
end)

function openGui()
  local radio = hasRadio()
  local incall = exports["isPed"]:isPed("incall")
  if (incall) then
    TriggerEvent("DoShortHudText","You can not do that while in a call!",2)
    return
  end
  local job = DBWF.GetPlayerData().job.name
  local Emergency = false
  if job == "police" then
    Emergency = true
  elseif job == "ambulance" then
    Emergency = true
  end
  
  if not GuiOpened and radio then
    GuiOpened = true
    SetNuiFocus(false,false)
    SetNuiFocus(true,true)
    SendNUIMessage({open = true, jobType = Emergency})
  else
    GuiOpened = false
    SetNuiFocus(false,false)
    SendNUIMessage({open = false, jobType = Emergency})
  end
  TriggerEvent("animation:radio",GuiOpened)
  TriggerEvent("InteractSound_CL:PlayOnOne","radioon",0.6)
end

function hasRadio()
  if exports["dbfw-inventory"]:hasEnoughOfItem("radio",1,false) then
    return true
  else
    return false
  end
end

RegisterNUICallback('click', function(data, cb)
  PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end)

RegisterNUICallback('volumeUp', function(data, cb)
  TriggerEvent("TokoVoip:UpVolume")
end)

RegisterNUICallback('volumeDown', function(data, cb)
  TriggerEvent("TokoVoip:DownVolume")
end)
RegisterNUICallback('cleanClose', function(data, cb)
  TriggerEvent("InteractSound_CL:PlayOnOne","radioon",0.6)
  GuiOpened = false
  SetNuiFocus(false,false)
  SendNUIMessage({open = false})
  TriggerEvent("animation:radio",GuiOpened)
  print("removing all radios")
end)

RegisterNUICallback('poweredOn', function(data, cb)
  TriggerEvent("InteractSound_CL:PlayOnOne","radioon",0.6)
  local fuckingidiot = tonumber(data.channel)
  if fuckingidiot == nil then
    fuckingidiot = 0
  end
  local newChannel = fuckingidiot

  if fuckingidiot < 10 and fuckingidiot > 0 then
    newChannel = fuckingidiot
  end
  

  if newChannel == 0 then
    --TriggerServerEvent("TokoVoip:removePlayerFromAllRadio",GetPlayerServerId(PlayerId()))
  else
    --TriggerServerEvent("TokoVoip:addPlayerToRadio", newChannel, GetPlayerServerId(PlayerId()))
    TriggerServerEvent("TokoVoip:addPlayerToRadio", newChannel, GetPlayerServerId(PlayerId()))
  end
end)

RegisterNUICallback('poweredOff', function(data, cb)
  TriggerEvent("InteractSound_CL:PlayOnOne","radiooff",0.6)
  TriggerServerEvent("TokoVoip:removePlayerFromAllRadio", GetPlayerServerId(PlayerId()))
end)

RegisterNUICallback('close', function(data, cb)
  TriggerEvent("InteractSound_CL:PlayOnOne","radiooff",0.6)
  local fuckingidiot = tonumber(data.channel)
  if fuckingidiot == nil then
    fuckingidiot = 0
  end
  local newChannel = fuckingidiot

  if fuckingidiot < 10 and fuckingidiot > 0 then
    newChannel = fuckingidiot
  end
  

  if newChannel == 0 then
    TriggerEvent('DoLongHudText', 'Encrypted Channel', 2)
    TriggerServerEvent("TokoVoip:removePlayerFromAllRadio", GetPlayerServerId(PlayerId()))
  else
    TriggerServerEvent("TokoVoip:addPlayerToRadio", newChannel, GetPlayerServerId(PlayerId()))
  end

  GuiOpened = false
  SetNuiFocus(false,false)
  SendNUIMessage({open = false})
  TriggerEvent("animation:radio",GuiOpened)
end)


RegisterNetEvent('animation:radio')
AddEventHandler('animation:radio', function(enable)
  TriggerEvent("destroyPropRadio")
  local lPed = PlayerPedId()
  inPhone = enable

  RequestAnimDict("cellphone@")
  while not HasAnimDictLoaded("cellphone@") do
    Citizen.Wait(0)
  end

  local intrunk = exports["isPed"]:isPed("intrunk")
  if not intrunk then
    TaskPlayAnim(lPed, "cellphone@", "cellphone_text_in", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
  end
  Citizen.Wait(300)
  if inPhone then
    TriggerEvent("attachItemRadio","radio01")
    Citizen.Wait(150)
    while inPhone do

      local dead = exports["isPed"]:isPed("dead")
      if dead then
        closeGui()
        inPhone = false
      end
      local intrunk = exports["isPed"]:isPed("intrunk")
      if not intrunk and not IsEntityPlayingAnim(lPed, "cellphone@", "cellphone_text_read_base", 3) and not IsEntityPlayingAnim(lPed, "cellphone@", "cellphone_swipe_screen", 3) then
        TaskPlayAnim(lPed, "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
      end    
      Citizen.Wait(1)
    end
    local intrunk = exports["isPed"]:isPed("intrunk")
    if not intrunk then
      ClearPedTasks(PlayerPedId())
    end
  else
    local intrunk = exports["isPed"]:isPed("intrunk")
    if not intrunk then
      Citizen.Wait(100)
      ClearPedTasks(PlayerPedId())
      TaskPlayAnim(lPed, "cellphone@", "cellphone_text_out", 2.0, 1.0, 5.0, 49, 0, 0, 0, 0)
      Citizen.Wait(400)
      TriggerEvent("destroyPropRadio")
      Citizen.Wait(400)
      ClearPedTasks(PlayerPedId())
    else
      TriggerEvent("destroyPropRadio")
    end
  end
  TriggerEvent("destroyPropRadio")
end)


Citizen.CreateThread(function()

  while true do
    if GuiOpened then
      Citizen.Wait(1)
      DisableControlAction(0, 1, GuiOpened) -- LookLeftRight
      DisableControlAction(0, 2, GuiOpened) -- LookUpDown
      DisableControlAction(0, 14, GuiOpened) -- INPUT_WEAPON_WHEEL_NEXT
      DisableControlAction(0, 15, GuiOpened) -- INPUT_WEAPON_WHEEL_PREV
      DisableControlAction(0, 16, GuiOpened) -- INPUT_SELECT_NEXT_WEAPON
      DisableControlAction(0, 17, GuiOpened) -- INPUT_SELECT_PREV_WEAPON
      DisableControlAction(0, 99, GuiOpened) -- INPUT_VEH_SELECT_NEXT_WEAPON
      DisableControlAction(0, 100, GuiOpened) -- INPUT_VEH_SELECT_PREV_WEAPON
      DisableControlAction(0, 115, GuiOpened) -- INPUT_VEH_FLY_SELECT_NEXT_WEAPON
      DisableControlAction(0, 116, GuiOpened) -- INPUT_VEH_FLY_SELECT_PREV_WEAPON
      DisableControlAction(0, 142, GuiOpened) -- MeleeAttackAlternate
      DisableControlAction(0, 106, GuiOpened) -- VehicleMouseControlOverride
    else
      Citizen.Wait(20)
    end    
  end
end)