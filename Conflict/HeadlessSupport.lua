HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )

SupportHandler = EVENTHANDLER:New()

local SpawnsTableConcurrent = {}
local ZeusWaypointData = {}
local ZeusTaskData = {}
local ZeusSpawnedAssets = {}


--Utils----------------------------------------------------------------------------
function _split(str, sep)    
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    
    return result
end

local function ternary ( cond , T , F )
    if cond then return T else return F end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- function SUPPORTWipeSpawnedAssets()
--     for i = 1, #ZeusSpawnedAssets do
--         local spawnedGroup = ZeusSpawnedAssets[i]
--         spawnedGroup:Destroy(false)
--     end
--     ZeusSpawnedAssets = {}
-- end

-- function SUPPORTWipeLastAsset()
--     local spawnedGroup = ZeusSpawnedAssets[#ZeusSpawnedAssets]
--     spawnedGroup:Destroy(false)
--     table.remove( ZeusSpawnedAssets, #ZeusSpawnedAssets )
-- end

-- function SUPPORTResetTankerAWACSTask()
--     local awacsTask = E2EWR:EnRouteTaskAWACS()
--     local awacsEPLRS = E2EWR:TaskEPLRS(true)
--     local awacsRouteTask = E2EWR:TaskOrbitCircleAtVec2(E2EWR:GetUnit(1):GetCoordinate(), E2EWR:GetUnit(1):GetAltitude(), UTILS.KnotsToMps(307))
--     E2EWR:SetTask(awacsTask, 2)
--     E2EWR:PushTask(awacsEPLRS)
--     E2EWR:PushTask(awacsRouteTask, 4)

--     local tanker130Task = KC130Tanker:EnRouteTaskTanker()
--     local tankerRouteTask = tanker:TaskOrbitCircleAtVec2(KC130Tanker:GetUnit(1):GetCoordinate(), KC130Tanker:GetUnit(1):GetAltitude(), UTILS.KnotsToMps(307))
--     KC130Tanker:SetTask(tankerRouteTask, 2)
--     KC130Tanker:PushTask(tanker130Task, 2)
-- end

--------------------------------------------------------------------------------
local destroyZoneCount = 0
function handleExfillRequest(text, coord)

    local destroyZoneName = string.format("destroy %d", destroyZoneCount)
    local zoneRadiusToDestroy = ZONE_RADIUS:New(destroyZoneName, coord:GetVec2(), 800)
    destroyZoneCount = destroyZoneCount + 1
    local function destroyUnit(zoneUnit)
        env.info(string.format("BTI: Found unit in zone %s", destroyZoneName))
        env.info(string.format("BTI: Salvaging command received, executing"))
        zoneUnit:Destroy()
        return true
    end
    zoneRadiusToDestroy:SearchZone(destroyUnit, Object.Category.UNIT)
    CommandCenter:MessageTypeToCoalition( string.format("Exfill complete!"), MESSAGE.Type.Information )
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- -z f13;-altitude 12000;-waypoint something
-- -z f13;-altitude 12000;-task cap
-- -z t90;-amount 5
-- -z t89

function handleZeusRequest(text, coord)

    local arguments = _split(text, ";")
    env.info("BTI: arguments " .. UTILS.OneLineSerialize(arguments))

    -- parse the command string
    local spawnString = ""
    local spawnAmount = 1
    local spawnAltitude = 3000
    local spawnSpeed = UTILS.KnotsToMps(350)
    local spawnTask = ""
    for _,argument in pairs(arguments) do
        local argumentValues = _split(argument, " ")
        env.info("BTI: argumentValue " .. UTILS.OneLineSerialize(arguments))
        local command = argumentValues[1]
        local value = argumentValues[2]

        if command:find("-z") then
            spawnString = value
        elseif command:find("-amount") or command:find("-n")  then
            spawnAmount = tonumber(value)
        elseif command:find("-altitude") or command:find("-a") then
            spawnAltitude = UTILS.FeetToMeters(tonumber(value))
        elseif command:find("-speed") or command:find("-s") then
            spawnSpeed = UTILS.KnotsToMps(tonumber(value))
        elseif command:find("-task") or command:find("-t") then
            spawnTask = value
        end
    end

    -- fetch spawn from table
    local spawnData = ZeusTable[spawnString]
    local spawnSecondaryData = ZeusWaypointData[spawnString]
    local spawnTaskingData = ZeusTaskData[spawnString]
    local spawnType = spawnData["type"]

    -- prepare asset spawn
    local spawn = SpawnsTableConcurrent[spawnString]
    if spawn == nil then
        local newSpawn = SPAWN:New(spawnString)
        SpawnsTableConcurrent[spawnString] = newSpawn
        spawn = newSpawn
    end

    -- task spawned asset
    spawn:OnSpawnGroup(
        function(spawnedGroup)
            if spawnType == "air" then
                if spawnTaskingData ~= nil then
                    env.info("BTI: SpawnTaskingData " .. UTILS.OneLineSerialize(spawnTaskingData))
                    local engageTargets = ternary(spawnTaskingData["engage"] == "a", { "Air" }, { "Planes", "Battle airplanes", })
                    local enrouteEngageZoneTask = spawnedGroup:EnRouteTaskEngageTargetsInZone(
                        spawnTaskingData["coord"]:GetVec2(),
                        spawnTaskingData["radius"],
                        engageTargets,
                        1
                    )
                    trigger.action.removeMark(spawnTaskingData["mark"])
                    spawnedGroup:SetTask(enrouteEngageZoneTask, 2)
                elseif spawnTask == "cap" then
                    local enrouteTask = spawnedGroup:EnRouteTaskEngageTargets( 70000, { "Air" }, 1 )
                    spawnedGroup:SetTask(enrouteTask, 2)
                elseif spawnTask == "jtac" then
                    ctld.JTACAutoLase(spawnedGroup:GetName(), 1686, true, "all", 2)
                elseif spawnTask == "tanker" then
                    local tankerTask = spawnedGroup:EnRouteTaskTanker()
                    spawnedGroup:SetTask(tankerTask)
                end


                local finalCoord = coord
                local finalSpeed = spawnSpeed
                local finalAltitude = spawnAltitude
                if spawnSecondaryData ~= nil then
                    finalCoord = spawnSecondaryData["coord"]
                    finalAltitude = spawnSecondaryData["altitude"]
                    finalSpeed = spawnSecondaryData["speed"]
                    trigger.action.removeMark(spawnSecondaryData["mark"])
                end
                local orbitTask = spawnedGroup:TaskOrbitCircleAtVec2( finalCoord:GetVec2(), finalAltitude, finalSpeed)
                spawnedGroup:PushTask(orbitTask, 4)

            elseif spawnType == "ground" then
                -- route so they get in formation and start their AI
                if spawnTask == "jtac" then
                    ctld.JTACAutoLase(spawnedGroup:GetName(), 1686, true, "all", 2)
                end
                spawnedGroup:RouteToVec2(coord:GetRandomVec2InRadius( 20, 5 ), 5)
            end
            table.insert( ZeusSpawnedAssets, spawnedGroup )
        end
    )

    -- Spawn asset
    for i = 1, spawnAmount do
        spawn:SpawnFromVec2(coord:GetRandomVec2InRadius( 100, 300 ), spawnAltitude, spawnAltitude)
    end
    
    -- Remove Zeus Data and mark for secondary
    ZeusWaypointData[spawnString] = nil
    ZeusTaskData[spawnString] = nil
    if text:find("-x") then
        CommandCenter:MessageToAll( string.format("Requested asset %s times %d spawned", spawnString, spawnAmount))
    end
end


function handleSecondaryRequest(arguments, coord, markID)
    local spawnID = ""
    local waypointAltitude = UTILS.FeetToMeters(10000)
    local zoneRadius = UTILS.NMToMeters(10)
    local waypointSpeed = UTILS.KnotsToMps(350)
    local engageTarget = "a"
    local type = ""

    for _,argument in pairs(arguments) do
        local argumentValues = _split(argument, " ")
        local command = argumentValues[1]
        local value = argumentValues[2]

        env.info("BTI: stop1 " .. UTILS.OneLineSerialize(argumentValues))
        if command:find("-waypoint") or command:find("-engageZone") then
            spawnID = value
            env.info("BTI: stop1.5")
            if command:find("-waypoint") then
                type = "waypoint"
            elseif command:find("-engageZone") then
                type = "engageZone"
            end
        elseif command:find("-altitude") or command:find("-a") then
            waypointAltitude = UTILS.FeetToMeters(tonumber(value))
        elseif command:find("-radius") or command:find("-r") then
            zoneRadius = UTILS.NMToMeters(tonumber(value))
        elseif command:find("-speed") or command:find("-s") then
            waypointSpeed = UTILS.KnotsToMps(tonumber(value))
        elseif command:find("-targets") or command:find("-t") then
            engageTarget = value
        end
    end

    if type:find("waypoint") then
        ZeusWaypointData[spawnID] = {
            ["coord"] = coord,
            ["altitude"] = waypointAltitude,
            ["speed"] = waypointSpeed,
            ["mark"] = markID
        }
        env.info("BTI: SpawnWaypointData " .. UTILS.OneLineSerialize(ZeusWaypointData[spawnID]))
    elseif type:find("engageZone") then
        ZeusTaskData[spawnID] = {
            ["coord"] = coord,
            ["radius"] = zoneRadius,
            ["engage"] = engageTarget,
            ["mark"] = markID
        }
        env.info("BTI: SpawnTaskingData " .. UTILS.OneLineSerialize(ZeusTaskData[spawnID]))
    end
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

function handleCommandRequest(text, coord)
    if text:find("awacs") then
        E2EWR = SPAWN:New('BLUE C EWR E2'):Spawn()
    elseif text:find("smoke") then
        if text:find("green") then
            coord:SmokeGreen()
        elseif text:find("orange") then
            coord:SmokeOrange()
        elseif text:find("blue") then
            coord:SmokeBlue()
        elseif text:find("red") then
            coord:SmokeRed()
        else
            coord:SmokeWhite()
        end
    elseif text:find("flare") then
        if text:find("green") then
            for i=10,1,-1 do coord:FlareGreen() end
        elseif text:find("yellow") then
            for i=10,1,-1 do coord:FlareYellow() end
        elseif text:find("red") then
            for i=10,1,-1 do coord:FlareRed() end
        else
            for i=10,1,-1 do coord:FlareWhite() end
        end
    end
end

function handleDebugRequest(text, coord)
    if text:find("fire") then
        if text:find("big") then
            coord:BigSmokeAndFireLarge()
        elseif text:find("medium") then
            coord:BigSmokeAndFireMedium()
        elseif text:find("inferno") then
            coord:BigSmokeAndFireHuge(1)
        else
            coord:BigSmokeAndFireSmall()
        end
    end
end

local function handleWeatherRequest(text, coord)
    local currentPressure = coord:GetPressure(0)
    local currentTemperature = coord:GetTemperature()
    local currentWindDirection, currentWindStrengh = coord:GetWind()
    local weatherString = string.format("Requested weather: Wind from %d@%.1fkts, QNH %.2f, Temperature %d", currentWindDirection, UTILS.MpsToKnots(currentWindStrengh), currentPressure * 0.0295299830714, currentTemperature)
    CommandCenter:MessageTypeToCoalition(weatherString, MESSAGE.Type.Information)
end

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function markRemoved(Event)
    if Event.text~=nil and Event.text:lower():find("-") then 
        -- local text = Event.text:lower()
        local text = Event.text
        local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
        local coord = COORDINATE:NewFromVec3(vec3)
        coord.y = coord:GetLandHeight()

        if text:find("-fac") then
            handleFACRequest(text, coord)
        elseif text:find("-tanker") then
            handleTankerRequest(text, coord)
        elseif text:find("-support") then
            handleSupportRequest(text, coord)
        elseif text:find("-destroy") then
            handleExfillRequest(text, coord)
        elseif text:find("-command") then
            handleCommandRequest(text, coord)
        elseif text:find("-debug") then
            handleDebugRequest(text, coord)
        elseif text:find("-weather") then
            handleWeatherRequest(text, coord)
        elseif text:find("-z") then
            handleZeusRequest(text, coord)
        end
    end
end

function markChanged(Event)
    if Event.text~=nil and Event.text:lower():find("-") then
        -- local text = Event.text:lower()
        local text = Event.text
        local vec3 = {y=Event.pos.y, x=Event.pos.z, z=Event.pos.x}
        local coord = COORDINATE:NewFromVec3(vec3)
        coord.y = coord:GetLandHeight()

        local arguments = _split(text, ";")
        handleSecondaryRequest(arguments, coord, Event.idx)
    end
end

function SupportHandler:onEvent(Event)
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        -- env.info(string.format("BTI: Support got event ADDED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
    elseif Event.id == world.event.S_EVENT_MARK_CHANGE then
        env.info(string.format("BTI: Support got event CHANGE id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markChanged(Event)
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
        -- env.info(string.format("BTI: Support got event REMOVED id %s idx %s coalition %s group %s text %s", Event.id, Event.idx, Event.coalition, Event.groupID, Event.text))
        markRemoved(Event)
    end
end

world.addEventHandler(SupportHandler)

env.info('BTI: Beyond Support is online')
