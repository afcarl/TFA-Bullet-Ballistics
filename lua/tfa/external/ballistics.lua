TFA_BALLISTICS = TFA_BALLISTICS or {}

TFA_BALLISTICS.Bullets = TFA_BALLISTICS.Bullets or {}

TFA_BALLISTICS.AddBullet = function(damage, velocity, pos, dir, owner, ang, weapon, tracerenabled, tracercolor )

	if SERVER then
		local bulletent

		bulletent = ents.Create("tfa_ballistic_bullet")
		bulletent:SetPos( pos )
		bulletent:SetAngles( ang )
		bulletent:SetOwner( owner )
		bulletent.InitialPos = pos
		bulletent.Color = tracercolor
		bulletent:Spawn()

		local bulletdata = {
			["damage"] = damage,
			["velocity"] = velocity,
			["pos"] = pos,
			["initialpos"] = pos,
			["dir"] = dir,
			["owner"] = owner,
			["ang"] = ang,
			["weapon"] = weapon,
			["ent"] = bulletent,
			["tracer"] = tracereffect,
			["dropamount"] = 0,
			["lifetime"] = 0
		}

		table.insert( TFA_BALLISTICS.Bullets, bulletdata )
	end

end

if SERVER then
	util.AddNetworkString( "TFA_BALLISTICS_DoImpact" )
	util.AddNetworkString( "TFA_BALLISTICS_AddBullet" )

	hook.Add( "Tick", "TFA_BALLISTICS_Tick", function()

		for key, bullet in pairs( TFA_BALLISTICS.Bullets ) do
			TFA_BALLISTICS.Simulate( bullet )
		end

	end)

	TFA_BALLISTICS.Simulate = function( bullet )

		if not IsFirstTimePredicted() then return end

		if not IsValid( bullet["weapon"] ) then
			table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )
			return false
		end

		bullet["lifetime"] = bullet["lifetime"] + ( 0.1 * game.GetTimeScale() )

		bullet["damage"] = bullet["damage"] * 0.9875

		// Velocity
		local sourcevelocity = ( bullet["velocity"] * 3.28084 * 12 / 0.75 )
		local grav_vec = Vector( 0, 0, GetConVarNumber("sv_gravity") )
		local velocity = bullet["dir"] * sourcevelocity
		local finalvelocity = ( velocity - ( (grav_vec * 3.28084 * 12) * bullet["lifetime"] ) * FrameTime() / 2 ) * game.GetTimeScale()

		local windspeed
		local windangle

		// Wind
		if StormFox then
			windspeed = ( ( ( StormFox.GetNetworkData( "Wind" ) * 3.28084 * 12 / 0.95 ) * bullet["lifetime"] ) / 2 ) * game.GetTimeScale()
			windangle = Angle( 0, StormFox.GetNetworkData( "WindAngle" ), 0 )
			windangle:Normalize()
		else
			windspeed = 0
			windangle = Angle( 0, 0, 0 )
		end

		// Final Pos
		local finalpos = bullet["pos"] + ( finalvelocity + ( windangle:Forward() * windspeed ) ) * FrameTime()

		local bullet_trace = util.TraceLine( {
			start = bullet["pos"],
			endpos = finalpos
		} )
		local water_trace = util.TraceLine( {
			start = bullet["pos"],
			endpos = finalpos,
			mask = MASK_WATER }
		)

		if water_trace.Hit then

			BallisticsFireBullet( bullet, water_trace.HitPos, water_trace.HitNormal, water_trace.MatType )

		elseif bullet_trace.Hit and bullet_trace.Entity != bullet["owner"] then

			BallisticsFireBullet( bullet, bullet_trace.HitPos, bullet_trace.HitNormal, bullet_trace.MatType )

		end

		bullet["pos"] = finalpos

		if IsValid( bullet["ent"] ) then
			bullet["ent"]:SetPos( bullet["pos"] )
			bullet["ent"]:SetAngles( finalvelocity:Angle() )
		end

	end

	local impacts = {
		[MAT_METAL] = "Impact.Metal",
		[MAT_SAND] = "Impact.Sand",
		[MAT_WOOD] = "Impact.Wood",
		[MAT_GLASS] = "Impact.Glass",
		[MAT_ANTLION] = "Impact.Antlion",
		[MAT_BLOODYFLESH] = "Impact.BloodyFlesh",
		[MAT_FLESH] = "Blood"
	}

	function MatTypeToDecal( mattype )
		return impacts[mattype] or "Impact.Concrete"
	end

	function BallisticsFireBullet( bullet, hitpos, hitnormal, mattype )

		bullet["weapon"].MainBullet.Attacker = bullet["owner"]
		bullet["weapon"].MainBullet.Inflictor = bullet["weapon"]
		bullet["weapon"].MainBullet.Num = 1
		bullet["weapon"].MainBullet.Src = hitpos
		bullet["weapon"].MainBullet.Dir = bullet["ang"]:Forward()
		bullet["weapon"].MainBullet.HullSize = 1
		bullet["weapon"].MainBullet.Spread.x = 0
		bullet["weapon"].MainBullet.Spread.y = 0
		bullet["weapon"].MainBullet.PenetrationCount = 0
		bullet["weapon"].MainBullet.AmmoType = bullet["weapon"]:GetPrimaryAmmoType()
		bullet["weapon"].MainBullet.Force = bullet["weapon"]:GetStat("Primary.Damage") / 6 * math.sqrt( bullet["weapon"]:GetStat("Primary.KickUp") + bullet["weapon"]:GetStat("Primary.KickDown") + bullet["weapon"]:GetStat("Primary.KickHorizontal")) * 1 * bullet["weapon"]:GetAmmoForceMultiplier()
		bullet["weapon"].MainBullet.Damage = bullet["damage"]
		bullet["weapon"].MainBullet.HasAppliedRange = false
		bullet["weapon"].MainBullet.TracerName = ""

		if bullet["weapon"].CustomBulletCallback then
			bullet["weapon"].MainBullet.Callback2 = bullet["weapon"].CustomBulletCallback
		end

		bullet["weapon"].MainBullet.Callback = function(a, b, c)
			if IsValid( bullet["weapon"] ) then
				c:SetInflictor(bullet["weapon"])
				if bullet["weapon"].MainBullet.Callback2 then
					bullet["weapon"].MainBullet.Callback2(a, b, c)
				end

				bullet["weapon"].MainBullet:Penetrate(a, b, c, bullet["weapon"])
			end
		end

		bullet["weapon"]:GetOwner():FireBullets( bullet["weapon"].MainBullet)

		util.Decal( MatTypeToDecal( mattype ), hitpos + hitnormal, hitpos - hitnormal)

		net.Start( "TFA_BALLISTICS_DoImpact" )
			net.WriteEntity( bullet["weapon"] )
			net.WriteVector( hitpos )
			net.WriteVector( hitnormal )
			net.WriteInt( mattype, 32 )
		net.Broadcast()

		if IsValid( bullet["ent"] ) then
			bullet["ent"]:StopParticles()
			SafeRemoveEntity( bullet["ent"] )
		end

		timer.Simple( 0, function()
			table.RemoveByValue( TFA_BALLISTICS.Bullets, bullet )
		end )

	end
