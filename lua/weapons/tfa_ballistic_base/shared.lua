SWEP.Base = "tfa_gun_base"

DEFINE_BASECLASS(SWEP.Base)

SWEP.EnableTracer = true
SWEP.TracerColor = Color( 255, 0, 0 )

local TracerName
local cv_forcemult = GetConVar("sv_tfa_force_multiplier")

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() and not game.SinglePlayer() and not CLIENT then return end
	
	if self:GetStat("Primary.Projectile") then
		return BaseClass.ShootBullet(self, damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	end

	num_bullets = num_bullets or 1
	aimcone = aimcone or 0


	if self.Owner:GetShootPos():Distance( self.Owner:GetEyeTrace().HitPos ) >= 1000 then
		for i = 1, num_bullets do
			local velocity = self:GetStat("Primary.Velocity")

			local angles = self.Owner:EyeAngles()

			angles:RotateAroundAxis( angles:Right(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)
			angles:RotateAroundAxis( angles:Up(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)

			TFA_BALLISTICS.AddBullet( damage, velocity, self.Owner:GetShootPos(), angles:Forward(), self.Owner, self.Owner:GetAngles(), self, self.EnableTracer, self.TracerColor )
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
		self.MainBullet.Force = damage / 6 * math.sqrt(self:GetStat("Primary.KickUp") + self:GetStat("Primary.KickDown") + self:GetStat("Primary.KickHorizontal")) * cv_forcemult:GetFloat() * self:GetAmmoForceMultiplier()
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

function SWEP:ImpactEffectFunc(pos, normal, mattype)
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

function SWEP:DoImpactEffect()
end
