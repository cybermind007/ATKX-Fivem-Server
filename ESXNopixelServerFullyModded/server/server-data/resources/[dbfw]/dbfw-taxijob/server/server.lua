DBFWCore                = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('towtruck:giveCash')
AddEventHandler('towtruck:giveCash', function(cash)
  local source = source
  local xPlayer  = DBFWCore.GetPlayerFromId(source)
  xPlayer.addMoney(cash)
end)

RegisterServerEvent('dbfw-imp:mechCar')
AddEventHandler('dbfw-imp:mechCar', function(plate)
	local user = DBFWCore.GetPlayerFromId(source)
    local characterId = user.identifier
	garage = 'Impound Lot'
	state = 'Normal Impound'
	MySQL.Async.execute("UPDATE owned_vehicles SET garage = @garage, state = @state WHERE plate = @plate", {['garage'] = garage, ['state'] = state, ['plate'] = plate})
end)