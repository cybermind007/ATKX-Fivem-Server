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

DBFWCore = nil 

local PlayerData              = {}

Citizen.CreateThread(function ()
    while DBFWCore == nil do
        TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
        Citizen.Wait(1)
    end

    while DBFWCore.GetPlayerData() == nil do
        Citizen.Wait(10)
    end

    PlayerData = DBFWCore.GetPlayerData()
end) 

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

--------------  Pawn Shop ---------------------------
function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function DrawText3D(x, y, z, text, scale)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
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

local gym = {
  {x = 412.31, y = 314.11, z = 103.02}
}

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      for k in pairs(gym) do
          DrawMarker(21, gym[k].x, gym[k].y, gym[k].z, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 0, 153, 255, 255, 0, 0, 0, 0)
      end
  end
end)

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      for k in pairs(gym) do
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, gym[k].x, gym[k].y, gym[k].z)
        if dist <= 0.5 then
          DrawText3D(plyCoords.x, plyCoords.y, plyCoords.z, "~w~Press ~r~[E] ~w~ to use pawn shop!", 0.4)
          if IsControlJustPressed(0, Keys['E'])then
            OpenSellMenu()
          end
        end		
      end
  end
end)

function OpenSellMenu()
  DBFWCore.UI.Menu.CloseAll()

  DBFWCore.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'pawn_sell_menu',
      {
          title    = 'Kalxie RP Pawnshop',
          elements = {
              {label = 'Jewels ($50)', value = 'water'},
          }
      },
      function(data, menu)
		      if data.current.value == 'water' then
              TriggerEvent('dbfw-pawnshop:selljewelscl')
          end
      end,
      function(data, menu)
          menu.close()
      end
  )
end

RegisterNetEvent('dbfw-pawnshop:selljewelscl')
AddEventHandler('dbfw-pawnshop:selljewelscl', function()
  if exports['dbfw-inventory']:hasEnoughOfItem('water', 1) then
    TriggerServerEvent('dbfw-pawnshop:selljewels')
    TriggerEvent('OpenInv')
    TriggerEvent('inventory:removeItem', 'water', 1)
    TriggerEvent('DoLongHudText', 'You sold 1 jewel for $50', 1) 
  else 
    TriggerEvent('DoLongHudText', 'You don\'t enough jewels to sell!', 2) 
  end
end)
