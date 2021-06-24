DBFWCore          = nil

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
end)

local currentCallSign = ""
local ped = PlayerPedId()
local isInVehicle = IsPedInAnyVehicle(ped, true)
Citizen.CreateThread( function()
    while true do
        Wait(1000)
        ped = PlayerPedId()
        isInVehicle = IsPedInAnyVehicle(ped, true)
    end
end)
local recipientList = {
  "police", "ambulance"
}

colors = {
  --[0] = "Metallic Black",
  [1] = "Metallic Graphite Black",
  [2] = "Metallic Black Steel",
  [3] = "Metallic Dark Silver",
  [4] = "Metallic Silver",
  [5] = "Metallic Blue Silver",
  [6] = "Metallic Steel Gray",
  [7] = "Metallic Shadow Silver",
  [8] = "Metallic Stone Silver",
  [9] = "Metallic Midnight Silver",
  [10] = "Metallic Gun Metal",
  [11] = "Metallic Anthracite Grey",
  [12] = "Matte Black",
  [13] = "Matte Gray",
  [14] = "Matte Light Grey",
  [15] = "Util Black",
  [16] = "Util Black Poly",
  [17] = "Util Dark silver",
  [18] = "Util Silver",
  [19] = "Util Gun Metal",
  [20] = "Util Shadow Silver",
  [21] = "Worn Black",
  [22] = "Worn Graphite",
  [23] = "Worn Silver Grey",
  [24] = "Worn Silver",
  [25] = "Worn Blue Silver",
  [26] = "Worn Shadow Silver",
  [27] = "Metallic Red",
  [28] = "Metallic Torino Red",
  [29] = "Metallic Formula Red",
  [30] = "Metallic Blaze Red",
  [31] = "Metallic Graceful Red",
  [32] = "Metallic Garnet Red",
  [33] = "Metallic Desert Red",
  [34] = "Metallic Cabernet Red",
  [35] = "Metallic Candy Red",
  [36] = "Metallic Sunrise Orange",
  [37] = "Metallic Classic Gold",
  [38] = "Metallic Orange",
  [39] = "Matte Red",
  [40] = "Matte Dark Red",
  [41] = "Matte Orange",
  [42] = "Matte Yellow",
  [43] = "Util Red",
  [44] = "Util Bright Red",
  [45] = "Util Garnet Red",
  [46] = "Worn Red",
  [47] = "Worn Golden Red",
  [48] = "Worn Dark Red",
  [49] = "Metallic Dark Green",
  [50] = "Metallic Racing Green",
  [51] = "Metallic Sea Green",
  [52] = "Metallic Olive Green",
  [53] = "Metallic Green",
  [54] = "Metallic Gasoline Blue Green",
  [55] = "Matte Lime Green",
  [56] = "Util Dark Green",
  [57] = "Util Green",
  [58] = "Worn Dark Green",
  [59] = "Worn Green",
  [60] = "Worn Sea Wash",
  [61] = "Metallic Midnight Blue",
  [62] = "Metallic Dark Blue",
  [63] = "Metallic Saxony Blue",
  [64] = "Metallic Blue",
  [65] = "Metallic Mariner Blue",
  [66] = "Metallic Harbor Blue",
  [67] = "Metallic Diamond Blue",
  [68] = "Metallic Surf Blue",
  [69] = "Metallic Nautical Blue",
  [70] = "Metallic Bright Blue",
  [71] = "Metallic Purple Blue",
  [72] = "Metallic Spinnaker Blue",
  [73] = "Metallic Ultra Blue",
  [74] = "Metallic Bright Blue",
  [75] = "Util Dark Blue",
  [76] = "Util Midnight Blue",
  [77] = "Util Blue",
  [78] = "Util Sea Foam Blue",
  [79] = "Uil Lightning blue",
  [80] = "Util Maui Blue Poly",
  [81] = "Util Bright Blue",
  [82] = "Matte Dark Blue",
  [83] = "Matte Blue",
  [84] = "Matte Midnight Blue",
  [85] = "Worn Dark blue",
  [86] = "Worn Blue",
  [87] = "Worn Light blue",
  [88] = "Metallic Taxi Yellow",
  [89] = "Metallic Race Yellow",
  [90] = "Metallic Bronze",
  [91] = "Metallic Yellow Bird",
  [92] = "Metallic Lime",
  [93] = "Metallic Champagne",
  [94] = "Metallic Pueblo Beige",
  [95] = "Metallic Dark Ivory",
  [96] = "Metallic Choco Brown",
  [97] = "Metallic Golden Brown",
  [98] = "Metallic Light Brown",
  [99] = "Metallic Straw Beige",
  [100] = "Metallic Moss Brown",
  [101] = "Metallic Biston Brown",
  [102] = "Metallic Beechwood",
  [103] = "Metallic Dark Beechwood",
  [104] = "Metallic Choco Orange",
  [105] = "Metallic Beach Sand",
  [106] = "Metallic Sun Bleeched Sand",
  [107] = "Metallic Cream",
  [108] = "Util Brown",
  [109] = "Util Medium Brown",
  [110] = "Util Light Brown",
  [111] = "Metallic White",
  [112] = "Metallic Frost White",
  [113] = "Worn Honey Beige",
  [114] = "Worn Brown",
  [115] = "Worn Dark Brown",
  [116] = "Worn straw beige",
  [117] = "Brushed Steel",
  [118] = "Brushed Black steel",
  [119] = "Brushed Aluminium",
  [120] = "Chrome",
  [121] = "Worn Off White",
  [122] = "Util Off White",
  [123] = "Worn Orange",
  [124] = "Worn Light Orange",
  [125] = "Metallic Securicor Green",
  [126] = "Worn Taxi Yellow",
  [127] = "police car blue",
  [128] = "Matte Green",
  [129] = "Matte Brown",
  [130] = "Worn Orange",
  [131] = "Matte White",
  [132] = "Worn White",
  [133] = "Worn Olive Army Green",
  [134] = "Pure White",
  [135] = "Hot Pink",
  [136] = "Salmon pink",
  [137] = "Metallic Vermillion Pink",
  [138] = "Orange",
  [139] = "Green",
  [140] = "Blue",
  [141] = "Mettalic Black Blue",
  [142] = "Metallic Black Purple",
  [143] = "Metallic Black Red",
  [144] = "hunter green",
  [145] = "Metallic Purple",
  [146] = "Metaillic V Dark Blue",
  [147] = "MODSHOP BLACK1",
  [148] = "Matte Purple",
  [149] = "Matte Dark Purple",
  [150] = "Metallic Lava Red",
  [151] = "Matte Forest Green",
  [152] = "Matte Olive Drab",
  [153] = "Matte Desert Brown",
  [154] = "Matte Desert Tan",
  [155] = "Matte Foilage Green",
  [156] = "DEFAULT ALLOY COLOR",
  [157] = "Epsilon Blue",
  [158] = "Unknown",
  }
