DBWF = nil
local pos = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBWF = obj end)



DBWF.RegisterServerCallback("spawnselector:lastlocation",function(source,cb)
    local sql = MySQL.Sync.fetchAll("SELECT `position` FROM `users` WHERE `identifier` = '"..GetPlayerIdentifiers(source)[1].."'")
    if sql[1] ~= nil then
        pos = json.decode(sql[1].position)
	else
        pos = vector3(195.58, -933.15 , 30.69)
	end
    cb(pos)
end)