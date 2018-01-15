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

			local jsonblacklist = util.TableToJSON( blacklisted )
			file.Write( "tfa_ballistics_blacklist.txt", jsonblacklist )

			TFA_BALLISTICS.PATCHED = true

			if not weapons.GetStored(newbase) then return end

			for _, regtbl in ipairs(weapons.GetList()) do
				local wep = weapons.GetStored(regtbl.ClassName)

				if blacklisted[regtbl.ClassName] or not wep.Base or wep.Base ~= "tfa_gun_base" then continue end

				wep.Base = newbase

				if SERVER then
					print( "[TFA Ballistics] Patched " .. regtbl.ClassName )
				end
			end

		end,
		function( error )

			local tablefetch

			if file.Exists( "tfa_ballistics_blacklist.txt", "DATA" ) then
				tablefetch = util.JSONToTable( file.Read( "tfa_ballistics_blacklist.txt", "DATA" ) )
			else
				if SERVER then Error( "ERROR: [TFA Ballistics] Could not fetch blacklist and no local copy exists, no weapons were blacklisted.\n" ) end
				tablefetch = {}
			end

			blacklisted = tablefetch

			local newbase = "tfa_ballistic_base"
			blacklisted[newbase] = true

			TFA_BALLISTICS.PATCHED = true

			if not weapons.GetStored(newbase) then return end

			for _, regtbl in ipairs(weapons.GetList()) do
				local wep = weapons.GetStored(regtbl.ClassName)

				if blacklisted[regtbl.ClassName] or not wep.Base or wep.Base ~= "tfa_gun_base" then continue end

				wep.Base = newbase
				
				if SERVER then
					print( "[TFA Ballistics] Patched " .. regtbl.ClassName )
				end
			end
		end )
end

if TFA_BALLISTICS.PATCHED then
	PatchTFAWeapons()
end

hook.Add("InitPostEntity", "TFA_BALLISTICS_PatchGuns", PatchTFAWeapons)