local disableNotifications = false
local disableNotificationSounds = false
RegisterNetEvent('dispatch:toggleNotifications')
AddEventHandler('dispatch:toggleNotifications', function(state)
    state = tostring(state)
    if state == "on" then
        disableNotifications = false
        disableNotificationSounds = false
        TriggerEvent('DoLongHudText', "Dispatch is now enabled.")
    elseif state == "off" then
        disableNotifications = true
        disableNotificationSounds = true
        TriggerEvent('DoLongHudText', "Dispatch is now disabled.")
    elseif state == "mute" then
        disableNotifications = false
        disableNotificationSounds = true
        TriggerEvent('DoLongHudText', "Dispatch is now muted.")
    else
        TriggerEvent('DoLongHudText', "You need to type in 'on', 'off' or 'mute'.")
    end
end)

local function randomizeBlipLocation(pOrigin)
  local x = pOrigin.x
  local y = pOrigin.y
  local z = pOrigin.z
  local luck = math.random(2)
  y = math.random(25) + y
  if luck == 1 then
      x = math.random(25) + x
  end
  return {x = x, y = y, z = z}
end

RegisterCommand('clearblips', function()
  TriggerEvent('clearblipsss')
end, false)

RegisterNetEvent('dispatch:clNotify')
AddEventHandler('dispatch:clNotify', function(pNotificationData)
  local currentJob = DBFWCore.GetPlayerData().job.name
    if pNotificationData ~= nil then
        if pNotificationData.recipientList then
            for key, value in pairs(pNotificationData.recipientList) do
                if key == currentJob and value and not disableNotifications then
                    if pNotificationData.origin ~= nil then
                        if pNotificationData.originStatic == nil or not pNotificationData.originStatic then
                            pNotificationData.origin = randomizeBlipLocation(pNotificationData.origin)
                        else
                            pNotificationData.origin = pNotificationData.origin
                        end
                    end

                    if currentJob ~= "news" then
                        SendNUIMessage({
                            mId = "notification",
                            eData = pNotificationData
                        })
                    elseif currentJob == "news" then
                        if exports["dbfw-inventory"]:getQuantity("scanner") > 0 then
                            local newsObject = {}
                            newsObject.dispatchMessage = "A 911 call has been picked up on your radio scanner!"
                            newsObject.displayCode = nil
                            newsObject.isImportant = false
                            newsObject.priority = 1

                            SendNUIMessage({
                                mId = "notification",
                                eData = newsObject
                            })

                        end
                    end

                    if(pNotificationData.playSound and currentJob ~= "news" and not disableNotificationSounds) then
                        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, pNotificationData.soundName, 0.3)
                    end
                end
            end
        end
    else
        print("I didnt receive any data")
    end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        if (IsControlJustReleased(0, 178) and (DBFWCore.GetPlayerData().job.name == 'ambulance' or DBFWCore.GetPlayerData().job.name == 'police') and not exports["dbfw-ambulancejob"]:GetDeath()) then
            showDispatchLog = not showDispatchLog
            SetNuiFocus(showDispatchLog, showDispatchLog)
            SetNuiFocusKeepInput(showDispatchLog)
            SendNUIMessage({
                mId = "showDispatchLog",
                eData = showDispatchLog
            })
        end
        if showDispatchLog then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 142, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
            DisableControlAction(0, 24, true) -- disable attack
            DisableControlAction(0, 25, true) -- disable aim
            DisableControlAction(0, 47, true) -- disable weapon
            DisableControlAction(0, 58, true) -- disable weapon
            DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
        end
    end
