DBFWCore                 = nil
Jobs                = {}
RegisteredSocieties = {}

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

function GetSociety(name)
	for i=1, #RegisteredSocieties, 1 do
		if RegisteredSocieties[i].name == name then
			return RegisteredSocieties[i]
		end
	end
end

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result, 1 do
		Jobs[result[i].name]        = result[i]
		Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2, 1 do
		Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
	end
end)

AddEventHandler('dbfw-society:registerSociety', function(name, label, account, datastore, inventory, data)
	local found = false

	local society = {
		name      = name,
		label     = label,
		account   = account,
		datastore = datastore,
		inventory = inventory,
		data      = data,
	}

	for i=1, #RegisteredSocieties, 1 do
		if RegisteredSocieties[i].name == name then
			found                  = true
			RegisteredSocieties[i] = society
			break
		end
	end

	if not found then
		table.insert(RegisteredSocieties, society)
	end
end)

AddEventHandler('dbfw-society:getSocieties', function(cb)
	cb(RegisteredSocieties)
end)

AddEventHandler('dbfw-society:getSociety', function(name, cb)
	cb(GetSociety(name))
end)

RegisterServerEvent('dbfw-society:withdrawMoney')
AddEventHandler('dbfw-society:withdrawMoney', function(society, amount)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local society = GetSociety(society)

	TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function(account)
		if amount > 0 and account.money >= amount then
			account.removeMoney(amount)
			xPlayer.addMoney(amount)

			TriggerClientEvent('DoLongHudText', xPlayer.source, _U('have_withdrawn', amount), 1)
		else
			TriggerClientEvent('DoLongHudText', xPlayer.source, _U('invalid_amount'), 2)
		end
	end)
end)

RegisterServerEvent('dbfw-society:depositMoney')
AddEventHandler('dbfw-society:depositMoney', function(society, amount)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local society = GetSociety(society)

	if amount > 0 and xPlayer.get('money') >= amount then

		TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function(account)
			xPlayer.removeMoney(amount)
			account.addMoney(amount)
		end)

		TriggerClientEvent('DoLongHudText', xPlayer.source, _U('have_deposited', amount), 1)

	else
		TriggerClientEvent('DoLongHudText', xPlayer.source, _U('invalid_amount'), 2)
	end
end)

RegisterServerEvent('dbfw-society:washMoney')
AddEventHandler('dbfw-society:washMoney', function(society, amount)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local account = xPlayer.getAccount('black_money')
	amount = tonumber(amount)
	if amount and amount > 0 and account.money >= amount then

		xPlayer.removeAccountMoney('black_money', amount)

		MySQL.Async.execute('INSERT INTO society_moneywash (identifier, society, amount) VALUES (@identifier, @society, @amount)',
		{
			['@identifier'] = xPlayer.identifier,
			['@society']    = society,
			['@amount']     = amount
		}, function(rowsChanged)
			TriggerClientEvent('DoLongHudText', xPlayer.source, _U('you_have', amount), 1)
		end)

	else
		TriggerClientEvent('DoLongHudText', xPlayer.source, _U('invalid_amount'), 2)
	end

end)

RegisterServerEvent('dbfw-society:putVehicleInGarage')
AddEventHandler('dbfw-society:putVehicleInGarage', function(societyName, vehicle)
	local society = GetSociety(societyName)

	TriggerEvent('dbfw-datastore:getSharedDataStore', society.datastore, function(store)
		local garage = store.get('garage') or {}
		table.insert(garage, vehicle)
		store.set('garage', garage)
	end)
end)

RegisterServerEvent('dbfw-society:removeVehicleFromGarage')
AddEventHandler('dbfw-society:removeVehicleFromGarage', function(societyName, vehicle)
	local society = GetSociety(societyName)

	TriggerEvent('dbfw-datastore:getSharedDataStore', society.datastore, function(store)
		local garage = store.get('garage') or {}

		for i=1, #garage, 1 do
			if garage[i].plate == vehicle.plate then
				table.remove(garage, i)
				break
			end
		end

		store.set('garage', garage)
	end)
end)

DBFWCore.RegisterServerCallback('dbfw-society:getSocietyMoney', function(source, cb, societyName)
	local society = GetSociety(societyName)

	if society ~= nil then

		TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function(account)
			cb(account.money)
		end)

	else
		cb(0)
	end
end)

