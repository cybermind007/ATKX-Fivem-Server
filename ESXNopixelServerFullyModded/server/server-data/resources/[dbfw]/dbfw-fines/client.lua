DBFWCore = nil

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end

	while DBFWCore.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = DBFWCore.GetPlayerData()
end)

RegisterNetEvent('dbfw-fines:Anim')
AddEventHandler('dbfw-fines:Anim', function()
	RequestAnimDict('mp_common')
    while not HasAnimDictLoaded('mp_common') do
        Citizen.Wait(5)
    end
    TaskPlayAnim(PlayerPedId(), "mp_common", "givetake1_a", 8.0, -8, -1, 12, 1, 0, 0, 0)
end)