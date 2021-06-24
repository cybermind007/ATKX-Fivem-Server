local vehicleKeys = {}
local myVehicleKeys = {}

DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj)
  DBFWCore = obj
end)

local robbableItems = {
  [1] = {chance = 3, id = 0, quantity = math.random(50, 800)}, -- really common
  [2] = {chance = 4, id = 'plastic', quantity = math.random(1, 5)}, -- rare
  [3] = {chance = 3, id = 'joint', quantity = math.random(1, 3)}, -- really common
  [4] = {chance = 7, id = '1gcocaine', quantity = 1}, -- rare
  [5] = {chance = 10, id = 'thermite', quantity = 1},
  [6] = {chance = 8, id = 'highgradefemaleseed', quantity = math.random(1, 3)},
  [7] = {chance = 6, id = 'highgrademaleseed', quantity = math.random(1, 4)},
  [8] = {chance = 4, id = 'rubber', quantity = math.random(1, 5)},
  [9] = {chance = 10, id = 'cb', quantity = 1}, -- rare
}

RegisterServerEvent('garage:searchItem')
AddEventHandler('garage:searchItem', function(plate)
  local source = tonumber(source)
  local item = {}
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  local ident = xPlayer.getIdentifier()

  item = robbableItems[math.random(1, #robbableItems)]
  if math.random(1, 10) >= item.chance then
   if tonumber(item.id) == 0 then
    xPlayer.addMoney(item.quantity)
    TriggerClientEvent('DoLongHudText', source, 'You found $'..item.quantity, 1)
   elseif tonumber(item.id) == 1 then
    TriggerClientEvent('DoLongHudText', source, 'You have found the keys to the vehicle!', 1)
    vehicleKeys[plate] = {}
    table.insert(vehicleKeys[plate], {id = ident})
    TriggerClientEvent('garage:updateKeys', source, vehicleKeys, ident)
    TriggerClientEvent('vehicle:start', source)
   else
    TriggerClientEvent('player:receiveItem', source, item.id, item.quantity)
    TriggerClientEvent('DoLongHudText', source, 'Item Added!', 1)
   end
  else
    TriggerClientEvent('DoLongHudText', source, 'You found nothing', 1)
  end
end)


DBFWCore.RegisterServerCallback('dbfw-keys:checkOwner', function(source, cb, plate)
  local player = DBFWCore.GetPlayerFromId(source)
  MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier AND plate = @plate', {
      ['@identifier'] = player.identifier,
      ['@plate'] = plate
  }, function(results)
      cb(#results == 1)
  end)
end)

RegisterServerEvent('garage:giveKey')
AddEventHandler('garage:giveKey', function(target, plate)
  local targetSource = tonumber(target)
  local xPlayer = DBFWCore.GetPlayerFromId(targetSource)
  local ident = xPlayer.getIdentifier()
  local xPlayer2 = DBFWCore.GetPlayerFromId(source)
  local ident2 = xPlayer2.getIdentifier()
  local plate = tostring(plate)

  vehicleKeys[plate] = {}
  table.insert(vehicleKeys[plate], {id = ident})
  TriggerClientEvent('DoLongHudText', targetSource, 'You just recieved keys to a vehicle', 1)
  TriggerClientEvent('garage:updateKeys', targetSource, vehicleKeys, ident)
end)

RegisterServerEvent('garage:addKeys')
AddEventHandler('garage:addKeys', function(plate)
  local source = tonumber(source)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  local ident = xPlayer.getIdentifier()
  while plate == nil do
    Citizen.Wait(5)
  end

  if vehicleKeys[plate] ~= nil then
    table.insert(vehicleKeys[plate], {id = ident})
    TriggerClientEvent('garage:updateKeys', source, vehicleKeys, ident)
  else
    vehicleKeys[plate] = {}
    table.insert(vehicleKeys[plate], {id = ident})
    TriggerClientEvent('garage:updateKeys', source, vehicleKeys, ident)
  end
end)


RegisterServerEvent('garage:removeKeys')
AddEventHandler('garage:removeKeys', function(plate)
 local source = tonumber(source)
 local xPlayer = DBFWCore.GetPlayerFromId(source)
 local ident = xPlayer.getIdentifier()
 if vehicleKeys[plate] ~= nil then
  for id,v in pairs(vehicleKeys[plate]) do
   if v.id == ident then
    table.remove(vehicleKeys[plate], id)
   end
  end
 end
 TriggerClientEvent('garage:updateKeys', source, vehicleKeys, ident)
end)

RegisterServerEvent('removelockpick')
AddEventHandler('removelockpick', function()
  local source = tonumber(source)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  if math.random(1, 20) == 1 then
    TriggerClientEvent('inventory:removeItem', source, 'lockpick', 1)
    TriggerClientEvent('DoLongHudText', source, 'The lockpick bent out of shape.', 1)
  end
end)
