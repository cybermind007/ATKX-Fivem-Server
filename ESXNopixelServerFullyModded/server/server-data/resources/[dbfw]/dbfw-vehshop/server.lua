DBFWCore = nil
TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

local repayTime = 168 * 60 -- hours * 60
local timer = ((60 * 1000) * 10) -- 10 minute timer

local carTable = {
	[1] = { ["model"] = "gauntlet", ["baseprice"] = 100000, ["commission"] = 15 }, 
	[2] = { ["model"] = "dubsta3", ["baseprice"] = 100000, ["commission"] = 15 },
	[3] = { ["model"] = "landstalker", ["baseprice"] = 100000, ["commission"] = 15 },
	[4] = { ["model"] = "bobcatxl", ["baseprice"] = 100000, ["commission"] = 15 },
	[5] = { ["model"] = "surfer", ["baseprice"] = 100000, ["commission"] = 15 },
	[6] = { ["model"] = "glendale", ["baseprice"] = 100000, ["commission"] = 15 },
	[7] = { ["model"] = "washington", ["baseprice"] = 100000, ["commission"] = 15 },
}

-- Update car table to server
RegisterServerEvent('carshop:table')
AddEventHandler('carshop:table', function(table)
    if table ~= nil then
        carTable = table
        TriggerClientEvent('veh_shop:returnTable', -1, carTable)
        updateDisplayVehicles()
    end
end)

-- Enables finance for 60 seconds
RegisterServerEvent('finance:enable')
AddEventHandler('finance:enable', function(plate)
    if plate ~= nil then
        TriggerClientEvent('finance:enableOnClient', -1, plate)
    end
end)

RegisterServerEvent('buy:enable')
AddEventHandler('buy:enable', function(plate)
    if plate ~= nil then
        TriggerClientEvent('buy:enableOnClient', -1, plate)
    end
end)

-- return table
-- TODO (return db table)
RegisterServerEvent('carshop:requesttable')
AddEventHandler('carshop:requesttable', function()
    local user = DBFWCore.GetPlayerFromId(source)
    local display = MySQL.Sync.fetchAll('SELECT * FROM vehicles_display')
    for k,v in pairs(display) do
        carTable[v.ID] = v
        v.price = carTable[v.ID].baseprice
    end
    TriggerClientEvent('veh_shop:returnTable', user.source, carTable)
end)

-- Check if player has enough money
RegisterServerEvent('CheckMoneyForVeh')
AddEventHandler('CheckMoneyForVeh', function(name, model,price,financed)
	local user = DBFWCore.GetPlayerFromId(source)
    local money = user.getMoney()
    if financed then
        local financedPrice = math.ceil(price / 4)
        if money >= financedPrice then
            user.removeMoney(financedPrice)
            TriggerClientEvent('FinishMoneyCheckForVeh', user.source, name, model, price, financed)
        else
            TriggerClientEvent('DoLongHudText', user.source, 'You dont have enough money on you!', 2)
            TriggerClientEvent('carshop:failedpurchase', user.source)
        end
    else
        if money >= price then
            user.removeMoney(price)
            TriggerClientEvent('FinishMoneyCheckForVeh', user.source, name, model, price, financed)
        else
            TriggerClientEvent('DoLongHudText', user.source, 'You dont have enough money on you!', 2)
            TriggerClientEvent('carshop:failedpurchase', user.source)
        end
    end
end)


-- Add the car to database when completed purchase
RegisterServerEvent('BuyForVeh')
AddEventHandler('BuyForVeh', function(vehicleProps,name, vehicle, price, financed)
    local user = DBFWCore.GetPlayerFromId(source)
    if financed then
        local cols = 'owner, plate, vehicle, buy_price, finance, financetimer, vehiclename, shop'
        local val = '@owner, @plate, @vehicle, @buy_price, @finance, @financetimer, @vehiclename, @shop'
        local downPay = math.ceil(price / 4)
        local data = MySQL.Sync.fetchAll("SELECT money FROM addon_account_data WHERE account_name=@account_name",{['@account_name'] = 'pdm'})
        local curSociety = data[1].money
        MySQL.Async.execute('INSERT INTO owned_vehicles ( '..cols..' ) VALUES ( '..val..' )',{
            ['@owner']   = user.identifier,
            ['@plate']   = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@vehiclename'] = vehicle,
            ['@buy_price'] = price,
            ['@finance'] = price - downPay,
            ['@financetimer'] = repayTime,
            ['@shop'] = 'pdm'
        })
        MySQL.Sync.execute('UPDATE addon_account_data SET money=@money WHERE account_name=@account_name',{['@money'] = curSociety + downPay,['@account_name'] = 'pdm'})
    else
        local data = MySQL.Sync.fetchAll("SELECT money FROM addon_account_data WHERE account_name=@account_name",{['@account_name'] = 'pdm'})
        local curSociety = data[1].money
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, vehiclename, shop) VALUES (@owner, @plate, @vehicle, @vehiclename, @shop)',{
            ['@owner']   = user.identifier,
            ['@plate']   = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@vehiclename'] = vehicle,
            ['@buy_price'] = price,
            ['@shop'] = 'pdm'
        })
        MySQL.Sync.execute('UPDATE addon_account_data SET money=@money WHERE account_name=@account_name',{['@money'] = curSociety + price,['@account_name'] = 'pdm'})
    end
