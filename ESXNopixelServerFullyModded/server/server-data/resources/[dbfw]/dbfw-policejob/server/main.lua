DBFWCore = nil

TriggerEvent('dbfw:getSharedObject', function(obj)
    DBFWCore = obj
end)

if Config.MaxInService ~= -1 then
	TriggerEvent('dbfw-service:activateService', 'police', Config.MaxInService)
end

RegisterServerEvent('police:forceEnterAsk')
AddEventHandler('police:forceEnterAsk', function(target,netid)
	local xPlayer = DBFWCore.GetPlayerFromId(source)	
		TriggerClientEvent('police:forcedEnteringVeh', target, netid)
		TriggerClientEvent('DoLongHudText', source, 'Seating Player',1)
end)

RegisterServerEvent('police:escortAsk')
AddEventHandler('police:escortAsk', function(target)
	local xPlayer = DBFWCore.GetPlayerFromId(source)

		TriggerClientEvent('dr:escort', target,source)
		TriggerClientEvent('DoLongHudText', source, 'Escorting Player',1)

end)


AddEventHandler('playerDropped', function()
	-- Save the source in case we lose it (which happens a lot)
	local _source = source
	
	-- Did the player ever join?
	if _source ~= nil then
		local xPlayer = DBFWCore.GetPlayerFromId(_source)
		local user = DBFWCore.GetPlayerFromId(_source)
		local player = user.identifier
		-- Is it worth telling all clients to refresh?
		if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'police' then
			Citizen.Wait(5000)
			TriggerClientEvent('dbfw-policejob:updateBlip', -1)
			MySQL.Async.execute("UPDATE users SET job = @job WHERE identifier = @identifier", {['job'] = 'offpolice', ['identifier'] = player})
			TriggerClientEvent('dbfw-policejob:updateBlip', -1)
		end
	end
end)

RegisterServerEvent('dbfw-policejob:spawned')
AddEventHandler('dbfw-policejob:spawned', function()
	local _source = source
	local xPlayer = DBFWCore.GetPlayerFromId(_source)

	if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'police' then
		Citizen.Wait(5000)
		TriggerClientEvent('dbfw-policejob:updateBlip', -1)
	end
end)

