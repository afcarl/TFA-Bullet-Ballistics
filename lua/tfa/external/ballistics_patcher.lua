TFA_BALLISTICS = TFA_BALLISTICS or {}

local blacklisted = {
	["tfa_ins2_codol_free"] = true,
}

local newbase = "tfa_ballistic_base"
blacklisted[newbase] = true -- :thonk:

local function PatchTFAWeapons()
	TFA_BALLISTICS.PATCHED = true

	if not weapons.GetStored(newbase) then return end

	for _, regtbl in ipairs(weapons.GetList()) do
		if blacklisted[regtbl.ClassName] then continue end

		local wep = weapons.GetStored(regtbl.ClassName)

		if not wep.Base or wep.Base ~= "tfa_gun_base" then continue end -- we're patching only tfa base weapons, anything else that derives them doesnt need to be patched

		wep.Base = newbase

		local velocity = TFA_BALLISTICS.AmmoVelocity[ table.KeyFromValue( TFA_BALLISTICS.AmmoNames, wep.Primary.Ammo ) ] or 500

		wep.Primary.Velocity = velocity

		/*
		if not wep.Primary.Velocity then -- trying to autodetect velocity, probably needs improvements
			if wep.Primary.ProjectileVelocity and wep.Primary.ProjectileVelocity > 0 then
				wep.Primary.Velocity = wep.Primary.ProjectileVelocity
			elseif wep.ProjectileVelocity and wep.ProjectileVelocity > 0 then
				wep.Primary.Velocity = wep.ProjectileVelocity
			elseif wep.Velocity and wep.Velocity > 0 then
				wep.Primary.Velocity = wep.Velocity
			else
				wep.Primary.Velocity = 500
			end
		end
		*/

		if SERVER and velocity != nil then
			print("[TFA Ballistics] Patched " .. regtbl.ClassName .. ", velocity is " .. tostring( velocity ))
		elseif SERVER then
			print("[TFA Ballistics] Patched " .. regtbl.ClassName .. ", velocity is " .. "500")
		end
	end
end

if TFA_BALLISTICS.PATCHED then
	PatchTFAWeapons()
end

hook.Add("InitPostEntity", "TFA_BALLISTICS_PatchGuns", PatchTFAWeapons)
