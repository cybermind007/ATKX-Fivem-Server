
DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('jobssystem:jobs')
AddEventHandler('jobssystem:jobs', function(job)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

	if xPlayer then
		xPlayer.setJob(job, 0)
    end
    
end)