end)

RegisterNUICallback('setGPSMarker', function(data, cb)
  SetNewWaypoint(data.gpsMarkerLocation.x, data.gpsMarkerLocation.y)
end)
RegisterNUICallback('disableGui', function(data, cb)
  showDispatchLog = not showDispatchLog
  SetNuiFocus(showDispatchLog, showDispatchLog)
  SetNuiFocusKeepInput(showDispatchLog)
end)

RegisterNetEvent('alert:noPedCheck')
AddEventHandler('alert:noPedCheck', function(alertType)
  if alertType == "banktruck" then
    AlertBankTruck()
  end
end)

function GetStreetAndZone()
  local plyPos = GetEntityCoords(PlayerPedId(), true)
  local s1, s2 = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
  local street1 = GetStreetNameFromHashKey(s1)
  local street2 = GetStreetNameFromHashKey(s2)
  local zone = GetLabelText(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
  local street = street1 .. ", " .. zone
  return street
end

local function uuid()
    math.randomseed(GetCloudTimeAsInt())
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function getCardinalDirectionFromHeading()
    local heading = GetEntityHeading(PlayerPedId())
    if heading >= 315 or heading < 45 then
        return "North Bound"
    elseif heading >= 45 and heading < 135 then
        return "West Bound"
    elseif heading >=135 and heading < 225 then
        return "South Bound"
    elseif heading >= 225 and heading < 315 then
        return "East Bound"
    end
end

function GetVehicleDescription()
    local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not DoesEntityExist(currentVehicle) then
      return
    end
  
    plate = GetVehicleNumberPlateText(currentVehicle)
    make = GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle))
    color1, color2 = GetVehicleColours(currentVehicle)
  
    if color1 == 0 then color1 = 1 end
    if color2 == 0 then color2 = 2 end
    if color1 == -1 then color1 = 158 end
    if color2 == -1 then color2 = 158 end 
  
    if math.random(100) > 25 then
      plate = "Unknown"
    end
  
    local dir = getCardinalDirectionFromHeading()
  
    local vehicleData  = {
      model = make,
      plate = plate,
      firstColor = colors[color1],
      secondColor = colors[color2],
      heading = dir
    }
    return vehicleData
  end

  function canPedBeUsed(ped,isGunshot,isSpeeder)

    if math.random(100) > 15 then
      return false
    end

    if ped == nil then
        return false
    end

    if isSpeeder == nil then
        isSpeeder = false
    end

    if ped == PlayerPedId() then
        return false
    end

    if GetEntityHealth(ped) < GetEntityMaxHealth(ped) then
      return false
    end

    if isSpeeder then
      if not IsPedInAnyVehicle(ped, false) then
          return false
      end
    end

    if `mp_f_deadhooker` == GetEntityModel(ped) then
      return false
    end

    local curcoords = GetEntityCoords(PlayerPedId())
    local startcoords = GetEntityCoords(ped)

    if #(curcoords - startcoords) < 10.0 then
      return false
    end    

    -- here we add areas that peds can not alert the police
    if #(curcoords - vector3( 1088.76, -3187.51, -38.99)) < 15.0 then
      return false
    end  

    if not HasEntityClearLosToEntity( GetPlayerPed( -1 ), ped , 17 ) and not isGunshot then
      return false
    end

    if not DoesEntityExist(ped) then
        return false
    end

    if IsPedAPlayer(ped) then
        return false
    end

    if IsPedFatallyInjured(ped) then
        return false
    end
    
    if IsPedArmed(ped, 7) then
        return false
    end

    if IsPedInMeleeCombat(ped) then
        return false
    end

    if IsPedShooting(ped) then
        return false
    end

    if IsPedDucking(ped) then
        return false
    end

    if IsPedBeingJacked(ped) then
        return false
    end

    if IsPedSwimming(ped) then
        return false
    end

    if IsPedJumpingOutOfVehicle(ped) or IsPedBeingJacked(ped) then
        return false
    end

    local pedType = GetPedType(ped)
    if pedType == 6 or pedType == 27 or pedType == 29 or pedType == 28 then
        return false
    end
    return true
end

