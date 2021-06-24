local forSale = {}
local TCE = TriggerClientEvent
local RSC = DBFWCore.RegisterServerCallback

NewEvent = function(net,func,name,...)
  if net then RegisterNetEvent(name); end
  AddEventHandler(name, function(...) func(source,...); end)
end

RSC('vehsales:TryBuy',function(source,cb,veh)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do xPlayer = DBFWCore.GetPlayerFromId(source); Citizen.Wait(0); end
  if (xPlayer.identifier == veh.owner or xPlayer.getMoney() >= tonumber(veh.price)) then

    local vehData
    local keyData
    for k,v in pairs(forSale) do
      if v.vehProps.plate == veh.vehProps.plate then
        vehData = v
        keyData = k
      end
    end

    if vehData then
      if not forSale[keyData].brought then
        forSale[keyData].brought = true
        TCE('vehsales:RemoveFromSale',-1,vehData)
        if xPlayer.identifier ~= veh.owner then
          cb(true,"You have purchased the vehicle.")
        else
          cb(true,"You have reclaimed the vehicle.")
        end
      else
        cb(false,"Somebody else is purchasing this vehicle.")
      end
    else
      cb(false,"Can't find this vehicle.")
    end
  else
    cb(false,"You can't afford this vehicle.")
  end
end)

RSC('vehsales:TrySell', function(source,cb,veh)
  local xPlayer = DBFWCore.GetPlayerFromId(source)
  while not xPlayer do xPlayer = DBFWCore.GetPlayerFromId(source); Citizen.Wait(0); end
  local data = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE plate=@plate',{['@plate'] = veh.plate})
  if not data or not data[1] then 
    cb(false,"You don't own this vehicle.")
  else
    if data[1].finance and data[1].finance > 0 then 
      cb(false,"You need to finish paying this car off before you can sell it.")
    else
      if data[1].owner ~= xPlayer.identifier then
        cb(false,"You don't own this vehicle.")
      else
        cb(json.decode(data[1].vehicle))
      end
    end
  end
end)

RSC('vehsales:GetStartData', function(s,c) c(forSale); end)

function AddSale(source,veh,loc,price,props)
  local id = GetPlayerIdentifier(source)
  TCE('vehsales:AddToSale',-1,veh,loc,price,props,id)
  forSale[#forSale+1] = {veh = veh, loc = loc, price = price, vehProps = props, owner = id}
end

function DoBuy(source,veh)
  local vData = false
  for k,v in pairs(forSale) do
    if v.vehProps.plate == veh.vehProps.plate then
      vData = v
      kData = k
    end
  end
  if vData then
    local truePrice = tonumber(vData.price)
    local identifier = GetPlayerIdentifier(source)

    if vData.owner ~= identifier then
      local xPlayer = DBFWCore.GetPlayerFromIdentifier(vData.owner)
      local tick = 0
      while not xPlayer and tick < 1000 do
        tick = tick + 1
        xPlayer = DBFWCore.GetPlayerFromIdentifier(vData.owner)
        Citizen.Wait(0)
      end

      if xPlayer then 
        xPlayer.addMoney(vData.price)
        xPlayer = nil
        local xPlayer = DBFWCore.GetPlayerFromId(source)
        while not xPlayer do xPlayer = DBFWCore.GetPlayerFromId(source); Citizen.Wait(0); end
        xPlayer.removeMoney(vData.price)
        MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate=@plate',{['@plate'] = vData.vehProps.plate},function(data)
          if data then
            MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner,@plate,@vehicle)',{['@owner'] = identifier,['@plate'] = vData.vehProps.plate,['@vehicle'] = json.encode(vData.vehProps)})
          end
        end)
        forSale[kData] = nil
      else
      end
    end
  end
end

NewEvent(true,AddSale,'vehsales:AddSale')
NewEvent(true,DoBuy,'vehsales:BuyVeh')