else
	local function genOrderedTbl(str, min, max)
		if not min then min = 1 end
		if not max then
			max = min
			min = 1
		end
		local tbl = {}
		for i=min, max do
			table.insert(tbl, str:format(i))
		end
		return tbl
	end

	local subsonicsounds = genOrderedTbl(">ballistics/subsonic/%i.wav", 27)
	local supersonicsounds = genOrderedTbl("ballistics/supersonic/%i.wav", 12)

	sound.Add( {
		name = "TFA_BALLISTICS.Subsonic",
		channel = CHAN_STATIC,
		volume = 0.5,
		level = 97,
		pitch = { 95, 110 },
		sound = subsonicsounds
	} )

	sound.Add( {
		name = "TFA_BALLISTICS.Supersonic",
		channel = CHAN_STATIC,
		volume = { 0.9, 1.0 },
		level = 97,
		pitch = { 95, 110 },
		sound = supersonicsounds
	} )

	net.Receive( "TFA_BALLISTICS_DoImpact", function ()
		local weapon = net.ReadEntity()
		local hitpos = net.ReadVector()
		local hitnormal = net.ReadVector()
		local mattype = net.ReadInt( 32 )
		if weapon.ImpactEffectFunc then
			weapon:ImpactEffectFunc( hitpos, hitnormal, mattype )
		end
	end)

	net.Receive( "TFA_BALLISTICS_StopParticles", function ()
		local ent = net.ReadEntity()
		ent:StopParticles()
	end)

	net.Receive( "TFA_BALLISTICS_SendWindSpeed", function ()
		local windspeed = net.ReadInt( 32 )
		TFA_BALLISTICS.WindSpeed = windspeed
	end)

	surface.CreateFont( "TFA_BALLISTICS_Font", {
		font = "Roboto Condensed",
		extended = false,
		size = ScreenScale( 11 ), -- will not update after screen resolution change
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
end