function getRandomNpc(basedistance,isGunshot)

  local basedistance = basedistance
  local playerped = PlayerPedId()
  local playerCoords = GetEntityCoords(playerped)
  local handle, ped = FindFirstPed()
  local success
  local rped = nil
  local distanceFrom
  repeat
      local pos = GetEntityCoords(ped)
      local distance = #(playerCoords - pos)
      if canPedBeUsed(ped,isGunshot) and distance < basedistance and distance > 2.0 and (distanceFrom == nil or distance < distanceFrom) then
          distanceFrom = distance
          rped = ped
      end
      success, ped = FindNextPed(handle)
  until not success

  EndFindPed(handle)

  return rped
end

RegisterNetEvent('civilian:alertPolice')
AddEventHandler("civilian:alertPolice",function(basedistance,alertType,objPassed,isGunshot,isSpeeder)
    local job = DBFWCore.GetPlayerData().job.name
    local pd = false
    if job == "police" then
        pd = true
    end

    local object = objPassed

    if not daytime then
      basedistance = basedistance * 8.2
    else
      basedistance = basedistance * 3.45
    end

    if alertType == "personRobbed" and not pd then
      AlertpersonRobbed(object)
    end

    if isGunshot == nil then 
      isGunshot = false 
    end
    if isSpeeder == nil then 
      isSpeeder = false 
    end

    local nearNPC = getRandomNpc(basedistance,isGunshot,isSpeeder)
    local dst = 0

    if nearNPC then
        dst = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(nearNPC))
    end

    if alertType == "lockpick" and math.random(100) > 88 and not pd then
      nearNPC = true
    end

    if nearNPC == nil and alertType ~= "robberyhouseMansion" and not pd then
      --nobody around for the police call.
      return
    else
      if alertType == "robberyhouseMansion" and not pd then 
        alertType = "robberyhouse" 
      end

      if not isSpeeder and alertType ~= "robberyhouse" then
        RequestAnimDict("amb@code_human_wander_texting@male@base")
        while not HasAnimDictLoaded("amb@code_human_wander_texting@male@base") do
          Citizen.Wait(0)
        end
        Citizen.Wait(1000)
        if GetEntityHealth(nearNPC) < GetEntityMaxHealth(nearNPC) then
          return
        end
        if not DoesEntityExist(nearNPC) then
            return
        end
        if IsPedFatallyInjured(nearNPC) then
            return
        end
        if IsPedInMeleeCombat(nearNPC) then
            return
        end
        ClearPedTasks(nearNPC)
        TaskPlayAnim(nearNPC, "cellphone@", "cellphone_call_listen_base", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
      end
    end

    local plyCoords = GetEntityCoords(PlayerPedId())
    local underground = false
    if plyCoords["z"] < -25 or aids then
        underground = true
    end        

    Citizen.Wait(math.random(5000))

    if alertType == "drugsale" and not underground and not pd then
      if dst > 12.0 and dst < 18.0 then
          DrugSale()
      end
    end

    if alertType == "druguse" and not underground and not pd then
      if dst > 12.0 and dst < 18.0 then
          DrugUse()
      end
    end

    if alertType == "carcrash" then
      CarCrash()
    end

    if alertType == "death" and not underground then
      AlertDeath()
      local roadtest2 = IsPointOnRoad(GetEntityCoords(PlayerPedId()), PlayerPedId())

      if roadtest2 then
        return
      end

      BringNpcs()
    end

    if alertType == "PDOF" and not robbing and not underground and not pd then
      if dst > 12.0 and dst < 18.0 then
        AlertPdof()
      end
    end

    if alertType == "Suspicious" then
      AlertSuspicious()
    end

    if alertType == "fight" and not underground then
      AlertFight()      
    end
    if (alertType == "gunshot" or alertType == "gunshotvehicle") then
      AlertGunShot()
    end

    if alertType == "lockpick" then
      if dst > 12.0 and dst < 18.0 then
          AlertCheckLockpick(object)
      end
    end


    if alertType == "robberyhouse" and not DBFWCore.GetPlayerData().job.name == 'police' then
      AlertCheckRobbery2()
    end
end)

