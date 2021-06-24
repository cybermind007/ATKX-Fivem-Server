DensityMultiplier = 0.3
Citizen.CreateThread(function()
	while true do
	    Citizen.Wait(0)
	    SetVehicleDensityMultiplierThisFrame(0.4)
	    SetPedDensityMultiplierThisFrame(0.6)
	    SetRandomVehicleDensityMultiplierThisFrame(0.6)
	    SetParkedVehicleDensityMultiplierThisFrame(0.9)
	    SetScenarioPedDensityMultiplierThisFrame(DensityMultiplier, DensityMultiplier)
	end
end)