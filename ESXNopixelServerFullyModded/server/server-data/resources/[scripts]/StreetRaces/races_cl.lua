-- DEFINITIONS AND CONSTANTS
local RACE_STATE_NONE = 0
local racing = false
local dst = 30.0
local RACE_STATE_JOINED = 1
local RACE_STATE_RACING = 2
local RACE_STATE_RECORDING = 3
local RACE_CHECKPOINT_TYPE = 45
local RACE_CHECKPOINT_FINISH_TYPE = 9

-- Races and race status
local races = {}
local SetBlips = {}
local currentMap = {}
local raceStatus = {
    state = RACE_STATE_NONE,
    index = 0,
    checkpoint = 0
}

-- Recorded checkpoints
local recordedCheckpoints = {}
local checkpointMarkers = {}

function cpCount()
    if #recordedCheckpoints > 0 then
        return true
    else
        return false
    end
end

-- Main command for races
RegisterCommand("race", function(source, args)
    if args[1] == "clear" or args[1] == "leave" then
        -- If player is part of a race, clean up map and send leave event to server
        if raceStatus.state == RACE_STATE_JOINED or raceStatus.state == RACE_STATE_RACING then
            cleanupRace()
            TriggerServerEvent('races:leaveRace_sv', raceStatus.index)
        end

        -- Reset state
        raceStatus.index = 0
        raceStatus.checkpoint = 0
        raceStatus.state = RACE_STATE_NONE
        racing = false
    elseif args[1] == "record" then
        -- Clear waypoint, cleanup recording and set flag to start recording
        SetWaypointOff()
        cleanupRecording()
        raceStatus.state = RACE_STATE_RECORDING
    elseif args[1] == "start" then
        -- Parse arguments and create race
        local amount = tonumber(args[2])
        if amount then
            -- Get optional start delay argument and starting coordinates
            local startDelay = tonumber(args[3])
            startDelay = startDelay and startDelay*1000 or config_cl.joinDuration
            local startCoords = GetEntityCoords(GetPlayerPed(-1))

            -- Create a race using checkpoints or waypoint if none set
            if #recordedCheckpoints > 0 then
                -- Create race using custom checkpoints
                TriggerServerEvent('races:createRace_sv', amount, startDelay, startCoords, recordedCheckpoints, currentMap)
            elseif IsWaypointActive() then
                -- Create race using waypoint as the only checkpoint
                local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
                local retval, nodeCoords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 0)
                table.insert(recordedCheckpoints, {blip = nil, coords = nodeCoords})
                TriggerServerEvent('races:createRace_sv', amount, startDelay, startCoords, recordedCheckpoints)
            end

            -- Set state to none to cleanup recording blips while waiting to join
            raceStatus.state = RACE_STATE_NONE
            racing = false
        end
    elseif args[1] == "cancel" then
        -- Send cancel event to server
        TriggerServerEvent('races:cancelRace_sv')
    else
        return
    end
end)

-- Client event for when a race is created
RegisterNetEvent("races:createRace_cl")
AddEventHandler("races:createRace_cl", function(index, amount, startDelay, startCoords, checkpoints, currentMap)
    -- Create race struct and add to array
    local race = {
        amount = amount,
        started = false,
        startTime = GetGameTimer() + startDelay,
        startCoords = startCoords,
        checkpoints = checkpoints,
        currentMap = currentMap,
    }
    races[index] = race
end)


-- Client event for when a race is joined
RegisterNetEvent("races:joinedRace_cl")
AddEventHandler("races:joinedRace_cl", function(index)
    -- Set index and state to joined
    raceStatus.index = index
    raceStatus.state = RACE_STATE_JOINED

    -- Add map blips
    local race = races[index]
    local checkpoints = race.checkpoints
    local racers = race.currentMap
    for index, checkpoint in pairs(checkpoints) do
        loadCheckpointModels()
        for index, map in pairs(racers) do
            addCheckpointMarker(vector3(map["flare1x"], map["flare1y"], map["flare1z"]), vector3(map["flare2x"], map["flare2y"], map["flare2z"]))
        end

        local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
        local retval, coords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1)
        local key = #SetBlips+1
        checkpoint.blip = AddBlipForCoord(checkpoint.coords.x, checkpoint.coords.y, checkpoint.coords.z)
        SetBlipAsFriendly(checkpoint.blip, true)
        SetBlipSprite(checkpoint.blip, 1)
        ShowNumberOnBlip(checkpoint.blip, index)
        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString(tostring("Checkpoint " ..index))
        EndTextCommandSetBlipName(checkpoint.blip)
    end

    -- Clear waypoint and add route for first checkpoint blip
    SetWaypointOff()
    SetBlipRoute(checkpoints[1].blip, true)
    SetBlipRouteColour(checkpoints[1].blip, config_cl.checkpointBlipColor)