function BringNpcs()
    for i = 1, #curWatchingPeds do
      if DoesEntityExist(curWatchingPeds[i]) then
        ClearPedTasks(curWatchingPeds[i])
        SetEntityAsNoLongerNeeded(curWatchingPeds[i])
      end
    end
    curWatchingPeds = {}
    local basedistance = 35.0
    local playerped = PlayerPedId()
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstPed()
    local success
    local rped = nil
    local distanceFrom
    repeat

        local pos = GetEntityCoords(ped)
        local distance = #(playerCoords - pos)
        if canPedBeUsed(ped,false) and distance < basedistance and distance > 3.0 then

          if math.random(75) > 45 and #curWatchingPeds < 5 then

            TriggerEvent("TriggerAIRunning",ped)
            curWatchingPeds[#curWatchingPeds] = ped

          end

        end

        success, ped = FindNextPed(handle)

    until not success

    EndFindPed(handle)
end

tasksIdle = {
  [1] = "CODE_HUMAN_MEDIC_KNEEL",
  [2] = "WORLD_HUMAN_STAND_MOBILE",
}

RegisterNetEvent("police:setCallSign")
AddEventHandler("police:setCallSign", function(pCallSign)
	if pCallSign ~= nil then currentCallSign = pCallSign end
end)

local exlusionZones = {
  {1713.1795654297,2586.6862792969,59.880760192871,250}, -- prison
  {-106.63687896729,6467.7294921875,31.626684188843,45}, -- paleto bank
  {251.21984863281,217.45391845703,106.28686523438,20}, -- city bank
  {-622.25042724609,-230.93577575684,38.057060241699,10}, -- jewlery store
  {699.91052246094,132.29960632324,80.743064880371,55}, -- power 1
  {2739.5505371094,1532.9992675781,57.56616973877,235}, -- power 2
  {12.53, -1097.99, 29.8, 10} -- Adam's Apple / Pillbox Weapon shop
}

Citizen.CreateThread( function()
  local origin = false
  local w = `WEAPON_PetrolCan`
  local w1 = `WEAPON_FIREEXTINGUISHER`
  local w2 = `WEAPON_FLARE`
  local curw = GetSelectedPedWeapon(PlayerPedId())
  local armed = false
  local timercheck = 0
  while true do
      Wait(5)
      

      if not armed then
          if IsPedArmed(ped, 7) and not IsPedArmed(ped, 1) then
           --   print("detect weapon")
              curw = GetSelectedPedWeapon(ped)
              armed = true
              timercheck = 15
          end
      end

      if armed then
          if IsPedShooting(ped) and curw ~= w and curw ~= w2 and curw ~= w1 and not origin then

            --  print("shot")
              local inArea = false
              for i,v in ipairs(exlusionZones) do
                  local playerPos = GetEntityCoords(ped)
                  if #(vector3(v[1],v[2],v[3]) - vector3(playerPos.x,playerPos.y,playerPos.z)) < v[4] then
                      --if `WEAPON_COMBATPDW` == curw then
                          inArea = true
                      --end
                  end
              end
              if not inArea then
                  origin = true
                  if IsPedCurrentWeaponSilenced(ped) then
                      TriggerEvent("civilian:alertPolice",15.0,"gunshot",0,true)
                  elseif isInVehicle then
                      TriggerEvent("civilian:alertPolice",150.0,"gunshotvehicle",0,true)
                  else
                      TriggerEvent("civilian:alertPolice",550.0,"gunshot",0,true)
                  end

                  Wait(3200)
                  origin = false
              end
          end

          if timercheck == 0 then
             -- print("weapon disabled")
              armed = false
          else
              timercheck = timercheck - 1
          end
      else
           Citizen.Wait(5000)

      end
  end
end)


Citizen.CreateThread( function()
  local origin3 = false
  while true do
      Wait(1)
      if GetVehiclePedIsUsing(PlayerPedId()) == 0 then
          if IsPedInMeleeCombat(PlayerPedId()) and not origin3 and getRandomNpc(3.0) then
              origin3 = true
              TriggerEvent("civilian:alertPolice",15.0,"fight",0)
              TriggerEvent("Evidence:StateSet",1,300)
              Wait(20000)
              origin3 = false
          end
      else
          Citizen.Wait(1500)
      end
  end
end)

RegisterNetEvent('police:tenThirteenA')
AddEventHandler('police:tenThirteenA', function()
		local pos = GetEntityCoords(PlayerPedId(),  true)
		TriggerServerEvent("dispatch:svNotify", {
			dispatchCode = "10-13A",
			firstStreet = GetStreetAndZone(),
			isImportant = true,
			priority = 3,
      dispatchMessage = "Officer Down",
      recipientList = {
        police = "police", ambulance = "ambulance"
      },
			origin = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			  }
		})
		TriggerEvent('dbfw-alerts:1013A')
end)


RegisterNetEvent('police:tenThirteenB')
AddEventHandler('police:tenThirteenB', function()
		local pos = GetEntityCoords(PlayerPedId(),  true)
		TriggerServerEvent("dispatch:svNotify", {
			dispatchCode = "10-13B",
			firstStreet = GetStreetAndZone(),
			isImportant = false,
			priority = 3,
      dispatchMessage = "Officer Down",
      recipientList = {
        police = "police", ambulance = "ambulance"
      },
			origin = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			}
		})
		TriggerEvent('dbfw-alerts:1013B')
end)

RegisterNetEvent('police:panic')
AddEventHandler('police:panic', function()
		local pos = GetEntityCoords(PlayerPedId(),  true)
		TriggerServerEvent("dispatch:svNotify", {
			dispatchCode = "10-78",
			firstStreet = GetStreetAndZone(),
			isImportant = false,
			priority = 3,
      dispatchMessage = "Panic Button",
      recipientList = {
        police = "police", ambulance = "ambulance"
      },
			origin = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			}
		})
		TriggerEvent('dbfw-alerts:policepanic')
