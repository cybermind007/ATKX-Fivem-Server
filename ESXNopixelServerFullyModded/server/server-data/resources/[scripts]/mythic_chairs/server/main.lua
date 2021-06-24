local SeatsTaken = {}
DBWF = nil

TriggerEvent('dbfw:getSharedObject', function(obj) DBWF = obj end)

-- SEATS
RegisterServerEvent('mythic_chairs:server:TakeChair')
AddEventHandler('mythic_chairs:server:TakeChair', function(object)
	table.insert(SeatsTaken, object)
end)

RegisterServerEvent('mythic_chairs:server:LeaveChair')
AddEventHandler('mythic_chairs:server:LeaveChair', function(object)
	local _SeatsTaken = {}
	for i=1, #SeatsTaken, 1 do
		if object ~= SeatsTaken[i] then
			table.insert(_SeatsTaken, SeatsTaken[i])
		end
	end
	SeatsTaken = _SeatsTaken
end)

DBWF.RegisterServerCallback('mythic_chairs:server:GetChair', function(source, cb, id)
	local found = false

	for i=1, #SeatsTaken, 1 do
		if SeatsTaken[i] == id then
			found = true
		end
	end
	cb(found)
end)

RegisterCommand("sit", function(source)
    TriggerClientEvent('mythic_chairs:client:StartSit', source)
end, false)