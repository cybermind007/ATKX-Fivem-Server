--- Prone Stuff ----

local crouched = false
local proned = false
crouchKey = 19
proneKey = 36

Citizen.CreateThread( function()
	while true do 
		Citizen.Wait( 1 )
		local ped = GetPlayerPed( -1 )
		local isDead = exports["dbfw-ambulancejob"]:GetDeath()
		if ( DoesEntityExist( ped ) and not isDead ) then 
			ProneMovement()
			DisableControlAction( 0, proneKey, true ) 
			DisableControlAction( 0, crouchKey, true ) 
			if ( not IsPauseMenuActive() ) then 
				if ( IsDisabledControlJustPressed( 0, crouchKey ) and not proned ) and not IsPedInAnyVehicle(ped, false) then 
					RequestAnimSet( "move_ped_crouched" )
					RequestAnimSet("MOVE_M@TOUGH_GUY@")
					
					while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
						Citizen.Wait( 100 )
					end 
					while ( not HasAnimSetLoaded( "MOVE_M@TOUGH_GUY@" ) ) do 
						Citizen.Wait( 100 )
					end 		
					if ( crouched and not proned ) then 
						ResetPedMovementClipset( ped )
						ResetPedStrafeClipset(ped)
						SetPedMovementClipset( ped,"MOVE_M@TOUGH_GUY@", 0.5)
						crouched = false 
					elseif ( not crouched and not proned ) then
						SetPedMovementClipset( ped, "move_ped_crouched", 0.55 )
						SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
						crouched = true 
					end 
				elseif ( IsDisabledControlJustPressed(0, proneKey) and not crouched and not IsPedInAnyVehicle(ped, true) and not IsPedFalling(ped) and not IsPedDiving(ped) and not IsPedInCover(ped, false) and not IsPedInParachuteFreeFall(ped) and (GetPedParachuteState(ped) == 0 or GetPedParachuteState(ped) == -1) ) then
					if proned then
						StopAnimTask(ped, "move_crawl", "onfront_fwd", 2.0)
						proned = false
					elseif not proned then
						RequestAnimSet( "move_crawl" )
						while ( not HasAnimSetLoaded( "move_crawl" ) ) do 
							Citizen.Wait( 100 )
						end 
						StopAnimTask(ped, "move_crawl", "onfront_fwd", 2.0)
						proned = true
						if IsPedSprinting(ped) or IsPedRunning(ped) or GetEntitySpeed(ped) > 5 then
							TaskPlayAnim(ped, "move_jump", "dive_start_run", 8.0, 1.0, -1, 0, 0.0, 0, 0, 0)
							Citizen.Wait(1000)
						end
						SetProned()
					end
				end
			end
		else
			proned = false
			crouched = false
		end
	end
end)

function SetProned()
	ped = PlayerPedId()
	ClearPedTasks(ped)
	local pronepos = GetEntityCoords(ped)
	TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", pronepos["x"],pronepos["y"],pronepos["z"]+0.1, 0.0, 0.0, GetEntityHeading(ped), 2.0, 0.4, 1.0, 7, 2.0, 1, 1)
end


function ProneMovement()
	if proned then
		ped = PlayerPedId()
		if IsControlPressed(0, 32) or IsControlPressed(0, 33) then
			DisablePlayerFiring(ped, true)
		 elseif IsControlJustReleased(0, 32) or IsControlJustReleased(0, 33) then
		 	DisablePlayerFiring(ped, false)
		 end
		if IsControlJustPressed(0, 32) and not movefwd then
			movefwd = true
			SetPedMoveAnimsBlendOut(ped)
			local pronepos = GetEntityCoords(ped)
			TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", pronepos["x"],pronepos["y"],pronepos["z"]+0.1, 0.0, 0.0, GetEntityHeading(ped), 100.0, 0.4, 1.0, 7, 2.0, 1, 1)
			Citizen.Wait(500)
		elseif IsControlJustReleased(0, 32) and movefwd then
			local pronepos = GetEntityCoords(ped)
			TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_fwd", pronepos["x"],pronepos["y"],pronepos["z"]+0.1, 0.0, 0.0, GetEntityHeading(ped), 100.0, 0.4, 1.0, 6, 2.0, 1, 1)
			Citizen.Wait(500)
			movefwd = false
		end		
		if IsControlJustPressed(0, 33) and not movebwd then
			movebwd = true
			--SetPedMoveAnimsBlendOut(ped)
			local pronepos = GetEntityCoords(ped)
		    TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_bwd", pronepos["x"],pronepos["y"],pronepos["z"]+0.1, 0.0, 0.0, GetEntityHeading(ped), 100.0, 0.4, 1.0, 7, 2.0, 1, 1)
		elseif IsControlJustReleased(0, 33) and movebwd then 
			local pronepos = GetEntityCoords(ped)
		    TaskPlayAnimAdvanced(ped, "move_crawl", "onfront_bwd", pronepos["x"],pronepos["y"],pronepos["z"]+0.1, 0.0, 0.0, GetEntityHeading(ped), 100.0, 0.4, 1.0, 6, 2.0, 1, 1)
		    movebwd = false
		end
		if IsControlPressed(0, 34) then
			SetEntityHeading(ped, GetEntityHeading(ped)+2.0 )
		elseif IsControlPressed(0, 35) then
			SetEntityHeading(ped, GetEntityHeading(ped)-2.0 )
		end
	end
end