end)

RegisterNetEvent("police:tenForteenA")
AddEventHandler("police:tenForteenA", function()	
	local pos = GetEntityCoords(PlayerPedId(),  true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-14A",
		firstStreet = GetStreetAndZone(),
		isImportant = true,
		priority = 3,
    dispatchMessage = "Medic Down",
    recipientList = {
      police = "police", ambulance = "ambulance"
    },
		origin = {
			x = pos.x,
			y = pos.y,
			z = pos.z
		}
	})
		TriggerEvent('dbfw-alerts:1014A')
end)

RegisterNetEvent("police:tenForteenB")
AddEventHandler("police:tenForteenB", function()
	local pos = GetEntityCoords(PlayerPedId(),  true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-14B",
		firstStreet = GetStreetAndZone(),
		isImportant = false,
		priority = 3,
    dispatchMessage = "Medic Down",
    recipientList = {
      police = "police", ambulance = "ambulance"
    },
		origin = {
			x = pos.x,
			y = pos.y,
			z = pos.z
		}
	})
		TriggerEvent('dbfw-alerts:1014B')
end)

RegisterNetEvent("police:1047")
AddEventHandler("police:1047", function()
	local pos = GetEntityCoords(PlayerPedId(),  true)
	TriggerServerEvent("dispatch:svNotify", {
		dispatchCode = "10-47",
		firstStreet = GetStreetAndZone(),
		isImportant = false,
		priority = 3,
    dispatchMessage = "Injured Person",
    recipientList = {
      police = "police", ambulance = "ambulance"
    },
		origin = {
			x = pos.x,
			y = pos.y,
			z = pos.z
		}
	})
		TriggerEvent('dbfw-alerts:downguy')
end)

RegisterNetEvent('TriggerAIRunning')
AddEventHandler("TriggerAIRunning",function(p)
    local usingped = p

    local nm1 = math.random(6,9) / 100
    local nm2 = math.random(6,9) / 100
    nm1 = nm1 + 0.3
    nm2 = nm2 + 0.3
    if math.random(10) > 5 then
      nm1 = 0.0 - nm1
    end

    if math.random(10) > 5 then
      nm2 = 0.0 - nm2
    end

    local moveto = GetOffsetFromEntityInWorldCoords(PlayerPedId(), nm1, nm2, 0.0)
    TaskGoStraightToCoord(usingped, moveto, 2.5, -1, 0.0, 0.0)
    SetPedKeepTask(usingped, true) 

    local dist = #(moveto - GetEntityCoords(usingped))
    while dist > 3.5 and (imdead == 1 or imcollapsed == 1) do
      TaskGoStraightToCoord(usingped, moveto, 2.5, -1, 0.0, 0.0)
      dist = #(moveto - GetEntityCoords(usingped))
      Citizen.Wait(100)
    end

    ClearPedTasksImmediately(ped)
  
    TaskLookAtEntity(usingped, PlayerPedId(), 5500.0, 2048, 3)

    TaskTurnPedToFaceEntity(usingped, PlayerPedId(), 5500)

    Citizen.Wait(3000)

    if math.random(3) == 2 then
      TaskStartScenarioInPlace(usingped, tasksIdle[2], 0, 1)
    elseif math.random(2) == 1 then
      TaskStartScenarioInPlace(usingped, tasksIdle[1], 0, 1)
    else
      TaskStartScenarioInPlace(usingped, tasksIdle[2], 0, 1)
      TaskStartScenarioInPlace(usingped, tasksIdle[1], 0, 1)
    end
   
    SetPedKeepTask(usingped, true) 

    while imdead == 1 or imcollapsed == 1 do
      Citizen.Wait(1)
      if not IsPedFacingPed(usingped, PlayerPedId(), 15.0) then
          ClearPedTasksImmediately(ped)
          TaskLookAtEntity(usingped, PlayerPedId(), 5500.0, 2048, 3)
          TaskTurnPedToFaceEntity(usingped, PlayerPedId(), 5500)
          Citizen.Wait(3000)
      end
    end

    SetEntityAsNoLongerNeeded(usingped)
    ClearPedTasks(usingped)

end)

