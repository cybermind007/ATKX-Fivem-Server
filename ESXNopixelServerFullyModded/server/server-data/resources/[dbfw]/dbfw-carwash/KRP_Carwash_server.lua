RegisterServerEvent('dbfw_Carwash:checkmoney')
AddEventHandler('dbfw_Carwash:checkmoney', function ()
		TriggerEvent('es:getPlayerFromId', source, function (user)
			userMoney = user.getMoney()
			if userMoney >= 250 then
				user.removeMoney(250)
				TriggerClientEvent('dbfw_Carwash:success', source, 25)
			else
			moneyleft = 250 - userMoney
			TriggerClientEvent('dbfw_Carwash:notenoughmoney', source, moneyleft)
		end
	end)
end)