DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

AddEventHandler('dbfw:playerLoaded', function(source)
	TriggerEvent('dbfw-license:getLicenses', source, function(licenses)
		TriggerClientEvent('dbfw-dmvschool:loadLicenses', source, licenses)
	end)
end)

RegisterNetEvent('dbfw-dmvschool:addLicense')
AddEventHandler('dbfw-dmvschool:addLicense', function(type)
	local _source = source

	TriggerEvent('dbfw-license:addLicense', _source, type, function()
		TriggerEvent('dbfw-license:getLicenses', _source, function(licenses)
			TriggerClientEvent('dbfw-dmvschool:loadLicenses', _source, licenses)
		end)
	end)
end)

RegisterNetEvent('dbfw-dmvschool:pay')
AddEventHandler('dbfw-dmvschool:pay', function(price)
	local _source = source
	local xPlayer = DBFWCore.GetPlayerFromId(_source)

	xPlayer.removeMoney(price)
	TriggerClientEvent('DoLongHudText', _source, 'You paid $'.. DBFWCore.Math.GroupDigits(price) .. ' to the DMV school', 1)
end)
