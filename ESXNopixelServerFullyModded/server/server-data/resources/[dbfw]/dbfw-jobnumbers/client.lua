local JobCount = {}


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

RegisterNetEvent('dbfw:setJob')
AddEventHandler('dbfw:setJob', function(job)
	PlayerData.job = job
	TriggerServerEvent('dbfw-jobnumbers:setjobs', job)
end)

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
    TriggerServerEvent('dbfw-jobnumbers:setjobs', xPlayer.job)
end)


RegisterNetEvent('dbfw-jobnumbers:setjobs')
AddEventHandler('dbfw-jobnumbers:setjobs', function(jobslist)
   JobCount = jobslist
end)

function jobonline(joblist)
    for i,v in pairs(Config.MultiNameJobs) do
        for u,c in pairs(v) do
            if c == joblist then
                joblist = i
            end
        end
    end

    local amount = 0
    local job = joblist
    if JobCount[job] ~= nil then
        amount = JobCount[job]
    end

    return amount
end


