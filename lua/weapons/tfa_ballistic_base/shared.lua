SWEP.Base = "tfa_gun_base"

DEFINE_BASECLASS(SWEP.Base)

SWEP.Primary.Velocity = 0

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	if not IsFirstTimePredicted() then return end

	if TFA_BALLISTICS.Blacklisted[self:GetClass()] or self:GetStat("Primary.Projectile") then
		return BaseClass.ShootBullet(self, damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	end

	num_bullets = num_bullets or 1
	aimcone = aimcone or 0

	self.Primary.Velocity = TFA_BALLISTICS.AmmoTypes[self:GetStat("Primary.Ammo")] or 500

	if self.Owner:GetShootPos():Distance( self.Owner:GetEyeTrace().HitPos ) >= 500 then
		for i = 1, num_bullets do
			local angles = self.Owner:EyeAngles()

			angles:RotateAroundAxis( angles:Right(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)
			angles:RotateAroundAxis( angles:Up(), ( -aimcone / 2 + math.Rand(0, aimcone) ) * 90)
			
			TFA_BALLISTICS.AddBullet( damage, self.Primary.Velocity, self.Owner:GetShootPos(), angles:Forward(), self.Owner, self.Owner:GetAngles(), self )
		end
	else
		return BaseClass.ShootBullet(self, damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)
	end
end

function SWEP:DoImpactEffect(tr, dmgtype)
	if tr.HitSky then return true end
	local ib = self.BashBase and IsValid(self) and self:GetBashing()
	local dmginfo = DamageInfo()
	dmginfo:SetDamageType(dmgtype)

	if ib and self.Secondary.BashDamageType == DMG_GENERIC then return true end
	if ib then return end

	if IsValid(self) then
		self:ImpactEffectFunc(tr.HitPos, tr.HitNormal, tr.MatType)
	end
end
