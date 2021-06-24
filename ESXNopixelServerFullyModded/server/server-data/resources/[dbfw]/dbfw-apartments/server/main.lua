DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

local ApartmentObjects = {}

RegisterServerEvent('apartments:server:CreateApartment')
AddEventHandler('apartments:server:CreateApartment', function(type, label)
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local num =  tostring(math.random(1, 9999))
    local apartmentId = tostring(type .. num)
    local label = tostring(label .. " " .. num)
    if ( xPlayer.getAccount('bank').money >= 1000 ) then
        xPlayer.removeBank(1000)
        MySQL.Async.execute("INSERT INTO apartments (name, type, label, identifier) VALUES (@name, @type, @label, @identifier)",{['@name'] = apartmentId, ['@type'] = type , ['@label'] = label,['@identifier'] = xPlayer.identifier })
        TriggerClientEvent('DoLongHudText', src,('You have apartment ('..label..')'), 3)
        TriggerClientEvent("apartments:client:SpawnInApartment", src, apartmentId, type)
        TriggerClientEvent("apartments:client:SetHomeBlip", src, type)
    else
        TriggerClientEvent('DoLongHudText', src,('You Dont Have Enough Money In The Bank. Amount Required: $1000'), 2)
    end
end)

RegisterServerEvent('apartments:server:UpdateApartment')
AddEventHandler('apartments:server:UpdateApartment', function(type)
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    MySQL.Async.execute('UPDATE apartments SET type= @type WHERE identifier = @identifier',{['@identifier'] = xPlayer.identifier})
    TriggerClientEvent('DoLongHudText', src,('You changed your apartment!'), 2)
    TriggerClientEvent("apartments:client:SetHomeBlip", src, type)
end)

RegisterServerEvent('apartments:server:RingDoor')
AddEventHandler('apartments:server:RingDoor', function(apartmentId, apartment)
    local src = source
    if ApartmentObjects[apartment].apartments[apartmentId] ~= nil and next(ApartmentObjects[apartment].apartments[apartmentId].players) ~= nil then
        for k, v in pairs(ApartmentObjects[apartment].apartments[apartmentId].players) do
            TriggerClientEvent('apartments:client:RingDoor', k, src)
        end
    end
end)

RegisterServerEvent('apartments:server:OpenDoor')
AddEventHandler('apartments:server:OpenDoor', function(target, apartmentId, apartment)
    local src = source
    local OtherPlayer = DBFWCore.GetPlayerFromId(target)
    if OtherPlayer ~= nil then
        TriggerClientEvent('apartments:client:SpawnInApartment', OtherPlayer.source, apartmentId, apartment)
    end
end)

RegisterServerEvent('apartments:server:AddObject')
AddEventHandler('apartments:server:AddObject', function(apartmentId, apartment, offset)
    local src = source
    local Player = DBFWCore.GetPlayerFromId(src)
    if ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil and ApartmentObjects[apartment].apartments[apartmentId] ~= nil then
        ApartmentObjects[apartment].apartments[apartmentId].players[src] = Player.identifier
    else
        if ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
            ApartmentObjects[apartment].apartments[apartmentId] = {}
            ApartmentObjects[apartment].apartments[apartmentId].offset = offset
            ApartmentObjects[apartment].apartments[apartmentId].players = {}
            ApartmentObjects[apartment].apartments[apartmentId].players[src] = Player.identifier
        else
            ApartmentObjects[apartment] = {}
            ApartmentObjects[apartment].apartments = {}
            ApartmentObjects[apartment].apartments[apartmentId] = {}
            ApartmentObjects[apartment].apartments[apartmentId].offset = offset
            ApartmentObjects[apartment].apartments[apartmentId].players = {}
            ApartmentObjects[apartment].apartments[apartmentId].players[src] = Player.identifier
        end
    end
end)

RegisterServerEvent('apartments:server:RemoveObject')
AddEventHandler('apartments:server:RemoveObject', function(apartmentId, apartment)
    local src = source
    if ApartmentObjects[apartment].apartments[apartmentId].players ~= nil then
        ApartmentObjects[apartment].apartments[apartmentId].players[src] = nil
        if next(ApartmentObjects[apartment].apartments[apartmentId].players) == nil then
            ApartmentObjects[apartment].apartments[apartmentId] = nil
        end
    end
end)