end)

-- Client event for when a race is removed
RegisterNetEvent("races:removeRace_cl")
AddEventHandler("races:removeRace_cl", function(index)
    -- Check if index matches active race
    if index == raceStatus.index then
        -- Cleanup map blips and checkpoints
        cleanupRace()

        -- Reset racing state
        raceStatus.index = 0
        raceStatus.checkpoint = 0
        raceStatus.state = RACE_STATE_NONE
        racing = false
    elseif index < raceStatus.index then
        -- Decrement raceStatus.index to match new index after removing race
        raceStatus.index = raceStatus.index - 1
    end
    
    -- Remove race from table
    table.remove(races, index)
end)

-- Main thread
Citizen.CreateThread(function()
    -- Loop forever and update every frame
    while true do
        Citizen.Wait(0)

        -- Get player and check if they're in a vehicle
        local player = GetPlayerPed(-1)
        if IsPedInAnyVehicle(player, false) then
            -- Get player position and vehicle
            local position = GetEntityCoords(player)
            local vehicle = GetVehiclePedIsIn(player, false)

            -- Player is racing
            if raceStatus.state == RACE_STATE_RACING then
                racing = true
                -- Initialize first checkpoint if not set
                local race = races[raceStatus.index]
                if raceStatus.checkpoint == 0 then
                    -- Increment to first checkpoint
                    raceStatus.checkpoint = 1
                    local checkpoint = race.checkpoints[raceStatus.checkpoint]

                    -- Create checkpoint when enabled

                    -- Set blip route for navigation
                    SetBlipRoute(checkpoint.blip, true)
                    SetBlipRouteColour(checkpoint.blip, config_cl.checkpointBlipColor)
                else
                    -- Check player distance from current checkpoint
                    local checkpoint = race.checkpoints[raceStatus.checkpoint]
                    if GetDistanceBetweenCoords(position.x, position.y, position.z, checkpoint.coords.x, checkpoint.coords.y, 0, false) < config_cl.checkpointProximity then
                        -- Passed the checkpoint, delete map blip and checkpoint
                        RemoveBlip(checkpoint.blip)
                        if config_cl.checkpointRadius > 0 then
                            DeleteCheckpoint(checkpoint.checkpoint)
                        end
                        
                        -- Check if at finish line
                        if raceStatus.checkpoint == #(race.checkpoints) then
                            -- Play finish line sound
                            PlaySoundFrontend(-1, "ScreenFlash", "WastedSounds")

                            -- Send finish event to server
                            local currentTime = (GetGameTimer() - race.startTime)
                            TriggerServerEvent('races:finishedRace_sv', raceStatus.index, currentTime)
                            RemoveCheckpoints()
                            ClearBlips()
                            currentMap = {}
                            -- Reset state
                            raceStatus.index = 0
                            raceStatus.state = RACE_STATE_NONE
                            racing = false
                        else
                            -- Play checkpoint sound
                            PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")

                            -- Increment checkpoint counter and get next checkpoint
                            raceStatus.checkpoint = raceStatus.checkpoint + 1
                            local nextCheckpoint = race.checkpoints[raceStatus.checkpoint]

                            -- Create checkpoint when enabled

                            -- Set blip route for navigation
                            SetBlipRoute(nextCheckpoint.blip, true)
                            SetBlipRouteColour(nextCheckpoint.blip, config_cl.checkpointBlipColor)
                        end
                    end
                end

                -- Draw HUD when it's enabled
                if config_cl.hudEnabled then
                    -- Draw time and checkpoint HUD above minimap
                    local timeSeconds = (GetGameTimer() - race.startTime)/1000.0
                    local timeMinutes = math.floor(timeSeconds/60.0)
                    timeSeconds = timeSeconds - 60.0*timeMinutes
                    Draw2DText(config_cl.hudPosition.x, config_cl.hudPosition.y, ("~w~%02d:%06.3f"):format(timeMinutes, timeSeconds), 0.7)
                    local checkpoint = race.checkpoints[raceStatus.checkpoint]
                    local checkpointDist = math.floor(GetDistanceBetweenCoords(position.x, position.y, position.z, checkpoint.coords.x, checkpoint.coords.y, 0, false))
                    Draw2DText(config_cl.hudPosition.x, config_cl.hudPosition.y + 0.04, ("~w~CHECKPOINT %d/%d (%dm)"):format(raceStatus.checkpoint, #race.checkpoints, checkpointDist), 0.5)
                end
            -- Player has joined a race
            elseif raceStatus.state == RACE_STATE_JOINED then
                -- Check countdown to race start
                local race = races[raceStatus.index]
                local currentTime = GetGameTimer()
                local count = race.startTime - currentTime
                if count <= 0 then
                    -- Race started, set racing state and unfreeze vehicle position
                    raceStatus.state = RACE_STATE_RACING
                    racing = true
                    raceStatus.checkpoint = 0
                    FreezeEntityPosition(vehicle, false)
                elseif count <= config_cl.freezeDuration then
                    -- Display countdown text and freeze vehicle position
                    TriggerEvent("DoLongHudText","Race Starts in 5",14)
                    PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                    Citizen.Wait(1000)
                    TriggerEvent("DoLongHudText","Race Starts in 4",14)
                    PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                    Citizen.Wait(1000)
                    TriggerEvent("DoLongHudText","Race Starts in 3",14)
                    PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                    Citizen.Wait(1000)
                    TriggerEvent("DoLongHudText","Race Starts in 2",14)
                    PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                    Citizen.Wait(1000)
                    TriggerEvent("DoLongHudText","Race Starts in 1",14)
                    PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                    Citizen.Wait(1000)
                    PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
                    TriggerEvent("DoLongHudText","GO!",14)
                    FreezeEntityPosition(vehicle, true)
                else
                    -- Draw 3D start time and join text
                    local temp, zCoord = GetGroundZFor_3dCoord(race.startCoords.x, race.startCoords.y, 9999.9, 1)
                    Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.0, ("Race for $%d starting in %ds"):format(race.amount, math.ceil(count/1000.0)))
                    Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+0.80, "Joined")
                    FreezeEntityPosition(vehicle, true)

                end
            -- Player is not in a race
            else
                -- Loop through all races
                for index, race in pairs(races) do
                    -- Get current time and player proximity to start
                    local currentTime = GetGameTimer()
                    local proximity = GetDistanceBetweenCoords(position.x, position.y, position.z, race.startCoords.x, race.startCoords.y, race.startCoords.z, true)

                    -- When in proximity and race hasn't started draw 3D text and prompt to join
                    if proximity < config_cl.joinProximity and currentTime < race.startTime then
                        -- Draw 3D text
                        local count = math.ceil((race.startTime - currentTime)/1000.0)
                        local temp, zCoord = GetGroundZFor_3dCoord(race.startCoords.x, race.startCoords.y, 9999.9, 0)
                        Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.0, ("Race for $%d starting in %ds"):format(race.amount, count))
                        Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+0.80, "[E] - Join")

                        -- Check if player enters the race and send join event to server
                        if IsControlJustReleased(1, config_cl.joinKeybind) then
                            TriggerServerEvent('races:joinRace_sv', index)
                            break
                        end
                    end
                end
            end  
        end
    end
