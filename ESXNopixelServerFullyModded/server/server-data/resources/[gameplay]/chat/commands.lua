DBFWCore = nil
local PlayerData              = {}
Citizen.CreateThread(function()

	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end

end)

RegisterNetEvent('dbfw:playerLoaded')
AddEventHandler('dbfw:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)


RegisterCommand('911', function(source, args, rawCommand)
    local source = GetPlayerServerId(PlayerId())
    local name = GetPlayerName(PlayerId())
    local caller = GetPlayerServerId(PlayerId())
    local msg = rawCommand:sub(4)
    TriggerEvent("animation:phonecall",source)
    TriggerServerEvent('chat:server:911source', source, caller, msg)
    TriggerServerEvent('911', source, caller, msg)
end, false)

RegisterCommand('311', function(source, args, rawCommand)
    local source = GetPlayerServerId(PlayerId())
    local name = GetPlayerName(PlayerId())
    local caller = GetPlayerServerId(PlayerId())
    local msg = rawCommand:sub(4)
    TriggerEvent("animation:phonecall",source)
    TriggerServerEvent(('chat:server:311source'), source, caller, msg)
    TriggerServerEvent('311', source, caller, msg)
end, false)


RegisterNetEvent('chat:EmergencySend911r')
AddEventHandler('chat:EmergencySend911r', function(fal, caller, msg)
    if DBFWCore.GetPlayerData().job.name == 'police' or DBFWCore.GetPlayerData().job.name == 'ambulance' then
        TriggerEvent('chatMessagess', '911 RESPONSE: '.. caller, 1, 'Sent to: '.. fal .. ' : '.. msg )
    end
end)

RegisterNetEvent('chat:EmergencySend311r')
AddEventHandler('chat:EmergencySend311r', function(fal, caller, msg)
    if DBFWCore.GetPlayerData().job.name == 'police' or DBFWCore.GetPlayerData().job.name == 'ambulance' then
        TriggerEvent('chatMessagess', '311 RESPONSE: '.. caller, 4, 'Sent to: '.. fal .. ' : '.. msg )
    end
end)

RegisterNetEvent('chat:EmergencySend911')
AddEventHandler('chat:EmergencySend911', function(fal, caller, msg)
    if DBFWCore.GetPlayerData().job.name == 'police' or DBFWCore.GetPlayerData().job.name == 'ambulance' then
        TriggerEvent('chatMessagess', '[911] ', 1, '( Caller ID: '.. caller .. ' | ' .. fal ..' ) '.. msg )
        PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)
    end
end)

RegisterNetEvent('chat:EmergencySend311')
AddEventHandler('chat:EmergencySend311', function(fal, caller, msg)
    if DBFWCore.GetPlayerData().job.name == 'police' or DBFWCore.GetPlayerData().job.name == 'ambulance' then
        TriggerEvent('chatMessagess', '[311] ', 4, '( Caller ID: '.. caller .. ' | ' .. fal ..' ) '.. msg )
        PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)
    end
end)

RegisterCommand('911r', function(target, args, rawCommand)
    if DBFWCore.GetPlayerData().job.name == 'police' or DBFWCore.GetPlayerData().job.name == 'ambulance' then
        local source = GetPlayerServerId(PlayerId())
        local target = tonumber(args[1])
        local msg = rawCommand:sub(8)
        TriggerEvent("animation:phonecall",source)
        TriggerServerEvent(('chat:server:911r'), target, source, msg)
        TriggerServerEvent('911r', target, source, msg)
    end
end, false)

RegisterCommand('311r', function(target, args, rawCommand)
    if DBFWCore.GetPlayerData().job.name == 'police' or DBFWCore.GetPlayerData().job.name == 'ambulance' then 
        local source = GetPlayerServerId(PlayerId())
        local target = tonumber(args[1])
        local msg = rawCommand:sub(8)
        TriggerEvent("animation:phonecall",source)
        TriggerServerEvent(('chat:server:311r'), target, source, msg)
        TriggerServerEvent('311r', target, source, msg)
    end
end, false)