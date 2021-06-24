DBWF = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBWF = obj end)

-- Helper function for getting player money
function getMoney(source)
    local xPlayer = DBWF.GetPlayerFromId(source)
    local getmoney = xPlayer.getMoney()
    return getmoney
end

-- Helper function for removing player money
function removeMoney(source, amount)
    local xPlayer = DBWF.GetPlayerFromId(source)
    xPlayer.removeMoney(amount)
end

-- Helper function for adding player money
function addMoney(source, amount)
    local xPlayer = DBWF.GetPlayerFromId(source)
    xPlayer.addMoney(amount)
end