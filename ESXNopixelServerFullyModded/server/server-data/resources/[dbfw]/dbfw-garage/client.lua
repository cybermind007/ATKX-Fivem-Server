--[[Register]]--
DBFWCore = nil

local PlayerData              = {}

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
	
	while DBFWCore.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	DBFWCore.PlayerData = DBFWCore.GetPlayerData()
end)

DecorRegister("CurrentFuel", 3)

Fuel = 0
local houseGarage = {}
local enableHgarage = false
local houseID = 0
local curHouseGarage = ""
local hasAlreadyJoined = false


RegisterNetEvent('garages:StoreVehicle')
RegisterNetEvent('garages:SelVehicle')
--

local markerColor = 
{
	["Red"] = 222,
	["Green"] = 50,
	["Blue"] = 50
}
local garagesRunning = false

local garages = {
	[1] = { loc = {484.77066040039,-77.643089294434,77.600166320801}, spawn = {469.40374755859,-65.764274597168,76.935157775879}, garage = "A"},
	[2] = { loc = {-331.96115112305,-781.52337646484,33.964477539063}, spawn = {-334.75921630859,-777.63739013672,33.965934753418}, garage = "B"},
	[3] = { loc = {-451.37295532227,-794.06591796875,30.543809890747}, spawn = {-453.78579711914,-799.77722167969,30.544193267822}, garage = "C"},
	[4] = { loc = {399.51190185547,-1346.2742919922,31.121940612793}, spawn = {404.08923339844,-1340.2329101563,31.123672485352}, garage = "D"},
	[5] = { loc = {598.77319335938,90.707237243652,92.829048156738}, spawn = {604.99200439453,90.680313110352,92.638885498047}, garage = "E"},
	[6] = { loc = {641.53442382813,205.42562866211,97.186958312988}, spawn = {643.27648925781,200.49697875977,96.490730285645}, garage = "F"},
	[7] = { loc = {82.359413146973,6418.9575195313,31.479639053345}, spawn = {68.428749084473,6394.8129882813,31.233980178833}, garage = "G"},
	[8] = { loc = {-794.578125,-2020.8499755859,8.9431390762329}, spawn = {-773.12854003906,-2034.2691650391,8.8856906890869}, garage = "H"},
	[9] = { loc = {-669.15631103516,-2001.7552490234,7.5395741462708}, spawn = {-666.11407470703,-1993.1220703125,6.9599323272705}, garage = "I"},
	[10] = { loc = {-606.86322021484,-2236.7624511719,6.0779848098755}, spawn = {-617.38104248047,-2228.3828125,6.0075860023499}, garage = "J"},
	[11] = { loc = {-166.60482788086,-2143.9333496094,16.839847564697}, spawn = {-166.0227355957,-2150.9533691406,16.704912185669}, garage = "K"},
	[12] = { loc = {-38.922565460205,-2097.2663574219,16.704851150513}, spawn = {-42.358554840088,-2106.9069824219,16.704837799072}, garage = "L"},
	[13] = { loc = {-70.179389953613,-2004.4139404297,18.016941070557}, spawn = {-66.245826721191,-2012.8634033203,18.016965866089}, garage = "M"},
	[14] = { loc = {549.47796630859,-55.197559356689,71.069190979004}, spawn = {549.47796630859,-55.197559356689,71.069190979004}, garage = "Impound Lot"},
	[15] = { loc = {364.27685546875,297.84490966797,103.49515533447}, spawn = {370.07534790039,291.43197631836,103.33471679688}, garage = "O"},
	[16] = { loc = {-338.31619262695,266.79782104492,85.741966247559}, spawn = {-334.42706298828,278.54644775391,85.945793151855}, garage = "P"},
	[17] = { loc = {273.66683959961,-343.83737182617,44.919876098633}, spawn = {272.68188476563,-334.81295776367,44.919876098633}, garage = "Q"},
	[18] = { loc = {66.215492248535,13.700443267822,69.047248840332}, spawn = {61.096534729004,24.754076004028,69.682136535645}, garage = "R"},
	[19] = { loc = {3.3330917358398,-1680.7877197266,29.170293807983}, spawn = {0.7901134,-1679.708,28.8765}, garage = "Imports"},
	[20] = { loc = {286.67013549805,79.613700866699,94.362899780273}, spawn = {282.82489013672,76.622230529785,94.36026763916}, garage = "S"},
	[21] = { loc = {211.79,-808.38,30.833}, spawn = {212.04,-800.325,30.89}, garage = "T"},
	[22] = { loc = {447.65,-1021.23,28.45}, spawn = {447.65,-1021.23,28.45}, garage = "Police Department"},
	[23] = { loc = {-25.59,-720.86,32.62}, spawn = {-25.59,-720.86,32.22}, garage = "House"},
	[24] = { loc = {570.81,2729.85,42.07}, spawn = {561.026,2728.24,41.70773}, garage = 'Harmony Garage'},
	[25] = { loc = {-1287.1, 293.02, 64.82}, spawn = {-1292.408, 296.0714, 64.45718}, garage = 'Richman Garage'},
	[26] = { loc = {-1579.01,-889.11,9.88,}, spawn = {-1575.275,-881.7657,9.74567,}, garage = 'Pier Garage'},
	[27] = { loc = {-277.52,-890.0,30.87}, spawn = {-273.3148,-891.4863,31.0806}, garage = '24/7 Garage'},
	[28] =  { loc = {986.28, -208.47, 70.46}, spawn = {986.28, -208.47, 70.46}, garage = 'Run Down Hotel' },
	[29] =  { loc = {847.36, -3219.15, 5.97}, spawn = {855.372, -3218.256, 5.543503}, garage = 'Docks' },
	[30] =  { loc = {-1479.6,-666.556,28.4}, spawn = {-1479.6,-666.556,28.4}, garage = 'Q' },
	[31] =  { loc = {1038.04,-764.42,57.93}, spawn = {1040.11,-775.55,58.02}, garage = 'U' },
	[32] = { loc = {-3173.02,1110.12,20.83}, spawn = {-3173.02,1110.12,20.83}, garage = 'Chumash'},
}


