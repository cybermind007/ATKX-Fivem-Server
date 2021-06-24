RegisterNetEvent('MF_DopePlant:SyncPlant')
RegisterNetEvent('MF_DopePlant:RemovePlant')

local MFD = MF_DopePlant
local PlayerConvertTimer = {}

function MFD:Awake(...)
  while not DBFWCore do 
    Citizen.Wait(0); 
  end

  self:DSP(true);
  self.dS = true
  self:Start()
end

function MFD:DoLogin(src)  
  self:DSP(true);
end

function MFD:DSP(val) self.cS = val; end
function MFD:Start(...)
  self:Update();
end

function MFD:Update(...)
end

function MFD:SyncPlant(plant,delete)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); DBFWCore.GetPlayerFromId(source); end
  local identifier = xPlayer.getIdentifier()
  plant["Owner"] = identifier
  if delete then 
    if xPlayer.job.label ~= self.PoliceJobLabel then
      self:RewardPlayer(source, plant)
    end
  end
  self:PlantCheck(identifier,plant,delete) 
  TriggerClientEvent('MF_DopePlant:SyncPlant',-1,plant,delete)
end

function MFD:RewardPlayer(source,plant)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); DBFWCore.GetPlayerFromId(source); end
  if not source or not plant then return; end
  if plant.Gender == "Male" then
    math.random();math.random();math.random();
    local r = math.random(1000,5000)
    if r < 3000 then
      if plant.Quality > 95 then
        TriggerClientEvent('player:receiveItem', source, 'highgrademaleseed', math.random(3, 6))
        TriggerClientEvent('player:receiveItem', source, 'highgradefemaleseed', math.random(3, 6))
      elseif plant.Quality > 80 then
        TriggerClientEvent('player:receiveItem', source, 'highgrademaleseed', math.random(2, 5))
        TriggerClientEvent('player:receiveItem', source, 'highgradefemaleseed', math.random(1, 3))
      else
      end
    else
      if plant.Quality > 95 then
        TriggerClientEvent('player:receiveItem', source, 'highgrademaleseed', math.random(3, 5))
        TriggerClientEvent('player:receiveItem', source, 'highgradefemaleseed', math.random(2, 4))
      elseif plant.Quality > 80 then
        TriggerClientEvent('player:receiveItem', source, 'highgrademaleseed', math.random(2, 5))
        TriggerClientEvent('player:receiveItem', source, 'highgradefemaleseed', math.random(1, 3))
      else
      end
    end
  else
    if plant and plant.Quality and plant.Quality > 80 then
      TriggerClientEvent('player:receiveItem', source, 'weedq', math.random(10, 15))
    elseif plant.Quality then
      TriggerClientEvent('player:receiveItem', source, 'weedq', math.random(5, 10))
    end
  end
end

function MFD:PlantCheck(identifier, plant, delete)
  if not plant or not identifier then return; end
  local data = MySQL.Sync.fetchAll('SELECT * FROM dopeplants WHERE plantid=@plantid',{['@plantid'] = plant.PlantID})
  if not delete then
    if not data or not data[1] then  
      MySQL.Async.execute('INSERT INTO dopeplants (owner, plantid, plant) VALUES (@owner, @id, @plant)',{['@owner'] = identifier,['@id'] = plant.PlantID, ['@plant'] = json.encode(plant)})
    else
      MySQL.Sync.execute('UPDATE dopeplants SET plant=@plant WHERE plantid=@plantid',{['@plant'] = json.encode(plant),['@plantid'] = plant.PlantID})
    end
  else
    if data and data[1] then
      MySQL.Async.execute('DELETE FROM dopeplants WHERE plantid=@plantid', {['@plantid'] = plant.PlantID})
    end
  end
end

function MFD:GetLoginData(source)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); DBFWCore.GetPlayerFromId(source); end
  local data = MySQL.Sync.fetchAll('SELECT * FROM dopeplants WHERE owner=@owner',{['@owner'] = xPlayer.identifier})
  if not data or not data[1] then return false; end
  local aTab = {}
  for k = 1,#data,1 do
    local v = data[k]
    if v and v.plant then
      local data = json.decode(v.plant)
      table.insert(aTab,data)
    end
  end
  return aTab
