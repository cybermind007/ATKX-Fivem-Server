function CreateExtendedPlayer(player, accounts, job, loadout, name, lastPosition)
	local self = {}

	self.player       = player
	self.accounts     = accounts
	self.job          = job
	self.loadout      = loadout
	self.name         = name
	self.lastPosition = lastPosition

	self.source     = self.player.get('source')
	self.identifier = self.player.get('identifier')

	self.setMoney = function(money)
		money = DBFWCore.Math.Round(money)

		if money >= 0 then
			self.player.setMoney(money)
		else
			print(('dbfw-core: %s attempted exploiting! (reason: player tried setting -1 cash balance)'):format(self.identifier))
		end
	end

	self.getMoney = function()
		return self.player.get('money')
	end

	self.setBankBalance = function(money)
		money = DBFWCore.Math.Round(money)

		if money >= 0 then
			self.player.setBankBalance(money)
		else
			print(('dbfw-core: %s attempted exploiting! (reason: player tried setting -1 bank balance)'):format(self.identifier))
		end
	end

	self.getBank = function()
		return self.player.get('bank')
	end

	self.getCoords = function()
		return self.player.get('coords')
	end

	self.setCoords = function(x, y, z)
		self.player.coords = {x = x, y = y, z = z}
	end

	self.kick = function(reason)
		self.player.kick(reason)
	end

	self.addMoney = function(money)
		money = DBFWCore.Math.Round(money)

		if money >= 0 then
			self.player.addMoney(money)
			TriggerClientEvent("banking:addCash", self.source, money)
		else
			print(('dbfw-core: %s attempted exploiting! (reason: player tried adding -1 cash balance)'):format(self.identifier))
		end
	end

	self.removeMoney = function(money)
		money = DBFWCore.Math.Round(money)

		if money >= 0 then
			self.player.removeMoney(money)
			TriggerClientEvent('banking:removeCash', self.source, money)
		else
			print(('dbfw-core: %s attempted exploiting! (reason: player tried removing -1 cash balance)'):format(self.identifier))
		end
	end

	self.addBank = function(money)
		money = DBFWCore.Math.Round(money)

		if money >= 0 then
			self.player.addBank(money)
			TriggerClientEvent('banking:addBalance', self.source, money)
		else
			print(('dbfw-core: %s attempted exploiting! (reason: player tried adding -1 bank balance)'):format(self.identifier))
		end
	end

	self.removeBank = function(money)
		money = DBFWCore.Math.Round(money)

		if money >= 0 then
			self.player.removeBank(money)
			TriggerClientEvent('banking:removeBalance', self.source, money)
		else
			print(('dbfw-core: %s attempted exploiting! (reason: player tried removing -1 bank balance)'):format(self.identifier))
		end
	end

	self.displayMoney = function(money)
		self.player.displayMoney(money)
	end

	self.displayBank = function(money)
		self.player.displayBank(money)
	end

	self.setSessionVar = function(key, value)
		self.player.setSessionVar(key, value)
	end

	self.getSessionVar = function(k)
		return self.player.getSessionVar(k)
	end

	self.getPermissions = function()
		return self.player.getPermissions()
	end

	self.setPermissions = function(p)
		self.player.setPermissions(p)
	end

	self.getIdentifier = function()
		return self.player.getIdentifier()
	end

	self.getGroup = function()
		return self.player.getGroup()
	end

	self.set = function(k, v)
		self.player.set(k, v)
	end

	self.get = function(k)
		return self.player.get(k)
	end

	self.getPlayer = function()
		return self.player
	end

	self.getAccounts = function()
		local accounts = {}

		for k,v in ipairs(Config.Accounts) do
			if v == 'bank' then
				table.insert(accounts, {
					name  = 'bank',
					money = self.get('bank'),
					label = Config.AccountLabels.bank
				})
			else
				for k2,v2 in ipairs(self.accounts) do
					if v2.name == v then
						table.insert(accounts, v2)
					end
				end
			end
		end

		return accounts
	end

	self.getAccount = function(a)
		if a == 'bank' then
			return {
				name  = 'bank',
				money = self.get('bank'),
				label = Config.AccountLabels.bank
			}
		end

		for k,v in ipairs(self.accounts) do
			if v.name == a then
				return v
			end
		end
	end

	self.getJob = function()
		return self.job
	end

	self.getLoadout = function()
		return self.loadout
	end

	self.getName = function()
		return self.name
	end

	self.setName = function(newName)
		self.name = newName
	end

	self.getLastPosition = function()
		if self.lastPosition and self.lastPosition.x and self.lastPosition.y and self.lastPosition.z then
			self.lastPosition.x = DBFWCore.Math.Round(self.lastPosition.x, 1)
			self.lastPosition.y = DBFWCore.Math.Round(self.lastPosition.y, 1)
			self.lastPosition.z = DBFWCore.Math.Round(self.lastPosition.z, 1)
		end

		return self.lastPosition
	end

	self.setLastPosition = function(position)
		self.lastPosition = position
	end

	self.getMissingAccounts = function(cb)
		MySQL.Async.fetchAll('SELECT name FROM user_accounts WHERE identifier = @identifier', {
			['@identifier'] = self.getIdentifier()
		}, function(result)
			local missingAccounts = {}

			for k,v in ipairs(Config.Accounts) do
				if v ~= 'bank' then
					local found = false

					for k2,v2 in ipairs(result) do
						if v == v2.name then
							found = true
							break
						end
					end

					if not found then
						table.insert(missingAccounts, v)
					end
				end
			end

			cb(missingAccounts)
		end)
	end

	self.createAccounts = function(missingAccounts, cb)
		for k,v in ipairs(missingAccounts) do
			MySQL.Async.execute('INSERT INTO user_accounts (identifier, name) VALUES (@identifier, @name)', {
				['@identifier'] = self.getIdentifier(),
				['@name'] = v
			}, function(rowsChanged)
				if cb then
					cb()
				end
			end)
		end
	end

	self.setAccountMoney = function(acc, money)
		if money < 0 then
			print(('dbfw-core: %s attempted exploiting! (reason: player tried setting -1 account balance)'):format(self.identifier))
			return
		end

		local account   = self.getAccount(acc)
		local prevMoney = account.money
		local newMoney  = DBFWCore.Math.Round(money)

		account.money = newMoney

		if acc == 'bank' then
			self.set('bank', newMoney)
		end

		TriggerClientEvent('dbfw:setAccountMoney', self.source, account)
	end

	self.addAccountMoney = function(acc, money)
		if money < 0 then
			print(('dbfw-core: %s attempted exploiting! (reason: player tried adding -1 account balance)'):format(self.identifier))
			return
		end

		local account  = self.getAccount(acc)
		local newMoney = account.money + DBFWCore.Math.Round(money)

		account.money = newMoney

		if acc == 'bank' then
			self.set('bank', newMoney)
		end

		TriggerClientEvent('dbfw:setAccountMoney', self.source, account)
	end

	self.removeAccountMoney = function(acc, money)
		if money < 0 then
			print(('dbfw-core: %s attempted exploiting! (reason: player tried removing -1 account balance)'):format(self.identifier))
			return
		end

		local account  = self.getAccount(acc)
		local newMoney = account.money - DBFWCore.Math.Round(money)

		account.money = newMoney

		if acc == 'bank' then
			self.set('bank', newMoney)
		end

		TriggerClientEvent('dbfw:setAccountMoney', self.source, account)
	end

	self.setJob = function(job, grade)
		grade = tostring(grade)
		local lastJob = json.decode(json.encode(self.job))

		if DBFWCore.DoesJobExist(job, grade) then
			local jobObject, gradeObject = DBFWCore.Jobs[job], DBFWCore.Jobs[job].grades[grade]

			self.job.id    = jobObject.id
			self.job.name  = jobObject.name
			self.job.label = jobObject.label

			self.job.grade        = tonumber(grade)
			self.job.grade_name   = gradeObject.name
			self.job.grade_label  = gradeObject.label
			self.job.grade_salary = gradeObject.salary

			self.job.skin_male    = {}
			self.job.skin_female  = {}

			if gradeObject.skin_male then
				self.job.skin_male = json.decode(gradeObject.skin_male)
			end

			if gradeObject.skin_female then
				self.job.skin_female = json.decode(gradeObject.skin_female)
			end

			TriggerEvent('dbfw:setJob', self.source, self.job, lastJob)
			TriggerClientEvent('dbfw:setJob', self.source, self.job)
		else
			print(('dbfw-core: ignoring setJob for %s due to job not found!'):format(self.source))
		end
	end
	return self
end