function DefaultGarages()
	 garages = {
		[1] = { loc = {484.77066040039,-77.643089294434,77.600166320801}, spawn = {469.40374755859,-65.764274597168,76.935157775879}, garage = "A"},
		[2] = { loc = {-331.96115112305,-781.52337646484,33.964477539063}, spawn = {-334.75921630859,-777.63739013672,33.965934753418}, garage = "B"},
		[3] = { loc = {-451.37295532227,-794.06591796875,30.543809890747}, spawn = {-453.78579711914,-799.77722167969,30.544193267822}, garage = "C"},
		[4] = { loc = {399.51190185547,-1346.2742919922,31.121940612793}, spawn = {404.08923339844,-1340.2329101563,31.123672485352}, garage = "D"},
		[5] = { loc = {598.77319335938,90.707237243652,92.829048156738}, spawn = {604.99200439453,90.680313110352,92.638885498047}, garage = "E"},
		[6] = { loc = {641.53442382813,205.42562866211,97.186958312988}, spawn = {643.27648925781,200.49697875977,96.490730285645}, garage = "F"},
		[7] = { loc = {82.359413146973,6418.9575195313,31.479639053345}, spawn = {68.428749084473,6394.8129882813,31.233980178833}, garage = "G"},
		[8] = { loc = {-794.578125,-2020.8499755859,8.9431390762329}, spawn = {-773.12854003906,-2034.2691650391,8.8856906890869}, garage = "H"},
		[9] = { loc = {-669.15631103516,-2001.7552490234,7.5395741462708}, spawn = {-666.11407470703,-1993.1220703125,6.9599323272705}, garage = "I"},
		[10] = { loc = {-606.86322021484,-2236.7624511719,6.0779848098755}, spawn = {-617.38104248047,-2228.3828125,6.0075860023499}, garage = "J"},
		[11] = { loc = {-166.60482788086,-2143.9333496094,16.839847564697}, spawn = {-166.0227355957,-2150.9533691406,16.704912185669}, garage = "K"},
		[12] = { loc = {-38.922565460205,-2097.2663574219,16.704851150513}, spawn = {-42.358554840088,-2106.9069824219,16.704837799072}, garage = "L"},
		[13] = { loc = {-70.179389953613,-2004.4139404297,18.016941070557}, spawn = {-66.245826721191,-2012.8634033203,18.016965866089}, garage = "M"},
		[14] = { loc = {549.47796630859,-55.197559356689,71.069190979004}, spawn = {549.47796630859,-55.197559356689,71.069190979004}, garage = "Impound Lot"},
		[15] = { loc = {364.27685546875,297.84490966797,103.49515533447}, spawn = {370.07534790039,291.43197631836,103.33471679688}, garage = "O"},
		[16] = { loc = {-338.31619262695,266.79782104492,85.741966247559}, spawn = {-334.42706298828,278.54644775391,85.945793151855}, garage = "P"},
		[17] = { loc = {273.66683959961,-343.83737182617,44.919876098633}, spawn = {272.68188476563,-334.81295776367,44.919876098633}, garage = "Q"},
		[18] = { loc = {66.215492248535,13.700443267822,69.047248840332}, spawn = {61.096534729004,24.754076004028,69.682136535645}, garage = "R"},
		[19] = { loc = {3.3330917358398,-1680.7877197266,29.170293807983}, spawn = {0.7901134,-1679.708,28.8765}, garage = "Imports"},
		[20] = { loc = {286.67013549805,79.613700866699,94.362899780273}, spawn = {282.82489013672,76.622230529785,94.36026763916}, garage = "S"},
		[21] = { loc = {211.79,-808.38,30.833}, spawn = {212.04,-800.325,30.89}, garage = "T"},
		[22] = { loc = {447.65,-1021.23,28.45}, spawn = {447.65,-1021.23,28.45}, garage = "Police Department"},
		[23] = { loc = {-25.59,-720.86,32.62}, spawn = {-25.59,-720.86,32.22}, garage = "House"},
		[24] = { loc = {570.81,2729.85,42.07}, spawn = {561.026,2728.24,41.70773}, garage = 'Harmony Garage'},
		[25] = { loc = {-1287.1, 293.02, 64.82}, spawn = {-1292.408, 296.0714, 64.45718}, garage = 'Richman Garage'},
		[26] = { loc = {-1579.01,-889.11,9.88,}, spawn = {-1575.275,-881.7657,9.74567,}, garage = 'Pier Garage'},
		[27] = { loc = {-277.52,-890.0,30.87}, spawn = {-273.3148,-891.4863,31.0806}, garage = '24/7 Garage'},
		[28] =  { loc = {986.28, -208.47, 70.46}, spawn = {986.28, -208.47, 70.46}, garage = 'Run Down Hotel' },
		[29] =  { loc = {847.36, -3219.15, 5.97}, spawn = {855.372, -3218.256, 5.543503}, garage = 'Docks' },
		[30] =  { loc = {-1479.6,-666.556,28.4}, spawn = {-1479.6,-666.556,28.4}, garage = 'Q' },
		[31] =  { loc = {1038.04,-764.42,57.93}, spawn = {1040.11,-775.55,58.02}, garage = 'U' },
		[32] = { loc = {-3173.02,1110.12,20.83}, spawn = {-3173.02,1110.12,20.83}, garage = "Chumash"},
	}
end


