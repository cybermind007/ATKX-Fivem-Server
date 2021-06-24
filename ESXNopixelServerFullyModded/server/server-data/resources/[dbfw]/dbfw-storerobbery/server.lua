DBFWCore = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

local deadPeds = {}

RegisterServerEvent('dbfw-storerobbery:pedDead')
AddEventHandler('dbfw-storerobbery:pedDead', function(store)
    if not deadPeds[store] then
        deadPeds[store] = 'deadlol'
        TriggerClientEvent('dbfw-storerobbery:onPedDeath', -1, store)
        local second = 1000
        local minute = 60 * second
        local hour = 60 * minute
        local cooldown = Config.Shops[store].cooldown
        local wait = cooldown.hour * hour + cooldown.minute * minute + cooldown.second * second
        Wait(wait)
        if not Config.Shops[store].robbed then
            for k, v in pairs(deadPeds) do if k == store then table.remove(deadPeds, k) end end
            TriggerClientEvent('dbfw-storerobbery:resetStore', -1, store)
        end
    end
end)

RegisterServerEvent('dbfw-storerobbery:handsUp')
AddEventHandler('dbfw-storerobbery:handsUp', function(store)
    TriggerClientEvent('dbfw-storerobbery:handsUp', -1, store)
end)

RegisterServerEvent('dbfw-storerobbery:pickUp')
AddEventHandler('dbfw-storerobbery:pickUp', function(store)
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local randomAmount = math.random(Config.Shops[store].money[1], Config.Shops[store].money[2])
    xPlayer.addMoney(randomAmount)
    TriggerClientEvent('DoLongHudText', source, 'You got: $' .. randomAmount, 2) 
    TriggerClientEvent('dbfw-storerobbery:removePickup', -1, store) 
end)

DBFWCore.RegisterServerCallback('dbfw-storerobbery:canRob', function(source, cb, store)
    local cops = 0
    local xPlayers = DBFWCore.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            cops = cops + 1
        end
    end
    if cops >= Config.Shops[store].cops then
        if not Config.Shops[store].robbed and not deadPeds[store] then
            cb(true)
        else
            cb(false)
        end
    else
        cb('no_cops')
    end
end)

RegisterServerEvent('dbfw-storerobbery:notif')
AddEventHandler('dbfw-storerobbery:notif', function(store)
    local src = source
    local xPlayers = DBFWCore.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == 'police' then
            TriggerClientEvent('dbfw-storerobbery:msgPolice', src, store)
            return
        end
    end
end)

RegisterServerEvent('dbfw-storerobbery:rob')
AddEventHandler('dbfw-storerobbery:rob', function(store)
    local src = source
    Config.Shops[store].robbed = true
    TriggerClientEvent('dbfw-storerobbery:rob', -1, store)
    Wait(30000)
    TriggerClientEvent('dbfw-storerobbery:robberyOver', src)

    local second = 1000
    local minute = 60 * second
    local hour = 60 * minute
    local cooldown = Config.Shops[store].cooldown
    local wait = cooldown.hour * hour + cooldown.minute * minute + cooldown.second * second
    Wait(wait)
    Config.Shops[store].robbed = false
    for k, v in pairs(deadPeds) do if k == store then table.remove(deadPeds, k) end end
    TriggerClientEvent('dbfw-storerobbery:resetStore', -1, store)
end)

Citizen.CreateThread(function()
    while true do
        for i = 1, #deadPeds do TriggerClientEvent('dbfw-storerobbery:pedDead', -1, i) end -- update dead peds
        Citizen.Wait(500)
    end
end)
