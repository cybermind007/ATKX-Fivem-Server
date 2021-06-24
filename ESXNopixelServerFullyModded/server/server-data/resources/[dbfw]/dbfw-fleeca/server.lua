DBFWCore = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent("dbfw-fleeca:startcheck")
AddEventHandler("dbfw-fleeca:startcheck", function(bank)
    local _source = source
    local copcount = 2
    local Players = DBFWCore.GetPlayers()

    for i = 1, #Players, 1 do
        local xPlayer = DBFWCore.GetPlayerFromId(Players[i])

        if xPlayer.job.name == "police" then
            copcount = copcount + 2
        end
    end
    local xPlayer = DBFWCore.GetPlayerFromId(_source)

    if copcount >= fleeca.mincops then
        if not fleeca.Banks[bank].onaction == true then
            if (os.time() - fleeca.cooldown) > fleeca.Banks[bank].lastrobbed then
                fleeca.Banks[bank].onaction = true
                TriggerClientEvent('inventory:removeItem', _source, 'thermite', 1)
                TriggerClientEvent("dbfw-fleeca:outcome", _source, true, bank)
                TriggerClientEvent("dbfw-fleeca:policenotify", -1, bank)
                TriggerClientEvent('dbfw-dispatch:bankrobbery', -1)
                    return
                else
                    TriggerClientEvent("dbfw-fleeca:outcome", _source, false, "This bank recently robbed. You need to wait "..math.floor((fleeca.cooldown - (os.time() - fleeca.Banks[bank].lastrobbed)) / 60)..":"..math.fmod((fleeca.cooldown - (os.time() - fleeca.Banks[bank].lastrobbed)), 60))
                end
            else
            TriggerClientEvent("dbfw-fleeca:outcome", _source, false, "This bank is currently being robbed.")
        end
    else
        TriggerClientEvent("dbfw-fleeca:outcome", _source, false, "There is not enough police in the city.")
    end
end)

RegisterServerEvent("dbfw-fleeca:lootup")
AddEventHandler("dbfw-fleeca:lootup", function(var, var2)
    TriggerClientEvent("dbfw-fleeca:lootup_c", -1, var, var2)
end)

RegisterServerEvent("dbfw-fleeca:openDoor")
AddEventHandler("dbfw-fleeca:openDoor", function(coords, method)
    TriggerClientEvent("dbfw-fleeca:openDoor_c", -1, coords, method)
end)

RegisterServerEvent("dbfw-fleeca:startLoot")
AddEventHandler("dbfw-fleeca:startLoot", function(data, name, players)
    local _source = source

    for i = 1, #players, 1 do
        TriggerClientEvent("dbfw-fleeca:startLoot_c", players[i], data, name)
    end
    TriggerClientEvent("dbfw-fleeca:startLoot_c", _source, data, name)
end)

RegisterServerEvent("dbfw-fleeca:stopHeist")
AddEventHandler("dbfw-fleeca:stopHeist", function(name)
    TriggerClientEvent("dbfw-fleeca:stopHeist_c", -1, name)
end)

RegisterServerEvent("dbfw-fleeca:rewardCash")
AddEventHandler("dbfw-fleeca:rewardCash", function()
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local reward = math.random(1, 2)
    local mathfunc = math.random(200)
    local payout = math.random(2,4)
    if mathfunc == 15 then
      TriggerClientEvent('player:receiveItem', source, 'goldbar', payout)
    end
    TriggerClientEvent("player:receiveItem", source, "band", reward)
end)

RegisterServerEvent("dbfw-fleeca:setCooldown")
AddEventHandler("dbfw-fleeca:setCooldown", function(name)
    fleeca.Banks[name].lastrobbed = os.time()
    fleeca.Banks[name].onaction = false
    TriggerClientEvent("dbfw-fleeca:resetDoorState", -1, name)
end)

DBFWCore.RegisterServerCallback("dbfw-fleeca:getBanks", function(source, cb)
    cb(fleeca.Banks)
end)