RegisterNetEvent("checkifbike")
AddEventHandler("checkifbike", function(vehicle, veh_id)
	local bicycle = IsThisModelABicycle( GetHashKey(vehicle) )
	if bicycle then
		TriggerServerEvent( "garages:CheckForSpawnVeh2", veh_id)
	else
		TriggerEvent( "DoLongHudTexts", "No License.",2 )
	end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

--[[Local/Global]]--

--["garage"..table_id] = { ["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0, ["table_id"] = table_id },
local mygarages = {}
local scannedPOIs = {}


function DeleteSpawnedHouse()

	TriggerEvent("inhouse",false)
    local playerped = PlayerPedId()
    local plycoords = GetEntityCoords(playerped)
    local handle, ObjectFound = FindFirstObject()
    local success
    repeat
        local pos = GetEntityCoords(ObjectFound)
        local distance = #(vector3(plycoords["x"], plycoords["y"], (plycoords["z"])) - pos)
        if distance < 35.0 and ObjectFound ~= playerped then
        	if not IsEntityAPed(ObjectFound) then
        		DeleteObject(ObjectFound)
        	end            
        end
        success, ObjectFound = FindNextObject(handle)
    until not success
    EndFindObject(handle)
end


function hasKey(id) 
	local myhousekeys = exports["isPed"]:isPed("myhousekeys")
	for i = 1, #myhousekeys do
		if tonumber(myhousekeys[i]) == id then
			return true
		end
	end
	return false
end


-- this is called if we get a new key
RegisterNetEvent("RequestKeyUpdate")
AddEventHandler("RequestKeyUpdate", function()
	TriggerServerEvent("ReturnHouseKeys")
end)

-- this is called if a key is altered, we request new ones if one of ours is.
RegisterNetEvent("CheckForKeyUpdate")
AddEventHandler("CheckForKeyUpdate", function(id)
	if hasKey(id) then
		TriggerServerEvent("ReturnHouseKeys")
	end
end)


RegisterNetEvent("UpdateCurrentHouseSpawns")
AddEventHandler("UpdateCurrentHouseSpawns", function(id,house_poi)

	local id = tonumber(id)
	if hasKey(id) then
		TriggerServerEvent("GarageData")
	end

end)

RegisterNetEvent('dbfw-garages:client:houseGarageConfig')
AddEventHandler('dbfw-garages:client:houseGarageConfig', function(garageConfig)
    HouseGarages = garageConfig
end)

RegisterNetEvent('qb-garages:client:addHouseGarage')
AddEventHandler('qb-garages:client:addHouseGarage', function(house, garageInfo)
    HouseGarages[house] = garageInfo
end)


RegisterNetEvent("house:garagelocations")
AddEventHandler("house:garagelocations", function(sentmygarages,closesthouse,garageConfig)
	print(json.encode(sentmygarages))
	print(garageConfig)
	print(json.encode(closesthouse))
	houseGarage = sentmygarages
	houseID = closesthouse
	enableHgarage = true
	curHouseGarage = houseID
end)



local entering = false
RegisterNetEvent("house:entering")
AddEventHandler("house:entering", function(entering)
	entering = true
	Citizen.Wait(10000)
	entering = false
end)


RegisterNetEvent("house:garagechanges")
AddEventHandler("house:garagechanges", function(table_id)
	if scannedPOIs["garage"..table_id] ~= nil then
		Citizen.Wait(math.random(1000,5000))
		TriggerEvent("house:entering")
		TriggerServerEvent("GarageData")
	end
end)

Citizen.CreateThread(function() --ok

	while DBFWCore == nil do
	  TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
	  Citizen.Wait(1)
	end

  end)

Citizen.CreateThread(function()
	--TriggerServerEvent("GarageData")
	
	while true do
		Citizen.Wait(1)
		local closest = 500.0
		if garagesRunning then
			for i,row in pairs(mygarages) do
				local dist = #(vector3(row["x"],row["y"],row["z"]) - GetEntityCoords(PlayerPedId()))
				if dist < 40.0 and scannedPOIs["garage"..row["table_id"]] == nil and not resetting then
					scannedPOIs["garage"..row["table_id"]] = row
					CreateHouseGarages(row)

				elseif scannedPOIs["garage"..row["table_id"]] ~= nil and dist > 150.0 and not entering then
					scannedPOIs["garage"..row["table_id"]] = nil
					RemoveHouseGarages(row)
				end
				Citizen.Wait(1000)
			end
		end
		Citizen.Wait(math.ceil(closest * 20))
	end

end)

local addedGarages = {}
function CreateHouseGarages(currentRow)

	for x,row in pairs(currentRow["house_poi"]["garages"]) do

		local currentGarage = row
		local garageName = currentRow["house_name"] .. " #" .. x

		for _, g in ipairs(garages) do
			if g.garage == garageName and g.disabled then
				addedGarages[garageName] = true
				g.disabled = false
			end
		end

		if addedGarages[garageName] == nil then
			garages[#garages+1] =
			{ 
				loc = { currentGarage["x"],currentGarage["y"],currentGarage["z"],currentGarage["h"] },
				spawn = { currentGarage["x"],currentGarage["y"],currentGarage["z"],currentGarage["h"] }, 
				garage = garageName
			}
		end

	end

	garagesRunning = false
	TriggerEvent("RecreateGarages")
end

function RemoveHouseGarages(currentRow)
	
	local todelete = {}

	for x,row in pairs(currentRow["house_poi"]["garages"]) do
		local currentGarage = row
		local garageName = currentRow["house_name"] .. " #" .. x
		for i = 1, #garages do
			if garageName == garages[i].garage and not garages[i].disabled then
				garages[i].disabled = true
			end
		end
	end

	garagesRunning = false
	TriggerEvent("RecreateGarages")	
end
local nearClothing = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local plyId = LocalPed()
		local plyCoords = GetEntityCoords(plyId)
		for x,row in pairs(scannedPOIs) do
			if row["house_poi"] ~= nil then
				local garages = row["house_poi"]["garages"]
				local backdooroutside = row["house_poi"]["backdooroutside"]
				local backdoorinside = row["house_poi"]["backdoorinside"]
				local clothing = row["house_poi"]["clothing"]
				local storage = row["house_poi"]["storage"]

				if backdooroutside["x"] ~= 0.0 then
					if #(vector3(backdooroutside["x"],backdooroutside["y"],backdooroutside["z"]-0.3) - plyCoords) < 3.0 then
						DrawMarker(20,backdooroutside["x"],backdooroutside["y"],backdooroutside["z"]-0.3,0,0,0,0,0,0,0.701,1.0001,0.3001,markerColor.Red,markerColor.Green, markerColor.Blue,11,0,0,0,0)
					end
					if #(vector3(backdooroutside["x"],backdooroutside["y"],backdooroutside["z"]-0.3) - plyCoords) < 1.5 then
						DrawText3Ds( backdooroutside["x"],backdooroutside["y"],backdooroutside["z"] , '~g~E~s~ to enter house.')
						
						if IsControlJustReleased(2, 38) then
							TriggerServerEvent("house:enterhousebackdoor",row["house_id"],row["house_model"],false,backdoorinside["x"],backdoorinside["y"],backdoorinside["z"],backdoorinside["h"])
							Citizen.Wait(3000)
						end
					end
				end

				if backdoorinside["x"] ~= 0.0 then
					if #(vector3(backdoorinside["x"],backdoorinside["y"],backdoorinside["z"]-0.3) - plyCoords) < 3.0 then
						DrawMarker(20,backdoorinside["x"],backdoorinside["y"],backdoorinside["z"]-0.3,0,0,0,0,0,0,0.701,1.0001,0.3001,markerColor.Red,markerColor.Green, markerColor.Blue,11,0,0,0,0)
					end
					if #(vector3(backdoorinside["x"],backdoorinside["y"],backdoorinside["z"]-0.3) - plyCoords) < 1.5 then
						DrawText3Ds( backdoorinside["x"],backdoorinside["y"],backdoorinside["z"] , '~g~E~s~ to leave house.')
						if IsControlJustReleased(2, 38) then
							TriggerEvent("housing:exit:backdoor",backdooroutside["x"],backdooroutside["y"],backdooroutside["z"],backdooroutside["h"])
							Citizen.Wait(3000)
						end
					end	
				end
				if clothing["x"] ~= 0.0 then
					if #(vector3(clothing["x"],clothing["y"],clothing["z"]-0.3) - plyCoords) < 1.5 then
						nearClothing = true
						DrawText3Ds( clothing["x"],clothing["y"],clothing["z"] , 'Press G to relog or use /outfits to change clothing' )
						if IsControlJustReleased(2,47) then
							DeleteSpawnedHouse()

							logout()
							TriggerEvent("inhouse",false)
						end
					else
						nearClothing = false
					end
				end

				if storage["x"] ~= 0.0 then
					if #(vector3(storage["x"],storage["y"],storage["z"]-0.3) - plyCoords) < 1.5 then
						DrawText3Ds( storage["x"],storage["y"],storage["z"] , 'Press ~g~E~s~ to open your stash.')
						if IsControlJustReleased(2, 38) then
							if row["house_owner_cid"] == exports["isPed"]:isPed("cid") then
								TriggerEvent("server-inventory-open", "1", "house-"..row["house_name"])
							else
								TriggerEvent("DoLongHudTexts", "You are not allowed to open other's stashes.", 1)
							end
						end
					end
				end
			end
		end
	end
end)

function logout()
	TransitionToBlurred(500)
	DoScreenFadeOut(500)
	Citizen.Wait(1000)
	Citizen.Wait(1000)   
	TriggerEvent("np-base:clearStates")
	--exports["np-base"]:getModule("SpawnManager"):Initialize()
	Citizen.Wait(1000)
end


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



local myroomtype = 0
local showGarages = false
local blips = {
	{469.40374755859,-65.764274597168,76.935157775879,"A"},
	{-331.96115112305,-781.52337646484,33.964477539063,"B"},
	{-451.37295532227,-794.06591796875,30.543809890747,"C"},
	{399.51190185547,-1346.2742919922,31.121940612793,"D"},
	{598.77319335938,90.707237243652,92.829048156738,"E"},
	{641.53442382813,205.42562866211,97.186958312988,"F"},
	{82.359413146973,6418.9575195313,31.479639053345,"G"},
	{-794.578125,-2020.8499755859,8.9431390762329,"H"},
	{-669.15631103516,-2001.7552490234,7.5395741462708,"I"},
	{-606.86322021484,-2236.7624511719,6.0779848098755,"J"},
	{-166.60482788086,-2143.9333496094,16.839847564697,"K"},
	{-38.922565460205,-2097.2663574219,16.704851150513,"L"},
	{-70.179389953613,-2004.4139404297,18.016941070557,"M"},
	{549.47796630859,-55.197559356689,71.069190979004,"Impound Lot"},
	{364.27685546875,297.84490966797,103.49515533447,"O"},
	{-338.31619262695,266.79782104492,85.741966247559,"P"},
	{273.66683959961,-343.83737182617,44.919876098633,"Q"},
	{66.215492248535,13.700443267822,69.047248840332,"R"},
	{3.3330917358398,-1680.7877197266,29.170293807983,"Imports"},
	{286.67013549805,79.613700866699,94.362899780273,"S"},
	{211.79,-808.38,30.833,"T"},
	{447.65,-1021.23,28.45,"Police Department"},
	{-25.59,-720.86,32.62, "Highrise Garage"},
	{570.81,2729.85,42.07,'Harmony Garage'},
	{-3173.02, 1110.12, 20.83,'Chumash'},
	{ -1287.1, 293.02, 64.82, ' Richman Garage' },
	{ -1579.01,-889.11,9.38, ' Pier Garage' },
	{ -277.52,-890.0,30.47, '24/7 Garage' },
	{ 986.28, -208.47, 70.46, 'Run Down Hotel' },
	{847.36, -3219.15, 5.97, 'Docks' },
	{-1479.6,-666.556,28.4, 'Q' },
	
}

AddEventHandler('playerSpawned', function(spawn)
	if not hasAlreadyJoined then
		TriggerServerEvent('dbfw-garage:putcaringarage')
	end
	hasAlreadyJoined = true
end)

RegisterNetEvent('Garages:ToggleGarageBlip')
AddEventHandler('Garages:ToggleGarageBlip', function()
    showGarages = not showGarages
    local what = 1
   for _, item in pairs(blips) do
        if not showGarages then
            if item.blip ~= nil then
                RemoveBlip(item.blip)
            end
        else
            item.blip = AddBlipForCoord(item[1], item[2], item[3])
            SetBlipSprite(item.blip, 357)

			if what == 14 then
				AddTextComponentString('Impound Lot')
				SetBlipColour(item.blip, 5)
			else
				SetBlipColour(item.blip, 3)
				AddTextComponentString('Garage ' .. item[4])
			end
			what = what + 1



			SetBlipScale(item.blip, 0.5)
			SetBlipAsShortRange(item.blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Garage " .. item[4])
			EndTextCommandSetBlipName(item.blip)
        end
    end
end)

Citizen.CreateThread(function()
	showGarages = false
	TriggerEvent('Garages:ToggleGarageBlip')
end)
--
VEHICLES = {}
local vente_location = {-45.228, -1083.123, 25.816}
local inrangeofgarage = false
local currentlocation = nil
local garage = {title = "garage", currentpos = nil, marker = { r = 0, g = 155, b = 255, a = 200, type = 1 }}
local selectedGarage = false
selectedPage = 0

--[[Functions]]--

function HouseMenuGarage()
	playerCoords = GetEntityCoords(LocalPed())
	impLocation =  vector3(549.48272705078,-55.188056945801,71.063934326172)
    ped = PlayerPedId();
    --MenuTitle = "Garagessssss"
	ClearMenu()
	selectedPage = 0
    Menu.addButton("Store Vehicle","RentrerVehicule",nil)
    Menu.addButton("Vehicle List","ListeVehicule",0)
	Menu.addButton("Close Menu","CloseMenu",nil)  
end

function MenuGarage()
	enableHgarage = false
	playerCoords = GetEntityCoords(LocalPed())
	impLocation =  vector3(549.48272705078,-55.188056945801,71.063934326172)
    ped = PlayerPedId();
    --MenuTitle = "Garagessssss"
	ClearMenu()
	selectedPage = 0
	--current_used_garage = garages[selectedGarage].garage
	if current_used_garage == "Impound Lot" then
		Menu.addButton("Vehicle List","ListeVehicule",0)
    Menu.addButton("Close Menu","CloseMenu",nil) 
	else
    Menu.addButton("Store Vehicle","RentrerVehicule",nil)
    Menu.addButton("Vehicle List","ListeVehicule",0)
	Menu.addButton("Close Menu","CloseMenu",nil) 
	end
end

function RentrerVehicule()
	TriggerEvent('garages:StoreVehicle',source)
	--TriggerServerEvent('dbfw-garage:CheckForVeh')
	--TriggerEvent('garages:StoreVehicle')
	CloseMenu()
end
carCount = 0
firstCar = 0



function doCarDamages(eh, bh, Fuel, veh)
	smash = false
	damageOutside = false
	damageOutside2 = false 
	local engine = eh + 0.0
	local body = bh + 0.0
	if engine < 200.0 then
		engine = 200.0
	end

	if body < 150.0 then
		body = 150.0
	end
	if body < 550.0 then
		smash = true
	end

	if body < 520.0 then
		damageOutside = true
	end

	if body < 520.0 then
		damageOutside2 = true
	end

	local currentVehicle = (veh and IsEntityAVehicle(veh)) and veh or GetVehiclePedIsIn(PlayerPedId(), false)

	Citizen.Wait(100)
	SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.0)
	end
end


local myspawnedhousecars = {}
nearHouseGarage = false
local currentGarage = GetEntityCoords(PlayerPedId())
RegisterNetEvent('Garages:SpawnHouseGarage')
AddEventHandler('Garages:SpawnHouseGarage', function(z)
	currentGarage = z

	ListeVehicule()

end)
local dntdelete = "none"
RegisterNetEvent('Garages:HouseRemoveVehicle')
AddEventHandler('Garages:HouseRemoveVehicle', function(veh)
	for i = 1, #myspawnedhousecars do
		if myspawnedhousecars[i] == veh then
			table.remove(myspawnedhousecars,i)
		end
	end

	local plate = GetVehicleNumberPlateText(veh)
	SetVehicleHasBeenOwnedByPlayer(veh,true)
	
	local id = NetworkGetNetworkIdFromEntity(veh)
	SetNetworkIdCanMigrate(id, true)
	dntdelete = plate
	TriggerServerEvent('garage:addKeys', plate)
	TriggerServerEvent('garages:SetVehOut', veh, plate)
	TriggerEvent("Garages:ToggleHouse",false)
	TriggerEvent("veh.PlayerOwned",veh)
	Citizen.Wait(1000)
	TriggerServerEvent("garages:CheckGarageForVeh")
end)



RegisterNetEvent('hotel:myroomtype')
AddEventHandler('hotel:myroomtype', function(roomtype)
	myroomtype = roomtype
end)

RegisterNetEvent('Garages:ToggleHouse')
AddEventHandler('Garages:ToggleHouse', function(tg)

	nearHouseGarage = tg
	if nearHouseGarage then

	else
		for i=1,#myspawnedhousecars do
			local plate = GetVehicleNumberPlateText(myspawnedhousecars[i])
			if plate ~= dntdelete then

				--SetEntityAsMissionEntity(myspawnedhousecars[i],false,true)
				--DeleteEntity(myspawnedhousecars[i])
				Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(myspawnedhousecars[i]))
			end
		end
	end

	myspawnedhousecars = {}
	dntdelete = "none"

end)




-- function AddonsHouseCars(veh,v)
	
	
-- 	SetVehicleOnGroundProperly(veh)
-- 	SetEntityInvincible(veh, false) 

-- 	SetVehicleModKit(veh, 0)
-- 	local plate = v.license_plate
-- 	SetVehicleNumberPlateText(veh, plate)
-- 	local customized = v.data
-- 	local plate = GetVehicleNumberPlateText(vehicle)
-- 	TriggerEvent("chop:plateoff",plate)	


-- 	if customized ~= nil then
-- 		SetVehicleWheelType(veh, customized.wheeltype)
-- 		SetVehicleNumberPlateTextIndex(veh, 3)

-- 		for i = 0, 16 do
-- 			SetVehicleMod(veh, i, customized.mods[tostring(i)])
-- 		end

-- 		for i = 17, 22 do
-- 			ToggleVehicleMod(veh, i, customized.mods[tostring(i)])
-- 		end

-- 		for i = 23, 48 do
-- 			SetVehicleMod(veh, i, customized.mods[tostring(i)])
-- 		end

-- 		for i = 0, 3 do
-- 			SetVehicleNeonLightEnabled(veh, i, customized.neon[tostring(i)])
-- 		end

-- 		SetVehicleColours(veh, customized.colors[1], customized.colors[2])
-- 		SetVehicleExtraColours(veh, customized.extracolors[1], customized.extracolors[2])
-- 		SetVehicleNeonLightsColour(veh, customized.lights[1], customized.lights[2], customized.lights[3])
-- 		SetVehicleTyreSmokeColor(veh, customized.smokecolor[1], customized.smokecolor[2], customized.smokecolor[3])
-- 		SetVehicleWindowTint(veh, customized.tint)
-- 	else
-- 		SetVehicleColours(veh, 0, 0)
-- 		SetVehicleExtraColours(veh, 0, 0)
-- 	end
-- 	--SetEntityAsMissionEntity(veh,false,true)

-- 	TriggerEvent("keys:addNew",veh,plate)
-- 	SetVehicleHasBeenOwnedByPlayer(veh,true)
	

-- 	local id = NetworkGetNetworkIdFromEntity(veh)
-- 	SetNetworkIdCanMigrate(id, true)
	
-- 	if GetEntityModel(veh) == `rumpo4` then
-- 		SetVehicleLivery(veh,0)
-- 	end

-- 	if GetEntityModel(veh) == `rumpo` then
-- 		SetVehicleLivery(veh,0)
-- 	end

-- 	if GetEntityModel(veh) == `taxi` then

-- 		SetVehicleExtra(veh, 8, 1)
-- 		SetVehicleExtra(veh, 9, 1)
-- 		SetVehicleExtra(veh, 6, 0)

-- 	end
-- 	doCarDamages(v.engine_damage, v.body_damage, v.fuel, veh)
-- 	myspawnedhousecars[#myspawnedhousecars+1]=veh
-- end

function spawnCars(houseCars)
 	myspawnedhousecars = {}
 	local spawnStart = {}
 	spawnStart.x = currentGarage.x-4.1
 	spawnStart.y = currentGarage.y-14.2
 	spawnStart.z = currentGarage.z+1.0
 	local fuckyou = 1
	for i, v in pairs(houseCars) do
		if i < 7 then

	 		RequestModel(v.model)
			while not HasModelLoaded(v.model) do
				Citizen.Wait(1)
			end
	 		local vehicle = CreateVehicle(v.model,spawnStart.x,spawnStart.y + (i*4.5),spawnStart.z,235.0,true,false)
	 		AddonsHouseCars(vehicle,v)	
	
		else
	 		RequestModel(v.model)
			while not HasModelLoaded(v.model) do
				Citizen.Wait(1)
			end

	 		if i < 12 then
	 			local vehicle = CreateVehicle(v.model,spawnStart.x+7.7,spawnStart.y + (fuckyou*4.5),spawnStart.z,115.0,true,false)	
	 			AddonsHouseCars(vehicle,v)

	 			fuckyou = fuckyou + 1
	 		end
		end
	end

 end

 RegisterNetEvent('house:usingGarage')
 AddEventHandler('house:usingGarage', function()
	enableHgarage = false
 end)

function ListeVehicule(page)
	ped = PlayerPedId();
	selectedPage = page
	MenuTitle = "My Vehicles :"
	ClearMenu()
	local carCount = 0
	DBFWCore.TriggerServerCallback('dbfw-garage:getOwnedCars', function(ownedCars)
		for ind, value in pairs(ownedCars) do
		carCount = carCount + 1
		end 
	end)

	estimate = 15 * (carCount * carCount * 2)

   DBFWCore.TriggerServerCallback('dbfw-garage:getOwnedCars', function(ownedCars)
	   local count = 0
   for ind, value in pairs(ownedCars) do
	   local hashVehicule = value.vehicle.model
	   local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)

	   enginePercent = value.engine_damage / 10
	   bodyPercent = value.body_damage / 10
	   curGarage = value.garage
			plate = value.plate
		   local vehicle_state = value.state
			 if curGarage == nil then
				 curGarage = "Any"
			 end
			if enableHgarage then
				current_used_garage = houseID
			 end
			--if garages[selectedGarage].garage == curGarage then
					if ((count >= (page*10)) and (count < ((page*10)+10))) then
					if vehicle_state == "Standard Impound" then
						Menu.addButton(tostring(vehicleName), "OptionVehicle", value.id, "Impounded: $500", " Engine %:" .. DBFWCore.Math.Round(enginePercent,1) .. "", " Body %:" .. DBFWCore.Math.Round(bodyPercent,1) .. "", "Plate: "..plate.."")
					elseif vehicle_state == "Police Impound" then
						Menu.addButton(tostring(vehicleName), "OptionVehicle", value.id, "Impounded: $1500", " Engine %:" .. DBFWCore.Math.Round(enginePercent,1) .. ""," Body %:" .. DBFWCore.Math.Round(bodyPercent,1) .. "", "Plate: "..plate.."")
					elseif curGarage ~= current_used_garage and curGarage ~= "Any" and vehicle_state ~= "Out" and curGarage ~= "house" then
						Menu.addButton(tostring(vehicleName), "OptionVehicle", 0, curGarage, " Engine %:" .. DBFWCore.Math.Round(enginePercent,1) .. "", " Body %:" .. DBFWCore.Math.Round(bodyPercent,1) .. "", "Plate: "..plate.."")
					--elseif currentGarage == ""
					else

						Menu.addButton(tostring(vehicleName), "OptionVehicle", value.id, tostring(value.state) , " Engine %:" .. DBFWCore.Math.Round(enginePercent,1) .. ""," Body %:" .. DBFWCore.Math.Round(bodyPercent,1) .. "", "Plate: "..plate.."")
					end
				end
			--end
		   count = count + 1
   end  


   Menu.addButton("Next >","ListeVehicule",page+1)
   if page == 0 then
	   Menu.addButton("Return","MenuGarage",nil)
   else		
	   Menu.addButton("Previous","ListeVehicule",page-1)
	   Menu.addButton("Return","MenuGarage",nil)
   end
end) 
    TriggerEvent("DoLongHudTexts", "It will cost $" .. estimate .. " to $" .. estimate + (estimate * 0.15) .. " @ $15 x (carCount x carCount x 2)",1)
		
    Menu.addButton("Return","MenuGarage",nil)
end


RegisterNetEvent('Garages:PhoneUpdate')
AddEventHandler('Garages:PhoneUpdate', function()
	TriggerEvent("phone:Garage",VEHICLES)
end)


function OptionVehicle(vehID)
	local vehID = vehID
	MenuTitle = "Options :"
	ClearMenu()
	if vehID == 0 then
		TriggerEvent('notification', 'You dont have vehicle in this garage', 2)
		Menu.addButton("Return", "ListeVehicule", nil)
	else
    Menu.addButton("Take Out", "SortirVehicule", vehID)
	--Menu.addButton("Supprimer", "SupprimerVehicule", vehID)
	Menu.addButton("Return", "ListeVehicule", nil)
	end
end

function SortirVehicule(vehID)
	local vehID = vehID
	if firstCar == 0 then carCount = 0 end
	local impound = false
	local dist = #(vector3(550.09,-55.45,71.08) - GetEntityCoords(LocalPed()))


	if dist < 15.0 then
		impound = true
	end
	local garagecount = 1
	for i = 1, #garages do
		if current_used_garage == garages[i] then
			garagecount = i
		end
	end
	local garagefree = false

	if addedGarages[current_used_garage] ~= nil then
		garagefree = true
	end
	for i = 1, #garages do
		if garages[i].garage == "House" then
			garagefree = true
		end
	end
	if current_used_garage == "Impound Lot" then
		local garageCost = 500
		TriggerServerEvent('garages:CheckForSpawnVeh', vehID, garageCost)
	else
		local garageCost = 0
	TriggerServerEvent('garages:CheckForSpawnVeh', vehID, garageCost)
	end
	firstCar = 1
	CloseMenu()

end

--[[
function SupprimerVehicule(vehID)
	local vehID = vehID
		TriggerServerEvent('garages:CheckForDelVeh', vehID)
    Menu.addButton("Fermer","CloseMenu",nil) 
end
]]--

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function CloseMenu()
	TriggerEvent("inmenu",false)
    Menu.hidden = true
end

function LocalPed()
	return PlayerPedId()
end

function IsPlayerInRangeOfGarage()
	return inrangeofgarage
end

function Chat(debugg)
    TriggerEvent("chatMessage", '', { 0, 0x99, 255 }, tostring(debugg))
end

isJudge = false
RegisterNetEvent("isJudge")
AddEventHandler("isJudge", function()
	isJudge = true
end)

RegisterNetEvent("isJudgeOff")
AddEventHandler("isJudgeOff", function()
    isJudge = false
end)
RegisterNetEvent("car:dopayment")
AddEventHandler("car:dopayment", function(plate)
	local rankCarshop = exports["isPed"]:GroupRank("car_shop")
    local rankImport = exports["isPed"]:GroupRank("illegal_carshop")
    local salesman = false
	if rankCarshop > 0 or rankImport > 0 then
		salesman = true
	end
	TriggerServerEvent('car:dopayment', plate, salesman)
end)

RegisterNetEvent("car:carpaymentsowed")
AddEventHandler("car:carpaymentsowed", function()
    TriggerServerEvent("car:Outstanding")
end)
if enableHgarage then
	local current_used_garage = houseID
end
current_used_garage = "Any"

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	TriggerEvent("RecreateGarages")
end) 

function spawnJudgeCar(model,garage)

		RequestModel(model)
		while not HasModelLoaded(model) do
		  Wait(1)
		end 

		local playerPed = PlayerPedId()
		local spawnPos = garages[garage].spawn
		local spawned_car = CreateVehicle(model, spawnPos[1], spawnPos[2], spawnPos[3], spawnPos[4], true, false)

		local plate = "TRU ".. GetRandomIntInRange(1000, 9000)

		SetVehicleOnGroundProperly(spawned_car)

		SetVehicleNumberPlateText(spawned_car, plate)
		TriggerServerEvent('garage:addKeys', plate)
		TriggerServerEvent('garges:addJobPlate', plate)

		SetPedIntoVehicle(playerPed, spawned_car, -1)
		--SetEntityAsMissionEntity(spawned_car,false,true)

end

Controlkey = {["generalUse"] = {38,"E"},["generalUseSecondary"] = {18,"Enter"},["generalUseThird"] = {47,"G"}} 
RegisterNetEvent('event:control:update')
AddEventHandler('event:control:update', function(table)
	Controlkey["generalUse"] = table["generalUse"]
	Controlkey["generalUseSecondary"] = table["generalUseSecondary"]
	Controlkey["generalUseThird"] = table["generalUseThird"]
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
			 if enableHgarage then
				local mygarage = json.decode(houseGarage)
				local dist = #(vector3(mygarage.x,mygarage.y,mygarage.z) - GetEntityCoords(LocalPed()))
				if dist < 3.0 then
					DrawMarker(20,mygarage.x,mygarage.y,mygarage.z,0,0,0,0,0,0,0.701,1.0001,0.3001,markerColor.Red,markerColor.Green, markerColor.Blue,dist,0,0,0,0)
					DisplayHelpText('~g~'..Controlkey["generalUse"][2]..'~s~ or ~g~'..Controlkey["generalUseSecondary"][2]..'~s~ Accepts ~g~Arrows~s~ Move ~g~Backspace~s~ Exit')
					if IsControlJustPressed(1, 177) and not Menu.hidden then
						--	MenuCallFunction(Menu.GUI[Menu.selection -1]["func"], Menu.GUI[Menu.selection -1]["args"])
							CloseMenu()
							PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
						end
					if ( IsControlJustPressed(1,Controlkey["generalUse"][1]) or IsControlJustPressed(1,Controlkey["generalUseSecondary"][1]) ) and Menu.hidden then
						TriggerServerEvent("garages:CheckGarageForVeh")
						Citizen.Wait(150)
						HouseMenuGarage()
						TriggerEvent("inmenu",true)
						selectedGarage = k
						Menu.hidden = not Menu.hidden
					end
					Menu.renderGUI()
				end
			end
	end
end)

RegisterNetEvent("RecreateGarages") -- This is the ^(RED) for garage sign
AddEventHandler("RecreateGarages", function()
	Citizen.Wait(5000)
	if not garagesRunning then
		garagesRunning = true
		for k,v in ipairs(garages) do
			Citizen.CreateThread(function()
				if v.disabled then return end
				local pos = v.loc
				local gar = v.garage
				while garagesRunning do
					Citizen.Wait(1)

					local dist = #(vector3(pos[1],pos[2],pos[3]) - GetEntityCoords(LocalPed()))
					if dist < 35.0 then
						dist = math.floor(200 - (dist * 10))
						if dist < 0 then dist = 0 end
						if myroomtype ~= 3 and gar == "House" then

						else
							DrawMarker(20,pos[1],pos[2],pos[3],0,0,0,0,0,0,0.701,1.0001,0.3001,markerColor.Red,markerColor.Green, markerColor.Blue,dist,0,0,0,0)
						end
					end

					if #(vector3(pos[1],pos[2],pos[3]) - GetEntityCoords(LocalPed())) < 3.0 and IsPedInAnyVehicle(LocalPed(), true) == false then
						if Menu.hidden then
							--current_used_garage = garages[k].garage
							if enableHgarage then
								current_used_garage = houseID
							else	
								current_used_garage = garages[k].garage
							end
						else
							DisplayHelpText('~g~'..Controlkey["generalUse"][2]..'~s~ or ~g~'..Controlkey["generalUseSecondary"][2]..'~s~ Accepts ~g~Arrows~s~ Move ~g~Backspace~s~ Exit')
						end

						if IsControlJustPressed(1, 177) and not Menu.hidden then
						--	MenuCallFunction(Menu.GUI[Menu.selection -1]["func"], Menu.GUI[Menu.selection -1]["args"])
							CloseMenu()
							PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
						end
						if (myroomtype ~= 3 and gar == "House") then

						elseif ( IsControlJustPressed(1,Controlkey["generalUse"][1]) or IsControlJustPressed(1,Controlkey["generalUseSecondary"][1]) ) and Menu.hidden then
							TriggerServerEvent("garages:CheckGarageForVeh")
							Citizen.Wait(150)
							MenuGarage()
							TriggerEvent("inmenu",true)
							selectedGarage = k
							Menu.hidden = not Menu.hidden
						
						end
						Menu.renderGUI()
					end
					if dist > 200.0 then
						Citizen.Wait(2000)
					end
				end
			end)
		end
	end
end)





Citizen.CreateThread(function()
	local loc = vente_location
	pos = vente_location
	local blip = AddBlipForCoord(pos[1],pos[2],pos[3])
	SetBlipSprite(blip,207)
	SetBlipColour(blip, 2)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Sell Vehicle')
	EndTextCommandSetBlipName(blip)
	SetBlipAsShortRange(blip,true)
	SetBlipAsMissionCreatorBlip(blip,true)
	SetBlipScale(blip, 0.7)

	checkgarage = 0
	while true do
		
		Wait(1)

		DrawMarker(27,376.6728515625,-1612.5723876953,28.29195022583,0,0,0,0,0,0,3.001,3.0001,0.5001,0,155,255,50,0,0,0,0)
		if isJudge and #(vector3(376.6728515625,-1612.5723876953,29.29195022583) - GetEntityCoords(LocalPed())) < 5 and IsPedInAnyVehicle(LocalPed(), true) == false then
			DisplayHelpText('Press on ~g~'..Controlkey["generalUse"][2]..'~s~ to sell this vehicle for the state!')		
			if IsControlJustPressed(1,Controlkey["generalUse"][1]) then
				local caissei = GetClosestVehicle(376.6728515625,-1612.5723876953,29.29195022583, 3.000, 0, 70)
				if not DoesEntityExist(caissei) then caissei = GetVehiclePedIsIn(PlayerPedId(), true) end
				if DoesEntityExist(caissei) then
					local plate = GetVehicleNumberPlateText(caissei)
					TriggerServerEvent('garages:SelVehJudge',plate)
					--SetEntityAsMissionEntity(caissei,false,true)
					Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(caissei))
				else
					TriggerEvent("DoLongHudTexts","No Vehicle",2)
				end
			end
		end

		wait2 = #(vector3(376.6728515625,-1612.5723876953,29.29195022583) - GetEntityCoords(LocalPed()))
		if wait2 > 50.0 then
			if wait2 then
				Citizen.Wait(math.ceil(wait2) * 10)
			end
		end

	end

end)


