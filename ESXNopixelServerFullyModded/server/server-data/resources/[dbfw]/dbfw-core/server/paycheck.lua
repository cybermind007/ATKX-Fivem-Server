DBFWCore.StartPayCheck = function()

	function payCheck()
		local xPlayers = DBFWCore.GetPlayers()

		for i=1, #xPlayers, 1 do
			local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
			local job     = xPlayer.job.grade_name
			local salary  = 15

			if salary > 0 then
				if job == 'unemployed' then -- unemployed
					xPlayer.addAccountMoney('bank', salary)
				elseif Config.EnableSocietyPayouts then -- possibly a society
					TriggerEvent('dbfw-society:getSociety', xPlayer.job.name, function (society)
						if society ~= nil then -- verified society
							TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function (account)
								if account.money >= salary then -- does the society money to pay its employees?
									xPlayer.addAccountMoney('bank', salary)
									account.removeMoney(salary)
								else
									TriggerClientEvent('dbfw:showAdvancedNotification', xPlayer.source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_MAZE', 1)
								end
							end)
						else -- not a society
							xPlayer.addAccountMoney('bank', salary)
						end
					end)
				else -- generic job
					xPlayer.addAccountMoney('bank', salary)
				end
			end

		end

		SetTimeout(Config.PaycheckInterval, payCheck)

	end

	SetTimeout(Config.PaycheckInterval, payCheck)

end

DBFWCore.RegisterServerCallback('paycheck:checkSalary', function(source, cb)
	if source ~= nil then
		local xPlayer = DBFWCore.GetPlayerFromId(source)
		local salary  = xPlayer.job.grade_salary
		if xPlayer ~= nil then
			cb(salary)
		else
			cb(false)
		end
	end
end)




RegisterServerEvent('paycheck:collectPay')
AddEventHandler('paycheck:collectPay', function()
	local source = source
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local job     = xPlayer.job.grade_name
	local salary  = xPlayer.job.grade_salary

	if salary > 0 then
		if job == 'unemployed' then -- unemployed
			xPlayer.addMoney( salary)
		elseif Config.EnableSocietyPayouts then -- possibly a society
			TriggerEvent('dbfw-society:getSociety', xPlayer.job.name, function (society)
				if society ~= nil then -- verified society
					TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function (account)
						if account.money >= salary then -- does the society money to pay its employees?
							xPlayer.addMoney( salary)
							account.removeMoney(salary)
							--TriggerClientEvent("banking:updateCash", source, (xPlayer.getMoney()))
						else
							TriggerClientEvent('dbfw:showAdvancedNotification', source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_MAZE', 1)
						end
					end)
				else -- not a society
					xPlayer.addMoney( salary)
				end
			end)
		else -- generic job
			xPlayer.addMoney( salary)
		end
	end
end)

RegisterServerEvent('paycheck:collectPayStack')
AddEventHandler('paycheck:collectPayStack', function()
	local source = source
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local job     = xPlayer.job.grade_name
	local salary  = xPlayer.job.grade_salary * 2

	if salary > 0 then
		if job == 'unemployed' then -- unemployed
			xPlayer.addMoney( salary)
		elseif Config.EnableSocietyPayouts then -- possibly a society
			TriggerEvent('dbfw-society:getSociety', xPlayer.job.name, function (society)
				if society ~= nil then -- verified society
					TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function (account)
						if account.money >= salary then -- does the society money to pay its employees?
							xPlayer.addMoney( salary)
							account.removeMoney(salary)
							--TriggerClientEvent("banking:updateCash", source, (xPlayer.getMoney()))

						else
							TriggerClientEvent('dbfw:showAdvancedNotification', source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_MAZE', 1)
						end
					end)
				else -- not a society
					xPlayer.addMoney( salary)
				end
			end)
		else -- generic job
			xPlayer.addMoney( salary)
		end
	end
end)

RegisterServerEvent('paycheck:collectPayStack3')
AddEventHandler('paycheck:collectPayStack3', function()
	local source = source
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local job     = xPlayer.job.grade_name
	local salary  = xPlayer.job.grade_salary * 3

	if salary > 0 then
		if job == 'unemployed' then -- unemployed
			xPlayer.addMoney( salary)
		elseif Config.EnableSocietyPayouts then -- possibly a society
			TriggerEvent('dbfw-society:getSociety', xPlayer.job.name, function (society)
				if society ~= nil then -- verified society
					TriggerEvent('dbfw-addonaccount:getSharedAccount', society.account, function (account)
						if account.money >= salary then -- does the society money to pay its employees?
							xPlayer.addMoney( salary)
							account.removeMoney(salary)
							--TriggerClientEvent("banking:updateCash", source, (xPlayer.getMoney()))

						else
							TriggerClientEvent('dbfw:showAdvancedNotification', source, _U('bank'), '', _U('company_nomoney'), 'CHAR_BANK_MAZE', 1)
						end
					end)
				else -- not a society
					xPlayer.addMoney( salary)
				end
			end)
		else -- generic job
			xPlayer.addMoney( salary)
		end
	end
end) 