DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

MySQL.ready(function ()
    TriggerEvent('deleteAllYP')
end)

MySQL.ready(function ()
    TriggerEvent('deleteAllTweets')
end)

local callID = nil

--[[ Twitter Stuff ]]
RegisterNetEvent('GetTweets')
AddEventHandler('GetTweets', function(onePlayer)
    local source = source
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local name = getIdentity(source)	
    fal = "@" .. name.firstname .. "_" .. name.lastname
    local handle = fal
    -- MySQL.Async.fetchAll('SELECT * FROM tweets', {}, function(tweets)
    MySQL.Async.fetchAll('SELECT * FROM (SELECT * FROM tweets ORDER BY `time` DESC LIMIT 50) sub ORDER BY time ASC', {}, function(tweets) -- Get most recent 100 tweets
        if onePlayer then
            TriggerClientEvent('Client:UpdateTweets', source, tweets,handle)
        else
            TriggerClientEvent('Client:UpdateTweets', source, tweets,handle)
        end
    end)
end)

RegisterNetEvent('Tweet')
AddEventHandler('Tweet', function(handle, data, time)
    local handle = handle
    local src = source

    MySQL.Async.execute('INSERT INTO tweets (handle, message, time) VALUES (@handle, @message, @time)', {
        ['@handle'] = handle,
        ['@message'] = data,
        ['@time'] = time
    }, function(result)
        TriggerClientEvent('Client:UpdateTweet', -1, data, handle)
        TriggerEvent('GetTweets', true, src)
    end)
end)

RegisterNetEvent('Server:GetHandle')
AddEventHandler('Server:GetHandle', function()
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local name = getIdentity(src)	
    fal = "@" .. name.firstname .. "_" .. name.lastname
    local handle = fal
    TriggerClientEvent('givemethehandle', src, handle)
    TriggerClientEvent('updateNameClient', src, name.firstname, name.lastname)
end)

function getIdentity(target)
	local identifier = GetPlayerIdentifiers(target)[1]
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			firstname = identity['firstname'],
			lastname = identity['lastname'],
		}
	else
		return nil
	end
end

RegisterNetEvent('deleteAllTweets')
AddEventHandler('deleteAllTweets', function()
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local src = source
    MySQL.Async.execute('DELETE FROM tweets', {}, function (result) end)
end)

--[[ Contacts stuff ]]

RegisterNetEvent('phone:addContact')
AddEventHandler('phone:addContact', function(name, number)
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local handle = handle
    local src = source
    

    MySQL.Async.execute('INSERT INTO phone_contacts (identifier, name, number) VALUES (@identifier, @name, @number)', {
        ['@identifier'] = xPlayer.getIdentifier(),
        ['@name'] = name,
        ['@number'] = number
    }, function(result)
        TriggerEvent('getContacts', true, src)
        TriggerClientEvent('refreshContacts', src)
        TriggerClientEvent('phone:newContact', src, name, number)
    end)
end)

RegisterNetEvent('deleteContact')
AddEventHandler('deleteContact', function(name, number)
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local src = source
    local myIdent = xPlayer.getIdentifier()
    

    MySQL.Async.execute('DELETE FROM phone_contacts WHERE name = @name AND number = @number LIMIT 1', {
        ['@name'] = name,
        ['@number'] = number
    }, function (result)
        TriggerEvent('getContacts', true, src)
        TriggerClientEvent('refreshContacts', src)
        TriggerClientEvent('phone:deleteContact', src, name, number)
    end)
end)

RegisterNetEvent('getContacts')
AddEventHandler('getContacts', function(identifier, opt)
    local src = source

    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local myIdent = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT * FROM phone_contacts WHERE identifier = @identifier', { ['@identifier'] = myIdent }, function(contacts)
        TriggerClientEvent('phone:loadContacts', src, contacts)
    end)
end)