function AlertFight()
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local armed = IsPedArmed(PlayerPedId(), 7)
  local plyPos = GetEntityCoords(PlayerPedId(), true)


  local dispatchCode = "10-10"

  if armed then
    dispatchCode = "10-11"
  end

  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = false,
    priority = 1,
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    },
    dispatchMessage = "Fight in Progress",
    blipSprite = 458,
    blipColor = 25
  })

  TriggerEvent('dbfw-alerts:fight')
  Wait(math.random(5000,15000))

  if math.random(10,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
    vehicleData = GetVehicleDescription() or {}
    plyPos = GetEntityCoords(PlayerPedId(), true)
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      isImportant = false,
      priority = 1,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:fight')
  end
end

function AlertGunShot()
    Citizen.CreateThread(function() 
      local street1 = GetStreetAndZone()
      local gender = IsPedMale(PlayerPedId())
      local plyPos = GetEntityCoords(PlayerPedId())
  
      local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
      local vehicleData = GetVehicleDescription() or {}
      local initialTenCode = (not isInVehicle and '10-71A' or '10-71B')
      local eventId = uuid()
      Wait(math.random(30000))
      TriggerServerEvent('dispatch:svNotify', {
        dispatchCode = initialTenCode,
        firstStreet = street1,
        gender = gender,
        model = vehicleData.model,
        plate = vehicleData.plate,
        isImportant = false,
        priority = 1,
        firstColor = vehicleData.firstColor,
        secondColor = vehicleData.secondColor,
        heading = vehicleData.heading,
        eventId = eventId,
        recipientList = {
          police = "police"
        },
        origin = {
          x = plyPos.x,
          y = plyPos.y,
          z = plyPos.z
        },
        dispatchMessage = "Shots Fired in Progress",
      })
      TriggerEvent('dbfw-alerts:gunshot')
      Wait(math.random(5000,10000))

    if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
      vehicleData = GetVehicleDescription() or {}
      plyPos = GetEntityCoords(PlayerPedId())
      TriggerServerEvent('dispatch:svNotify', {
        dispatchCode = 'CarFleeing',
        relatedCode = initialTenCode,
        firstStreet = street1,
        gender = gender,
        model = vehicleData.model,
        plate = vehicleData.plate,
        isImportant = false,
        priority = 1,
        firstColor = vehicleData.firstColor,
        secondColor = vehicleData.secondColor,
        heading = vehicleData.heading,
        eventId = eventId,
        dispatchMessage = "Shots Fired from a Vehicle",
        recipientList = {
          police = "police"
        },
        origin = {
          x = plyPos.x,
          y = plyPos.y,
          z = plyPos.z
        }
      })
      TriggerEvent('dbfw-alerts:gunshot')
    end
  end)
end

function CarCrash()
  local street1 = GetStreetAndZone()
  local plyPos = GetEntityCoords(PlayerPedId(), true)
  local gender = IsPedMale(PlayerPedId())

  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local dispatchCode = "10-50"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = false,
    priority = 3,
    dispatchMessage = "Vehicle Crash",
    recipientList = {
      police = "police", ambulance = "ambulance"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })
  TriggerEvent('dbfw-alerts:vehiclecrash')

  Wait(math.random(5000,15000))

  local job = DBFWCore.GetPlayerData().job.name
  if DBFWCore.GetPlayerData().job.name == 'police' then
    vehicleData = GetVehicleDescription() or {}
    plyPos = GetEntityCoords(PlayerPedId(), true)
    TriggerServerEvent('dispatch:svNotify', { 
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = false,
      priority = 3,
      dispatchMessage = "Vehicle Crash",
      recipientList = {
        police = "police", ambulance = "ambulance"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:vehiclecrash')
  end
end

function AlertCheckLockpick(object)
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local targetVehicle = object
  local origin = GetEntityCoords(PlayerPedId())
  if not DoesEntityExist(targetVehicle) then
    vehicleData = GetVehicleDescription() or {}
    plyPos = GetEntityCoords(PlayerPedId(), true)
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = '10-60',
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      isImportant = false,
      priority = 1,
      dispatchMessage = "Vehicle Theft",
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:stolenveh')
  end
end


function AlertpersonRobbed(vehicle)
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local plyPos = GetEntityCoords(PlayerPedId(), true)

  local dispatchCode = "10-31B"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = false,
    priority = 1,
    dispatchMessage = "Store Robbery",
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })
  TriggerEvent('dbfw-alerts:robstore')
  Wait(math.random(5000,15000))

  if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) then
    vehicleData = GetVehicleDescription() or {}
    plyPos = GetEntityCoords(PlayerPedId(), true)
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = true,
      priority = 1,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:robstore')
  end
end

function AlertCheckRobbery2()
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId()) 
  local plyPos = GetEntityCoords(PlayerPedId(), true)

  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local dispatchCode = "10-31A"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = true,
    priority = 1,
    dispatchMessage = "Breaking and entering",
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })

  TriggerEvent('dbfw-alerts:robhouse')
  Wait(math.random(5000,15000))

  if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
    vehicleData = GetVehicleDescription() or {}
    plyPos = GetEntityCoords(PlayerPedId(), true)
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = true,
      priority = 1,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:robhouse')
  end
end