end)

-- Get All finance > 0 then take 10min off
-- Every 10 Min
function updateFinance()
    MySQL.Async.fetchAll('SELECT financetimer, plate FROM owned_vehicles WHERE financetimer > @financetimer', {
        ["@financetimer"] = 0
    }, function(result)
        for i=1, #result do
            local financeTimer = result[i].financetimer
            local plate = result[i].plate
            local newTimer = financeTimer - 10
            if financeTimer ~= nil then
                MySQL.Sync.execute('UPDATE owned_vehicles SET financetimer=@financetimer WHERE plate=@plate', {
                    ['@plate'] = plate,
                    ['@financetimer'] = newTimer
                })
            end
        end
    end)
    SetTimeout(timer, updateFinance)
end
SetTimeout(timer, updateFinance)

RegisterNetEvent('RS7x:phonePayment')
AddEventHandler('RS7x:phonePayment', function(plate)
    local src = source
    local pPlate = plate
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local group = MySQL.Sync.fetchAll("SELECT shop FROM owned_vehicles WHERE plate=@plate", {['@plate'] = plate})
    print(group[1].shop)
    if pPlate ~= nil then
        local pData = MySQL.Sync.fetchAll("SELECT buy_price, plate FROM owned_vehicles WHERE plate=@plate", {['@plate'] = pPlate})
        for k,v in pairs(pData) do
            if pData ~= nil then
                if pPlate == v.plate then
                    local price = (v.buy_price / 10)
                    if xPlayer.getMoney() >= price then
                        xPlayer.removeMoney(price)
                        fuck = true
                        TriggerClientEvent('chatMessagess', src, 'IMPORTANT: ', 1, 'Please see pdm dealer for reimbursement. Take a screen shot of the payment or you will not receive any money back!')
                        TriggerClientEvent('chatMessagess', src, 'IMPORTANT: ', 1, 'You payed $'.. price .. ' on your vehicle.')
                    else
                        fuck = false
                        TriggerClientEvent('DoLongHudText', src, 'You don\'t have enough money to pay on this vehicle!', 2)
                        TriggerClientEvent('DoLongHudText', src, 'You need $'.. price .. ' to pay for your vehicle!', 1)
                    end

                    if fuck then
                        local data = MySQL.Sync.fetchAll("SELECT finance FROM owned_vehicles WHERE plate=@plate",{['@plate'] = plate})
                        if not data or not data[1] then return; end
                        local prevAmount = data[1].finance
                        if prevAmount - price <= 0 or prevAmount - price <= 0.0 then
                            settimer = 0
                        else
                            settimer = repayTime
                        end
                        if prevAmount < price then
                            MySQL.Sync.execute('UPDATE owned_vehicles SET finance=@finance WHERE plate=@plate',{['@finance'] = 0, ['@plate'] = plate})
                            MySQL.Sync.execute('UPDATE owned_vehicles SET financetimer=@financetimer WHERE plate=@plate',{['@financetimer'] = 0, ['@plate'] = plate})
                        else
                            MySQL.Sync.execute('UPDATE owned_vehicles SET finance=@finance WHERE plate=@plate',{['@finance'] = prevAmount - price, ['@plate'] = plate})
                            MySQL.Sync.execute('UPDATE owned_vehicles SET financetimer=@financetimer WHERE plate=@plate',{['@financetimer'] = settimer, ['@plate'] = plate})
                        end
                    end

                    local data = MySQL.Sync.fetchAll("SELECT money FROM addon_account_data WHERE account_name=@account_name",{['@account_name'] = group[1].shop})
                    if not data then return; end
                    local curSociety = data[1].money
                    MySQL.Sync.execute('UPDATE addon_account_data SET money=@money WHERE account_name=@account_name',{['@money'] = curSociety + price,['@account_name'] = group[1].shop})
                end
                return
            end
        end
    end
end)

function updateDisplayVehicles()
    for i=1, #carTable do
        MySQL.Sync.execute("UPDATE vehicles_display SET model=@model, commission=@commission, baseprice=@baseprice WHERE ID=@ID",{
            ['@ID'] = i,
            ['@model'] = carTable[i]["model"],
            ['@commission'] = carTable[i]["commission"],
            ['@baseprice'] = carTable[i]["baseprice"]
        })
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        updateDisplayVehicles()
    end
end)

--Citizen.CreateThread(function()
--    updateFinance()
--end)

--[[
        MySQL.Async.fetchAll('SELECT finance, plate FROM owned_vehicles WHERE finance < @finance', {
        ["@finance"] = os.date('%Y-%m-%d %H:%M:%S', os.time())
    }, function(result)
        local finance = result[1].finance
        local plate = result[1].plate
        if finance ~= nil then
            local reference = finance
            local daysfrom = os.difftime(os.time(), reference) / (24 * 60 * 60)
            local wholedays = math.floor(daysfrom)
            if wholedays < 0 then
                MySQL.Async.execute('UPDATE owned_vehicles SET finance = @finance WHERE plate=@plate', {
                    ['plate'] = e
                    ['@finance'] = fi
                })
            end
        end
    end)
    --MySQL.Sync.execute('UPDATE finance FROM owned_vehicles WHERE ')
]]