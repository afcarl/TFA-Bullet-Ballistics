TFA_BALLISTICS = TFA_BALLISTICS or {}
TFA_BALLISTICS.Blacklisted = TFA_BALLISTICS.Blacklisted or {}

local cv_blacklist = CreateConVar("sv_tfa_ballistics_globalblacklist", "1", {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, "Should patcher use global weapon blacklist? (Recommended)")

local function PatchTFAWeapons()
	local blacklisted = {}

	if cv_blacklist:GetBool() then
		if file.Exists("tfa_ballistics_blacklist.txt", "DATA") then
			blacklisted = util.JSONToTable(file.Read("tfa_ballistics_blacklist.txt", "DATA"))
		else
			if SERVER then ErrorNoHalt("[TFA Ballistics] ERROR: No cached copy of blacklist exists, no weapons were blacklisted.\n") end
		end
	end

	TFA_BALLISTICS.Blacklisted = blacklisted

	local newbase = "tfa_ballistic_base"
	blacklisted[newbase] = true

	if not weapons.GetStored(newbase) then return end

	for _, regtbl in ipairs(weapons.GetList()) do
		local wep = weapons.GetStored(regtbl.ClassName)

		if blacklisted[regtbl.ClassName] or not wep.Base or wep.Base ~= "tfa_gun_base" then continue end

		wep.Base = newbase

		if SERVER then print("[TFA Ballistics] Patched " .. regtbl.ClassName) end
	end
end

local function PatchAndFetch()
	TFA_BALLISTICS.PATCHED = true

	if cv_blacklist:GetBool() then
		local req = {}
		req.url = "https://raw.githubusercontent.com/Daxble/TFA-Bullet-Ballistics/master/blacklist.txt"
		req.method = "GET"

		req.success = function(code, body, headers)
			if code == 200 then
				local blacklisted = {}
				local tablefetch = string.Explode(" ", body)

				for k, v in pairs( tablefetch ) do
					blacklisted[v] = true
				end

				local jsonblacklist = util.TableToJSON( blacklisted )
				file.Write("tfa_ballistics_blacklist.txt", jsonblacklist)
			else
				if SERVER then ErrorNoHalt("[TFA Ballistics] ERROR: Could not fetch global blacklist.\n") end
			end

			PatchTFAWeapons()
		end

		req.failed = function( reason )
			if SERVER then ErrorNoHalt("[TFA Ballistics] ERROR: Could not fetch global blacklist.\n") end
			PatchTFAWeapons()
		end

		HTTP(req)
	else
		PatchTFAWeapons()
	end
end

if TFA_BALLISTICS.PATCHED then
	PatchAndFetch()
end

hook.Add("InitPostEntity", "TFA_BALLISTICS_PatchGuns", PatchAndFetch)