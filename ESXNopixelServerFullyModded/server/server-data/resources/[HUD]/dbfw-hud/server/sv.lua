local ResetStress = false


TriggerEvent('dbfw:getSharedObject', function(obj)
	DBFWCore = obj
   end)

RegisterServerEvent('db-hud:Server:GainStress')
AddEventHandler('db-hud:Server:GainStress', function(amount)
	TriggerClientEvent('dbfw_status:add', source, 'stress', amount)
end)

RegisterServerEvent('db-hud:Server:RelieveStress')
AddEventHandler('db-hud:Server:RelieveStress', function(amount)
	TriggerClientEvent('dbfw_status:remove', source, 'stress', amount)
end)
