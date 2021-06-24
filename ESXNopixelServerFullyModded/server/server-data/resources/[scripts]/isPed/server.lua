
DBWF = nil

Citizen.CreateThread(function()
	while DBWF == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBWF = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('dbfw:playerLoaded', function (source)
	TriggerEvent("playerSpawned")
end)


RegisterServerEvent('CheckMyLicense')
AddEventHandler('CheckMyLicense', function()
  local _src = source
  local player = DBWF.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM user_licenses WHERE owner = @owner', {
      ['@owner'] = player.identifier
    }, function (result)
      if result[1] ~= nil then
        if result[1].type == 'weapon'then
        TriggerClientEvent('wtflols',_src, player.getMoney(), 1)
        end
      end
    end)
end)

