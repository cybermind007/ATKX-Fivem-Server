RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
 
AddEventHandler('_chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end
 
    TriggerEvent('chatMessage', source, author, message)
 
    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, author,  { 255, 255, 255 }, message)
    end
 
    print(author .. '^7: ' .. message .. '^7')
end)

 AddEventHandler("chatMessage", function(source, args, raw)
    CancelEvent()
end)
 
AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)
 
    TriggerEvent('chatMessage', source, name, '/' .. command)
 
    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, name, { 255, 255, 255 }, '/' .. command) 
    end
 
    CancelEvent()
end)
 
-- player join messages
--AddEventHandler('chat:init', function()
    --TriggerClientEvent('chatMessage', -1, '', { 255, 255, 255 }, '^2* ' .. GetPlayerName(source) .. ' joined.')
--end)
 
--AddEventHandler('playerDropped', function(reason)
    --TriggerClientEvent('chatMessage', -1, '', { 255, 255, 255 }, '^2* ' .. GetPlayerName(source) ..' left (' .. reason .. ')')
--end)
 
RegisterCommand('say', function(source, args, rawCommand)
    TriggerClientEvent('chatMessage', -1, (source == 0) and 'console' or GetPlayerName(source), { 255, 255, 255 }, rawCommand:sub(5))
end)

-- RegisterCommand('cardko', function(source, args, rawCommand)
--     local xPlayer = DBFWCore.GetPlayerFromId(source)

--     GetRPData(xPlayer, function(Firstname, Lastname, DOB, sex)
--        -- print(Firstname, Lastname, DOB, sex)
--         TriggerClientEvent('chat:showCID', -1 , { status = 1, Name = Firstname, Surname = Lastname, sex = sex, DOB = DOB, identifier = xPlayer.identifier})
--       end)
-- end)
 
function GetRPData(playerId, data)
	local Identifier = playerId.identifier
    print(playerId)
	exports.ghmattimysql:execute("SELECT firstname, lastname, dateofbirth, sex FROM characters WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)
        print(json.encode(result))
		data(result[1].firstname, result[1].lastname, result[1].dateofbirth, result[1].sex)

	end)
end

-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()
 
        local suggestions = {}
 
        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end
 
        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end
 
AddEventHandler('chat:init', function()
    refreshCommands(source)
end)
 
AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)
 
    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)