RegisterNetEvent('phone:deleteYP')
AddEventHandler('phone:deleteYP', function(number)
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local src = source
    local myNumber = getNumberPhone(xPlayer.getIdentifier())
    MySQL.Async.execute('DELETE FROM phone_yp WHERE phoneNumber = @phoneNumber', {
        ['@phoneNumber'] = myNumber
    }, function (result)
        TriggerClientEvent('refreshYP', src)
  
    end)
end)

--[[ Phone calling stuff ]]

function getNumberPhone(identifier)
    local result = MySQL.Sync.fetchAll("SELECT users.phone_number FROM users WHERE users.identifier = @identifier", {
        ['@identifier'] = identifier
    })
    if result[1] ~= nil then
        return result[1].phone_number
    end
    return nil
end
function getIdentifierByPhoneNumber(phone_number) 
    local result = MySQL.Sync.fetchAll("SELECT users.identifier FROM users WHERE users.phone_number = @phone_number", {
        ['@phone_number'] = phone_number
    })
    if result[1] ~= nil then
        return result[1].identifier
    end
    return nil
end

RegisterNetEvent('phone:callContact')
AddEventHandler('phone:callContact', function(targetnumber, toggle)
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local targetIdentifier = getIdentifierByPhoneNumber(targetnumber)
    local xPlayers = DBFWCore.GetPlayers()
    local srcIdentifier = xPlayer.getIdentifier()
    local srcPhone = getNumberPhone(srcIdentifier)

    TriggerClientEvent('phone:initiateCall', src, src)
    
    for i=1, #xPlayers, 1 do
        local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
        if xPlayer then
          if xPlayer.identifier == targetIdentifier then
            playerID = xPlayer.source
          end
        end
    end

    TriggerClientEvent('phone:receiveCall', playerID, targetnumber, src, srcPhone)
end)

RegisterNetEvent('phone:getSMS')
AddEventHandler('phone:getSMS', function()
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local mynumber = getNumberPhone(xPlayer.identifier)

    local result = MySQL.Sync.fetchAll("SELECT * FROM phone_messages WHERE receiver = @mynumber OR sender = @mynumber ORDER BY id DESC", {['@mynumber'] = mynumber})

    local numbers ={}
    local convos = {}
    local valid
    if result ~= nil then
    for k, v in pairs(result) do
        valid = true
        if v.sender == mynumber then
            for i=1, #numbers, 1 do
                if v.receiver == numbers[i] then
                    valid = false
                end
            end
            if valid then
                table.insert(numbers, v.receiver)
            end
        elseif v.receiver == mynumber then
            for i=1, #numbers, 1 do
                if v.sender == numbers[i] then
                    valid = false
                end
            end
            if valid then
                table.insert(numbers, v.sender)
            end
        end
    end
    
    for i, j in pairs(numbers) do
        for g, f in pairs(result) do
            if j == f.sender or j == f.receiver then
                table.insert(convos, {
                    id = f.id,
                    sender = f.sender,
                    receiver = f.receiver,
                    message = f.message,
                    date = f.date
                })
                break
            end
        end
    end

        local data = ReverseTable(convos)
        TriggerClientEvent('phone:loadSMS', src, data, mynumber)
    else

        TriggerClientEvent('phone:loadSMS', src, {}, mynumber)
    end
 
end)

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

RegisterNetEvent('phone:sendSMS')
AddEventHandler('phone:sendSMS', function(receiver, message)
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local mynumber = getNumberPhone(xPlayer.identifier)

    local target = getIdentifierByPhoneNumber(receiver)
    
    local xPlayers = DBFWCore.GetPlayers()
    --if receiver ~= mynumber then
    MySQL.Async.execute('INSERT INTO phone_messages (sender, receiver, message) VALUES (@sender, @receiver, @message)', {
        ['@sender'] = mynumber,
        ['@receiver'] = receiver,
        ['@message'] = message
    }, function(result)
    end)
    for i=1, #xPlayers, 1 do
        local xPlayer = DBFWCore.GetPlayerFromId(xPlayers[i])
        if xPlayer then
            if xPlayer.identifier == target then
                local receiverID = xPlayer.source
                TriggerClientEvent('phone:newSMS', receiverID, 1, mynumber)
            end
        end
    end

end)

