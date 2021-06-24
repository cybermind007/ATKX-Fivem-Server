DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

TriggerEvent('es:addGroupCommand', 'spec', "admin", function(source, args, user)
	TriggerClientEvent('dbfw-spectate:spectate', source, target)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

DBFWCore.RegisterServerCallback('dbfw-spectate:getPlayerData', function(source, cb, id)
	local xPlayer = DBFWCore.GetPlayerFromId(id)
	cb(xPlayer)
end)