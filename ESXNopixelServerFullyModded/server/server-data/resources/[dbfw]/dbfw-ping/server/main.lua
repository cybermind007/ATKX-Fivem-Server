DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

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
			height = identity['height']

		}
	else
		return nil
	end
end

RegisterCommand('ping', function(source, args, rawCommand)
    local name = getIdentity(source)
	if args[1] ~= nil then
        if args[1]:lower() == 'accept' then
            TriggerClientEvent('dbfw-ping:client:AcceptPing', source)
        elseif args[1]:lower() == 'reject' then
            TriggerClientEvent('dbfw-ping:client:RejectPing', source)
        else
            local tSrc = tonumber(args[1])
            if source ~= tSrc then
                TriggerClientEvent('dbfw-ping:client:SendPing', tSrc, name.firstname .. ' ' .. name.lastname, source)
            else
                TriggerClientEvent('DoLongHudText', source, 'Can\'t Ping Yourself', 1)
            end
        end
    end
end, false)

RegisterServerEvent('dbfw-ping:server:SendPingResult')
AddEventHandler('dbfw-ping:server:SendPingResult', function(id, result)
    local name = getIdentity(source)
	if result == 'accept' then
		TriggerClientEvent('DoLongHudText', id, name.firstname .. ' ' .. name.lastname .. "'s Accepted Your Ping", 1)
	elseif result == 'reject' then
		TriggerClientEvent('DoLongHudText', id, name.firstname .. ' ' .. name.lastname .. "'s Rejected Your Ping", 1)
	elseif result == 'timeout' then
		TriggerClientEvent('DoLongHudText', id, name.firstname .. ' ' .. name.lastname .. "'s Did Not Accept Your Ping", 1)
	elseif result == 'unable' then
		TriggerClientEvent('DoLongHudText', id, name.firstname .. ' ' .. name.lastname .. "'s Was Unable To Receive Your Ping", 1)
	elseif result == 'received' then
		TriggerClientEvent('DoLongHudText', id, 'You Sent A Ping To ' .. name.firstname .. ' ' .. name.lastname .. '.', 1)
	end
end)
