DBFWCore = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
---------- Pawn Shop --------------

RegisterServerEvent('dbfw-pawnshop:selljewels')
AddEventHandler('dbfw-pawnshop:selljewels', function()
local _source = source
local xPlayer = DBFWCore.GetPlayerFromId(_source)
	xPlayer.addMoney(50)
end)