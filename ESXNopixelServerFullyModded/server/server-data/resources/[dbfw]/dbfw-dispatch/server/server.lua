RegisterServerEvent("dispatch:svNotify")
AddEventHandler("dispatch:svNotify", function(data, pCallSign)
    --print(json.encode(data))
    local name = getIdentity(source)
    currentCallSign = name.firstname  .. '  ' .. name.lastname
    TriggerClientEvent('police:setCallSign', -1, currentCallSign)
    TriggerClientEvent('dispatch:clNotify', -1, data)
end)

RegisterCommand('togglealerts', function(source, args, user)
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    if xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' then
        TriggerClientEvent('dispatch:toggleNotifications', source, args[1])
    end
end)

function getIdentity(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			dateofbirth = identity['dateofbirth'],
			sex = identity['sex'],
			height = identity['height'],
			phonenumber = identity['phone_number']

		}
	else
		return nil
	end
end
