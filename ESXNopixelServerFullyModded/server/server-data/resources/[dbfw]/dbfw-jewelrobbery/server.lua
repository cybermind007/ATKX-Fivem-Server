DBFWCore = nil 
local joblist = {}
local resettime = nil
local policeclosed = false
local currentStreetHash, intersectStreetHash

AddEventHandler('')


TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('dbfw-jewelrobbery:closestore')
AddEventHandler('dbfw-jewelrobbery:closestore', function()
    local _source = source
    local xPlayer = DBFWCore.GetPlayerFromId(_source)
    local ispolice = false
	for i, v in pairs(Config.PoliceJobs) do
		if xPlayer.job.name == v then
			ispolice = true
			break
		end
	end
    if ispolice and resettime ~= nil then
        TriggerClientEvent('dbfw-jewelrobbery:policeclosure', -1)
        policeclosed = true
    elseif ispolice and resettime == nil then
        TriggerClientEvent('DoLongHudText', _source, 'Store does not appear to be damaged - unable to force closed!', 2)          
    else
        TriggerClientEvent('DoLongHudText', _source, 'Only Law enforcment or Vangelico staff can decide if store is closed!', 2)       
    end
end)

RegisterServerEvent('dbfw-jewelrobbery:playsound')
AddEventHandler('dbfw-jewelrobbery:playsound', function(x,y,z, soundtype)
    TriggerClientEvent('dbfw-jewelrobbery:playsound', -1, x, y, z, soundtype)
end)

RegisterServerEvent('dbfw-jewelrobbery:setcase')
AddEventHandler('dbfw-jewelrobbery:setcase', function(casenumber, switch)
    _source = source
    if not Config.CaseLocations[casenumber].Broken then
        Config.CaseLocations[casenumber].Broken  = true
        TriggerEvent('dbfw-jewelrobbery:RestTimer')
        TriggerClientEvent('dbfw-jewelrobbery:setcase', -1, casenumber, true)
        TriggerEvent('dbfw-jewelrobbery:AwardItems', _source)
    end
end)

RegisterServerEvent('dbfw-jewelrobbery:policenotify')
AddEventHandler('dbfw-jewelrobbery:policenotify', function()
    TriggerClientEvent('dbfw-dispatch:jewelrobbery', -1)
	return
end)


RegisterServerEvent('dbfw-jewelrobbery:loadconfig')
AddEventHandler('dbfw-jewelrobbery:loadconfig', function()
    local _source = source
    local xPlayer = DBFWCore.GetPlayerFromId(_source)
    local buildlist = {
        id = _source,
        job = xPlayer.job.name,
    }
    table.insert(joblist, buildlist)
    TriggerClientEvent('dbfw-jewelrobbery:loadconfig', _source, Config.CaseLocations)
    if policeclosed then
        TriggerClientEvent('dbfw-jewelrobbery:policeclosure', _source)
    end

end)

AddEventHandler('dbfw-jewelrobbery:AwardItems', function(source)
    local _source = source
	if math.random(25) == 20 then
        local myluck = math.random(5)

        if myluck == 1 then
            TriggerClientEvent("player:receiveItem", _source, "gruppe63",1)
        elseif myluck == 2 then
            TriggerClientEvent("player:receiveItem", _source, "cb",1)
        end
	end

	TriggerClientEvent("player:receiveItem", _source, "rolexwatch",math.random(5,20))

	if math.random(5) == 1 then
		TriggerClientEvent("player:receiveItem", _source, "goldbar",math.random(1,20))
	end

	if math.random(69) == 69 then
		TriggerClientEvent("player:receiveItem", _source, "valuablegoods",math.random(15))
    end
    TriggerClientEvent("player:receiveItem", _source, "goldbar",1)
end)


AddEventHandler('dbfw-jewelrobbery:RestTimer', function()
    if resettime == nil then
        totaltime = Config.ResetTime * 60
        resettime = os.time() + totaltime

        while os.time() < resettime do
            Citizen.Wait(2350)
        end

        for i, v in pairs(Config.CaseLocations) do
            v.Broken = false
        end
        TriggerClientEvent('dbfw-jewelrobbery:resetcases', -1, Config.CaseLocations)
        resettime = nil
        policeclosed = false
    end
end)


AddEventHandler('dbfw-jewelrobbery:AwardItems', function(serverid)
    local xPlayer = DBFWCore.GetPlayerFromId(serverid)

    local randomitem = math.random(1,100)
    for i, v in pairs(Config.ItemDrops) do 
        if randomitem <= v.chance then
            randomamount = math.random(1, v.max)
            sourceItem = xPlayer.getInventoryItem(v.name)
            if sourceItem.limit ~= nil then
                if sourceItem.limit ~= -1 and (sourceItem.count + randomamount) > sourceItem.limit then
                    if sourceItem.count < sourceItem.limit then
                        randomamount = sourceItem.limit - sourceItem.count
                        xPlayer.addInventoryItem(v.name, randomamount)
                    else
                        TriggerClientEvent('DoLongHudText', _source, 'Not enough room in your inventory to carry more '.. sourceItem.label, 2) 
                    end
                else
                    xPlayer.addInventoryItem(v.name, randomamount)
                end
                break
            else
                xPlayer.addInventoryItem(v.name, randomamount)
                break
            end
        end
    end

end)

function getIdentity(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			identifier = identity['identifier'],
			firstname = identity['firstname'],
			lastname = identity['lastname'],
			dateofbirth = identity['dateofbirth'],
			sex = identity['sex'],
			height = identity['height'],
			phonenumber = identity['phone_number']

		}
	else
		return nil
	end
end