end)

function isRecordingRace()
    if raceStatus.state == RACE_STATE_RECORDING then
        return true
    else
        return false
    end
end
local isModelsLoaded = false
function loadCheckpointModels()
  local models = {}
  models[1] = "prop_offroad_tyres02"
  models[2] = "prop_beachflag_01"
  for i = 1, #models do
    local checkpointModel = GetHashKey(models[i])
    RequestModel(checkpointModel)
    while not HasModelLoaded(checkpointModel) do
      Citizen.Wait(1)
    end
  end
  isModelsLoaded = true
end

function RemoveCheckpoints()
    for i = 1, #checkpointMarkers do
      SetEntityAsNoLongerNeeded(checkpointMarkers[i].left)
      DeleteObject(checkpointMarkers[i].left)
      SetEntityAsNoLongerNeeded(checkpointMarkers[i].right)
      DeleteObject(checkpointMarkers[i].right)
      checkpointMarkers[i] = nil
    end
end

function ClearBlips()
    for i = 1, #SetBlips do
      RemoveBlip(SetBlips[i])
    end
    SetBlips = {}
end

function addCheckpointMarker(leftMarker, rightMarker)
    local model = #checkpointMarkers == 0 and 'prop_beachflag_01' or 'prop_offroad_tyres02'
  
    local checkpointLeft = CreateObject(GetHashKey(model), leftMarker, false, false, false)
    local checkpointRight = CreateObject(GetHashKey(model), rightMarker, false, false, false)
    checkpointMarkers[#checkpointMarkers + 1] = {
      left = checkpointLeft,
      right = checkpointRight
    }
    PlaceObjectOnGroundProperly(checkpointLeft)
    SetEntityAsMissionEntity(checkpointLeft)
    PlaceObjectOnGroundProperly(checkpointRight)
    SetEntityAsMissionEntity(checkpointRight)
  end
  function FUCKK(num)
    local new = math.ceil(num*100)
    new = new / 100
    return new
  end