RegisterServerEvent('dbfw-policejob:forceBlip')
AddEventHandler('dbfw-policejob:forceBlip', function()
	TriggerClientEvent('dbfw-policejob:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('dbfw-policejob:updateBlip', -1)
	end
end)


RegisterServerEvent('policejob:payBill')
AddEventHandler('policejob:payBill', function(args)
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(args[1])
	
	--change price here for revive
	xPlayer.removeBank(args[2])
	TriggerClientEvent('DoLongHudText', xPlayer, 'You were billed for $'..args[2])
	TriggerClientEvent('DoLongHudText', src, 'They were billed for $'..args[2])
end)

RegisterServerEvent('police:cuffGranted2')
AddEventHandler('police:cuffGranted2', function(t,softcuff)
	local src = source
	
	TriggerEvent('police:setCuffState2', t, true)
	if softcuff then
		TriggerClientEvent('handCuffedWalking', t)
	else
		TriggerClientEvent('police:getArrested2', t, src)
		TriggerClientEvent('police:cuffTransition',src)
	end
end)

RegisterServerEvent('police:cuffGranted')
AddEventHandler('police:cuffGranted', function(t)
	local src = source
	
		TriggerEvent('police:setCuffState', t, true)
		TriggerClientEvent('police:getArrested', t, src)
		TriggerClientEvent('police:cuffTransition',src)
end)

RegisterServerEvent('falseCuffs')
AddEventHandler('falseCuffs', function(t)
	TriggerClientEvent('falseCuffs',t)
end)

RegisterServerEvent('police:setCuffState')
AddEventHandler('police:setCuffState', function(t,state)
	TriggerClientEvent('police:currentHandCuffedState',t,true)
end)

-----------------------------------np
RegisterServerEvent('police:crimseUser')
AddEventHandler('police:crimseUser', function(src, reason, cid)
	if not isPolice(src) then return end
	crimseUser(src, reason, cid)
end)

RegisterServerEvent('dragPlayer:disable')
AddEventHandler('dragPlayer:disable', function()
	TriggerClientEvent('drag:stopped', -1, source)
end)

RegisterServerEvent('dr:releaseEscort')
AddEventHandler('dr:releaseEscort', function(releaseID)
	TriggerClientEvent('dr:releaseEscort', tonumber(releaseID))
end)

RegisterServerEvent('server:takephone')
AddEventHandler('server:takephone', function(t)
	TriggerClientEvent('takePhone',t)
end)

RegisterServerEvent('unseatAccepted')
AddEventHandler('unseatAccepted', function(t,x,y,z)
	local src = source

	TriggerClientEvent('DoLongHudText', src, 'Unseating',1)
	TriggerClientEvent('unseatPlayerFinish', t,x,y,z)
end)

RegisterServerEvent('CrashTackle')
AddEventHandler('CrashTackle', function(t)
	local src = source
	TriggerClientEvent('playerTackled', t)
end)

RegisterServerEvent('police:remmaskGranted')
AddEventHandler('police:remmaskGranted', function(t)
	TriggerClientEvent('police:remmaskAccepted', t)
end)

RegisterServerEvent('ped:forceTrunkAsk')
AddEventHandler('ped:forceTrunkAsk', function(target,netid)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
		TriggerClientEvent('ped:forcedEnteringVeh', target, netid)
		TriggerClientEvent('DoLongHudText', source, 'Throwing someon in trunk!',1)
end)

RegisterServerEvent('ped:trunkAccepted')
AddEventHandler('ped:trunkAccepted', function(plateN)
	local src = source
	--TriggerClientEvent('ped:releaseTrunk', t, plateN)
	TriggerClientEvent('ped:releaseTrunk', -1, plateN)
end)
------------------EMS-------------------
RegisterServerEvent('reviveGranted')
AddEventHandler('reviveGranted', function(target)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
		TriggerClientEvent('policejob:undrag', target, source)
		--TriggerClientEvent('DBFWCore_ambulancejob:revive', target)
		Wait(5000)
		TriggerClientEvent("reviveFunction", target)
end)


RegisterServerEvent('evidence:bleeder')
AddEventHandler('evidence:bleeder', function(isBleeding)
	local src = source
	TriggerClientEvent('bleeder:alter',-1,src,isBleeding)
end)

RegisterServerEvent('bones:server:updateServer')
AddEventHandler('bones:server:updateServer', function(bones)
	local src = source

	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local pastebones = json.encode(bones)

	local bones = json.encode(bones)

	exports.ghmattimysql:execute("UPDATE users SET `bones` = @bones WHERE identifier = @identifier", {['bones'] = bones, ['identifier'] = xPlayer.identifier})
end)

RegisterServerEvent('Evidence:GiveWoundsFinish')
AddEventHandler('Evidence:GiveWoundsFinish', function(CurrentDamageList,id,bones)
	TriggerClientEvent('Evidence:CurrentDamageListTarget',id,CurrentDamageList,bones,source)
end)

RegisterServerEvent('police:SeizeCash')
AddEventHandler('police:SeizeCash', function(target)
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local identifier = xPlayer.identifier
	local zPlayer = DBFWCore.GetPlayerFromId(target)
	if not xPlayer.job.name == 'police' then
		print('steam:'..identifier..' User attempted sieze cash')
		return
	end

	local cash = zPlayer.getMoney()
	zPlayer.removeMoney(cash)
	TriggerClientEvent('DoLongHudText', target, 'Your cash and Marked Bills was seized',1)
	TriggerClientEvent('DoLongHudText', src, 'Seized persons cash', 1)
end)

RegisterServerEvent("police:robs")
AddEventHandler("police:rob", function(target)
	-- local src = source
	-- local xPlayer = DBFWCore.GetPlayerFromId(src)
	-- local identifier = xPlayer.identifier
	-- local zPlayer = DBFWCore.GetPlayerFromId(target)
	-- if not zPlayer then return end
	-- local cash = zPlayer.getMoney()
	-- if cash < 1 then
	-- 	cash = 0
	-- end
	-- zPlayer.removeMoney(cash)
	-- TriggerClientEvent('DoLongHudText', target, 'You were robbed for $'..cash,1)
	-- TriggerClientEvent('DoLongHudText', src, 'You stole $'..cash, 1)
end)
RegisterServerEvent("police:rob:peeps")
AddEventHandler("police:rob:peeps", function(target)
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local identifier = xPlayer.identifier
	local zPlayer = DBFWCore.GetPlayerFromId(target)
	if not zPlayer then return end
	local cash = zPlayer.getMoney()
	if cash < 1 then
		cash = 0
	end
	zPlayer.removeMoney(cash)
	TriggerClientEvent('DoLongHudText', target, 'You were robbed for $'..cash,2)
	TriggerClientEvent('DoLongHudText', src, 'You stole $'..cash, 1)
end)
-- 	local xPlayer = DBFWCore.GetPlayerFromId(target)
-- 	local identifier = xPlayer.identifier

-- 	TriggerClientEvent("server-inventory-open", source, "1", identifier) --COPY THIS

RegisterServerEvent("police:targetCheckInventory")
AddEventHandler("police:targetCheckInventory", function(target, status)
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(target)
	local identifier = xPlayer.identifier
	TriggerEvent("people-search",src, target)
	TriggerClientEvent("server-inventory-open", source, "1", identifier) --COPY THIS

end)
-- function stealMoney()
-- 	print("come steal my money here")
-- end

RegisterServerEvent('police:burstTire')
AddEventHandler('police:burstTire', function(player, wheel)
	TriggerClientEvent('police:burstTire', player,wheel)
end)

RegisterServerEvent('police:setEmoteData')
AddEventHandler('police:setEmoteData', function(emoteTable)
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local identifier = xPlayer.identifier
	local emote = json.encode(emoteTable)
	exports.ghmattimysql:execute("UPDATE users SET `emotes` = @emotes WHERE identifier = @identifier", {['emotes'] = emote, ['identifier'] = identifier})
end)

RegisterServerEvent('police:setAnimData')
AddEventHandler('police:setAnimData', function(AnimSet)
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local identifier = xPlayer.identifier
	local metaData = json.encode(AnimSet)
	exports.ghmattimysql:execute("UPDATE users SET `metaData` = @metaData WHERE identifier = @identifier", {['metaData'] = metaData, ['identifier'] = identifier})
end)

--[[RegisterServerEvent('police:getAnimData')
AddEventHandler('police:getAnimData', function()
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local identifier = xPlayer.identifier

	exports.ghmattimysql:execute("SELECT metaData FROM users WHERE identifier = @identifier", {['identifier'] = identifier}, function(result)
		if (result[1]) then
			if not result[1].metaData then
				TriggerClientEvent('checkDNA', src)
			else
				local meta = json.decode(result[1].metaData)
			if meta == nil then
				TriggerClientEvent('CheckDNA',src)
				return
			end
			TriggerClientEvent('emote:setAnimsFromDB', src, result[1].metaData)
			end
		end
	end)
end)--]]

RegisterServerEvent('Police:getMeta')
AddEventHandler('Police:getMeta', function()
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local identifier = xPlayer.identifier

	exports.ghmattimysql:execute("SELECT metaData FROM users WHERE identifier = @identifier", {['identifier'] = identifier}, function(result)
		if (result[1]) then
			meta = json.decode(result[1].metaData)
			print(meta.hunger)
		end 
	end)
end)

RegisterServerEvent('police:setServerMeta')
AddEventHandler('police:setServerMeta', function(health,armor,thirst,hunger)
    print('coming here')
    local src = source
    local xPlayer = DBFWCore.GetPlayerFromId(src)
    local mets = {}
    MySQL.Async.execute('UPDATE users SET health = @health, armor = @armor, hunger = @hunger, thirst = @thirst WHERE identifier = @identifier', {
        ['@health']     = health,
        ['@armor']      = armor,
        ['@hunger']     = hunger,
        ['@thirst']     = thirst,
		['@identifier'] = xPlayer.identifier
	})
    MySQL.Async.fetchAll('SELECT health,armor,hunger,thirst FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		local data = {}

		if result[1] ~= 0 then
			table.insert(mets, {
                health = result[1].health,
                armor = result[1].armor,
                hunger = result[1].hunger,
                thirst = result[1].thirst
            })
		end

	--	xPlayer.set('status', data)
        TriggerClientEvent('police:setClientMeta',src,mets)
	end)
    --TriggerClientEvent('police:setClientMeta',src,mets)
end)

--[[RegisterServerEvent('police:getEmoteData')
AddEventHandler('police:getEmoteData', function()
	local src = source
	local xPlayer = DBFWCore.GetPlayerFromId(src)
	local identifier = xPlayer.identifier

	exports.ghmattimysql:execute("SELECT emotes FROM users WHERE identifier = @identifier", {['identifier'] = identifier}, function(result)
		if(result[1]) then
			local emotes = json.decode(result[1].emotes)
			if result[1] ~= nil then
				TriggerClientEvent('emote:setEmotesFromDB', src,emotes)
			else
				local emoteTable = {
					{['key'] = {289},["anim"] = "Handsup"},
					{['key'] = {170},["anim"] = "HandsHead"},
					{['key'] = {166},["anim"] = "Drink"},
					{['key'] = {167},["anim"] = "Lean"},
					{['key'] = {168},["anim"] = "Smoke"},
					{['key'] = {56},["anim"] = "FacePalm"},
					{['key'] = {57},["anim"] = "Wave"},

					{['key'] = {289,21},["anim"] = "gangsign1"},
					{['key'] = {170,21},["anim"] = "gangsign3"},
					{['key'] = {166,21},["anim"] = "gangsign2"},
					{['key'] = {167,21},["anim"] = "hug"},
					{['key'] = {168,21},["anim"] = "Cop"},
					{['key'] = {56,21},["anim"] = "Medic"},
					{['key'] = {57,21},["anim"] = "Notepad"},
				}

				local emote = json.encode(emoteTable)
				exports.ghmattimysql:execute("UPDATE users SET `emotes` = @emotes WHERE identifier = @identifier", {['emotes'] = emote, ['identifier'] = identifier})
				TriggerClientEvent("emote:setEmotesFromDB", src, emoteTable)
			end
		end
	end)
end)--]]

RegisterServerEvent("Evidence:checkDna")
AddEventHandler("Evidence:checkDna", function()
		local src = source
		local xPlayer = DBFWCore.GetPlayerFromId(src)
		local identifier = xPlayer.identifier
		local needsNewDna = false

		exports.ghmattimysql:execute("SELECT metaData FROM users WHERE identifier = @identifier", {['identifier'] = identifier}, function(result)
			if(result[1]) then
				if(result[1].metaData) then
					meta = json.decode(result[1].metaData)
					if meta ~= nil then
						if meta.dna == "" then
							needsNewDna = true
						end
					else
					 needsNewDna = true
					end
	     		 else
					needsNewDna = true
		 		end
	   		else
		 		needsNewDna = true
	 	 end
	 end)
	Wait(300)
	if needsNewDna then
	local dna = ""
	local check = false
	while check == false do
		dna = math.random(1000,9999).."-"..math.random(10000,99999).."-"..math.random(0,999)
		Wait(1200)
		check = checkDBForDna(identifier,dna)
	end
	local metaData = {["dna"] = dna, ["health"] = 200, ["armour"] = 0, ["animSet"] = "none"}
	 meta = json.encode(metaData)
	 exports.ghmattimysql:execute("UPDATE users SET `metaData` = @metaData WHERE identifier = @identifier", {['metaData'] = meta, ['identifier'] = identifier})
	end
end)

function checkDBFirDn(ident,dna)
	local canUse = true
	exports.ghmattimysql:execute("SELECT metaData FROM users WHERE identifier = @identifier", {['identifier'] = ident}, function(result)
		if (result[1]) then
			meta = json.decode(result[1].metaData)
			if meta.dna ~= dna then
				canUse = true
			end
		end
	end)
	Wait(200)
	if canUse then
		return true
	else
		return false
	end
end

function GetRPName(playerId, data)
	local xPlayer = DBFWCore.GetPlayerFromId(playerId)

	exports.ghmattimysql:execute("SELECT firstname, lastname, phone_number FROM users WHERE identifier = @identifier", { ["@identifier"] = xPlayer.identifier }, function(result)

		data(result[1].firstname, result[1].lastname, result[1].phone_number)

	end)
end

function string.random(length)
	local str = "";
	for i = 1, length do
		str = str..string.char(math.random(97,122));
	end
	return str;
end

-- AddEventHandler('es:playerLoaded', function(source, user)
-- 	print
--     TriggerEvent("police:getAnimData",user)
--     TriggerEvent("police:getEmoteData",user)
--     TriggerEvent("stocks:retrieveclientstocks",user)
-- end)

----------------COMMAND-----------------
TriggerEvent('es:addCommand', 'trunkin', function(source, args, user)
	local src = source
		TriggerClientEvent('ped:forceTrunkSelf', src)
end)

TriggerEvent('es:addCommand', 'trunkejectself', function(source, args, user)
	local src = source
	TriggerClientEvent('ped:releaseTrunkCheckSelf', src)
end)

TriggerEvent('es:addCommand', 'trunkkidnap', function(source, args, user)
	local src = source
	TriggerClientEvent('ped:forceTrunk', src)
end)

TriggerEvent('es:addCommand', 'trunkeject', function(source, args, user)
	local src = source
	TriggerClientEvent('ped:releaseTrunkCheck', src)
end)

TriggerEvent('es:addCommand', 'seize', function(source, args)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local src = source
	if xPlayer.job.name == 'police' then
		TriggerClientEvent('police:seizeCash', src, args)
	end
end)

TriggerEvent('es:addCommand', 'search', function(source, args)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local src = source
	if xPlayer.job.name == 'police' then
		TriggerClientEvent('police:seizeInventory', src, args)
	end
end)

TriggerEvent('es:addCommand', 'stealing', function(source, args)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local src = source
		TriggerClientEvent('police:rob', src, args)
end)

TriggerEvent('es:addCommand', 'carry', function(source, args)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local src = source
		TriggerClientEvent('police:carryAI', src, args)
end)

TriggerEvent('es:addCommand', 'sec', function(source, args)
	local xPlayer = DBFWCore.GetPlayerFromId(source)
	local src = source
	if xPlayer.job.name == 'police' then
		TriggerClientEvent('security:camera', src, args)
	end
end)

RegisterCommand('givelicense', function(source, cb)
	local src = source
	local myPed = GetPlayerPed(src)
	local myPos = GetEntityCoords(myPed)
	local players = DBFWCore.GetPlayers()
  
	for k, v in ipairs(players) do
		if v ~= src then
	  local xTarget = GetPlayerPed(v)
	  local xPlayer = DBFWCore.GetPlayerFromId(v)
			local tPos = GetEntityCoords(xTarget)
	  local dist = #(vector3(tPos.x, tPos.y, tPos.z) - myPos)
	  local xSource = DBFWCore.GetPlayerFromId(source)
		
			if dist < 1 and xSource.job.name == 'police' then -- job goes here
		xPlayer.removeAccountMoney('bank', 500) -- change price here
		TriggerEvent('dbfw-license:checkLicense', v, 'weapon', function(cb)
		  if cb == false then 
			TriggerEvent('dbfw-license:addLicense', v, 'weapon', function()
			end)
			TriggerClientEvent('DoLongHudText', source, 'You have given a License to Carry a Weapon to ID - [' .. v .. '] for $500.' , 1) -- price also changes here
			TriggerClientEvent('DoLongHudText', v, 'You have given a License to Carry a Weapon for $500.', 1) -- price also changes here
			TriggerClientEvent('dbfw-fines:Anim', source)
		  else
			TriggerClientEvent('DoLongHudText', source, 'Failed. ID [ ' .. v .. ' ] already has a license.' , 2) -- price also changes here
		  end
		end)
	  end
		end
	end
  end)