function CreateApartmentId(type)
    local UniqueFound = false
	local AparmentId = nil

	while not UniqueFound do
        local AparmentId = tostring(math.random(1, 9999))
        MySQL.Async.fetchAll("SELECT COUNT(*) as count FROM apartments WHERE name = @name",{['@name'] =tostring(type .. AparmentId) }, function(result)
            print(result)
			if result[1].count == 0 then
				UniqueFound = true
			end
		end)
	end
	return AparmentId
end

function GetApartmentInfo(apartmentId)
    local retval = nil
    MySQL.Async.fetchAll("SELECT * FROM apartments WHERE name = @name ",{['@name'] = apartmentId}, function(result)
        if result[1] ~= nil then 
            retval = result[1]
        end
    end)
    return retval
end

function GetOwnedApartment(identifier)
    MySQL.Async.fetchAll("SELECT * FROM apartments WHERE identifier = @identifier ", {['@identifier'] = identifier}, function(result)
        if result[1] ~= nil then 
            return result[1]
        end
        return nil
    end)
    return nil
end

DBFWCore.RegisterServerCallback('apartments:GetAvailableApartments', function(source, cb, apartment)
    local apartments = {}
    if ApartmentObjects ~= nil and ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
        for k, v in pairs(ApartmentObjects[apartment].apartments) do
            if (ApartmentObjects[apartment].apartments[k] ~= nil and next(ApartmentObjects[apartment].apartments[k].players) ~= nil) then
                local apartmentInfo = GetApartmentInfo(k)
                apartments[k] = apartmentInfo.label
            end
        end
    end
    cb(apartments)
end)
DBFWCore.RegisterServerCallback('apartments:GetApartmentOffset', function(source, cb, apartmentId)
    local retval = 0
    if ApartmentObjects ~= nil then
        for k, v in pairs(ApartmentObjects) do
            if (ApartmentObjects[k].apartments[apartmentId] ~= nil and tonumber(ApartmentObjects[k].apartments[apartmentId].offset) ~= 0) then
                retval = tonumber(ApartmentObjects[k].apartments[apartmentId].offset)
            end
        end
    end
    cb(retval)
end)

DBFWCore.RegisterServerCallback('apartments:GetApartmentOffsetNewOffset', function(source, cb, apartment)
    local retval = Apartments.SpawnOffset
    if ApartmentObjects ~= nil and ApartmentObjects[apartment] ~= nil and ApartmentObjects[apartment].apartments ~= nil then
        for k, v in pairs(ApartmentObjects[apartment].apartments) do
            if (ApartmentObjects[apartment].apartments[k] ~= nil) then
                retval = ApartmentObjects[apartment].apartments[k].offset + Apartments.SpawnOffset
            end
        end
    end
    cb(retval)
end)

DBFWCore.RegisterServerCallback('apartments:GetOwnedApartment', function(source, cb, cid)
    if cid ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM apartments WHERE identifier = @identifier ",{['@identifier'] = cid}, function(result)
            if result[1] ~= nil then 
                return cb(result[1])
            end
            return cb(nil)
        end)
    else
        local src = source
        local Player = DBFWCore.GetPlayerFromId(src)
        MySQL.Async.fetchAll("SELECT * FROM apartments WHERE identifier = @identifier", {['@identifier']= Player.identifier}, function(result)
            if result[1] ~= nil then 
                return cb(result[1])
            end
            return cb(nil)
        end)
    end
end)

DBFWCore.RegisterServerCallback('apartments:IsOwner', function(source, cb, apartment)
	local src = source
    local Player = DBFWCore.GetPlayerFromId(src)
    if Player ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM apartments WHERE  identifier = @identifier",{['@identifier'] = Player.identifier}, function(result)
            if result[1] ~= nil then 
                if result[1].type == apartment then
                    cb(true)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        end)
    end
end)


DBFWCore.RegisterServerCallback('apartments:GetOutfits', function(source, cb)
	local src = source
	local Player = DBFWCore.GetPlayerFromId(src)

	if Player then
		MySQL.Async.fetchAll("SELECT * FROM player_outfits WHERE identifier = @identifier",{['@identifier'] = Player.identifier}, function(result)
			if result[1] ~= nil then
				cb(result)
			else
				cb(nil)
			end
		end)
	end
end)