DBFWCore.RegisterServerCallback('dbfw-society:getEmployees', function(source, cb, society)
	if Config.EnableDBFWCoreIdentity then

		MySQL.Async.fetchAll('SELECT * FROM users WHERE job = @job ORDER BY job_grade DESC', {
			['@job'] = society
		}, function (results)
			local employees = {}

			for i=1, #results, 1 do
				table.insert(employees, {
					name       = results[i].firstname .. ' ' .. results[i].lastname,
					identifier = results[i].identifier,
					job = {
						name        = results[i].job,
						label       = Jobs[results[i].job].label,
						grade       = results[i].job_grade,
						grade_name  = Jobs[results[i].job].grades[tostring(results[i].job_grade)].name,
						grade_label = Jobs[results[i].job].grades[tostring(results[i].job_grade)].label,
					}
				})
			end

			cb(employees)
		end)
	else
		MySQL.Async.fetchAll('SELECT * FROM users WHERE job = @job ORDER BY job_grade DESC', {
			['@job'] = society
		}, function (result)
			local employees = {}

			for i=1, #result, 1 do
				table.insert(employees, {
					name       = result[i].name,
					identifier = result[i].identifier,
					job = {
						name        = result[i].job,
						label       = Jobs[result[i].job].label,
						grade       = result[i].job_grade,
						grade_name  = Jobs[result[i].job].grades[tostring(result[i].job_grade)].name,
						grade_label = Jobs[result[i].job].grades[tostring(result[i].job_grade)].label,
					}
				})
			end

			cb(employees)
		end)
	end
end)

DBFWCore.RegisterServerCallback('dbfw-society:getJob', function(source, cb, society)
	local job    = json.decode(json.encode(Jobs[society]))
	local grades = {}

	for k,v in pairs(job.grades) do
		table.insert(grades, v)
	end

	table.sort(grades, function(a, b)
		return a.grade < b.grade
	end)

	job.grades = grades
	cb(job)
end)


DBFWCore.RegisterServerCallback('dbfw-society:setJob', function(source, cb, identifier, job, grade, type)

	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local xTarget = DBFWCore.GetPlayerFromIdentifier(identifier)

	if xTarget ~= nil then
		xTarget.setJob(job, grade)
		
		if type == 'hire' then
			TriggerClientEvent('DoLongHudText', xTarget.source, _U('you_have_been_hired', job), 1)
		elseif type == 'promote' then
			TriggerClientEvent('DoLongHudText', xTarget.source, _U('you_have_been_promoted'), 1)
		elseif type == 'fire' then
			TriggerClientEvent('DoLongHudText', xTarget.source, _U('you_have_been_fired', xTarget.getJob().label), 1)
		end

		cb()
	else
		MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier',
		{
			['@job']        = job,
			['@job_grade']  = grade,
			['@identifier'] = identifier
		}, function(rowsChanged)
			cb()
		end)
	end

end)

DBFWCore.RegisterServerCallback('dbfw-society:setJobSalary', function(source, cb, job, grade, salary)

	MySQL.Async.execute('UPDATE job_grades SET salary = @salary WHERE job_name = @job_name AND grade = @grade',
	{
		['@salary']   = salary,
		['@job_name'] = job,
		['@grade']    = grade
	}, function(rowsChanged)

		Jobs[job].grades[tostring(grade)].salary = salary
		local xPlayers = DBFWCore.GetPlayers()

		for i=1, #xPlayers, 1 do

			local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == job and xPlayer.job.grade == grade then
				xPlayer.setJob(job, grade)
			end

		end

		cb()
	end)

end)

DBFWCore.RegisterServerCallback('dbfw-society:getOnlinePlayers', function(source, cb)
	local xPlayers = DBFWCore.GetPlayers()
	local players  = {}

	for i=1, #xPlayers, 1 do
		local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
			name       = xPlayer.name,
			job        = xPlayer.job
		})
	end

	cb(players)
end)

DBFWCore.RegisterServerCallback('dbfw-society:getVehiclesInGarage', function(source, cb, societyName)
	local society = GetSociety(societyName)
	TriggerEvent('dbfw-datastore:getSharedDataStore', society.datastore, function(store)
		local garage = store.get('garage') or {}
		cb(garage)
	end)
end)

DBFWCore.RegisterServerCallback('dbfw-society:isBoss', function(source, cb, jobName)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	if xPlayer.job.name == jobName then
		if xPlayer.job.name == 'police' then
			if xPlayer.job.grade_name == 'boss' or xPlayer.job.grade_name == 'assistantchief' or xPlayer.job.grade_name == 'captain' then
				cb(true)
			end
		elseif xPlayer.job.grade_name == 'boss' then
			cb(true)
		end
	else
		cb(false)
	end
end)

function WashMoneyCRON(d, h, m)
	MySQL.Async.fetchAll('SELECT * FROM society_moneywash', {}, function(result)
		for i=1, #result, 1 do

			-- add society money
			local society = GetSociety(result[i].society)
			TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function(account)
				account.addMoney(result[i].amount)
			end)

			-- send notification if player is online
			local xPlayer = DBFWCore.GetPlayerFromIdentifier(result[i].identifier)
			if xPlayer ~= nil then
				TriggerClientEvent('DoLongHudText', xPlayer.source, _U('you_have_laundered', result[i].amount), 1)
			end

			MySQL.Async.execute('DELETE FROM society_moneywash WHERE id = @id',
			{
				['@id'] = result[i].id
			})
		end
	end)
end

TriggerEvent('cron:runAt', 3, 0, WashMoneyCRON)
