include('shared.lua')

DEFINE_BASECLASS(SWEP.Base)

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

function SWEP:DrawHUD()
	BaseClass.DrawHUD( self )

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
