env.info("BTI: Starting Zones")

local QeshmZonesList = BeyondPersistedZones["Qeshm"]
local TimeToEvaluate = 60

HQ = GROUP:FindByName("BLUE CC")
CommandCenter = COMMANDCENTER:New( HQ, "HQ" )
captureHelos = SPAWN:New('BLUE H Capture')

ZonesCaptureCoalitions = {}

function InitZoneCoalition(line, keyIndex, zoneName)
    env.info(string.format("BTI: Creating new Coalition Zone with index %d and name %s", keyIndex, zoneName))
    CaptureZone = ZONE:New( zoneName )
    local ZoneCaptureCoalition = ZONE_CAPTURE_COALITION:New( CaptureZone, coalition.side.RED ) 
    ZoneCaptureCoalition:Start( 5, TimeToEvaluate )

    ZonesCaptureCoalitions[line] = {}
    ZonesCaptureCoalitions[line][keyIndex] = ZoneCaptureCoalition

    function ZoneCaptureCoalition:OnEnterGuarded( From, Event, To )
        if From ~= To then
            local Coalition = self:GetCoalition()
            self:E( { Coalition = Coalition } )
            if Coalition == coalition.side.BLUE then
                env.info(string.format("BTI: Zone %s is detected guarded, changing persistence", zoneName))

                BeyondPersistedZones[line][keyIndex]["Coalition"] = coalition.side.BLUE
                ZoneCaptureCoalition:Stop()
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of the USA", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            else
                CommandCenter:MessageTypeToCoalition( string.format( "%s is under protection of Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            end
        end
    end

    function ZoneCaptureCoalition:OnEnterEmpty(From, Event, To)
        local Coalition = self:GetCoalition()
        if From ~= 'Empty' and BeyondPersistedZones[line][keyIndex]["Coalition"] ~= coalition.side.BLUE then
            ZoneCaptureCoalition:Smoke( SMOKECOLOR.Green )
            CommandCenter:MessageTypeToCoalition( string.format( "%s is unprotected, and can be captured! Sending Helos", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
            local coordinate = ZoneCaptureCoalition:GetZone():GetCoordinate()
            captureHelos:OnSpawnGroup(
                function(spawnGroup)
                    env.info(string.format("BTI: Sending helos to zone %s", ZoneCaptureCoalition:GetZoneName()))
                    local task = spawnGroup:TaskLandAtZone(ZoneCaptureCoalition.Zone, 60000, true)
                    spawnGroup:SetTask(task)
                end 
            )
            captureHelos:Spawn()
        end
        
    end

    function ZoneCaptureCoalition:OnEnterAttacked(From, Event, To)
        -- ZoneCaptureCoalition:Smoke( SMOKECOLOR.White )
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE then
            CommandCenter:MessageTypeToCoalition( string.format( "%s is under attack by Iran", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "We are attacking %s", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
    end

    function ZoneCaptureCoalition:OnEnterCaptured(From, Event, To)
        local Coalition = self:GetCoalition()
        self:E({Coalition = Coalition})
        if Coalition == coalition.side.BLUE and BeyondPersistedZones[line][keyIndex]["Coalition"] ~= coalition.side.BLUE then
            env.info(string.format("BTI: Zone %s is detected captured, changing persistence", zoneName))
            BeyondPersistedZones[line][keyIndex]["Coalition"] = coalition.side.BLUE
            CommandCenter:MessageTypeToCoalition( string.format( "We captured %s, Excellent job!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        else
            CommandCenter:MessageTypeToCoalition( string.format( "%s is captured by Iran, we lost it!", ZoneCaptureCoalition:GetZoneName() ), MESSAGE.Type.Information )
        end
        
        self:__Guard( 30 )
    end

    ZoneCaptureCoalition:__Guard(1)







    function ZoneMarkingRefresh(lineName, keyIndexZone, zoneNameParam)
        local Zone = ZoneCaptureCoalition
        if not Zone then
            env.info(string.format("BTI: DEBUG Couldn't get the zone %s for Refresh %s", zoneNameParam, zoneName))
            return
        end
        Zone:Mark()
    end

    function ZoneIntelRefresh(lineName, keyIndexZone, zoneNameParam)
        local Zone = ZoneCaptureCoalition
        if not Zone then
            env.info(string.format("BTI: DEBUG Couldn't get the zone %s for Intel %s", zoneNameParam, zoneName))
            return
        end
        local Coalition = Zone:GetCoalition()
        if Coalition == coalition.side.BLUE then
            if Zone:IsGuarded() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is guarded by BLUFOR", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsAttacked() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by REDFOR, go help!", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsEmpty() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is BLUEFOR but empty", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsCaptured() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by BLUEFOR", Zone:GetZoneName() ), MESSAGE.Type.Information )
            end
        else
            if Zone:IsGuarded() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is captured by the Iranians", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsAttacked() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is attacked by BLUEFOR. Go help them!", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsEmpty() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is empty! Go Capture it!", Zone:GetZoneName() ), MESSAGE.Type.Information )
            elseif Zone:IsCaptured() then
                CommandCenter:MessageTypeToCoalition( string.format( " %s is being captured by Iranians! You lost it", Zone:GetZoneName() ), MESSAGE.Type.Information )
            end
        end
    end

    SCHEDULER:New(nil, ZoneMarkingRefresh, {line, keyIndex, zoneName}, 2, 60)
    SCHEDULER:New(nil, ZoneIntelRefresh, {line, keyIndex, zoneName}, 600, 600)
end





-- Schedule
local interval = 5
for keyIndex, zone in pairs(QeshmZonesList) do
    local seconds = keyIndex * interval
    local zoneName = zone["ZoneName"]
    if zone["Coalition"] ~= coalition.side.BLUE then
        SCHEDULER:New(nil, InitZoneCoalition, {"Qeshm", keyIndex, zoneName}, seconds)
    else
        env.info(string.format("BTI: We need to destroy this zone %s", zoneName))
        local zoneToDestroy = ZONE:New(zoneName)
        local zoneRadiusToDestroy = ZONE_RADIUS:New(zoneName, zoneToDestroy:GetVec2(), 1850)
        local function destroyUnit(zoneUnit)
            env.info(string.format("BTI: Found unit in zone %s, destroying", zoneName))
            zoneUnit:Destroy()
            return true
        end
        zoneRadiusToDestroy:SearchZone(destroyUnit, Object.Category.UNIT)
    end
end

function IntelBriefing()
    CommandCenter:MessageTypeToCoalition("Intel Report to follow\n. Use F10 map markers to find coordinates for each zone.\nCapture them by escorting the convoy that spawns when the zone is undefended.")
end

SCHEDULER:New(nil, IntelBriefing, nil, 600, 600)






