-- HudStage = 1
-- RegisterNetEvent('DoLongHudTexts')
-- AddEventHandler('DoLongHudTexts', function(text,color,length)
--     if HudStage > 2 then return end
--     if not color then color = 1 end
--     if not length then length = 12000 end
--     TriggerEvent("tasknotify:guiupdate",color, text, 12000)
-- end)


--[[Events]]--
RegisterNetEvent("garages:getVehicles")
AddEventHandler("garages:getVehicles", function(ownedCars)
	DBFWCore.TriggerServerCallback('dbfw-garage:getOwnedCars', function(ownedCars)
		if #ownedCars == 0 then
		else
		end
   VEHICLES = {}
	VEHICLES = ownedCars
	end)
end)

-- AddEventHandler("playerSpawned", function()
--     TriggerServerEvent("garages:CheckGarageForVeh")
-- end)

RegisterNetEvent('garages:SpawnVehicle')
--AddEventHandler('garages:SpawnVehicle', function(vehicle, plate, customized, state, Fuel, coordlocation)
AddEventHandler('garages:SpawnVehicle', function(vehicle, plate, state, fuelSet)
	local loc = ""
	if enableHgarage then
		loc = json.decode(houseGarage)
		
	else
		loc = garages[selectedGarage].loc
	end

	local car = GetHashKey(vehicle.model)

	Citizen.CreateThread(function()			
		Citizen.Wait(1000)
		local caisseo = ""
		if enableHgarage then
			caisseo = GetClosestVehicle(loc.x,loc.y,loc.z, 3.000, 0, 70)
		else
			caisseo = GetClosestVehicle(loc[1], loc[2], loc[3], 3.000, 0, 70)
		end
		if DoesEntityExist(caisseo) then

			TriggerEvent("DoShortHudText", "The area is crowded",2)

		else
			if state == "Out" and coordlocation == nil then
				TriggerEvent("DoShortHudText","Not in garage",2)
			else	

				if state == "Normal Impound" then
					TriggerEvent("DoLongHudTexts","This vehicle cost you $100.",1)
				end

				if state == "Police Impound" then
					TriggerEvent("DoLongHudTexts","This vehicle cost you $1500.",1)
				end
				 local spawnPos = ""
					if enableHgarage then
						spawnPos = json.decode(houseGarage)
					else
						spawnPos = garages[selectedGarage].spawn
					end

					if coordlocation ~= nil then
						--veh = CreateVehicle(car, coordlocation[1],coordlocation[2],coordlocation[3], 0.0, true, false)
							veh = SpawnVehicle(vehicle, plate, fuelSet, coordlocation[1],coordlocation[2],coordlocation[3], 0.0)

					else
						--veh = CreateVehicle(car, spawnPos[1], spawnPos[2], spawnPos[3], spawnPos[4], true, false)
						if enableHgarage then
							veh = SpawnVehicle(vehicle, plate, fuelSet, spawnPos.x,spawnPos.y,spawnPos.z, 0.0)
						else
							veh = SpawnVehicle(vehicle, plate, fuelSet, spawnPos[1], spawnPos[2], spawnPos[3], spawnPos[4])
						end
						
					end
					
			end
			
		end
		TriggerServerEvent("garages:CheckGarageForVeh")
	end)
end)


SetFuel = function(vehicle, fuel)



    DecorSetInt(vehicle, "CurrentFuel", fuel)

end



function GetFuel(vehicle)

	return DecorGetInt(vehicle, "CurrentFuel")

end

function SpawnVehicle(vehicle, plate, fuelSet, spawnx, spawny, spawx, spawnz)
	
	DBFWCore.Game.SpawnVehicle(vehicle.model, {
		x = spawnx,
		y = spawny,
		z = spawx
	}, spawnz, function(callback_vehicle)
		SetVehicleProperties(callback_vehicle, vehicle, fuelSet)
		doCarDamages(vehicle.engineHealth, vehicle.bodyHealth, fuelSet, callback_vehicle)
		--DBFWCore.Game.SetVehicleProperties(callback_vehicle, vehicle)
		--SetVehicleProperties(callback_vehicle, vehicleProps)
		-- -- Fuel = vehicle.fuelLevel
		-- if Fuel < 5 then
		-- 	Fuel = 5
		-- end
		
		-- local Fuels = round(Fuel)
		
		-- DecorSetInt(callback_vehicle, "CurrentFuel", Fuels)
		NetworkFadeInEntity(callback_vehicle, true, true)
		SetModelAsNoLongerNeeded(vehicle.model)
		SetVehRadioStation(callback_vehicle, "OFF")
		SetVehicleNumberPlateText(callback_vehicle, plate)
		SetVehicleHasBeenOwnedByPlayer(callback_vehicle,true)
		SetPedIntoVehicle(PlayerPedId(), callback_vehicle, - 1)	
		SetModelAsNoLongerNeeded(vehicle.model)
		SetEntityAsMissionEntity(callback_vehicle, true, true)
		TriggerServerEvent('garage:addKeys', GetVehicleNumberPlateText(callback_vehicle))
		TriggerServerEvent('garages:SetVehOut', callback_vehicle, plate)
	end)
	
	TriggerServerEvent('dbfw-advancedgarage:setVehicleState', plate, false)
end

function round( n )

    return math.floor( n + 0.5 )

end

SetVehicleProperties = function(vehicle, vehicleProps, fuelSet)
    DBFWCore.Game.SetVehicleProperties(vehicle, vehicleProps)

    SetVehicleEngineHealth(vehicle, vehicleProps["engineHealth"] and vehicleProps["engineHealth"] + 0.0 or 1000.0)
    SetVehicleBodyHealth(vehicle, vehicleProps["bodyHealth"] and vehicleProps["bodyHealth"] + 0.0 or 1000.0)
	--SetVehicleFuelLevel(vehicle, vehicleProps["fuelLevel"] and vehicleProps["fuelLevel"] + 0.0 or 1000.0)
	fuelMe = round(fuelSet)
	DecorSetInt(vehicle, "CurrentFuel", fuelMe)
    if vehicleProps["windows"] then
        for windowId = 1, 13, 1 do
            if vehicleProps["windows"][windowId] == false then
                SmashVehicleWindow(vehicle, windowId)
            end
        end
    end

    if vehicleProps["tyres"] then
        for tyreId = 1, 7, 1 do
            if vehicleProps["tyres"][tyreId] ~= false then
                SetVehicleTyreBurst(vehicle, tyreId, true, 1000)
            end
        end
    end

    if vehicleProps["doors"] then
        for doorId = 0, 5, 1 do
            if vehicleProps["doors"][doorId] ~= false then
                SetVehicleDoorBroken(vehicle, doorId - 1, true)
            end
        end
    end
end

GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = DBFWCore.Game.GetVehicleProperties(vehicle)

        vehicleProps["tyres"] = {}
        vehicleProps["windows"] = {}
        vehicleProps["doors"] = {}

        for id = 1, 7 do
            local tyreId = IsVehicleTyreBurst(vehicle, id, false)
        
            if tyreId then
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = tyreId
        
                if tyreId == false then
                    tyreId = IsVehicleTyreBurst(vehicle, id, true)
                    vehicleProps["tyres"][ #vehicleProps["tyres"]] = tyreId
                end
            else
                vehicleProps["tyres"][#vehicleProps["tyres"] + 1] = false
            end
        end

        -- for id = 1, 13 do
        --     local windowId = IsVehicleWindowIntact(vehicle, id)

        --     if windowId ~= nil then
        --         vehicleProps["windows"][#vehicleProps["windows"] + 1] = windowId
        --     else
        --         vehicleProps["windows"][#vehicleProps["windows"] + 1] = true
        --     end
        -- end
        
        for id = 0, 5 do
            local doorId = IsVehicleDoorDamaged(vehicle, id)
        
            if doorId then
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = doorId
            else
                vehicleProps["doors"][#vehicleProps["doors"] + 1] = false
            end
        end

        vehicleProps["engineHealth"] = GetVehicleEngineHealth(vehicle)
        vehicleProps["bodyHealth"] = GetVehicleBodyHealth(vehicle)
		--vehicleProps["fuelLevel"] = GetFuel(vehicle)

        return vehicleProps
    end
end

AddEventHandler('garages:StoreVehicle', function()
	ClearMenu()

    coordA = GetEntityCoords(PlayerPedId(), 1)

    coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 100.0, 0.0)

    local vehicle = GetClosestVehicle(coordA.x, coordA.y, coordA.z, 20.000, 0, 70)

    local vehicleProps = GetVehicleProperties(vehicle)

    
	if not DoesEntityExist(vehicle) then

		TriggerEvent('DoLongHudText', 'No Vehicle', 2)

		CloseMenu()
	else
		local pos = ""
		if enableHgarage then
			pos = houseID
			current_used_garage = houseID
		else
			pos = garages[selectedGarage].loc
			current_used_garage = garages[selectedGarage].garage
		end
	
	
	

			
			local vehicleProps = GetVehicleProperties(vehicle)

			
			Citizen.Wait(300)
			local plate = GetVehicleNumberPlateText(vehicle)
	
			local realFuel = DecorGetInt(vehicle, "CurrentFuel")
			--NetworkFadeOutEntity(vehicle, true, true)
	
			TriggerEvent('DoLongHudText', 'You saved your vehicle in garage '..current_used_garage, 1)
	
			Citizen.Wait(500)
	
	
	
			deleteCar(vehicle)
			
			local livery = GetVehicleLivery(vehicle)
			TriggerServerEvent('garages:SetVehIn', plate, current_used_garage, vehicleProps, livery, realFuel)
			--TriggerServerEvent('dbfw-garage:modifystate', vehicleProps, 1, garage)
	
			CloseMenu()
	
		end
	
end)

function deleteCar( entity )

    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )

end

function getVehicleInDirection(coordFrom, coordTo)

    local offset = 0

    local rayHandle

    local vehicle



    for i = 0, 100 do

        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)   

        a, b, c, d, vehicle = GetRaycastResult(rayHandle)

        

        offset = offset - 1



        if vehicle ~= 0 then break end

    end

    

    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))

    print(distance)

    if distance > 100000 then vehicle = nil end



    return vehicle ~= nil and vehicle or 0

end

AddEventHandler('garages:SelVehicle', function(vehicle, plate)
	local car = GetHashKey(vehicle)	
	local plate = plate
	Citizen.CreateThread(function()		
		Citizen.Wait(0)
		local caissei = GetClosestVehicle(215.124, -791.377, 30.836, 3.000, 0, 70)
		if not DoesEntityExist(caissei) then caissei = GetVehiclePedIsIn(PlayerPedId(), true) end
		--SetEntityAsMissionEntity(caissei,false,true)
		local platecaissei = GetVehicleNumberPlateText(caissei)
		if DoesEntityExist(caissei) then	
			if plate ~= platecaissei then					
				TriggerEvent("DoLongHudTexts","It's not your vehicle",2)
			else
				TriggerEvent('keys:remove', platecaissei)
				Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(caissei))
				TriggerServerEvent('garages:SelVeh', plate)
				TriggerServerEvent("garages:CheckGarageForVeh")
			end
		else
			TriggerEvent("DoLongHudTexts","No Vehicle",2)
		end   
	end)
end)
waitingForAccept = true
local isWanting = false
local previousPlayer = 0
RegisterNetEvent('garages:SellToPlayer')
AddEventHandler('garages:SellToPlayer', function(price,plate,player)
	if waitingForAccept then
		waitingForAccept = false
		TriggerServerEvent("CancelSale",previousPlayer)
		Citizen.Wait(1000)
	end

	waitingForAccept = true
	price = tonumber(price)
	player = tonumber(player)
	if price <= 0 then return end
	if player <= 0 then return end
	previousPlayer = player
	local car = GetHashKey(vehicle)	
	local plate = plate
	Citizen.CreateThread(function()		
		Citizen.Wait(0)
		local targetPed = GetPlayerFromServerId(player)
		if not DoesEntityExist(GetPlayerPed(targetPed)) then
			TriggerEvent("DoLongHudTexts","No Person",2)
			return
		end
		local pos = GetEntityCoords(PlayerPedId())
		local pos2 = GetEntityCoords(GetPlayerPed(targetPed))
		if #(vector3(pos.x,pos.y,pos.z) - vector3(pos2.x,pos2.y,pos2.z)) < 40 then
			local caissei = GetClosestVehicle(pos.x,pos.y,pos.z, 3.000, 0, 70)
			if not DoesEntityExist(caissei) then caissei = GetVehiclePedIsIn(PlayerPedId(), true) end
			local platecaissei = GetVehicleNumberPlateText(caissei)
			if DoesEntityExist(caissei) then	
				if plate ~= platecaissei then					
					TriggerEvent("DoLongHudTexts","It's not your vehicle",2)
				else
					TriggerServerEvent('garages:askRequest',player)
					while waitingForAccept do
						Wait(5)
						DisplayHelpText('Waiting for other person to decide.')
					end
					if isWanting then
						TriggerServerEvent('garages:SellToPlayerEnd', plate,player,price)
					else
						TriggerEvent("DoLongHudTexts","Person has declined.",2)
					end
				end
			else
				TriggerEvent("DoLongHudTexts","No Vehicle",2)
			end
		else
			TriggerEvent("DoLongHudTexts","Not close enough.",2)
		end
	end)
end)