function AddCheckPoint()
    loadCheckpointModels()
    local plycoords = GetEntityCoords(GetPlayerPed(-1))
    local ballsdick = dst/2
    local fx,fy,fz = table.unpack(GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1),  ballsdick, 0.0, -0.25))
  
    local fx2,fy2,fz2 = table.unpack(GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0 - ballsdick, 0.0, -0.25))
    
    addCheckpointMarker(vector3(fx,fy,fz), vector3(fx2,fy2,fz2))

    local checkcounter = #currentMap + 1
    currentMap[checkcounter] = { 
    ["flare1x"] = FUCKK(fx), ["flare1y"] = FUCKK(fy), ["flare1z"] = FUCKK(fz),
    ["flare2x"] = FUCKK(fx2), ["flare2y"] = FUCKK(fy2), ["flare2z"] = FUCKK(fz2),
    ["x"] = FUCKK(plycoords.x),  ["y"] = FUCKK(plycoords.y), ["z"] = FUCKK(plycoords.z-1.1), ["start"] = start, ["dist"] = ballsdick, 
  }

    local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
    local retval, coords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1)
    local key = #SetBlips+1
    SetBlips[key] = AddBlipForCoord(plycoords.x,plycoords.y,plycoords.z)
    SetBlipAsFriendly(SetBlips[key], true)
    SetBlipSprite(SetBlips[key], 1)
    ShowNumberOnBlip(SetBlips[key], key)
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString(tostring("Checkpoint " ..key))
    EndTextCommandSetBlipName(SetBlips[key])
  end

  function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

