TFA_BALLISTICS = TFA_BALLISTICS or {}

local function PatchTFAWeapons()
		
	local blacklisted = {}

	http.Fetch( "https://raw.githubusercontent.com/Daxble/TFA-Bullet-Ballistics/master/blacklist.txt",
		function( body, len, headers, code )
			local tablefetch = string.Explode( " ", body )
			
			for k, v in pairs( tablefetch ) do
				blacklisted[v] = true
			end
			
			local newbase = "tfa_ballistic_base"
			blacklisted[newbase] = true
			
			TFA_BALLISTICS.PATCHED = true

			if not weapons.GetStored(newbase) then return end

			for _, regtbl in ipairs(weapons.GetList()) do
				local wep = weapons.GetStored(regtbl.ClassName)
				
				if blacklisted[regtbl.ClassName] or not wep.Base or wep.Base ~= "tfa_gun_base" then continue end

				wep.Base = newbase

				wep.Primary.Velocity = TFA_BALLISTICS.AmmoVelocity[ table.KeyFromValue( TFA_BALLISTICS.AmmoNames, wep.Primary.Ammo ) ] or 500

				if SERVER and velocity != nil then
					print( "[TFA Ballistics] Patched " .. regtbl.ClassName )
				elseif SERVER then
					print( "[TFA Ballistics] Patched " .. regtbl.ClassName )
				end
			end
			
		end,
		function( error )
			print("[TFA BALLISTICS] Failed to fetch blacklist, no weapons have been patched to use ballistics, please report this to Daxble.")
		end
	)
	
end

if TFA_BALLISTICS.PATCHED then
	PatchTFAWeapons()
end

hook.Add("InitPostEntity", "TFA_BALLISTICS_PatchGuns", PatchTFAWeapons)