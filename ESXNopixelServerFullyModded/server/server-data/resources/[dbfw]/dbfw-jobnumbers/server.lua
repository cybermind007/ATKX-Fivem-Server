DBFWCore = nil
local serverjobs, droppedplayer, currentplayer = {}, {}, {}
local IsBusy = false

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

AddEventHandler('playerDropped', function()
    _source = source
   table.insert(droppedplayer, _source)
end)

RegisterServerEvent('dbfw-jobnumbers:setjobs')
AddEventHandler('dbfw-jobnumbers:setjobs', function(jobname)
    local _source = source 
    local buildlist = { id = _source, job = jobname,}
    table.insert(currentplayer, buildlist)
end)


function AnnounceJobs()
    local sendingjobs = {}
    for i, v in pairs(serverjobs) do
        if sendingjobs[v.jobname] == nil then
            sendingjobs[v.jobname] = 1
        else
            sendingjobs[v.jobname] = sendingjobs[v.jobname] + 1
        end
    end
    TriggerClientEvent('dbfw-jobnumbers:setjobs', -1, sendingjobs)
end


Citizen.CreateThread(function()
    while true do
        sleep = 50
        if #droppedplayer > 0 then
            for i, v in pairs(serverjobs) do
                if v.id == droppedplayer[1] then
                    table.remove(serverjobs, i)
                    break
                end
            end
            AnnounceJobs()
            table.remove(droppedplayer, 1)
            sleep = 0
        end

        if #currentplayer > 0 then
            local updated = false
            for i, v in pairs(serverjobs) do
                if v.id == currentplayer[1].id then
                    for i,v in pairs(Config.MultiNameJobs) do
                        for c, u in pairs(v) do
                            if u == currentplayer[1].job.name then
                                currentplayer[1].job.name = i
                                ismulti = true
                            end
                        end
                    end
                    v.jobname = currentplayer[1].job.name
                    updated = true
                end
            end
                
            if not updated then
                for i,v in pairs(Config.MultiNameJobs) do
                    for c,u in pairs(v) do
                        if u == currentplayer[1].job.name then
                            currentplayer[1].job.name = i
                        end
                    end
                end
                buildlist = { id = currentplayer[1].id, jobname = currentplayer[1].job.name}
                table.insert(serverjobs, buildlist)
            end
            AnnounceJobs()
            table.remove(currentplayer, 1)
            sleep = 0
        end
        Citizen.Wait(sleep)
	end
end)



