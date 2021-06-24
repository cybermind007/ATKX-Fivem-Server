---------------------------------- VAR ----------------------------------
isCop = false
curJob = nil

local changeYourJob = {
  {name="Job Center", colour=17, id=351, x=-1081.8293457031, y=-248.12872314453, z=37.763294219971},
}

local jobs = {
  {name="Unemployed", id="unemployed"},
  {name="Tow Truck Driver", id="towtruck"},  
  {name="Taxi Driver", id="taxi"},
  {name="Garbage Job", id="garbage"},
  {name="Uber Delivery", id="uberdriver"},
  --{name="Lumberjack Job", id="lumberjack"},
}

DBFWCore = nil

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


---------------------------------- FUNCTIONS ----------------------------------

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(centre)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x , y)
end

function menuJobs()
  MenuTitle = "Jobs"
  ClearMenu()
  for _, item in pairs(jobs) do
    local nameJob = item.name
    local idJob = item.id
    Menu.addButton(nameJob,"changeJob",idJob)
  end
end

function changeJob(id)
  TriggerServerEvent("jobssystem:jobs", id)
end

---------------------------------- CITIZEN ----------------------------------
local inGurgle = false
RegisterNetEvent('event:control:jobSystem')
AddEventHandler('event:control:jobSystem', function(useID)
  if useID == 1 then
    TriggerServerEvent("server:paySlipPickup")
    Citizen.Wait(1000)

  elseif useID == 2 and not inGurgle then
    TriggerEvent("Gurgle:open")
    inGurgle = true

  elseif useID == 3 then
    menuJobs()
    Menu.hidden = not Menu.hidden 
  end
end)

Controlkey = {["generalUse"] = {38,"E", 202, "ESPACE"}} 
RegisterNetEvent('event:control:update')
AddEventHandler('event:control:update', function(table)
  Controlkey["generalUse"] = table["generalUse"]
end)


-- #MarkedForMarker
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    local jobDst = #(vector3(-138.39538574219,-632.17938232422,168.82051086426) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
    -- local gurDst = #(vector3(-1062.96, -248.24, 44.03) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
     local payDst = #(vector3(-1082.81, -248.19, 37.77) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))

    if jobDst > 30 and payDst > 30 then
      Citizen.Wait(1000)
    else

      DrawMarker(27,-138.39538574219,-632.17938232422,168.82051086426, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.5001, 0, 155, 255, 200, 0, 0, 0, 0) 
      --DrawMarker(27,-1082.81, -248.19, 36.77, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.5001, 0, 155, 255, 200, 0, 0, 0, 0) 
      -- DrawMarker(27,165.8, -21.12, 34.45, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.5001, 0, 155, 255, 200, 0, 0, 0, 0)

      if jobDst < 1 then
          
        if Menu.hidden then
          drawTxt('Push ['..Controlkey["generalUse"][2]..'] to access jobs (Tow / Taxi / News require your own specific vehicle)',0,1,0.5,0.8,0.35,255,255,255,255)
          --drawTxt(banks[scanid].x, banks[scanid].y, banks[scanid].z,"["..Controlkey["generalUse"][2].."] to use Bank.")
            if IsControlJustPressed(1, Controlkey["generalUse"][1])  then -- IF INPUT_PICKUP Is pressed

              TriggerEvent('event:control:jobSystem', 3)
            end
        
        else
          drawTxt('Push ~b~Arrows~s~ to change selection, ~b~Enter~s~ to select, ~b~Backspace~s~ to quit. ',0,1,0.5,0.8,0.35,255,255,255,255)
          if IsControlJustPressed(1, Controlkey["generalUse"][3]) then
            Menu.hidden = not Menu.hidden
          end
        end
      end
      Menu.renderGUI()
    end

    
  end
end)


-- #MarkedForMarker
Citizen.CreateThread(function()
local insideCentre = { x = -137.2746887207, y = -623.98498535156, z = 168.8203125 }
local outsideCentre = { x = 172.78, y = -26.89, z = 68.35 }
  while true do
   Citizen.Wait(1)
   local plyId = PlayerPedId()
   local plyCoords = GetEntityCoords(plyId)
   local dstOffice = #(plyCoords - vector3(172.78, -26.89, 68.35))
   local dstOfficeExit = #(plyCoords - vector3(-137.274, -623.98, 168.82))

   if dstOffice < 3.0 then
    DrawText3Ds( 172.78, -26.89, 68.35, '[E] Enter Job Centre' )
    if IsControlJustReleased(0, Keys['E']) then
      DBFWCore.Game.Teleport(PlayerPedId(), insideCentre)
    end
   elseif dstOfficeExit < 3.0 then
    DrawText3Ds( -137.2746887207, -623.98498535156, 168.8203125, '[E] Exit Job Centre' )

    if IsControlJustReleased(0, Keys['E']) then
      DBFWCore.Game.Teleport(PlayerPedId(), outsideCentre)
    end
   else
     if dstOffice > 100.0 then
       Citizen.Wait(2000)
     end
   end
 end
end)


RegisterNetEvent('jobssystem:current')
AddEventHandler('jobssystem:current', function(cb)
  LocalPlayer = exports["np-base"]:getModule("LocalPlayer")
  cb(LocalPlayer:getVar("job"))
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

		local blip = AddBlipForCoord(vector3(172.78,-26.89,68.35))

		SetBlipSprite (blip, 457)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.8)
		SetBlipColour (blip, 47)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Job Center')
		EndTextCommandSetBlipName(blip)

end)