RegisterNetEvent('phone:serverGetMessagesBetweenParties')
AddEventHandler('phone:serverGetMessagesBetweenParties', function(sender, receiver, displayName)
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local mynumber = getNumberPhone(xPlayer.identifier)
    local result = MySQL.Sync.fetchAll("SELECT * FROM phone_messages WHERE (sender = @sender AND receiver = @receiver) OR (sender = @receiver AND receiver = @sender) ORDER BY id ASC", {['@sender'] = sender, ['@receiver'] = receiver})

    TriggerClientEvent('phone:clientGetMessagesBetweenParties', src, result, displayName, mynumber)
end)

RegisterNetEvent('phone:StartCallConfirmed')
AddEventHandler('phone:StartCallConfirmed', function(mySourceID)
    local channel = math.random(10000, 99999)
    local src = source

    TriggerClientEvent('phone:callFullyInitiated', mySourceID, mySourceID, src)
    TriggerClientEvent('phone:callFullyInitiated', src, src, mySourceID)

    -- After add them to the same channel or do it from server.
    TriggerClientEvent('phone:addToCall', source, channel)
    TriggerClientEvent('phone:addToCall', mySourceID, channel)

    TriggerClientEvent('phone:id', src, channel)
    TriggerClientEvent('phone:id', mySourceID, channel)
end)

RegisterNetEvent('phone:EndCall')
AddEventHandler('phone:EndCall', function(mySourceID, stupidcallnumberidk, somethingextra)
    local src = source
    TriggerClientEvent('phone:removefromToko', source, stupidcallnumberidk)

    if mySourceID ~= 0 or mySourceID ~= nil then
        TriggerClientEvent('phone:removefromToko', mySourceID, stupidcallnumberidk)
        TriggerClientEvent('phone:otherClientEndCall', mySourceID)
    end

    if somethingextra then
        TriggerClientEvent('phone:otherClientEndCall', src)
    end
end)

RegisterCommand("answer", function(source, args, rawCommand)
    local src = source
    TriggerClientEvent('phone:answercall', src)
end, false)

RegisterCommand("a", function(source, args, rawCommand)
    local src = source
    TriggerClientEvent('phone:answercall', src)
end, false)

RegisterCommand("h", function(source, args, rawCommand)
    local src = source
    TriggerClientEvent('phone:endCalloncommand', src)
end, false)


RegisterCommand("hangup", function(source, args, rawCommand)
    local src = source
    TriggerClientEvent('phone:endCalloncommand', src)
end, false)

RegisterCommand("lawyer", function(source, args, rawCommand)
    local src = source
    TriggerClientEvent('yellowPages:retrieveLawyersOnline', src, true)
end, false)

RegisterCommand("pnum", function(source, args, rawCommand)
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local identifier = xPlayer.getIdentifier()
    local srcPhone = getNumberPhone(identifier)


    TriggerClientEvent('sendMessagePhoneN', src, srcPhone)
end, false)

function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end
function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

AddEventHandler('es:playerLoaded',function(source)
    local sourcePlayer = tonumber(source)
    local identifier = getPlayerID(source)
    getOrGeneratePhoneNumber(sourcePlayer, identifier, function (myPhoneNumber)
    end)
end)

function getOrGeneratePhoneNumber (sourcePlayer, identifier, cb)
    local sourcePlayer = sourcePlayer
    local identifier = identifier
    local myPhoneNumber = getNumberPhone(identifier)
    if myPhoneNumber == '0' or myPhoneNumber == nil then
        repeat
            myPhoneNumber = getPhoneRandomNumber()
            local id = getIdentifierByPhoneNumber(myPhoneNumber)
        until id == nil
        MySQL.Async.insert("UPDATE users SET phone_number = @myPhoneNumber WHERE identifier = @identifier", {
            ['@myPhoneNumber'] = myPhoneNumber,
            ['@identifier'] = identifier
        }, function ()
            cb(myPhoneNumber)
        end)
    else
        cb(myPhoneNumber)
    end
