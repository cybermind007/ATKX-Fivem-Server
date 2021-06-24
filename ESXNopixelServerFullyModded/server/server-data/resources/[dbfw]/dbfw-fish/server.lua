DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('dbfw-fish:payShit')
AddEventHandler('dbfw-fish:payShit', function(money)
    local source = source
    local xPlayer  = DBFWCore.GetPlayerFromId(source)
    if money ~= nil then
        xPlayer.addMoney(money)
    end
end)

RegisterServerEvent('fish:checkAndTakeDepo')
AddEventHandler('fish:checkAndTakeDepo', function()
local source = source
local xPlayer  = DBFWCore.GetPlayerFromId(source)
    xPlayer.removeMoney(500)
end)

RegisterServerEvent('fish:returnDepo')
AddEventHandler('fish:returnDepo', function()
local source = source
local xPlayer  = DBFWCore.GetPlayerFromId(source)
    xPlayer.addMoney(500)
end)

RegisterServerEvent('dbfw-fish:getFish')
AddEventHandler('dbfw-fish:getFish', function()
local source = source
    TriggerClientEvent('player:receiveItem', source, "fish", math.random(1,2))
end)