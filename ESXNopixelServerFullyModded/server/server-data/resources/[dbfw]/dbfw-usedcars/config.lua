vehsales = {}

vehsales.Version = '1.0.10'

TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj; end)
Citizen.CreateThread(function(...)
  while not DBFWCore do
    TriggerEvent('dbfw:getSharedObject', function(obj) DBFWCore = obj; end)
    Citizen.Wait(0)
  end
end)