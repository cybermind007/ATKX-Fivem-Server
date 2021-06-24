DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('dbfw-driftschool:takemoney')
AddEventHandler('dbfw-driftschool:takemoney', function(money)
    local source = source
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    if xPlayer.getMoney() >= money then
        xPlayer.removeMoney(money)
        TriggerClientEvent('dbfw-driftschool:tookmoney', source, true)
    else
        TriggerClientEvent('DoLongHudText', source, 'Not enough money', 2)
    end
end)