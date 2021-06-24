DBFWCore.Trace = function(str)
	if Config.EnableDebug then
		print('DBFWCore> ' .. str)
	end
end

DBFWCore.SetTimeout = function(msec, cb)
	local id = DBFWCore.TimeoutCount + 1

	SetTimeout(msec, function()
		if DBFWCore.CancelledTimeouts[id] then
			DBFWCore.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	DBFWCore.TimeoutCount = id

	return id
end

DBFWCore.ClearTimeout = function(id)
	DBFWCore.CancelledTimeouts[id] = true
end

DBFWCore.RegisterServerCallback = function(name, cb)
	DBFWCore.ServerCallbacks[name] = cb
end

DBFWCore.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if DBFWCore.ServerCallbacks[name] ~= nil then
		DBFWCore.ServerCallbacks[name](source, cb, ...)
	else
		print('dbfw-core: TriggerServerCallback => [' .. name .. '] does not exist')
	end
end

DBFWCore.SavePlayer = function(xPlayer, cb)
	local asyncTasks = {}
	xPlayer.setLastPosition(xPlayer.getCoords())

	-- User accounts
	for i=1, #xPlayer.accounts, 1 do
		if DBFWCore.LastPlayerData[xPlayer.source].accounts[xPlayer.accounts[i].name] ~= xPlayer.accounts[i].money then
			table.insert(asyncTasks, function(cb)
				MySQL.Async.execute('UPDATE user_accounts SET money = @money WHERE identifier = @identifier AND name = @name', {
					['@money']      = xPlayer.accounts[i].money,
					['@identifier'] = xPlayer.identifier,
					['@name']       = xPlayer.accounts[i].name
				}, function(rowsChanged)
					cb()
				end)
			end)

			DBFWCore.LastPlayerData[xPlayer.source].accounts[xPlayer.accounts[i].name] = xPlayer.accounts[i].money
		end
	end
	
	-- Job, loadout and position
	table.insert(asyncTasks, function(cb)
		MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade, loadout = @loadout, position = @position WHERE identifier = @identifier', {
			['@job']        = xPlayer.job.name,
			['@job_grade']  = xPlayer.job.grade,
			['@loadout']    = json.encode(xPlayer.getLoadout()),
			['@position']   = json.encode(xPlayer.getLastPosition()),
			['@identifier'] = xPlayer.identifier
		}, function(rowsChanged)
			cb()
		end)
	end)

	Async.parallel(asyncTasks, function(results)
		RconPrint('\27[32m[dbfw-core] [Saving Player]\27[0m ' .. xPlayer.name .. "^7\n")

		if cb ~= nil then
			cb()
		end
	end)
end

DBFWCore.SavePlayers = function(cb)
	local asyncTasks = {}
	local xPlayers   = DBFWCore.GetPlayers()

	for i=1, #xPlayers, 1 do
		table.insert(asyncTasks, function(cb)
			local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
			DBFWCore.SavePlayer(xPlayer, cb)
		end)
	end

	Async.parallelLimit(asyncTasks, 8, function(results)
		RconPrint('\27[32m[dbfw-core] [Saving All Players]\27[0m' .. "\n")

		if cb ~= nil then
			cb()
		end
	end)
end

DBFWCore.StartDBSync = function()
	function saveData()
		DBFWCore.SavePlayers()
		SetTimeout(10 * 60 * 1000, saveData)
	end

	SetTimeout(10 * 60 * 1000, saveData)
end

DBFWCore.GetPlayers = function()
	local sources = {}

	for k,v in pairs(DBFWCore.Players) do
		table.insert(sources, k)
	end

	return sources
end


DBFWCore.GetPlayerFromId = function(source)
	return DBFWCore.Players[tonumber(source)]
end

DBFWCore.GetPlayerFromIdentifier = function(identifier)
	for k,v in pairs(DBFWCore.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

DBFWCore.RegisterUsableItem = function(item, cb)
	DBFWCore.UsableItemsCallbacks[item] = cb
end

DBFWCore.UseItem = function(source, item)
	DBFWCore.UsableItemsCallbacks[item](source)
end

DBFWCore.GetItemLabel = function(item)
	if DBFWCore.Items[item] ~= nil then
		return DBFWCore.Items[item].label
	end
end

DBFWCore.CreatePickup = function(type, name, count, label, player)
	local pickupId = (DBFWCore.PickupId == 65635 and 0 or DBFWCore.PickupId + 1)

	DBFWCore.Pickups[pickupId] = {
		type  = type,
		name  = name,
		count = count
	}

	TriggerClientEvent('dbfw:pickup', -1, pickupId, label, player)
	DBFWCore.PickupId = pickupId
end

DBFWCore.DoesJobExist = function(job, grade)
	grade = tostring(grade)

	if job and grade then
		if DBFWCore.Jobs[job] and DBFWCore.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end