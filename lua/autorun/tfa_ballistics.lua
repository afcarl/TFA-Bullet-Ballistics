TFA_BALLISTICS = {}

TFA_BALLISTICS.Bullets = {}

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

      local subsonicsounds = genOrderedTbl("ballistics/subsonic/%i.wav", 27)
      local supersonicsounds = genOrderedTbl("ballistics/supersonic/%i.wav", 12)

      sound.Add( {
      	name = "TFA_BALLISTICS.Subsonic",
      	channel = CHAN_AUTO,
      	volume = 1.0,
      	level = 100,
      	pitch = { 95, 110 },
      	sound = subsonicsounds
      } )

      sound.Add( {
      	name = "TFA_BALLISTICS.Supersonic",
      	channel = CHAN_AUTO,
      	volume = 1.0,
      	level = 100,
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
      	size = ScreenScale( 11 ),
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

local TracerName

function TFA_BALLISTICS_ShootBullet(self, damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride, velocity)
	if not IsFirstTimePredicted() and not game.SinglePlayer() and not CLIENT then return end
	num_bullets = num_bullets or 1
	aimcone = aimcone or 0

	if self.Owner:GetShootPos():Distance( self.Owner:GetEyeTrace().HitPos ) >= 1000 then
		for i = 1, num_bullets do

			local angles = self.Owner:EyeAngles()

			angles:RotateAroundAxis( angles:Right(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)
			angles:RotateAroundAxis( angles:Up(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)

			TFA_BALLISTICS.AddBullet( damage, velocity, self.Owner:GetShootPos(), angles:Forward(), self.Owner, self.Owner:GetAngles(), self, self.EnableTracer, Color( 255, 93, 0 ) )
		end
	else
		if self.Tracer == 1 then
			TracerName = "Ar2Tracer"
		elseif self.Tracer == 2 then
			TracerName = "AirboatGunHeavyTracer"
		else
			TracerName = "Tracer"
		end

		self.MainBullet.PCFTracer = nil

		if self.TracerName and self.TracerName ~= "" then
			if self.TracerPCF then
				TracerName = nil
				self.MainBullet.PCFTracer = self.TracerName
				self.MainBullet.Tracer = 0
			else
				TracerName = self.TracerName
			end
		end

		self.MainBullet.Attacker = self:GetOwner()
		self.MainBullet.Inflictor = self
		self.MainBullet.Num = num_bullets
		self.MainBullet.Src = self:GetOwner():GetShootPos()
		self.MainBullet.Dir = self:GetOwner():GetAimVector()
		self.MainBullet.HullSize = self:GetStat("Primary.HullSize") or 0
		self.MainBullet.Spread.x = aimcone
		self.MainBullet.Spread.y = aimcone
		if self.TracerPCF then
			self.MainBullet.Tracer = 0
		else
			self.MainBullet.Tracer = self.TracerCount and self.TracerCount or 3
		end
		self.MainBullet.TracerName = TracerName
		self.MainBullet.PenetrationCount = 0
		self.MainBullet.AmmoType = self:GetPrimaryAmmoType()
		self.MainBullet.Force = damage / 6 * math.sqrt(self:GetStat("Primary.KickUp") + self:GetStat("Primary.KickDown") + self:GetStat("Primary.KickHorizontal")) * GetConVar("sv_tfa_force_multiplier"):GetFloat() * self:GetAmmoForceMultiplier()
		self.MainBullet.Damage = damage
		self.MainBullet.HasAppliedRange = false

		if self.CustomBulletCallback then
			self.MainBullet.Callback2 = self.CustomBulletCallback
		end

		self.MainBullet.Callback = function(a, b, c)
			if IsValid(self) then
				c:SetInflictor(self)
				if self.MainBullet.Callback2 then
					self.MainBullet.Callback2(a, b, c)
				end

				self.MainBullet:Penetrate(a, b, c, self)

				self:PCFTracer( self.MainBullet, b.HitPos or vector_origin )
			end
		end

		self:GetOwner():FireBullets(self.MainBullet)
	end
end

function TFA_BALLISTICS_ImpactEffectFunc( self, pos, normal, mattype )
      local enabled = true

	if enabled then
		local fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetNormal(normal)

		if self:CanDustEffect(mattype) then
			util.Effect("tfa_dust_impact", fx)
		end

		if self:CanSparkEffect(mattype) then
			util.Effect("tfa_metal_impact", fx)
		end

		local scal = math.sqrt(self:GetStat("Primary.Damage") / 30)
		if mattype == MAT_FLESH then
			scal = scal * 0.25
		end
		fx:SetEntity(self:GetOwner())
		fx:SetMagnitude(mattype or 0)
		fx:SetScale( scal )
		util.Effect("tfa_bullet_impact", fx)

		if self.ImpactEffect then
			util.Effect(self.ImpactEffect, fx)
		end
	end
end

if CLIENT then
      local cos, sin, abs, max, rad1, log, pow = math.cos, math.sin, math.abs, math.max, math.rad, math.log, math.pow
      local surface = surface
      function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color)
      	surface.SetDrawColor(color)
      	surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness))
      end

      function surface.DrawArc(arc)
      	for k,v in ipairs(arc) do
      		surface.DrawPoly(v)
      	end
      end

      function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness)
      	local quadarc = {}
      	local startang,endang = startang or 0, endang or 0
      	local diff = abs(startang-endang)
      	local smoothness = log(diff,2)/2
      	local step = diff / (pow(2,smoothness))
      	if startang > endang then
      		step = abs(step) * -1
      	end
      	local inner = {}
      	local outer = {}
      	local ct = 1
      	local r = radius - thickness
      	for deg=startang, endang, step do
      		local rad = rad1(deg)
      		local cosrad, sinrad = cos(rad), sin(rad)
      		local ox, oy = cx+(cosrad*r), cy+(-sinrad*r)
      		inner[ct] = {
      			x=ox,
      			y=oy,
      			u=(ox-cx)/radius + .5,
      			v=(oy-cy)/radius + .5,
      		}
      		local ox2, oy2 = cx+(cosrad*radius), cy+(-sinrad*radius)
      		outer[ct] = {
      			x=ox2,
      			y=oy2,
      			u=(ox2-cx)/radius + .5,
      			v=(oy2-cy)/radius + .5,
      		}
      		ct = ct + 1
      	end
      	for tri=1,ct do
      		local p1,p2,p3,p4
      		local t = tri+1
      		p1=outer[tri]
      		p2=outer[t]
      		p3=inner[t]
      		p4=inner[tri]
      		quadarc[tri] = {p1,p2,p3,p4}
      	end
      	return quadarc

      end

      function draw.Circle( x, y, radius, seg )
      local cir = {}

      table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
      	for i = 0, seg do
      		local a = math.rad( ( i / seg ) * -360 )
      		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
      	end

      	local a = math.rad( 0 )
      	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

      	surface.DrawPoly( cir )
      end

      local whitemat = CreateMaterial( "tfa_ballistics_nocull", "UnlitGeneric", {
      	["$translucent"] = "1",
      	["$vertexcolor"] = "1",
      	["$vertexalpha"] = "1",
      	["$ignorez"] = "1",
      	["$no_fullbright"] = "1",
      	["$nocull"] = "1"
      } )

      function TFA_BALLISTICS_DrawHUD( self )
            local baseclass = baseclass.Get( self.ClassName )

            baseclass.DrawHUD( self )

      	if StormFox then
      		draw.NoTexture()

      		surface.SetDrawColor( 26, 26, 26, 150 )
      		draw.Circle( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ), ScrW() * 0.02, 30 )

      		surface.SetDrawColor( 26, 26, 26, 200 )
      		draw.Circle( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ), ScrW() * 0.016, 30 )

      		startAng = ( StormFox.GetNetworkData( "WindAngle" ) + ( LocalPlayer():GetAngles().y * -1 ) + 90) - ( StormFox.GetNetworkData( "Wind" ) )
      		endAng = ( StormFox.GetNetworkData( "WindAngle" ) + ( LocalPlayer():GetAngles().y * -1 ) + 90) + ( StormFox.GetNetworkData( "Wind" ) )

      		surface.DrawCircle( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ) , ScrW() * 0.0196, 26, 26, 26, 200)

      		surface.SetFont( "TFA_BALLISTICS_Font" )
      		surface.SetTextColor( 225, 225, 225 )
      		local width, height = surface.GetTextSize( math.Round( StormFox.GetNetworkData( "Wind" ) ) )
      		surface.SetTextPos( ( ScrW() / 2 ) - ( width / 2 ), ( ScrH() - ( ScrW() * 0.02 ) ) - ( height / 2 ) )
      		surface.DrawText( math.Round( StormFox.GetNetworkData( "Wind" ) ) )

      		render.SetMaterial( whitemat )
      		surface.SetMaterial( whitemat )

      		draw.Arc( ScrW() / 2, ScrH() - ( ScrW() * 0.02 ), ScrW() * 0.02, ScrW() * 0.004, startAng, endAng, 1, Color(225, 225, 225) )
      	end
      end
