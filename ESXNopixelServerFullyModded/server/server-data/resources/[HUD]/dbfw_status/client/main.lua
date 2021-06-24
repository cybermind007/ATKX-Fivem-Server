DBFWCore = nil
local Status, isPaused = {}, false

Citizen.CreateThread(function()
	while DBFWCore == nil do
		TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj end)
		Citizen.Wait(0)
	end
end)

function GetStatusData(minimal)
	local status = {}

	for i=1, #Status, 1 do
		if minimal then
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		else
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				color   = Status[i].color,
				visible = Status[i].visible(Status[i]),
				max     = Status[i].max,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		end
	end

	return status
end

AddEventHandler('dbfw_status:registerStatus', function(name, default, color, visible, tickCallback)
	local status = CreateStatus(name, default, color, visible, tickCallback)
	table.insert(Status, status)
end)

AddEventHandler('dbfw_status:unregisterStatus', function(name)
	for k,v in ipairs(Status) do
		if v.name == name then
			table.remove(Status, k)
			break
		end
	end
end)

RegisterNetEvent('dbfw_status:load')
AddEventHandler('dbfw_status:load', function(status)
  for i=1, #Status, 1 do
  	for j=1, #status, 1 do
  		if Status[i].name == status[j].name then
  			Status[i].set(status[j].val)
  		end
  	end
  end

  Citizen.CreateThread(function()
  	while true do
  		for i=1, #Status, 1 do
  			Status[i].onTick()
  		end

  		SendNUIMessage({
  			update = true,
  			status = GetStatusData()
  		})

  		TriggerEvent('DBFWCore_HealthBAR-UI:updateStatus', GetStatusData(true))
  		Citizen.Wait(Config.TickTime)
  	end
  end)
end)

RegisterNetEvent('dbfw_status:set')
AddEventHandler('dbfw_status:set', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].set(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = GetStatusData()
	})

	TriggerServerEvent('dbfw_status:update', GetStatusData(true))
end)

RegisterNetEvent('dbfw_status:add')
AddEventHandler('dbfw_status:add', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].add(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = GetStatusData()
	})

	TriggerServerEvent('dbfw_status:update', GetStatusData(true))
end)

RegisterNetEvent('dbfw_status:remove')
AddEventHandler('dbfw_status:remove', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].remove(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = GetStatusData()
	})

	TriggerServerEvent('dbfw_status:update', GetStatusData(true))
end)

AddEventHandler('dbfw_status:getStatus', function(name, cb)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			cb(Status[i])
			return
		end
	end
end)

AddEventHandler('dbfw_status:setDisplay', function(val)
	SendNUIMessage({
		setDisplay = true,
		display    = val
	})
end)

-- Pause menu disable hud display
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(300)

		if IsPauseMenuActive() and not isPaused then
			isPaused = true
			TriggerEvent('dbfw_status:setDisplay', 0.0)
		elseif not IsPauseMenuActive() and isPaused then
			isPaused = false 
			TriggerEvent('dbfw_status:setDisplay', 0.5)
		end
	end
end)

-- Loaded event
Citizen.CreateThread(function()
	TriggerEvent('dbfw_status:loaded')
end)

-- Update server
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.UpdateInterval)

		TriggerServerEvent('dbfw_status:update', GetStatusData(true))
	end
end)
