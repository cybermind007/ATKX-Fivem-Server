DBFWCore = nil
passanger1 = nil
passanger2 = nil
passanger3 = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)

RegisterServerEvent('cr7842-882ga:445-266-8887-112')
AddEventHandler('cr7842-882ga:445-266-8887-112', function(amount)
	local _source = source
	local xPlayer = DBFWCore.GetPlayerFromId(_source)
	local payamount = math.ceil(amount)
	local payout = math.random(2,4)
	local matherino = math.random(0, 2)
	xPlayer.addMoney(tonumber(payamount))
	if matherino == 2 then
		TriggerClientEvent('player:receiveItem', _source, 'plastic', payout)
		TriggerClientEvent('player:receiveItem', _source, 'scrapmetal', payout)
	end
	TriggerClientEvent('DoLongHudText', _source, 'You received $'.. payamount ..' from this stop!', 1)
end)

RegisterServerEvent('cr7842-882ga:8475-249-37-5874')
AddEventHandler('cr7842-882ga:8475-249-37-5874', function(binpos, platenumber, bagnumb)
	TriggerClientEvent('cr7842-882ga:46-4565-47-656-68', -1, binpos, platenumber,  bagnumb)
end)

RegisterServerEvent('cr7842-882ga:284-4588-658-4446')
AddEventHandler('cr7842-882ga:284-4588-658-4446', function(platenumber, amount)
	TriggerClientEvent('cr7842-882ga:974-4888-365-44', -1, platenumber, amount)
end)

RegisterServerEvent('cr7842-882ga:7894-670-56-0943')
AddEventHandler('cr7842-882ga:7894-670-56-0943', function(platenumber)
	TriggerClientEvent('cr7842-882ga:4169-656-88-01', -1, platenumber)
end)

RegisterServerEvent('cr7842-882ga:66-111-894-1346')
AddEventHandler('cr7842-882ga:66-111-894-1346', function(platenumber)
	TriggerClientEvent('cr7842-882ga:294-22-483-0027', -1, platenumber)
end)

RegisterServerEvent('cr7842-882ga:975-348-75-34')
AddEventHandler('cr7842-882ga:975-348-75-34', function(platenumber)
	TriggerClientEvent('cr7842-882ga:54-9416-44-8887', -1, platenumber)
end)

RegisterServerEvent('cr7842-882ga:7669-652-8884-79')
AddEventHandler('cr7842-882ga:7669-652-8884-79', function(platenumber, bagstopay)
	local _source = source
	local xPlayer = DBFWCore.GetPlayerFromId(_source)
	TriggerClientEvent('cr7842-882ga:7510-44-3987-440', -1, platenumber, bagstopay, xPlayer )
end)

RegisterServerEvent('cr7842-882ga:498-568-7243-5583-67')
AddEventHandler('cr7842-882ga:498-568-7243-5583-67', function()
	_source = source
	local currenttruckcount = Config.TruckPlateNumb
	TriggerClientEvent('cr7842-882ga:496-15-9149-81-785', _source,  currenttruckcount)
end)

RegisterServerEvent('cr7842-882ga:54-9415-146-9581')
AddEventHandler('cr7842-882ga:54-9415-146-9581', function()
	local currenttruckcount = Config.TruckPlateNumb + 1
	if currenttruckcount == 999 then currenttruckcount = 1 end
	Config.TruckPlateNumb = currenttruckcount
	-- RegisterServerEvent('srpgarbagejob:movetruckcount
	-- TriggerClientEvent('srpgarbagejob:configset'
end)




-- cr7842-882ga --cr7842-882ga






--Server and client side
-- dbfw-garbagejob:pay = 445-266-8887-112
-- dbfw-garbagejob:requestpay = 284-4588-658-4446
-- dbfw-garbagejob:startpayrequest = 974-4888-365-44
-- dbfw-garbagejob:countbagtotal = 54-9416-44-8887
-- dbfw-garbagejob:bagsdone = 7669-652-8884-79
-- dbfw-garbagejob:removedbag = 4169-656-88-01
-- dbfw-garbagejob:clearjob = 294-22-483-0027
-- dbfw-garbagejob:endcollection = 66-111-894-1346
-- dbfw-garbagejob:addbags = 7510-44-3987-440
-- dbfw-garbagejob:reportbags = 975-348-75-34
-- dbfw-garbagejob:binselect = 8475-249-37-5874
-- dbfw-garbagejob:setbin = 46-4565-47-656-68
-- dbfw-garbagejob:bagremoval = 7894-670-56-0943
-- dbfw-garbagejob:setconfig = 498-568-7243-5583-67
-- gen=garbagejob:configset = 496-15-9149-81-785
-- dbfw-garbagejob:movetruckcount =- 54-9415-146-9581

--only on client Side 
-- dbfw-garbagejob:hasExitedMarker = 789-456-5544-8711
-- dbfw-garbagejob:hasEnteredMarker = 123-56-4984-622