local making = false
RegisterNetEvent('CancelNow')
AddEventHandler('CancelNow', function()
	making = false
end)	

RegisterNetEvent('garages:askingForVeh')
AddEventHandler('garages:askingForVeh', function(source)
	making = true
	Citizen.CreateThread(function()	
		while making do	
			Citizen.Wait(3)
			DisplayHelpText('~g~'..Controlkey["generalUse"][2]..'~s~ to Accept Car ,~g~'..Controlkey["generalUseSecondary"][2]..'~s~ to Refuse Car.')

			if ( IsControlJustPressed(1,Controlkey["generalUse"][1])) then
				TriggerServerEvent('garages:askResult',source,true)
				making = false
			elseif IsControlJustPressed(1,Controlkey["generalUseSecondary"][1]) then
				making = false
				TriggerServerEvent('garages:askResult',source,false)
			end
		end
	end)
end)

RegisterNetEvent('garages:clientResult')
AddEventHandler('garages:clientResult', function(result)
	waitingForAccept = false
	isWanting = result
end)

RegisterNetEvent('garages:ClientEnd')
AddEventHandler('garages:ClientEnd', function(plate)
	Citizen.CreateThread(function()		
		Citizen.Wait(0)
		local pos = GetEntityCoords(PlayerPedId())
		local caissei = GetClosestVehicle(pos.x,pos.y,pos.z, 3.000, 0, 70)
		if not DoesEntityExist(caissei) then caissei = GetVehiclePedIsIn(PlayerPedId(), true) end
		local platecaissei = GetVehicleNumberPlateText(caissei)
		if DoesEntityExist(caissei) then
			TriggerEvent('keys:remove', platecaissei)
			TriggerServerEvent("garages:CheckGarageForVeh")
		else
			TriggerEvent("DoLongHudTexts","No Vehicle",2)
		end   
	end)
end)