end

if SERVER then
      if not file.Exists( "tfa_ballistics_blacklist.txt", "DATA" ) then
            local init = {
                  "tfa_gun_base"
            }
            local insertjson = util.TableToJSON( init )
            file.Write( "tfa_ballistics_blacklist.txt", insertjson )
      end

      local table = util.JSONToTable( file.Read( "tfa_ballistics_blacklist.txt", "DATA" ) )
end

concommand.Add( "tfa_ballistics_blacklist_weapon", function( ply, cmd, args )
      if not ply:IsPlayer() then
            local tabled = util.JSONToTable( file.Read( "tfa_ballistics_blacklist.txt", "DATA" ) )
            table.insert( tabled, args[1] )
            local insertjson = util.TableToJSON( tabled )
            file.Write( "tfa_ballistics_blacklist.txt", insertjson )
      end
end )

concommand.Add( "tfa_ballistics_unblacklist_weapon", function( ply, cmd, args )
      if game.SinglePlayer() or not ply:IsPlayer() then
            local tabled = util.JSONToTable( file.Read( "tfa_ballistics_blacklist.txt", "DATA" ) )
            if table.HasValue( tabled, args[1] ) then
                  table.RemoveByValue( tabled, args[1] )
            else
                  print("Weapon not found in blacklist")
            end
            local insertjson = util.TableToJSON( tabled )
            file.Write( "tfa_ballistics_blacklist.txt", insertjson )
      end
end )

hook.Add( "InitPostEntity", "TFA_BALLISTICS_Conversion", function()
      local blacklist = util.JSONToTable( file.Read( "tfa_ballistics_blacklist.txt", "DATA" ) )
      for k, v in pairs( weapons.GetList() ) do
            if v and string.find( v.ClassName, "tfa_" ) and not string.find(v.ClassName, "_base") and not table.HasValue( blacklist, v.ClassName ) then
                  local weapon = weapons.GetStored( v.ClassName )
                  v.ShootBullet = function( self, damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride )
                        TFA_BALLISTICS_ShootBullet( self, damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride, 500 )
                  end
                  v.ImpactEffectFunc = function( self, pos, normal, mattype )
                        TFA_BALLISTICS_ImpactEffectFunc( self, pos, normal, mattype )
                  end
                  v.DrawHUD = function( self )
                        TFA_BALLISTICS_DrawHUD( self )
                  end
            end
      end
end )
