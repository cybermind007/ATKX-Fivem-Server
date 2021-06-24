
DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
local IdentifierTables = {
    {table = "addon_account_data", column = "owner"},
--    {table = "addon_inventory_items", column = "owner"},
    {table = "apartments", column = "identifier"},
    {table = "billing", column = "identifier"},
    {table = "playerstattoos", column = "identifier"},
    {table = "character_outfits", column = "steamid"},
    {table = "characters", column = "identifier"},
    {table = "jail", column = "identifier"},
    {table = "dpkeybinds", column = "id"},
	{table = "datastore_data", column = "owner"},
	{table = "owned_vehicles", column = "owner"},
    {table = "datastore_data", column = "owner"},
	{table = "society_moneywash", column = "identifier"},
	{table = "users", column = "identifier"},
    {table = "user_accounts", column = "identifier"},
	{table = "user_inventory2", column = "name"},
    {table = "user_licenses", column = "owner"},
    {table = "dopeplants", column = "owner"},
    {table = "phone_contacts", column = "identifier"},
    {table = "player_houses", column = "identifier"},
    {table = "phone_messages", column = "id"},
    {table = "dbfw_ammo", column = "owner"},
}

RegisterServerEvent("kashactersS:SetupCharacters")
AddEventHandler('kashactersS:SetupCharacters', function()
    local src = source
    local LastCharId = GetLastCharacter(src)
    SetIdentifierToChar(GetPlayerIdentifiers(src)[1], LastCharId)
    local Characters = GetPlayerCharacters(src)
    TriggerClientEvent('kashactersC:SetupUI', src, Characters)
    TriggerClientEvent('updatecid', src, GetPlayerIdentifiers(src)[1])
end)

RegisterServerEvent("kashactersS:CharacterChosen")
AddEventHandler('kashactersS:CharacterChosen', function(charid, ischar, spawnid)
	local spid = spawnid
    local src = source
    if type(charid) == "number" and type(ischar) == "boolean" then
        local spawn = {}
        SetLastCharacter(src, tonumber(charid))
        SetCharToIdentifier(GetPlayerIdentifiers(src)[1], tonumber(charid))
        if ischar then

            if spid=="1" then
                spawn = GetSpawnPos(src)
            elseif spid=="2" then
                --Stab city
                spawn = { x = 101.0187, y = -1713.761, z = 30.11242 }
            elseif spid=="3" then
                --Sandy Shores
                spawn = { x = 101.0187, y = -1713.761, z = 30.11242 }
            elseif spid=="4" then
                --paleto
                spawn = { x = 101.0187, y = -1713.761, z = 30.11242 }
            else
                spawn = GetSpawnPos(src)
            end
            if spawn.x == nil then
                spawn = { x = 101.0187, y = -1713.761, z = 30.11242 }
            end
            TriggerClientEvent("kashactersC:SpawnCharacter", src, spawn)
            TriggerClientEvent('updatecid', src, GetPlayerIdentifiers(src)[1])
        else --default spawn mode

            spawn = { x = 101.0187, y = -1713.761, z = 30.11242 } -- DEFAULT SPAWN POSITION -- EDIT THIS
            TriggerClientEvent("kashactersC:SpawnCharacter", src, spawn,true)
        end
    end
end)

RegisterServerEvent('kashactersS:Yeet')
AddEventHandler('kashactersS:Yeet', function()
    local src = source
    local spawn = {}

    spawn = GetSpawnPos(src)
    TriggerClientEvent('kashactersC:ChoseCharacter', src, spawn)
end)

RegisterServerEvent("kashactersS:Register")
AddEventHandler('kashactersS:Register', function(charid)
    local src = source
    if type(charid) == "number" then 
        GetIdentifierWithSteam(GetPlayerIdentifiers(src)[1], charid)
        TriggerClientEvent("kashactersC:ReloadCharacters", src)
    end
end)

RegisterServerEvent("kashactersS:DeleteCharacter")
AddEventHandler('kashactersS:DeleteCharacter', function(charid)
    local src = source
    DeleteCharacter(GetPlayerIdentifiers(src)[1], charid)
    TriggerClientEvent("kashactersC:ReloadCharacters", src)
    TriggerClientEvent('updatecid', src, GetPlayerIdentifiers(src)[1])
end)

function GetPlayerCharacters(source)
    local identifier = GetIdentifierWithoutSteam(GetPlayerIdentifiers(source)[1])
    local Chars = MySQLAsyncExecute("SELECT * FROM `users` WHERE identifier LIKE '%"..identifier.."%'")
    return Chars
end

function GetLastCharacter(source)
    local LastChar = MySQLAsyncExecute("SELECT `charid` FROM `user_lastcharacter` WHERE `steamid` = '"..GetPlayerIdentifiers(source)[1].."'")
    if LastChar[1] ~= nil and LastChar[1].charid ~= nil then
        return tonumber(LastChar[1].charid)
    else
        MySQLAsyncExecute("INSERT INTO `user_lastcharacter` (`steamid`, `charid`) VALUES('"..GetPlayerIdentifiers(source)[1].."', 1)")
        return 1
    end
end

function SetLastCharacter(source, charid)
    MySQLAsyncExecute("UPDATE `user_lastcharacter` SET `charid` = '"..charid.."' WHERE `steamid` = '"..GetPlayerIdentifiers(source)[1].."'")
end

function SetIdentifierToChar(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("UPDATE `"..itable.table.."` SET `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutSteam(identifier).."' WHERE `"..itable.column.."` = '"..identifier.."'")
    end
end

function SetCharToIdentifier(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("UPDATE `"..itable.table.."` SET `"..itable.column.."` = '"..identifier.."' WHERE `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutSteam(identifier).."'")
    end
end

function DeleteCharacter(identifier, charid)
    for _, itable in pairs(IdentifierTables) do
        MySQLAsyncExecute("DELETE FROM `"..itable.table.."` WHERE `"..itable.column.."` = 'Char"..charid..GetIdentifierWithoutSteam(identifier).."'")
    end
end

function GetSpawnPos(source)
    local SpawnPos = MySQLAsyncExecute("SELECT `position` FROM `users` WHERE `identifier` = '"..GetPlayerIdentifiers(source)[1].."'")
	if SpawnPos[1].position ~= nil then
		return json.decode(SpawnPos[1].position)
    else
		local spawn = { x = -1045.42, y = -2750.85, z = 22.31 }
		return spawn
	end
end

function GetIdentifierWithoutSteam(Identifier)
    return string.gsub(Identifier, "steam", "")
end

function MySQLAsyncExecute(query)
    local IsBusy = true
    local result = nil
    MySQL.Async.fetchAll(query, {}, function(data)
        result = data
        IsBusy = false
    end)
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end