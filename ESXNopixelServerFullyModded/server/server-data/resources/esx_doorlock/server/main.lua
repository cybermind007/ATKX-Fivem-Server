DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)


RegisterServerEvent('dbfw_doorlock:server:updateState')
AddEventHandler('dbfw_doorlock:server:updateState', function(doorIndex, state)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	if xPlayer and type(doorIndex) == 'number' and type(state) == 'boolean' and Config.Doors[doorIndex] then
		Config.Doors[doorIndex].locked = state
        TriggerClientEvent('dbfw_doorlock:client:setState', -1, doorIndex, state)
    else
        print('error')
	end
end)

RegisterServerEvent('dbfw_doorlock:server:setupDoors')
AddEventHandler('dbfw_doorlock:server:setupDoors', function()
    local id = source
    local xPlayer = DBFWCore.GetPlayerFromId(id)
    
    for k,v in pairs(Config.Doors) do
        local state = Config.Doors[k].locked
        TriggerClientEvent('dbfw_doorlock:client:setState', id, k, state)
    end
end)