function AlertBankTruck()
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local plyPos = GetEntityCoords(PlayerPedId())
  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local dispatchCode = "10-90"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = true,
    priority = 1,
    dispatchMessage = "Bank Truck",
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })
  
  TriggerEvent('dbfw-alerts:bankt')
  Wait(math.random(5000,15000))

  if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
    plyPos = GetEntityCoords(PlayerPedId())
    vehicleData = GetVehicleDescription() or {}
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = true,
      priority = 1,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:bankt')
  end
end

function AlertJewelRob()
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local plyPos = GetEntityCoords(PlayerPedId())
  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local dispatchCode = "10-90"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = true,
    priority = 1,
    dispatchMessage = "Vangelico Robbery In Progress",
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })
  
  TriggerEvent('dbfw-alerts:jewrob')
  Wait(math.random(5000,15000))

  if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
    plyPos = GetEntityCoords(PlayerPedId())
    vehicleData = GetVehicleDescription() or {}
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = true,
      priority = 1,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:jewrob')
  end
end

function AlertJailBreak()
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local plyPos = GetEntityCoords(PlayerPedId())
  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local dispatchCode = "10-98"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = true,
    priority = 1,
    dispatchMessage = "Jail Break in Progress",
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })
  
  TriggerEvent('dbfw-alerts:jailb')
  Wait(math.random(5000,15000))

  if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
    plyPos = GetEntityCoords(PlayerPedId())
    vehicleData = GetVehicleDescription() or {}
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = true,
      priority = 1,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('dbfw-alerts:jailb')
  end
end

function AlertFleecaRobbery()
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local plyPos = GetEntityCoords(PlayerPedId())
  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local dispatchCode = "10-90"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = true,
    priority = 1,
    dispatchMessage = "Fleeca Robbery",
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })
  
  Wait(math.random(5000,15000))

  if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
    plyPos = GetEntityCoords(PlayerPedId())
    vehicleData = GetVehicleDescription() or {}
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = true,
      priority = 1,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
  end
end

function AlertDrugJob()
  local street1 = GetStreetAndZone()
  local gender = IsPedMale(PlayerPedId())
  local plyPos = GetEntityCoords(PlayerPedId())
  local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
  local dispatchCode = "10-15"
  local eventId = uuid()
  TriggerServerEvent('dispatch:svNotify', {
    dispatchCode = dispatchCode,
    firstStreet = street1,
    gender = gender,
    eventId = eventId,
    isImportant = true,
    priority = 1,
    dispatchMessage = "Drug Job in Progress",
    recipientList = {
      police = "police"
    },
    origin = {
      x = plyPos.x,
      y = plyPos.y,
      z = plyPos.z
    }
  })

  TriggerEvent('t1ger_drugs:OutlawBlipEvent')
  
  Wait(math.random(5000,15000))

  if math.random(1,10) > 3 and IsPedInAnyVehicle(PlayerPedId()) and not isInVehicle then
    plyPos = GetEntityCoords(PlayerPedId())
    vehicleData = GetVehicleDescription() or {}
    TriggerServerEvent('dispatch:svNotify', {
      dispatchCode = 'CarFleeing',
      relatedCode = dispatchCode,
      firstStreet = street1,
      gender = gender,
      model = vehicleData.model,
      plate = vehicleData.plate,
      firstColor = vehicleData.firstColor,
      secondColor = vehicleData.secondColor,
      heading = vehicleData.heading,
      eventId = eventId,
      isImportant = true,
      priority = 1,
      recipientList = {
        police = "police"
      },
      origin = {
        x = plyPos.x,
        y = plyPos.y,
        z = plyPos.z
      }
    })
    TriggerEvent('t1ger_drugs:OutlawBlipEvent')
  end
end

RegisterNetEvent('dbfw-dispatch:drugjob')
AddEventHandler("dbfw-dispatch:drugjob",function()
  AlertDrugJob()
end)

RegisterNetEvent('dbfw-dispatch:bankrobbery')
AddEventHandler("dbfw-dispatch:bankrobbery",function()
  AlertFleecaRobbery()
end)

RegisterNetEvent('dbfw-dispatch:jailbreak')
AddEventHandler("dbfw-dispatch:jailbreak",function()
  AlertJailBreak()
end)

RegisterNetEvent('dbfw-dispatch:jewelrobbery')
AddEventHandler("dbfw-dispatch:jewelrobbery",function()
  AlertJewelRob()
  return
end)

RegisterNetEvent('dbfw-dispatch:houserobbery')
AddEventHandler("dbfw-dispatch:houserobbery",function()
  AlertCheckRobbery2()
end)

RegisterNetEvent('dbfw-dispatch:storerobbery')
AddEventHandler("dbfw-dispatch:storerobbery",function()
  AlertpersonRobbed(vehicle)
end)

RegisterNetEvent('dbfw-dispatch:carjacking')
AddEventHandler("dbfw-dispatch:carjacking",function()
  AlertCheckLockpick(object)
end)

RegisterNetEvent('dbfw-ambulancejob:downplayer')
AddEventHandler("dbfw-ambulancejob:downplayer",function()
    AlertDeath()
end)
