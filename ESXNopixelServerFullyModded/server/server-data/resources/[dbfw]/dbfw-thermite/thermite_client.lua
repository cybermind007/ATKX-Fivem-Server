DBFWCore = nil

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
end)

local currentFires = {}

RegisterNetEvent("thermite:StartClientFires")
AddEventHandler("thermite:StartClientFires", function(x,y,z,arg1,arg2)
  if #(vector3(x,y,z) - GetEntityCoords(PlayerPedId())) < 100 then
    local fire = StartScriptFire(x,y,z,arg1,arg2)
    currentFires[#currentFires+1]=fire
  end
end)

RegisterNetEvent("thermite:StopFiresClient")
AddEventHandler("thermite:StopFiresClient", function()
   for p,j in ipairs(currentFires) do
        RemoveScriptFire(j)
    end
end)

function startFireAtLocation(x,y,z,time)
      local rand = math.random(7,11)

        for j=1,rand do   

            local randy = randomFloat(0,0.4,5)
            local randx = randomFloat(0,0.4,5)

            if math.random(1,2) == 2 then
                y = y + randy
            else
                y = y - randy
            end

            if math.random(1,2) == 2 then
                x = x + randx
            else
                x = x - randx
            end

            TriggerServerEvent("thermite:StartFireAtLocation",x,y,z,24,false)
      end

      Citizen.Wait(time)
      TriggerServerEvent("thermite:StopFires")

end

function randomFloat(min, max, precision)
    local range = max - min
    local offset = range * math.random()
    local unrounded = min + offset

    if not precision then
        return unrounded
    end

    local powerOfTen = 10 ^ precision
    return math.floor(unrounded * powerOfTen + 0.5) / powerOfTen
end

local currentlyInGame = false
local passed = false;


-----------------
-- dropAmount , the amount of letters to drop for completion
-- Letter , the letter set , letterset 1 = [q,w,e] letterset 2 = [q,w,e,j,k,l] , the set is used to determain what letters will drop
-- speed , the speed that the letters move on the screen
-- inter , interval , the time between letter drops
----------------

function startGame(dropAmount,letter,speed,inter)
  if exports['dbfw-inventory']:hasEnoughOfItem('thermite', 1) then
    openGui()
    play(dropAmount,letter,speed,inter)
    currentlyInGame = true
    while currentlyInGame do
      Wait(400)
      if exports["dbfw-ambulancejob"]:GetDeath() then 
        closeGui()
      end 
    end
    return passed;
  else
    TriggerEvent('DoLongHudText', 'You must have thermite to continue', 2)
    return false
  end
end



local gui = false

function openGui()
    gui = true
    SetNuiFocus(true,true)
    SendNUIMessage({openPhone = true})
end

function play(dropAmount,letter,speed,inter) 
  SendNUIMessage({openSection = "playgame", amount = dropAmount,letterSet = letter,speed = speed,interval = inter})
end

function CloseGui()
    currentlyInGame = false
    gui = false
    SetNuiFocus(false,false)
    SendNUIMessage({openPhone = false})
end

-- NUI Callback Methods
RegisterNUICallback('close', function(data, cb)
  CloseGui()
  cb('ok')
end)

RegisterNUICallback('failure', function(data, cb)
  passed = false
  TriggerEvent('DoLongHudText', 'Failure', 2)
  CloseGui()
  cb('ok')
  Citizen.Wait(1500)
  FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNUICallback('complete', function(data, cb)
  passed = true
  TriggerEvent('DoLongHudText', 'Success!')
  CloseGui()
  cb('ok')
end)

AddEventHandler("onResourceStart", function(resource)
  if resource == GetCurrentResourceName() then
    TriggerServerEvent("thermite:StopFires")
  end
end)


