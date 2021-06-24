DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

local license = 0

local licenseArray = {}

RegisterServerEvent('sec:checkRobbed')
AddEventHandler('sec:checkRobbed', function(license)

local _source = source

if licenseArray[#licenseArray] ~= nil then
    for k, v in pairs(licenseArray) do
        if v == license then
        print('Bitch')
        return
        end
    end
end

licenseArray[#licenseArray+1] = license

    TriggerClientEvent('sec:AllowHeist', _source)
end)

RegisterServerEvent('dbfw-securityheists:banktstart')
AddEventHandler('dbfw-securityheists:banktstart', function(license)
    local copcount = 0
    local Players = DBFWCore.GetPlayers()

    for i = 1, #Players, 1 do
        local xPlayer = DBFWCore.GetPlayerFromId(Players[i])

        if xPlayer.job.name == "police" then
            copcount = copcount + 1
        end
    end
    if copcount >= 0 then
	    local xPlayer = DBFWCore.GetPlayerFromId(source)
        TriggerClientEvent('sec:usegroup6card', source)
        TriggerClientEvent('inventory:removeItem', source, 'Gruppe6Card', 1)
    else
        TriggerClientEvent('DoLongHudText', source, 'There is not enough police on duty!', 2)
    end
end)