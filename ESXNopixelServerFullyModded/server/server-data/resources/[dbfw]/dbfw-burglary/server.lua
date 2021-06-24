local DBFWCore = nil
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
 --[6] = {chance = 14, id = 'keycard', name = 'Keycard', quantity = 1}, -- rare
 --[7] = {chance = 13, id = 'keycard2', name = 'Keycard', quantity = 1}, -- rare
 --[8] = {chance = 11, id = 'keycard3', name = 'Keycard', quantity = 1}, -- rare
 --[12] = {chance = 10, id = 'drugItem', name = 'Black USB-C', quantity = 1}, -- rare
 --[13] = {chance = 8, id = 'drugbags', name = 'Baggies', quantity = math.random(1, 6)},
 --[15] = {chance = 6, id = 'rolex', name = 'Rolex', quantity = math.random(1, 5)},
}

--[[chance = 1 is very common, the higher the value the less the chance]]--

TriggerEvent('dbfw:getSharedObject', function(obj)
 DBFWCore = obj
end)

RegisterServerEvent('houseRobberies:removeLockpick')
AddEventHandler('houseRobberies:removeLockpick', function()
 local source = tonumber(source)
 local xPlayer = DBFWCore.GetPlayerFromId(source)
 TriggerClientEvent('inventory:removeItem', source, 'advlockpick', 1)
 TriggerClientEvent('DoLongHudText',  source, 'The lockpick bent out of shape' , 1)
end)

RegisterServerEvent('houseRobberies:giveMoney')
AddEventHandler('houseRobberies:giveMoney', function()
 local source = tonumber(source)
 local xPlayer = DBFWCore.GetPlayerFromId(source)
 local cash = math.random(200, 500)
 xPlayer.addMoney(cash)
 TriggerClientEvent('DoLongHudText',  source, 'You found $'..cash , 1)
end)


RegisterServerEvent('houseRobberies:searchItem')
AddEventHandler('houseRobberies:searchItem', function()
 local source = tonumber(source)
 local item = {}
 local xPlayer = DBFWCore.GetPlayerFromId(source)
 local gotID = {}

 for i=1, math.random(1, 2) do
  item = robbableItems[math.random(1, #robbableItems)]
  if math.random(1, 15) >= item.chance then
    if tonumber(item.id) == 0 and not gotID[item.id] then
        gotID[item.id] = true
        xPlayer.addMoney(item.quantity)
        TriggerClientEvent('DoLongHudText',  source, 'You found $'..item.quantity , 1)
    elseif not gotID[item.id] then
        gotID[item.id] = true
        TriggerClientEvent('player:receiveItem', source, item.id, item.quantity)
        TriggerClientEvent('DoLongHudText', source, 'Item Added!', 1)
    end
  else
    TriggerClientEvent('DoLongHudText', source, 'You found nothing', 1)
  end
end
end)