end

function getPhoneRandomNumber()
    local numBase0 = 4
    local numBase1 = math.random(10,99)
    local numBase2 = math.random(100,999)
    local numBase3 = math.random(1000,9999)
    local num = string.format(numBase0 .. "" .. numBase1 .. "" .. numBase2 .. "" .. numBase3)
    return num
end

RegisterNetEvent('message:inDistanceZone')
AddEventHandler('message:inDistanceZone', function(somethingsomething, messagehueifh)
    local src = source		
    local first = messagehueifh:sub(1, 3)
    local second = messagehueifh:sub(4, 6)
    local third = messagehueifh:sub(7, 11)

    local msg = first .. "-" .. second .. "-" .. third
    TriggerClientEvent('chatMessagess', somethingsomething, 'Phone Number: ', 4, msg)
end)

RegisterNetEvent('message:tome')
AddEventHandler('message:tome', function(messagehueifh)
    local src = source		
    local first = messagehueifh:sub(1, 3)
    local second = messagehueifh:sub(4, 6)
    local third = messagehueifh:sub(7, 11)

    local msg = first .. "-" .. second .. "-" .. third
    TriggerClientEvent('chatMessagess', src, 'Phone Number: ', 4, msg)
end)

RegisterNetEvent('phone:getServerTime')
AddEventHandler('phone:getServerTime', function()
    local hours, minutes, seconds = Citizen.InvokeNative(0x50C7A99057A69748, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt())
    TriggerClientEvent('timeheader', -1, hours, minutes)
end)

RegisterNetEvent('getAccountInfo')
AddEventHandler('getAccountInfo', function()
    local src = source
    local player = DBFWCore.GetPlayerFromId(source)

    local money = player.getMoney()
    local inbank = player.getBank()
    local licenceTable = {}

    TriggerEvent('dbfw-license:getLicenses', source, function(licenses)
        licenceTable = licenses
    end)

    Citizen.Wait(100)

    -- print(licenceTable)
    
    TriggerClientEvent('getAccountInfo', src, money, inbank, licenceTable)
end)


--[[ Yellow Pages ]]

RegisterNetEvent('getYP')
AddEventHandler('getYP', function()
    local source = source
    MySQL.Async.fetchAll('SELECT * FROM phone_yp LIMIT 30', {}, function(yp)
        local deorencoded = json.encode(yp)
        TriggerClientEvent('YellowPageArray', source, yp)
    end)
end)

RegisterNetEvent('phone:updatePhoneJob')
AddEventHandler('phone:updatePhoneJob', function(advert)
    --local handle = handle
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local mynumber = getNumberPhone(xPlayer.identifier)
    local name = getIdentity(src)

    fal = name.firstname .. " " .. name.lastname

    MySQL.Async.execute('INSERT INTO phone_yp (name, advert, phoneNumber) VALUES (@name, @advert, @phoneNumber)', {
        ['@name'] = fal,
        ['@advert'] = advert,
        ['@phoneNumber'] = mynumber
    }, function(result)
        TriggerClientEvent('refreshYP', src)
    end)
end)

RegisterNetEvent('deleteAllYP')
AddEventHandler('deleteAllYP', function()
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    local src = source
    MySQL.Async.execute('DELETE FROM phone_yp', {}, function (result) end)
end)

RegisterCommand("payphone", function(source, args, raw)
    local src = source
    local pnumber = args[1]
    local xPlayer = DBFWCore.GetPlayerFromId(source)
    if xPlayer.get('money') >= 25 then
        TriggerClientEvent('phone:makepayphonecall', src, pnumber)
        xPlayer.removeMoney(25)
    else
        TriggerClientEvent('DoLongHudText', _source, 'You dont have $25 for the payphone', 2)
       
    end
end, false)

RegisterCommand("call", function(source, args, raw)
    local src = source
    local pnumber = args[1]
    local xPlayer = DBFWCore.GetPlayerFromId(source)
        TriggerClientEvent('phone:makecall', src, pnumber)
end, false)

