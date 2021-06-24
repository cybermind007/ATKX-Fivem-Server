local steamIds = {
    ["steam:11000010aa15521"] = true --kevin
}

local DBFWCore = nil
-- DBFWCore
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('dbfw-doors:alterlockstate2')
AddEventHandler('dbfw-doors:alterlockstate2', function()
    --dbfw.DoorCoords[10]["lock"] = 0

    TriggerClientEvent('dbfw-doors:alterlockstateclient', source, dbfw.DoorCoords)

end)

RegisterServerEvent('dbfw-doors:alterlockstate')
AddEventHandler('dbfw-doors:alterlockstate', function(alterNum)
    print('lockstate:', alterNum)
    dbfw.alterState(alterNum)
end)

RegisterServerEvent('dbfw-doors:ForceLockState')
AddEventHandler('dbfw-doors:ForceLockState', function(alterNum, state)
    dbfw.DoorCoords[alterNum]["lock"] = state
    TriggerClientEvent('dbfw:Door:alterState', -1,alterNum,state)
end)

RegisterServerEvent('dbfw-doors:requestlatest')
AddEventHandler('dbfw-doors:requestlatest', function()
    local src = source 
    local steamcheck = DBFWCore.GetPlayerFromId(source).identifier
    if steamIds[steamcheck] then
        TriggerClientEvent('doors:HasKeys',src,true)
    end
    TriggerClientEvent('dbfw-doors:alterlockstateclient', source,dbfw.DoorCoords)
end)

function isDoorLocked(door)
    if dbfw.DoorCoords[door].lock == 1 then
        return true
    else
        return false
    end
end