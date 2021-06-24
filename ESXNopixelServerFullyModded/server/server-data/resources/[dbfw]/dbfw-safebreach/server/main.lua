local DBFWCore = nil

local cachedSafes = {}

TriggerEvent('dbfw:getSharedObject', function(obj) 
	DBFWCore = obj 
end)

RegisterServerEvent("safebreach:globalEvent")
AddEventHandler("safebreach:globalEvent", function(options)
    -- DBFWCore.Trace((options["event"] or "none") .. " triggered to all clients.")

	if options["data"] and options["data"]["save"] then
		if not cachedSafes[options["data"]["store"]] then
			cachedSafes[options["data"]["store"]] = {
				["breacher"] = GetPlayerName(source),
				["safeCoords"] = options["data"]["doorCoords"],
				["timeBreached"] = os.time()
			}
		end

		cachedSafes[options["data"]["store"]]["saveData"] = options["data"]
	end

    TriggerClientEvent("safebreach:eventHandler", -1, options["event"] or "none", options["data"] or nil)
end)

DBFWCore.RegisterServerCallback("safebreach:checkSafeBreaches", function(source, cb)
	local player = DBFWCore.GetPlayerFromId(source)

	if player then
		for safeStore, safeData in pairs(cachedSafes) do
			if safeData["saveData"] then
				TriggerClientEvent("safebreach:eventHandler", source, "open_door", safeData["saveData"])
			end
		end

		cb(true)
	else
		cb(false)	
	end
end)

DBFWCore.RegisterServerCallback("safebreach:checkIfSafeIsBreachable", function(source, cb, safe)
	local player = DBFWCore.GetPlayerFromId(source)

	if player then
		if cachedSafes[safe] then
			cb(false)
		else
			local policeMen = 0

			local players = DBFWCore.GetPlayers()

			for i = 1, #players do
				local player = DBFWCore.GetPlayerFromId(players[i])

				if player and player["job"]["name"] == "police" then
					policeMen = policeMen + 1
				end
			end

			if policeMen >= Config.PoliceRequired then
				cb(true)
			else
				cb(false)
			end
		end
	else
		cb(false)	
	end
end)

DBFWCore.RegisterServerCallback("safebreach:safeBreached", function(source, cb, safeData)
	local player = DBFWCore.GetPlayerFromId(source)

	if player then
		if cachedSafes[safeData["store"]] then
			cb(false)

			return
		end

		cachedSafes[safeData["store"]] = {
			["breacher"] = player["name"],
			["safeCoords"] = safeData["doorCoords"],
			["timeBreached"] = os.time()
		}

		StartTimer(safeData)

		cb(true)
	else
		cb(false)
	end
end)

DBFWCore.RegisterServerCallback("safebreach:receiveReward", function(source, cb, reward)
	local player = DBFWCore.GetPlayerFromId(source)

	if player then
		if reward then
			if reward == "money" then
				local _source = source
				local xPlayer = DBFWCore.GetPlayerFromId(_source)
				local randomChance = math.random(1, 100)
				local payout = math.random(1,3)			
				TriggerClientEvent('player:receiveItem', _source, 'rollcash', payout)

				if randomChance < 30 then
					TriggerClientEvent('player:receiveItem', _source, 'Gruppe6Card3', 1)
				end
			end

			cb(true)
		else
			cb(false)
		end
	else
		cb(false)
	end
end)

StartTimer = function(safeData)
	Citizen.CreateThread(function()
		while (os.time() - cachedSafes[safeData["store"]]["timeBreached"]) < Config.SafeCooldown do
			Citizen.Wait(0)
		end

		cachedSafes[safeData["store"]] = nil

		TriggerClientEvent("safebreach:eventHandler", -1, "close_door", {
			["store"] = safeData["store"],
			["safeCoords"] = safeData["doorCoords"],
			["doorRotation"] = safeData["doorRotation"]
		})
	end)
end