end

function MFD:ItemTemplate()
  return {
    ["Type"] = "Water",
    ["Quality"] = 0.0,
  }
end

function MFD:PlantTemplate()
  return {
    ["Gender"] = "Female",
    ["Quality"] = 0.0,
    ["Growth"] = 0.0,
    ["Water"] = 20.0,
    ["Food"] = 20.0,
    ["Stage"] = 1,
    ["PlantID"] = math.random(math.random(999999,9999999),math.random(99999999,999999999))
  }
end

DBFWCore.RegisterServerCallback('MF_DopePlant:GetLoginData', function(source,cb) cb(MFD:GetLoginData(source)); end)
DBFWCore.RegisterServerCallback('MF_DopePlant:GetStartData', function(source,cb) while not MFD.dS do Citizen.Wait(0); end; cb(MFD.cS); end)
AddEventHandler('MF_DopePlant:SyncPlant', function(plant,delete) MFD:SyncPlant(plant,delete); end)
AddEventHandler('playerConnected', function(...) MFD:DoLogin(source); end)
Citizen.CreateThread(function(...) MFD:Awake(...); end)

RegisterServerEvent("dbfw-weedplants:purifiedwater")
AddEventHandler("dbfw-weedplants:purifiedwater", function(id)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); DBFWCore.GetPlayerFromId(source); end
    TriggerClientEvent('inventory:removeItem', source, 'purifiedwater', 1)

    local template = MFD:ItemTemplate()
    template.Type = "Water"
    template.Quality = 0.2

    TriggerClientEvent('MF_DopePlant:UseItem',source,template)
end)

RegisterServerEvent("dbfw-weedplants:highgradefert")
AddEventHandler("dbfw-weedplants:highgradefert", function(id)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); DBFWCore.GetPlayerFromId(source); end
    TriggerClientEvent('inventory:removeItem', source, 'highgradefert', 1)

    local template = MFD:ItemTemplate()
    template.Type = "Food"
    template.Quality = 0.2

    TriggerClientEvent('MF_DopePlant:UseItem',source,template)
    TriggerClientEvent('tm1_stores:addFertilizer', source, 50)
end)

RegisterServerEvent("dbfw-weedplants:highgrademaleseed")
AddEventHandler("dbfw-weedplants:highgrademaleseed", function(id)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); DBFWCore.GetPlayerFromId(source); end
    TriggerClientEvent('inventory:removeItem', source, 'highgrademaleseed', 1)
    TriggerClientEvent('inventory:removeItem', source, 'plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Male"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
end)

RegisterServerEvent("dbfw-weedplants:highgradefemaleseed")
AddEventHandler("dbfw-weedplants:highgradefemaleseed", function(id)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do Citizen.Wait(0); DBFWCore.GetPlayerFromId(source); end
    TriggerClientEvent('inventory:removeItem', source, 'highgradefemaleseed', 1)
    TriggerClientEvent('inventory:removeItem', source, 'plantpot', 1)

    local template = MFD:PlantTemplate()
    template.Gender = "Female"
    template.Quality = 0.2
    template.Quality = math.random(200,500)/10
    template.Food =  math.random(200,400)/10
    template.Water = math.random(200,400)/10

    TriggerClientEvent('MF_DopePlant:UseSeed',source,template)
end)

function CheckedStartedConvert(source)
	for k,v in pairs(PlayerConvertTimer) do
		if v.startedConvert == source then
			return true
		end
	end
	return false
end

function GetTimeForDrugs(source)
	for k,v in pairs(PlayerDrugsTimer) do
		if v.startedDrugs == source then
			return math.ceil(v.timeDrugs/1000)
		end
	end
end

function CheckedStartedDrugs(source)
	for k,v in pairs(PlayerDrugsTimer) do
		if v.startedDrugs == source then
			return true
		end
	end
	return false
end

function RemoveStartedConvert(source)
	for k,v in pairs(PlayerConvertTimer) do
		if v.startedConvert == source then
			table.remove(PlayerConvertTimer,k)
		end
	end
end