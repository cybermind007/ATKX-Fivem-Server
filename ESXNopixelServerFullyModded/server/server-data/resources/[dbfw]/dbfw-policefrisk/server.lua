DBFWCore = nil

TriggerEvent("dbfw:getSharedObject", function(obj) DBFWCore = obj end)

RegisterServerEvent("dbfw-policefrisk:closestPlayer")
AddEventHandler("dbfw-policefrisk:closestPlayer", function(closestPlayer)
    _source = source
    target = closestPlayer

    TriggerClientEvent("dbfw-policefrisk:friskPlayer", target)
end)

RegisterServerEvent("dbfw-policefrisk:notifyMessage")
AddEventHandler("dbfw-policefrisk:notifyMessage", function(frisk)
    if frisk == true then
        TriggerClientEvent('chatMessagess', _source, 'Information: ', 4, "I could feel something that reminds of a firearm")
        return
    elseif frisk == false then
        TriggerClientEvent('chatMessagess', _source, 'Information: ', 4, "I could not feel anything")
        return
    end
end)