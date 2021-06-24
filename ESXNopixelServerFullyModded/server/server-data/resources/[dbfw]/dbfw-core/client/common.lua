AddEventHandler('dbfw:getSharedObject', function(cb)
	cb(DBFWCore)
end)

function getSharedObject()
	return DBFWCore
end
