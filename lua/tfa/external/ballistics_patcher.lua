TFA_BALLISTICS = TFA_BALLISTICS or {}

local blacklisted = {
	-- ["classname"] = true, -- only useful for things that are REALLY broken
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

		if SERVER then print("[TFA Ballistics] Patched ".. regtbl.ClassName) end
	end
end

if TFA_BALLISTICS.PATCHED then
	PatchTFAWeapons()
end

hook.Add("InitPostEntity", "TFA_BALLISTICS_PatchGuns", PatchTFAWeapons)