-- Checkpoint recording thread
Citizen.CreateThread(function()
    -- Loop forever and record checkpoints every 100ms
    while true do
        Citizen.Wait(0)
        
        -- When recording flag is set, save checkpoints
        if raceStatus.state == RACE_STATE_RECORDING then

            local plycoords = GetEntityCoords(GetPlayerPed(-1))
          
            DrawMarker(27,plycoords.x,plycoords.y,plycoords.z,0,0,0,0,0,0,dst,dst,0.3001,255,255,255,255,0,0,0,0)
                
            if #recordedCheckpoints == 0 then
                DrawText3Ds(plycoords.x,plycoords.y,plycoords.z,"[E] to add start point, up/down for size, phone to save or cancel.")
            else
                DrawText3Ds(plycoords.x,plycoords.y,plycoords.z,"[E] to add check point, up/down for size, phone to save or cancel.")
            end
          
            if IsControlPressed(0,27) then
                dst = dst + 1
                if dst > 60.0 then
                dst = 60.0
                end
            end
          
            if IsControlPressed(0,173) then
                dst = dst - 1
                if dst < 4 then
                dst = 3.0
                end
            end
          
            if IsControlJustReleased(0,38) then
                AddCheckPoint()
                local plycoords = GetEntityCoords(GetPlayerPed(-1))
                local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
                local retval, coords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1)
                if (coords ~= nil) then
                    table.insert(recordedCheckpoints, {blip = blip, coords = plycoords})
                end
                Wait(1000)
            end





             --[[-- Create new checkpoint when waypoint is set
             if IsWaypointActive() then
                -- Get closest vehicle node to waypoint coordinates and remove waypoint
                local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
                local retval, coords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1)
                SetWaypointOff()

                -- Check if coordinates match any existing checkpoints
                for index, checkpoint in pairs(recordedCheckpoints) do
                    if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, checkpoint.coords.x, checkpoint.coords.y, checkpoint.coords.z, false) < 1.0 then
                        -- Matches existing checkpoint, remove blip and checkpoint from table
                        RemoveBlip(checkpoint.blip)
                        table.remove(recordedCheckpoints, index)
                        coords = nil

                        -- Update existing checkpoint blips
                        for i = index, #recordedCheckpoints do
                            ShowNumberOnBlip(recordedCheckpoints[i].blip, i)
                        end
                        break
                    end
                end

                -- Add new checkpoint
                if (coords ~= nil) then
                    -- Add numbered checkpoint blip
                    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                    SetBlipColour(blip, 4)
                    SetBlipAsShortRange(blip, true)
                    ShowNumberOnBlip(blip, #recordedCheckpoints+1)

                    -- Add checkpoint to array
                    table.insert(recordedCheckpoints, {blip = blip, coords = coords})
                end
            end]]--
        else
            -- Not recording, do cleanup
            --cleanupRecording()
        end
    end
end)

-- Helper function to clean up race blips, checkpoints and status
function cleanupRace()
    -- Cleanup active race
    RemoveCheckpoints()
    ClearBlips()
    currentMap = {}
    -- Reset state
    if raceStatus.index ~= 0 then
        -- Cleanup map blips and checkpoints
        local race = races[raceStatus.index]
        local checkpoints = race.checkpoints
        for _, checkpoint in pairs(checkpoints) do
            if checkpoint.blip then
                RemoveBlip(checkpoint.blip)
            end
            if checkpoint.checkpoint then
                DeleteCheckpoint(checkpoint.checkpoint)
            end
        end

        -- Set new waypoint to finish if racing
        if raceStatus.state == RACE_STATE_RACING then
            racing = true
            local lastCheckpoint = checkpoints[#checkpoints]
            SetNewWaypoint(lastCheckpoint.coords.x, lastCheckpoint.coords.y)
        end

        -- Unfreeze vehicle
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        FreezeEntityPosition(vehicle, false)
        raceStatus.index = 0
        raceStatus.state = RACE_STATE_NONE
        recordedCheckpoints = {}
    end
end
RegisterNetEvent('racing:cleanupRace')
AddEventHandler('racing:cleanupRace', function()
    RemoveCheckpoints()
    ClearBlips()
    currentMap = {}
    -- Reset state
    raceStatus.index = 0
    raceStatus.state = RACE_STATE_NONE
    recordedCheckpoints = {}
end)
-- Helper function to clean up recording blips
function cleanupRecording()
    RemoveCheckpoints()
    ClearBlips()
    currentMap = {}
    -- Reset state
    raceStatus.index = 0
    raceStatus.state = RACE_STATE_NONE
    recordedCheckpoints = {}
end

-- Draw 3D text at coordinates
function Draw3DText(x, y, z, text)
    -- Check if coords are visible and get 2D screen coords
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        -- Calculate text scale to use
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = 1.8*(1/dist)*(1/GetGameplayCamFov())*100

        -- Draw text on screen
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0,255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Draw 2D text on screen
function Draw2DText(x, y, text, scale)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