RegisterNetEvent('garages:PlayerEnd')
AddEventHandler('garages:PlayerEnd', function(plate)
	Citizen.CreateThread(function()		
		Citizen.Wait(0)
		local pos = GetEntityCoords(PlayerPedId())
		local caissei = GetClosestVehicle(pos.x,pos.y,pos.z, 3.000, 0, 70)
		if not DoesEntityExist(caissei) then caissei = GetVehiclePedIsIn(PlayerPedId(), true) end
		local platecaissei = GetVehicleNumberPlateText(caissei)
		if DoesEntityExist(caissei) then	
			TriggerServerEvent('garage:addKeys', plate)
			TriggerServerEvent("garages:CheckGarageForVeh")
		else
			TriggerEvent("DoLongHudTexts","No Vehicle",2)
		end   
	end)
end)

local colorblind = false
RegisterNetEvent('option:colorblind')
AddEventHandler('option:colorblind',function()
	colorblind = not colorblind

	if colorblind then
		markerColor = 
		{
			["Red"] = 200,
			["Green"] = 200,
			["Blue"] = 0
		}
	else 
		markerColor = 
		{
			["Red"] = 222,
			["Green"] = 50,
			["Blue"] = 50
		}
	end
end)

RegisterNetEvent('hotel:outfit')
AddEventHandler('hotel:outfit', function(args,sentType)
	if nearClothing then
		if sentType == 1 then
			local id = args[2]
			table.remove(args, 1)
			table.remove(args, 1)
			strng = ""
			for i = 1, #args do
				strng = strng .. " " .. args[i]
			end
			TriggerEvent("raid_clothes:outfits", sentType, id, strng)
		elseif sentType == 2 then
			local id = args[2]
			TriggerEvent("raid_clothes:outfits", sentType, id)
		elseif sentType == 3 then
			local id = args[2]
			TriggerEvent('item:deleteClothesDna')
			TriggerEvent('InteractSound_CL:PlayOnOne','Clothes1', 0.6)
			TriggerEvent("raid_clothes:outfits", sentType, id)
		else
			TriggerServerEvent("raid_clothes:list_outfits")
		end
	end
end)

function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

